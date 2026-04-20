import '../data/badge_model.dart';

// ── Service de calcul des badges ──────────────────────────────
// Toute la logique métier est ici, sans aucune dépendance Flutter
class BadgeService {
  BadgeService._();

  /// Calcule la liste complète des badges à partir des stats utilisateur
  static List<AppBadge> computeBadges({
    required int longestStreak,
    required int currentStreak,
    required int totalPoints,
    required int level,
  }) {
    // On utilise le meilleur des deux pour le streak (actuel ou record)
    final bestStreak = longestStreak > currentStreak ? longestStreak : currentStreak;

    return [
      // ── Badges Streak ──────────────────────────────────────
      AppBadge(
        id: 'streak_3',
        emoji: '🔥',
        name: '3 jours de suite',
        description: 'Tu avances à ton rythme — continue !',
        category: BadgeCategory.streak,
        isUnlocked: bestStreak >= 3,
      ),
      AppBadge(
        id: 'streak_7',
        emoji: '🔥🔥',
        name: 'Une semaine !',
        description: '7 jours de régularité, c\'est solide.',
        category: BadgeCategory.streak,
        isUnlocked: bestStreak >= 7,
      ),
      AppBadge(
        id: 'streak_14',
        emoji: '⭐',
        name: '2 semaines',
        description: 'Tu construis une vraie habitude.',
        category: BadgeCategory.streak,
        isUnlocked: bestStreak >= 14,
      ),
      AppBadge(
        id: 'streak_30',
        emoji: '🏆',
        name: '1 mois',
        description: 'Un mois complet — impressionnant !',
        category: BadgeCategory.streak,
        isUnlocked: bestStreak >= 30,
      ),
      AppBadge(
        id: 'streak_100',
        emoji: '💎',
        name: '100 jours',
        description: '100 jours — tu es un exemple pour la tribu.',
        category: BadgeCategory.streak,
        isUnlocked: bestStreak >= 100,
      ),
      AppBadge(
        id: 'streak_365',
        emoji: '👑',
        name: '1 an',
        description: 'Un an ensemble — respect total.',
        category: BadgeCategory.streak,
        isUnlocked: bestStreak >= 365,
      ),

      // ── Badges Niveau ──────────────────────────────────────
      AppBadge(
        id: 'level_1',
        emoji: '🌱',
        name: 'Explorateur',
        description: 'Tu commences l\'aventure Kolyb.',
        category: BadgeCategory.level,
        isUnlocked: level >= 1,
      ),
      AppBadge(
        id: 'level_2',
        emoji: '💼',
        name: 'Indépendant',
        description: 'Tu trouves ton propre rythme.',
        category: BadgeCategory.level,
        isUnlocked: level >= 2,
      ),
      AppBadge(
        id: 'level_3',
        emoji: '🚀',
        name: 'Entrepreneur',
        description: 'Tu avances avec intention chaque jour.',
        category: BadgeCategory.level,
        isUnlocked: level >= 3,
      ),
      AppBadge(
        id: 'level_4',
        emoji: '🏗️',
        name: 'Bâtisseur',
        description: 'Tu construis quelque chose de solide.',
        category: BadgeCategory.level,
        isUnlocked: level >= 4,
      ),
      AppBadge(
        id: 'level_5',
        emoji: '👑',
        name: 'Visionnaire',
        description: 'Tu es un modèle pour toute la communauté.',
        category: BadgeCategory.level,
        isUnlocked: level >= 5,
      ),

      // ── Badges Spéciaux ────────────────────────────────────
      AppBadge(
        id: 'first_step',
        emoji: '👟',
        name: 'Premier pas',
        description: 'Tu as démarré — c\'est le plus dur.',
        category: BadgeCategory.special,
        isUnlocked: totalPoints >= 1,
      ),
      AppBadge(
        id: 'momentum',
        emoji: '⚡',
        name: 'Momentum',
        description: 'Tu accumules de l\'élan — ça se sent !',
        category: BadgeCategory.special,
        isUnlocked: totalPoints >= 50,
      ),
      AppBadge(
        id: 'comeback',
        emoji: '💪',
        name: 'Relevé !',
        description: 'Tu t\'es relevé après une pause — respect.',
        category: BadgeCategory.special,
        // Débloqué si tu as accumulé des points "comeback" (bonus bienveillance)
        // Pour V1 : débloqué si tu as >= 15 pts (seuil du bonus comeback)
        isUnlocked: totalPoints >= 15,
      ),
    ];
  }

  /// Retourne uniquement les badges débloqués
  static List<AppBadge> unlockedBadges(List<AppBadge> badges) =>
      badges.where((b) => b.isUnlocked).toList();

  /// Retourne les badges par catégorie
  static List<AppBadge> byCategory(
    List<AppBadge> badges,
    BadgeCategory category,
  ) =>
      badges.where((b) => b.category == category).toList();
}
