/// Clave de caché estable para media descargada, separada de [MediaStore]
/// (que la usa) y de `app_database.dart` (que la reusa en la migración del
/// esquema 8→9) para no crear un import circular entre ambos.
///
/// El backend genera cada URL de media con un PAR (Pre-Authenticated
/// Request) de OCI Object Storage **nuevo en cada respuesta**
/// (`OciService.generarUrlPrivadaParaBucket()`: el `name` del PAR lleva
/// `System.currentTimeMillis()` y expira en 1 hora), con forma
/// `.../p/<TOKEN>/n/<namespace>/b/<bucket>/o/<objeto>`. Cachear por URL
/// completa convierte cada respuesta en un miss: mismo objeto, token
/// distinto, archivo descargado otra vez y duplicado en disco — la causa
/// real de "se descarga todo de nuevo al abrir la app".
///
/// [mediaCacheKey] quita el segmento `/p/<token>` y deja el resto (que sí es
/// estable: namespace, bucket y nombre de objeto) como clave de caché. Una
/// URL que no siga ese patrón (bundle, otro backend) se devuelve intacta.
final _ociParSegment = RegExp(r'/p/[^/]+/n/');

String mediaCacheKey(String url) {
  final match = _ociParSegment.firstMatch(url);
  if (match == null) return url;
  return url.replaceRange(match.start, match.end, '/n/');
}
