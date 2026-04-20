import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/badge_model.dart';
import '../../domain/badge_service.dart';
import '../../../profile/presentation/providers/profile_provider.dart';

// ── Provider principal des badges ─────────────────────────────
// Calcule les badges à partir des stats du profil (déjà chargées)
final badgesProvider = FutureProvider<List<AppBadge>>((ref) async {
  final stats = await ref.watch(profileStatsProvider.future);

  return BadgeService.computeBadges(
    longestStreak: stats.longestStreak,
    currentStreak: stats.currentStreak,
    totalPoints:   stats.totalPoints,
    level:         stats.level,
  );
});

// ── Helpers dérivés ───────────────────────────────────────────

/// Badges débloqués uniquement
final unlockedBadgesProvider = FutureProvider<List<AppBadge>>((ref) async {
  final badges = await ref.watch(badgesProvider.future);
  return BadgeService.unlockedBadges(badges);
});

/// Nombre de badges débloqués (pour affichage rapide)
final badgeCountProvider = FutureProvider<(int unlocked, int total)>((ref) async {
  final badges = await ref.watch(badgesProvider.future);
  return (BadgeService.unlockedBadges(badges).length, badges.length);
});
