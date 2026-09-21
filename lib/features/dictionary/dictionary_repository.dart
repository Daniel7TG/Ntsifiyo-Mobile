import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../core/api/api_client.dart';
import '../../core/storage/app_database.dart';
import '../../core/storage/media_store.dart';
import '../../data/models/models.dart';
import '../../data/services/misc_services.dart';

class DictionaryData {
  final List<String> categories;
  final Map<String, List<Word>> wordsByCategory;
  final bool fromBundle;

  const DictionaryData({
    required this.categories,
    required this.wordsByCategory,
    this.fromBundle = false,
  });

  List<Word> get allWords =>
      [for (final words in wordsByCategory.values) ...words];
}

/// Diccionario offline-first:
/// - `loadLocal()` responde al instante (copia en drift o snapshot del bundle).
/// - `fetchRemote()` descarga todo, guarda en drift y devuelve lo fresco.
/// - Las imágenes/audios empaquetados se usan siempre que la palabra exista
///   en el bundle (carga inmediata y sin red); las palabras nuevas se
///   descargan a disco vía [MediaStore] para que también funcionen offline.
class DictionaryRepository {
  final DictionaryService _service;
  final AppDatabase _db;
  final MediaStore _mediaStore;

  DictionaryRepository(this._service, this._db, this._mediaStore);

  static const _categoriesKey = 'dictionary_categories';

  // Manifest del bundle cacheado en memoria (id → rutas de assets).
  Map<int, ({String? image, String? audio})>? _bundleMedia;
  // Mismo overlay indexado por nombre normalizado: red de seguridad para
  // cuando el backend reasigna ids y el casado por id deja de servir.
  Map<String, ({String? image, String? audio})>? _bundleMediaByName;
  DictionaryData? _bundleData;
  DateTime? _bundleGeneratedAt;

  /// Fecha en que se generó el snapshot empaquetado (`generatedAt` del
  /// manifest). Es la línea base de frescura del diccionario instalado: no
  /// tiene sentido volver a descargarlo si el backend no ha registrado
  /// ningún cambio posterior a esta fecha.
  Future<DateTime?> bundleGeneratedAt() async {
    try {
      await _ensureBundleLoaded();
    } catch (_) {}
    return _bundleGeneratedAt;
  }

  /// Copia local: drift (última descarga) o bundle (primera vez sin red).
  /// Devuelve null solo si no hay nada en drift ni bundle legible.
  Future<DictionaryData?> loadLocal() async {
    final local = await _loadFromDb();
    if (local != null) return _applyBundleMedia(local);
    try {
      return await _loadFromBundle();
    } catch (_) {
      return null;
    }
  }

  /// Descarga completa desde el backend y persiste en drift.
  ///
  /// [force] omite la salvaguarda anti-menguante de [_saveToDb]: solo debe
  /// usarse cuando el usuario pide explícitamente actualizar (`refresh()`),
  /// para que un borrado real en el backend sí se propague.
  Future<DictionaryData> fetchRemote({bool force = false}) async {
    // El manifest debe estar en memoria antes de aplicar overlay; a
    // diferencia de loadLocal(), fetchRemote() no pasaba por aquí y se
    // arriesgaba a fusionar sin las palabras propias del bundle.
    try {
      await _ensureBundleLoaded();
    } catch (_) {}

    final categories = await _service.getCategories();
    // Las categorías se descargan en paralelo; dentro de cada una las
    // páginas van en secuencia (no se conoce el total por adelantado).
    final results = await Future.wait([
      for (final category in categories) _fetchCategory(category),
    ]);
    var data = _applyBundleMedia(DictionaryData(
      categories: categories,
      wordsByCategory: {
        for (var i = 0; i < categories.length; i++) categories[i]: results[i],
      },
    ));
    // Palabras fuera del bundle: descargar su media a disco para que
    // también funcionen sin red (antes solo la imagen se cacheaba vía
    // CachedNetworkImage; el audio se perdía por streaming puro).
    data = await _localizeNewWordsMedia(data);
    // data.categories, no la `categories` cruda del backend: _applyBundleMedia
    // la extendió con las categorías que solo existen en el bundle, y esas
    // deben persistir en el KV o se pierden en el siguiente arranque.
    await _saveToDb(data, data.categories, force: force);
    return data;
  }

  /// Aplica el delta de `GET /api/catalog/updates` (ver
  /// `ResourceUpdateService`) sin redescargar el diccionario entero.
  ///
  /// [upsertIds] (CREATED/UPDATED) se bajan de una sola vez con
  /// `GET /api/dictionary/words/full?ids=...` ([DictionaryService.getFullWords]):
  /// a diferencia de `GET /api/dictionary/words/details/{id}` (que solo
  /// devuelve media, `WordMediaResponseDTO`), `words/full` sí trae la
  /// palabra completa por id — texto en ambos idiomas, categoría y media —
  /// así que el delta ya no necesita deducir la categoría del propio caché
  /// ni bajar una categoría entera por cada palabra cambiada.
  ///
  /// [_applyWordDeltaByCategory] queda como red de seguridad para un backend
  /// desplegado antes de que existiera `words/full` (403/404): ahí sí hace
  /// falta resolver por categoría, porque ningún otro endpoint da la palabra
  /// completa por id.
  ///
  /// [deletedIds] se borran del caché sin tocar el resto de la tabla. La
  /// salvaguarda anti-menguante de [_saveToDb] no interviene ahí, y es
  /// correcto: esa protege contra una *lista completa* corta o vacía, que es
  /// indistinguible de un fallo del backend; un id marcado `DELETED` es lo
  /// contrario, una afirmación puntual sobre esa palabra concreta.
  ///
  /// Devuelve true solo si **todo** se aplicó bien, para que quien llame no
  /// avance el cursor de sincronización si algo quedó a medias.
  Future<bool> applyWordDelta({
    Set<int> upsertIds = const {},
    Set<int> deletedIds = const {},
  }) async {
    // Los borrados no gastan red: el backend ya dijo qué id desapareció.
    if (deletedIds.isNotEmpty) {
      try {
        await _db.applyCachedWordDelta(deletedIds: deletedIds);
      } catch (_) {
        return false;
      }
    }
    if (upsertIds.isEmpty) return true;

    // El manifest debe estar en memoria antes del overlay de media, igual
    // que en fetchRemote().
    try {
      await _ensureBundleLoaded();
    } catch (_) {}

    try {
      final words = await _service.getFullWords(upsertIds);
      if (words.length < upsertIds.length) {
        // El backend no encontró alguno de los ids (raro: cambió justo
        // entre el `/updates` y esta llamada) — se completa por el camino
        // viejo antes que dejarlo a medias.
        return await _applyWordDeltaByCategory(upsertIds);
      }
      await _persistWordUpserts(words);
      return true;
    } on ApiException catch (e) {
      // Backend sin `words/full` desplegado todavía: red de seguridad, no
      // ruta normal.
      if (e.status == 403 || e.status == 404) {
        return await _applyWordDeltaByCategory(upsertIds);
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Camino de respaldo para un backend sin `GET /api/dictionary/words/full`
  /// (ver [applyWordDelta]): sin él, ningún endpoint devuelve una palabra
  /// completa por id, así que el delta se resuelve al nivel más fino que
  /// queda — la categoría completa, deducida del propio caché.
  Future<bool> _applyWordDeltaByCategory(Set<int> upsertIds) async {
    // La categoría de cada id cambiado se deduce del propio caché. Una
    // palabra nueva (CREATED) todavía no está ahí y el delta no trae su
    // tema, así que no hay a qué categoría pedirla: toca refresco completo.
    final cachedCategory = {
      for (final w in await _db.allCachedWords()) w.id: w.category,
    };
    final categories = <String>{};
    var needsFullRefresh = false;
    for (final id in upsertIds) {
      final category = cachedCategory[id];
      if (category == null || category.isEmpty) {
        needsFullRefresh = true;
        break;
      }
      categories.add(category);
    }

    if (!needsFullRefresh) {
      try {
        final found = <Word>[];
        for (final category in categories) {
          for (final w in await _fetchCategory(category)) {
            if (w.id != null && upsertIds.contains(w.id)) found.add(w);
          }
        }
        // Si falta alguna, es que cambió de categoría: la que teníamos
        // cacheada era la vieja y no aparece donde la buscamos. Refresco
        // completo antes que dejarla desactualizada en silencio.
        needsFullRefresh = found.length < upsertIds.length;
        if (!needsFullRefresh) {
          await _persistWordUpserts(found);
          return true;
        }
      } catch (_) {
        return false;
      }
    }

    try {
      // Camino de lista completa, con su salvaguarda anti-menguante intacta.
      await fetchRemote();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Persiste un puñado de palabras sin tocar el resto de la tabla, pasando
  /// por el mismo tratamiento de media que [fetchRemote].
  Future<void> _persistWordUpserts(List<Word> words) async {
    // Overlay del bundle palabra a palabra. Deliberadamente NO se usa
    // `_applyBundleMedia`: ese además fusiona el bundle entero en el
    // resultado, lo que en un delta reescribiría las ~146 palabras
    // empaquetadas en cada sincronización.
    final media = _bundleMedia;
    final mediaByName = _bundleMediaByName;
    var withMedia = [
      for (final w in words) _withBundleOverlay(w, media, mediaByName)
    ];
    // Lo que no está en el bundle sigue con URL remota: se baja a disco para
    // que también funcione sin red.
    final byCategory = <String, List<Word>>{};
    for (final w in withMedia) {
      byCategory.putIfAbsent(w.category ?? '', () => []).add(w);
    }
    final localized = await _localizeNewWordsMedia(
        DictionaryData(categories: const [], wordsByCategory: byCategory));
    withMedia = localized.allWords;

    final now = DateTime.now();
    await _db.applyCachedWordDelta(
      upserted: [
        for (final w in withMedia)
          if (w.id != null)
            CachedWordsCompanion(
              id: Value(w.id!),
              spanishWord: Value(w.spanishWord),
              mazahuaWord: Value(w.mazahuaWord),
              spanishPronunciation: Value(w.spanishPronunciation),
              mazahuaPronunciation: Value(w.mazahuaPronunciation),
              category: Value(w.category ?? ''),
              imagePath: Value(w.imageUrl),
              audioPath: Value(w.audioUrl),
              pronunciation: Value(w.pronunciation),
              updatedAt: Value(now),
            ),
      ],
    );
  }

  Future<List<Word>> _fetchCategory(String category) async {
    final words = <Word>[];
    // Recorrer páginas; el backend responde 404 al pasar la última.
    for (var page = 0; page < 50; page++) {
      try {
        final pageWords =
            await _service.getWordsByCategory(category, page: page);
        if (pageWords.isEmpty) break;
        // `GET /api/dictionary/words/{topic}` NO devuelve el tema por palabra
        // (`DictionaryWordPreviewDTO` = id/spanishWord/mazahuaWord/imageUrl/
        // audioUrl/pronunciation): el tema es implícito en qué endpoint se
        // llamó. Se asigna aquí explícitamente, porque `_saveToDb` persiste
        // `w.category` y no la clave del mapa — sin esto, todo lo que viene
        // de la red se guardaba con `category: ''` y el diccionario perdía
        // sus categorías en el primer refresco. Mismo bug que
        // `progress_providers.dart` tuvo con `g.topic`; no lo reintroduzcas.
        words.addAll([
          for (final w in pageWords)
            (w.category == null || w.category!.isEmpty)
                ? w.copyWith(category: category)
                : w,
        ]);
      } on ApiException catch (e) {
        if (e.status == 404) break;
        rethrow;
      }
    }
    return words;
  }

  /// Sustituye imageUrl/audioUrl por los assets empaquetados cuando la
  /// palabra existe en el bundle y fusiona las palabras locales del bundle
  /// que no existan en el backend o en la base de datos local.
  DictionaryData _applyBundleMedia(DictionaryData data) {
    final media = _bundleMedia;
    final mediaByName = _bundleMediaByName;
    final bundle = _bundleData;
    if ((media == null || media.isEmpty) && bundle == null) return data;

    final existingIds = <int>{};
    for (final words in data.wordsByCategory.values) {
      for (final w in words) {
        if (w.id != null) existingIds.add(w.id!);
      }
    }

    // Unión de las tres fuentes de categorías, no solo `data.categories`:
    // `wordsByCategory` puede tener claves huérfanas (p.ej. `''` cuando una
    // palabra llegó sin categoría) que antes se descartaban en silencio al
    // reconstruir el mapa más abajo.
    final categories = <String>[...data.categories];
    for (final c in data.wordsByCategory.keys) {
      if (!categories.contains(c)) categories.add(c);
    }
    if (bundle != null) {
      for (final c in bundle.categories) {
        if (!categories.contains(c)) {
          categories.add(c);
        }
      }
    }

    final wordsByCategory = <String, List<Word>>{};
    for (final c in categories) {
      final existingWords = data.wordsByCategory[c] ?? [];
      final updatedWords = [
        for (final w in existingWords) _withBundleOverlay(w, media, mediaByName)
      ];

      if (bundle != null && bundle.wordsByCategory.containsKey(c)) {
        for (final bw in bundle.wordsByCategory[c]!) {
          if (bw.id != null && !existingIds.contains(bw.id)) {
            updatedWords.add(bw);
            existingIds.add(bw.id!);
          }
        }
      }

      wordsByCategory[c] = updatedWords;
    }

    return DictionaryData(
      categories: categories,
      wordsByCategory: wordsByCategory,
      fromBundle: data.fromBundle,
    );
  }

  /// Aplica la media del bundle a [w]: primero por id (caso normal) y, si no
  /// hay coincidencia, por nombre en español normalizado. El backend puede
  /// reasignar ids (p.ej. migrar a UUID) sin que eso deba tumbar la media ya
  /// empaquetada de una palabra que sigue siendo, en esencia, la misma.
  Word _withBundleOverlay(
    Word w,
    Map<int, ({String? image, String? audio})>? media,
    Map<String, ({String? image, String? audio})>? mediaByName,
  ) {
    final byId = (w.id != null && media != null) ? media[w.id] : null;
    final overlay =
        byId ?? mediaByName?[_normalizeWordName(w.spanishWord)];
    if (overlay == null) return w;
    return w.copyWith(
      imageUrl: overlay.image ?? w.imageUrl,
      audioUrl: overlay.audio ?? w.audioUrl,
    );
  }

  String _normalizeWordName(String s) => s.trim().toLowerCase();

  /// Descarga a disco la media de las palabras que no están en el bundle
  /// (siguen con URL remota tras `_applyBundleMedia`). Las que fallan
  /// conservan su URL: el diccionario nunca fue "todo o nada" y esto no
  /// cambia esa tolerancia.
  Future<DictionaryData> _localizeNewWordsMedia(DictionaryData data) async {
    Future<Word> localizeWord(Word w) async {
      final needsImage = w.imageUrl?.startsWith('http') ?? false;
      final needsAudio = w.audioUrl?.startsWith('http') ?? false;
      if (!needsImage && !needsAudio) return w;
      final image = needsImage
          ? await _mediaStore.localize(w.imageUrl, 'image')
          : w.imageUrl;
      final audio = needsAudio
          ? await _mediaStore.localize(w.audioUrl, 'audio')
          : w.audioUrl;
      return w.copyWith(imageUrl: image, audioUrl: audio);
    }

    return DictionaryData(
      categories: data.categories,
      fromBundle: data.fromBundle,
      wordsByCategory: {
        for (final e in data.wordsByCategory.entries)
          e.key: [for (final w in e.value) await localizeWord(w)],
      },
    );
  }

  /// Persiste [data] en drift. Si [force] es false (el caso normal, refresco
  /// de fondo) y la lista entrante tiene notablemente menos palabras que lo
  /// ya guardado, se descarta la escritura entera: una respuesta a medias
  /// del backend (página vacía a mitad de la paginación, error puntual) no
  /// debe sustituir una copia local buena por una truncada. Una lista vacía
  /// jamás se persiste, ni siquiera con `force: true`: no hay caso de uso
  /// legítimo para vaciar el diccionario entero, así que se trata siempre
  /// como respuesta rota, no como un borrado real del backend.
  Future<void> _saveToDb(
    DictionaryData data,
    List<String> categories, {
    bool force = false,
  }) async {
    final now = DateTime.now();
    final entries = [
      for (final w in data.allWords)
        if (w.id != null)
          CachedWordsCompanion(
            id: Value(w.id!),
            spanishWord: Value(w.spanishWord),
            mazahuaWord: Value(w.mazahuaWord),
            spanishPronunciation: Value(w.spanishPronunciation),
            mazahuaPronunciation: Value(w.mazahuaPronunciation),
            category: Value(w.category ?? ''),
            imagePath: Value(w.imageUrl),
            audioPath: Value(w.audioUrl),
            pronunciation: Value(w.pronunciation),
            updatedAt: Value(now),
          ),
    ];

    if (entries.isEmpty) return;

    if (!force) {
      final currentCount = (await _db.allCachedWords()).length;
      if (currentCount > 0 && entries.length < currentCount * 0.9) {
        return;
      }
    }

    await _db.replaceCachedWords(entries);
    await _db.kvPut(_categoriesKey, jsonEncode(categories));
  }

  /// Carga lo guardado en drift. A diferencia de la versión anterior, cada
  /// paso arriesgado (manifest del bundle, migración legacy, resolver un
  /// medio puntual) tiene su propio try/catch: un fallo aislado ya no tumba
  /// el diccionario entero y lo manda de vuelta a las 257 palabras del
  /// bundle. `null` significa exclusivamente "no hay filas guardadas".
  Future<DictionaryData?> _loadFromDb() async {
    // El manifest debe estar en memoria antes de aplicar overlay.
    try {
      await _ensureBundleLoaded();
    } catch (_) {}
    try {
      await _migrateLegacyDiskCacheIfNeeded();
    } catch (_) {}

    List<CachedWord> rows;
    try {
      rows = await _db.allCachedWords();
    } catch (_) {
      return null;
    }
    if (rows.isEmpty) return null;

    var storedCategories = <String>[];
    try {
      final categoriesJson = await _db.kvGet(_categoriesKey);
      if (categoriesJson != null) {
        storedCategories = (jsonDecode(categoriesJson) as List).cast<String>();
      }
    } catch (_) {
      // KV corrupto: se reconstruye la lista a partir de las filas.
    }
    // Unión con las categorías realmente presentes en las filas: si el KV
    // quedó desalineado (o el backend dejó de listar una categoría) sus
    // palabras no deben desaparecer solo porque su clave no está "oficial".
    final rowCategories = rows.map((r) => r.category).toSet().toList()..sort();
    final categories = <String>[
      ...storedCategories,
      for (final c in rowCategories)
        if (!storedCategories.contains(c)) c,
    ];

    final byCategory = <String, List<Word>>{
      for (final c in categories) c: [],
    };
    for (final row in rows) {
      var imageUrl = row.imagePath;
      var audioUrl = row.audioPath;
      try {
        imageUrl = await _mediaStore.resolve(row.imagePath);
      } catch (_) {
        // Falla resolver este medio puntual: se conserva la ruta cruda en
        // vez de perder la palabra completa (y con ella, todo el diccionario).
      }
      try {
        audioUrl = await _mediaStore.resolve(row.audioPath);
      } catch (_) {}
      final word = Word(
        id: row.id,
        spanishWord: row.spanishWord,
        mazahuaWord: row.mazahuaWord,
        spanishPronunciation: row.spanishPronunciation,
        mazahuaPronunciation: row.mazahuaPronunciation,
        imageUrl: imageUrl,
        audioUrl: audioUrl,
        category: row.category,
        pronunciation: row.pronunciation,
      );
      byCategory.putIfAbsent(row.category, () => []).add(word);
    }
    return DictionaryData(categories: categories, wordsByCategory: byCategory);
  }

  /// Sembrado único desde el JSON suelto de versiones anteriores de la app
  /// (antes de que el diccionario viviera en drift). Solo actúa si la tabla
  /// está vacía, así que corre como mucho una vez por instalación.
  Future<void> _migrateLegacyDiskCacheIfNeeded() async {
    if ((await _db.allCachedWords()).isNotEmpty) return;
    final file = await _legacyCacheFile();
    if (!file.existsSync()) return;
    try {
      final json =
          jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      final categories = ((json['categories'] ?? []) as List).cast<String>();
      final wordsByCategory = <String, List<Word>>{
        for (final e
            in ((json['words'] ?? {}) as Map<String, dynamic>).entries)
          e.key: [
            for (final w
                in (e.value as List).whereType<Map<String, dynamic>>())
              Word.fromJson(w)
          ],
      };
      await _saveToDb(
        DictionaryData(categories: categories, wordsByCategory: wordsByCategory),
        categories,
      );
    } catch (_) {
      // Legacy corrupto: se ignora: el flujo normal cae a bundle/red.
    }
    await file.delete().catchError((_) => file);
  }

  Future<File> _legacyCacheFile() async {
    final dir = await getApplicationSupportDirectory();
    return File(p.join(dir.path, 'dictionary_cache.json'));
  }

  /// Snapshot empaquetado por scripts/export_dictionary.py.
  Future<DictionaryData> _loadFromBundle() async {
    await _ensureBundleLoaded();
    final bundled = _bundleData;
    if (bundled == null) {
      throw StateError('Bundle de diccionario no disponible');
    }
    return bundled;
  }

  Future<void> _ensureBundleLoaded() async {
    if (_bundleMedia != null) return;
    try {
      final raw =
          await rootBundle.loadString('assets/dictionary/manifest.json');
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final media = <int, ({String? image, String? audio})>{};
      final mediaByName = <String, ({String? image, String? audio})>{};
      final words = <Word>[];
      for (final w in ((json['words'] ?? []) as List)
          .whereType<Map<String, dynamic>>()) {
        final image = _assetPath(w['image'] as String?);
        final audio = _assetPath(w['audio'] as String?);
        final word = Word.fromJson(w).copyWith(
          imageUrl: image,
          audioUrl: audio,
        );
        words.add(word);
        final id = word.id;
        final overlay = (image: image, audio: audio);
        if (id != null) media[id] = overlay;
        if (word.spanishWord.isNotEmpty) {
          mediaByName[_normalizeWordName(word.spanishWord)] = overlay;
        }
      }
      final categories = ((json['categories'] ?? []) as List).cast<String>();
      _bundleMedia = media;
      _bundleMediaByName = mediaByName;
      _bundleGeneratedAt = DateTime.tryParse(json['generatedAt'] as String? ?? '');
      _bundleData = DictionaryData(
        categories: categories,
        wordsByCategory: {
          for (final c in categories)
            c: words.where((w) => w.category == c).toList(),
        },
        fromBundle: true,
      );
    } catch (_) {
      // Se deja en null (no un `{}` que cuenta como "ya cargado, vacío")
      // para que la próxima llamada reintente en vez de quedar envenenado
      // el resto de la vida de esta instancia del repositorio.
      _bundleMedia = null;
      _bundleMediaByName = null;
      _bundleGeneratedAt = null;
      _bundleData = null;
    }
  }

  String? _assetPath(String? relative) {
    if (relative == null || relative.isEmpty) return null;
    return 'assets/dictionary/$relative';
  }
}

final dictionaryRepositoryProvider = Provider<DictionaryRepository>((ref) =>
    DictionaryRepository(ref.watch(dictionaryServiceProvider),
        ref.watch(appDatabaseProvider), ref.watch(mediaStoreProvider)));

/// Estado del diccionario: emite la copia local al instante (drift o
/// bundle). El refresco ya no es una descarga completa en cada arranque —
/// lo cubre `ResourceUpdateService.checkAndRefresh()` → [applyWordDelta],
/// disparado una vez desde `AppShell` para los dos catálogos (juegos y
/// diccionario) a la vez.
class DictionaryController extends AsyncNotifier<DictionaryData> {
  @override
  Future<DictionaryData> build() async {
    final repo = ref.watch(dictionaryRepositoryProvider);
    final local = await repo.loadLocal();
    if (local != null) return local;
    // Sin copia local (ni bundle): única opción es la red.
    return repo.fetchRemote();
  }

  /// Refresco manual (botón actualizar): fuerza red con la copia local
  /// como respaldo si falla. A diferencia del refresco de fondo, sí se
  /// permite que la escritura reduzca el número de palabras (`force: true`):
  /// es una acción explícita del usuario y debe poder propagar un borrado
  /// real del backend, no solo protegerse de uno accidental.
  Future<void> refresh() async {
    final repo = ref.read(dictionaryRepositoryProvider);
    state = const AsyncLoading();
    try {
      state = AsyncData(await repo.fetchRemote(force: true));
    } catch (e, st) {
      final local = await repo.loadLocal();
      state = local != null ? AsyncData(local) : AsyncError(e, st);
    }
  }
}

final dictionaryProvider =
    AsyncNotifierProvider<DictionaryController, DictionaryData>(
        DictionaryController.new);
