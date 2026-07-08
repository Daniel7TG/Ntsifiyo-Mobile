import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../data/models/models.dart';

/// Descarga imágenes/audio de un GameData a disco y reescribe las URLs a
/// rutas locales (equivalente persistente del preloadAssets de la web).
/// Si un recurso no puede descargarse, conserva la URL remota.
Future<GameData> preloadGameAssets(GameData data) async {
  final dir = await getApplicationSupportDirectory();
  final mediaDir = Directory(p.join(dir.path, 'game_media'));
  if (!mediaDir.existsSync()) mediaDir.createSync(recursive: true);
  final dio = Dio();
  final cache = <String, String>{};

  Future<String?> localize(String? url) async {
    if (url == null || url.isEmpty || !url.startsWith('http')) return url;
    if (cache.containsKey(url)) return cache[url];
    final name =
        url.hashCode.toRadixString(16) + p.extension(Uri.parse(url).path);
    final file = File(p.join(mediaDir.path, name));
    if (!file.existsSync()) {
      try {
        await dio.download(url, file.path);
      } catch (_) {
        return url;
      }
    }
    cache[url] = file.path;
    return file.path;
  }

  Future<Word> localizeWord(Word w) async => w.copyWith(
        imageUrl: await localize(w.imageUrl),
        audioUrl: await localize(w.audioUrl),
      );

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
