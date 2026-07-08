import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/app_database.dart';
import '../../core/sync/asset_preloader.dart';
import '../../data/models/models.dart';
import '../../data/services/activity_service.dart';

/// Sesión de juego activa (equivalente a GameContext.currentGameData de la web).
class GameSession {
  final int gameId;
  final GameData data;
  final DateTime startDate;
  final bool isOffline;
  final bool fromAssignment;

  const GameSession({
    required this.gameId,
    required this.data,
    required this.startDate,
    this.isOffline = false,
    this.fromAssignment = false,
  });

  /// activityId real para el POST /complete (mirror de GameSummary.jsx:
  /// si el start devolvió activityId es asignación; si no, gameId hace de ambos).
  int get effectiveActivityId => data.activityId ?? gameId;
}

/// Resultado local de un juego terminado, listo para enviar o encolar.
class GameOutcome {
  final int correctAnswers;
  final int totalQuestions;
  final List<ResponseLog> responseLogs;

  const GameOutcome({
    required this.correctAnswers,
    required this.totalQuestions,
    required this.responseLogs,
  });
}

class GameSessionController extends Notifier<GameSession?> {
  @override
  GameSession? build() => null;

  ActivityService get _service => ref.read(activityServiceProvider);
  AppDatabase get _db => ref.read(appDatabaseProvider);

  /// Inicia un juego desde el panel (POST start/game/{id}); si no hay red,
  /// usa el contenido cacheado en drift.
  Future<GameSession> startFromGame(GameSummaryDto game) async {
    GameData data;
    bool offline = false;
    try {
      data = await _service.startGame(game.id);
      data = await preloadGameAssets(data);
      // Refrescar el caché offline con el contenido más reciente.
      await _db.upsertCachedGame(CachedGamesCompanion(
        gameId: Value(game.id),
        gameType: Value(data.gameType ?? game.gameType ?? ''),
        title: Value(game.title),
        topic: Value(game.topic),
        difficult: Value(game.difficult),
        experience: Value(game.experience),
        totalQuestions: Value(game.totalQuestions),
        contentJson: Value(jsonEncode(data.toJson())),
        updatedAt: Value(DateTime.now()),
      ));
    } catch (_) {
      final cached = await _db.cachedGame(game.id);
      if (cached == null) rethrow;
      data = GameData.fromJson(
          jsonDecode(cached.contentJson) as Map<String, dynamic>);
      offline = true;
    }

    final session = GameSession(
      gameId: game.id,
      data: data,
      startDate: DateTime.now(),
      isOffline: offline,
    );
    state = session;
    return session;
  }

  /// Inicia una actividad asignada (POST start/{activityId}). Solo online.
  Future<GameSession> startFromAssignment(int activityId) async {
    var data = await _service.startAssignedActivity(activityId);
    data = await preloadGameAssets(data);
    final session = GameSession(
      gameId: activityId,
      data: data,
      startDate: DateTime.now(),
      fromAssignment: true,
    );
    state = session;
    return session;
  }

  /// Reinicia el reloj para "jugar de nuevo" con el mismo contenido.
  void restart() {
    final current = state;
    if (current != null) {
      state = GameSession(
        gameId: current.gameId,
        data: current.data,
        startDate: DateTime.now(),
        isOffline: current.isOffline,
        fromAssignment: current.fromAssignment,
      );
    }
  }

  void clear() => state = null;

  /// Envía el resultado (o lo encola si no hay red).
  /// Devuelve el RewardResult, o null si quedó pendiente de sincronizar.
  Future<RewardResult?> complete(GameOutcome outcome) async {
    final session = state;
    if (session == null) return null;

    final startDateIso = session.startDate.toIso8601String();
    try {
      return await _service.completeActivity(
        activityId: session.effectiveActivityId,
        startDate: startDateIso,
        correctAnswers: outcome.correctAnswers,
        responseLogs: outcome.responseLogs,
        gameId: session.gameId,
      );
    } catch (_) {
      // Sin conexión: encolar para el protocolo de sincronización de 2 pasos.
      await _db.enqueueResult(PendingResultsCompanion(
        gameId: Value(session.gameId),
        title: Value(session.data.title ?? ''),
        gameType: Value(session.data.gameType ?? ''),
        startDate: Value(startDateIso),
        correctAnswers: Value(outcome.correctAnswers),
        totalQuestions: Value(outcome.totalQuestions),
        responseLogsJson: Value(
            jsonEncode(outcome.responseLogs.map((l) => l.toJson()).toList())),
        completedAt: Value(DateTime.now()),
      ));
      return null;
    }
  }
}

final gameSessionProvider =
    NotifierProvider<GameSessionController, GameSession?>(
        GameSessionController.new);
