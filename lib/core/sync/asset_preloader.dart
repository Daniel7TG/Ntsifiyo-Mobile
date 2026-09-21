import '../../data/models/models.dart';
import '../storage/media_store.dart';

bool _wasRemote(String? url) => url != null && url.startsWith('http');

/// Descarga imágenes/audio de un GameData a disco vía [MediaStore] y
/// reescribe las URLs a rutas locales relativas (equivalente persistente
/// del preloadAssets de la web). Si un recurso no puede descargarse,
/// conserva la URL remota y el segundo valor de la tupla vuelve `false`:
/// GameCacheService usa eso para reintentar el juego en la próxima conexión
/// en vez de darlo por cacheado con medios rotos para siempre.
Future<(GameData, bool)> preloadGameAssets(
  GameData data,
  MediaStore store,
) async {
  var complete = true;

  Future<Word> localizeWord(Word w) async {
    final image = await store.localize(w.imageUrl, 'image');
    final audio = await store.localize(w.audioUrl, 'audio');
    if (_wasRemote(w.imageUrl) && image == null) complete = false;
    if (_wasRemote(w.audioUrl) && audio == null) complete = false;
    final resolvedImage = await store.resolve(image ?? w.imageUrl);
    final resolvedAudio = await store.resolve(audio ?? w.audioUrl);
    return w.copyWith(imageUrl: resolvedImage, audioUrl: resolvedAudio);
  }

  final words = [for (final w in data.words) await localizeWord(w)];
  final questions = <Question>[];
  for (final q in data.questions) {
    final answers = <Answer>[];
    for (final a in q.responseList) {
      answers.add(Answer(
        id: a.id,
        answerText: a.answerText,
        isCorrect: a.isCorrect,
        wordId: a.wordId,
        word: a.word != null ? await localizeWord(a.word!) : null,
      ));
    }
    questions.add(Question(
      id: q.id,
      question: q.question,
      responseList: answers,
      word: q.word != null ? await localizeWord(q.word!) : null,
    ));
  }

  final localized = GameData(
    activityId: data.activityId,
    gameType: data.gameType,
    title: data.title,
    difficult: data.difficult,
    experience: data.experience,
    totalQuestions: data.totalQuestions,
    questions: questions,
    words: words,
    gameConfigs: data.gameConfigs,
    mediaId: data.mediaId,
  );
  return (localized, complete);
}

/// Simétrico de [preloadGameAssets]: al LEER un juego del caché, resuelve
/// cada ruta guardada (relativa, absoluta heredada, asset o URL) a lo que
/// el widget debe consumir, con verificación de que el archivo exista.
Future<GameData> resolveGameMedia(GameData data, MediaStore store) async {
  Future<Word> resolveWord(Word w) async => w.copyWith(
        imageUrl: await store.resolve(w.imageUrl),
        audioUrl: await store.resolve(w.audioUrl),
      );

  final words = [for (final w in data.words) await resolveWord(w)];
  final questions = <Question>[];
  for (final q in data.questions) {
    final answers = <Answer>[];
    for (final a in q.responseList) {
      answers.add(Answer(
        id: a.id,
        answerText: a.answerText,
        isCorrect: a.isCorrect,
        wordId: a.wordId,
        word: a.word != null ? await resolveWord(a.word!) : null,
      ));
    }
    questions.add(Question(
      id: q.id,
      question: q.question,
      responseList: answers,
      word: q.word != null ? await resolveWord(q.word!) : null,
    ));
  }

  return GameData(
    activityId: data.activityId,
    gameType: data.gameType,
    title: data.title,
    difficult: data.difficult,
    experience: data.experience,
    totalQuestions: data.totalQuestions,
    questions: questions,
    words: words,
    gameConfigs: data.gameConfigs,
    mediaId: data.mediaId,
  );
}
