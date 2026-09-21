import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jnatrjo_mobile/core/api/api_client.dart';
import 'package:jnatrjo_mobile/core/storage/app_database.dart';
import 'package:jnatrjo_mobile/core/storage/media_store.dart';
import 'package:jnatrjo_mobile/core/storage/session_store.dart';
import 'package:jnatrjo_mobile/data/models/models.dart';
import 'package:jnatrjo_mobile/data/services/misc_services.dart';
import 'package:jnatrjo_mobile/features/dictionary/dictionary_repository.dart';

/// Anota qué categorías se piden, que es justo lo que el delta debe reducir.
class _FakeDictionaryService extends DictionaryService {
  _FakeDictionaryService(this._wordsByCategory)
      : super(ApiClient(SessionStore(const FlutterSecureStorage())));

  final Map<String, List<Word>> _wordsByCategory;
  final List<String> requested = [];

  @override
  Future<List<String>> getCategories() async => _wordsByCategory.keys.toList();

  @override
  Future<List<Word>> getWordsByCategory(String category,
      {int page = 0}) async {
    if (page == 0) requested.add(category);
    if (page > 0) return [];
    return _wordsByCategory[category] ?? [];
  }
}

Word _word(int id, String es, {String? category}) => Word(
      id: id,
      spanishWord: es,
      mazahuaWord: 'mz-$es',
      category: category,
    );

void main() {
  late AppDatabase db;
  late MediaStore mediaStore;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    mediaStore = MediaStore(db);
  });
  tearDown(() => db.close());

  Future<void> seed(List<(int, String, String)> rows) => db.replaceCachedWords([
        for (final (id, es, cat) in rows)
          CachedWordsCompanion(
            id: Value(id),
            spanishWord: Value(es),
            mazahuaWord: Value('mz-$es'),
            category: Value(cat),
            updatedAt: Value(DateTime(2026, 8, 19)),
          ),
      ]);

  group('DictionaryRepository._fetchCategory', () {
    test('asigna el tema consultado a las palabras que llegan sin él '
        '(el DTO del backend no lo trae; guardarlo en null vaciaba la '
        'categoría de todo el diccionario al refrescar)', () async {
      final service = _FakeDictionaryService({
        'ANIMALS': [_word(1, 'perro'), _word(2, 'gato')],
      });
      final repo = DictionaryRepository(service, db, mediaStore);

      await repo.fetchRemote();

      final rows = await db.allCachedWords();
      expect(rows.map((r) => r.category).toSet(), {'ANIMALS'});
    });

    test('respeta la categoría que sí venga en el payload', () async {
      final service = _FakeDictionaryService({
        'ANIMALS': [_word(1, 'perro', category: 'FRUITS')],
      });
      final repo = DictionaryRepository(service, db, mediaStore);

      await repo.fetchRemote();

      expect((await db.allCachedWords()).single.category, 'FRUITS');
    });
  });

  group('DictionaryRepository.applyWordDelta', () {
    test('un borrado no gasta red y solo quita ese id', () async {
      await seed([(1, 'perro', 'ANIMALS'), (2, 'gato', 'ANIMALS')]);
      final service = _FakeDictionaryService({});
      final repo = DictionaryRepository(service, db, mediaStore);

      expect(await repo.applyWordDelta(deletedIds: {1}), isTrue);

      expect(service.requested, isEmpty);
      expect((await db.allCachedWords()).map((w) => w.id), [2]);
    });

    test('una palabra editada refresca solo su categoría, no las ocho',
        () async {
      await seed([
        (1, 'perro', 'ANIMALS'),
        (2, 'gato', 'ANIMALS'),
        (3, 'rojo', 'COLORS'),
        (4, 'pan', 'FOOD'),
      ]);
      final service = _FakeDictionaryService({
        'ANIMALS': [_word(1, 'perro'), _word(2, 'gato-corregido')],
        'COLORS': [_word(3, 'rojo')],
        'FOOD': [_word(4, 'pan')],
      });
      final repo = DictionaryRepository(service, db, mediaStore);

      expect(await repo.applyWordDelta(upsertIds: {2}), isTrue);

      expect(service.requested, ['ANIMALS']);
      final rows = await db.allCachedWords();
      expect(rows.firstWhere((w) => w.id == 2).spanishWord, 'gato-corregido');
      // Las demás quedan intactas.
      expect(rows.length, 4);
      expect(rows.firstWhere((w) => w.id == 3).spanishWord, 'rojo');
    });

    test('una palabra nueva (categoría desconocida) cae al refresco completo',
        () async {
      await seed([(1, 'perro', 'ANIMALS')]);
      final service = _FakeDictionaryService({
        'ANIMALS': [_word(1, 'perro'), _word(9, 'lobo')],
        'COLORS': [_word(3, 'rojo')],
      });
      final repo = DictionaryRepository(service, db, mediaStore);

      expect(await repo.applyWordDelta(upsertIds: {9}), isTrue);

      // No sabía a qué categoría pedirla: refresca todas.
      expect(service.requested.toSet(), {'ANIMALS', 'COLORS'});
      expect((await db.allCachedWords()).map((w) => w.id).toSet(), {1, 9, 3});
    });

    test('una palabra que cambió de categoría también cae al refresco '
        'completo en vez de quedarse desactualizada', () async {
      await seed([(1, 'perro', 'ANIMALS'), (2, 'gato', 'ANIMALS')]);
      // El id 2 ya no está en ANIMALS: se movió a FOOD.
      final service = _FakeDictionaryService({
        'ANIMALS': [_word(1, 'perro')],
        'FOOD': [_word(2, 'gato')],
      });
      final repo = DictionaryRepository(service, db, mediaStore);

      expect(await repo.applyWordDelta(upsertIds: {2}), isTrue);

      expect(service.requested.where((c) => c == 'FOOD'), isNotEmpty);
      expect((await db.allCachedWords()).firstWhere((w) => w.id == 2).category,
          'FOOD');
    });

    test('delta vacío no toca nada', () async {
      await seed([(1, 'perro', 'ANIMALS')]);
      final service = _FakeDictionaryService({});
      final repo = DictionaryRepository(service, db, mediaStore);

      expect(await repo.applyWordDelta(), isTrue);
      expect(service.requested, isEmpty);
      expect((await db.allCachedWords()).length, 1);
    });
  });
}
