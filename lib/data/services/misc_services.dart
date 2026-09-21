import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_client.dart';
import '../models/models.dart';

/// Mirror de client/src/services/DictionaryService.js (lectura y actualización de media/pronunciación).
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

  /// PUT /api/dictionary/word/{id}/media
  Future<void> updateWordPronunciation(int wordId, bool pronunciation) async {
    try {
      final formData = FormData.fromMap({
        'pronunciation': pronunciation,
      });
      await _api.put('/api/dictionary/word/$wordId/media', formData);
    } catch (_) {
      // Ignorar errores de red en segundo plano
    }
  }

  // Nota: `GET /api/dictionary/words/details/{id}` (alias de `words/media`)
  // NO sirve para traer una palabra por id — su `WordMediaResponseDTO` solo
  // lleva `id`/`urlImage`/`urlAudio`. La palabra completa vive en
  // `words/full`, ver [getFullWords].

  /// GET /api/dictionary/words/full?ids=a,b,c — palabra completa (texto en
  /// ambos idiomas, categoría, media) para uno o más ids, en una sola
  /// llamada. Es lo que [DictionaryRepository.applyWordDelta] usa para
  /// bajar solo las palabras `CREATED`/`UPDATED` que reporta
  /// `GET /api/catalog/updates`, en vez de redescargar toda su categoría.
  ///
  /// Troceado en lotes de [_fullWordsBatchSize]: el backend no publica un
  /// límite documentado para `ids`, y el delta de una sincronización que
  /// llevara mucho tiempo sin correr podría acumular cientos.
  static const _fullWordsBatchSize = 50;

  Future<List<Word>> getFullWords(Iterable<int> ids) async {
    final idList = ids.toList();
    if (idList.isEmpty) return const [];
    final words = <Word>[];
    for (var i = 0; i < idList.length; i += _fullWordsBatchSize) {
      final batch = idList.skip(i).take(_fullWordsBatchSize);
      final response = await _api
          .get('/api/dictionary/words/full?ids=${batch.join(',')}');
      final list = response is List
          ? response
          : ((response as Map<String, dynamic>)['words'] ?? []) as List;
      words.addAll(
          list.whereType<Map<String, dynamic>>().map(Word.fromJson));
    }
    return words;
  }
}

/// Tamaño de página fijo del backend para `GET /api/media` — espejo de
/// `MediaService.PAGE_SIZE` (`MediaService.java`, backend). El backend
/// ignora cualquier `size` que se le mande y nunca informa `totalPages`;
/// la única señal de "última página" es que vuelva con menos de este
/// número de elementos.
const mediaPageSize = 10;

/// Extrae la lista de media de la respuesta de `GET /api/media`.
///
/// El backend responde `PlayMediaListMediaDTO`, es decir
/// `{"mediaList": [...]}` (`PlayMediaListMediaDTO.java`), NO `{"content": [...]}`
/// ni `{"media": [...]}` — ambas formas están mal documentadas en
/// `API_Documentation.md`. Leer `content` aquí hacía que el panel de
/// Contenido saliera vacío siempre, sin importar cuánta media hubiera en
/// el backend: este es el bug real que dejaba `ContentScreen` en su
/// `EmptyState` de forma permanente.
///
/// Se aceptan `content`/`media` solo por tolerancia extra (mismo espíritu
/// que el resto de parsers de este archivo), nunca como el camino
/// principal.
List<MediaItem> parseMediaList(dynamic response) {
  final list = response is List
      ? response
      : ((response as Map<String, dynamic>)['mediaList'] ??
          response['content'] ??
          response['media'] ??
          []) as List;
  return list
      .whereType<Map<String, dynamic>>()
      .map(MediaItem.fromJson)
      .toList();
}

/// Mirror de client/src/services/MediaService.js (lectura).
class MediaService {
  final ApiClient _api;
  MediaService(this._api);

  /// GET /api/media?type=&page={page}
  ///
  /// El backend fija `PAGE_SIZE = 10` (ver [mediaPageSize]) e ignora
  /// cualquier `size` en la query, así que ya no se manda.
  Future<List<MediaItem>> getMediaByType(String type, {int page = 0}) async {
    final response = await _api.get('/api/media?type=$type&page=$page');
    return parseMediaList(response);
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
