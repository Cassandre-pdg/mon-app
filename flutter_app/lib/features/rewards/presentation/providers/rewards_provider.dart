import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/badge_model.dart';
import '../../data/badge_preferences_repository.dart';
import '../../data/rewards_repository.dart';
import '../../domain/badge_service.dart';
import '../../../profile/presentation/providers/profile_provider.dart';

// ── Repositories ──────────────────────────────────────────────
final rewardsRepositoryProvider = Provider<RewardsRepository>(
  (ref) => RewardsRepository(Supabase.instance.client),
);

final badgePrefsRepositoryProvider = Provider<BadgePreferencesRepository>(
  (_) => BadgePreferencesRepository(),
);

// ── Stats d'activité ──────────────────────────────────────────
final rewardsStatsProvider = FutureProvider<RewardsStats>((ref) async {
  return ref.read(rewardsRepositoryProvider).getStats();
});

// ── Badges (liste complète calculée) ─────────────────────────
final badgesProvider = FutureProvider<List<AppBadge>>((ref) async {
  final stats    = await ref.watch(profileStatsProvider.future);
  final activity = await ref.watch(rewardsStatsProvider.future);

  return BadgeService.computeBadges(
    longestStreak: stats.longestStreak,
    currentStreak: stats.currentStreak,
    totalPoints:   stats.totalPoints,
    level:         stats.level,
    activity:      activity,
  );
});

// ── Dates de déverrouillage (enregistrées localement) ─────────
final unlockDatesProvider = FutureProvider<Map<String, DateTime>>((ref) async {
  final badges = await ref.watch(badgesProvider.future);
  final repo   = ref.read(badgePrefsRepositoryProvider);
  // Enregistre les nouveaux badges débloqués
  for (final b in badges.where((b) => b.isUnlocked)) {
    await repo.markUnlockedIfNew(b.id);
  }
  return repo.getUnlockDates();
});

// ── Badges épinglés ───────────────────────────────────────────
class _PinnedBadgesNotifier extends AsyncNotifier<List<String>> {
  @override
  Future<List<String>> build() {
    return ref.read(badgePrefsRepositoryProvider).getPinnedBadgeIds();
  }

  /// Retourne true si le badge est maintenant épinglé, false sinon.
  Future<bool> togglePin(String badgeId) async {
    final repo = ref.read(badgePrefsRepositoryProvider);
    final isPinned = await repo.togglePin(badgeId);
    ref.invalidateSelf();
    return isPinned;
  }
}

final pinnedBadgesProvider =
    AsyncNotifierProvider<_PinnedBadgesNotifier, List<String>>(
  _PinnedBadgesNotifier.new,
);

// ── Helpers dérivés ───────────────────────────────────────────
final unlockedBadgesProvider = FutureProvider<List<AppBadge>>((ref) async {
  final badges = await ref.watch(badgesProvider.future);
  return BadgeService.unlockedBadges(badges);
});

final badgeCountProvider = FutureProvider<(int unlocked, int total)>((ref) async {
  final badges = await ref.watch(badgesProvider.future);
  return (BadgeService.unlockedBadges(badges).length, badges.length);
});
