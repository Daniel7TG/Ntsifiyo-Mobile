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

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CachedGamesTable cachedGames = $CachedGamesTable(this);
  late final $PendingResultsTable pendingResults = $PendingResultsTable(this);
  late final $KvEntriesTable kvEntries = $KvEntriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    cachedGames,
    pendingResults,
    kvEntries,
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

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CachedGamesTableTableManager get cachedGames =>
      $$CachedGamesTableTableManager(_db, _db.cachedGames);
  $$PendingResultsTableTableManager get pendingResults =>
      $$PendingResultsTableTableManager(_db, _db.pendingResults);
  $$KvEntriesTableTableManager get kvEntries =>
      $$KvEntriesTableTableManager(_db, _db.kvEntries);
}
