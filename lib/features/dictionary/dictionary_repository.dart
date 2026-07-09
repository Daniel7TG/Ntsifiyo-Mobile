import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../core/api/api_client.dart';
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
/// - `loadLocal()` responde al instante (copia en disco o snapshot del bundle).
/// - `fetchRemote()` descarga todo, guarda en disco y devuelve lo fresco.
/// - Las imágenes/audios empaquetados se usan siempre que la palabra exista
///   en el bundle (carga inmediata y sin red); solo palabras nuevas usan URL.
class DictionaryRepository {
  final DictionaryService _service;

  DictionaryRepository(this._service);

  // Manifest del bundle cacheado en memoria (id → rutas de assets).
  Map<int, ({String? image, String? audio})>? _bundleMedia;
  DictionaryData? _bundleData;

  Future<File> _cacheFile() async {
    final dir = await getApplicationSupportDirectory();
    return File(p.join(dir.path, 'dictionary_cache.json'));
  }

  /// Copia local: disco (última descarga) o bundle (primera vez sin red).
  /// Devuelve null solo si no hay disco ni bundle legible.
  Future<DictionaryData?> loadLocal() async {
    final disk = await _loadFromDisk();
    if (disk != null) return _applyBundleMedia(disk);
    try {
      return await _loadFromBundle();
    } catch (_) {
      return null;
    }
  }

  /// Descarga completa desde el backend y persiste en disco.
  Future<DictionaryData> fetchRemote() async {
    final categories = await _service.getCategories();
    // Las categorías se descargan en paralelo; dentro de cada una las
    // páginas van en secuencia (no se conoce el total por adelantado).
    final results = await Future.wait([
      for (final category in categories) _fetchCategory(category),
    ]);
    final data = _applyBundleMedia(DictionaryData(
      categories: categories,
      wordsByCategory: {
        for (var i = 0; i < categories.length; i++) categories[i]: results[i],
      },
    ));
    await _saveToDisk(data);
    return data;
  }

  Future<List<Word>> _fetchCategory(String category) async {
    final words = <Word>[];
    // Recorrer páginas; el backend responde 404 al pasar la última.
    for (var page = 0; page < 50; page++) {
      try {
        final pageWords =
            await _service.getWordsByCategory(category, page: page);
        if (pageWords.isEmpty) break;
        words.addAll(pageWords);
      } on ApiException catch (e) {
        if (e.status == 404) break;
        rethrow;
      }
    }
    return words;
  }

  /// Sustituye imageUrl/audioUrl por los assets empaquetados cuando la
  /// palabra existe en el bundle: carga instantánea y funciona sin red.
  DictionaryData _applyBundleMedia(DictionaryData data) {
    final media = _bundleMedia;
    if (media == null || media.isEmpty) return data;
    return DictionaryData(
      categories: data.categories,
      fromBundle: data.fromBundle,
      wordsByCategory: {
        for (final e in data.wordsByCategory.entries)
          e.key: [
            for (final w in e.value)
              media.containsKey(w.id)
                  ? w.copyWith(
                      imageUrl: media[w.id]!.image ?? w.imageUrl,
                      audioUrl: media[w.id]!.audio ?? w.audioUrl,
                    )
                  : w
          ],
      },
    );
  }

  Future<void> _saveToDisk(DictionaryData data) async {
    final file = await _cacheFile();
    await file.writeAsString(jsonEncode({
      'categories': data.categories,
      'words': {
        for (final e in data.wordsByCategory.entries)
          e.key: [for (final w in e.value) w.toJson()],
      },
    }));
  }

  Future<DictionaryData?> _loadFromDisk() async {
    try {
      // El manifest debe estar en memoria antes de aplicar overlay.
      await _ensureBundleLoaded();
      final file = await _cacheFile();
      if (!file.existsSync()) return null;
      final json =
          jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      final data = DictionaryData(
        categories: ((json['categories'] ?? []) as List).cast<String>(),
        wordsByCategory: {
          for (final e in ((json['words'] ?? {}) as Map<String, dynamic>).entries)
            e.key: [
              for (final w in (e.value as List).whereType<Map<String, dynamic>>())
                Word.fromJson(w)
            ],
        },
      );
      if (data.categories.isEmpty) return null;
      return data;
    } catch (_) {
      return null;
    }
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
        if (id != null) media[id] = (image: image, audio: audio);
      }
      final categories = ((json['categories'] ?? []) as List).cast<String>();
      _bundleMedia = media;
      _bundleData = DictionaryData(
        categories: categories,
        wordsByCategory: {
          for (final c in categories)
            c: words.where((w) => w.category == c).toList(),
        },
        fromBundle: true,
      );
    } catch (_) {
      _bundleMedia = const {};
    }
  }

  String? _assetPath(String? relative) {
    if (relative == null || relative.isEmpty) return null;
    return 'assets/dictionary/$relative';
  }
}

final dictionaryRepositoryProvider = Provider<DictionaryRepository>(
    (ref) => DictionaryRepository(ref.watch(dictionaryServiceProvider)));

/// Estado del diccionario: emite la copia local al instante y luego se
/// actualiza solo cuando la descarga de fondo termina.
class DictionaryController extends AsyncNotifier<DictionaryData> {
  @override
  Future<DictionaryData> build() async {
    final repo = ref.watch(dictionaryRepositoryProvider);
    final local = await repo.loadLocal();
    if (local != null) {
      _refreshInBackground(repo);
      return local;
    }
    // Sin copia local (ni bundle): única opción es la red.
    return repo.fetchRemote();
  }

  void _refreshInBackground(DictionaryRepository repo) {
    Future(() async {
      try {
        final fresh = await repo.fetchRemote();
        state = AsyncData(fresh);
      } catch (_) {
        // Sin red: se conserva la copia local ya emitida.
      }
    });
  }

  /// Refresco manual (botón actualizar): fuerza red con la copia local
  /// como respaldo si falla.
  Future<void> refresh() async {
    final repo = ref.read(dictionaryRepositoryProvider);
    state = const AsyncLoading();
    try {
      state = AsyncData(await repo.fetchRemote());
    } catch (e, st) {
      final local = await repo.loadLocal();
      state = local != null ? AsyncData(local) : AsyncError(e, st);
    }
  }
}

final dictionaryProvider =
    AsyncNotifierProvider<DictionaryController, DictionaryData>(
        DictionaryController.new);
