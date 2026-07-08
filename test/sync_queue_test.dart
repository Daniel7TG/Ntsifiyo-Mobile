import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jnatrjo_mobile/core/storage/app_database.dart';
import 'package:jnatrjo_mobile/data/models/models.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() => db.close());

  test('cola de resultados pendientes: encolar, listar y eliminar', () async {
    expect(await db.pendingCount(), 0);

    final logs = [
      const ResponseLog(questionId: 1, responseAnswerId: 10, isCorrect: true),
      const ResponseLog(questionId: 2, responseAnswerId: 20, isCorrect: false),
    ];

    final id = await db.enqueueResult(PendingResultsCompanion(
      gameId: const Value(42),
      title: const Value('Quiz de animales'),
      gameType: const Value('QUESTIONNAIRE'),
      startDate: Value(DateTime(2026, 7, 8).toIso8601String()),
      correctAnswers: const Value(1),
      totalQuestions: const Value(2),
      responseLogsJson:
          Value(jsonEncode(logs.map((l) => l.toJson()).toList())),
      completedAt: Value(DateTime.now()),
    ));

    expect(await db.pendingCount(), 1);

    final pending = await db.allPendingResults();
    expect(pending, hasLength(1));
    expect(pending.first.gameId, 42);

    // Los logs sobreviven el viaje JSON con el shape que espera el backend.
    final restored = (jsonDecode(pending.first.responseLogsJson) as List)
        .whereType<Map<String, dynamic>>()
        .map(ResponseLog.fromJson)
        .toList();
    expect(restored, hasLength(2));
    expect(restored.first.responseAnswerId, 10);
    expect(restored.first.isCorrect, isTrue);
    expect(restored.first.toApiJson().keys,
        containsAll(['questionId', 'responseAnswerId', 'isCorrect']));

    await db.deletePendingResult(id);
    expect(await db.pendingCount(), 0);
  });

  test('caché de juegos: upsert y consulta por tipo y tópico', () async {
    final content = const GameData(
      gameType: 'MEMORY_GAME',
      words: [Word(id: 1, spanishWord: 'perro', mazahuaWord: "dyo'o")],
    );

    await db.upsertCachedGame(CachedGamesCompanion(
      gameId: const Value(7),
      gameType: const Value('MEMORY_GAME'),
      title: const Value('Memorama animales'),
      topic: const Value('ANIMALS'),
      contentJson: Value(jsonEncode(content.toJson())),
      updatedAt: Value(DateTime.now()),
    ));

    final byType = await db.cachedGamesByType('MEMORY_GAME');
    expect(byType, hasLength(1));

    final byTopic = await db.cachedGamesByTopic('ANIMALS');
    expect(byTopic, hasLength(1));

    final restored = GameData.fromJson(
        jsonDecode(byTopic.first.contentJson) as Map<String, dynamic>);
    expect(restored.words.first.mazahuaWord, "dyo'o");
  });
}
