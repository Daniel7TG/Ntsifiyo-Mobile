import '../../core/ai/validador_service.dart';
import '../../data/models/models.dart';

/// Mismo vocabulario para la práctica libre y el reto diario.
bool isPracticeWord(Word word, Set<String> centroids) {
  final sp = normalizePronunciationKey(word.spanishWord);
  final mz = normalizePronunciationKey(word.mazahuaWord);
  return centroids.contains(sp) ||
      centroids.contains(mz) ||
      (sp.endsWith('s') && centroids.contains(sp.substring(0, sp.length - 1)));
}
