import 'models.dart';

class DailyChallenge {
  final int id;
  final Word word;
  final DateTime startsAt, expiresAt;
  final bool completed, pending;

  /// True when the challenge was created from the bundled dictionary while
  /// the server was unavailable. Its local id is negative and is exchanged
  /// for a server challenge when the result is synchronized.
  final bool localOnly;
  final String? error;
  final RewardResult? reward;
  const DailyChallenge({
    required this.id,
    required this.word,
    required this.startsAt,
    required this.expiresAt,
    this.completed = false,
    this.pending = false,
    this.localOnly = false,
    this.error,
    this.reward,
  });
  factory DailyChallenge.fromJson(Map<String, dynamic> j) => DailyChallenge(
    id: int.parse('${j['id']}'),
    word: Word.fromJson(Map<String, dynamic>.from(j['word'] as Map)),
    startsAt: DateTime.parse(j['startsAt'] as String),
    expiresAt: DateTime.parse(j['expiresAt'] as String),
    completed: j['completed'] == true,
    localOnly: j['localOnly'] == true,
    reward: j['reward'] is Map
        ? RewardResult.fromJson(Map<String, dynamic>.from(j['reward'] as Map))
        : null,
  );
  bool validAt(DateTime now) =>
      !now.isBefore(startsAt) && now.isBefore(expiresAt);
  DailyChallenge withPending({String? error}) => DailyChallenge(
    id: id,
    word: word,
    startsAt: startsAt,
    expiresAt: expiresAt,
    completed: completed,
    pending: true,
    localOnly: localOnly,
    error: error,
    reward: reward,
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'word': word.toJson(),
    'startsAt': startsAt.toUtc().toIso8601String(),
    'expiresAt': expiresAt.toUtc().toIso8601String(),
    'completed': completed,
    'localOnly': localOnly,
  };
}
