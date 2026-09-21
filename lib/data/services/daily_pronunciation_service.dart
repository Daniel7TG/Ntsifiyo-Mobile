import 'dart:convert';
import 'dart:math';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/api_client.dart';
import '../../core/storage/app_database.dart';
import '../../core/storage/session_store.dart';
import '../models/daily_pronunciation.dart';
import '../models/models.dart';

const pendingXpMessage =
    'Sin conexión: tu resultado quedó guardado. La XP se agregará cuando recuperes la conexión y se sincronice.';

class DailyPronunciationService {
  final ApiClient api;
  final AppDatabase db;
  final String? Function() currentAccount;
  DailyPronunciationService(this.api, this.db, this.currentAccount);
  String _key(String account) => 'daily_pronunciation:$account';
  String _historyKey(String account) => 'daily_pronunciation_history:$account';
  void _check(String account) {
    if (account != currentAccount()) throw StateError('La cuenta cambió.');
  }

  Future<DailyChallenge?> cached(String account) async {
    final raw = await db.kvGet(_key(account));
    if (raw == null) return null;
    try {
      final c = DailyChallenge.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
      return await withPending(account, c);
    } catch (_) {
      return null;
    }
  }

  Future<DailyChallenge> withPending(String account, DailyChallenge c) async {
    if (c.completed) return c;
    final rows = await db.dailyPending(account);
    final pending = rows.where((r) => r.challengeId == c.id).firstOrNull;
    return pending == null ? c : c.withPending(error: pending.error);
  }

  Future<DailyChallenge> start(String account, List<int> supportedIds) async {
    _check(account);
    // Si ya resolvimos un reto creado offline, conservarlo hasta que la
    // cola lo pueda convertir en un reto del servidor. Cambiarlo aquí
    // dejaría la resolución local sin una palabra asociada.
    final cachedChallenge = await cached(account);
    if (cachedChallenge != null &&
        cachedChallenge.localOnly &&
        cachedChallenge.pending) {
      return cachedChallenge;
    }
    final json = await api.post('/api/pronunciation/daily/start', {
      'supportedWordIds': supportedIds,
    });
    _check(account);
    final c = DailyChallenge.fromJson(Map<String, dynamic>.from(json as Map));
    await db.kvPut(_key(account), jsonEncode(c.toJson()));
    return withPending(account, c);
  }

  /// Asigna una palabra desde el diccionario y el modelo empaquetados. Se
  /// usa únicamente cuando no hay conexión: el id negativo marca que aún no
  /// existe una fila equivalente en el backend. Al sincronizar, [send]
  /// obtiene la asignación real y conserva la fecha del intento.
  Future<DailyChallenge?> startLocal(String account, List<Word> words) async {
    _check(account);
    final now = DateTime.now();
    final cachedChallenge = await cached(account);
    if (cachedChallenge != null && cachedChallenge.validAt(now)) {
      return cachedChallenge;
    }
    final eligible = words.where((word) => word.id != null).toList();
    if (eligible.isEmpty) return null;

    var cycle = 1;
    var used = <int>{};
    int? lastId;
    final historyRaw = await db.kvGet(_historyKey(account));
    if (historyRaw != null) {
      try {
        final history = jsonDecode(historyRaw) as Map<String, dynamic>;
        cycle = (history['cycle'] as num?)?.toInt() ?? 1;
        used = ((history['used'] as List?) ?? const [])
            .whereType<num>()
            .map((id) => id.toInt())
            .toSet();
        lastId = (history['lastId'] as num?)?.toInt();
      } catch (_) {
        cycle = 1;
        used = <int>{};
      }
    }

    var remaining = eligible.where((word) => !used.contains(word.id!)).toList();
    if (remaining.isEmpty) {
      cycle++;
      used = <int>{};
      remaining = [...eligible];
      if (remaining.length > 1 && lastId != null) {
        remaining.removeWhere((word) => word.id! == lastId);
      }
    }
    final seed = _stableSeed(
      '$account:${now.year}-${now.month}-${now.day}:$cycle',
    );
    final word = remaining[Random(seed).nextInt(remaining.length)];
    final startsAt = DateTime(now.year, now.month, now.day);
    final expiresAt = DateTime(now.year, now.month, now.day + 1);
    final challenge = DailyChallenge(
      id: -word.id!,
      word: word,
      startsAt: startsAt.toUtc(),
      expiresAt: expiresAt.toUtc(),
      localOnly: true,
    );
    used.add(word.id!);
    await db.kvPut(
      _historyKey(account),
      jsonEncode({'cycle': cycle, 'used': used.toList(), 'lastId': word.id}),
    );
    await db.kvPut(_key(account), jsonEncode(challenge.toJson()));
    return challenge;
  }

  Future<DailyChallenge> complete(String account, DailyChallenge c) async {
    _check(account);
    final now = DateTime.now().toUtc();
    if (c.completed) return c;
    if (!c.validAt(now)) {
      throw ApiException(
        'El reto de este día terminó. Abre el reto de hoy.',
        status: 400,
      );
    }
    await db.enqueueDaily(
      PendingDailyResultsCompanion(
        account: Value(account),
        challengeId: Value(c.id),
        challengeJson: Value(jsonEncode(c.toJson())),
        completedAt: Value(now),
      ),
    );
    final row = (await db.dailyPending(
      account,
    )).firstWhere((r) => r.challengeId == c.id);
    try {
      return await send(row);
    } on ApiException catch (e) {
      if (e.status != null) {
        await db.rejectDaily(
          account,
          c.id,
          e.message,
          retryable: e.status == 401 || e.status == 429 || e.status! >= 500,
        );
        rethrow;
      }
      return c.withPending();
    }
  }

  Future<DailyChallenge> send(PendingDailyResult row) async {
    _check(row.account);
    final local = DailyChallenge.fromJson(
      jsonDecode(row.challengeJson) as Map<String, dynamic>,
    );
    var challenge = local;
    if (local.localOnly || row.challengeId < 0) {
      final startedJson = await api.post('/api/pronunciation/daily/start', {
        'supportedWordIds': [local.word.id!],
      });
      _check(row.account);
      challenge = DailyChallenge.fromJson(
        Map<String, dynamic>.from(startedJson as Map),
      );
    }
    final json = await api.post(
      '/api/pronunciation/daily/${challenge.id}/complete',
      {
        'accepted': true,
        // Una asignación creada offline no tiene `issuedAt` en el backend.
        // Al enlazarla se registra el momento de sincronización para que el
        // servidor pueda validar la ventana de su reto actual.
        'completedAt':
            (local.localOnly ? DateTime.now().toUtc() : row.completedAt.toUtc())
                .toIso8601String(),
      },
    );
    _check(row.account);
    final c = DailyChallenge.fromJson(Map<String, dynamic>.from(json as Map));
    if (!c.completed || c.reward == null) {
      throw ApiException('Respuesta de recompensa incompleta', status: 502);
    }
    final cache = await cached(row.account);
    if (cache?.id == row.challengeId || cache?.id == c.id) {
      await db.kvPut(_key(row.account), jsonEncode(c.toJson()));
    }
    await db.deleteDaily(row.account, row.challengeId);
    return c;
  }

  int _stableSeed(String value) {
    var hash = 0x811c9dc5;
    for (final codeUnit in value.codeUnits) {
      hash = ((hash ^ codeUnit) * 0x01000193) & 0x7fffffff;
    }
    return hash;
  }
}

final dailyPronunciationServiceProvider = Provider((ref) {
  final session = ref.watch(sessionStoreProvider);
  return DailyPronunciationService(
    ref.watch(apiClientProvider),
    ref.watch(appDatabaseProvider),
    () => session.accountId,
  );
});
