import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jnatrjo_mobile/core/api/api_client.dart';
import 'package:jnatrjo_mobile/core/storage/app_database.dart';
import 'package:jnatrjo_mobile/core/storage/session_store.dart';
import 'package:jnatrjo_mobile/core/sync/sync_service.dart';
import 'package:jnatrjo_mobile/data/services/activity_service.dart';
import 'package:jnatrjo_mobile/data/services/daily_pronunciation_service.dart';
import 'package:jnatrjo_mobile/data/models/daily_pronunciation.dart';
import 'package:jnatrjo_mobile/data/models/models.dart';

class FakeDailyApi extends ApiClient {
  FakeDailyApi() : super(SessionStore(const FlutterSecureStorage()));
  bool offline = false, loseResponse = false;
  int? failureStatus;
  int awarded = 0;
  int requests = 0;
  final Set<int> completed = {};
  final challenge = DailyChallenge(
    id: 42,
    word: const Word(id: 1, spanishWord: 'casa', mazahuaWord: 'ngumu'),
    startsAt: DateTime.now().toUtc().subtract(const Duration(minutes: 2)),
    expiresAt: DateTime.now().toUtc().add(const Duration(hours: 1)),
  );
  @override
  Future<dynamic> post(String endpoint, [Object? body]) async {
    requests++;
    if (offline) throw ApiException('Sin conexión');
    if (failureStatus != null) {
      throw ApiException(
        'Servidor rechazó el resultado',
        status: failureStatus,
      );
    }
    if (endpoint.endsWith('/start')) return challenge.toJson();
    final first = completed.add(42);
    if (first) awarded += 100;
    if (loseResponse) {
      loseResponse = false;
      throw ApiException('Respuesta perdida');
    }
    return {
      ...challenge.toJson(),
      'completed': true,
      'reward': {
        'xpGained': first ? 100 : 0,
        'actualXp': awarded,
        'currentLevel': 2,
        'isLevelUp': first,
      },
    };
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppDatabase db;
  late FakeDailyApi api;
  late DailyPronunciationService daily;
  String? account;
  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    api = FakeDailyApi();
    account = 'ana';
    daily = DailyPronunciationService(api, db, () => account);
  });
  tearDown(() => db.close());
  test(
    'aceptado offline se guarda una vez y no acredita XP hasta sincronizar',
    () async {
      final c = await daily.start('ana', [1]);
      api.offline = true;
      expect((await daily.complete('ana', c)).pending, true);
      await daily.complete('ana', c);
      expect(await db.dailyPending('ana'), hasLength(1));
      expect(api.awarded, 0);
      expect((await daily.cached('ana'))!.pending, true);
      api.offline = false;
      final sync = SyncService(ActivityService(api), db, daily, () => account);
      expect(await sync.pendingCount(), 1);
      final result = await sync.syncPending();
      expect(result!.totalXpGained, 100);
      expect(result.activities.single.gameType, 'daily_pronunciation');
      expect(await sync.pendingCount(), 0);
      expect((await daily.cached('ana'))!.completed, true);
    },
  );
  test(
    'sin servidor crea el reto desde el diccionario local y luego lo enlaza',
    () async {
      api.offline = true;
      final local = await daily.startLocal('ana', [
        const Word(id: 1, spanishWord: 'casa', mazahuaWord: 'ngumu'),
      ]);
      expect(local, isNotNull);
      expect(local!.localOnly, true);
      expect(local.id, lessThan(0));

      final saved = await daily.complete('ana', local);
      expect(saved.pending, true);
      expect(await db.dailyPending('ana'), hasLength(1));
      expect(api.awarded, 0);

      api.offline = false;
      final summary = await SyncService(
        ActivityService(api),
        db,
        daily,
        () => account,
      ).syncPending();
      expect(summary!.totalXpGained, 100);
      expect((await daily.cached('ana'))!.completed, true);
      expect((await daily.cached('ana'))!.localOnly, false);
      expect(await db.dailyPending('ana'), isEmpty);
    },
  );
  test(
    'respuesta perdida reintenta sin duplicar XP y no cruza cuentas',
    () async {
      final c = await daily.start('ana', [1]);
      api.loseResponse = true;
      await daily.complete('ana', c);
      expect(api.awarded, 100);
      final row = (await db.dailyPending('ana')).single;
      account = 'bea';
      await expectLater(daily.send(row), throwsStateError);
      expect(await db.dailyPending('ana'), hasLength(1));
      expect(await daily.cached('bea'), null);
      account = 'ana';
      final result = await daily.send(row);
      expect(result.reward!.xpGained, 0);
      expect(api.awarded, 100);
      expect(await db.dailyPending('ana'), isEmpty);
    },
  );
  test('rechazo explícito no se anuncia como falta de conexión', () async {
    final c = await daily.start('ana', [1]);
    api.failureStatus = 400;
    await expectLater(daily.complete('ana', c), throwsA(isA<ApiException>()));
    final row = (await db.dailyPending('ana')).single;
    expect(row.error, 'Servidor rechazó el resultado');
    expect(row.retryable, false);
    expect((await daily.cached('ana'))!.error, row.error);
    expect(api.awarded, 0);
    expect(
      await SyncService(
        ActivityService(api),
        db,
        daily,
        () => account,
      ).pendingCount(),
      0,
    );
  });
  test(
    'sin red se detiene antes del reto diario y conserva ambas colas',
    () async {
      final c = await daily.start('ana', [1]);
      api.offline = true;
      await daily.complete('ana', c);
      await db.enqueueResult(
        PendingResultsCompanion(
          gameId: const Value(7),
          title: const Value('Memorama'),
          gameType: const Value('MEMORY_GAME'),
          startDate: Value(DateTime.now().toIso8601String()),
          correctAnswers: const Value(1),
          totalQuestions: const Value(1),
          responseLogsJson: const Value('[]'),
          completedAt: Value(DateTime.now()),
        ),
      );
      final before = api.requests;
      final sync = SyncService(ActivityService(api), db, daily, () => account);
      expect(await sync.syncPending(), null);
      expect(api.requests - before, 1);
      expect(await sync.pendingCount(), 2);
      expect(api.awarded, 0);
    },
  );
  test(
    'migración 10 a 11 conserva caché y la cola diaria sobrevive reinicio',
    () async {
      await db.close();
      final directory = await Directory.systemTemp.createTemp('daily-db');
      final file = File('${directory.path}/db.sqlite');
      var persistent = AppDatabase.forTesting(NativeDatabase(file));
      await persistent.kvPut('anterior', 'conservar');
      await persistent.customStatement('DROP TABLE pending_daily_results');
      await persistent.customStatement('PRAGMA user_version = 10');
      await persistent.close();
      persistent = AppDatabase.forTesting(NativeDatabase(file));
      final service = DailyPronunciationService(api, persistent, () => account);
      final c = await service.start('ana', [1]);
      api.offline = true;
      await service.complete('ana', c);
      await persistent.close();
      persistent = AppDatabase.forTesting(NativeDatabase(file));
      expect(await persistent.kvGet('anterior'), 'conservar');
      expect(await persistent.dailyPending('ana'), hasLength(1));
      await persistent.close();
      await directory.delete(recursive: true);
      db = AppDatabase.forTesting(NativeDatabase.memory());
    },
  );
  test('identidad de sesión estable aunque cambie el token', () async {
    FlutterSecureStorage.setMockInitialValues({});
    final session = SessionStore(const FlutterSecureStorage());
    String token(String sub, int exp) =>
        'header.${base64Url.encode(utf8.encode(jsonEncode({'sub': sub, 'exp': exp})))}.signature';
    const user = AppUser(firstname: 'Ana', lastname: '', userType: 'STUDENT');
    await session.save(user, token('ana', 1));
    expect(session.accountId, 'ana');
    await session.save(user, token('ana', 2));
    expect(session.accountId, 'ana');
    await session.clear();
    expect(session.accountId, null);
  });
}
