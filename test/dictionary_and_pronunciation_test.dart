import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jnatrjo_mobile/core/ai/validador_service.dart';
import 'package:jnatrjo_mobile/core/api/api_client.dart';
import 'package:jnatrjo_mobile/core/storage/app_database.dart';
import 'package:jnatrjo_mobile/core/storage/media_store.dart';
import 'package:jnatrjo_mobile/core/storage/session_store.dart';
import 'package:jnatrjo_mobile/data/models/models.dart';
import 'package:jnatrjo_mobile/data/services/misc_services.dart';
import 'package:jnatrjo_mobile/features/dictionary/dictionary_repository.dart';

/// Sustituye las llamadas de red por listas fijas, sin tocar `ApiClient`.
/// Solo se usa en el test de la salvaguarda anti-menguante, que necesita
/// pasar por `fetchRemote()` (y por tanto por `_saveToDb`) de verdad.
class _FakeDictionaryService extends DictionaryService {
  _FakeDictionaryService(super.api, this._categories, this._wordsByCategory);

  final List<String> _categories;
  final Map<String, List<Word>> _wordsByCategory;

  @override
  Future<List<String>> getCategories() async => _categories;

  @override
  Future<List<Word>> getWordsByCategory(String category,
      {int page = 0}) async {
    if (page > 0) return [];
    return _wordsByCategory[category] ?? [];
  }
}

DictionaryService _unusedNetworkService() =>
    DictionaryService(ApiClient(SessionStore(const FlutterSecureStorage())));

/// Lee la lista de palabras de `centroides_y_config.json` tolerando las dos
/// formas que emite `exportar_onnx.py`: el mapa `palabra -> vector` (la que
/// trae el modelo desplegado) y el par de listas `palabras`/`vectores`. Es la
/// misma tolerancia que `ValidadorService.ensureCentroides`; leer solo
/// `['palabras']` reventaba con `Null is not a subtype of List` contra el
/// asset real.
List<String> _palabrasDeCentroides(Map<String, dynamic> config) {
  final centroides = config['centroides'] as Map<String, dynamic>;
  final palabras = centroides['palabras'];
  if (palabras is List) return palabras.cast<String>();
  return centroides.keys.toList();
}

void main() {
  group('normalizePronunciationKey', () {
    test('quita tildes de vocales', () {
      expect(normalizePronunciationKey('gabán'), 'gaban');
      expect(normalizePronunciationKey('Camión'), 'camion');
    });

    test('conserva la ñ (no es una n acentuada)', () {
      expect(normalizePronunciationKey('caña'), 'caña');
      expect(normalizePronunciationKey('año') == normalizePronunciationKey('ano'),
          isFalse);
    });

    test('quita espacios y guiones', () {
      expect(normalizePronunciationKey('zapato huarache'), 'zapatohuarache');
      expect(normalizePronunciationKey('zapato-huarache'), 'zapatohuarache');
    });
  });

  group('coincidencia hub de pronunciación ↔ centroides (datos reales)', () {
    // 36, no 45: además de burro/delantal/lasOrejas (fuera del modelo por
    // corpus) y zapato-huarache (fusionado con zapato), agua/arroz/huevo/
    // laMano/mole/pollito/queso/salsa/zapato se retiraron del manifest en
    // esta sesión por tener la palabra en mazahua mal transcrita — no deben
    // aparecer en ningún lado de la app, ni siquiera como centroide sin
    // palabra que lo alcance (ver el segundo `test` de este grupo).
    test('con acentos normalizados, 36 palabras casan y los únicos '
        'centroides huérfanos son los 9 retirados por transcripción '
        'incorrecta', () {
      final manifest = jsonDecode(
              File('assets/dictionary/manifest.json').readAsStringSync())
          as Map<String, dynamic>;
      final words = (manifest['words'] as List).cast<Map<String, dynamic>>();

      final config = jsonDecode(
              File('assets/modelo/centroides_y_config.json').readAsStringSync())
          as Map<String, dynamic>;
      final centroidWords = _palabrasDeCentroides(config);
      final centroidSet = centroidWords.map(normalizePronunciationKey).toSet();

      bool matches(Map<String, dynamic> word) {
        final sp = normalizePronunciationKey(word['spanishWord'] as String? ?? '');
        final mz = normalizePronunciationKey(word['mazahuaWord'] as String? ?? '');
        if (centroidSet.contains(sp) || centroidSet.contains(mz)) return true;
        if (sp.endsWith('s') && centroidSet.contains(sp.substring(0, sp.length - 1))) {
          return true;
        }
        return false;
      }

      final matched = words.where(matches).toList();
      expect(matched, hasLength(36));

      final matchedKeys = {
        for (final w in matched) normalizePronunciationKey(w['spanishWord'] as String? ?? ''),
        for (final w in matched) normalizePronunciationKey(w['mazahuaWord'] as String? ?? ''),
      };
      final orphanCentroids = centroidSet.where((c) =>
          !matchedKeys.contains(c) && !matchedKeys.contains('${c}s'));

      // El modelo ONNX (assets/modelo/centroides_y_config.json) es un
      // artefacto generado por otro repo (mazahua/config.py); retirar estas
      // 9 palabras del manifest no lo regenera. Mientras eso no pase, sus
      // centroides quedan huérfanos a propósito: sin palabra en el
      // diccionario, el hub de pronunciación no puede ofrecerlas.
      const retiradasPorTranscripcion = {
        'agua', 'arroz', 'huevo', 'lamano', 'mole', 'pollito', 'queso',
        'salsa', 'zapato',
      };
      expect(orphanCentroids.toSet(), retiradasPorTranscripcion,
          reason: 'cualquier huérfano fuera de la lista documentada es un '
              'centroide sin palabra que lo alcance por accidente, no a '
              'propósito');
    });

    test('el bundle no trae palabras retiradas del modelo', () {
      final config = jsonDecode(
              File('assets/modelo/centroides_y_config.json').readAsStringSync())
          as Map<String, dynamic>;
      final centroidWords = _palabrasDeCentroides(config);

      // mazahua/config.py: PALABRAS_EXCLUIDAS + ALIAS_PALABRAS. Un export hecho
      // con exportar_onnx.py antes de ese filtro las reintroducía en silencio.
      for (final retirada in const [
        'burro',
        'delantal',
        'lasOrejas',
        'zapato-huarache',
      ]) {
        expect(centroidWords, isNot(contains(retirada)));
      }
      expect(centroidWords, contains('zapato'));
      expect(centroidWords, hasLength(43));
    });
  });

  group('AppDatabase.replaceCachedWords', () {
    test('deduplica por id en vez de fallar el batch completo', () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      await db.replaceCachedWords([
        CachedWordsCompanion(
          id: const Value(1),
          spanishWord: const Value('primero'),
          mazahuaWord: const Value('mz1'),
          category: const Value('CAT'),
          pronunciation: const Value(false),
          updatedAt: Value(DateTime(2026, 1, 1)),
        ),
        CachedWordsCompanion(
          id: const Value(1),
          spanishWord: const Value('duplicado'),
          mazahuaWord: const Value('mz1b'),
          category: const Value('CAT'),
          pronunciation: const Value(false),
          updatedAt: Value(DateTime(2026, 1, 2)),
        ),
        CachedWordsCompanion(
          id: const Value(2),
          spanishWord: const Value('segundo'),
          mazahuaWord: const Value('mz2'),
          category: const Value('CAT'),
          pronunciation: const Value(false),
          updatedAt: Value(DateTime(2026, 1, 1)),
        ),
      ]);

      final rows = await db.allCachedWords();
      expect(rows, hasLength(2));
      expect(rows.firstWhere((r) => r.id == 1).spanishWord, 'duplicado');
    });
  });

  group('DictionaryRepository', () {
    test('_loadFromDb conserva palabras de una categoría huérfana (no '
        'listada en el KV de categorías)', () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      await db.replaceCachedWords([
        CachedWordsCompanion(
          id: const Value(9001),
          spanishWord: const Value('palabra huerfana'),
          mazahuaWord: const Value('mazahua huerfana'),
          category: const Value(''), // sin categoría real (D2 del diagnóstico)
          pronunciation: const Value(false),
          updatedAt: Value(DateTime.now()),
        ),
      ]);
      // El KV de categorías deliberadamente no incluye la categoría ''.
      await db.kvPut('dictionary_categories', jsonEncode(['ANIMALS']));

      final mediaStore = MediaStore(db);
      final repo = DictionaryRepository(_unusedNetworkService(), db, mediaStore);

      final data = await repo.loadLocal();
      expect(data, isNotNull);
      expect(data!.allWords.any((w) => w.id == 9001), isTrue,
          reason: 'la palabra de la categoría huérfana no debe desaparecer');
    });

    test('fetchRemote descarta una respuesta que trae bastantes menos '
        'palabras que el caché ya guardado, salvo con force: true', () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);
      final mediaStore = MediaStore(db);
      final apiClient = ApiClient(SessionStore(const FlutterSecureStorage()));

      // Categoría de prueba deliberadamente ajena a las del diccionario
      // real, para que la fusión con el bundle no la toque.
      final fullWords = [
        for (var i = 0; i < 10; i++)
          Word(
            id: 5000 + i,
            spanishWord: 'palabra$i',
            mazahuaWord: 'mz$i',
            category: 'TESTCAT',
          ),
      ];

      final fullService =
          _FakeDictionaryService(apiClient, const ['TESTCAT'], {'TESTCAT': fullWords});
      await DictionaryRepository(fullService, db, mediaStore).fetchRemote();
      expect((await db.allCachedWords()).length, 10);

      final shrunkWords = fullWords.take(2).toList();
      final shrunkService = _FakeDictionaryService(
          apiClient, const ['TESTCAT'], {'TESTCAT': shrunkWords});
      final repo2 = DictionaryRepository(shrunkService, db, mediaStore);

      await repo2.fetchRemote(); // sin force: la escritura se descarta
      expect((await db.allCachedWords()).length, 10,
          reason: 'una respuesta menguante no debe reemplazar el caché bueno');

      await repo2.fetchRemote(force: true); // con force: sí reemplaza
      expect((await db.allCachedWords()).length, 2);
    });
  });
}
