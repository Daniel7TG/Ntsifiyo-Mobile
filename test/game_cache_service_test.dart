import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jnatrjo_mobile/core/api/api_client.dart';
import 'package:jnatrjo_mobile/core/storage/app_database.dart';
import 'package:jnatrjo_mobile/core/storage/media_store.dart';
import 'package:jnatrjo_mobile/core/storage/session_store.dart';
import 'package:jnatrjo_mobile/core/sync/game_cache_service.dart';
import 'package:jnatrjo_mobile/data/models/models.dart';
import 'package:jnatrjo_mobile/data/services/activity_service.dart';

ApiClient _dummyApiClient() =>
    ApiClient(SessionStore(const FlutterSecureStorage()));

/// Fake de `ActivityService` para el único camino de red que
/// [GameCacheService] usa hoy: `GET /api/games/{id}` (metadatos) y
/// `GET /api/games/{id}/preview` (contenido), nunca `GET /api/games` ni
/// `GET /api/games/topic/{topic}` — esos ya no tienen llamador.
class _FakeActivityService extends ActivityService {
  _FakeActivityService({
    this._details = const {},
    this._previews = const {},
    this._detailsFailFor = const {},
    this._previewsFailFor = const {},
  }) : super(_dummyApiClient());

  final Map<int, GameSummaryDto> _details;
  final Map<int, GameData> _previews;
  final Set<int> _detailsFailFor;
  final Set<int> _previewsFailFor;
  final List<int> detailsRequested = [];
  final List<int> previewsRequested = [];

  @override
  Future<GameSummaryDto> getGameDetails(int gameId) async {
    detailsRequested.add(gameId);
    if (_detailsFailFor.contains(gameId)) {
      throw ApiException('falló', status: 500);
    }
    final meta = _details[gameId];
    if (meta == null) throw ApiException('no encontrado', status: 404);
    return meta;
  }

  @override
  Future<GameData> getGamePreview(int gameId) async {
    previewsRequested.add(gameId);
    if (_previewsFailFor.contains(gameId)) {
      throw ApiException('falló', status: 500);
    }
    return _previews[gameId] ??
        GameData(gameType: 'MEMORY_GAME', title: 'g$gameId');
  }
}

Future<void> _seedCachedGame(AppDatabase db, int gameId,
        {String? topic, bool mediaComplete = true, String? contentJson}) =>
    db.upsertCachedGame(
      CachedGamesCompanion(
        gameId: Value(gameId),
        gameType: const Value('MEMORY_GAME'),
        title: Value('juego $gameId'),
        topic: Value(topic),
        contentJson: Value(contentJson ?? '{}'),
        mediaComplete: Value(mediaComplete),
        updatedAt: Value(DateTime.now()),
      ),
    );

void main() {
  group('GameCacheService.applyGameDelta', () {
    late AppDatabase db;
    late MediaStore mediaStore;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      mediaStore = MediaStore(db);
    });
    tearDown(() => db.close());

    test('upsertIds nuevos: baja metadatos con getGameDetails y contenido '
        'con getGamePreview, nunca startGame ni un listado', () async {
      final service = _FakeActivityService(details: {
        166: const GameSummaryDto(
            id: 166,
            title: 'Memorama animales',
            gameType: 'MEMORY_GAME',
            topic: 'ANIMALS'),
      });
      final cache = GameCacheService(service, db, mediaStore);

      final ok = await cache.applyGameDelta(upsertIds: {166});

      expect(ok, isTrue);
      final row = await db.cachedGame(166);
      expect(row, isNotNull);
      expect(row!.topic, 'ANIMALS');
      expect(service.detailsRequested, [166]);
      expect(service.previewsRequested, [166]);
    });

    test('si GET /api/games/{id} falla, conserva el topic ya cacheado en '
        'vez de pisarlo con null', () async {
      await _seedCachedGame(db, 166, topic: 'ANIMALS');
      final service = _FakeActivityService(detailsFailFor: {166});
      final cache = GameCacheService(service, db, mediaStore);

      final ok = await cache.applyGameDelta(upsertIds: {166});

      // El delta sigue dándose por aplicado: el contenido jugable (lo
      // importante) sí llegó, solo falló la metadata no crítica.
      expect(ok, isTrue);
      final row = await db.cachedGame(166);
      expect(row!.topic, 'ANIMALS');
    });

    test('si GET /api/games/{id}/preview falla, el delta no se da por '
        'aplicado (se reintenta en el próximo arranque)', () async {
      final service = _FakeActivityService(previewsFailFor: {166});
      final cache = GameCacheService(service, db, mediaStore);

      final ok = await cache.applyGameDelta(upsertIds: {166});

      expect(ok, isFalse);
      expect(await db.cachedGame(166), isNull);
    });

    test('deletedIds borra del caché sin tocar el resto', () async {
      await _seedCachedGame(db, 1, topic: 'ANIMALS');
      await _seedCachedGame(db, 2, topic: 'FOOD');
      final cache = GameCacheService(_FakeActivityService(), db, mediaStore);

      final ok = await cache.applyGameDelta(deletedIds: {1});

      expect(ok, isTrue);
      expect(await db.cachedGame(1), isNull);
      expect(await db.cachedGame(2), isNotNull);
    });
  });

  group('GameCacheService.completeMissingGameMedia', () {
    late AppDatabase db;
    late MediaStore mediaStore;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      mediaStore = MediaStore(db);
    });
    tearDown(() => db.close());

    test('ignora los juegos ya completos y no llama a la red por ellos',
        () async {
      await _seedCachedGame(db, 1, mediaComplete: true);
      final service = _FakeActivityService();
      final cache = GameCacheService(service, db, mediaStore);

      await cache.completeMissingGameMedia();

      expect(service.previewsRequested, isEmpty);
    });

    test('un juego con mediaComplete: false y contentJson vacío pide '
        'GET /api/games/{id}/preview de nuevo', () async {
      await _seedCachedGame(db, 5, mediaComplete: false, contentJson: '{}');
      final service = _FakeActivityService(previews: {
        5: const GameData(gameType: 'MEMORY_GAME', title: 'g5'),
      });
      final cache = GameCacheService(service, db, mediaStore);

      await cache.completeMissingGameMedia();

      expect(service.previewsRequested, [5]);
      final row = await db.cachedGame(5);
      expect(row!.mediaComplete, isTrue);
    });

    test('nunca llama a getGameDetails ni crea actividades (sin start)',
        () async {
      await _seedCachedGame(db, 5, mediaComplete: false, contentJson: '{}');
      final service = _FakeActivityService();
      final cache = GameCacheService(service, db, mediaStore);

      await cache.completeMissingGameMedia();

      expect(service.detailsRequested, isEmpty);
    });
  });

  group('GameCacheService.seedFromBundleIfNewer', () {
    late AppDatabase db;
    late MediaStore mediaStore;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      mediaStore = MediaStore(db);
    });
    tearDown(() => db.close());

    test('sin bundle cargable, no hace nada', () async {
      final cache =
          GameCacheService(_FakeActivityService(), db, mediaStore);
      await cache.seedFromBundleIfNewer();
      expect(await db.allCachedGames(), isEmpty);
    });
  });

  group('parseGamesBundle', () {
    test('mapea el manifest de scripts/export_games.py a filas de '
        'CachedGames, con generatedAt y datos por juego', () {
      const raw = '''
      {
        "generatedAt": "2026-08-01T10:00:00.000",
        "games": [
          {
            "gameId": 166,
            "title": "Memorama de animales",
            "gameType": "MEMORY_GAME",
            "topic": "ANIMALS",
            "difficult": "EASY",
            "experience": 50,
            "totalQuestions": 5,
            "mediaComplete": true,
            "raw": {
              "activityId": 136,
              "words": [
                {"id": 5, "spanishWord": "abeja", "mazahuaWord": "ngini",
                 "imageUrl": "assets/dictionary/img/5.webp",
                 "audioUrl": "assets/dictionary/audio/5.mp3"}
              ],
              "questions": []
            }
          }
        ]
      }
      ''';

      final parsed = parseGamesBundle(raw);

      expect(parsed.generatedAt, DateTime.parse('2026-08-01T10:00:00.000'));
      expect(parsed.games, hasLength(1));
      final entry = parsed.games.single;
      expect(entry.gameId.value, 166);
      expect(entry.gameType.value, 'MEMORY_GAME');
      expect(entry.topic.value, 'ANIMALS');
      expect(entry.mediaComplete.value, isTrue);
      // contentJson debe ser el GameData ya reconstruido (round-trip por
      // GameData.fromJson/toJson), no el 'raw' crudo tal cual.
      final decoded = GameData.fromJson(
          jsonDecode(entry.contentJson.value) as Map<String, dynamic>);
      expect(decoded.words.single.spanishWord, 'abeja');
      expect(decoded.words.single.imageUrl, 'assets/dictionary/img/5.webp');
    });

    test('ignora entradas sin gameId y tolera generatedAt ausente', () {
      const raw = '{"games": [{"title": "sin id", "raw": {}}]}';
      final parsed = parseGamesBundle(raw);
      expect(parsed.generatedAt, isNull);
      expect(parsed.games, isEmpty);
    });
  });
}
