import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/app_database.dart';
import '../../data/models/models.dart';
import '../../data/services/activity_service.dart';

/// Actividades disponibles por tipo de juego, con fallback al caché offline.
final activitiesByTypeProvider = FutureProvider.autoDispose
    .family<Paged<GameSummaryDto>, (String, int)>((ref, key) async {
  final (type, page) = key;
  final service = ref.read(activityServiceProvider);
  final db = ref.read(appDatabaseProvider);

  try {
    final result = await service.getActivitiesByType(type, page: page);
    return result;
  } catch (_) {
    // Sin red: listar los juegos cacheados de este tipo.
    final cached = await db.cachedGamesByType(type);
    if (cached.isEmpty) rethrow;
    return Paged(
      content: [
        for (final g in cached)
          GameSummaryDto(
            id: g.gameId,
            title: g.title,
            difficult: g.difficult,
            gameType: g.gameType,
            experience: g.experience,
            totalQuestions: g.totalQuestions,
            gameConfigs: _configsFromContent(g.contentJson),
          ),
      ],
    );
  }
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
