import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../core/storage/app_database.dart';
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
      data = await _preloadAssets(data);
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
    data = await _preloadAssets(data);
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

  /// Descarga imágenes/audio referenciados a disco y reescribe las URLs
  /// (equivalente persistente del preloadAssets de GameAccessPanel.jsx).
  Future<GameData> _preloadAssets(GameData data) async {
    final dir = await getApplicationSupportDirectory();
    final mediaDir = Directory(p.join(dir.path, 'game_media'));
    if (!mediaDir.existsSync()) mediaDir.createSync(recursive: true);
    final dio = Dio();
    final cache = <String, String>{};

    Future<String?> localize(String? url) async {
      if (url == null || url.isEmpty || !url.startsWith('http')) return url;
      if (cache.containsKey(url)) return cache[url];
      final name = url.hashCode.toRadixString(16) +
          p.extension(Uri.parse(url).path);
      final file = File(p.join(mediaDir.path, name));
      if (!file.existsSync()) {
        try {
          await dio.download(url, file.path);
        } catch (_) {
          return url; // sin conexión o error: dejar URL remota
        }
      }
      cache[url] = file.path;
      return file.path;
    }

    Future<Word> localizeWord(Word w) async => w.copyWith(
          imageUrl: await localize(w.imageUrl),
          audioUrl: await localize(w.audioUrl),
        );

    final words = [for (final w in data.words) await localizeWord(w)];
    final questions = <Question>[];
    for (final q in data.questions) {
      final answers = <Answer>[];
      for (final a in q.responseList) {
        answers.add(Answer(
          id: a.id,
          answerText: a.answerText,
          isCorrect: a.isCorrect,
          wordId: a.wordId,
          word: a.word != null ? await localizeWord(a.word!) : null,
        ));
      }
      questions.add(Question(
        id: q.id,
        question: q.question,
        responseList: answers,
        word: q.word != null ? await localizeWord(q.word!) : null,
      ));
    }

    return GameData(
      activityId: data.activityId,
      gameType: data.gameType,
      title: data.title,
      difficult: data.difficult,
      experience: data.experience,
      totalQuestions: data.totalQuestions,
      questions: questions,
      words: words,
      gameConfigs: data.gameConfigs,
      mediaId: data.mediaId,
    );
  }

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
