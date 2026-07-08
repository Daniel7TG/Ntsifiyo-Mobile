import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_client.dart';
import '../models/models.dart';

/// Mirror de client/src/services/DictionaryService.js (lectura).
class DictionaryService {
  final ApiClient _api;
  DictionaryService(this._api);

  /// GET /api/dictionary/words/categories
  Future<List<String>> getCategories() async {
    final response = await _api.get('/api/dictionary/words/categories');
    final map = response as Map<String, dynamic>;
    return ((map['categories'] ?? []) as List).cast<String>();
  }

  /// GET /api/dictionary/words/all
  Future<List<Word>> getAllWords() async {
    final response = await _api.get('/api/dictionary/words/all');
    final list = response is List
        ? response
        : ((response as Map<String, dynamic>)['words'] ?? []) as List;
    return list.whereType<Map<String, dynamic>>().map(Word.fromJson).toList();
  }

  /// GET /api/dictionary/words/{category}?page=#
  Future<List<Word>> getWordsByCategory(String category,
      {int page = 0}) async {
    final response = await _api
        .get('/api/dictionary/words/${Uri.encodeComponent(category)}?page=$page');
    final list = response is List
        ? response
        : ((response as Map<String, dynamic>)['words'] ?? []) as List;
    return list.whereType<Map<String, dynamic>>().map(Word.fromJson).toList();
  }
}

/// Mirror de client/src/services/MediaService.js (lectura).
class MediaService {
  final ApiClient _api;
  MediaService(this._api);

  /// GET /api/media?type=&page=0&size=50
  Future<List<MediaItem>> getMediaByType(String type) async {
    final response = await _api.get('/api/media?type=$type&page=0&size=50');
    final list = response is List
        ? response
        : ((response as Map<String, dynamic>)['content'] ?? []) as List;
    return list
        .whereType<Map<String, dynamic>>()
        .map(MediaItem.fromJson)
        .toList();
  }

  /// GET /api/media/{id}/stream
  Future<StreamResources> getMediaStream(int mediaId) async {
    final response = await _api.get('/api/media/$mediaId/stream');
    return StreamResources.fromJson(response as Map<String, dynamic>);
  }
}

/// Mirror de client/src/services/UserService.js — sesión de uso.
class UserSessionService {
  final ApiClient _api;
  UserSessionService(this._api);

  Future<void> startSession() async {
    try {
      await _api.post('/api/user/session/start');
    } catch (_) {
      // No bloquear la app si falla el registro de sesión.
    }
  }

  Future<void> endSession() async {
    try {
      await _api.put('/api/user/session/end');
    } catch (_) {}
  }
}

final dictionaryServiceProvider = Provider<DictionaryService>(
    (ref) => DictionaryService(ref.watch(apiClientProvider)));

final mediaServiceProvider =
    Provider<MediaService>((ref) => MediaService(ref.watch(apiClientProvider)));

final userSessionServiceProvider = Provider<UserSessionService>(
    (ref) => UserSessionService(ref.watch(apiClientProvider)));
