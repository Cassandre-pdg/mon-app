import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logger/logger.dart';

import '../../data/challenge_model.dart';

final _log = Logger();

// ── Notifier du défi mensuel ──────────────────────────────────
class ChallengeNotifier extends StateNotifier<AsyncValue<KolybChallenge?>> {
  ChallengeNotifier() : super(const AsyncValue.loading()) {
    _load();
  }

  final _supabase = Supabase.instance.client;

  static String _monthKey() {
    final now = DateTime.now();
    return 'challenge_${now.year}_${now.month}';
  }

  String get _userId => _supabase.auth.currentUser?.id ?? '';

  // 📸 MODE CAPTURES APP STORE — mettre à false avant de soumettre
  static const bool screenshotMode = false;

  Future<void> _load() async {
    if (screenshotMode) {
      state = AsyncValue.data(buildCurrentChallenge(
        isJoined: false,
        progressDays: 0,
        communityCount: 47,
      ));
      return;
    }
    try {
      final challengeId = _monthKey();

      // Nombre de participants pour ce defi (lecture publique)
      final countRes = await _supabase
          .from('challenge_participants')
          .select('id')
          .eq('challenge_id', challengeId);
      final participantsCount = (countRes as List).length;

      // Etat de l'utilisateur courant
      bool isJoined = false;
      int progressDays = 0;
      if (_userId.isNotEmpty) {
        final userRes = await _supabase
            .from('challenge_participants')
            .select('progress_days')
            .eq('challenge_id', challengeId)
            .eq('user_id', _userId)
            .maybeSingle();
        if (userRes != null) {
          isJoined = true;
          progressDays = (userRes['progress_days'] as int?) ?? 0;
        }
      }

      state = AsyncValue.data(buildCurrentChallenge(
        isJoined: isJoined,
        progressDays: progressDays,
        communityCount: participantsCount,
      ));
    } catch (e, st) {
      _log.e('ChallengeNotifier._load', error: e);
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> joinChallenge() async {
    final current = state.valueOrNull;
    if (current == null || _userId.isEmpty) return;

    try {
      await _supabase.from('challenge_participants').upsert({
        'user_id': _userId,
        'challenge_id': _monthKey(),
        'progress_days': 0,
      });
      state = AsyncValue.data(current.copyWith(
        isJoined: true,
        participantsCount: current.participantsCount + 1,
      ));
    } catch (e) {
      _log.e('joinChallenge', error: e);
    }
  }

  Future<void> leaveChallenge() async {
    final current = state.valueOrNull;
    if (current == null || _userId.isEmpty) return;

    try {
      await _supabase
          .from('challenge_participants')
          .delete()
          .eq('challenge_id', _monthKey())
          .eq('user_id', _userId);
      state = AsyncValue.data(current.copyWith(
        isJoined: false,
        participantsCount: (current.participantsCount - 1).clamp(0, 999999),
      ));
    } catch (e) {
      _log.e('leaveChallenge', error: e);
    }
  }

  Future<void> incrementProgress() async {
    final current = state.valueOrNull;
    if (current == null || !current.isJoined || _userId.isEmpty) return;

    final newProgress = (current.userProgressDays + 1).clamp(0, current.targetDays);
    try {
      await _supabase
          .from('challenge_participants')
          .update({'progress_days': newProgress})
          .eq('challenge_id', _monthKey())
          .eq('user_id', _userId);
      state = AsyncValue.data(current.copyWith(userProgressDays: newProgress));
    } catch (e) {
      _log.e('incrementProgress', error: e);
    }
  }
}

final challengeProvider = StateNotifierProvider<ChallengeNotifier, AsyncValue<KolybChallenge?>>(
  (ref) => ChallengeNotifier(),
);
