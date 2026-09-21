// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CachedGamesTable extends CachedGames
    with TableInfo<$CachedGamesTable, CachedGame> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedGamesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _gameIdMeta = const VerificationMeta('gameId');
  @override
  late final GeneratedColumn<int> gameId = GeneratedColumn<int>(
    'game_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gameTypeMeta = const VerificationMeta(
    'gameType',
  );
  @override
  late final GeneratedColumn<String> gameType = GeneratedColumn<String>(
    'game_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _topicMeta = const VerificationMeta('topic');
  @override
  late final GeneratedColumn<String> topic = GeneratedColumn<String>(
    'topic',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _difficultMeta = const VerificationMeta(
    'difficult',
  );
  @override
  late final GeneratedColumn<String> difficult = GeneratedColumn<String>(
    'difficult',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _experienceMeta = const VerificationMeta(
    'experience',
  );
  @override
  late final GeneratedColumn<int> experience = GeneratedColumn<int>(
    'experience',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totalQuestionsMeta = const VerificationMeta(
    'totalQuestions',
  );
  @override
  late final GeneratedColumn<int> totalQuestions = GeneratedColumn<int>(
    'total_questions',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _contentJsonMeta = const VerificationMeta(
    'contentJson',
  );
  @override
  late final GeneratedColumn<String> contentJson = GeneratedColumn<String>(
    'content_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mediaCompleteMeta = const VerificationMeta(
    'mediaComplete',
  );
  @override
  late final GeneratedColumn<bool> mediaComplete = GeneratedColumn<bool>(
    'media_complete',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("media_complete" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    gameId,
    gameType,
    title,
    topic,
    difficult,
    experience,
    totalQuestions,
    contentJson,
    mediaComplete,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_games';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedGame> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('game_id')) {
      context.handle(
        _gameIdMeta,
        gameId.isAcceptableOrUnknown(data['game_id']!, _gameIdMeta),
      );
    }
    if (data.containsKey('game_type')) {
      context.handle(
        _gameTypeMeta,
        gameType.isAcceptableOrUnknown(data['game_type']!, _gameTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_gameTypeMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('topic')) {
      context.handle(
        _topicMeta,
        topic.isAcceptableOrUnknown(data['topic']!, _topicMeta),
      );
    }
    if (data.containsKey('difficult')) {
      context.handle(
        _difficultMeta,
        difficult.isAcceptableOrUnknown(data['difficult']!, _difficultMeta),
      );
    }
    if (data.containsKey('experience')) {
      context.handle(
        _experienceMeta,
        experience.isAcceptableOrUnknown(data['experience']!, _experienceMeta),
      );
    }
    if (data.containsKey('total_questions')) {
      context.handle(
        _totalQuestionsMeta,
        totalQuestions.isAcceptableOrUnknown(
          data['total_questions']!,
          _totalQuestionsMeta,
        ),
      );
    }
    if (data.containsKey('content_json')) {
      context.handle(
        _contentJsonMeta,
        contentJson.isAcceptableOrUnknown(
          data['content_json']!,
          _contentJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_contentJsonMeta);
    }
    if (data.containsKey('media_complete')) {
      context.handle(
        _mediaCompleteMeta,
        mediaComplete.isAcceptableOrUnknown(
          data['media_complete']!,
          _mediaCompleteMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {gameId};
  @override
  CachedGame map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedGame(
      gameId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}game_id'],
      )!,
      gameType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}game_type'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      topic: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}topic'],
      ),
      difficult: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}difficult'],
      ),
      experience: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}experience'],
      ),
      totalQuestions: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_questions'],
      ),
      contentJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_json'],
      )!,
      mediaComplete: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}media_complete'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $CachedGamesTable createAlias(String alias) {
    return $CachedGamesTable(attachedDatabase, alias);
  }
}

class CachedGame extends DataClass implements Insertable<CachedGame> {
  final int gameId;
  final String gameType;
  final String title;
  final String? topic;
  final String? difficult;
  final int? experience;
  final int? totalQuestions;
  final String contentJson;
  final bool mediaComplete;
  final DateTime updatedAt;
  const CachedGame({
    required this.gameId,
    required this.gameType,
    required this.title,
    this.topic,
    this.difficult,
    this.experience,
    this.totalQuestions,
    required this.contentJson,
    required this.mediaComplete,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['game_id'] = Variable<int>(gameId);
    map['game_type'] = Variable<String>(gameType);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || topic != null) {
      map['topic'] = Variable<String>(topic);
    }
    if (!nullToAbsent || difficult != null) {
      map['difficult'] = Variable<String>(difficult);
    }
    if (!nullToAbsent || experience != null) {
      map['experience'] = Variable<int>(experience);
    }
    if (!nullToAbsent || totalQuestions != null) {
      map['total_questions'] = Variable<int>(totalQuestions);
    }
    map['content_json'] = Variable<String>(contentJson);
    map['media_complete'] = Variable<bool>(mediaComplete);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CachedGamesCompanion toCompanion(bool nullToAbsent) {
    return CachedGamesCompanion(
      gameId: Value(gameId),
      gameType: Value(gameType),
      title: Value(title),
      topic: topic == null && nullToAbsent
          ? const Value.absent()
          : Value(topic),
      difficult: difficult == null && nullToAbsent
          ? const Value.absent()
          : Value(difficult),
      experience: experience == null && nullToAbsent
          ? const Value.absent()
          : Value(experience),
      totalQuestions: totalQuestions == null && nullToAbsent
          ? const Value.absent()
          : Value(totalQuestions),
      contentJson: Value(contentJson),
      mediaComplete: Value(mediaComplete),
      updatedAt: Value(updatedAt),
    );
  }

  factory CachedGame.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedGame(
      gameId: serializer.fromJson<int>(json['gameId']),
      gameType: serializer.fromJson<String>(json['gameType']),
      title: serializer.fromJson<String>(json['title']),
      topic: serializer.fromJson<String?>(json['topic']),
      difficult: serializer.fromJson<String?>(json['difficult']),
      experience: serializer.fromJson<int?>(json['experience']),
      totalQuestions: serializer.fromJson<int?>(json['totalQuestions']),
      contentJson: serializer.fromJson<String>(json['contentJson']),
      mediaComplete: serializer.fromJson<bool>(json['mediaComplete']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'gameId': serializer.toJson<int>(gameId),
      'gameType': serializer.toJson<String>(gameType),
      'title': serializer.toJson<String>(title),
      'topic': serializer.toJson<String?>(topic),
      'difficult': serializer.toJson<String?>(difficult),
      'experience': serializer.toJson<int?>(experience),
      'totalQuestions': serializer.toJson<int?>(totalQuestions),
      'contentJson': serializer.toJson<String>(contentJson),
      'mediaComplete': serializer.toJson<bool>(mediaComplete),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CachedGame copyWith({
    int? gameId,
    String? gameType,
    String? title,
    Value<String?> topic = const Value.absent(),
    Value<String?> difficult = const Value.absent(),
    Value<int?> experience = const Value.absent(),
    Value<int?> totalQuestions = const Value.absent(),
    String? contentJson,
    bool? mediaComplete,
    DateTime? updatedAt,
  }) => CachedGame(
    gameId: gameId ?? this.gameId,
    gameType: gameType ?? this.gameType,
    title: title ?? this.title,
    topic: topic.present ? topic.value : this.topic,
    difficult: difficult.present ? difficult.value : this.difficult,
    experience: experience.present ? experience.value : this.experience,
    totalQuestions: totalQuestions.present
        ? totalQuestions.value
        : this.totalQuestions,
    contentJson: contentJson ?? this.contentJson,
    mediaComplete: mediaComplete ?? this.mediaComplete,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  CachedGame copyWithCompanion(CachedGamesCompanion data) {
    return CachedGame(
      gameId: data.gameId.present ? data.gameId.value : this.gameId,
      gameType: data.gameType.present ? data.gameType.value : this.gameType,
      title: data.title.present ? data.title.value : this.title,
      topic: data.topic.present ? data.topic.value : this.topic,
      difficult: data.difficult.present ? data.difficult.value : this.difficult,
      experience: data.experience.present
          ? data.experience.value
          : this.experience,
      totalQuestions: data.totalQuestions.present
          ? data.totalQuestions.value
          : this.totalQuestions,
      contentJson: data.contentJson.present
          ? data.contentJson.value
          : this.contentJson,
      mediaComplete: data.mediaComplete.present
          ? data.mediaComplete.value
          : this.mediaComplete,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedGame(')
          ..write('gameId: $gameId, ')
          ..write('gameType: $gameType, ')
          ..write('title: $title, ')
          ..write('topic: $topic, ')
          ..write('difficult: $difficult, ')
          ..write('experience: $experience, ')
          ..write('totalQuestions: $totalQuestions, ')
          ..write('contentJson: $contentJson, ')
          ..write('mediaComplete: $mediaComplete, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    gameId,
    gameType,
    title,
    topic,
    difficult,
    experience,
    totalQuestions,
    contentJson,
    mediaComplete,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedGame &&
          other.gameId == this.gameId &&
          other.gameType == this.gameType &&
          other.title == this.title &&
          other.topic == this.topic &&
          other.difficult == this.difficult &&
          other.experience == this.experience &&
          other.totalQuestions == this.totalQuestions &&
          other.contentJson == this.contentJson &&
          other.mediaComplete == this.mediaComplete &&
          other.updatedAt == this.updatedAt);
}

class CachedGamesCompanion extends UpdateCompanion<CachedGame> {
  final Value<int> gameId;
  final Value<String> gameType;
  final Value<String> title;
  final Value<String?> topic;
  final Value<String?> difficult;
  final Value<int?> experience;
  final Value<int?> totalQuestions;
  final Value<String> contentJson;
  final Value<bool> mediaComplete;
  final Value<DateTime> updatedAt;
  const CachedGamesCompanion({
    this.gameId = const Value.absent(),
    this.gameType = const Value.absent(),
    this.title = const Value.absent(),
    this.topic = const Value.absent(),
    this.difficult = const Value.absent(),
    this.experience = const Value.absent(),
    this.totalQuestions = const Value.absent(),
    this.contentJson = const Value.absent(),
    this.mediaComplete = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  CachedGamesCompanion.insert({
    this.gameId = const Value.absent(),
    required String gameType,
    required String title,
    this.topic = const Value.absent(),
    this.difficult = const Value.absent(),
    this.experience = const Value.absent(),
    this.totalQuestions = const Value.absent(),
    required String contentJson,
    this.mediaComplete = const Value.absent(),
    required DateTime updatedAt,
  }) : gameType = Value(gameType),
       title = Value(title),
       contentJson = Value(contentJson),
       updatedAt = Value(updatedAt);
  static Insertable<CachedGame> custom({
    Expression<int>? gameId,
    Expression<String>? gameType,
    Expression<String>? title,
    Expression<String>? topic,
    Expression<String>? difficult,
    Expression<int>? experience,
    Expression<int>? totalQuestions,
    Expression<String>? contentJson,
    Expression<bool>? mediaComplete,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (gameId != null) 'game_id': gameId,
      if (gameType != null) 'game_type': gameType,
      if (title != null) 'title': title,
      if (topic != null) 'topic': topic,
      if (difficult != null) 'difficult': difficult,
      if (experience != null) 'experience': experience,
      if (totalQuestions != null) 'total_questions': totalQuestions,
      if (contentJson != null) 'content_json': contentJson,
      if (mediaComplete != null) 'media_complete': mediaComplete,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  CachedGamesCompanion copyWith({
    Value<int>? gameId,
    Value<String>? gameType,
    Value<String>? title,
    Value<String?>? topic,
    Value<String?>? difficult,
    Value<int?>? experience,
    Value<int?>? totalQuestions,
    Value<String>? contentJson,
    Value<bool>? mediaComplete,
    Value<DateTime>? updatedAt,
  }) {
    return CachedGamesCompanion(
      gameId: gameId ?? this.gameId,
      gameType: gameType ?? this.gameType,
      title: title ?? this.title,
      topic: topic ?? this.topic,
      difficult: difficult ?? this.difficult,
      experience: experience ?? this.experience,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      contentJson: contentJson ?? this.contentJson,
      mediaComplete: mediaComplete ?? this.mediaComplete,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (gameId.present) {
      map['game_id'] = Variable<int>(gameId.value);
    }
    if (gameType.present) {
      map['game_type'] = Variable<String>(gameType.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (topic.present) {
      map['topic'] = Variable<String>(topic.value);
    }
    if (difficult.present) {
      map['difficult'] = Variable<String>(difficult.value);
    }
    if (experience.present) {
      map['experience'] = Variable<int>(experience.value);
    }
    if (totalQuestions.present) {
      map['total_questions'] = Variable<int>(totalQuestions.value);
    }
    if (contentJson.present) {
      map['content_json'] = Variable<String>(contentJson.value);
    }
    if (mediaComplete.present) {
      map['media_complete'] = Variable<bool>(mediaComplete.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedGamesCompanion(')
          ..write('gameId: $gameId, ')
          ..write('gameType: $gameType, ')
          ..write('title: $title, ')
          ..write('topic: $topic, ')
          ..write('difficult: $difficult, ')
          ..write('experience: $experience, ')
          ..write('totalQuestions: $totalQuestions, ')
          ..write('contentJson: $contentJson, ')
          ..write('mediaComplete: $mediaComplete, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $PendingResultsTable extends PendingResults
    with TableInfo<$PendingResultsTable, PendingResult> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PendingResultsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _gameIdMeta = const VerificationMeta('gameId');
  @override
  late final GeneratedColumn<int> gameId = GeneratedColumn<int>(
    'game_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gameTypeMeta = const VerificationMeta(
    'gameType',
  );
  @override
  late final GeneratedColumn<String> gameType = GeneratedColumn<String>(
    'game_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<String> startDate = GeneratedColumn<String>(
    'start_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _correctAnswersMeta = const VerificationMeta(
    'correctAnswers',
  );
  @override
  late final GeneratedColumn<int> correctAnswers = GeneratedColumn<int>(
    'correct_answers',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalQuestionsMeta = const VerificationMeta(
    'totalQuestions',
  );
  @override
  late final GeneratedColumn<int> totalQuestions = GeneratedColumn<int>(
    'total_questions',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _responseLogsJsonMeta = const VerificationMeta(
    'responseLogsJson',
  );
  @override
  late final GeneratedColumn<String> responseLogsJson = GeneratedColumn<String>(
    'response_logs_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _attemptsMeta = const VerificationMeta(
    'attempts',
  );
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    gameId,
    title,
    gameType,
    startDate,
    correctAnswers,
    totalQuestions,
    responseLogsJson,
    attempts,
    completedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pending_results';
  @override
  VerificationContext validateIntegrity(
    Insertable<PendingResult> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('game_id')) {
      context.handle(
        _gameIdMeta,
        gameId.isAcceptableOrUnknown(data['game_id']!, _gameIdMeta),
      );
    } else if (isInserting) {
      context.missing(_gameIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('game_type')) {
      context.handle(
        _gameTypeMeta,
        gameType.isAcceptableOrUnknown(data['game_type']!, _gameTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_gameTypeMeta);
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('correct_answers')) {
      context.handle(
        _correctAnswersMeta,
        correctAnswers.isAcceptableOrUnknown(
          data['correct_answers']!,
          _correctAnswersMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_correctAnswersMeta);
    }
    if (data.containsKey('total_questions')) {
      context.handle(
        _totalQuestionsMeta,
        totalQuestions.isAcceptableOrUnknown(
          data['total_questions']!,
          _totalQuestionsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalQuestionsMeta);
    }
    if (data.containsKey('response_logs_json')) {
      context.handle(
        _responseLogsJsonMeta,
        responseLogsJson.isAcceptableOrUnknown(
          data['response_logs_json']!,
          _responseLogsJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_responseLogsJsonMeta);
    }
    if (data.containsKey('attempts')) {
      context.handle(
        _attemptsMeta,
        attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta),
      );
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_completedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PendingResult map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PendingResult(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      gameId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}game_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      gameType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}game_type'],
      )!,
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}start_date'],
      )!,
      correctAnswers: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}correct_answers'],
      )!,
      totalQuestions: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_questions'],
      )!,
      responseLogsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}response_logs_json'],
      )!,
      attempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempts'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      )!,
    );
  }

  @override
  $PendingResultsTable createAlias(String alias) {
    return $PendingResultsTable(attachedDatabase, alias);
  }
}

class PendingResult extends DataClass implements Insertable<PendingResult> {
  final int id;
  final int gameId;
  final String title;
  final String gameType;
  final String startDate;
  final int correctAnswers;
  final int totalQuestions;
  final String responseLogsJson;
  final int attempts;
  final DateTime completedAt;
  const PendingResult({
    required this.id,
    required this.gameId,
    required this.title,
    required this.gameType,
    required this.startDate,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.responseLogsJson,
    required this.attempts,
    required this.completedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['game_id'] = Variable<int>(gameId);
    map['title'] = Variable<String>(title);
    map['game_type'] = Variable<String>(gameType);
    map['start_date'] = Variable<String>(startDate);
    map['correct_answers'] = Variable<int>(correctAnswers);
    map['total_questions'] = Variable<int>(totalQuestions);
    map['response_logs_json'] = Variable<String>(responseLogsJson);
    map['attempts'] = Variable<int>(attempts);
    map['completed_at'] = Variable<DateTime>(completedAt);
    return map;
  }

  PendingResultsCompanion toCompanion(bool nullToAbsent) {
    return PendingResultsCompanion(
      id: Value(id),
      gameId: Value(gameId),
      title: Value(title),
      gameType: Value(gameType),
      startDate: Value(startDate),
      correctAnswers: Value(correctAnswers),
      totalQuestions: Value(totalQuestions),
      responseLogsJson: Value(responseLogsJson),
      attempts: Value(attempts),
      completedAt: Value(completedAt),
    );
  }

  factory PendingResult.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PendingResult(
      id: serializer.fromJson<int>(json['id']),
      gameId: serializer.fromJson<int>(json['gameId']),
      title: serializer.fromJson<String>(json['title']),
      gameType: serializer.fromJson<String>(json['gameType']),
      startDate: serializer.fromJson<String>(json['startDate']),
      correctAnswers: serializer.fromJson<int>(json['correctAnswers']),
      totalQuestions: serializer.fromJson<int>(json['totalQuestions']),
      responseLogsJson: serializer.fromJson<String>(json['responseLogsJson']),
      attempts: serializer.fromJson<int>(json['attempts']),
      completedAt: serializer.fromJson<DateTime>(json['completedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'gameId': serializer.toJson<int>(gameId),
      'title': serializer.toJson<String>(title),
      'gameType': serializer.toJson<String>(gameType),
      'startDate': serializer.toJson<String>(startDate),
      'correctAnswers': serializer.toJson<int>(correctAnswers),
      'totalQuestions': serializer.toJson<int>(totalQuestions),
      'responseLogsJson': serializer.toJson<String>(responseLogsJson),
      'attempts': serializer.toJson<int>(attempts),
      'completedAt': serializer.toJson<DateTime>(completedAt),
    };
  }

  PendingResult copyWith({
    int? id,
    int? gameId,
    String? title,
    String? gameType,
    String? startDate,
    int? correctAnswers,
    int? totalQuestions,
    String? responseLogsJson,
    int? attempts,
    DateTime? completedAt,
  }) => PendingResult(
    id: id ?? this.id,
    gameId: gameId ?? this.gameId,
    title: title ?? this.title,
    gameType: gameType ?? this.gameType,
    startDate: startDate ?? this.startDate,
    correctAnswers: correctAnswers ?? this.correctAnswers,
    totalQuestions: totalQuestions ?? this.totalQuestions,
    responseLogsJson: responseLogsJson ?? this.responseLogsJson,
    attempts: attempts ?? this.attempts,
    completedAt: completedAt ?? this.completedAt,
  );
  PendingResult copyWithCompanion(PendingResultsCompanion data) {
    return PendingResult(
      id: data.id.present ? data.id.value : this.id,
      gameId: data.gameId.present ? data.gameId.value : this.gameId,
      title: data.title.present ? data.title.value : this.title,
      gameType: data.gameType.present ? data.gameType.value : this.gameType,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      correctAnswers: data.correctAnswers.present
          ? data.correctAnswers.value
          : this.correctAnswers,
      totalQuestions: data.totalQuestions.present
          ? data.totalQuestions.value
          : this.totalQuestions,
      responseLogsJson: data.responseLogsJson.present
          ? data.responseLogsJson.value
          : this.responseLogsJson,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PendingResult(')
          ..write('id: $id, ')
          ..write('gameId: $gameId, ')
          ..write('title: $title, ')
          ..write('gameType: $gameType, ')
          ..write('startDate: $startDate, ')
          ..write('correctAnswers: $correctAnswers, ')
          ..write('totalQuestions: $totalQuestions, ')
          ..write('responseLogsJson: $responseLogsJson, ')
          ..write('attempts: $attempts, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    gameId,
    title,
    gameType,
    startDate,
    correctAnswers,
    totalQuestions,
    responseLogsJson,
    attempts,
    completedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PendingResult &&
          other.id == this.id &&
          other.gameId == this.gameId &&
          other.title == this.title &&
          other.gameType == this.gameType &&
          other.startDate == this.startDate &&
          other.correctAnswers == this.correctAnswers &&
          other.totalQuestions == this.totalQuestions &&
          other.responseLogsJson == this.responseLogsJson &&
          other.attempts == this.attempts &&
          other.completedAt == this.completedAt);
}

class PendingResultsCompanion extends UpdateCompanion<PendingResult> {
  final Value<int> id;
  final Value<int> gameId;
  final Value<String> title;
  final Value<String> gameType;
  final Value<String> startDate;
  final Value<int> correctAnswers;
  final Value<int> totalQuestions;
  final Value<String> responseLogsJson;
  final Value<int> attempts;
  final Value<DateTime> completedAt;
  const PendingResultsCompanion({
    this.id = const Value.absent(),
    this.gameId = const Value.absent(),
    this.title = const Value.absent(),
    this.gameType = const Value.absent(),
    this.startDate = const Value.absent(),
    this.correctAnswers = const Value.absent(),
    this.totalQuestions = const Value.absent(),
    this.responseLogsJson = const Value.absent(),
    this.attempts = const Value.absent(),
    this.completedAt = const Value.absent(),
  });
  PendingResultsCompanion.insert({
    this.id = const Value.absent(),
    required int gameId,
    required String title,
    required String gameType,
    required String startDate,
    required int correctAnswers,
    required int totalQuestions,
    required String responseLogsJson,
    this.attempts = const Value.absent(),
    required DateTime completedAt,
  }) : gameId = Value(gameId),
       title = Value(title),
       gameType = Value(gameType),
       startDate = Value(startDate),
       correctAnswers = Value(correctAnswers),
       totalQuestions = Value(totalQuestions),
       responseLogsJson = Value(responseLogsJson),
       completedAt = Value(completedAt);
  static Insertable<PendingResult> custom({
    Expression<int>? id,
    Expression<int>? gameId,
    Expression<String>? title,
    Expression<String>? gameType,
    Expression<String>? startDate,
    Expression<int>? correctAnswers,
    Expression<int>? totalQuestions,
    Expression<String>? responseLogsJson,
    Expression<int>? attempts,
    Expression<DateTime>? completedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (gameId != null) 'game_id': gameId,
      if (title != null) 'title': title,
      if (gameType != null) 'game_type': gameType,
      if (startDate != null) 'start_date': startDate,
      if (correctAnswers != null) 'correct_answers': correctAnswers,
      if (totalQuestions != null) 'total_questions': totalQuestions,
      if (responseLogsJson != null) 'response_logs_json': responseLogsJson,
      if (attempts != null) 'attempts': attempts,
      if (completedAt != null) 'completed_at': completedAt,
    });
  }

  PendingResultsCompanion copyWith({
    Value<int>? id,
    Value<int>? gameId,
    Value<String>? title,
    Value<String>? gameType,
    Value<String>? startDate,
    Value<int>? correctAnswers,
    Value<int>? totalQuestions,
    Value<String>? responseLogsJson,
    Value<int>? attempts,
    Value<DateTime>? completedAt,
  }) {
    return PendingResultsCompanion(
      id: id ?? this.id,
      gameId: gameId ?? this.gameId,
      title: title ?? this.title,
      gameType: gameType ?? this.gameType,
      startDate: startDate ?? this.startDate,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      responseLogsJson: responseLogsJson ?? this.responseLogsJson,
      attempts: attempts ?? this.attempts,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (gameId.present) {
      map['game_id'] = Variable<int>(gameId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (gameType.present) {
      map['game_type'] = Variable<String>(gameType.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<String>(startDate.value);
    }
    if (correctAnswers.present) {
      map['correct_answers'] = Variable<int>(correctAnswers.value);
    }
    if (totalQuestions.present) {
      map['total_questions'] = Variable<int>(totalQuestions.value);
    }
    if (responseLogsJson.present) {
      map['response_logs_json'] = Variable<String>(responseLogsJson.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PendingResultsCompanion(')
          ..write('id: $id, ')
          ..write('gameId: $gameId, ')
          ..write('title: $title, ')
          ..write('gameType: $gameType, ')
          ..write('startDate: $startDate, ')
          ..write('correctAnswers: $correctAnswers, ')
          ..write('totalQuestions: $totalQuestions, ')
          ..write('responseLogsJson: $responseLogsJson, ')
          ..write('attempts: $attempts, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }
}

class $KvEntriesTable extends KvEntries
    with TableInfo<$KvEntriesTable, KvEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $KvEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'kv_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<KvEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  KvEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return KvEntry(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $KvEntriesTable createAlias(String alias) {
    return $KvEntriesTable(attachedDatabase, alias);
  }
}

class KvEntry extends DataClass implements Insertable<KvEntry> {
  final String key;
  final String value;
  final DateTime updatedAt;
  const KvEntry({
    required this.key,
    required this.value,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  KvEntriesCompanion toCompanion(bool nullToAbsent) {
    return KvEntriesCompanion(
      key: Value(key),
      value: Value(value),
      updatedAt: Value(updatedAt),
    );
  }

  factory KvEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return KvEntry(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  KvEntry copyWith({String? key, String? value, DateTime? updatedAt}) =>
      KvEntry(
        key: key ?? this.key,
        value: value ?? this.value,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  KvEntry copyWithCompanion(KvEntriesCompanion data) {
    return KvEntry(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('KvEntry(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is KvEntry &&
          other.key == this.key &&
          other.value == this.value &&
          other.updatedAt == this.updatedAt);
}

class KvEntriesCompanion extends UpdateCompanion<KvEntry> {
  final Value<String> key;
  final Value<String> value;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const KvEntriesCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  KvEntriesCompanion.insert({
    required String key,
    required String value,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value),
       updatedAt = Value(updatedAt);
  static Insertable<KvEntry> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  KvEntriesCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return KvEntriesCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('KvEntriesCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedMediaTable extends CachedMedia
    with TableInfo<$CachedMediaTable, CachedMediaData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedMediaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceUrlMeta = const VerificationMeta(
    'sourceUrl',
  );
  @override
  late final GeneratedColumn<String> sourceUrl = GeneratedColumn<String>(
    'source_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _relativePathMeta = const VerificationMeta(
    'relativePath',
  );
  @override
  late final GeneratedColumn<String> relativePath = GeneratedColumn<String>(
    'relative_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _byteSizeMeta = const VerificationMeta(
    'byteSize',
  );
  @override
  late final GeneratedColumn<int> byteSize = GeneratedColumn<int>(
    'byte_size',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _downloadedAtMeta = const VerificationMeta(
    'downloadedAt',
  );
  @override
  late final GeneratedColumn<DateTime> downloadedAt = GeneratedColumn<DateTime>(
    'downloaded_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    url,
    sourceUrl,
    relativePath,
    byteSize,
    kind,
    downloadedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_media';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedMediaData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('source_url')) {
      context.handle(
        _sourceUrlMeta,
        sourceUrl.isAcceptableOrUnknown(data['source_url']!, _sourceUrlMeta),
      );
    }
    if (data.containsKey('relative_path')) {
      context.handle(
        _relativePathMeta,
        relativePath.isAcceptableOrUnknown(
          data['relative_path']!,
          _relativePathMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_relativePathMeta);
    }
    if (data.containsKey('byte_size')) {
      context.handle(
        _byteSizeMeta,
        byteSize.isAcceptableOrUnknown(data['byte_size']!, _byteSizeMeta),
      );
    } else if (isInserting) {
      context.missing(_byteSizeMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('downloaded_at')) {
      context.handle(
        _downloadedAtMeta,
        downloadedAt.isAcceptableOrUnknown(
          data['downloaded_at']!,
          _downloadedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_downloadedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {url};
  @override
  CachedMediaData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedMediaData(
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      )!,
      sourceUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_url'],
      ),
      relativePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}relative_path'],
      )!,
      byteSize: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}byte_size'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      downloadedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}downloaded_at'],
      )!,
    );
  }

  @override
  $CachedMediaTable createAlias(String alias) {
    return $CachedMediaTable(attachedDatabase, alias);
  }
}

class CachedMediaData extends DataClass implements Insertable<CachedMediaData> {
  final String url;
  final String? sourceUrl;
  final String relativePath;
  final int byteSize;
  final String kind;
  final DateTime downloadedAt;
  const CachedMediaData({
    required this.url,
    this.sourceUrl,
    required this.relativePath,
    required this.byteSize,
    required this.kind,
    required this.downloadedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['url'] = Variable<String>(url);
    if (!nullToAbsent || sourceUrl != null) {
      map['source_url'] = Variable<String>(sourceUrl);
    }
    map['relative_path'] = Variable<String>(relativePath);
    map['byte_size'] = Variable<int>(byteSize);
    map['kind'] = Variable<String>(kind);
    map['downloaded_at'] = Variable<DateTime>(downloadedAt);
    return map;
  }

  CachedMediaCompanion toCompanion(bool nullToAbsent) {
    return CachedMediaCompanion(
      url: Value(url),
      sourceUrl: sourceUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceUrl),
      relativePath: Value(relativePath),
      byteSize: Value(byteSize),
      kind: Value(kind),
      downloadedAt: Value(downloadedAt),
    );
  }

  factory CachedMediaData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedMediaData(
      url: serializer.fromJson<String>(json['url']),
      sourceUrl: serializer.fromJson<String?>(json['sourceUrl']),
      relativePath: serializer.fromJson<String>(json['relativePath']),
      byteSize: serializer.fromJson<int>(json['byteSize']),
      kind: serializer.fromJson<String>(json['kind']),
      downloadedAt: serializer.fromJson<DateTime>(json['downloadedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'url': serializer.toJson<String>(url),
      'sourceUrl': serializer.toJson<String?>(sourceUrl),
      'relativePath': serializer.toJson<String>(relativePath),
      'byteSize': serializer.toJson<int>(byteSize),
      'kind': serializer.toJson<String>(kind),
      'downloadedAt': serializer.toJson<DateTime>(downloadedAt),
    };
  }

  CachedMediaData copyWith({
    String? url,
    Value<String?> sourceUrl = const Value.absent(),
    String? relativePath,
    int? byteSize,
    String? kind,
    DateTime? downloadedAt,
  }) => CachedMediaData(
    url: url ?? this.url,
    sourceUrl: sourceUrl.present ? sourceUrl.value : this.sourceUrl,
    relativePath: relativePath ?? this.relativePath,
    byteSize: byteSize ?? this.byteSize,
    kind: kind ?? this.kind,
    downloadedAt: downloadedAt ?? this.downloadedAt,
  );
  CachedMediaData copyWithCompanion(CachedMediaCompanion data) {
    return CachedMediaData(
      url: data.url.present ? data.url.value : this.url,
      sourceUrl: data.sourceUrl.present ? data.sourceUrl.value : this.sourceUrl,
      relativePath: data.relativePath.present
          ? data.relativePath.value
          : this.relativePath,
      byteSize: data.byteSize.present ? data.byteSize.value : this.byteSize,
      kind: data.kind.present ? data.kind.value : this.kind,
      downloadedAt: data.downloadedAt.present
          ? data.downloadedAt.value
          : this.downloadedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedMediaData(')
          ..write('url: $url, ')
          ..write('sourceUrl: $sourceUrl, ')
          ..write('relativePath: $relativePath, ')
          ..write('byteSize: $byteSize, ')
          ..write('kind: $kind, ')
          ..write('downloadedAt: $downloadedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(url, sourceUrl, relativePath, byteSize, kind, downloadedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedMediaData &&
          other.url == this.url &&
          other.sourceUrl == this.sourceUrl &&
          other.relativePath == this.relativePath &&
          other.byteSize == this.byteSize &&
          other.kind == this.kind &&
          other.downloadedAt == this.downloadedAt);
}

class CachedMediaCompanion extends UpdateCompanion<CachedMediaData> {
  final Value<String> url;
  final Value<String?> sourceUrl;
  final Value<String> relativePath;
  final Value<int> byteSize;
  final Value<String> kind;
  final Value<DateTime> downloadedAt;
  final Value<int> rowid;
  const CachedMediaCompanion({
    this.url = const Value.absent(),
    this.sourceUrl = const Value.absent(),
    this.relativePath = const Value.absent(),
    this.byteSize = const Value.absent(),
    this.kind = const Value.absent(),
    this.downloadedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedMediaCompanion.insert({
    required String url,
    this.sourceUrl = const Value.absent(),
    required String relativePath,
    required int byteSize,
    required String kind,
    required DateTime downloadedAt,
    this.rowid = const Value.absent(),
  }) : url = Value(url),
       relativePath = Value(relativePath),
       byteSize = Value(byteSize),
       kind = Value(kind),
       downloadedAt = Value(downloadedAt);
  static Insertable<CachedMediaData> custom({
    Expression<String>? url,
    Expression<String>? sourceUrl,
    Expression<String>? relativePath,
    Expression<int>? byteSize,
    Expression<String>? kind,
    Expression<DateTime>? downloadedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (url != null) 'url': url,
      if (sourceUrl != null) 'source_url': sourceUrl,
      if (relativePath != null) 'relative_path': relativePath,
      if (byteSize != null) 'byte_size': byteSize,
      if (kind != null) 'kind': kind,
      if (downloadedAt != null) 'downloaded_at': downloadedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedMediaCompanion copyWith({
    Value<String>? url,
    Value<String?>? sourceUrl,
    Value<String>? relativePath,
    Value<int>? byteSize,
    Value<String>? kind,
    Value<DateTime>? downloadedAt,
    Value<int>? rowid,
  }) {
    return CachedMediaCompanion(
      url: url ?? this.url,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      relativePath: relativePath ?? this.relativePath,
      byteSize: byteSize ?? this.byteSize,
      kind: kind ?? this.kind,
      downloadedAt: downloadedAt ?? this.downloadedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (sourceUrl.present) {
      map['source_url'] = Variable<String>(sourceUrl.value);
    }
    if (relativePath.present) {
      map['relative_path'] = Variable<String>(relativePath.value);
    }
    if (byteSize.present) {
      map['byte_size'] = Variable<int>(byteSize.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (downloadedAt.present) {
      map['downloaded_at'] = Variable<DateTime>(downloadedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedMediaCompanion(')
          ..write('url: $url, ')
          ..write('sourceUrl: $sourceUrl, ')
          ..write('relativePath: $relativePath, ')
          ..write('byteSize: $byteSize, ')
          ..write('kind: $kind, ')
          ..write('downloadedAt: $downloadedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedWordsTable extends CachedWords
    with TableInfo<$CachedWordsTable, CachedWord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedWordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _spanishWordMeta = const VerificationMeta(
    'spanishWord',
  );
  @override
  late final GeneratedColumn<String> spanishWord = GeneratedColumn<String>(
    'spanish_word',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mazahuaWordMeta = const VerificationMeta(
    'mazahuaWord',
  );
  @override
  late final GeneratedColumn<String> mazahuaWord = GeneratedColumn<String>(
    'mazahua_word',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _spanishPronunciationMeta =
      const VerificationMeta('spanishPronunciation');
  @override
  late final GeneratedColumn<String> spanishPronunciation =
      GeneratedColumn<String>(
        'spanish_pronunciation',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _mazahuaPronunciationMeta =
      const VerificationMeta('mazahuaPronunciation');
  @override
  late final GeneratedColumn<String> mazahuaPronunciation =
      GeneratedColumn<String>(
        'mazahua_pronunciation',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _imagePathMeta = const VerificationMeta(
    'imagePath',
  );
  @override
  late final GeneratedColumn<String> imagePath = GeneratedColumn<String>(
    'image_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _audioPathMeta = const VerificationMeta(
    'audioPath',
  );
  @override
  late final GeneratedColumn<String> audioPath = GeneratedColumn<String>(
    'audio_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pronunciationMeta = const VerificationMeta(
    'pronunciation',
  );
  @override
  late final GeneratedColumn<bool> pronunciation = GeneratedColumn<bool>(
    'pronunciation',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("pronunciation" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    spanishWord,
    mazahuaWord,
    spanishPronunciation,
    mazahuaPronunciation,
    category,
    imagePath,
    audioPath,
    pronunciation,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_words';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedWord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('spanish_word')) {
      context.handle(
        _spanishWordMeta,
        spanishWord.isAcceptableOrUnknown(
          data['spanish_word']!,
          _spanishWordMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_spanishWordMeta);
    }
    if (data.containsKey('mazahua_word')) {
      context.handle(
        _mazahuaWordMeta,
        mazahuaWord.isAcceptableOrUnknown(
          data['mazahua_word']!,
          _mazahuaWordMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_mazahuaWordMeta);
    }
    if (data.containsKey('spanish_pronunciation')) {
      context.handle(
        _spanishPronunciationMeta,
        spanishPronunciation.isAcceptableOrUnknown(
          data['spanish_pronunciation']!,
          _spanishPronunciationMeta,
        ),
      );
    }
    if (data.containsKey('mazahua_pronunciation')) {
      context.handle(
        _mazahuaPronunciationMeta,
        mazahuaPronunciation.isAcceptableOrUnknown(
          data['mazahua_pronunciation']!,
          _mazahuaPronunciationMeta,
        ),
      );
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('image_path')) {
      context.handle(
        _imagePathMeta,
        imagePath.isAcceptableOrUnknown(data['image_path']!, _imagePathMeta),
      );
    }
    if (data.containsKey('audio_path')) {
      context.handle(
        _audioPathMeta,
        audioPath.isAcceptableOrUnknown(data['audio_path']!, _audioPathMeta),
      );
    }
    if (data.containsKey('pronunciation')) {
      context.handle(
        _pronunciationMeta,
        pronunciation.isAcceptableOrUnknown(
          data['pronunciation']!,
          _pronunciationMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedWord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedWord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      spanishWord: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}spanish_word'],
      )!,
      mazahuaWord: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mazahua_word'],
      )!,
      spanishPronunciation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}spanish_pronunciation'],
      ),
      mazahuaPronunciation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mazahua_pronunciation'],
      ),
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      imagePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_path'],
      ),
      audioPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}audio_path'],
      ),
      pronunciation: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}pronunciation'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $CachedWordsTable createAlias(String alias) {
    return $CachedWordsTable(attachedDatabase, alias);
  }
}

class CachedWord extends DataClass implements Insertable<CachedWord> {
  final int id;
  final String spanishWord;
  final String mazahuaWord;
  final String? spanishPronunciation;
  final String? mazahuaPronunciation;
  final String category;
  final String? imagePath;
  final String? audioPath;
  final bool pronunciation;
  final DateTime updatedAt;
  const CachedWord({
    required this.id,
    required this.spanishWord,
    required this.mazahuaWord,
    this.spanishPronunciation,
    this.mazahuaPronunciation,
    required this.category,
    this.imagePath,
    this.audioPath,
    required this.pronunciation,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['spanish_word'] = Variable<String>(spanishWord);
    map['mazahua_word'] = Variable<String>(mazahuaWord);
    if (!nullToAbsent || spanishPronunciation != null) {
      map['spanish_pronunciation'] = Variable<String>(spanishPronunciation);
    }
    if (!nullToAbsent || mazahuaPronunciation != null) {
      map['mazahua_pronunciation'] = Variable<String>(mazahuaPronunciation);
    }
    map['category'] = Variable<String>(category);
    if (!nullToAbsent || imagePath != null) {
      map['image_path'] = Variable<String>(imagePath);
    }
    if (!nullToAbsent || audioPath != null) {
      map['audio_path'] = Variable<String>(audioPath);
    }
    map['pronunciation'] = Variable<bool>(pronunciation);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CachedWordsCompanion toCompanion(bool nullToAbsent) {
    return CachedWordsCompanion(
      id: Value(id),
      spanishWord: Value(spanishWord),
      mazahuaWord: Value(mazahuaWord),
      spanishPronunciation: spanishPronunciation == null && nullToAbsent
          ? const Value.absent()
          : Value(spanishPronunciation),
      mazahuaPronunciation: mazahuaPronunciation == null && nullToAbsent
          ? const Value.absent()
          : Value(mazahuaPronunciation),
      category: Value(category),
      imagePath: imagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(imagePath),
      audioPath: audioPath == null && nullToAbsent
          ? const Value.absent()
          : Value(audioPath),
      pronunciation: Value(pronunciation),
      updatedAt: Value(updatedAt),
    );
  }

  factory CachedWord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedWord(
      id: serializer.fromJson<int>(json['id']),
      spanishWord: serializer.fromJson<String>(json['spanishWord']),
      mazahuaWord: serializer.fromJson<String>(json['mazahuaWord']),
      spanishPronunciation: serializer.fromJson<String?>(
        json['spanishPronunciation'],
      ),
      mazahuaPronunciation: serializer.fromJson<String?>(
        json['mazahuaPronunciation'],
      ),
      category: serializer.fromJson<String>(json['category']),
      imagePath: serializer.fromJson<String?>(json['imagePath']),
      audioPath: serializer.fromJson<String?>(json['audioPath']),
      pronunciation: serializer.fromJson<bool>(json['pronunciation']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'spanishWord': serializer.toJson<String>(spanishWord),
      'mazahuaWord': serializer.toJson<String>(mazahuaWord),
      'spanishPronunciation': serializer.toJson<String?>(spanishPronunciation),
      'mazahuaPronunciation': serializer.toJson<String?>(mazahuaPronunciation),
      'category': serializer.toJson<String>(category),
      'imagePath': serializer.toJson<String?>(imagePath),
      'audioPath': serializer.toJson<String?>(audioPath),
      'pronunciation': serializer.toJson<bool>(pronunciation),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CachedWord copyWith({
    int? id,
    String? spanishWord,
    String? mazahuaWord,
    Value<String?> spanishPronunciation = const Value.absent(),
    Value<String?> mazahuaPronunciation = const Value.absent(),
    String? category,
    Value<String?> imagePath = const Value.absent(),
    Value<String?> audioPath = const Value.absent(),
    bool? pronunciation,
    DateTime? updatedAt,
  }) => CachedWord(
    id: id ?? this.id,
    spanishWord: spanishWord ?? this.spanishWord,
    mazahuaWord: mazahuaWord ?? this.mazahuaWord,
    spanishPronunciation: spanishPronunciation.present
        ? spanishPronunciation.value
        : this.spanishPronunciation,
    mazahuaPronunciation: mazahuaPronunciation.present
        ? mazahuaPronunciation.value
        : this.mazahuaPronunciation,
    category: category ?? this.category,
    imagePath: imagePath.present ? imagePath.value : this.imagePath,
    audioPath: audioPath.present ? audioPath.value : this.audioPath,
    pronunciation: pronunciation ?? this.pronunciation,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  CachedWord copyWithCompanion(CachedWordsCompanion data) {
    return CachedWord(
      id: data.id.present ? data.id.value : this.id,
      spanishWord: data.spanishWord.present
          ? data.spanishWord.value
          : this.spanishWord,
      mazahuaWord: data.mazahuaWord.present
          ? data.mazahuaWord.value
          : this.mazahuaWord,
      spanishPronunciation: data.spanishPronunciation.present
          ? data.spanishPronunciation.value
          : this.spanishPronunciation,
      mazahuaPronunciation: data.mazahuaPronunciation.present
          ? data.mazahuaPronunciation.value
          : this.mazahuaPronunciation,
      category: data.category.present ? data.category.value : this.category,
      imagePath: data.imagePath.present ? data.imagePath.value : this.imagePath,
      audioPath: data.audioPath.present ? data.audioPath.value : this.audioPath,
      pronunciation: data.pronunciation.present
          ? data.pronunciation.value
          : this.pronunciation,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedWord(')
          ..write('id: $id, ')
          ..write('spanishWord: $spanishWord, ')
          ..write('mazahuaWord: $mazahuaWord, ')
          ..write('spanishPronunciation: $spanishPronunciation, ')
          ..write('mazahuaPronunciation: $mazahuaPronunciation, ')
          ..write('category: $category, ')
          ..write('imagePath: $imagePath, ')
          ..write('audioPath: $audioPath, ')
          ..write('pronunciation: $pronunciation, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    spanishWord,
    mazahuaWord,
    spanishPronunciation,
    mazahuaPronunciation,
    category,
    imagePath,
    audioPath,
    pronunciation,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedWord &&
          other.id == this.id &&
          other.spanishWord == this.spanishWord &&
          other.mazahuaWord == this.mazahuaWord &&
          other.spanishPronunciation == this.spanishPronunciation &&
          other.mazahuaPronunciation == this.mazahuaPronunciation &&
          other.category == this.category &&
          other.imagePath == this.imagePath &&
          other.audioPath == this.audioPath &&
          other.pronunciation == this.pronunciation &&
          other.updatedAt == this.updatedAt);
}

class CachedWordsCompanion extends UpdateCompanion<CachedWord> {
  final Value<int> id;
  final Value<String> spanishWord;
  final Value<String> mazahuaWord;
  final Value<String?> spanishPronunciation;
  final Value<String?> mazahuaPronunciation;
  final Value<String> category;
  final Value<String?> imagePath;
  final Value<String?> audioPath;
  final Value<bool> pronunciation;
  final Value<DateTime> updatedAt;
  const CachedWordsCompanion({
    this.id = const Value.absent(),
    this.spanishWord = const Value.absent(),
    this.mazahuaWord = const Value.absent(),
    this.spanishPronunciation = const Value.absent(),
    this.mazahuaPronunciation = const Value.absent(),
    this.category = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.audioPath = const Value.absent(),
    this.pronunciation = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  CachedWordsCompanion.insert({
    this.id = const Value.absent(),
    required String spanishWord,
    required String mazahuaWord,
    this.spanishPronunciation = const Value.absent(),
    this.mazahuaPronunciation = const Value.absent(),
    required String category,
    this.imagePath = const Value.absent(),
    this.audioPath = const Value.absent(),
    this.pronunciation = const Value.absent(),
    required DateTime updatedAt,
  }) : spanishWord = Value(spanishWord),
       mazahuaWord = Value(mazahuaWord),
       category = Value(category),
       updatedAt = Value(updatedAt);
  static Insertable<CachedWord> custom({
    Expression<int>? id,
    Expression<String>? spanishWord,
    Expression<String>? mazahuaWord,
    Expression<String>? spanishPronunciation,
    Expression<String>? mazahuaPronunciation,
    Expression<String>? category,
    Expression<String>? imagePath,
    Expression<String>? audioPath,
    Expression<bool>? pronunciation,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (spanishWord != null) 'spanish_word': spanishWord,
      if (mazahuaWord != null) 'mazahua_word': mazahuaWord,
      if (spanishPronunciation != null)
        'spanish_pronunciation': spanishPronunciation,
      if (mazahuaPronunciation != null)
        'mazahua_pronunciation': mazahuaPronunciation,
      if (category != null) 'category': category,
      if (imagePath != null) 'image_path': imagePath,
      if (audioPath != null) 'audio_path': audioPath,
      if (pronunciation != null) 'pronunciation': pronunciation,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  CachedWordsCompanion copyWith({
    Value<int>? id,
    Value<String>? spanishWord,
    Value<String>? mazahuaWord,
    Value<String?>? spanishPronunciation,
    Value<String?>? mazahuaPronunciation,
    Value<String>? category,
    Value<String?>? imagePath,
    Value<String?>? audioPath,
    Value<bool>? pronunciation,
    Value<DateTime>? updatedAt,
  }) {
    return CachedWordsCompanion(
      id: id ?? this.id,
      spanishWord: spanishWord ?? this.spanishWord,
      mazahuaWord: mazahuaWord ?? this.mazahuaWord,
      spanishPronunciation: spanishPronunciation ?? this.spanishPronunciation,
      mazahuaPronunciation: mazahuaPronunciation ?? this.mazahuaPronunciation,
      category: category ?? this.category,
      imagePath: imagePath ?? this.imagePath,
      audioPath: audioPath ?? this.audioPath,
      pronunciation: pronunciation ?? this.pronunciation,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (spanishWord.present) {
      map['spanish_word'] = Variable<String>(spanishWord.value);
    }
    if (mazahuaWord.present) {
      map['mazahua_word'] = Variable<String>(mazahuaWord.value);
    }
    if (spanishPronunciation.present) {
      map['spanish_pronunciation'] = Variable<String>(
        spanishPronunciation.value,
      );
    }
    if (mazahuaPronunciation.present) {
      map['mazahua_pronunciation'] = Variable<String>(
        mazahuaPronunciation.value,
      );
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (imagePath.present) {
      map['image_path'] = Variable<String>(imagePath.value);
    }
    if (audioPath.present) {
      map['audio_path'] = Variable<String>(audioPath.value);
    }
    if (pronunciation.present) {
      map['pronunciation'] = Variable<bool>(pronunciation.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedWordsCompanion(')
          ..write('id: $id, ')
          ..write('spanishWord: $spanishWord, ')
          ..write('mazahuaWord: $mazahuaWord, ')
          ..write('spanishPronunciation: $spanishPronunciation, ')
          ..write('mazahuaPronunciation: $mazahuaPronunciation, ')
          ..write('category: $category, ')
          ..write('imagePath: $imagePath, ')
          ..write('audioPath: $audioPath, ')
          ..write('pronunciation: $pronunciation, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $CompletedGamesTable extends CompletedGames
    with TableInfo<$CompletedGamesTable, CompletedGame> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CompletedGamesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _gameIdMeta = const VerificationMeta('gameId');
  @override
  late final GeneratedColumn<int> gameId = GeneratedColumn<int>(
    'game_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _topicMeta = const VerificationMeta('topic');
  @override
  late final GeneratedColumn<String> topic = GeneratedColumn<String>(
    'topic',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _correctAnswersMeta = const VerificationMeta(
    'correctAnswers',
  );
  @override
  late final GeneratedColumn<int> correctAnswers = GeneratedColumn<int>(
    'correct_answers',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalQuestionsMeta = const VerificationMeta(
    'totalQuestions',
  );
  @override
  late final GeneratedColumn<int> totalQuestions = GeneratedColumn<int>(
    'total_questions',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _starsMeta = const VerificationMeta('stars');
  @override
  late final GeneratedColumn<int> stars = GeneratedColumn<int>(
    'stars',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    gameId,
    topic,
    correctAnswers,
    totalQuestions,
    stars,
    completedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'completed_games';
  @override
  VerificationContext validateIntegrity(
    Insertable<CompletedGame> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('game_id')) {
      context.handle(
        _gameIdMeta,
        gameId.isAcceptableOrUnknown(data['game_id']!, _gameIdMeta),
      );
    }
    if (data.containsKey('topic')) {
      context.handle(
        _topicMeta,
        topic.isAcceptableOrUnknown(data['topic']!, _topicMeta),
      );
    }
    if (data.containsKey('correct_answers')) {
      context.handle(
        _correctAnswersMeta,
        correctAnswers.isAcceptableOrUnknown(
          data['correct_answers']!,
          _correctAnswersMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_correctAnswersMeta);
    }
    if (data.containsKey('total_questions')) {
      context.handle(
        _totalQuestionsMeta,
        totalQuestions.isAcceptableOrUnknown(
          data['total_questions']!,
          _totalQuestionsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalQuestionsMeta);
    }
    if (data.containsKey('stars')) {
      context.handle(
        _starsMeta,
        stars.isAcceptableOrUnknown(data['stars']!, _starsMeta),
      );
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_completedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {gameId};
  @override
  CompletedGame map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CompletedGame(
      gameId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}game_id'],
      )!,
      topic: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}topic'],
      ),
      correctAnswers: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}correct_answers'],
      )!,
      totalQuestions: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_questions'],
      )!,
      stars: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}stars'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      )!,
    );
  }

  @override
  $CompletedGamesTable createAlias(String alias) {
    return $CompletedGamesTable(attachedDatabase, alias);
  }
}

class CompletedGame extends DataClass implements Insertable<CompletedGame> {
  final int gameId;
  final String? topic;
  final int correctAnswers;
  final int totalQuestions;

  /// Mejores estrellas conseguidas en esta actividad (0-5, ver
  /// `lib/core/stars.dart`). `recordGameCompletion` nunca las hace bajar:
  /// rejugar peor no debe restarle progreso al anillo del mapa.
  final int stars;
  final DateTime completedAt;
  const CompletedGame({
    required this.gameId,
    this.topic,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.stars,
    required this.completedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['game_id'] = Variable<int>(gameId);
    if (!nullToAbsent || topic != null) {
      map['topic'] = Variable<String>(topic);
    }
    map['correct_answers'] = Variable<int>(correctAnswers);
    map['total_questions'] = Variable<int>(totalQuestions);
    map['stars'] = Variable<int>(stars);
    map['completed_at'] = Variable<DateTime>(completedAt);
    return map;
  }

  CompletedGamesCompanion toCompanion(bool nullToAbsent) {
    return CompletedGamesCompanion(
      gameId: Value(gameId),
      topic: topic == null && nullToAbsent
          ? const Value.absent()
          : Value(topic),
      correctAnswers: Value(correctAnswers),
      totalQuestions: Value(totalQuestions),
      stars: Value(stars),
      completedAt: Value(completedAt),
    );
  }

  factory CompletedGame.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CompletedGame(
      gameId: serializer.fromJson<int>(json['gameId']),
      topic: serializer.fromJson<String?>(json['topic']),
      correctAnswers: serializer.fromJson<int>(json['correctAnswers']),
      totalQuestions: serializer.fromJson<int>(json['totalQuestions']),
      stars: serializer.fromJson<int>(json['stars']),
      completedAt: serializer.fromJson<DateTime>(json['completedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'gameId': serializer.toJson<int>(gameId),
      'topic': serializer.toJson<String?>(topic),
      'correctAnswers': serializer.toJson<int>(correctAnswers),
      'totalQuestions': serializer.toJson<int>(totalQuestions),
      'stars': serializer.toJson<int>(stars),
      'completedAt': serializer.toJson<DateTime>(completedAt),
    };
  }

  CompletedGame copyWith({
    int? gameId,
    Value<String?> topic = const Value.absent(),
    int? correctAnswers,
    int? totalQuestions,
    int? stars,
    DateTime? completedAt,
  }) => CompletedGame(
    gameId: gameId ?? this.gameId,
    topic: topic.present ? topic.value : this.topic,
    correctAnswers: correctAnswers ?? this.correctAnswers,
    totalQuestions: totalQuestions ?? this.totalQuestions,
    stars: stars ?? this.stars,
    completedAt: completedAt ?? this.completedAt,
  );
  CompletedGame copyWithCompanion(CompletedGamesCompanion data) {
    return CompletedGame(
      gameId: data.gameId.present ? data.gameId.value : this.gameId,
      topic: data.topic.present ? data.topic.value : this.topic,
      correctAnswers: data.correctAnswers.present
          ? data.correctAnswers.value
          : this.correctAnswers,
      totalQuestions: data.totalQuestions.present
          ? data.totalQuestions.value
          : this.totalQuestions,
      stars: data.stars.present ? data.stars.value : this.stars,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CompletedGame(')
          ..write('gameId: $gameId, ')
          ..write('topic: $topic, ')
          ..write('correctAnswers: $correctAnswers, ')
          ..write('totalQuestions: $totalQuestions, ')
          ..write('stars: $stars, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    gameId,
    topic,
    correctAnswers,
    totalQuestions,
    stars,
    completedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CompletedGame &&
          other.gameId == this.gameId &&
          other.topic == this.topic &&
          other.correctAnswers == this.correctAnswers &&
          other.totalQuestions == this.totalQuestions &&
          other.stars == this.stars &&
          other.completedAt == this.completedAt);
}

class CompletedGamesCompanion extends UpdateCompanion<CompletedGame> {
  final Value<int> gameId;
  final Value<String?> topic;
  final Value<int> correctAnswers;
  final Value<int> totalQuestions;
  final Value<int> stars;
  final Value<DateTime> completedAt;
  const CompletedGamesCompanion({
    this.gameId = const Value.absent(),
    this.topic = const Value.absent(),
    this.correctAnswers = const Value.absent(),
    this.totalQuestions = const Value.absent(),
    this.stars = const Value.absent(),
    this.completedAt = const Value.absent(),
  });
  CompletedGamesCompanion.insert({
    this.gameId = const Value.absent(),
    this.topic = const Value.absent(),
    required int correctAnswers,
    required int totalQuestions,
    this.stars = const Value.absent(),
    required DateTime completedAt,
  }) : correctAnswers = Value(correctAnswers),
       totalQuestions = Value(totalQuestions),
       completedAt = Value(completedAt);
  static Insertable<CompletedGame> custom({
    Expression<int>? gameId,
    Expression<String>? topic,
    Expression<int>? correctAnswers,
    Expression<int>? totalQuestions,
    Expression<int>? stars,
    Expression<DateTime>? completedAt,
  }) {
    return RawValuesInsertable({
      if (gameId != null) 'game_id': gameId,
      if (topic != null) 'topic': topic,
      if (correctAnswers != null) 'correct_answers': correctAnswers,
      if (totalQuestions != null) 'total_questions': totalQuestions,
      if (stars != null) 'stars': stars,
      if (completedAt != null) 'completed_at': completedAt,
    });
  }

  CompletedGamesCompanion copyWith({
    Value<int>? gameId,
    Value<String?>? topic,
    Value<int>? correctAnswers,
    Value<int>? totalQuestions,
    Value<int>? stars,
    Value<DateTime>? completedAt,
  }) {
    return CompletedGamesCompanion(
      gameId: gameId ?? this.gameId,
      topic: topic ?? this.topic,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      stars: stars ?? this.stars,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (gameId.present) {
      map['game_id'] = Variable<int>(gameId.value);
    }
    if (topic.present) {
      map['topic'] = Variable<String>(topic.value);
    }
    if (correctAnswers.present) {
      map['correct_answers'] = Variable<int>(correctAnswers.value);
    }
    if (totalQuestions.present) {
      map['total_questions'] = Variable<int>(totalQuestions.value);
    }
    if (stars.present) {
      map['stars'] = Variable<int>(stars.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CompletedGamesCompanion(')
          ..write('gameId: $gameId, ')
          ..write('topic: $topic, ')
          ..write('correctAnswers: $correctAnswers, ')
          ..write('totalQuestions: $totalQuestions, ')
          ..write('stars: $stars, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }
}

class $ResourceUpdatesTable extends ResourceUpdates
    with TableInfo<$ResourceUpdatesTable, ResourceUpdate> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ResourceUpdatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _resourceMeta = const VerificationMeta(
    'resource',
  );
  @override
  late final GeneratedColumn<String> resource = GeneratedColumn<String>(
    'resource',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastUpdatedAtMeta = const VerificationMeta(
    'lastUpdatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastUpdatedAt =
      GeneratedColumn<DateTime>(
        'last_updated_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lastChangeTypeMeta = const VerificationMeta(
    'lastChangeType',
  );
  @override
  late final GeneratedColumn<String> lastChangeType = GeneratedColumn<String>(
    'last_change_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastResourceIdMeta = const VerificationMeta(
    'lastResourceId',
  );
  @override
  late final GeneratedColumn<int> lastResourceId = GeneratedColumn<int>(
    'last_resource_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncCursorMeta = const VerificationMeta(
    'syncCursor',
  );
  @override
  late final GeneratedColumn<String> syncCursor = GeneratedColumn<String>(
    'sync_cursor',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    resource,
    lastUpdatedAt,
    lastChangeType,
    lastResourceId,
    syncCursor,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'resource_updates';
  @override
  VerificationContext validateIntegrity(
    Insertable<ResourceUpdate> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('resource')) {
      context.handle(
        _resourceMeta,
        resource.isAcceptableOrUnknown(data['resource']!, _resourceMeta),
      );
    } else if (isInserting) {
      context.missing(_resourceMeta);
    }
    if (data.containsKey('last_updated_at')) {
      context.handle(
        _lastUpdatedAtMeta,
        lastUpdatedAt.isAcceptableOrUnknown(
          data['last_updated_at']!,
          _lastUpdatedAtMeta,
        ),
      );
    }
    if (data.containsKey('last_change_type')) {
      context.handle(
        _lastChangeTypeMeta,
        lastChangeType.isAcceptableOrUnknown(
          data['last_change_type']!,
          _lastChangeTypeMeta,
        ),
      );
    }
    if (data.containsKey('last_resource_id')) {
      context.handle(
        _lastResourceIdMeta,
        lastResourceId.isAcceptableOrUnknown(
          data['last_resource_id']!,
          _lastResourceIdMeta,
        ),
      );
    }
    if (data.containsKey('sync_cursor')) {
      context.handle(
        _syncCursorMeta,
        syncCursor.isAcceptableOrUnknown(data['sync_cursor']!, _syncCursorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {resource};
  @override
  ResourceUpdate map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ResourceUpdate(
      resource: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}resource'],
      )!,
      lastUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_updated_at'],
      ),
      lastChangeType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_change_type'],
      ),
      lastResourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_resource_id'],
      ),
      syncCursor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_cursor'],
      ),
    );
  }

  @override
  $ResourceUpdatesTable createAlias(String alias) {
    return $ResourceUpdatesTable(attachedDatabase, alias);
  }
}

class ResourceUpdate extends DataClass implements Insertable<ResourceUpdate> {
  final String resource;
  final DateTime? lastUpdatedAt;
  final String? lastChangeType;
  final int? lastResourceId;
  final String? syncCursor;
  const ResourceUpdate({
    required this.resource,
    this.lastUpdatedAt,
    this.lastChangeType,
    this.lastResourceId,
    this.syncCursor,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['resource'] = Variable<String>(resource);
    if (!nullToAbsent || lastUpdatedAt != null) {
      map['last_updated_at'] = Variable<DateTime>(lastUpdatedAt);
    }
    if (!nullToAbsent || lastChangeType != null) {
      map['last_change_type'] = Variable<String>(lastChangeType);
    }
    if (!nullToAbsent || lastResourceId != null) {
      map['last_resource_id'] = Variable<int>(lastResourceId);
    }
    if (!nullToAbsent || syncCursor != null) {
      map['sync_cursor'] = Variable<String>(syncCursor);
    }
    return map;
  }

  ResourceUpdatesCompanion toCompanion(bool nullToAbsent) {
    return ResourceUpdatesCompanion(
      resource: Value(resource),
      lastUpdatedAt: lastUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastUpdatedAt),
      lastChangeType: lastChangeType == null && nullToAbsent
          ? const Value.absent()
          : Value(lastChangeType),
      lastResourceId: lastResourceId == null && nullToAbsent
          ? const Value.absent()
          : Value(lastResourceId),
      syncCursor: syncCursor == null && nullToAbsent
          ? const Value.absent()
          : Value(syncCursor),
    );
  }

  factory ResourceUpdate.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ResourceUpdate(
      resource: serializer.fromJson<String>(json['resource']),
      lastUpdatedAt: serializer.fromJson<DateTime?>(json['lastUpdatedAt']),
      lastChangeType: serializer.fromJson<String?>(json['lastChangeType']),
      lastResourceId: serializer.fromJson<int?>(json['lastResourceId']),
      syncCursor: serializer.fromJson<String?>(json['syncCursor']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'resource': serializer.toJson<String>(resource),
      'lastUpdatedAt': serializer.toJson<DateTime?>(lastUpdatedAt),
      'lastChangeType': serializer.toJson<String?>(lastChangeType),
      'lastResourceId': serializer.toJson<int?>(lastResourceId),
      'syncCursor': serializer.toJson<String?>(syncCursor),
    };
  }

  ResourceUpdate copyWith({
    String? resource,
    Value<DateTime?> lastUpdatedAt = const Value.absent(),
    Value<String?> lastChangeType = const Value.absent(),
    Value<int?> lastResourceId = const Value.absent(),
    Value<String?> syncCursor = const Value.absent(),
  }) => ResourceUpdate(
    resource: resource ?? this.resource,
    lastUpdatedAt: lastUpdatedAt.present
        ? lastUpdatedAt.value
        : this.lastUpdatedAt,
    lastChangeType: lastChangeType.present
        ? lastChangeType.value
        : this.lastChangeType,
    lastResourceId: lastResourceId.present
        ? lastResourceId.value
        : this.lastResourceId,
    syncCursor: syncCursor.present ? syncCursor.value : this.syncCursor,
  );
  ResourceUpdate copyWithCompanion(ResourceUpdatesCompanion data) {
    return ResourceUpdate(
      resource: data.resource.present ? data.resource.value : this.resource,
      lastUpdatedAt: data.lastUpdatedAt.present
          ? data.lastUpdatedAt.value
          : this.lastUpdatedAt,
      lastChangeType: data.lastChangeType.present
          ? data.lastChangeType.value
          : this.lastChangeType,
      lastResourceId: data.lastResourceId.present
          ? data.lastResourceId.value
          : this.lastResourceId,
      syncCursor: data.syncCursor.present
          ? data.syncCursor.value
          : this.syncCursor,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ResourceUpdate(')
          ..write('resource: $resource, ')
          ..write('lastUpdatedAt: $lastUpdatedAt, ')
          ..write('lastChangeType: $lastChangeType, ')
          ..write('lastResourceId: $lastResourceId, ')
          ..write('syncCursor: $syncCursor')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    resource,
    lastUpdatedAt,
    lastChangeType,
    lastResourceId,
    syncCursor,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ResourceUpdate &&
          other.resource == this.resource &&
          other.lastUpdatedAt == this.lastUpdatedAt &&
          other.lastChangeType == this.lastChangeType &&
          other.lastResourceId == this.lastResourceId &&
          other.syncCursor == this.syncCursor);
}

class ResourceUpdatesCompanion extends UpdateCompanion<ResourceUpdate> {
  final Value<String> resource;
  final Value<DateTime?> lastUpdatedAt;
  final Value<String?> lastChangeType;
  final Value<int?> lastResourceId;
  final Value<String?> syncCursor;
  final Value<int> rowid;
  const ResourceUpdatesCompanion({
    this.resource = const Value.absent(),
    this.lastUpdatedAt = const Value.absent(),
    this.lastChangeType = const Value.absent(),
    this.lastResourceId = const Value.absent(),
    this.syncCursor = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ResourceUpdatesCompanion.insert({
    required String resource,
    this.lastUpdatedAt = const Value.absent(),
    this.lastChangeType = const Value.absent(),
    this.lastResourceId = const Value.absent(),
    this.syncCursor = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : resource = Value(resource);
  static Insertable<ResourceUpdate> custom({
    Expression<String>? resource,
    Expression<DateTime>? lastUpdatedAt,
    Expression<String>? lastChangeType,
    Expression<int>? lastResourceId,
    Expression<String>? syncCursor,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (resource != null) 'resource': resource,
      if (lastUpdatedAt != null) 'last_updated_at': lastUpdatedAt,
      if (lastChangeType != null) 'last_change_type': lastChangeType,
      if (lastResourceId != null) 'last_resource_id': lastResourceId,
      if (syncCursor != null) 'sync_cursor': syncCursor,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ResourceUpdatesCompanion copyWith({
    Value<String>? resource,
    Value<DateTime?>? lastUpdatedAt,
    Value<String?>? lastChangeType,
    Value<int?>? lastResourceId,
    Value<String?>? syncCursor,
    Value<int>? rowid,
  }) {
    return ResourceUpdatesCompanion(
      resource: resource ?? this.resource,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      lastChangeType: lastChangeType ?? this.lastChangeType,
      lastResourceId: lastResourceId ?? this.lastResourceId,
      syncCursor: syncCursor ?? this.syncCursor,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (resource.present) {
      map['resource'] = Variable<String>(resource.value);
    }
    if (lastUpdatedAt.present) {
      map['last_updated_at'] = Variable<DateTime>(lastUpdatedAt.value);
    }
    if (lastChangeType.present) {
      map['last_change_type'] = Variable<String>(lastChangeType.value);
    }
    if (lastResourceId.present) {
      map['last_resource_id'] = Variable<int>(lastResourceId.value);
    }
    if (syncCursor.present) {
      map['sync_cursor'] = Variable<String>(syncCursor.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ResourceUpdatesCompanion(')
          ..write('resource: $resource, ')
          ..write('lastUpdatedAt: $lastUpdatedAt, ')
          ..write('lastChangeType: $lastChangeType, ')
          ..write('lastResourceId: $lastResourceId, ')
          ..write('syncCursor: $syncCursor, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PendingDailyResultsTable extends PendingDailyResults
    with TableInfo<$PendingDailyResultsTable, PendingDailyResult> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PendingDailyResultsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _accountMeta = const VerificationMeta(
    'account',
  );
  @override
  late final GeneratedColumn<String> account = GeneratedColumn<String>(
    'account',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _challengeIdMeta = const VerificationMeta(
    'challengeId',
  );
  @override
  late final GeneratedColumn<int> challengeId = GeneratedColumn<int>(
    'challenge_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _challengeJsonMeta = const VerificationMeta(
    'challengeJson',
  );
  @override
  late final GeneratedColumn<String> challengeJson = GeneratedColumn<String>(
    'challenge_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _errorMeta = const VerificationMeta('error');
  @override
  late final GeneratedColumn<String> error = GeneratedColumn<String>(
    'error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _retryableMeta = const VerificationMeta(
    'retryable',
  );
  @override
  late final GeneratedColumn<bool> retryable = GeneratedColumn<bool>(
    'retryable',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("retryable" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    account,
    challengeId,
    challengeJson,
    completedAt,
    error,
    retryable,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pending_daily_results';
  @override
  VerificationContext validateIntegrity(
    Insertable<PendingDailyResult> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('account')) {
      context.handle(
        _accountMeta,
        account.isAcceptableOrUnknown(data['account']!, _accountMeta),
      );
    } else if (isInserting) {
      context.missing(_accountMeta);
    }
    if (data.containsKey('challenge_id')) {
      context.handle(
        _challengeIdMeta,
        challengeId.isAcceptableOrUnknown(
          data['challenge_id']!,
          _challengeIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_challengeIdMeta);
    }
    if (data.containsKey('challenge_json')) {
      context.handle(
        _challengeJsonMeta,
        challengeJson.isAcceptableOrUnknown(
          data['challenge_json']!,
          _challengeJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_challengeJsonMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_completedAtMeta);
    }
    if (data.containsKey('error')) {
      context.handle(
        _errorMeta,
        error.isAcceptableOrUnknown(data['error']!, _errorMeta),
      );
    }
    if (data.containsKey('retryable')) {
      context.handle(
        _retryableMeta,
        retryable.isAcceptableOrUnknown(data['retryable']!, _retryableMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {account, challengeId};
  @override
  PendingDailyResult map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PendingDailyResult(
      account: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account'],
      )!,
      challengeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}challenge_id'],
      )!,
      challengeJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}challenge_json'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      )!,
      error: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error'],
      ),
      retryable: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}retryable'],
      )!,
    );
  }

  @override
  $PendingDailyResultsTable createAlias(String alias) {
    return $PendingDailyResultsTable(attachedDatabase, alias);
  }
}

class PendingDailyResult extends DataClass
    implements Insertable<PendingDailyResult> {
  final String account;
  final int challengeId;
  final String challengeJson;
  final DateTime completedAt;
  final String? error;
  final bool retryable;
  const PendingDailyResult({
    required this.account,
    required this.challengeId,
    required this.challengeJson,
    required this.completedAt,
    this.error,
    required this.retryable,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['account'] = Variable<String>(account);
    map['challenge_id'] = Variable<int>(challengeId);
    map['challenge_json'] = Variable<String>(challengeJson);
    map['completed_at'] = Variable<DateTime>(completedAt);
    if (!nullToAbsent || error != null) {
      map['error'] = Variable<String>(error);
    }
    map['retryable'] = Variable<bool>(retryable);
    return map;
  }

  PendingDailyResultsCompanion toCompanion(bool nullToAbsent) {
    return PendingDailyResultsCompanion(
      account: Value(account),
      challengeId: Value(challengeId),
      challengeJson: Value(challengeJson),
      completedAt: Value(completedAt),
      error: error == null && nullToAbsent
          ? const Value.absent()
          : Value(error),
      retryable: Value(retryable),
    );
  }

  factory PendingDailyResult.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PendingDailyResult(
      account: serializer.fromJson<String>(json['account']),
      challengeId: serializer.fromJson<int>(json['challengeId']),
      challengeJson: serializer.fromJson<String>(json['challengeJson']),
      completedAt: serializer.fromJson<DateTime>(json['completedAt']),
      error: serializer.fromJson<String?>(json['error']),
      retryable: serializer.fromJson<bool>(json['retryable']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'account': serializer.toJson<String>(account),
      'challengeId': serializer.toJson<int>(challengeId),
      'challengeJson': serializer.toJson<String>(challengeJson),
      'completedAt': serializer.toJson<DateTime>(completedAt),
      'error': serializer.toJson<String?>(error),
      'retryable': serializer.toJson<bool>(retryable),
    };
  }

  PendingDailyResult copyWith({
    String? account,
    int? challengeId,
    String? challengeJson,
    DateTime? completedAt,
    Value<String?> error = const Value.absent(),
    bool? retryable,
  }) => PendingDailyResult(
    account: account ?? this.account,
    challengeId: challengeId ?? this.challengeId,
    challengeJson: challengeJson ?? this.challengeJson,
    completedAt: completedAt ?? this.completedAt,
    error: error.present ? error.value : this.error,
    retryable: retryable ?? this.retryable,
  );
  PendingDailyResult copyWithCompanion(PendingDailyResultsCompanion data) {
    return PendingDailyResult(
      account: data.account.present ? data.account.value : this.account,
      challengeId: data.challengeId.present
          ? data.challengeId.value
          : this.challengeId,
      challengeJson: data.challengeJson.present
          ? data.challengeJson.value
          : this.challengeJson,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      error: data.error.present ? data.error.value : this.error,
      retryable: data.retryable.present ? data.retryable.value : this.retryable,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PendingDailyResult(')
          ..write('account: $account, ')
          ..write('challengeId: $challengeId, ')
          ..write('challengeJson: $challengeJson, ')
          ..write('completedAt: $completedAt, ')
          ..write('error: $error, ')
          ..write('retryable: $retryable')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    account,
    challengeId,
    challengeJson,
    completedAt,
    error,
    retryable,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PendingDailyResult &&
          other.account == this.account &&
          other.challengeId == this.challengeId &&
          other.challengeJson == this.challengeJson &&
          other.completedAt == this.completedAt &&
          other.error == this.error &&
          other.retryable == this.retryable);
}

class PendingDailyResultsCompanion extends UpdateCompanion<PendingDailyResult> {
  final Value<String> account;
  final Value<int> challengeId;
  final Value<String> challengeJson;
  final Value<DateTime> completedAt;
  final Value<String?> error;
  final Value<bool> retryable;
  final Value<int> rowid;
  const PendingDailyResultsCompanion({
    this.account = const Value.absent(),
    this.challengeId = const Value.absent(),
    this.challengeJson = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.error = const Value.absent(),
    this.retryable = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PendingDailyResultsCompanion.insert({
    required String account,
    required int challengeId,
    required String challengeJson,
    required DateTime completedAt,
    this.error = const Value.absent(),
    this.retryable = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : account = Value(account),
       challengeId = Value(challengeId),
       challengeJson = Value(challengeJson),
       completedAt = Value(completedAt);
  static Insertable<PendingDailyResult> custom({
    Expression<String>? account,
    Expression<int>? challengeId,
    Expression<String>? challengeJson,
    Expression<DateTime>? completedAt,
    Expression<String>? error,
    Expression<bool>? retryable,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (account != null) 'account': account,
      if (challengeId != null) 'challenge_id': challengeId,
      if (challengeJson != null) 'challenge_json': challengeJson,
      if (completedAt != null) 'completed_at': completedAt,
      if (error != null) 'error': error,
      if (retryable != null) 'retryable': retryable,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PendingDailyResultsCompanion copyWith({
    Value<String>? account,
    Value<int>? challengeId,
    Value<String>? challengeJson,
    Value<DateTime>? completedAt,
    Value<String?>? error,
    Value<bool>? retryable,
    Value<int>? rowid,
  }) {
    return PendingDailyResultsCompanion(
      account: account ?? this.account,
      challengeId: challengeId ?? this.challengeId,
      challengeJson: challengeJson ?? this.challengeJson,
      completedAt: completedAt ?? this.completedAt,
      error: error ?? this.error,
      retryable: retryable ?? this.retryable,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (account.present) {
      map['account'] = Variable<String>(account.value);
    }
    if (challengeId.present) {
      map['challenge_id'] = Variable<int>(challengeId.value);
    }
    if (challengeJson.present) {
      map['challenge_json'] = Variable<String>(challengeJson.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (error.present) {
      map['error'] = Variable<String>(error.value);
    }
    if (retryable.present) {
      map['retryable'] = Variable<bool>(retryable.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PendingDailyResultsCompanion(')
          ..write('account: $account, ')
          ..write('challengeId: $challengeId, ')
          ..write('challengeJson: $challengeJson, ')
          ..write('completedAt: $completedAt, ')
          ..write('error: $error, ')
          ..write('retryable: $retryable, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CachedGamesTable cachedGames = $CachedGamesTable(this);
  late final $PendingResultsTable pendingResults = $PendingResultsTable(this);
  late final $KvEntriesTable kvEntries = $KvEntriesTable(this);
  late final $CachedMediaTable cachedMedia = $CachedMediaTable(this);
  late final $CachedWordsTable cachedWords = $CachedWordsTable(this);
  late final $CompletedGamesTable completedGames = $CompletedGamesTable(this);
  late final $ResourceUpdatesTable resourceUpdates = $ResourceUpdatesTable(
    this,
  );
  late final $PendingDailyResultsTable pendingDailyResults =
      $PendingDailyResultsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    cachedGames,
    pendingResults,
    kvEntries,
    cachedMedia,
    cachedWords,
    completedGames,
    resourceUpdates,
    pendingDailyResults,
  ];
}

typedef $$CachedGamesTableCreateCompanionBuilder =
    CachedGamesCompanion Function({
      Value<int> gameId,
      required String gameType,
      required String title,
      Value<String?> topic,
      Value<String?> difficult,
      Value<int?> experience,
      Value<int?> totalQuestions,
      required String contentJson,
      Value<bool> mediaComplete,
      required DateTime updatedAt,
    });
typedef $$CachedGamesTableUpdateCompanionBuilder =
    CachedGamesCompanion Function({
      Value<int> gameId,
      Value<String> gameType,
      Value<String> title,
      Value<String?> topic,
      Value<String?> difficult,
      Value<int?> experience,
      Value<int?> totalQuestions,
      Value<String> contentJson,
      Value<bool> mediaComplete,
      Value<DateTime> updatedAt,
    });

class $$CachedGamesTableFilterComposer
    extends Composer<_$AppDatabase, $CachedGamesTable> {
  $$CachedGamesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get gameId => $composableBuilder(
    column: $table.gameId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gameType => $composableBuilder(
    column: $table.gameType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get topic => $composableBuilder(
    column: $table.topic,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get difficult => $composableBuilder(
    column: $table.difficult,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get experience => $composableBuilder(
    column: $table.experience,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalQuestions => $composableBuilder(
    column: $table.totalQuestions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentJson => $composableBuilder(
    column: $table.contentJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get mediaComplete => $composableBuilder(
    column: $table.mediaComplete,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedGamesTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedGamesTable> {
  $$CachedGamesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get gameId => $composableBuilder(
    column: $table.gameId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gameType => $composableBuilder(
    column: $table.gameType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get topic => $composableBuilder(
    column: $table.topic,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get difficult => $composableBuilder(
    column: $table.difficult,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get experience => $composableBuilder(
    column: $table.experience,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalQuestions => $composableBuilder(
    column: $table.totalQuestions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentJson => $composableBuilder(
    column: $table.contentJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get mediaComplete => $composableBuilder(
    column: $table.mediaComplete,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedGamesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedGamesTable> {
  $$CachedGamesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get gameId =>
      $composableBuilder(column: $table.gameId, builder: (column) => column);

  GeneratedColumn<String> get gameType =>
      $composableBuilder(column: $table.gameType, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get topic =>
      $composableBuilder(column: $table.topic, builder: (column) => column);

  GeneratedColumn<String> get difficult =>
      $composableBuilder(column: $table.difficult, builder: (column) => column);

  GeneratedColumn<int> get experience => $composableBuilder(
    column: $table.experience,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalQuestions => $composableBuilder(
    column: $table.totalQuestions,
    builder: (column) => column,
  );

  GeneratedColumn<String> get contentJson => $composableBuilder(
    column: $table.contentJson,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get mediaComplete => $composableBuilder(
    column: $table.mediaComplete,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CachedGamesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedGamesTable,
          CachedGame,
          $$CachedGamesTableFilterComposer,
          $$CachedGamesTableOrderingComposer,
          $$CachedGamesTableAnnotationComposer,
          $$CachedGamesTableCreateCompanionBuilder,
          $$CachedGamesTableUpdateCompanionBuilder,
          (
            CachedGame,
            BaseReferences<_$AppDatabase, $CachedGamesTable, CachedGame>,
          ),
          CachedGame,
          PrefetchHooks Function()
        > {
  $$CachedGamesTableTableManager(_$AppDatabase db, $CachedGamesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedGamesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedGamesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedGamesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> gameId = const Value.absent(),
                Value<String> gameType = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> topic = const Value.absent(),
                Value<String?> difficult = const Value.absent(),
                Value<int?> experience = const Value.absent(),
                Value<int?> totalQuestions = const Value.absent(),
                Value<String> contentJson = const Value.absent(),
                Value<bool> mediaComplete = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => CachedGamesCompanion(
                gameId: gameId,
                gameType: gameType,
                title: title,
                topic: topic,
                difficult: difficult,
                experience: experience,
                totalQuestions: totalQuestions,
                contentJson: contentJson,
                mediaComplete: mediaComplete,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> gameId = const Value.absent(),
                required String gameType,
                required String title,
                Value<String?> topic = const Value.absent(),
                Value<String?> difficult = const Value.absent(),
                Value<int?> experience = const Value.absent(),
                Value<int?> totalQuestions = const Value.absent(),
                required String contentJson,
                Value<bool> mediaComplete = const Value.absent(),
                required DateTime updatedAt,
              }) => CachedGamesCompanion.insert(
                gameId: gameId,
                gameType: gameType,
                title: title,
                topic: topic,
                difficult: difficult,
                experience: experience,
                totalQuestions: totalQuestions,
                contentJson: contentJson,
                mediaComplete: mediaComplete,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedGamesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedGamesTable,
      CachedGame,
      $$CachedGamesTableFilterComposer,
      $$CachedGamesTableOrderingComposer,
      $$CachedGamesTableAnnotationComposer,
      $$CachedGamesTableCreateCompanionBuilder,
      $$CachedGamesTableUpdateCompanionBuilder,
      (
        CachedGame,
        BaseReferences<_$AppDatabase, $CachedGamesTable, CachedGame>,
      ),
      CachedGame,
      PrefetchHooks Function()
    >;
typedef $$PendingResultsTableCreateCompanionBuilder =
    PendingResultsCompanion Function({
      Value<int> id,
      required int gameId,
      required String title,
      required String gameType,
      required String startDate,
      required int correctAnswers,
      required int totalQuestions,
      required String responseLogsJson,
      Value<int> attempts,
      required DateTime completedAt,
    });
typedef $$PendingResultsTableUpdateCompanionBuilder =
    PendingResultsCompanion Function({
      Value<int> id,
      Value<int> gameId,
      Value<String> title,
      Value<String> gameType,
      Value<String> startDate,
      Value<int> correctAnswers,
      Value<int> totalQuestions,
      Value<String> responseLogsJson,
      Value<int> attempts,
      Value<DateTime> completedAt,
    });

class $$PendingResultsTableFilterComposer
    extends Composer<_$AppDatabase, $PendingResultsTable> {
  $$PendingResultsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get gameId => $composableBuilder(
    column: $table.gameId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gameType => $composableBuilder(
    column: $table.gameType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get correctAnswers => $composableBuilder(
    column: $table.correctAnswers,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalQuestions => $composableBuilder(
    column: $table.totalQuestions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get responseLogsJson => $composableBuilder(
    column: $table.responseLogsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PendingResultsTableOrderingComposer
    extends Composer<_$AppDatabase, $PendingResultsTable> {
  $$PendingResultsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get gameId => $composableBuilder(
    column: $table.gameId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gameType => $composableBuilder(
    column: $table.gameType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get correctAnswers => $composableBuilder(
    column: $table.correctAnswers,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalQuestions => $composableBuilder(
    column: $table.totalQuestions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get responseLogsJson => $composableBuilder(
    column: $table.responseLogsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PendingResultsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PendingResultsTable> {
  $$PendingResultsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get gameId =>
      $composableBuilder(column: $table.gameId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get gameType =>
      $composableBuilder(column: $table.gameType, builder: (column) => column);

  GeneratedColumn<String> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<int> get correctAnswers => $composableBuilder(
    column: $table.correctAnswers,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalQuestions => $composableBuilder(
    column: $table.totalQuestions,
    builder: (column) => column,
  );

  GeneratedColumn<String> get responseLogsJson => $composableBuilder(
    column: $table.responseLogsJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );
}

class $$PendingResultsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PendingResultsTable,
          PendingResult,
          $$PendingResultsTableFilterComposer,
          $$PendingResultsTableOrderingComposer,
          $$PendingResultsTableAnnotationComposer,
          $$PendingResultsTableCreateCompanionBuilder,
          $$PendingResultsTableUpdateCompanionBuilder,
          (
            PendingResult,
            BaseReferences<_$AppDatabase, $PendingResultsTable, PendingResult>,
          ),
          PendingResult,
          PrefetchHooks Function()
        > {
  $$PendingResultsTableTableManager(
    _$AppDatabase db,
    $PendingResultsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PendingResultsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PendingResultsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PendingResultsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> gameId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> gameType = const Value.absent(),
                Value<String> startDate = const Value.absent(),
                Value<int> correctAnswers = const Value.absent(),
                Value<int> totalQuestions = const Value.absent(),
                Value<String> responseLogsJson = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<DateTime> completedAt = const Value.absent(),
              }) => PendingResultsCompanion(
                id: id,
                gameId: gameId,
                title: title,
                gameType: gameType,
                startDate: startDate,
                correctAnswers: correctAnswers,
                totalQuestions: totalQuestions,
                responseLogsJson: responseLogsJson,
                attempts: attempts,
                completedAt: completedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int gameId,
                required String title,
                required String gameType,
                required String startDate,
                required int correctAnswers,
                required int totalQuestions,
                required String responseLogsJson,
                Value<int> attempts = const Value.absent(),
                required DateTime completedAt,
              }) => PendingResultsCompanion.insert(
                id: id,
                gameId: gameId,
                title: title,
                gameType: gameType,
                startDate: startDate,
                correctAnswers: correctAnswers,
                totalQuestions: totalQuestions,
                responseLogsJson: responseLogsJson,
                attempts: attempts,
                completedAt: completedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PendingResultsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PendingResultsTable,
      PendingResult,
      $$PendingResultsTableFilterComposer,
      $$PendingResultsTableOrderingComposer,
      $$PendingResultsTableAnnotationComposer,
      $$PendingResultsTableCreateCompanionBuilder,
      $$PendingResultsTableUpdateCompanionBuilder,
      (
        PendingResult,
        BaseReferences<_$AppDatabase, $PendingResultsTable, PendingResult>,
      ),
      PendingResult,
      PrefetchHooks Function()
    >;
typedef $$KvEntriesTableCreateCompanionBuilder =
    KvEntriesCompanion Function({
      required String key,
      required String value,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$KvEntriesTableUpdateCompanionBuilder =
    KvEntriesCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$KvEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $KvEntriesTable> {
  $$KvEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$KvEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $KvEntriesTable> {
  $$KvEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$KvEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $KvEntriesTable> {
  $$KvEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$KvEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $KvEntriesTable,
          KvEntry,
          $$KvEntriesTableFilterComposer,
          $$KvEntriesTableOrderingComposer,
          $$KvEntriesTableAnnotationComposer,
          $$KvEntriesTableCreateCompanionBuilder,
          $$KvEntriesTableUpdateCompanionBuilder,
          (KvEntry, BaseReferences<_$AppDatabase, $KvEntriesTable, KvEntry>),
          KvEntry,
          PrefetchHooks Function()
        > {
  $$KvEntriesTableTableManager(_$AppDatabase db, $KvEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$KvEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$KvEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$KvEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => KvEntriesCompanion(
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => KvEntriesCompanion.insert(
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$KvEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $KvEntriesTable,
      KvEntry,
      $$KvEntriesTableFilterComposer,
      $$KvEntriesTableOrderingComposer,
      $$KvEntriesTableAnnotationComposer,
      $$KvEntriesTableCreateCompanionBuilder,
      $$KvEntriesTableUpdateCompanionBuilder,
      (KvEntry, BaseReferences<_$AppDatabase, $KvEntriesTable, KvEntry>),
      KvEntry,
      PrefetchHooks Function()
    >;
typedef $$CachedMediaTableCreateCompanionBuilder =
    CachedMediaCompanion Function({
      required String url,
      Value<String?> sourceUrl,
      required String relativePath,
      required int byteSize,
      required String kind,
      required DateTime downloadedAt,
      Value<int> rowid,
    });
typedef $$CachedMediaTableUpdateCompanionBuilder =
    CachedMediaCompanion Function({
      Value<String> url,
      Value<String?> sourceUrl,
      Value<String> relativePath,
      Value<int> byteSize,
      Value<String> kind,
      Value<DateTime> downloadedAt,
      Value<int> rowid,
    });

class $$CachedMediaTableFilterComposer
    extends Composer<_$AppDatabase, $CachedMediaTable> {
  $$CachedMediaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceUrl => $composableBuilder(
    column: $table.sourceUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get relativePath => $composableBuilder(
    column: $table.relativePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get byteSize => $composableBuilder(
    column: $table.byteSize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get downloadedAt => $composableBuilder(
    column: $table.downloadedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedMediaTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedMediaTable> {
  $$CachedMediaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceUrl => $composableBuilder(
    column: $table.sourceUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get relativePath => $composableBuilder(
    column: $table.relativePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get byteSize => $composableBuilder(
    column: $table.byteSize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get downloadedAt => $composableBuilder(
    column: $table.downloadedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedMediaTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedMediaTable> {
  $$CachedMediaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get sourceUrl =>
      $composableBuilder(column: $table.sourceUrl, builder: (column) => column);

  GeneratedColumn<String> get relativePath => $composableBuilder(
    column: $table.relativePath,
    builder: (column) => column,
  );

  GeneratedColumn<int> get byteSize =>
      $composableBuilder(column: $table.byteSize, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<DateTime> get downloadedAt => $composableBuilder(
    column: $table.downloadedAt,
    builder: (column) => column,
  );
}

class $$CachedMediaTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedMediaTable,
          CachedMediaData,
          $$CachedMediaTableFilterComposer,
          $$CachedMediaTableOrderingComposer,
          $$CachedMediaTableAnnotationComposer,
          $$CachedMediaTableCreateCompanionBuilder,
          $$CachedMediaTableUpdateCompanionBuilder,
          (
            CachedMediaData,
            BaseReferences<_$AppDatabase, $CachedMediaTable, CachedMediaData>,
          ),
          CachedMediaData,
          PrefetchHooks Function()
        > {
  $$CachedMediaTableTableManager(_$AppDatabase db, $CachedMediaTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedMediaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedMediaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedMediaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> url = const Value.absent(),
                Value<String?> sourceUrl = const Value.absent(),
                Value<String> relativePath = const Value.absent(),
                Value<int> byteSize = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<DateTime> downloadedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedMediaCompanion(
                url: url,
                sourceUrl: sourceUrl,
                relativePath: relativePath,
                byteSize: byteSize,
                kind: kind,
                downloadedAt: downloadedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String url,
                Value<String?> sourceUrl = const Value.absent(),
                required String relativePath,
                required int byteSize,
                required String kind,
                required DateTime downloadedAt,
                Value<int> rowid = const Value.absent(),
              }) => CachedMediaCompanion.insert(
                url: url,
                sourceUrl: sourceUrl,
                relativePath: relativePath,
                byteSize: byteSize,
                kind: kind,
                downloadedAt: downloadedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedMediaTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedMediaTable,
      CachedMediaData,
      $$CachedMediaTableFilterComposer,
      $$CachedMediaTableOrderingComposer,
      $$CachedMediaTableAnnotationComposer,
      $$CachedMediaTableCreateCompanionBuilder,
      $$CachedMediaTableUpdateCompanionBuilder,
      (
        CachedMediaData,
        BaseReferences<_$AppDatabase, $CachedMediaTable, CachedMediaData>,
      ),
      CachedMediaData,
      PrefetchHooks Function()
    >;
typedef $$CachedWordsTableCreateCompanionBuilder =
    CachedWordsCompanion Function({
      Value<int> id,
      required String spanishWord,
      required String mazahuaWord,
      Value<String?> spanishPronunciation,
      Value<String?> mazahuaPronunciation,
      required String category,
      Value<String?> imagePath,
      Value<String?> audioPath,
      Value<bool> pronunciation,
      required DateTime updatedAt,
    });
typedef $$CachedWordsTableUpdateCompanionBuilder =
    CachedWordsCompanion Function({
      Value<int> id,
      Value<String> spanishWord,
      Value<String> mazahuaWord,
      Value<String?> spanishPronunciation,
      Value<String?> mazahuaPronunciation,
      Value<String> category,
      Value<String?> imagePath,
      Value<String?> audioPath,
      Value<bool> pronunciation,
      Value<DateTime> updatedAt,
    });

class $$CachedWordsTableFilterComposer
    extends Composer<_$AppDatabase, $CachedWordsTable> {
  $$CachedWordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get spanishWord => $composableBuilder(
    column: $table.spanishWord,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mazahuaWord => $composableBuilder(
    column: $table.mazahuaWord,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get spanishPronunciation => $composableBuilder(
    column: $table.spanishPronunciation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mazahuaPronunciation => $composableBuilder(
    column: $table.mazahuaPronunciation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get audioPath => $composableBuilder(
    column: $table.audioPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get pronunciation => $composableBuilder(
    column: $table.pronunciation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedWordsTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedWordsTable> {
  $$CachedWordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get spanishWord => $composableBuilder(
    column: $table.spanishWord,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mazahuaWord => $composableBuilder(
    column: $table.mazahuaWord,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get spanishPronunciation => $composableBuilder(
    column: $table.spanishPronunciation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mazahuaPronunciation => $composableBuilder(
    column: $table.mazahuaPronunciation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get audioPath => $composableBuilder(
    column: $table.audioPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get pronunciation => $composableBuilder(
    column: $table.pronunciation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedWordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedWordsTable> {
  $$CachedWordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get spanishWord => $composableBuilder(
    column: $table.spanishWord,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mazahuaWord => $composableBuilder(
    column: $table.mazahuaWord,
    builder: (column) => column,
  );

  GeneratedColumn<String> get spanishPronunciation => $composableBuilder(
    column: $table.spanishPronunciation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mazahuaPronunciation => $composableBuilder(
    column: $table.mazahuaPronunciation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get imagePath =>
      $composableBuilder(column: $table.imagePath, builder: (column) => column);

  GeneratedColumn<String> get audioPath =>
      $composableBuilder(column: $table.audioPath, builder: (column) => column);

  GeneratedColumn<bool> get pronunciation => $composableBuilder(
    column: $table.pronunciation,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CachedWordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedWordsTable,
          CachedWord,
          $$CachedWordsTableFilterComposer,
          $$CachedWordsTableOrderingComposer,
          $$CachedWordsTableAnnotationComposer,
          $$CachedWordsTableCreateCompanionBuilder,
          $$CachedWordsTableUpdateCompanionBuilder,
          (
            CachedWord,
            BaseReferences<_$AppDatabase, $CachedWordsTable, CachedWord>,
          ),
          CachedWord,
          PrefetchHooks Function()
        > {
  $$CachedWordsTableTableManager(_$AppDatabase db, $CachedWordsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedWordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedWordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedWordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> spanishWord = const Value.absent(),
                Value<String> mazahuaWord = const Value.absent(),
                Value<String?> spanishPronunciation = const Value.absent(),
                Value<String?> mazahuaPronunciation = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String?> imagePath = const Value.absent(),
                Value<String?> audioPath = const Value.absent(),
                Value<bool> pronunciation = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => CachedWordsCompanion(
                id: id,
                spanishWord: spanishWord,
                mazahuaWord: mazahuaWord,
                spanishPronunciation: spanishPronunciation,
                mazahuaPronunciation: mazahuaPronunciation,
                category: category,
                imagePath: imagePath,
                audioPath: audioPath,
                pronunciation: pronunciation,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String spanishWord,
                required String mazahuaWord,
                Value<String?> spanishPronunciation = const Value.absent(),
                Value<String?> mazahuaPronunciation = const Value.absent(),
                required String category,
                Value<String?> imagePath = const Value.absent(),
                Value<String?> audioPath = const Value.absent(),
                Value<bool> pronunciation = const Value.absent(),
                required DateTime updatedAt,
              }) => CachedWordsCompanion.insert(
                id: id,
                spanishWord: spanishWord,
                mazahuaWord: mazahuaWord,
                spanishPronunciation: spanishPronunciation,
                mazahuaPronunciation: mazahuaPronunciation,
                category: category,
                imagePath: imagePath,
                audioPath: audioPath,
                pronunciation: pronunciation,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedWordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedWordsTable,
      CachedWord,
      $$CachedWordsTableFilterComposer,
      $$CachedWordsTableOrderingComposer,
      $$CachedWordsTableAnnotationComposer,
      $$CachedWordsTableCreateCompanionBuilder,
      $$CachedWordsTableUpdateCompanionBuilder,
      (
        CachedWord,
        BaseReferences<_$AppDatabase, $CachedWordsTable, CachedWord>,
      ),
      CachedWord,
      PrefetchHooks Function()
    >;
typedef $$CompletedGamesTableCreateCompanionBuilder =
    CompletedGamesCompanion Function({
      Value<int> gameId,
      Value<String?> topic,
      required int correctAnswers,
      required int totalQuestions,
      Value<int> stars,
      required DateTime completedAt,
    });
typedef $$CompletedGamesTableUpdateCompanionBuilder =
    CompletedGamesCompanion Function({
      Value<int> gameId,
      Value<String?> topic,
      Value<int> correctAnswers,
      Value<int> totalQuestions,
      Value<int> stars,
      Value<DateTime> completedAt,
    });

class $$CompletedGamesTableFilterComposer
    extends Composer<_$AppDatabase, $CompletedGamesTable> {
  $$CompletedGamesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get gameId => $composableBuilder(
    column: $table.gameId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get topic => $composableBuilder(
    column: $table.topic,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get correctAnswers => $composableBuilder(
    column: $table.correctAnswers,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalQuestions => $composableBuilder(
    column: $table.totalQuestions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get stars => $composableBuilder(
    column: $table.stars,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CompletedGamesTableOrderingComposer
    extends Composer<_$AppDatabase, $CompletedGamesTable> {
  $$CompletedGamesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get gameId => $composableBuilder(
    column: $table.gameId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get topic => $composableBuilder(
    column: $table.topic,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get correctAnswers => $composableBuilder(
    column: $table.correctAnswers,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalQuestions => $composableBuilder(
    column: $table.totalQuestions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get stars => $composableBuilder(
    column: $table.stars,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CompletedGamesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CompletedGamesTable> {
  $$CompletedGamesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get gameId =>
      $composableBuilder(column: $table.gameId, builder: (column) => column);

  GeneratedColumn<String> get topic =>
      $composableBuilder(column: $table.topic, builder: (column) => column);

  GeneratedColumn<int> get correctAnswers => $composableBuilder(
    column: $table.correctAnswers,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalQuestions => $composableBuilder(
    column: $table.totalQuestions,
    builder: (column) => column,
  );

  GeneratedColumn<int> get stars =>
      $composableBuilder(column: $table.stars, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );
}

class $$CompletedGamesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CompletedGamesTable,
          CompletedGame,
          $$CompletedGamesTableFilterComposer,
          $$CompletedGamesTableOrderingComposer,
          $$CompletedGamesTableAnnotationComposer,
          $$CompletedGamesTableCreateCompanionBuilder,
          $$CompletedGamesTableUpdateCompanionBuilder,
          (
            CompletedGame,
            BaseReferences<_$AppDatabase, $CompletedGamesTable, CompletedGame>,
          ),
          CompletedGame,
          PrefetchHooks Function()
        > {
  $$CompletedGamesTableTableManager(
    _$AppDatabase db,
    $CompletedGamesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CompletedGamesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CompletedGamesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CompletedGamesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> gameId = const Value.absent(),
                Value<String?> topic = const Value.absent(),
                Value<int> correctAnswers = const Value.absent(),
                Value<int> totalQuestions = const Value.absent(),
                Value<int> stars = const Value.absent(),
                Value<DateTime> completedAt = const Value.absent(),
              }) => CompletedGamesCompanion(
                gameId: gameId,
                topic: topic,
                correctAnswers: correctAnswers,
                totalQuestions: totalQuestions,
                stars: stars,
                completedAt: completedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> gameId = const Value.absent(),
                Value<String?> topic = const Value.absent(),
                required int correctAnswers,
                required int totalQuestions,
                Value<int> stars = const Value.absent(),
                required DateTime completedAt,
              }) => CompletedGamesCompanion.insert(
                gameId: gameId,
                topic: topic,
                correctAnswers: correctAnswers,
                totalQuestions: totalQuestions,
                stars: stars,
                completedAt: completedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CompletedGamesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CompletedGamesTable,
      CompletedGame,
      $$CompletedGamesTableFilterComposer,
      $$CompletedGamesTableOrderingComposer,
      $$CompletedGamesTableAnnotationComposer,
      $$CompletedGamesTableCreateCompanionBuilder,
      $$CompletedGamesTableUpdateCompanionBuilder,
      (
        CompletedGame,
        BaseReferences<_$AppDatabase, $CompletedGamesTable, CompletedGame>,
      ),
      CompletedGame,
      PrefetchHooks Function()
    >;
typedef $$ResourceUpdatesTableCreateCompanionBuilder =
    ResourceUpdatesCompanion Function({
      required String resource,
      Value<DateTime?> lastUpdatedAt,
      Value<String?> lastChangeType,
      Value<int?> lastResourceId,
      Value<String?> syncCursor,
      Value<int> rowid,
    });
typedef $$ResourceUpdatesTableUpdateCompanionBuilder =
    ResourceUpdatesCompanion Function({
      Value<String> resource,
      Value<DateTime?> lastUpdatedAt,
      Value<String?> lastChangeType,
      Value<int?> lastResourceId,
      Value<String?> syncCursor,
      Value<int> rowid,
    });

class $$ResourceUpdatesTableFilterComposer
    extends Composer<_$AppDatabase, $ResourceUpdatesTable> {
  $$ResourceUpdatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get resource => $composableBuilder(
    column: $table.resource,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastUpdatedAt => $composableBuilder(
    column: $table.lastUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastChangeType => $composableBuilder(
    column: $table.lastChangeType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastResourceId => $composableBuilder(
    column: $table.lastResourceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncCursor => $composableBuilder(
    column: $table.syncCursor,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ResourceUpdatesTableOrderingComposer
    extends Composer<_$AppDatabase, $ResourceUpdatesTable> {
  $$ResourceUpdatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get resource => $composableBuilder(
    column: $table.resource,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastUpdatedAt => $composableBuilder(
    column: $table.lastUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastChangeType => $composableBuilder(
    column: $table.lastChangeType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastResourceId => $composableBuilder(
    column: $table.lastResourceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncCursor => $composableBuilder(
    column: $table.syncCursor,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ResourceUpdatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ResourceUpdatesTable> {
  $$ResourceUpdatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get resource =>
      $composableBuilder(column: $table.resource, builder: (column) => column);

  GeneratedColumn<DateTime> get lastUpdatedAt => $composableBuilder(
    column: $table.lastUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastChangeType => $composableBuilder(
    column: $table.lastChangeType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastResourceId => $composableBuilder(
    column: $table.lastResourceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncCursor => $composableBuilder(
    column: $table.syncCursor,
    builder: (column) => column,
  );
}

class $$ResourceUpdatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ResourceUpdatesTable,
          ResourceUpdate,
          $$ResourceUpdatesTableFilterComposer,
          $$ResourceUpdatesTableOrderingComposer,
          $$ResourceUpdatesTableAnnotationComposer,
          $$ResourceUpdatesTableCreateCompanionBuilder,
          $$ResourceUpdatesTableUpdateCompanionBuilder,
          (
            ResourceUpdate,
            BaseReferences<
              _$AppDatabase,
              $ResourceUpdatesTable,
              ResourceUpdate
            >,
          ),
          ResourceUpdate,
          PrefetchHooks Function()
        > {
  $$ResourceUpdatesTableTableManager(
    _$AppDatabase db,
    $ResourceUpdatesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ResourceUpdatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ResourceUpdatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ResourceUpdatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> resource = const Value.absent(),
                Value<DateTime?> lastUpdatedAt = const Value.absent(),
                Value<String?> lastChangeType = const Value.absent(),
                Value<int?> lastResourceId = const Value.absent(),
                Value<String?> syncCursor = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ResourceUpdatesCompanion(
                resource: resource,
                lastUpdatedAt: lastUpdatedAt,
                lastChangeType: lastChangeType,
                lastResourceId: lastResourceId,
                syncCursor: syncCursor,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String resource,
                Value<DateTime?> lastUpdatedAt = const Value.absent(),
                Value<String?> lastChangeType = const Value.absent(),
                Value<int?> lastResourceId = const Value.absent(),
                Value<String?> syncCursor = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ResourceUpdatesCompanion.insert(
                resource: resource,
                lastUpdatedAt: lastUpdatedAt,
                lastChangeType: lastChangeType,
                lastResourceId: lastResourceId,
                syncCursor: syncCursor,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ResourceUpdatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ResourceUpdatesTable,
      ResourceUpdate,
      $$ResourceUpdatesTableFilterComposer,
      $$ResourceUpdatesTableOrderingComposer,
      $$ResourceUpdatesTableAnnotationComposer,
      $$ResourceUpdatesTableCreateCompanionBuilder,
      $$ResourceUpdatesTableUpdateCompanionBuilder,
      (
        ResourceUpdate,
        BaseReferences<_$AppDatabase, $ResourceUpdatesTable, ResourceUpdate>,
      ),
      ResourceUpdate,
      PrefetchHooks Function()
    >;
typedef $$PendingDailyResultsTableCreateCompanionBuilder =
    PendingDailyResultsCompanion Function({
      required String account,
      required int challengeId,
      required String challengeJson,
      required DateTime completedAt,
      Value<String?> error,
      Value<bool> retryable,
      Value<int> rowid,
    });
typedef $$PendingDailyResultsTableUpdateCompanionBuilder =
    PendingDailyResultsCompanion Function({
      Value<String> account,
      Value<int> challengeId,
      Value<String> challengeJson,
      Value<DateTime> completedAt,
      Value<String?> error,
      Value<bool> retryable,
      Value<int> rowid,
    });

class $$PendingDailyResultsTableFilterComposer
    extends Composer<_$AppDatabase, $PendingDailyResultsTable> {
  $$PendingDailyResultsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get account => $composableBuilder(
    column: $table.account,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get challengeId => $composableBuilder(
    column: $table.challengeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get challengeJson => $composableBuilder(
    column: $table.challengeJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get error => $composableBuilder(
    column: $table.error,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get retryable => $composableBuilder(
    column: $table.retryable,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PendingDailyResultsTableOrderingComposer
    extends Composer<_$AppDatabase, $PendingDailyResultsTable> {
  $$PendingDailyResultsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get account => $composableBuilder(
    column: $table.account,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get challengeId => $composableBuilder(
    column: $table.challengeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get challengeJson => $composableBuilder(
    column: $table.challengeJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get error => $composableBuilder(
    column: $table.error,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get retryable => $composableBuilder(
    column: $table.retryable,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PendingDailyResultsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PendingDailyResultsTable> {
  $$PendingDailyResultsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get account =>
      $composableBuilder(column: $table.account, builder: (column) => column);

  GeneratedColumn<int> get challengeId => $composableBuilder(
    column: $table.challengeId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get challengeJson => $composableBuilder(
    column: $table.challengeJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get error =>
      $composableBuilder(column: $table.error, builder: (column) => column);

  GeneratedColumn<bool> get retryable =>
      $composableBuilder(column: $table.retryable, builder: (column) => column);
}

class $$PendingDailyResultsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PendingDailyResultsTable,
          PendingDailyResult,
          $$PendingDailyResultsTableFilterComposer,
          $$PendingDailyResultsTableOrderingComposer,
          $$PendingDailyResultsTableAnnotationComposer,
          $$PendingDailyResultsTableCreateCompanionBuilder,
          $$PendingDailyResultsTableUpdateCompanionBuilder,
          (
            PendingDailyResult,
            BaseReferences<
              _$AppDatabase,
              $PendingDailyResultsTable,
              PendingDailyResult
            >,
          ),
          PendingDailyResult,
          PrefetchHooks Function()
        > {
  $$PendingDailyResultsTableTableManager(
    _$AppDatabase db,
    $PendingDailyResultsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PendingDailyResultsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PendingDailyResultsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$PendingDailyResultsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> account = const Value.absent(),
                Value<int> challengeId = const Value.absent(),
                Value<String> challengeJson = const Value.absent(),
                Value<DateTime> completedAt = const Value.absent(),
                Value<String?> error = const Value.absent(),
                Value<bool> retryable = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PendingDailyResultsCompanion(
                account: account,
                challengeId: challengeId,
                challengeJson: challengeJson,
                completedAt: completedAt,
                error: error,
                retryable: retryable,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String account,
                required int challengeId,
                required String challengeJson,
                required DateTime completedAt,
                Value<String?> error = const Value.absent(),
                Value<bool> retryable = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PendingDailyResultsCompanion.insert(
                account: account,
                challengeId: challengeId,
                challengeJson: challengeJson,
                completedAt: completedAt,
                error: error,
                retryable: retryable,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PendingDailyResultsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PendingDailyResultsTable,
      PendingDailyResult,
      $$PendingDailyResultsTableFilterComposer,
      $$PendingDailyResultsTableOrderingComposer,
      $$PendingDailyResultsTableAnnotationComposer,
      $$PendingDailyResultsTableCreateCompanionBuilder,
      $$PendingDailyResultsTableUpdateCompanionBuilder,
      (
        PendingDailyResult,
        BaseReferences<
          _$AppDatabase,
          $PendingDailyResultsTable,
          PendingDailyResult
        >,
      ),
      PendingDailyResult,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CachedGamesTableTableManager get cachedGames =>
      $$CachedGamesTableTableManager(_db, _db.cachedGames);
  $$PendingResultsTableTableManager get pendingResults =>
      $$PendingResultsTableTableManager(_db, _db.pendingResults);
  $$KvEntriesTableTableManager get kvEntries =>
      $$KvEntriesTableTableManager(_db, _db.kvEntries);
  $$CachedMediaTableTableManager get cachedMedia =>
      $$CachedMediaTableTableManager(_db, _db.cachedMedia);
  $$CachedWordsTableTableManager get cachedWords =>
      $$CachedWordsTableTableManager(_db, _db.cachedWords);
  $$CompletedGamesTableTableManager get completedGames =>
      $$CompletedGamesTableTableManager(_db, _db.completedGames);
  $$ResourceUpdatesTableTableManager get resourceUpdates =>
      $$ResourceUpdatesTableTableManager(_db, _db.resourceUpdates);
  $$PendingDailyResultsTableTableManager get pendingDailyResults =>
      $$PendingDailyResultsTableTableManager(_db, _db.pendingDailyResults);
}
