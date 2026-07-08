import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/models.dart';
import '../../data/services/activity_service.dart';
import '../connectivity/connectivity_service.dart';
import '../storage/app_database.dart';

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

  SyncService(this._service, this._db);

  Future<int> pendingCount() => _db.pendingCount();

  /// Devuelve el resumen, o null si no había nada que sincronizar.
  Future<SyncSummary?> syncPending() async {
    final pending = await _db.allPendingResults();
    if (pending.isEmpty) return null;

    // Nivel/XP antes: última copia cacheada del dashboard.
    final (levelBefore, xpBefore) = await _readCachedProgress();

    final synced = <SyncedActivity>[];
    RewardResult? lastReward;

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

        synced.add(SyncedActivity(
          title: row.title,
          gameType: row.gameType,
          correctAnswers: row.correctAnswers,
          totalQuestions: row.totalQuestions,
          reward: reward,
        ));
        lastReward = reward;
        await _db.deletePendingResult(row.id);
      } catch (_) {
        // Sin red o error del servidor: dejar el pendiente para el
        // siguiente intento y no seguir golpeando el backend.
        break;
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
        final xp = ((json['experience'] ?? json['totalExperience']) as num?)
                ?.toInt() ??
            0;
        return (level, xp);
      } catch (_) {}
    }
    return (1, 0);
  }
}

final syncServiceProvider = Provider<SyncService>((ref) =>
    SyncService(ref.watch(activityServiceProvider), ref.watch(appDatabaseProvider)));

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

final syncControllerProvider =
    NotifierProvider<SyncController, SyncSummary?>(SyncController.new);
