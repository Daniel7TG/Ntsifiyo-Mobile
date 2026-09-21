import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jnatrjo_mobile/core/storage/app_database.dart';
import 'package:jnatrjo_mobile/features/progress/progress_providers.dart';

CachedGame _game(int id, String gameType, {String? topic}) => CachedGame(
      gameId: id,
      gameType: gameType,
      title: 'juego $id',
      topic: topic,
      contentJson: '{}',
      mediaComplete: true,
      updatedAt: DateTime.now(),
    );

CompletedGame _completed(int id, int stars, {String? topic}) => CompletedGame(
      gameId: id,
      topic: topic,
      correctAnswers: stars,
      totalQuestions: 5,
      stars: stars,
      completedAt: DateTime.now(),
    );

void main() {
  group('AppDatabase.recordGameCompletion', () {
    late AppDatabase db;
    setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
    tearDown(() => db.close());

    test('conserva la mejor puntuación al rejugar peor', () async {
      await db.recordGameCompletion(
        gameId: 1,
        topic: 'ANIMALS',
        correctAnswers: 5,
        totalQuestions: 5,
      );
      // Rejugar peor: 1 de 5 aciertos.
      await db.recordGameCompletion(
        gameId: 1,
        topic: 'ANIMALS',
        correctAnswers: 1,
        totalQuestions: 5,
      );

      final rows = await db.allCompletedGames();
      expect(rows.single.stars, 5);
      expect(rows.single.correctAnswers, 5);
    });

    test('sí sube las estrellas al rejugar mejor', () async {
      await db.recordGameCompletion(
        gameId: 1,
        topic: 'ANIMALS',
        correctAnswers: 1,
        totalQuestions: 5,
      );
      await db.recordGameCompletion(
        gameId: 1,
        topic: 'ANIMALS',
        correctAnswers: 5,
        totalQuestions: 5,
      );

      final rows = await db.allCompletedGames();
      expect(rows.single.stars, 5);
    });

    test('topic: null no pisa el que ya estaba cacheado', () async {
      await db.recordGameCompletion(
        gameId: 1,
        topic: 'ANIMALS',
        correctAnswers: 3,
        totalQuestions: 5,
      );
      await db.recordGameCompletion(
        gameId: 1,
        topic: null,
        correctAnswers: 4,
        totalQuestions: 5,
      );

      final rows = await db.allCompletedGames();
      expect(rows.single.topic, 'ANIMALS');
    });
  });

  group('ZoneProgress.percent', () {
    test('una zona sin actividades cuenta como 100% (no debe frenar el '
        'mapa ni verse como "en construcción")', () {
      expect(ZoneProgress.empty.percent, 1.0);
    });

    test('estrellas ganadas sobre posibles, no partidas completadas sobre '
        'total', () {
      const progress = ZoneProgress(
        earnedStars: 21,
        possibleStars: 40,
        totalGames: 8,
        completedGames: 8,
      );
      expect(progress.percent, 21 / 40);
    });
  });

  group('computeProgressSnapshot', () {
    test('MAZE no entra en el denominador de ninguna zona', () {
      final snapshot = computeProgressSnapshot(
        allGames: [
          _game(1, 'MEMORY_GAME', topic: 'ANIMALS'),
          _game(2, 'MAZE', topic: 'ANIMALS'),
        ],
        completedGames: const [],
        bundleGameIds: {1, 2},
      );
      expect(snapshot.byZone['FARM']!.totalGames, 1);
    });

    test(
        'un juego en CachedGames pero fuera de bundleGameIds no altera '
        'possibleStars de ninguna zona (universo congelado al bundle)', () {
      final snapshot = computeProgressSnapshot(
        allGames: [
          _game(1, 'MEMORY_GAME', topic: 'ANIMALS'), // en el bundle
          _game(2, 'MEMORY_GAME', topic: 'ANIMALS'), // llegó después, no
        ],
        completedGames: const [],
        bundleGameIds: {1},
      );
      final farm = snapshot.byZone['FARM']!;
      expect(farm.totalGames, 1);
      expect(farm.possibleStars, 5);
    });

    test('una zona de media agrupa por gameType, no por topic', () {
      final snapshot = computeProgressSnapshot(
        allGames: [
          // Tageado con un topic cualquiera: para el Campamento no importa,
          // se agrupa por MEDIA_LEGEND.
          _game(1, 'MEDIA_LEGEND', topic: 'ANIMALS'),
          _game(2, 'MEDIA_ANECDOTE'),
          // Mismo topic que arriba pero no es media: no debe colarse en la
          // Granja ni en el Campamento (excluido por `!mediaTypes.contains`
          // para las zonas por tema).
          _game(3, 'MEMORY_GAME', topic: 'ANIMALS'),
        ],
        completedGames: const [],
        bundleGameIds: {1, 2, 3},
      );

      expect(snapshot.byZone['FOREST']!.totalGames, 2); // Campamento
      expect(snapshot.byZone['FARM']!.totalGames, 1); // Granja
    });

    test('las estrellas ganadas y totales agregan bien al total global', () {
      final snapshot = computeProgressSnapshot(
        allGames: [
          _game(1, 'MEMORY_GAME', topic: 'ANIMALS'),
          _game(2, 'MEDIA_SONG'),
        ],
        completedGames: [
          _completed(1, 4, topic: 'ANIMALS'),
        ],
        bundleGameIds: {1, 2},
      );

      expect(snapshot.total.totalGames, 2);
      expect(snapshot.total.possibleStars, 10);
      expect(snapshot.total.earnedStars, 4);
      expect(snapshot.starsByGameId[1], 4);
    });
  });
}
