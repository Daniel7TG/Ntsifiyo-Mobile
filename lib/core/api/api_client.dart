import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/session_store.dart';

/// Backend Spring en Koyeb (mismo de la web, client/src/services/apiConfig.js).
const apiBaseUrl = String.fromEnvironment(
  'API_URL',
  defaultValue: 'https://mild-donella-daniel7g-b3e46241.koyeb.app',
);

/// Error de API con mensaje legible en español (mirror de handleResponse de la web).
class ApiException implements Exception {
  final String message;
  final int? status;
  final Map<String, dynamic>? responseData;

  ApiException(this.message, {this.status, this.responseData});

  @override
  String toString() => message;
}

String _buildErrorMessage(int? status, dynamic data) {
  if (data is! Map<String, dynamic>) {
    return 'Error: ${status ?? 'desconocido'}';
  }

  String message = (data['message'] as String?) ?? 'Error: $status';

  // Errores de validación por campo
  final validationErrors = data['validationErrors'];
  if (validationErrors is Map) {
    message = validationErrors.entries
        .map((e) => '${e.key}: ${e.value}')
        .join('. ');
  }

  // Cuenta bloqueada con tiempo de espera
  if (data['errorCode'] == 'ACCOUNT_LOCKED') {
    final waitTime = data['lockoutTimeMs'] ??
        data['retryAfterMs'] ??
        data['waitTimeMs'] ??
        data['waitTime'];
    if (waitTime is num) {
      final seconds = (waitTime / 1000).ceil();
      message =
          'Cuenta bloqueada por demasiados intentos. Espera $seconds segundos antes de intentar de nuevo.';
    }
  }

  // Normalizar milisegundos crudos en el mensaje a segundos
  final msMatch =
      RegExp(r'(\d{4,})\s*(?:ms|millis|milisegundos?)?', caseSensitive: false)
          .firstMatch(message);
  if (msMatch != null) {
    final ms = int.tryParse(msMatch.group(1)!) ?? 0;
    if (ms >= 1000 && ms < 100000) {
      final seconds = (ms / 1000).ceil();
      message = message.replaceFirst(
        RegExp(r'\d{4,}\s*(?:ms|millis|milisegundos?)?',
            caseSensitive: false),
        '$seconds segundos',
      );
    }
  }

  return message;
}

/// Cliente HTTP central: base URL + Bearer token + manejo de errores.
class ApiClient {
  final Dio dio;

  ApiClient(SessionStore session)
      : dio = Dio(BaseOptions(
          baseUrl: apiBaseUrl,
          connectTimeout: const Duration(seconds: 20),
          receiveTimeout: const Duration(seconds: 40),
          headers: {'Content-Type': 'application/json'},
        )) {
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = session.token;
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
    ));
  }

  Future<dynamic> get(String endpoint) => _request(() => dio.get(endpoint));

  Future<dynamic> post(String endpoint, [Object? body]) =>
      _request(() => dio.post(endpoint, data: body));

  Future<dynamic> put(String endpoint, [Object? body]) =>
      _request(() => dio.put(endpoint, data: body));

  Future<dynamic> patch(String endpoint, [Object? body]) =>
      _request(() => dio.patch(endpoint, data: body));

  Future<dynamic> delete(String endpoint) =>
      _request(() => dio.delete(endpoint));

  Future<dynamic> _request(Future<Response> Function() send) async {
    try {
      final response = await send();
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        final data = e.response!.data;
        throw ApiException(
          _buildErrorMessage(e.response!.statusCode, data),
          status: e.response!.statusCode,
          responseData: data is Map<String, dynamic> ? data : null,
        );
      }
      // Sin respuesta: problema de red
      throw ApiException(
        'No hay conexión con el servidor. Revisa tu internet.',
        status: null,
      );
    }
  }
}

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(ref.watch(sessionStoreProvider));
});
