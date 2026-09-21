import 'dart:io';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'app_database.dart';
import 'media_cache_key.dart';

/// Carpeta (relativa a ApplicationSupportDirectory) donde se guardan los
/// binarios descargados de juegos y diccionario.
const _mediaDirName = 'game_media';

/// Descarga y resuelve binarios remotos (imágenes/audio), respaldado por la
/// tabla `CachedMedia`. A diferencia del preloader original, nunca destruye
/// la URL remota: si el archivo local desaparece (borrado por el sistema,
/// contenedor de datos recreado en iOS…), `resolve` recupera el recurso
/// sirviendo de nuevo la URL en vez de dejar un ícono roto permanente.
class MediaStore {
  final AppDatabase _db;
  final Dio _dio;

  MediaStore(this._db)
      : _dio = Dio(BaseOptions(
          connectTimeout: const Duration(seconds: 20),
          receiveTimeout: const Duration(seconds: 60),
        ));

  // El directorio de soporte no cambia durante la vida del proceso; cada
  // resolve()/localize() lo pedía de nuevo (I/O evitable, cientos de veces
  // por carga del diccionario).
  Future<Directory>? _supportDir;
  Future<Directory> _dir() => _supportDir ??= getApplicationSupportDirectory();

  /// Descarga [url] si hace falta y devuelve la ruta RELATIVA (p.ej.
  /// 'game_media/3f2a1b9c.webp') para guardar en el contenido serializado.
  /// Devuelve `null` si la descarga falla; el llamador decide si conservar
  /// la URL remota o marcar el contenido como incompleto.
  Future<String?> localize(String? url, String kind) async {
    if (url == null || url.isEmpty) return url;
    if (url.startsWith('img/') || url.startsWith('audio/')) {
      return 'assets/dictionary/$url';
    }
    if (!url.startsWith('http')) return url;

    final dir = await _dir();
    final mediaDir = Directory(p.join(dir.path, _mediaDirName));
    if (!mediaDir.existsSync()) mediaDir.createSync(recursive: true);

    // Clave estable (sin el token PAR rotativo): ver [mediaCacheKey].
    final key = mediaCacheKey(url);
    final existing = await _db.cachedMediaByUrl(key);
    if (existing != null) {
      final file = File(p.join(dir.path, existing.relativePath));
      if (file.existsSync() && file.lengthSync() > 0) {
        return existing.relativePath;
      }
    }

    final name =
        '${_fnv1a64(key).toRadixString(16)}${p.extension(Uri.parse(url).path)}';
    final relativePath = p.join(_mediaDirName, name);
    final file = File(p.join(dir.path, relativePath));

    if (!file.existsSync() || file.lengthSync() == 0) {
      try {
        await _dio.download(url, file.path);
      } catch (_) {
        return null;
      }
      if (!file.existsSync() || file.lengthSync() == 0) return null;
    }

    await _db.upsertCachedMedia(CachedMediaCompanion(
      url: Value(key),
      // La URL absoluta con el token vigente, por si el archivo local
      // desaparece antes de la próxima descarga (ver [resolve]).
      sourceUrl: Value(url),
      relativePath: Value(relativePath),
      byteSize: Value(file.lengthSync()),
      kind: Value(kind),
      downloadedAt: Value(DateTime.now()),
    ));
    return relativePath;
  }

  /// Convierte lo guardado (ruta de asset, URL remota, o ruta de disco) en
  /// lo que el widget debe consumir. Verifica que el archivo exista; si no,
  /// intenta recuperar la URL original desde `CachedMedia` en vez de dejar
  /// una ruta rota. Tolera rutas absolutas heredadas de antes de la
  /// migración a rutas relativas.
  Future<String?> resolve(String? stored) async {
    if (stored == null || stored.isEmpty) return stored;
    if (stored.startsWith('http') || stored.startsWith('assets/')) {
      return stored;
    }
    if (stored.startsWith('img/') || stored.startsWith('audio/')) {
      return 'assets/dictionary/$stored';
    }

    final dir = await _dir();
    final relativePath = _relativeSuffix(stored) ??
        (p.isAbsolute(stored) ? p.relative(stored, from: dir.path) : stored);
    final absolutePath = p.join(dir.path, relativePath);
    final file = File(absolutePath);
    if (file.existsSync() && file.lengthSync() > 0) return absolutePath;

    final row = await _db.cachedMediaByPath(relativePath);
    // `sourceUrl` es la URL absoluta con el token PAR más reciente que se
    // vio para este objeto; `url` (la clave sin token) ya no sirve para
    // pedirle nada al backend. Con un `sourceUrl` viejo el peor caso es un
    // PAR expirado (dura 1h) — se resolverá solo en la próxima
    // sincronización, que vuelve a pasar por [localize].
    return row?.sourceUrl ?? row?.url ?? stored;
  }

  /// Borra de disco los archivos sin fila en `CachedMedia` y las filas cuyo
  /// archivo ya no existe. Disponible para una futura pantalla de "liberar
  /// espacio"; nadie lo invoca automáticamente todavía.
  Future<void> sweep() async {
    final dir = await _dir();
    final mediaDir = Directory(p.join(dir.path, _mediaDirName));
    final rows = await _db.allCachedMedia();
    final knownPaths = {
      for (final row in rows) p.join(dir.path, row.relativePath),
    };

    if (mediaDir.existsSync()) {
      for (final entity in mediaDir.listSync()) {
        if (entity is File && !knownPaths.contains(entity.path)) {
          entity.deleteSync();
        }
      }
    }

    for (final row in rows) {
      final file = File(p.join(dir.path, row.relativePath));
      if (!file.existsSync()) {
        await _db.deleteCachedMediaByUrl(row.url);
      }
    }
  }

  /// Extrae el sufijo 'game_media/archivo.ext' de una ruta absoluta,
  /// independientemente de qué directorio de datos la precediera. Es lo que
  /// permite recuperar rutas absolutas guardadas antes de la migración a
  /// rutas relativas, incluso si el directorio base cambió (p.ej. tras
  /// reinstalar en iOS).
  String? _relativeSuffix(String absolutePath) {
    final marker = '$_mediaDirName/';
    final normalized = absolutePath.replaceAll('\\', '/');
    final idx = normalized.indexOf(marker);
    if (idx == -1) return null;
    return normalized.substring(idx);
  }
}

/// FNV-1a de 64 bits: determinista y estable entre plataformas/builds, a
/// diferencia de `String.hashCode` (32 bits, sin garantía de estabilidad).
int _fnv1a64(String input) {
  const prime = 0x100000001b3;
  var hash = 0xcbf29ce484222325;
  for (final byte in input.codeUnits) {
    hash ^= byte;
    hash = (hash * prime) & 0xFFFFFFFFFFFFFFFF;
  }
  return hash;
}

final mediaStoreProvider =
    Provider<MediaStore>((ref) => MediaStore(ref.watch(appDatabaseProvider)));
