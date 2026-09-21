import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/models.dart';
import '../../data/services/activity_service.dart';
import '../storage/app_database.dart';
import '../storage/media_store.dart';
import 'asset_preloader.dart';

int? _asInt(dynamic v) =>
    v == null ? null : (v is int ? v : int.tryParse(v.toString()));

/// Caché offline de juegos: `CachedGames`, sin ningún camino que baje el
/// catálogo entero.
///
/// El único listado paginado de juegos (`GET /api/games`) es
/// `hasAnyRole("TEACHER", "ADMIN")` en el backend (`SecurityConfig.java`) —
/// esta app solo tiene estudiante/visitante, así que ese endpoint no es
/// alcanzable nunca, no solo "a veces". El flujo real:
///
/// 1. **Bundle** (`assets/games/manifest.json`, `scripts/export_games.py`):
///    siembra `CachedGames` sin red — ver [seedFromBundleIfNewer].
/// 2. **Delta incremental** (`GET /api/catalog/updates`, disparado por
///    `ResourceUpdateService`): por cada id que cambió,
///    `GET /api/games/{id}` (metadatos) + `GET /api/games/{id}/preview`
///    (contenido jugable) — ver [applyGameDelta]. Nunca
///    `POST /api/activities/start/game/{id}`: eso crea una actividad real en
///    el servidor y se reserva para cuando el usuario juega de verdad
///    (`GameSessionController.startFromGame`).
/// 3. **Mapa (progresión) y panel libre**: filtran `CachedGames` por
///    `topic`/`gameType` en memoria (`progress_providers.dart`,
///    `games_providers.dart`). Nunca `GET /api/games/topic/{topic}`: ese
///    endpoint no devuelve el tema por juego, así que persistir su
///    resultado a ciegas fue lo que causaba que `topic` se borrara solo y
///    el mapa se re-descargara en cada arranque.
class GameCacheService {
  final ActivityService _service;
  final AppDatabase _db;
  final MediaStore _mediaStore;

  bool _running = false;

  GameCacheService(this._service, this._db, this._mediaStore);

  // Bundle de juegos cacheado en memoria.
  List<CachedGamesCompanion>? _bundleGames;
  DateTime? _bundleGeneratedAt;

  static const _bundleSeededAtKey = 'games_bundle_seeded_at';

  /// Fecha del snapshot empaquetado por `scripts/export_games.py`. Línea
  /// base de frescura para `ResourceUpdateService`: no tiene sentido volver
  /// a descargar el catálogo si el backend no registró cambios posteriores
  /// a esta fecha (mismo principio que `DictionaryRepository.bundleGeneratedAt`).
  Future<DateTime?> bundleGeneratedAt() async {
    try {
      await _ensureBundleLoaded();
    } catch (_) {}
    return _bundleGeneratedAt;
  }

  /// Ids de los juegos compilados en `assets/games/manifest.json` — el
  /// universo cerrado sobre el que se calcula el progreso del mapa (ver
  /// «Camino de aprendizaje»/mapa). Un juego que llegue después
  /// por `GET /api/catalog/updates` se cachea, se lista y se juega igual
  /// desde el panel libre, pero no aparece aquí: si el mapa contara el
  /// catálogo vivo, publicar contenido nuevo haría *retroceder* el anillo de
  /// quien ya lo completó, y el 100 % dejaría de ser alcanzable. Reutiliza
  /// la misma carga memoizada que [bundleGeneratedAt] — no vuelve a leer el
  /// archivo de disco.
  Future<Set<int>> bundleGameIds() async {
    try {
      await _ensureBundleLoaded();
    } catch (_) {}
    final bundled = _bundleGames;
    if (bundled == null) return const {};
    return {for (final g in bundled) g.gameId.value};
  }

  /// Siembra `CachedGames` desde el bundle si aún no se sembró **este**
  /// `generatedAt` — instalación nueva (nunca se sembró nada) o APK
  /// actualizado con un manifest más reciente que el último sembrado (el
  /// caso "el usuario instaló una versión nueva"). Siempre por upsert, nunca
  /// borra: una fila que un delta posterior ya actualizó con contenido más
  /// nuevo que el bundle no se pisa hacia atrás porque el bundle solo trae
  /// lo que había *en ese release*, y upsert conserva lo demás intacto.
  ///
  /// Los juegos cuya media no casó con el diccionario en build-time
  /// (`mediaComplete: false` en el manifest) se completan solos en la
  /// siguiente llamada a [completeMissingGameMedia].
  Future<void> seedFromBundleIfNewer() async {
    try {
      await _ensureBundleLoaded();
    } catch (_) {
      return;
    }
    final bundled = _bundleGames;
    final generatedAt = _bundleGeneratedAt;
    if (bundled == null || bundled.isEmpty || generatedAt == null) return;

    final seededAtRaw = await _db.kvGet(_bundleSeededAtKey);
    final seededAt =
        seededAtRaw != null ? DateTime.tryParse(seededAtRaw) : null;
    if (seededAt != null && !generatedAt.isAfter(seededAt)) return;

    for (final entry in bundled) {
      await _db.upsertCachedGame(entry);
    }
    await _db.kvPut(_bundleSeededAtKey, generatedAt.toIso8601String());
  }

  /// Aplica el delta de `GET /api/catalog/updates` (ver
  /// `ResourceUpdateService`): descarga solo los juegos que cambiaron, nunca
  /// el catálogo entero.
  ///
  /// [upsertIds] (CREATED/UPDATED) se bajan con `GET /api/games/{id}`
  /// (metadatos: título, tema, dificultad, experiencia) y
  /// `GET /api/games/{id}/preview` (contenido jugable), en paralelo por
  /// juego. Si la llamada de metadatos falla se conservan los valores ya
  /// cacheados (o quedan vacíos si el juego es nuevo) en vez de abortar el
  /// juego entero por eso: el contenido jugable es lo importante.
  ///
  /// [deletedIds] se borran del caché. Esto **no** contradice el principio
  /// de "el refresco automático nunca vacía una caché": ese principio existe
  /// porque una lista completa vacía o corta es indistinguible de un fallo
  /// del backend, mientras que aquí el servidor afirma qué id concreto dejó
  /// de existir.
  ///
  /// Devuelve true solo si **todo** se aplicó bien, para que quien llame no
  /// avance el cursor de sincronización si algo quedó a medias.
  Future<bool> applyGameDelta({
    Set<int> upsertIds = const {},
    Set<int> deletedIds = const {},
  }) async {
    // Comparte `_running` con [completeMissingGameMedia]: las dos escriben
    // sobre CachedGames y pisarse dejaría filas a medio actualizar.
    if (_running) return false;
    _running = true;
    try {
      for (final id in deletedIds) {
        await _db.deleteCachedGame(id);
      }
      if (upsertIds.isEmpty) return true;

      final cached = {
        for (final g in await _db.allCachedGames()) g.gameId: g,
      };

      var allOk = true;
      for (final id in upsertIds) {
        final prev = cached[id];
        GameSummaryDto? meta;
        try {
          meta = await _service.getGameDetails(id);
        } catch (_) {
          // Metadata no crítica para que el juego sea jugable: si falla, se
          // conserva la que ya había (o queda vacía si es nuevo) y no se
          // aborta el delta por esto solo.
        }
        try {
          var data = await _service.getGamePreview(id);
          final (localized, complete) =
              await preloadGameAssets(data, _mediaStore);
          data = localized;
          await _db.upsertCachedGame(CachedGamesCompanion(
            gameId: Value(id),
            gameType: Value(
                data.gameType ?? meta?.gameType ?? prev?.gameType ?? ''),
            title: Value(meta?.title ?? prev?.title ?? ''),
            topic: Value(meta?.topic ?? prev?.topic),
            difficult: Value(meta?.difficult ?? prev?.difficult),
            experience: Value(meta?.experience ?? prev?.experience),
            totalQuestions:
                Value(meta?.totalQuestions ?? prev?.totalQuestions),
            contentJson: Value(jsonEncode(data.toJson())),
            mediaComplete: Value(complete),
            updatedAt: Value(DateTime.now()),
          ));
        } catch (_) {
          // Un juego que falla no frena a los demás, pero sí impide dar el
          // delta por aplicado: se reintenta en el próximo arranque.
          allOk = false;
        }
      }
      return allOk;
    } finally {
      _running = false;
    }
  }

  /// Completa la media que quedó pendiente (`mediaComplete: false`) sin
  /// tocar el catálogo ni crear ninguna actividad: reintenta la descarga a
  /// partir de `contentJson` ya cacheado, y solo pide
  /// `GET /api/games/{id}/preview` de nuevo si ese contenido viniera vacío
  /// (juego sembrado por el bundle cuya media no casó en build-time, sin
  /// `questions`/`words`). Se llama en cada arranque después del delta, para
  /// que un juego que falló por red la vez anterior no se quede a medias
  /// para siempre.
  Future<void> completeMissingGameMedia() async {
    if (_running) return;
    _running = true;
    try {
      final pending = await _db.gamesNeedingMedia();
      for (final game in pending) {
        try {
          var data = GameData.fromJson(
              jsonDecode(game.contentJson) as Map<String, dynamic>);
          if (data.words.isEmpty && data.questions.isEmpty) {
            data = await _service.getGamePreview(game.gameId);
          }
          final (localized, complete) =
              await preloadGameAssets(data, _mediaStore);
          await _db.upsertCachedGame(CachedGamesCompanion(
            gameId: Value(game.gameId),
            gameType: Value(game.gameType),
            title: Value(game.title),
            topic: Value(game.topic),
            difficult: Value(game.difficult),
            experience: Value(game.experience),
            totalQuestions: Value(game.totalQuestions),
            contentJson: Value(jsonEncode(localized.toJson())),
            mediaComplete: Value(complete),
            updatedAt: Value(DateTime.now()),
          ));
        } catch (_) {
          // Sigue sin red o el juego ya no existe: se reintenta la próxima
          // vez, no bloquea a los demás.
        }
      }
    } finally {
      _running = false;
    }
  }

  Future<void> _ensureBundleLoaded() async {
    if (_bundleGames != null) return;
    try {
      final raw = await rootBundle.loadString('assets/games/manifest.json');
      final parsed = parseGamesBundle(raw);
      _bundleGames = parsed.games;
      _bundleGeneratedAt = parsed.generatedAt;
    } catch (_) {
      // Se deja en null (no una lista vacía, que cuenta como "ya cargado")
      // para que la próxima llamada reintente en vez de quedar envenenado
      // el resto de la vida de esta instancia del servicio.
      _bundleGames = null;
      _bundleGeneratedAt = null;
    }
  }
}

final gameCacheServiceProvider = Provider<GameCacheService>((ref) =>
    GameCacheService(ref.watch(activityServiceProvider),
        ref.watch(appDatabaseProvider), ref.watch(mediaStoreProvider)));

/// Parsea `assets/games/manifest.json` (`scripts/export_games.py`) a filas
/// listas para `upsertCachedGame`. Separado de [GameCacheService] (función
/// pura, sin `rootBundle`) para poder testearlo con un JSON literal, igual
/// que el resto del parseo del proyecto.
({List<CachedGamesCompanion> games, DateTime? generatedAt}) parseGamesBundle(
    String raw) {
  final json = jsonDecode(raw) as Map<String, dynamic>;
  final generatedAtRaw = json['generatedAt'] as String?;
  final generatedAt =
      generatedAtRaw != null ? DateTime.tryParse(generatedAtRaw) : null;

  final entries = <CachedGamesCompanion>[];
  final now = DateTime.now();
  for (final g in ((json['games'] ?? []) as List)
      .whereType<Map<String, dynamic>>()) {
    final gameId = _asInt(g['gameId']);
    if (gameId == null) continue;
    // GameData.fromJson reutiliza el mismo parser tolerante a alias que ya
    // usa el camino de red — el manifest no necesita replicar su forma
    // exacta, solo lo que el backend ya devuelve en el preview.
    final data =
        GameData.fromJson(g['raw'] as Map<String, dynamic>? ?? const {});
    entries.add(CachedGamesCompanion(
      gameId: Value(gameId),
      gameType: Value(data.gameType ?? (g['gameType'] as String?) ?? ''),
      title: Value((g['title'] as String?) ?? ''),
      topic: Value(g['topic'] as String?),
      difficult: Value(g['difficult'] as String?),
      experience: Value(_asInt(g['experience'])),
      totalQuestions: Value(_asInt(g['totalQuestions'])),
      contentJson: Value(jsonEncode(data.toJson())),
      mediaComplete: Value((g['mediaComplete'] as bool?) ?? false),
      updatedAt: Value(now),
    ));
  }
  return (games: entries, generatedAt: generatedAt);
}
