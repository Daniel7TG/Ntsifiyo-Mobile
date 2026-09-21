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
  final bool pronunciation;

  const Word({
    this.id,
    required this.spanishWord,
    required this.mazahuaWord,
    this.spanishPronunciation,
    this.mazahuaPronunciation,
    this.imageUrl,
    this.audioUrl,
    this.category,
    this.pronunciation = false,
  });

  factory Word.fromJson(Map<String, dynamic> json) {
    final id = _asInt(json['id'] ?? json['wordId'] ?? json['word_id']);
    final img =
        (json['imageUrl'] ?? json['urlImage'] ?? json['image']) as String?;
    final aud = (json['audioUrl'] ??
        // WordMediaResponseDTO (GET /api/dictionary/words/details/{id},
        // POST /api/dictionary/media) los llama urlAudio/urlImage.
        json['urlAudio'] ??
        json['urlMazahuaAudio'] ??
        json['urlSpanishAudio'] ??
        // WordFullDTO (GET /api/dictionary/words/full[/{id}]) usa
        // mazahuaAudioUrl/spanishAudioUrl en vez del prefijo url*.
        json['mazahuaAudioUrl'] ??
        json['spanishAudioUrl'] ??
        json['audio']) as String?;

    return Word(
      id: id,
      spanishWord: (json['spanishWord'] ?? json['spanishText'] ?? '') as String,
      mazahuaWord: (json['mazahuaWord'] ?? json['mazahuaText'] ?? '') as String,
      spanishPronunciation: json['spanishPronunciation'] as String?,
      mazahuaPronunciation: json['mazahuaPronunciation'] as String?,
      // Sin ruta fabricada: si el backend no manda imageUrl/audioUrl se deja
      // en null. Inventar 'assets/dictionary/img/$id.webp' aquí persistía
      // una ruta inexistente en CachedWords cuando el id no está en el
      // bundle; el fallback por wordId ya lo resuelve WordImage en la UI.
      imageUrl: img,
      audioUrl: aud,
      category: (json['category'] ?? json['topic']) as String?,
      pronunciation: _asBool(json['pronunciation']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'spanishWord': spanishWord,
        'mazahuaWord': mazahuaWord,
        'spanishPronunciation': spanishPronunciation,
        'mazahuaPronunciation': mazahuaPronunciation,
        'imageUrl': imageUrl,
        'audioUrl': audioUrl,
        'category': category,
        'pronunciation': pronunciation,
      };

  Word copyWith({
    int? id,
    String? imageUrl,
    String? audioUrl,
    String? category,
    bool? pronunciation,
  }) =>
      Word(
        id: id ?? this.id,
        spanishWord: spanishWord,
        mazahuaWord: mazahuaWord,
        spanishPronunciation: spanishPronunciation,
        mazahuaPronunciation: mazahuaPronunciation,
        imageUrl: imageUrl ?? this.imageUrl,
        audioUrl: audioUrl ?? this.audioUrl,
        category: category ?? this.category,
        pronunciation: pronunciation ?? this.pronunciation,
      );

  /// Texto según configuración de idioma.
  String textFor(GameConfig config) =>
      config.isMazahua ? mazahuaWord : spanishWord;
}

/// Clasificación del resultado del modelo de pronunciación ONNX.
enum PronunciationStatus {
  correct,
  incorrect,
  incorrectDifferentWord,
  silence;

  static PronunciationStatus fromString(String? value) {
    switch (value?.toUpperCase()) {
      case 'CORRECT':
        return PronunciationStatus.correct;
      case 'INCORRECT_DIFFERENT_WORD':
        return PronunciationStatus.incorrectDifferentWord;
      case 'SILENCE':
        return PronunciationStatus.silence;
      case 'INCORRECT':
      default:
        return PronunciationStatus.incorrect;
    }
  }
}

/// Veredicto devuelto por la validación de pronunciación.
class VeredictoPronunciacion {
  final PronunciationStatus status;
  final double score; // Puntuación 0.0 a 100.0 %
  final String targetWord;
  final String? detectedWord;
  final double targetDistance;
  final double minDistance;
  final double threshold;
  final String mensaje;

  VeredictoPronunciacion({
    required this.status,
    required this.score,
    required this.targetWord,
    this.detectedWord,
    required this.targetDistance,
    required this.minDistance,
    required this.threshold,
    required this.mensaje,
  });

  bool get esCorrecto => status == PronunciationStatus.correct;
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

  factory Answer.fromJson(Map<String, dynamic> json) {
    Word? w;
    if (json['word'] is Map<String, dynamic>) {
      w = Word.fromJson(json['word'] as Map<String, dynamic>);
    } else {
      final wId = _asInt(json['wordId'] ?? json['word_id']);
      final img =
          (json['imageUrl'] ?? json['urlImage'] ?? json['image']) as String?;
      final aud = (json['audioUrl'] ??
          json['urlMazahuaAudio'] ??
          json['urlSpanishAudio'] ??
          json['audio']) as String?;
      final text = (json['answerText'] ?? json['text'] ?? '') as String;
      if (wId != null || img != null || aud != null) {
        // Sin ruta fabricada (ver Word.fromJson): que quede null si el
        // backend no la manda, para que WordImage resuelva el fallback por
        // wordId en tiempo de render en vez de congelar en contentJson una
        // ruta que puede no existir en el bundle.
        w = Word(
          id: wId,
          spanishWord: text,
          mazahuaWord: text,
          imageUrl: img,
          audioUrl: aud,
        );
      }
    }
    return Answer(
      id: _asInt(json['id'] ?? json['answerId']),
      answerText: (json['answerText'] ?? json['text'] ?? '') as String,
      isCorrect: _asBool(json['isCorrect'] ?? json['correct']),
      wordId: _asInt(json['wordId'] ?? json['word_id']),
      word: w,
    );
  }

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

  factory Question.fromJson(Map<String, dynamic> json) {
    Word? w;
    if (json['word'] is Map<String, dynamic>) {
      w = Word.fromJson(json['word'] as Map<String, dynamic>);
    } else {
      final wId = _asInt(json['wordId'] ?? json['word_id']);
      final img =
          (json['imageUrl'] ?? json['urlImage'] ?? json['image']) as String?;
      final aud = (json['audioUrl'] ??
          json['urlMazahuaAudio'] ??
          json['urlSpanishAudio'] ??
          json['audio']) as String?;
      if (wId != null || img != null || aud != null) {
        // Sin ruta fabricada, mismo motivo que en Answer.fromJson arriba.
        w = Word(
          id: wId,
          spanishWord: (json['question'] ?? '') as String,
          mazahuaWord: (json['question'] ?? '') as String,
          imageUrl: img,
          audioUrl: aud,
        );
      }
    }
    return Question(
      id: _asInt(json['id'] ?? json['questionId']),
      question: (json['question'] ?? '') as String,
      responseList: ((json['responseList'] ?? json['answers'] ?? []) as List)
          .whereType<Map<String, dynamic>>()
          .map(Answer.fromJson)
          .toList(),
      word: w,
    );
  }

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

  int get displayXp {
    if (experience != null && experience! > 0) return experience!;
    return (totalQuestions ?? 5) * 10;
  }

  factory GameSummaryDto.fromJson(Map<String, dynamic> json) =>
      GameSummaryDto(
        id: _asInt(json['id'] ?? json['gameId']) ?? 0,
        title: (json['title'] ?? '') as String,
        description: json['description'] as String?,
        difficult: json['difficult'] as String?,
        gameType: (json['gameType'] ?? json['type']) as String?,
        topic: (json['topic'] ?? json['gameTopic']) as String?,
        experience: _asInt(json['experience'] ?? json['xp'] ?? json['totalExperience'] ?? json['experienceEarned']),
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

  /// El backend no siempre incluye metadatos en el start; se completan
  /// desde el GameSummaryDto del listado.
  GameData copyWith({
    String? gameType,
    String? title,
    String? difficult,
    int? experience,
    int? totalQuestions,
  }) =>
      GameData(
        activityId: activityId,
        gameType: gameType ?? this.gameType,
        title: title ?? this.title,
        difficult: difficult ?? this.difficult,
        experience: experience ?? this.experience,
        totalQuestions: totalQuestions ?? this.totalQuestions,
        questions: questions,
        words: words,
        gameConfigs: gameConfigs,
        mediaId: mediaId,
      );

  factory GameData.fromJson(Map<String, dynamic> json) {
    final words = ((json['words'] ?? []) as List)
        .whereType<Map<String, dynamic>>()
        .map(Word.fromJson)
        .toList();
    final wordMap = {for (final w in words) if (w.id != null) w.id!: w};

    final rawQuestions = ((json['questions'] ?? []) as List)
        .whereType<Map<String, dynamic>>()
        .map(Question.fromJson)
        .toList();

    final questions = rawQuestions.map((q) {
      final qWord = q.word ?? (q.id != null ? wordMap[q.id] : null);
      final answers = q.responseList.map((a) {
        final linkedWord = a.word ?? (a.wordId != null ? wordMap[a.wordId] : null);
        return Answer(
          id: a.id,
          answerText: a.answerText,
          isCorrect: a.isCorrect,
          wordId: a.wordId,
          word: linkedWord,
        );
      }).toList();

      return Question(
        id: q.id,
        question: q.question,
        responseList: answers,
        word: qWord,
      );
    }).toList();

    return GameData(
      activityId: _asInt(json['activityId']),
      gameType: (json['gameType'] ?? json['type']) as String?,
      title: json['title'] as String?,
      difficult: json['difficult'] as String?,
      experience: _asInt(json['experience']),
      totalQuestions: _asInt(json['totalQuestions']),
      questions: questions,
      words: words,
      gameConfigs:
          ((json['gameConfigs'] ?? json['gameconfigs'] ?? json['gameConfigDTO'] ?? [])
                  as List)
              .whereType<Map<String, dynamic>>()
              .map(GameConfig.fromJson)
              .toList(),
      mediaId: _asInt(json['mediaId']),
    );
  }

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
///
/// Los campos de presentación (`wordText`, `questionText`, `correct*`,
/// `selected*`) solo alimentan el panel "Revisar respuestas" del resumen;
/// nunca viajan al backend (ver [toApiJson]).
class ResponseLog {
  final int? questionId;
  final dynamic responseAnswerId;
  final bool isCorrect;

  /// Solo para el resumen local en juegos de pares.
  final String? wordText;

  final String? questionText;
  final String? questionImage;
  final String? questionAudio;

  final String? correctText;
  final String? correctImage;
  final String? correctAudio;

  final String? selectedText;
  final String? selectedImage;
  final String? selectedAudio;

  const ResponseLog({
    this.questionId,
    this.responseAnswerId,
    required this.isCorrect,
    this.wordText,
    this.questionText,
    this.questionImage,
    this.questionAudio,
    this.correctText,
    this.correctImage,
    this.correctAudio,
    this.selectedText,
    this.selectedImage,
    this.selectedAudio,
  });

  factory ResponseLog.fromJson(Map<String, dynamic> json) => ResponseLog(
        questionId: _asInt(json['questionId']),
        responseAnswerId: json['responseAnswerId'] ?? json['answerId'],
        isCorrect: _asBool(json['isCorrect']),
        wordText: json['wordText'] as String?,
        questionText: json['questionText'] as String?,
        questionImage: json['questionImage'] as String?,
        questionAudio: json['questionAudio'] as String?,
        correctText: json['correctText'] as String?,
        correctImage: json['correctImage'] as String?,
        correctAudio: json['correctAudio'] as String?,
        selectedText: json['selectedText'] as String?,
        selectedImage: json['selectedImage'] as String?,
        selectedAudio: json['selectedAudio'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'questionId': questionId,
        'responseAnswerId': responseAnswerId,
        'isCorrect': isCorrect,
        if (wordText != null) 'wordText': wordText,
        if (questionText != null) 'questionText': questionText,
        if (questionImage != null) 'questionImage': questionImage,
        if (questionAudio != null) 'questionAudio': questionAudio,
        if (correctText != null) 'correctText': correctText,
        if (correctImage != null) 'correctImage': correctImage,
        if (correctAudio != null) 'correctAudio': correctAudio,
        if (selectedText != null) 'selectedText': selectedText,
        if (selectedImage != null) 'selectedImage': selectedImage,
        if (selectedAudio != null) 'selectedAudio': selectedAudio,
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

abstract class ResourceChangeType {
  static const created = 'CREATED';
  static const updated = 'UPDATED';
  static const deleted = 'DELETED';
}

/// Un elemento del delta de GET /api/catalog/updates: qué id cambió y cómo.
/// El backend colapsa el historial a un solo cambio por objeto (el más
/// reciente), así que un juego creado y editado tres veces desde `since`
/// llega una sola vez como `UPDATED`.
class CatalogChange {
  final int id;
  final String changeType;
  final DateTime? updatedAt;

  const CatalogChange({
    required this.id,
    required this.changeType,
    this.updatedAt,
  });

  bool get isDeleted => changeType == ResourceChangeType.deleted;

  /// [idKey] es `gameId` o `wordId` según la lista; se aceptan también `id`
  /// y snake_case por la misma tolerancia que el resto de parsers.
  static CatalogChange? fromJson(Map<String, dynamic> json, String idKey) {
    final id = _asInt(json[idKey] ?? json['id'] ?? json['resourceId']);
    if (id == null) return null;
    final raw = json['updatedAt'] as String?;
    return CatalogChange(
      id: id,
      changeType: (json['changeType'] as String?) ?? ResourceChangeType.updated,
      updatedAt: raw != null ? DateTime.tryParse(raw) : null,
    );
  }
}

/// Mirror de GET /api/catalog/updates. Sustituye a los antiguos
/// `/api/games/updatedGames` y `/api/dictionary/updatedWords`, que solo
/// daban la fecha del último cambio y obligaban a redescargar el catálogo
/// entero; este trae los **ids** de lo que cambió, para bajar solo eso.
///
/// [serverTime] se guarda **como string, sin parsear**, y se reenvía tal
/// cual como `since` en la siguiente sincronización. El backend lo emite
/// como `LocalDateTime` (sin zona), así que redondearlo por `DateTime` lo
/// interpretaría en la zona del dispositivo y podría desplazarlo horas
/// respecto al reloj del servidor, que es contra el que se compara `since`.
class CatalogUpdates {
  final String? since;
  final String? serverTime;
  final List<CatalogChange> games;
  final List<CatalogChange> words;

  const CatalogUpdates({
    this.since,
    this.serverTime,
    this.games = const [],
    this.words = const [],
  });

  bool get isEmpty => games.isEmpty && words.isEmpty;

  factory CatalogUpdates.fromJson(Map<String, dynamic> json) {
    List<CatalogChange> parse(dynamic raw, String idKey) => (raw is List
            ? raw.whereType<Map<String, dynamic>>()
            : const <Map<String, dynamic>>[])
        .map((e) => CatalogChange.fromJson(e, idKey))
        .whereType<CatalogChange>()
        .toList();

    return CatalogUpdates(
      since: json['since'] as String?,
      serverTime: json['serverTime'] as String?,
      games: parse(json['games'], 'gameId'),
      words: parse(json['words'], 'wordId'),
    );
  }
}
