import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jnatrjo_mobile/core/api/api_client.dart';
import 'package:jnatrjo_mobile/core/storage/app_database.dart';
import 'package:jnatrjo_mobile/core/storage/media_store.dart';
import 'package:jnatrjo_mobile/core/storage/session_store.dart';
import 'package:jnatrjo_mobile/core/sync/game_cache_service.dart';
import 'package:jnatrjo_mobile/core/sync/resource_update_service.dart';
import 'package:jnatrjo_mobile/data/models/models.dart';
import 'package:jnatrjo_mobile/data/services/activity_service.dart';
import 'package:jnatrjo_mobile/data/services/catalog_service.dart';
import 'package:jnatrjo_mobile/data/services/misc_services.dart';
import 'package:jnatrjo_mobile/features/dictionary/dictionary_repository.dart';

ApiClient _dummyApiClient() =>
    ApiClient(SessionStore(const FlutterSecureStorage()));

/// Sustituye la llamada de red por un delta fijo y anota con qué `since` se
/// pidió, que es la mitad del contrato que interesa aquí.
class _FakeCatalogService extends CatalogService {
  _FakeCatalogService(this._updates, {this.throws = false})
      : super(_dummyApiClient());
  final CatalogUpdates _updates;
  final bool throws;

  String? lastSince;
  int calls = 0;

  @override
  Future<CatalogUpdates> getUpdates({String? since}) async {
    calls++;
    lastSince = since;
    if (throws) throw Exception('sin red');
    return _updates;
  }
}

/// Anota los ids que le llegan en vez de tocar la red: lo que se comprueba
/// es qué decide `ResourceUpdateService`, no lo que hacen por dentro (eso ya
/// lo cubren los tests de `GameCacheService`/`DictionaryRepository`).
class _FakeGameCacheService extends GameCacheService {
  _FakeGameCacheService(AppDatabase db, MediaStore mediaStore,
      {this._bundleDate, this.result = true})
      : super(ActivityService(_dummyApiClient()), db, mediaStore);
  final DateTime? _bundleDate;
  final bool result;

  int calls = 0;
  Set<int> upserted = const {};
  Set<int> deleted = const {};

  @override
  Future<DateTime?> bundleGeneratedAt() async => _bundleDate;

  @override
  Future<bool> applyGameDelta({
    Set<int> upsertIds = const {},
    Set<int> deletedIds = const {},
  }) async {
    calls++;
    upserted = upsertIds;
    deleted = deletedIds;
    return result;
  }
}

class _FakeDictionaryRepository extends DictionaryRepository {
  _FakeDictionaryRepository(AppDatabase db, MediaStore mediaStore,
      {this._bundleDate, this.result = true})
      : super(DictionaryService(_dummyApiClient()), db, mediaStore);
  final DateTime? _bundleDate;
  final bool result;

  int calls = 0;
  Set<int> upserted = const {};
  Set<int> deleted = const {};

  @override
  Future<DateTime?> bundleGeneratedAt() async => _bundleDate;

  @override
  Future<bool> applyWordDelta({
    Set<int> upsertIds = const {},
    Set<int> deletedIds = const {},
  }) async {
    calls++;
    upserted = upsertIds;
    deleted = deletedIds;
    return result;
  }
}

CatalogChange _change(int id, String type, [DateTime? at]) =>
    CatalogChange(id: id, changeType: type, updatedAt: at);

void main() {
  group('CatalogUpdates.fromJson', () {
    test('parsea el delta con gameId/wordId y tolera listas ausentes', () {
      final updates = CatalogUpdates.fromJson({
        'since': '2026-08-01T00:00:00',
        'serverTime': '2026-08-19T10:15:30.482',
        'games': [
          {
            'gameId': 42,
            'changeType': 'UPDATED',
            'updatedAt': '2026-08-09T14:23:11.482'
          },
          {
            'gameId': 51,
            'changeType': 'DELETED',
            'updatedAt': '2026-08-14T18:02:45.117'
          },
        ],
      });

      expect(updates.since, '2026-08-01T00:00:00');
      // Se guarda tal cual, sin pasar por DateTime: es lo que se reenvía.
      expect(updates.serverTime, '2026-08-19T10:15:30.482');
      expect(updates.games.length, 2);
      expect(updates.games.first.id, 42);
      expect(updates.games.first.isDeleted, isFalse);
      expect(updates.games.last.isDeleted, isTrue);
      expect(updates.words, isEmpty);
      expect(updates.isEmpty, isFalse);
    });

    test('respuesta sin cambios', () {
      final updates = CatalogUpdates.fromJson({
        'since': '2026-08-19T10:00:00',
        'serverTime': '2026-08-19T10:15:30.482',
        'games': <dynamic>[],
        'words': <dynamic>[],
      });
      expect(updates.isEmpty, isTrue);
    });

    test('un elemento sin id se descarta en vez de tumbar el delta entero',
        () {
      final updates = CatalogUpdates.fromJson({
        'serverTime': '2026-08-19T10:15:30.482',
        'words': [
          {'changeType': 'CREATED'},
          {'wordId': 87, 'changeType': 'CREATED'},
        ],
      });
      expect(updates.words.length, 1);
      expect(updates.words.single.id, 87);
    });
  });

  group('AppDatabase.applyCachedWordDelta', () {
    late AppDatabase db;
    setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
    tearDown(() => db.close());

    CachedWordsCompanion word(int id, String es) => CachedWordsCompanion(
          id: Value(id),
          spanishWord: Value(es),
          mazahuaWord: Value('mz-$es'),
          category: const Value('ANIMALS'),
          updatedAt: Value(DateTime(2026, 8, 19)),
        );

    test('mete, reemplaza y borra por id sin tocar el resto de la tabla',
        () async {
      await db.replaceCachedWords([word(1, 'perro'), word(2, 'gato')]);

      await db.applyCachedWordDelta(
        upserted: [word(2, 'gato-corregido'), word(3, 'vaca')],
        deletedIds: {1},
      );

      final rows = await db.allCachedWords();
      expect(rows.map((w) => w.id).toSet(), {2, 3});
      expect(rows.firstWhere((w) => w.id == 2).spanishWord, 'gato-corregido');
    });

    test('un delta vacío no borra nada', () async {
      await db.replaceCachedWords([word(1, 'perro')]);
      await db.applyCachedWordDelta();
      expect((await db.allCachedWords()).length, 1);
    });
  });

  group('AppDatabase.resourceUpdate / putResourceUpdate', () {
    test('guarda y lee el cursor de sincronización de un recurso', () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      expect(await db.resourceUpdate('GAME'), isNull);

      await db.putResourceUpdate(ResourceUpdatesCompanion(
        resource: const Value('GAME'),
        syncCursor: const Value('2026-08-19T10:15:30.482'),
        lastUpdatedAt: Value(DateTime(2026, 8, 9, 14, 23, 11)),
        lastChangeType: const Value('UPDATED'),
        lastResourceId: const Value(42),
      ));

      final row = await db.resourceUpdate('GAME');
      expect(row!.syncCursor, '2026-08-19T10:15:30.482');
      expect(row.lastChangeType, 'UPDATED');
      expect(row.lastResourceId, 42);

      // insertOnConflictUpdate: una segunda escritura reemplaza, no duplica
      // (una sola fila por recurso, PK = resource).
      await db.putResourceUpdate(ResourceUpdatesCompanion(
        resource: const Value('GAME'),
        syncCursor: const Value('2026-08-20T09:00:00'),
        lastChangeType: const Value('DELETED'),
        lastResourceId: const Value(7),
      ));
      final updated = await db.resourceUpdate('GAME');
      expect(updated!.syncCursor, '2026-08-20T09:00:00');
      expect(updated.lastResourceId, 7);
    });

    test('Value.absent() conserva el último cambio registrado', () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      await db.putResourceUpdate(ResourceUpdatesCompanion(
        resource: const Value('GAME'),
        syncCursor: const Value('2026-08-19T10:00:00'),
        lastChangeType: const Value('UPDATED'),
        lastResourceId: const Value(42),
      ));
      await db.putResourceUpdate(const ResourceUpdatesCompanion(
        resource: Value('GAME'),
        syncCursor: Value('2026-08-20T10:00:00'),
      ));

      final row = await db.resourceUpdate('GAME');
      expect(row!.syncCursor, '2026-08-20T10:00:00');
      expect(row.lastChangeType, 'UPDATED');
      expect(row.lastResourceId, 42);
    });
  });

  group('ResourceUpdateService', () {
    late AppDatabase db;
    late MediaStore mediaStore;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      mediaStore = MediaStore(db);
    });
    tearDown(() => db.close());

    /// Deja los dos recursos ya sincronizados, que es el estado en el que
    /// el delta es realmente incremental.
    Future<void> seedCursors(String cursor) async {
      for (final r in ['GAME', 'DICTIONARY']) {
        await db.putResourceUpdate(ResourceUpdatesCompanion(
          resource: Value(r),
          syncCursor: Value(cursor),
        ));
      }
    }

    test('primera sincronización (sin cursor ni bundle) guarda el cursor '
        'pero no rebaja el catálogo entero id a id', () async {
      final catalog = _FakeCatalogService(CatalogUpdates(
        serverTime: '2026-08-19T10:15:30.482',
        games: [_change(1, 'CREATED'), _change(2, 'CREATED')],
        words: [_change(9, 'CREATED')],
      ));
      final games = _FakeGameCacheService(db, mediaStore);
      final dict = _FakeDictionaryRepository(db, mediaStore);
      final service = ResourceUpdateService(catalog, db, games, dict);

      final refreshed = await service.checkAndRefresh();

      expect(catalog.lastSince, isNull); // catálogo completo
      expect(refreshed, isEmpty);
      expect(games.calls, 0);
      expect(dict.calls, 0);
      // Pero sí queda el punto de partida para que el próximo arranque ya
      // pida solo lo nuevo.
      expect((await db.resourceUpdate('GAME'))?.syncCursor,
          '2026-08-19T10:15:30.482');
      expect((await db.resourceUpdate('DICTIONARY'))?.syncCursor,
          '2026-08-19T10:15:30.482');
    });

    test('delta vacío no refresca nada pero avanza el cursor', () async {
      await seedCursors('2026-08-18T00:00:00');
      final catalog = _FakeCatalogService(const CatalogUpdates(
        serverTime: '2026-08-19T10:15:30.482',
      ));
      final games = _FakeGameCacheService(db, mediaStore);
      final dict = _FakeDictionaryRepository(db, mediaStore);
      final service = ResourceUpdateService(catalog, db, games, dict);

      final refreshed = await service.checkAndRefresh();

      expect(catalog.lastSince, '2026-08-18T00:00:00');
      expect(refreshed, isEmpty);
      expect(games.calls, 0);
      expect(dict.calls, 0);
      expect((await db.resourceUpdate('GAME'))?.syncCursor,
          '2026-08-19T10:15:30.482');
    });

    test('reparte CREATED/UPDATED a upsert y DELETED a borrado, y avanza el '
        'cursor de cada recurso', () async {
      await seedCursors('2026-08-18T00:00:00');
      final catalog = _FakeCatalogService(CatalogUpdates(
        serverTime: '2026-08-19T10:15:30.482',
        games: [
          _change(42, 'UPDATED', DateTime(2026, 8, 9)),
          _change(51, 'DELETED', DateTime(2026, 8, 14)),
        ],
        words: [_change(87, 'CREATED', DateTime(2026, 8, 12))],
      ));
      final games = _FakeGameCacheService(db, mediaStore);
      final dict = _FakeDictionaryRepository(db, mediaStore);
      final service = ResourceUpdateService(catalog, db, games, dict);

      final refreshed = await service.checkAndRefresh();

      expect(refreshed, {TrackedResource.games, TrackedResource.dictionary});
      expect(games.upserted, {42});
      // Un DELETED nunca se pide al backend: ya no existe y daría 404.
      expect(games.deleted, {51});
      expect(dict.upserted, {87});
      expect(dict.deleted, isEmpty);

      final gameRow = await db.resourceUpdate('GAME');
      expect(gameRow!.syncCursor, '2026-08-19T10:15:30.482');
      // `changes` viene de más antiguo a más reciente: se guarda el último.
      expect(gameRow.lastChangeType, 'DELETED');
      expect(gameRow.lastResourceId, 51);
    });

    test('si la aplicación falla a medias no avanza el cursor de ese '
        'recurso, para reintentar el mismo rango', () async {
      await seedCursors('2026-08-18T00:00:00');
      final catalog = _FakeCatalogService(CatalogUpdates(
        serverTime: '2026-08-19T10:15:30.482',
        games: [_change(42, 'UPDATED')],
        words: [_change(87, 'UPDATED')],
      ));
      final games = _FakeGameCacheService(db, mediaStore, result: false);
      final dict = _FakeDictionaryRepository(db, mediaStore);
      final service = ResourceUpdateService(catalog, db, games, dict);

      final refreshed = await service.checkAndRefresh();

      expect(refreshed, {TrackedResource.dictionary});
      // Juegos: se intentó, falló, el cursor se queda donde estaba.
      expect(games.calls, 1);
      expect((await db.resourceUpdate('GAME'))?.syncCursor,
          '2026-08-18T00:00:00');
      // Diccionario: sí avanza, es un cursor independiente.
      expect((await db.resourceUpdate('DICTIONARY'))?.syncCursor,
          '2026-08-19T10:15:30.482');
    });

    test('el cursor de cada recurso es independiente: si falla el '
        'diccionario, el de juegos sí avanza', () async {
      await seedCursors('2026-08-18T00:00:00');
      final catalog = _FakeCatalogService(CatalogUpdates(
        serverTime: '2026-08-19T10:15:30.482',
        games: [_change(42, 'UPDATED')],
        words: [_change(87, 'UPDATED')],
      ));
      final games = _FakeGameCacheService(db, mediaStore);
      final dict = _FakeDictionaryRepository(db, mediaStore, result: false);
      final service = ResourceUpdateService(catalog, db, games, dict);

      final refreshed = await service.checkAndRefresh();

      expect(refreshed, {TrackedResource.games});
      expect(dict.calls, 1);
      expect((await db.resourceUpdate('GAME'))?.syncCursor,
          '2026-08-19T10:15:30.482');
      expect((await db.resourceUpdate('DICTIONARY'))?.syncCursor,
          '2026-08-18T00:00:00');
    });

    test('manda como since el cursor más atrasado de los dos recursos',
        () async {
      await db.putResourceUpdate(const ResourceUpdatesCompanion(
        resource: Value('GAME'),
        syncCursor: Value('2026-08-19T00:00:00'),
      ));
      await db.putResourceUpdate(const ResourceUpdatesCompanion(
        resource: Value('DICTIONARY'),
        syncCursor: Value('2026-08-10T00:00:00'), // va por detrás
      ));
      final catalog = _FakeCatalogService(
          const CatalogUpdates(serverTime: '2026-08-19T10:15:30.482'));
      final service = ResourceUpdateService(
        catalog,
        db,
        _FakeGameCacheService(db, mediaStore),
        _FakeDictionaryRepository(db, mediaStore),
      );

      await service.checkAndRefresh();
      expect(catalog.lastSince, '2026-08-10T00:00:00');
    });

    test('sin cursor guardado usa la fecha del bundle como línea base',
        () async {
      final catalog = _FakeCatalogService(
          const CatalogUpdates(serverTime: '2026-08-19T10:15:30.482'));
      final service = ResourceUpdateService(
        catalog,
        db,
        _FakeGameCacheService(db, mediaStore,
            bundleDate: DateTime(2026, 8, 14, 10, 55, 6)),
        _FakeDictionaryRepository(db, mediaStore,
            bundleDate: DateTime(2026, 8, 15)),
      );

      await service.checkAndRefresh();
      // El más atrasado de los dos bundles, sin sufijo de zona (el backend
      // lo compara como LocalDateTime).
      expect(catalog.lastSince, '2026-08-14T10:55:06.000');
    });

    test('un fallo de red no toca nada y no bloquea el arranque', () async {
      await seedCursors('2026-08-18T00:00:00');
      final catalog = _FakeCatalogService(
          const CatalogUpdates(serverTime: 'x'),
          throws: true);
      final games = _FakeGameCacheService(db, mediaStore);
      final dict = _FakeDictionaryRepository(db, mediaStore);
      final service = ResourceUpdateService(catalog, db, games, dict);

      expect(await service.checkAndRefresh(), isEmpty);
      expect(games.calls, 0);
      expect((await db.resourceUpdate('GAME'))?.syncCursor,
          '2026-08-18T00:00:00');
    });

    test('sin serverTime no se avanza el cursor', () async {
      await seedCursors('2026-08-18T00:00:00');
      final catalog = _FakeCatalogService(CatalogUpdates(
        games: [_change(42, 'UPDATED')],
      ));
      final games = _FakeGameCacheService(db, mediaStore);
      final dict = _FakeDictionaryRepository(db, mediaStore);
      final service = ResourceUpdateService(catalog, db, games, dict);

      await service.checkAndRefresh();
      expect(games.upserted, {42});
      expect((await db.resourceUpdate('GAME'))?.syncCursor,
          '2026-08-18T00:00:00');
    });
  });
}
