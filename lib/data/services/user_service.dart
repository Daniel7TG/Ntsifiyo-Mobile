import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_client.dart';

/// Mirror de client/src/services/UserService.js (avatar y leaderboard).
class UserService {
  final ApiClient _api;
  UserService(this._api);

  /// GET /api/user/avatar
  Future<int> getAvatar() async {
    final response = await _api.get('/api/user/avatar');
    if (response is Map<String, dynamic>) {
      return (response['avatarId'] as num?)?.toInt() ?? 0;
    }
    return (response as num?)?.toInt() ?? 0;
  }

  /// PUT /api/user/avatar
  Future<int> updateAvatar(int avatarId) async {
    final response = await _api.put(
      '/api/user/avatar',
      {'avatarId': avatarId},
    );
    if (response is Map<String, dynamic>) {
      return (response['avatarId'] as num?)?.toInt() ?? avatarId;
    }
    return avatarId;
  }

  /// GET /api/leaderboard — tabla paginada.
  Future<Map<String, dynamic>> getLeaderboard({
    int page = 0,
    int size = 20,
    String? userType,
  }) async {
    var url = '/api/leaderboard?page=$page&size=$size';
    if (userType != null && userType.isNotEmpty) {
      url += '&userType=$userType';
    }
    final response = await _api.get(url);
    if (response is Map<String, dynamic>) {
      return response;
    }
    if (response is List) {
      return {
        'content': response,
        'totalPages': 1,
        'number': page,
        'first': page == 0,
        'last': true,
      };
    }
    return {'content': [], 'totalPages': 0, 'number': page};
  }
}

final userServiceProvider = Provider<UserService>(
  (ref) => UserService(ref.watch(apiClientProvider)),
);
