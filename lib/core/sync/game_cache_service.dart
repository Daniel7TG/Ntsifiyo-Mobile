import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/activity_service.dart';
import '../storage/app_database.dart';
import 'asset_preloader.dart';

/// Precarga de juegos para modo offline (requisito del usuario: los juegos
/// se cargan en la primera conexión para poder usarse en cualquier momento).
///
/// GET /api/games → por cada juego sin cachear: POST start/game/{id} para
/// obtener su contenido, descarga los medios a disco y lo guarda en drift.
class GameCacheService {
  final ActivityService _service;
  final AppDatabase _db;

  bool _running = false;

  GameCacheService(this._service, this._db);

  Future<void> cacheAllGames({bool refreshExisting = false}) async {
    if (_running) return;
    _running = true;
    try {
      final games = await _service.getAllGames();
      final cachedIds = {
        for (final g in await _db.allCachedGames()) g.gameId,
      };

      for (final game in games) {
        if (!refreshExisting && cachedIds.contains(game.id)) continue;
        try {
          var data = await _service.startGame(game.id);
          data = await preloadGameAssets(data);
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
          // Un juego que falla no debe frenar el resto del caché.
        }
      }
    } finally {
      _running = false;
    }
  }
}

final gameCacheServiceProvider = Provider<GameCacheService>((ref) =>
    GameCacheService(
        ref.watch(activityServiceProvider), ref.watch(appDatabaseProvider)));
