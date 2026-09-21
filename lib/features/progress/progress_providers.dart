import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/activity_config.dart';
import '../../app/map_zones.dart';
import '../../core/stars.dart';
import '../../core/storage/app_database.dart';
import '../../core/sync/game_cache_service.dart';
import '../../data/models/models.dart';

/// Progreso local de una zona del mapa (o el total de todas ellas).
class ZoneProgress {
  final int earnedStars;
  final int possibleStars;
  final int totalGames;
  final int completedGames;

  const ZoneProgress({
    this.earnedStars = 0,
    this.possibleStars = 0,
    this.totalGames = 0,
    this.completedGames = 0,
  });

  static const empty = ZoneProgress();

  /// Una zona sin actividades cuenta como terminada: no debe frenar el mapa
  /// ni mostrarse como "en construcción".
  double get percent => possibleStars == 0 ? 1 : earnedStars / possibleStars;
}

class ProgressSnapshot {
  final Map<String, ZoneProgress> byZone;
  final ZoneProgress total;
  /// Mejores estrellas por `gameId`, para pintarlas en la tarjeta de cada
  /// actividad del mapa (no solo el agregado por zona).
  final Map<int, int> starsByGameId;

  const ProgressSnapshot({
    required this.byZone,
    required this.total,
    required this.starsByGameId,
  });
}

/// Calcula el progreso a partir de sus tres insumos, sin tocar Drift ni
/// `rootBundle` — función pura para poder testearla con fixtures literales
/// (mismo patrón que `parseGamesBundle` en `game_cache_service.dart`).
///
/// El recorte por [bundleGameIds] es lo que mantiene estable el
/// denominador: los juegos que lleguen después por
/// `GET /api/catalog/updates` se juegan desde el panel libre (acceso libre,
/// sin progreso) pero no entran aquí, para que publicar contenido nuevo no
/// haga retroceder el anillo de nadie. `disabledGameTypes` (MAZE) tampoco
/// entra: no es jugable en teléfono.
ProgressSnapshot computeProgressSnapshot({
  required List<CachedGame> allGames,
  required List<CompletedGame> completedGames,
  required Set<int> bundleGameIds,
}) {
  final starsByGameId = {for (final c in completedGames) c.gameId: c.stars};

  final eligible = [
    for (final g in allGames)
      if (bundleGameIds.contains(g.gameId) && isGameTypeEnabled(g.gameType))
        g,
  ];

  final byZone = <String, ZoneProgress>{};
  for (final zone in mapZones) {
    // Zonas de media: se agrupan por gameType. Zonas por tema: excluyen los
    // tipos de media, para que un juego de media tageado con un topic
    // cualquiera no aparezca también en esa zona ni se cuente dos veces.
    final games = zone.gameTypes.isNotEmpty
        ? eligible.where((g) => zone.gameTypes.contains(g.gameType))
        : eligible.where((g) =>
            zone.topics.any((t) => t.$1 == g.topic) &&
            !mediaTypes.contains(g.gameType));

    var earned = 0;
    var done = 0;
    var total = 0;
    for (final g in games) {
      total++;
      final stars = starsByGameId[g.gameId];
      if (stars != null) {
        earned += stars;
        done++;
      }
    }
    byZone[zone.id] = ZoneProgress(
      earnedStars: earned,
      possibleStars: total * maxStars,
      totalGames: total,
      completedGames: done,
    );
  }

  final total = ZoneProgress(
    earnedStars: byZone.values.fold(0, (s, z) => s + z.earnedStars),
    possibleStars: byZone.values.fold(0, (s, z) => s + z.possibleStars),
    totalGames: byZone.values.fold(0, (s, z) => s + z.totalGames),
    completedGames: byZone.values.fold(0, (s, z) => s + z.completedGames),
  );

  return ProgressSnapshot(
      byZone: byZone, total: total, starsByGameId: starsByGameId);
}

/// Foto del progreso local: catálogo cacheado ∩ juegos compilados en el
/// bundle, más las partidas terminadas. El backend no expone progreso (ver
/// CLAUDE.md), así que todo esto es inferencia del cliente sobre
/// `CachedGames` + `CompletedGames` (`computeProgressSnapshot`).
final progressSnapshotProvider =
    FutureProvider<ProgressSnapshot>((ref) async {
  final db = ref.read(appDatabaseProvider);
  final gameCache = ref.read(gameCacheServiceProvider);

  return computeProgressSnapshot(
    allGames: await db.allCachedGames(),
    completedGames: await db.allCompletedGames(),
    bundleGameIds: await gameCache.bundleGameIds(),
  );
});

/// Progreso por zona, listo para pintar sin lidiar con `AsyncValue` — vacío
/// mientras `progressSnapshotProvider` sigue cargando o falló (el mapa
/// entonces se ve sin anillos hasta que resuelva, nunca rompe).
final zoneProgressProvider = Provider<Map<String, ZoneProgress>>((ref) {
  return ref.watch(progressSnapshotProvider).value?.byZone ?? const {};
});

/// Progreso global, para el resumen del mapa en `/inicio` y en
/// `ExploreHubScreen`.
final totalProgressProvider = Provider<ZoneProgress>((ref) {
  return ref.watch(progressSnapshotProvider).value?.total ??
      ZoneProgress.empty;
});

/// Mejores estrellas por `gameId`, para las tarjetas de actividad del mapa.
final gameStarsProvider = Provider<Map<int, int>>((ref) {
  return ref.watch(progressSnapshotProvider).value?.starsByGameId ??
      const {};
});

/// Temas de una zona con al menos un juego jugable y compilado en el
/// bundle. Sin este filtro, `VOWELS` y `GREETINGS` — que no tienen ningún
/// juego en `assets/games/manifest.json` y son el chip por defecto de
/// Escuela y Parque — abrían la hoja de la zona directo en "Sin juegos por
/// ahora".
final zoneAvailableTopicsProvider = FutureProvider.autoDispose
    .family<List<(String, String)>, String>((ref, zoneId) async {
  final zone = mapZones.firstWhere((z) => z.id == zoneId);
  if (zone.topics.isEmpty) return const [];

  final db = ref.read(appDatabaseProvider);
  final gameCache = ref.read(gameCacheServiceProvider);
  final bundleIds = await gameCache.bundleGameIds();
  final allGames = await db.allCachedGames();

  final eligibleTopics = <String?>{
    for (final g in allGames)
      if (bundleIds.contains(g.gameId) &&
          isGameTypeEnabled(g.gameType) &&
          !mediaTypes.contains(g.gameType))
        g.topic,
  };

  return [
    for (final t in zone.topics)
      if (eligibleTopics.contains(t.$1)) t,
  ];
});

/// Juegos jugables de una zona del mapa — `topic` se ignora para una zona de
/// media (`zone.gameTypes` no vacío; agrupa por tipo, no por tema). Recorta
/// a `bundleGameIds()` igual que `progressSnapshotProvider`, a propósito:
/// la lista que ve el usuario y el denominador del anillo tienen que ser
/// exactamente el mismo conjunto, o el porcentaje dejaría de cuadrar con lo
/// que hay listado.
final gamesForZoneProvider = FutureProvider.autoDispose
    .family<List<GameSummaryDto>, (String zoneId, String? topic)>(
        (ref, key) async {
  final (zoneId, topic) = key;
  final zone = mapZones.firstWhere((z) => z.id == zoneId);

  final db = ref.read(appDatabaseProvider);
  final gameCache = ref.read(gameCacheServiceProvider);
  final bundleIds = await gameCache.bundleGameIds();
  final allGames = await db.allCachedGames();

  bool matches(CachedGame g) {
    if (!bundleIds.contains(g.gameId) || !isGameTypeEnabled(g.gameType)) {
      return false;
    }
    if (zone.gameTypes.isNotEmpty) return zone.gameTypes.contains(g.gameType);
    return g.topic == topic && !mediaTypes.contains(g.gameType);
  }

  return [
    for (final g in allGames)
      if (matches(g))
        GameSummaryDto(
          id: g.gameId,
          title: g.title,
          difficult: g.difficult,
          gameType: g.gameType,
          topic: g.topic,
          experience: g.experience,
          totalQuestions: g.totalQuestions,
        ),
  ];
});
