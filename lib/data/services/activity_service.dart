import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_client.dart';
import '../models/models.dart';

/// Mirror de client/src/services/ActivityApiService.js
/// (solo endpoints de estudiante/visitante).
class ActivityService {
  final ApiClient _api;
  ActivityService(this._api);

  /// GET /api/games — lista completa de juegos (para el caché offline).
  Future<List<GameSummaryDto>> getAllGames() async {
    final response = await _api.get('/api/games');
    return (response as List)
        .whereType<Map<String, dynamic>>()
        .map(GameSummaryDto.fromJson)
        .toList();
  }

  /// GET /api/games/{type}?page=# — actividades por tipo de juego.
  Future<Paged<GameSummaryDto>> getActivitiesByType(String type,
      {int page = 0}) async {
    final response = await _api.get('/api/games/$type?page=$page');
    return Paged.fromJson(
        response as Map<String, dynamic>, GameSummaryDto.fromJson);
  }

  /// GET /api/games/topic/{topic} — juegos por tópico (mapa).
  Future<Paged<GameSummaryDto>> getGamesByTopic(String topic,
      {int page = 0, int size = 0}) async {
    final response =
        await _api.get('/api/games/topic/$topic?page=$page&size=$size');
    return Paged.fromJson(
        response as Map<String, dynamic>, GameSummaryDto.fromJson);
  }

  /// POST /api/activities/start/game/{gameId} — inicia y devuelve contenido.
  Future<GameData> startGame(int gameId) async {
    final response = await _api.post('/api/activities/start/game/$gameId');
    return GameData.fromJson(response as Map<String, dynamic>);
  }

  /// POST /api/activities/start/{activityId} — inicia actividad asignada.
  Future<GameData> startAssignedActivity(int activityId) async {
    final response = await _api.post('/api/activities/start/$activityId');
    return GameData.fromJson(response as Map<String, dynamic>);
  }

  /// GET /api/activities/student?page=# — asignaciones del estudiante.
  Future<Map<String, dynamic>> getStudentActivities({int page = 0}) async {
    final response = await _api.get('/api/activities/student?page=$page');
    return response as Map<String, dynamic>;
  }

  /// POST /api/activities/complete — guarda el resultado y devuelve XP.
  Future<RewardResult> completeActivity({
    required int activityId,
    required String startDate,
    required int correctAnswers,
    required List<ResponseLog> responseLogs,
    required int gameId,
  }) async {
    final response = await _api.post('/api/activities/complete', {
      'activityId': activityId,
      'startDate': startDate,
      'correctAnswers': correctAnswers,
      'responseLogs': responseLogs.map((l) => l.toApiJson()).toList(),
      'gameId': gameId,
    });
    return RewardResult.fromJson(
        response is Map<String, dynamic> ? response : {});
  }

  /// GET /api/dashboard/student
  Future<Map<String, dynamic>> getStudentDashboard() async {
    final response = await _api.get('/api/dashboard/student');
    return response as Map<String, dynamic>;
  }

  /// GET /api/dashboard/visitor
  Future<Map<String, dynamic>> getVisitorDashboard() async {
    final response = await _api.get('/api/dashboard/visitor');
    return response as Map<String, dynamic>;
  }
}

final activityServiceProvider = Provider<ActivityService>(
    (ref) => ActivityService(ref.watch(apiClientProvider)));
