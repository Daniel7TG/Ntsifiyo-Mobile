import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_client.dart';
import '../models/models.dart';

/// Mirror de client/src/services/ActivityApiService.js
/// (solo endpoints de estudiante/visitante).
class ActivityService {
  final ApiClient _api;
  ActivityService(this._api);

  /// GET /api/games/{id} — metadatos de catálogo de un juego (título, tema,
  /// dificultad, experiencia, total de preguntas). Reutiliza
  /// `GameSummaryDto.fromJson`, que ya tolera tanto los alias de
  /// `GetGamesGameDTO` (listado, hoy sin llamador: solo TEACHER/ADMIN) como
  /// los de `GameDetailsDTO` (este endpoint): ambos usan `gameTopic` y
  /// `gameConfigs`, y los campos que no aparecen aquí (`wordIds`,
  /// `questions`) simplemente se ignoran.
  ///
  /// Es la única fuente de metadata para [GameCacheService.applyGameDelta]:
  /// `GET /api/games/{id}/preview` trae el contenido jugable pero no el
  /// título/tema/dificultad.
  Future<GameSummaryDto> getGameDetails(int gameId) async {
    final response = await _api.get('/api/games/$gameId');
    return GameSummaryDto.fromJson(response as Map<String, dynamic>);
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
    // El backend actual devuelve List<GetGamesGameDTO>; su id es el de
    // la asignación. Conserva el contrato paginado de los consumidores.
    if (response is List) {
      return {'content': response, 'number': 0, 'totalPages': 1,
        'totalElements': response.length, 'first': true, 'last': true};
    }
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

  /// GET /api/games/{gameId}/preview — mismo contenido jugable que
  /// [startGame] pero **sin crear ni iniciar una actividad**: no escribe en
  /// la base del servidor, no registra partida y no da experiencia.
  ///
  /// Es la vía correcta para llenar el caché offline (`GameCacheService`),
  /// donde solo queremos el contenido; [startGame] se reserva para cuando el
  /// usuario va a jugar de verdad y hace falta el `activityId`.
  Future<GameData> getGamePreview(int gameId) async {
    final response = await _api.get('/api/games/$gameId/preview');
    return GameData.fromJson(response as Map<String, dynamic>);
  }
}

final activityServiceProvider = Provider<ActivityService>(
    (ref) => ActivityService(ref.watch(apiClientProvider)));
