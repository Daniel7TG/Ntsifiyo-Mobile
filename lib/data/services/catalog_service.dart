import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_client.dart';
import '../models/models.dart';

/// Mirror del CatalogController del backend (`/api/catalog`).
///
/// Sincronización incremental: en vez de preguntar "¿cambió algo?" y volver
/// a bajar el catálogo entero, devuelve los **ids** de lo que cambió desde
/// `since` junto con el tipo de cambio, para descargar después solo eso.
class CatalogService {
  final ApiClient _api;
  CatalogService(this._api);

  /// GET /api/catalog/updates[?since=...]
  ///
  /// [since] es exclusiva y va **verbatim**: es el `serverTime` que devolvió
  /// la respuesta anterior, no una fecha del dispositivo. Se omite en la
  /// primera sincronización, y entonces el backend devuelve el catálogo
  /// completo en forma de ids (respuesta pequeña, no paginada).
  Future<CatalogUpdates> getUpdates({String? since}) async {
    final query =
        since == null ? '' : '?since=${Uri.encodeQueryComponent(since)}';
    final response = await _api.get('/api/catalog/updates$query');
    return CatalogUpdates.fromJson(response as Map<String, dynamic>);
  }
}

final catalogServiceProvider =
    Provider<CatalogService>((ref) => CatalogService(ref.watch(apiClientProvider)));
