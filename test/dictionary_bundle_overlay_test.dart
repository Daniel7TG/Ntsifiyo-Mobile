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

/// Separado de dictionary_and_pronunciation_test.dart a propósito: este
/// archivo SÍ necesita `rootBundle.loadString` (manifest empaquetado) y por
/// tanto inicializa el binding de test; el otro archivo usa `test()` puro
/// deliberadamente, y su salvaguarda anti-menguante asume que el merge del
/// bundle no ocurre (bundle no cargado sin binding) para poder fijar
/// conteos exactos. Inicializar el binding ahí rompería esos conteos.
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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('fetchRemote aplica la media del bundle por nombre cuando el '
      'backend reasignó el id de una palabra ya empaquetada (D del '
      'diagnóstico: ids de backend distintos a los del manifest)',
      () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final mediaStore = MediaStore(db);
    final apiClient = ApiClient(SessionStore(const FlutterSecureStorage()));

    // 'abeja' vive en el bundle con id=5 (assets/dictionary/manifest.json).
    // El backend la devuelve con un id completamente distinto y sin media
    // propia: solo el nombre coincide.
    final reassigned = [
      const Word(
        id: 999999,
        spanishWord: 'abeja',
        mazahuaWord: 'ngunu',
        category: 'ANIMALS',
      ),
    ];
    final service = _FakeDictionaryService(
        apiClient, const ['ANIMALS'], {'ANIMALS': reassigned});
    final repo = DictionaryRepository(service, db, mediaStore);

    final data = await repo.fetchRemote();
    final abeja = data.allWords.firstWhere((w) => w.id == 999999);
    expect(abeja.imageUrl, 'assets/dictionary/img/5.webp',
        reason: 'debe heredar la media del bundle por nombre, no '
            'quedarse sin imagen solo porque el id ya no casa');
    expect(abeja.audioUrl, 'assets/dictionary/audio/5.mp3');
  });
}
