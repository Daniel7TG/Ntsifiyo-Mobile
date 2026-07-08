import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'app_database.g.dart';

/// Contenido de juego cacheado para jugar offline.
/// `contentJson` es el GameData serializado con URLs reescritas a rutas locales.
class CachedGames extends Table {
  IntColumn get gameId => integer()();
  TextColumn get gameType => text()();
  TextColumn get title => text()();
  TextColumn get topic => text().nullable()();
  TextColumn get difficult => text().nullable()();
  IntColumn get experience => integer().nullable()();
  IntColumn get totalQuestions => integer().nullable()();
  TextColumn get contentJson => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {gameId};
}

/// Resultados de juegos terminados offline, pendientes de sincronizar.
class PendingResults extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get gameId => integer()();
  TextColumn get title => text()();
  TextColumn get gameType => text()();
  TextColumn get startDate => text()(); // ISO-8601, formato del backend
  IntColumn get correctAnswers => integer()();
  IntColumn get totalQuestions => integer()();
  TextColumn get responseLogsJson => text()();
  DateTimeColumn get completedAt => dateTime()();
}

/// Almacén clave-valor para copias cacheadas (dashboards, listas de juegos).
class KvEntries extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {key};
}

@DriftDatabase(tables: [CachedGames, PendingResults, KvEntries])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'jnatrjo'));

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  // ── KV ──────────────────────────────────────────────────────────────
  Future<String?> kvGet(String key) async {
    final row = await (select(kvEntries)..where((e) => e.key.equals(key)))
        .getSingleOrNull();
    return row?.value;
  }

  Future<void> kvPut(String key, String value) =>
      into(kvEntries).insertOnConflictUpdate(KvEntry(
        key: key,
        value: value,
        updatedAt: DateTime.now(),
      ));

  // ── Juegos cacheados ───────────────────────────────────────────────
  Future<List<CachedGame>> allCachedGames() => select(cachedGames).get();

  Future<List<CachedGame>> cachedGamesByType(String type) =>
      (select(cachedGames)..where((g) => g.gameType.equals(type))).get();

  Future<List<CachedGame>> cachedGamesByTopic(String topic) =>
      (select(cachedGames)..where((g) => g.topic.equals(topic))).get();

  Future<CachedGame?> cachedGame(int gameId) =>
      (select(cachedGames)..where((g) => g.gameId.equals(gameId)))
          .getSingleOrNull();

  Future<void> upsertCachedGame(CachedGamesCompanion entry) =>
      into(cachedGames).insertOnConflictUpdate(entry);

  Future<void> deleteCachedGame(int gameId) =>
      (delete(cachedGames)..where((g) => g.gameId.equals(gameId))).go();

  // ── Cola de sincronización ─────────────────────────────────────────
  Future<int> enqueueResult(PendingResultsCompanion entry) =>
      into(pendingResults).insert(entry);

  Future<List<PendingResult>> allPendingResults() =>
      (select(pendingResults)..orderBy([(r) => OrderingTerm.asc(r.id)]))
          .get();

  Future<int> pendingCount() async {
    final countExp = pendingResults.id.count();
    final query = selectOnly(pendingResults)..addColumns([countExp]);
    final row = await query.getSingle();
    return row.read(countExp) ?? 0;
  }

  Future<void> deletePendingResult(int id) =>
      (delete(pendingResults)..where((r) => r.id.equals(id))).go();
}

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});
