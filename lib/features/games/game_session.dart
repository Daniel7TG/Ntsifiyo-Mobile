import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_client.dart';
import '../../core/storage/app_database.dart';
import '../../core/storage/media_store.dart';
import '../../core/sync/asset_preloader.dart';
import '../../data/models/models.dart';
import '../../data/services/activity_service.dart';
import '../progress/progress_providers.dart';

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
  MediaStore get _mediaStore => ref.read(mediaStoreProvider);

  /// Inicia un juego desde el panel (POST start/game/{id}); si no hay red,
  /// usa el contenido cacheado en drift.
  Future<GameSession> startFromGame(GameSummaryDto game) async {
    GameData data;
    bool offline = false;
    try {
      data = await _service.startGame(game.id);
      // El start no siempre trae metadatos: completarlos desde el listado.
      data = data.copyWith(
        gameType: data.gameType ?? game.gameType,
        title: data.title ?? game.title,
        difficult: data.difficult ?? game.difficult,
        experience: data.experience ?? game.experience,
        totalQuestions: data.totalQuestions ?? game.totalQuestions,
      );
      final (localized, complete) =
          await preloadGameAssets(data, _mediaStore);
      data = localized;
      // Refrescar el caché offline con el contenido más reciente. `topic`
      // no viene en `GameData` (el `start` nunca lo trae) — solo puede
      // salir de `game.topic`, y si el llamador no lo trajo se deja
      // `Value.absent()` para no pisar con null el que ya estaba cacheado
      // (mismo bug que tuvo `progress_providers.dart`: un `topic: null` aquí
      // deja la fila invisible para el progreso del mapa).
      await _db.upsertCachedGame(CachedGamesCompanion(
        gameId: Value(game.id),
        gameType: Value(data.gameType ?? ''),
        title: Value(data.title ?? ''),
        topic: game.topic != null ? Value(game.topic) : const Value.absent(),
        difficult: Value(data.difficult),
        experience: Value(data.experience),
        totalQuestions: Value(data.totalQuestions),
        contentJson: Value(jsonEncode(data.toJson())),
        mediaComplete: Value(complete),
        updatedAt: Value(DateTime.now()),
      ));
    } catch (_) {
      final cached = await _db.cachedGame(game.id);
      if (cached == null) rethrow;
      final rawData = GameData.fromJson(
          jsonDecode(cached.contentJson) as Map<String, dynamic>);
      data = await resolveGameMedia(rawData, _mediaStore);
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
    final (localized, _) = await preloadGameAssets(data, _mediaStore);
    data = localized;
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
  ///
  /// Devuelve el RewardResult, o null si quedó pendiente de sincronizar.
  /// Si el servidor responde con un error (no es un problema de red) lanza
  /// la ApiException: el resumen ofrece reintentar en vez de encolar algo
  /// que el backend ya rechazó.
  Future<RewardResult?> complete(GameOutcome outcome) async {
    final session = state;
    if (session == null) return null;

    final startDateIso = session.startDate.toIso8601String();
    try {
      final reward = await _service.completeActivity(
        activityId: session.effectiveActivityId,
        startDate: startDateIso,
        correctAnswers: outcome.correctAnswers,
        responseLogs: outcome.responseLogs,
        gameId: session.gameId,
      );
      await _markCompleted(session, outcome);
      return reward;
    } on ApiException catch (e) {
      if (e.status != null) rethrow;
      await _enqueue(session, outcome, startDateIso);
      await _markCompleted(session, outcome);
      return null;
    } catch (_) {
      await _enqueue(session, outcome, startDateIso);
      await _markCompleted(session, outcome);
      return null;
    }
  }

  /// Registra el juego en el progreso local del mapa. El backend no expone
  /// progreso por tema; esta tabla es una inferencia del
  /// cliente a partir del `topic` que quedó guardado en `CachedGames` al
  /// iniciar la partida.
  Future<void> _markCompleted(GameSession session, GameOutcome outcome) async {
    final cached = await _db.cachedGame(session.gameId);
    await _db.recordGameCompletion(
      gameId: session.gameId,
      topic: cached?.topic,
      correctAnswers: outcome.correctAnswers,
      totalQuestions: outcome.totalQuestions,
    );
    // El anillo de la zona (y el resumen global) leen `CompletedGames`
    // entero: sin esto se quedarían mostrando el porcentaje de antes de
    // jugar hasta el siguiente arranque.
    ref.invalidate(progressSnapshotProvider);
  }

  /// Sin conexión: encolar para el protocolo de sincronización de 2 pasos.
  Future<void> _enqueue(
    GameSession session,
    GameOutcome outcome,
    String startDateIso,
  ) =>
      _db.enqueueResult(PendingResultsCompanion(
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
}

final gameSessionProvider =
    NotifierProvider<GameSessionController, GameSession?>(
        GameSessionController.new);
