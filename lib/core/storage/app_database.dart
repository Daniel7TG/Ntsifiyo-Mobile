import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../stars.dart';
import 'media_cache_key.dart';

part 'app_database.g.dart';

/// Contenido de juego cacheado para jugar offline.
/// `contentJson` es el GameData serializado con URLs reescritas a rutas
/// (relativas, resueltas por MediaStore) o URLs remotas para lo que falló.
/// `mediaComplete` indica si TODOS sus medios se descargaron con éxito;
/// mientras sea `false`, GameCacheService reintenta este juego en cada
/// conexión en vez de darlo por cacheado.
class CachedGames extends Table {
  IntColumn get gameId => integer()();
  TextColumn get gameType => text()();
  TextColumn get title => text()();
  TextColumn get topic => text().nullable()();
  TextColumn get difficult => text().nullable()();
  IntColumn get experience => integer().nullable()();
  IntColumn get totalQuestions => integer().nullable()();
  TextColumn get contentJson => text()();
  BoolColumn get mediaComplete =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {gameId};
}

/// Resultados de juegos terminados offline, pendientes de sincronizar.
/// `attempts` cuenta los rechazos definitivos del servidor (no de red): al
/// llegar al límite, SyncService descarta la fila en vez de bloquear la cola.
class PendingResults extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get gameId => integer()();
  TextColumn get title => text()();
  TextColumn get gameType => text()();
  TextColumn get startDate => text()(); // ISO-8601, formato del backend
  IntColumn get correctAnswers => integer()();
  IntColumn get totalQuestions => integer()();
  TextColumn get responseLogsJson => text()();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  DateTimeColumn get completedAt => dateTime()();
}

/// Almacén clave-valor para copias cacheadas (dashboards, listas de juegos).
class PendingDailyResults extends Table {
  TextColumn get account => text()();
  IntColumn get challengeId => integer()();
  TextColumn get challengeJson => text()();
  DateTimeColumn get completedAt => dateTime()();
  TextColumn get error => text().nullable()();
  BoolColumn get retryable => boolean().withDefault(const Constant(true))();
  @override
  Set<Column> get primaryKey => {account, challengeId};
}

class KvEntries extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {key};
}

/// Registro de binarios descargados (imágenes/audio de juegos y diccionario).
/// Conserva la URL remota original: si el archivo local se pierde (borrado
/// por el sistema, contenedor de la app recreado en iOS…), MediaStore puede
/// recuperar el recurso sirviendo de nuevo la URL en vez de mostrar un ícono
/// roto de forma permanente.
@DataClassName('CachedMediaData')
class CachedMedia extends Table {
  // Clave de caché ESTABLE (`MediaStore.mediaCacheKey`): la URL de OCI sin
  // el segmento de token PAR, que el backend rota en cada respuesta. No es
  // una URL descargable por sí sola.
  TextColumn get url => text()();
  // Última URL absoluta (con PAR vigente) vista para este objeto. Sirve
  // para recuperar el recurso por red si el archivo local desaparece y el
  // PAR de `url` ya expiró (dura 1h); nullable porque las filas de antes de
  // esta columna no la tienen.
  TextColumn get sourceUrl => text().nullable()();
  TextColumn get relativePath => text()();
  IntColumn get byteSize => integer()();
  TextColumn get kind => text()(); // 'image' | 'audio'
  DateTimeColumn get downloadedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {url};
}

/// Palabras del diccionario cacheadas (antes vivían solo en un JSON suelto
/// en disco). `imagePath`/`audioPath` son rutas de asset del bundle o rutas
/// relativas resueltas por MediaStore; se mantienen null si la palabra no
/// tiene ese medio.
class CachedWords extends Table {
  IntColumn get id => integer()();
  TextColumn get spanishWord => text()();
  TextColumn get mazahuaWord => text()();
  TextColumn get spanishPronunciation => text().nullable()();
  TextColumn get mazahuaPronunciation => text().nullable()();
  TextColumn get category => text()();
  TextColumn get imagePath => text().nullable()();
  TextColumn get audioPath => text().nullable()();
  BoolColumn get pronunciation =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Juegos completados con éxito, para inferir el progreso del camino de
/// aprendizaje por tema. El backend no expone `completed`/`locked`/`order`
/// para ningún endpoint de actividades — esta tabla es la única fuente de
/// progreso por unidad, y por lo tanto es local al dispositivo: no viaja
/// entre teléfonos ni sobrevive a una reinstalación.
class CompletedGames extends Table {
  IntColumn get gameId => integer()();
  TextColumn get topic => text().nullable()();
  IntColumn get correctAnswers => integer()();
  IntColumn get totalQuestions => integer()();
  /// Mejores estrellas conseguidas en esta actividad (0-5, ver
  /// `lib/core/stars.dart`). `recordGameCompletion` nunca las hace bajar:
  /// rejugar peor no debe restarle progreso al anillo del mapa.
  IntColumn get stars => integer().withDefault(const Constant(0))();
  DateTimeColumn get completedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {gameId};
}

/// Punto de sincronización de cada catálogo remoto (`GAME`, `DICTIONARY`)
/// contra `GET /api/catalog/updates`; ver `ResourceUpdateService`.
///
/// [syncCursor] es el `serverTime` de la última respuesta **aplicada con
/// éxito**, guardado como texto sin parsear para reenviarlo verbatim como
/// `since`: el backend lo emite como `LocalDateTime` (sin zona) y lo compara
/// contra su propio reloj, así que pasarlo por `DateTime` lo interpretaría
/// en la zona del dispositivo y podría desplazarlo horas.
///
/// Hay una fila por recurso justamente para que un fallo parcial no pierda
/// cambios: si los juegos se aplican pero el diccionario falla, solo avanza
/// el cursor de `GAME` y el de `DICTIONARY` se reintenta desde donde estaba.
/// Las tres columnas `last*` son informativas (último cambio aplicado), no
/// entran en la decisión de refrescar.
class ResourceUpdates extends Table {
  TextColumn get resource => text()(); // 'GAME' | 'DICTIONARY'
  DateTimeColumn get lastUpdatedAt => dateTime().nullable()();
  TextColumn get lastChangeType =>
      text().nullable()(); // CREATED | UPDATED | DELETED
  IntColumn get lastResourceId => integer().nullable()();
  TextColumn get syncCursor => text().nullable()();

  @override
  Set<Column> get primaryKey => {resource};
}

@DriftDatabase(tables: [
  CachedGames,
  PendingResults,
  KvEntries,
  CachedMedia,
  CachedWords,
  CompletedGames,
  ResourceUpdates,
  PendingDailyResults,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'jnatrjo'));

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 11;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(cachedMedia);
            await m.createTable(cachedWords);
            // Default false: fuerza que todo juego cacheado con el esquema
            // viejo (posibles rutas absolutas) se re-verifique y repare en
            // la siguiente conexión.
            await m.addColumn(cachedGames, cachedGames.mediaComplete);
            await m.addColumn(pendingResults, pendingResults.attempts);
          }
          if (from < 3) {
            await m.createTable(completedGames);
          }
          if (from < 4) {
            await m.drop(cachedWords);
            await m.createTable(cachedWords);
            await m.drop(cachedGames);
            await m.createTable(cachedGames);
          }
          if (from < 5) {
            await m.drop(cachedWords);
            await m.createTable(cachedWords);
          }
          if (from < 6) {
            await m.addColumn(cachedWords, cachedWords.pronunciation);
          }
          if (from < 7) {
            await m.createTable(resourceUpdates);
          }
          if (from < 8) {
            // Cursor de sincronización incremental (`serverTime` de
            // /api/catalog/updates). Nace en null: el primer arranque tras
            // actualizar cae a la fecha del bundle como línea base, igual
            // que una instalación nueva, en vez de pedir el catálogo entero.
            await m.addColumn(resourceUpdates, resourceUpdates.syncCursor);
          }
          if (from < 9) {
            // `CachedMedia` pasa a clavarse por `mediaCacheKey(url)` (sin el
            // token PAR rotativo de OCI) en vez de la URL completa — ver
            // media_cache_key.dart. Sin esta migración, cada fila vieja
            // (clavada con un token ya usado) sería un miss eterno y todo se
            // re-descargaría una vez más en el primer arranque tras
            // actualizar, aunque el archivo siga en disco.
            await m.addColumn(cachedMedia, cachedMedia.sourceUrl);
            final rows = await select(cachedMedia).get();
            // Varias URLs viejas (tokens PAR distintos del mismo objeto)
            // pueden colapsar a la misma clave nueva: nos quedamos con la
            // descarga más reciente y de paso liberamos el archivo duplicado
            // de las demás, en vez de dejarlo huérfano en disco para
            // siempre.
            final byKey = <String, CachedMediaData>{};
            for (final row in rows) {
              final key = mediaCacheKey(row.url);
              final current = byKey[key];
              if (current == null ||
                  row.downloadedAt.isAfter(current.downloadedAt)) {
                byKey[key] = row;
              }
            }
            await batch((b) {
              b.deleteWhere(cachedMedia, (_) => const Constant(true));
              b.insertAll(
                cachedMedia,
                [
                  for (final row in byKey.values)
                    CachedMediaCompanion(
                      url: Value(mediaCacheKey(row.url)),
                      sourceUrl: Value(row.url),
                      relativePath: Value(row.relativePath),
                      byteSize: Value(row.byteSize),
                      kind: Value(row.kind),
                      downloadedAt: Value(row.downloadedAt),
                    ),
                ],
              );
            });
          }
          if (from < 10) {
            // Estrellas por actividad (`lib/core/stars.dart`), persistentes.
            // Backfill inmediato: las filas viejas ya guardan aciertos/total,
            // así que nadie pierde progreso al actualizar la app.
            await m.addColumn(completedGames, completedGames.stars);
            final rows = await select(completedGames).get();
            await batch((b) {
              for (final row in rows) {
                b.update(
                  completedGames,
                  CompletedGamesCompanion(
                    stars: Value(
                        starsFor(row.correctAnswers, row.totalQuestions)),
                  ),
                  where: (t) => t.gameId.equals(row.gameId),
                );
              }
            });
          }
          if (from < 11) {
            await m.createTable(pendingDailyResults);
          }
        },
      );

  Future<List<PendingDailyResult>> dailyPending(String account) =>
      (select(pendingDailyResults)..where((t) => t.account.equals(account))).get();

  Future<void> enqueueDaily(PendingDailyResultsCompanion entry) async {
    await into(pendingDailyResults).insert(entry, mode: InsertMode.insertOrIgnore);
  }
  Future<void> deleteDaily(String account, int id) async {
    await (delete(pendingDailyResults)..where((t) => t.account.equals(account) & t.challengeId.equals(id))).go();
  }
  Future<void> rejectDaily(String account, int id, String message, {bool retryable = false}) async {
    await (update(pendingDailyResults)..where((t) => t.account.equals(account) & t.challengeId.equals(id)))
      .write(PendingDailyResultsCompanion(error: Value(message), retryable: Value(retryable)));
  }

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

  /// Juegos cacheados a los que les falta descargar algún medio.
  Future<List<CachedGame>> gamesNeedingMedia() =>
      (select(cachedGames)..where((g) => g.mediaComplete.equals(false)))
          .get();

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

  Future<void> incrementAttempts(int id) async {
    final row =
        await (select(pendingResults)..where((r) => r.id.equals(id)))
            .getSingleOrNull();
    if (row == null) return;
    await (update(pendingResults)..where((r) => r.id.equals(id)))
        .write(PendingResultsCompanion(attempts: Value(row.attempts + 1)));
  }

  Future<void> deletePendingResult(int id) =>
      (delete(pendingResults)..where((r) => r.id.equals(id))).go();

  // ── Medios descargados ──────────────────────────────────────────────
  Future<CachedMediaData?> cachedMediaByUrl(String url) =>
      (select(cachedMedia)..where((m) => m.url.equals(url)))
          .getSingleOrNull();

  Future<CachedMediaData?> cachedMediaByPath(String relativePath) =>
      (select(cachedMedia)..where((m) => m.relativePath.equals(relativePath)))
          .getSingleOrNull();

  Future<void> upsertCachedMedia(CachedMediaCompanion entry) =>
      into(cachedMedia).insertOnConflictUpdate(entry);

  Future<List<CachedMediaData>> allCachedMedia() => select(cachedMedia).get();

  Future<void> deleteCachedMediaByUrl(String url) =>
      (delete(cachedMedia)..where((m) => m.url.equals(url))).go();

  // ── Palabras del diccionario ────────────────────────────────────────
  Future<List<CachedWord>> allCachedWords() => select(cachedWords).get();

  Future<void> updateWordPronunciationFlag(int id, bool pronunciation) async {
    await (update(cachedWords)..where((w) => w.id.equals(id)))
        .write(CachedWordsCompanion(pronunciation: Value(pronunciation)));
  }

  /// Aplica un delta de `/api/catalog/updates`: mete o reemplaza las
  /// palabras de [upserted] y borra las de [deletedIds], **sin tocar el
  /// resto de la tabla**.
  ///
  /// Aquí no aplica la salvaguarda anti-menguante de
  /// `DictionaryRepository._saveToDb`: esa existe porque una lista completa
  /// corta o vacía es indistinguible de un fallo del backend. Un id con
  /// `changeType: DELETED` es lo contrario — una afirmación positiva y
  /// puntual de que *esa* palabra ya no existe, así que se obedece.
  Future<void> applyCachedWordDelta({
    List<CachedWordsCompanion> upserted = const [],
    Set<int> deletedIds = const {},
  }) {
    final byId = <int, CachedWordsCompanion>{
      for (final e in upserted) e.id.value: e,
    };
    return batch((b) {
      if (deletedIds.isNotEmpty) {
        b.deleteWhere(cachedWords, (w) => w.id.isIn(deletedIds));
      }
      if (byId.isNotEmpty) {
        b.insertAll(cachedWords, byId.values.toList(),
            mode: InsertMode.insertOrReplace);
      }
    });
  }

  /// Reemplazo completo (no upsert parcial): borra todas las palabras antes
  /// de insertar las nuevas, en la misma transacción del batch, para que
  /// una palabra eliminada en el backend no quede huérfana para siempre.
  ///
  /// Deduplica por `id` antes de insertar (se queda con la última): un id
  /// repetido en la respuesta del backend (misma palabra en dos categorías,
  /// páginas solapadas) violaría la PK y antes hacía fallar el batch
  /// entero, dejando la tabla vacía sin ningún aviso.
  Future<void> replaceCachedWords(List<CachedWordsCompanion> entries) {
    final byId = <int, CachedWordsCompanion>{
      for (final e in entries) e.id.value: e,
    };
    return batch((b) {
      b.deleteWhere(cachedWords, (_) => const Constant(true));
      b.insertAll(cachedWords, byId.values.toList(),
          mode: InsertMode.insertOrReplace);
    });
  }

  // ── Progreso local (mapa) ─────────────────────────────────────────────
  /// Registra una partida terminada, conservando siempre la mejor
  /// puntuación. Rejugar peor no debe hacer bajar las estrellas guardadas:
  /// son las que alimentan el anillo de progreso del mapa (`ZoneProgress`,
  /// `lib/features/progress/progress_providers.dart`), y verlo retroceder
  /// tras una partida más floja sería un progreso que deja de progresar.
  /// `topic: null` no pisa el que ya estaba cacheado (mismo cuidado que
  /// `GameSessionController.startFromGame` con `Value.absent()`).
  Future<void> recordGameCompletion({
    required int gameId,
    required String? topic,
    required int correctAnswers,
    required int totalQuestions,
  }) async {
    final newStars = starsFor(correctAnswers, totalQuestions);
    final existing = await (select(completedGames)
          ..where((g) => g.gameId.equals(gameId)))
        .getSingleOrNull();

    final keepPrevious = existing != null && existing.stars > newStars;
    await into(completedGames).insertOnConflictUpdate(CompletedGamesCompanion(
      gameId: Value(gameId),
      topic: Value(topic ?? existing?.topic),
      correctAnswers:
          Value(keepPrevious ? existing.correctAnswers : correctAnswers),
      totalQuestions:
          Value(keepPrevious ? existing.totalQuestions : totalQuestions),
      stars: Value(keepPrevious ? existing.stars : newStars),
      completedAt: Value(DateTime.now()),
    ));
  }

  Future<List<CompletedGame>> completedGamesByTopic(String topic) =>
      (select(completedGames)..where((g) => g.topic.equals(topic))).get();

  Future<List<CompletedGame>> allCompletedGames() =>
      select(completedGames).get();

  Future<Set<int>> allCompletedGameIds() async {
    final rows = await select(completedGames).get();
    return {for (final r in rows) r.gameId};
  }

  // ── Última actualización de catálogos remotos ────────────────────────
  Future<ResourceUpdate?> resourceUpdate(String resource) =>
      (select(resourceUpdates)..where((r) => r.resource.equals(resource)))
          .getSingleOrNull();

  Future<void> putResourceUpdate(ResourceUpdatesCompanion entry) =>
      into(resourceUpdates).insertOnConflictUpdate(entry);

  // ── Recuperación de instalaciones dañadas ────────────────────────────
  /// Vacía las cachés que se repueblan solas desde el bundle o el backend
  /// (juegos, diccionario, dashboards, media descargada y la marca de
  /// frescura). Deliberadamente **no** toca `CompletedGames` (progreso del
  /// camino de aprendizaje) ni `PendingResults` (partidas sin sincronizar):
  /// esos son datos del usuario, no caché. Salida de emergencia para un
  /// dispositivo cuyas cachés quedaron envenenadas antes de este fix.
  Future<void> resetOfflineCaches() => batch((b) {
        b.deleteWhere(cachedGames, (_) => const Constant(true));
        b.deleteWhere(cachedWords, (_) => const Constant(true));
        b.deleteWhere(kvEntries, (_) => const Constant(true));
        b.deleteWhere(cachedMedia, (_) => const Constant(true));
        b.deleteWhere(resourceUpdates, (_) => const Constant(true));
      });
}

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});
