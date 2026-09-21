import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/models.dart';
import '../../data/services/activity_service.dart';
import '../../data/services/daily_pronunciation_service.dart';
import '../storage/session_store.dart';
import '../api/api_client.dart';
import '../connectivity/connectivity_service.dart';
import '../storage/app_database.dart';

/// Intentos antes de descartar un pendiente que el servidor rechaza de
/// forma persistente (p.ej. gameId eliminado en el backend). Sin este
/// límite, un solo pendiente envenenado bloquearía la cola entera para
/// siempre, porque el bucle no seguiría al siguiente elemento.
const _maxSyncAttempts = 5;

/// Resultado de sincronizar una actividad pendiente.
class SyncedActivity {
  final String title;
  final String gameType;
  final int correctAnswers;
  final int totalQuestions;
  final RewardResult reward;

  const SyncedActivity({
    required this.title,
    required this.gameType,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.reward,
  });
}

/// Resumen mostrado al usuario tras sincronizar (requisito del usuario:
/// actividades realizadas, XP por cada una, XP total y diferencia de nivel).
class SyncSummary {
  final List<SyncedActivity> activities;
  final int levelBefore;
  final int levelAfter;
  final int totalXpBefore;
  final int totalXpAfter;

  const SyncSummary({
    required this.activities,
    required this.levelBefore,
    required this.levelAfter,
    required this.totalXpBefore,
    required this.totalXpAfter,
  });

  int get totalXpGained =>
      activities.fold(0, (sum, a) => sum + a.reward.xpGained);
}

/// Ejecuta el protocolo de sincronización de 2 pasos por cada resultado
/// pendiente:
///   1. POST /api/activities/start/game/{gameId} → activityId fresco
///   2. POST /api/activities/complete con los resultados guardados
class SyncService {
  final ActivityService _service;
  final AppDatabase _db;

  final DailyPronunciationService? _daily;
  final String? Function()? _account;
  SyncService(this._service, this._db, [this._daily, this._account]);

  Future<int> pendingCount() async {
    final account = _account?.call();
    return await _db.pendingCount() +
        (account == null
            ? 0
            : (await _db.dailyPending(
                account,
              )).where((r) => r.retryable).length);
  }

  /// Devuelve el resumen, o null si no había nada que sincronizar.
  Future<SyncSummary?> syncPending() async {
    final pending = await _db.allPendingResults();
    final account = _account?.call();
    final dailyPending = account == null
        ? <PendingDailyResult>[]
        : await _db.dailyPending(account);
    if (pending.isEmpty && dailyPending.isEmpty) return null;

    // Nivel/XP antes: última copia cacheada del dashboard.
    final (levelBefore, xpBefore) = await _readCachedProgress();

    final synced = <SyncedActivity>[];
    RewardResult? lastReward;
    var connectionLost = false;

    for (final row in pending) {
      try {
        // Paso 1: iniciar el juego para obtener un activityId fresco.
        final started = await _service.startGame(row.gameId);
        final activityId = started.activityId ?? row.gameId;

        // Paso 2: enviar el resultado guardado.
        final logs = ((jsonDecode(row.responseLogsJson) as List)
            .whereType<Map<String, dynamic>>()
            .map(ResponseLog.fromJson)
            .toList());

        final reward = await _service.completeActivity(
          activityId: activityId,
          startDate: row.startDate,
          correctAnswers: row.correctAnswers,
          responseLogs: logs,
          gameId: row.gameId,
        );

        synced.add(
          SyncedActivity(
            title: row.title,
            gameType: row.gameType,
            correctAnswers: row.correctAnswers,
            totalQuestions: row.totalQuestions,
            reward: reward,
          ),
        );
        lastReward = reward;
        await _db.deletePendingResult(row.id);

        // Progreso del mapa: la partida se jugó offline, pero ya se
        // confirmó con el backend — cuenta igual que una completada online.
        final cached = await _db.cachedGame(row.gameId);
        await _db.recordGameCompletion(
          gameId: row.gameId,
          topic: cached?.topic,
          correctAnswers: row.correctAnswers,
          totalQuestions: row.totalQuestions,
        );
      } on ApiException catch (e) {
        if (e.status == null) {
          // Sin red: dejar el resto pendiente y no seguir golpeando el
          // backend en este mismo intento.
          connectionLost = true;
          break;
        }
        // Error real del servidor (4xx/5xx): no se arregla reintentando el
        // resto de la cola con la misma conexión, pero tampoco bloquea a
        // los demás pendientes indefinidamente.
        await _db.incrementAttempts(row.id);
        if (row.attempts + 1 >= _maxSyncAttempts) {
          await _db.deletePendingResult(row.id);
        }
      } catch (_) {
        // Error no tipado (p.ej. datos guardados corruptos): mismo trato
        // que un rechazo del servidor, no bloquear la cola por esto.
        await _db.incrementAttempts(row.id);
        if (row.attempts + 1 >= _maxSyncAttempts) {
          await _db.deletePendingResult(row.id);
        }
      }
    }

    if (!connectionLost && _daily != null && account == _account?.call()) {
      for (final row in dailyPending) {
        if (!row.retryable || account != _account?.call()) continue;
        try {
          final result = await _daily.send(row);
          final reward = result.reward!;
          synced.add(
            SyncedActivity(
              title: 'Pronunciación diaria: ${result.word.mazahuaWord}',
              gameType: 'daily_pronunciation',
              correctAnswers: 1,
              totalQuestions: 1,
              reward: reward,
            ),
          );
          lastReward = reward;
        } on ApiException catch (e) {
          if (e.status == null ||
              e.status == 401 ||
              e.status == 429 ||
              e.status! >= 500) {
            break;
          }
          await _db.rejectDaily(row.account, row.challengeId, e.message);
        } catch (_) {
          break;
        }
      }
    }
    if (synced.isEmpty) return null;

    return SyncSummary(
      activities: synced,
      levelBefore: levelBefore,
      levelAfter: lastReward?.currentLevel ?? levelBefore,
      totalXpBefore: xpBefore,
      totalXpAfter: lastReward?.actualXp ?? xpBefore,
    );
  }

  Future<(int, int)> _readCachedProgress() async {
    for (final key in ['dashboard_student', 'dashboard_visitor']) {
      final raw = await _db.kvGet(key);
      if (raw == null) continue;
      try {
        final json = jsonDecode(raw) as Map<String, dynamic>;
        final level = (json['level'] as num?)?.toInt() ?? 1;
        final xp =
            ((json['experience'] ?? json['totalExperience']) as num?)
                ?.toInt() ??
            0;
        return (level, xp);
      } catch (_) {}
    }
    return (1, 0);
  }
}

final syncServiceProvider = Provider<SyncService>(
  (ref) => SyncService(
    ref.watch(activityServiceProvider),
    ref.watch(appDatabaseProvider),
    ref.watch(dailyPronunciationServiceProvider),
    () => ref.read(sessionStoreProvider).accountId,
  ),
);

/// Controlador: dispara la sincronización al recuperar conexión o al abrir
/// la app con pendientes; expone el resumen para que la UI lo muestre.
class SyncController extends Notifier<SyncSummary?> {
  bool _syncing = false;

  @override
  SyncSummary? build() {
    // Reaccionar a cambios de conectividad.
    ref.listen(connectivityStreamProvider, (previous, next) {
      final wasOffline = previous?.value == false;
      final isOnline = next.value == true;
      if (isOnline && wasOffline) trySync();
    });
    return null;
  }

  Future<void> trySync() async {
    if (_syncing) return;
    _syncing = true;
    try {
      final summary = await ref.read(syncServiceProvider).syncPending();
      if (summary != null) state = summary;
    } finally {
      _syncing = false;
    }
  }

  void dismissSummary() => state = null;
}

final syncControllerProvider = NotifierProvider<SyncController, SyncSummary?>(
  SyncController.new,
);
