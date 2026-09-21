import 'dart:convert';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/activity_config.dart';
import '../../app/map_zones.dart';
import '../../core/ai/validador_service.dart';
import '../../core/connectivity/connectivity_service.dart';
import '../../core/storage/app_database.dart';
import '../../core/storage/session_store.dart';
import '../../core/sync/game_cache_service.dart';
import '../../data/models/models.dart';
import '../../data/models/daily_pronunciation.dart';
import '../../data/services/activity_service.dart';
import '../../data/services/misc_services.dart';
import '../../data/services/daily_pronunciation_service.dart';
import '../auth/auth_controller.dart';
import '../dictionary/dictionary_repository.dart';
import '../progress/progress_providers.dart';
import '../pronunciation/practice_words.dart';

final homeAccountProvider = Provider<String?>((ref) {
  ref.watch(authControllerProvider);
  return ref.watch(sessionStoreProvider).accountId;
});
final practiceWordsProvider = FutureProvider<List<Word>>((ref) async {
  final dict = await ref.watch(dictionaryProvider.future);
  final keys = await ref.watch(centroidesProvider.future);
  return dict.allWords
      .where((w) => w.id != null && isPracticeWord(w, keys))
      .toList();
});
final dailyChallengeProvider = StreamProvider.autoDispose<DailyChallenge?>((
  ref,
) async* {
  final account = ref.watch(homeAccountProvider);
  final online = ref.watch(isOnlineProvider);
  final service = ref.watch(dailyPronunciationServiceProvider);
  final wordsFuture = ref.watch(practiceWordsProvider.future);
  if (account == null) {
    yield null;
    return;
  }
  final cached = await service.cached(account);
  final usable = cached != null && cached.validAt(DateTime.now());
  if (usable) yield cached;
  if (!online) {
    if (!usable) {
      try {
        final words = await wordsFuture;
        yield await service.startLocal(account, words);
      } catch (_) {
        yield null;
      }
    }
    return;
  }
  try {
    final words = await wordsFuture;
    if (words.isEmpty) {
      if (!usable) yield null;
      return;
    }
    yield await service.start(account, words.map((w) => w.id!).toList());
  } catch (_) {
    if (!usable) rethrow;
  }
});

T? pickHomeItem<T>(List<T> values) =>
    values.isEmpty ? null : values[Random().nextInt(values.length)];

final homeGameProvider = FutureProvider.autoDispose<GameSummaryDto?>((
  ref,
) async {
  final progress = await ref.watch(progressSnapshotProvider.future);
  final db = ref.watch(appDatabaseProvider);
  final bundle = await ref.watch(gameCacheServiceProvider).bundleGameIds();
  final games = await db.allCachedGames();
  return pickHomeItem([
    for (final g in games)
      if (bundle.contains(g.gameId) &&
          isGameTypeEnabled(g.gameType) &&
          playableGameTypes.contains(g.gameType) &&
          !mediaTypes.contains(g.gameType) &&
          !progress.starsByGameId.containsKey(g.gameId) &&
          mapZones.any((z) => z.topics.any((t) => t.$1 == g.topic)))
        GameSummaryDto(
          id: g.gameId,
          title: g.title,
          gameType: g.gameType,
          difficult: g.difficult,
          topic: g.topic,
          experience: g.experience,
          totalQuestions: g.totalQuestions,
        ),
  ]);
});
final homeAssignmentProvider =
    FutureProvider.autoDispose<Map<String, dynamic>?>((ref) async {
      final user = ref.watch(authControllerProvider);
      final account = ref.watch(homeAccountProvider);
      if (user?.isStudent != true || account == null) return null;
      final db = ref.watch(appDatabaseProvider);
      final key = 'home_assignment:$account';
      try {
        final json = await ref
            .watch(activityServiceProvider)
            .getStudentActivities();
        final paged = Paged.fromJson(json, (j) => j);
        final item = pickHomeItem(
          paged.content
              .where(
                (a) =>
                    a['finished'] != true &&
                    isGameTypeEnabled(a['gameType'] as String?) &&
                    playableGameTypes.contains(a['gameType']),
              )
              .toList(),
        );
        await db.kvPut(key, jsonEncode(item));
        return item;
      } catch (_) {
        final cached = await db.kvGet(key);
        return cached == null
            ? null
            : jsonDecode(cached) as Map<String, dynamic>?;
      }
    });
final homeMediaProvider = FutureProvider.autoDispose<MediaItem?>((ref) async {
  final online = ref.watch(isOnlineProvider);
  final db = ref.watch(appDatabaseProvider);
  final service = ref.watch(mediaServiceProvider);
  final all = <MediaItem>[];
  await Future.wait(
    ['POEM', 'LEGEND', 'ANECDOTE', 'SONG'].map((type) async {
      final key = 'home_media:$type';
      try {
        if (!online) throw StateError('offline');
        final items = await service.getMediaByType(type);
        // Conserva los campos que necesita el reproductor; el resto se carga allí.
        await db.kvPut(
          key,
          jsonEncode(
            items
                .map(
                  (m) => {
                    'id': m.id,
                    'title': m.title,
                    'description': m.description,
                    'type': type,
                  },
                )
                .toList(),
          ),
        );
        all.addAll(items);
      } catch (_) {
        final raw = await db.kvGet(key);
        if (raw != null) {
          all.addAll(
            (jsonDecode(raw) as List).map(
              (j) => MediaItem.fromJson(Map<String, dynamic>.from(j as Map)),
            ),
          );
        }
      }
    }),
  );
  return pickHomeItem(all.where((m) => m.id != null).toList());
});
