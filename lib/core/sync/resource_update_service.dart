import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/models.dart';
import '../../data/services/catalog_service.dart';
import '../../features/dictionary/dictionary_repository.dart';
import '../storage/app_database.dart';
import 'game_cache_service.dart';

/// Recurso remoto cuya frescura se comprueba en cada arranque.
enum TrackedResource {
  games('GAME'),
  dictionary('DICTIONARY');

  final String key;
  const TrackedResource(this.key);
}

/// Se dispara en cada arranque de la app: consulta
/// `GET /api/catalog/updates?since=<cursor>` y aplica el delta que devuelve.
///
/// El backend responde con los **ids** de lo que cambió (juegos y palabras)
/// y su `changeType`, no con el contenido. Con eso se descarga solo lo que
/// falta —`GET /api/games/{id}/preview` y
/// `GET /api/dictionary/words/details/{id}`— en vez de volver a bajar el
/// catálogo entero como hacían los antiguos `/api/games/updatedGames` y
/// `/api/dictionary/updatedWords`, que solo daban una fecha.
///
/// Tres reglas que gobiernan este archivo:
///
/// 1. **El cursor es el `serverTime` de la respuesta**, guardado como texto
///    y reenviado verbatim. Se compara contra el reloj del servidor, así que
///    usar la hora del dispositivo perdería cambios por desfase, y parsearlo
///    a `DateTime` lo reinterpretaría en la zona local (el backend lo emite
///    como `LocalDateTime`, sin zona).
/// 2. **Un cursor por recurso.** Si los juegos se aplican pero el
///    diccionario falla, solo avanza el de `GAME`; el de `DICTIONARY` se
///    reintenta desde donde estaba en el próximo arranque. Como se manda un
///    solo `since` (el más atrasado de los dos), el recurso adelantado puede
///    recibir cambios que ya aplicó: re-descargar es idempotente y volver a
///    borrar un id ya borrado no hace nada.
/// 3. **`DELETED` sí se obedece.** El principio de "el refresco automático
///    nunca vacía una caché" nació porque una lista completa vacía o corta
///    es indistinguible de un backend caído; un id marcado `DELETED` es la
///    afirmación positiva que faltaba. No hay ningún camino automático que
///    borre en bloque: un vaciado real solo pasa por "Restablecer datos
///    offline" en Perfil (`AppDatabase.resetOfflineCaches()`) o por el botón
///    de actualizar del diccionario (`DictionaryController.refresh`).
class ResourceUpdateService {
  final CatalogService _catalog;
  final AppDatabase _db;
  final GameCacheService _gameCache;
  final DictionaryRepository _dictionaryRepo;

  ResourceUpdateService(
    this._catalog,
    this._db,
    this._gameCache,
    this._dictionaryRepo,
  );

  /// Devuelve el subconjunto de [TrackedResource] que efectivamente cambió,
  /// para que quien llame (p.ej. `AppShell`) invalide los providers
  /// correspondientes si ya estaban en memoria.
  Future<Set<TrackedResource>> checkAndRefresh() async {
    final since = await _since();

    final CatalogUpdates updates;
    try {
      updates = await _catalog.getUpdates(since: since);
    } catch (_) {
      return const {}; // sin red u otro fallo: no bloquear el arranque
    }

    // Primera sincronización (sin cursor de ninguno de los dos recursos):
    // el delta llega con el catálogo completo, pero la app ya viene sembrada
    // por el bundle (`GameCacheService.seedFromBundleIfNewer`,
    // `DictionaryController`). Bajar aquí cada id por separado serían
    // cientos de peticiones para reconstruir lo que ya tenemos: se guarda el
    // cursor y a partir del próximo arranque los deltas ya son exactos.
    if (since == null) {
      await _advance(TrackedResource.games, updates.serverTime, null);
      await _advance(TrackedResource.dictionary, updates.serverTime, null);
      return const {};
    }

    final refreshed = <TrackedResource>{};
    if (await _applyDelta(
      resource: TrackedResource.games,
      changes: updates.games,
      serverTime: updates.serverTime,
      apply: (upsert, deleted) =>
          _gameCache.applyGameDelta(upsertIds: upsert, deletedIds: deleted),
    )) {
      refreshed.add(TrackedResource.games);
    }
    if (await _applyDelta(
      resource: TrackedResource.dictionary,
      changes: updates.words,
      serverTime: updates.serverTime,
      apply: (upsert, deleted) => _dictionaryRepo.applyWordDelta(
          upsertIds: upsert, deletedIds: deleted),
    )) {
      refreshed.add(TrackedResource.dictionary);
    }
    return refreshed;
  }

  /// `since` a enviar: el **más atrasado** de los dos cursores, para que el
  /// recurso que va por detrás no se salte sus cambios.
  ///
  /// Si alguno nunca se sincronizó y tampoco tiene fecha de bundle usable,
  /// se devuelve null y el backend manda el catálogo completo.
  Future<String?> _since() async {
    final games =
        await _cursorFor(TrackedResource.games, _gameCache.bundleGeneratedAt);
    final words = await _cursorFor(
        TrackedResource.dictionary, _dictionaryRepo.bundleGeneratedAt);
    if (games == null || words == null) return null;

    final gamesAt = DateTime.tryParse(games);
    final wordsAt = DateTime.tryParse(words);
    // Si alguno no se puede comparar, se pide el catálogo completo antes que
    // arriesgarse a saltar cambios con una comparación inventada.
    if (gamesAt == null || wordsAt == null) return null;
    return gamesAt.isBefore(wordsAt) ? games : words;
  }

  /// Cursor de un recurso: el `serverTime` de la última sincronización
  /// aplicada o, si nunca hubo, la fecha del snapshot empaquetado — una
  /// instalación nueva ya trae el bundle, así que no tiene sentido pedir
  /// todo lo anterior a esa fecha.
  Future<String?> _cursorFor(
    TrackedResource resource,
    Future<DateTime?> Function() bundleGeneratedAt,
  ) async {
    final row = await _db.resourceUpdate(resource.key);
    final cursor = row?.syncCursor;
    if (cursor != null && cursor.isNotEmpty) return cursor;
    try {
      // `scripts/export_*.py` escriben `datetime.now().isoformat()`, sin
      // zona, igual que el `LocalDateTime` del backend: el round-trip por
      // DateTime devuelve exactamente la misma cadena.
      return (await bundleGeneratedAt())?.toIso8601String();
    } catch (_) {
      return null;
    }
  }

  /// true si hubo cambios y se aplicaron todos.
  Future<bool> _applyDelta({
    required TrackedResource resource,
    required List<CatalogChange> changes,
    required String? serverTime,
    required Future<bool> Function(Set<int> upsert, Set<int> deleted) apply,
  }) async {
    if (changes.isEmpty) {
      // Nada que hacer, pero sí estamos al día hasta `serverTime`.
      await _advance(resource, serverTime, null);
      return false;
    }

    final deleted = <int>{};
    final upsert = <int>{};
    for (final c in changes) {
      // Un DELETED nunca se descarga: el backend ya no lo tiene y
      // respondería 404.
      (c.isDeleted ? deleted : upsert).add(c.id);
    }

    final bool ok;
    try {
      ok = await apply(upsert, deleted);
    } catch (_) {
      return false;
    }
    // Aplicado a medias: no se avanza el cursor, para que el próximo
    // arranque reintente el mismo rango en vez de darlo por hecho.
    if (!ok) return false;

    // `changes` viene del cambio más antiguo al más reciente.
    await _advance(resource, serverTime, changes.last);
    return true;
  }

  Future<void> _advance(
    TrackedResource resource,
    String? serverTime,
    CatalogChange? last,
  ) async {
    // Sin reloj del servidor no hay cursor fiable que guardar; se deja como
    // estaba y se reintenta.
    if (serverTime == null || serverTime.isEmpty) return;
    await _db.putResourceUpdate(ResourceUpdatesCompanion(
      resource: Value(resource.key),
      syncCursor: Value(serverTime),
      // Informativas. `Value.absent()` cuando no hubo cambios para no borrar
      // el último que sí se registró.
      lastUpdatedAt:
          last == null ? const Value.absent() : Value(last.updatedAt),
      lastChangeType:
          last == null ? const Value.absent() : Value(last.changeType),
      lastResourceId: last == null ? const Value.absent() : Value(last.id),
    ));
  }
}

final resourceUpdateServiceProvider = Provider<ResourceUpdateService>((ref) =>
    ResourceUpdateService(
      ref.watch(catalogServiceProvider),
      ref.watch(appDatabaseProvider),
      ref.watch(gameCacheServiceProvider),
      ref.watch(dictionaryRepositoryProvider),
    ));
