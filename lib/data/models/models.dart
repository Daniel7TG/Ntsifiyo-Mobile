/// Modelos de datos (mirror de docs/dtos-reference.md del proyecto web).
/// El backend a veces varía nombres de campos (gameConfigDTO vs gameConfigs),
/// por eso los parsers aceptan alias.
library;

int? _asInt(dynamic v) =>
    v == null ? null : (v is int ? v : int.tryParse(v.toString()));

bool _asBool(dynamic v) => v == true || v == 'true' || v == 1;

abstract class Roles {
  static const student = 'STUDENT';
  static const visitor = 'VISITOR';
}

abstract class Difficulty {
  static const easy = 'EASY';
  static const medium = 'MEDIUM';
  static const hard = 'HARD';

  static String label(String? d) => switch (d) {
        easy => 'Fácil',
        medium => 'Media',
        hard => 'Difícil',
        _ => d ?? '',
      };
}

/// Usuario autenticado (equivalente a `appUser` en localStorage de la web).
class AppUser {
  final String firstname;
  final String lastname;
  final String userType; // STUDENT | VISITOR

  const AppUser({
    required this.firstname,
    required this.lastname,
    required this.userType,
  });

  bool get isStudent => userType == Roles.student;

  String get displayName =>
      [firstname, lastname].where((s) => s.isNotEmpty).join(' ');

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        firstname: (json['firstname'] ?? json['firstName'] ?? '') as String,
        lastname: (json['lastname'] ?? json['lastName'] ?? '') as String,
        userType: (json['userType'] ?? Roles.visitor) as String,
      );

  Map<String, dynamic> toJson() => {
        'firstname': firstname,
        'lastname': lastname,
        'userType': userType,
      };
}

/// GameConfigDTO — cómo se presenta el prompt/las opciones de un juego.
class GameConfig {
  final bool showImage;
  final bool showText;
  final bool playAudio;
  final bool isMazahua;

  const GameConfig({
    this.showImage = true,
    this.showText = true,
    this.playAudio = false,
    this.isMazahua = true,
  });

  factory GameConfig.fromJson(Map<String, dynamic> json) => GameConfig(
        showImage: _asBool(json['showImage']),
        showText: _asBool(json['showText']),
        playAudio: _asBool(json['playAudio']),
        isMazahua: _asBool(json['isMazahua']),
      );

  Map<String, dynamic> toJson() => {
        'showImage': showImage,
        'showText': showText,
        'playAudio': playAudio,
        'isMazahua': isMazahua,
      };
}

/// Palabra del diccionario / contenido de juego.
class Word {
  final int? id;
  final String spanishWord;
  final String mazahuaWord;
  final String? spanishPronunciation;
  final String? mazahuaPronunciation;
  final String? imageUrl;
  final String? audioUrl;
  final String? category;

  const Word({
    this.id,
    required this.spanishWord,
    required this.mazahuaWord,
    this.spanishPronunciation,
    this.mazahuaPronunciation,
    this.imageUrl,
    this.audioUrl,
    this.category,
  });

  factory Word.fromJson(Map<String, dynamic> json) => Word(
        id: _asInt(json['id'] ?? json['wordId']),
        spanishWord: (json['spanishWord'] ?? '') as String,
        mazahuaWord: (json['mazahuaWord'] ?? '') as String,
        spanishPronunciation: json['spanishPronunciation'] as String?,
        mazahuaPronunciation: json['mazahuaPronunciation'] as String?,
        imageUrl: json['imageUrl'] as String?,
        audioUrl: json['audioUrl'] as String?,
        category: json['category'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'spanishWord': spanishWord,
        'mazahuaWord': mazahuaWord,
        'spanishPronunciation': spanishPronunciation,
        'mazahuaPronunciation': mazahuaPronunciation,
        'imageUrl': imageUrl,
        'audioUrl': audioUrl,
        'category': category,
      };

  Word copyWith({String? imageUrl, String? audioUrl}) => Word(
        id: id,
        spanishWord: spanishWord,
        mazahuaWord: mazahuaWord,
        spanishPronunciation: spanishPronunciation,
        mazahuaPronunciation: mazahuaPronunciation,
        imageUrl: imageUrl ?? this.imageUrl,
        audioUrl: audioUrl ?? this.audioUrl,
        category: category,
      );

  /// Texto según configuración de idioma.
  String textFor(GameConfig config) =>
      config.isMazahua ? mazahuaWord : spanishWord;
}

/// AnswerDTO — opción de respuesta de una pregunta.
class Answer {
  final int? id;
  final String answerText;
  final bool isCorrect;
  final int? wordId;
  final Word? word;

  const Answer({
    this.id,
    required this.answerText,
    required this.isCorrect,
    this.wordId,
    this.word,
  });

  factory Answer.fromJson(Map<String, dynamic> json) => Answer(
        id: _asInt(json['id'] ?? json['answerId']),
        answerText: (json['answerText'] ?? json['text'] ?? '') as String,
        isCorrect: _asBool(json['isCorrect'] ?? json['correct']),
        wordId: _asInt(json['wordId']),
        word: json['word'] is Map<String, dynamic>
            ? Word.fromJson(json['word'] as Map<String, dynamic>)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'answerText': answerText,
        'isCorrect': isCorrect,
        'wordId': wordId,
        'word': word?.toJson(),
      };
}

/// QuestionDTO.
class Question {
  final int? id;
  final String question;
  final List<Answer> responseList;
  final Word? word;

  const Question({
    this.id,
    required this.question,
    required this.responseList,
    this.word,
  });

  factory Question.fromJson(Map<String, dynamic> json) => Question(
        id: _asInt(json['id'] ?? json['questionId']),
        question: (json['question'] ?? '') as String,
        responseList: ((json['responseList'] ?? json['answers'] ?? []) as List)
            .whereType<Map<String, dynamic>>()
            .map(Answer.fromJson)
            .toList(),
        word: json['word'] is Map<String, dynamic>
            ? Word.fromJson(json['word'] as Map<String, dynamic>)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'question': question,
        'responseList': responseList.map((a) => a.toJson()).toList(),
        'word': word?.toJson(),
      };
}

/// GameDTO (listado) — tarjeta de actividad en el panel de acceso.
class GameSummaryDto {
  final int id;
  final String title;
  final String? description;
  final String? difficult;
  final String? gameType;
  final String? topic;
  final int? experience;
  final int? totalQuestions;
  final List<GameConfig> gameConfigs;

  const GameSummaryDto({
    required this.id,
    required this.title,
    this.description,
    this.difficult,
    this.gameType,
    this.topic,
    this.experience,
    this.totalQuestions,
    this.gameConfigs = const [],
  });

  factory GameSummaryDto.fromJson(Map<String, dynamic> json) =>
      GameSummaryDto(
        id: _asInt(json['id'] ?? json['gameId']) ?? 0,
        title: (json['title'] ?? '') as String,
        description: json['description'] as String?,
        difficult: json['difficult'] as String?,
        gameType: (json['gameType'] ?? json['type']) as String?,
        topic: (json['topic'] ?? json['gameTopic']) as String?,
        experience: _asInt(json['experience']),
        totalQuestions: _asInt(json['totalQuestions']),
        gameConfigs:
            ((json['gameConfigDTO'] ?? json['gameConfigs'] ?? []) as List)
                .whereType<Map<String, dynamic>>()
                .map(GameConfig.fromJson)
                .toList(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'difficult': difficult,
        'gameType': gameType,
        'topic': topic,
        'experience': experience,
        'totalQuestions': totalQuestions,
        'gameConfigDTO': gameConfigs.map((c) => c.toJson()).toList(),
      };
}

/// StartGameResponseDTO — contenido jugable (`currentGameData` de la web).
/// `gameConfigs[0]` = presentación del prompt, `gameConfigs[1]` = opciones.
class GameData {
  final int? activityId; // presente si vino de una asignación
  final String? gameType;
  final String? title;
  final String? difficult;
  final int? experience;
  final int? totalQuestions;
  final List<Question> questions;
  final List<Word> words;
  final List<GameConfig> gameConfigs;
  final int? mediaId;

  const GameData({
    this.activityId,
    this.gameType,
    this.title,
    this.difficult,
    this.experience,
    this.totalQuestions,
    this.questions = const [],
    this.words = const [],
    this.gameConfigs = const [],
    this.mediaId,
  });

  GameConfig get promptConfig =>
      gameConfigs.isNotEmpty ? gameConfigs[0] : const GameConfig();
  GameConfig get answerConfig =>
      gameConfigs.length > 1 ? gameConfigs[1] : promptConfig;

  factory GameData.fromJson(Map<String, dynamic> json) => GameData(
        activityId: _asInt(json['activityId']),
        gameType: (json['gameType'] ?? json['type']) as String?,
        title: json['title'] as String?,
        difficult: json['difficult'] as String?,
        experience: _asInt(json['experience']),
        totalQuestions: _asInt(json['totalQuestions']),
        questions: ((json['questions'] ?? []) as List)
            .whereType<Map<String, dynamic>>()
            .map(Question.fromJson)
            .toList(),
        words: ((json['words'] ?? []) as List)
            .whereType<Map<String, dynamic>>()
            .map(Word.fromJson)
            .toList(),
        gameConfigs:
            ((json['gameConfigs'] ?? json['gameconfigs'] ?? json['gameConfigDTO'] ?? [])
                    as List)
                .whereType<Map<String, dynamic>>()
                .map(GameConfig.fromJson)
                .toList(),
        mediaId: _asInt(json['mediaId']),
      );

  Map<String, dynamic> toJson() => {
        'activityId': activityId,
        'gameType': gameType,
        'title': title,
        'difficult': difficult,
        'experience': experience,
        'totalQuestions': totalQuestions,
        'questions': questions.map((q) => q.toJson()).toList(),
        'words': words.map((w) => w.toJson()).toList(),
        'gameConfigs': gameConfigs.map((c) => c.toJson()).toList(),
        'mediaId': mediaId,
      };
}

/// ResponseLogDTO — respuesta registrada durante un juego.
class ResponseLog {
  final int? questionId;
  final int? responseAnswerId;
  final bool isCorrect;

  /// Solo para el resumen local en juegos de pares (no se envía).
  final String? wordText;

  const ResponseLog({
    this.questionId,
    this.responseAnswerId,
    required this.isCorrect,
    this.wordText,
  });

  factory ResponseLog.fromJson(Map<String, dynamic> json) => ResponseLog(
        questionId: _asInt(json['questionId']),
        responseAnswerId:
            _asInt(json['responseAnswerId'] ?? json['answerId']),
        isCorrect: _asBool(json['isCorrect']),
        wordText: json['wordText'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'questionId': questionId,
        'responseAnswerId': responseAnswerId,
        'isCorrect': isCorrect,
        if (wordText != null) 'wordText': wordText,
      };

  /// Payload que espera POST /api/activities/complete.
  Map<String, dynamic> toApiJson() => {
        'questionId': questionId,
        'responseAnswerId': responseAnswerId,
        'isCorrect': isCorrect,
      };
}

/// RewardResponseDTO / respuesta de complete.
class RewardResult {
  final int xpGained;
  final int actualXp;
  final int currentLevel;
  final bool isLevelUp;

  const RewardResult({
    this.xpGained = 0,
    this.actualXp = 0,
    this.currentLevel = 1,
    this.isLevelUp = false,
  });

  factory RewardResult.fromJson(Map<String, dynamic> json) => RewardResult(
        xpGained: _asInt(json['xpGained']) ?? 0,
        actualXp: _asInt(json['actualXp']) ?? 0,
        currentLevel: _asInt(json['currentLevel']) ?? 1,
        isLevelUp: _asBool(json['isLevelUp']),
      );

  Map<String, dynamic> toJson() => {
        'xpGained': xpGained,
        'actualXp': actualXp,
        'currentLevel': currentLevel,
        'isLevelUp': isLevelUp,
      };
}

/// Página estilo Spring (`{content, totalPages, number, first, last}`).
class Paged<T> {
  final List<T> content;
  final int totalPages;
  final int number;
  final bool first;
  final bool last;

  const Paged({
    required this.content,
    this.totalPages = 1,
    this.number = 0,
    this.first = true,
    this.last = true,
  });

  factory Paged.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJson,
  ) =>
      Paged(
        content: ((json['content'] ?? []) as List)
            .whereType<Map<String, dynamic>>()
            .map(fromJson)
            .toList(),
        totalPages: _asInt(json['totalPages']) ?? 1,
        number: _asInt(json['number']) ?? 0,
        first: json['first'] != false,
        last: json['last'] != false,
      );
}

/// MediaDTO — elemento de la sección Contenido.
class MediaItem {
  final int? id;
  final String title;
  final int? duration;
  final String? overviewImage;
  final String? mediaType; // SONG | ANECDOTE | LEGEND | POEM
  final String? description;
  final String? difficult;

  const MediaItem({
    this.id,
    required this.title,
    this.duration,
    this.overviewImage,
    this.mediaType,
    this.description,
    this.difficult,
  });

  factory MediaItem.fromJson(Map<String, dynamic> json) => MediaItem(
        id: _asInt(json['id'] ?? json['mediaId']),
        title: (json['title'] ?? '') as String,
        duration: _asInt(json['duration']),
        overviewImage: json['overviewImage'] as String?,
        mediaType: json['mediaType'] as String?,
        description: json['description'] as String?,
        difficult: json['difficult'] as String?,
      );
}

/// SubtitleDTO — línea de subtítulo bilingüe.
class SubtitleLine {
  final String? spanishText;
  final String? mazahuaText;
  final int timeStart; // segundos
  final int timeEnd;

  const SubtitleLine({
    this.spanishText,
    this.mazahuaText,
    required this.timeStart,
    required this.timeEnd,
  });

  factory SubtitleLine.fromJson(Map<String, dynamic> json) => SubtitleLine(
        spanishText: json['spanishText'] as String?,
        mazahuaText: json['mazahuaText'] as String?,
        timeStart: _asInt(json['timeStart']) ?? 0,
        timeEnd: _asInt(json['timeEnd']) ?? 0,
      );
}

/// StreamResourcesDTO. El backend puede devolver la lista de subtítulos
/// embebida o URLs de archivos VTT por idioma.
class StreamResources {
  final String url;
  final List<SubtitleLine> subtitles;
  final String? espSubtitlesUrl;
  final String? mazSubtitlesUrl;

  const StreamResources({
    required this.url,
    this.subtitles = const [],
    this.espSubtitlesUrl,
    this.mazSubtitlesUrl,
  });

  factory StreamResources.fromJson(Map<String, dynamic> json) =>
      StreamResources(
        url: (json['url'] ?? '') as String,
        subtitles: ((json['subtitles'] ?? []) as List)
            .whereType<Map<String, dynamic>>()
            .map(SubtitleLine.fromJson)
            .toList(),
        espSubtitlesUrl: json['espSubtitlesUrl'] as String?,
        mazSubtitlesUrl: json['mazSubtitlesUrl'] as String?,
      );
}
