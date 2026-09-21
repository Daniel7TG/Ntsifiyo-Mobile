import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/activity_config.dart';
import '../../core/storage/app_database.dart';
import '../../data/models/models.dart';

/// Actividades disponibles por tipo de juego, leídas por entero de
/// `CachedGames` (Drift), sin llamar a `GET /api/games/{type}`: el bundle y
/// el delta de `GameCacheService` ya dejan el caché poblado, y una consulta
/// de red aquí solo repetiría trabajo que el arranque ya hizo.
///
/// [page] se ignora: no hay paginación real sobre una lista local, así que
/// `GameAccessScreen` siempre ve una sola página (el `Paged` por defecto ya
/// sale con `totalPages: 1`).
final activitiesByTypeProvider = FutureProvider.autoDispose
    .family<Paged<GameSummaryDto>, (String, int)>((ref, key) async {
  final (type, _) = key;
  final db = ref.read(appDatabaseProvider);
  final cached = await db.cachedGamesByType(type);
  return Paged(
    content: [
      for (final g in cached)
        if (isGameTypeEnabled(g.gameType))
          GameSummaryDto(
            id: g.gameId,
            title: g.title,
            difficult: g.difficult,
            gameType: g.gameType,
            topic: g.topic,
            experience: g.experience,
            totalQuestions: g.totalQuestions,
            gameConfigs: _configsFromContent(g.contentJson),
          ),
    ],
  );
});

/// Todas las actividades cacheadas, agrupadas por tipo — el panel libre de
/// `/inicio` (`GamesHubScreen`). A diferencia del progreso del mapa
/// (`progress_providers.dart`), esto **no** se recorta a
/// `GameCacheService.bundleGameIds()`: el panel es acceso libre y crece con
/// cada juego que llegue por `GET /api/catalog/updates`, sin entrar nunca en
/// ninguna zona ni mover ningún anillo. Una sola lectura de
/// `CachedGames`, agrupada en memoria.
final gamesByTypeProvider =
    FutureProvider.autoDispose<Map<String, List<GameSummaryDto>>>((ref) async {
  final db = ref.read(appDatabaseProvider);
  final cached = await db.allCachedGames();

  final byType = <String, List<GameSummaryDto>>{};
  for (final g in cached) {
    if (!isGameTypeEnabled(g.gameType)) continue;
    byType.putIfAbsent(g.gameType, () => []).add(GameSummaryDto(
          id: g.gameId,
          title: g.title,
          difficult: g.difficult,
          gameType: g.gameType,
          topic: g.topic,
          experience: g.experience,
          totalQuestions: g.totalQuestions,
        ));
  }
  return byType;
});

List<GameConfig> _configsFromContent(String contentJson) {
  try {
    final data =
        GameData.fromJson(jsonDecode(contentJson) as Map<String, dynamic>);
    return data.gameConfigs;
  } catch (_) {
    return const [];
  }
}
