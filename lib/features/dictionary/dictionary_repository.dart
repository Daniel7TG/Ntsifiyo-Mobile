import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

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
/// 1. Con conexión: descarga categorías + palabras y guarda copia en disco.
/// 2. Sin conexión: usa la copia en disco.
/// 3. Primera vez sin conexión: usa el snapshot empaquetado en assets.
class DictionaryRepository {
  final DictionaryService _service;

  DictionaryRepository(this._service);

  Future<File> _cacheFile() async {
    final dir = await getApplicationSupportDirectory();
    return File(p.join(dir.path, 'dictionary_cache.json'));
  }

  Future<DictionaryData> load() async {
    try {
      final categories = await _service.getCategories();
      final wordsByCategory = <String, List<Word>>{};
      for (final category in categories) {
        final words = <Word>[];
        // Recorrer páginas hasta que una venga vacía.
        for (var page = 0; page < 50; page++) {
          final pageWords =
              await _service.getWordsByCategory(category, page: page);
          words.addAll(pageWords);
          if (pageWords.isEmpty) break;
        }
        wordsByCategory[category] = words;
      }
      final data = DictionaryData(
          categories: categories, wordsByCategory: wordsByCategory);
      await _saveToDisk(data);
      return data;
    } catch (_) {
      final disk = await _loadFromDisk();
      if (disk != null) return disk;
      return _loadFromBundle();
    }
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
      final file = await _cacheFile();
      if (!file.existsSync()) return null;
      final json =
          jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      return DictionaryData(
        categories: ((json['categories'] ?? []) as List).cast<String>(),
        wordsByCategory: {
          for (final e in ((json['words'] ?? {}) as Map<String, dynamic>).entries)
            e.key: [
              for (final w in (e.value as List).whereType<Map<String, dynamic>>())
                Word.fromJson(w)
            ],
        },
      );
    } catch (_) {
      return null;
    }
  }

  /// Snapshot empaquetado por scripts/export_dictionary.py.
  Future<DictionaryData> _loadFromBundle() async {
    final raw = await rootBundle.loadString('assets/dictionary/manifest.json');
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final words = ((json['words'] ?? []) as List)
        .whereType<Map<String, dynamic>>()
        .map((w) {
      final word = Word.fromJson(w);
      // Las rutas del manifest son relativas al bundle.
      return word.copyWith(
        imageUrl: _assetPath(w['image'] as String?) ?? word.imageUrl,
        audioUrl: _assetPath(w['audio'] as String?) ?? word.audioUrl,
      );
    }).toList();

    final categories = ((json['categories'] ?? []) as List).cast<String>();
    final byCategory = <String, List<Word>>{
      for (final c in categories)
        c: words.where((w) => w.category == c).toList(),
    };
    return DictionaryData(
        categories: categories,
        wordsByCategory: byCategory,
        fromBundle: true);
  }

  String? _assetPath(String? relative) {
    if (relative == null || relative.isEmpty) return null;
    return 'assets/dictionary/$relative';
  }
}

final dictionaryRepositoryProvider = Provider<DictionaryRepository>(
    (ref) => DictionaryRepository(ref.watch(dictionaryServiceProvider)));

final dictionaryProvider = FutureProvider<DictionaryData>(
    (ref) => ref.watch(dictionaryRepositoryProvider).load());
