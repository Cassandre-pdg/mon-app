import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

import '../../data/challenge_model.dart';

final _log = Logger();

const _kJoinKey     = 'challenge_joined_';
const _kProgressKey = 'challenge_progress_';

// ── Notifier du défi mensuel ──────────────────────────────────
class ChallengeNotifier extends StateNotifier<AsyncValue<KolybChallenge?>> {
  ChallengeNotifier() : super(const AsyncValue.loading()) {
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key   = _monthKey();

      final isJoined = prefs.getBool('$_kJoinKey$key')      ?? false;
      final progress = prefs.getInt('$_kProgressKey$key')   ?? 0;

      final challenge = buildCurrentChallenge(
        isJoined:       isJoined,
        progressDays:   progress,
        communityCount: _estimateCommunityCount(),
      );

      state = AsyncValue.data(challenge);
    } catch (e, st) {
      _log.e('ChallengeNotifier._load', error: e);
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> joinChallenge() async {
    final current = state.valueOrNull;
    if (current == null) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_kJoinKey${_monthKey()}', true);

    state = AsyncValue.data(current.copyWith(
      isJoined:           true,
      participantsCount:  current.participantsCount + 1,
    ));
  }

  Future<void> leaveChallenge() async {
    final current = state.valueOrNull;
    if (current == null) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_kJoinKey${_monthKey()}', false);

    state = AsyncValue.data(current.copyWith(
      isJoined:           false,
      participantsCount:  (current.participantsCount - 1).clamp(0, 999999),
    ));
  }

  Future<void> incrementProgress() async {
    final current = state.valueOrNull;
    if (current == null || !current.isJoined) return;

    final newProgress = (current.userProgressDays + 1).clamp(0, current.targetDays);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('$_kProgressKey${_monthKey()}', newProgress);

    state = AsyncValue.data(current.copyWith(userProgressDays: newProgress));
  }

  static String _monthKey() {
    final now = DateTime.now();
    return '${now.year}_${now.month}';
  }

  // Simule une croissance organique réaliste — à remplacer par une query Supabase en V2
  static int _estimateCommunityCount() {
    final daysSinceLaunch = DateTime.now()
        .difference(DateTime(2025, 5, 1))
        .inDays
        .clamp(0, 99999);
    return 38 + (daysSinceLaunch * 2);
  }
}

final challengeProvider = StateNotifierProvider<ChallengeNotifier, AsyncValue<KolybChallenge?>>(
  (ref) => ChallengeNotifier(),
);
