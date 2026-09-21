import 'api_client.dart';

/// Traduce cualquier error capturado por un provider a un mensaje que un
/// niño pueda leer. `ApiException` ya trae un mensaje en español armado por
/// `ApiClient` (incluye "sin conexión", bloqueos de cuenta, etc.) y se usa
/// tal cual; cualquier otro tipo (fallo al parsear JSON, error de SQLite al
/// leer la caché…) se reemplaza por un mensaje genérico en vez de mostrar
/// `e.toString()` crudo en pantalla.
String friendlyErrorMessage(Object error) {
  if (error is ApiException) return error.message;
  return 'Algo salió mal. Inténtalo de nuevo en un momento.';
}
