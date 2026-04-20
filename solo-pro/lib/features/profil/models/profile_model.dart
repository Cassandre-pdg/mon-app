import 'package:flutter/material.dart';

class UserProfile {
  final String prenom;
  final String metier;
  final String objectif;
  final String emoji;
  final DateTime memberSince;
  final int streak;
  final int longestStreak;
  final int totalCheckins;
  final int totalPomodoros;
  final double avgEnergyScore;
  final double avgSleepHours;
  final List<UserBadge> badges;

  const UserProfile({
    required this.prenom,
    required this.metier,
    required this.objectif,
    required this.emoji,
    required this.memberSince,
    required this.streak,
    required this.longestStreak,
    required this.totalCheckins,
    required this.totalPomodoros,
    required this.avgEnergyScore,
    required this.avgSleepHours,
    required this.badges,
  });
}

class UserBadge {
  final String emoji;
  final String title;
  final String description;
  final bool unlocked;
  final DateTime? unlockedAt;
  final Color color;

  const UserBadge({
    required this.emoji,
    required this.title,
    required this.description,
    required this.unlocked,
    required this.color,
    this.unlockedAt,
  });
}

// ─── Définition de tous les badges ───────────────────────────────────────────

final List<UserBadge> allUserBadges = [
  UserBadge(
    emoji: '🚀',
    title: 'Premier pas',
    description: 'Premier check-in réalisé',
    unlocked: true,
    unlockedAt: DateTime.now().subtract(const Duration(days: 12)),
    color: const Color(0xFF6C63FF),
  ),
  UserBadge(
    emoji: '🔥',
    title: 'En feu !',
    description: '3 jours de streak consécutifs',
    unlocked: true,
    unlockedAt: DateTime.now().subtract(const Duration(days: 9)),
    color: const Color(0xFFFF6B6B),
  ),
  UserBadge(
    emoji: '🍅',
    title: 'Pomodoro addict',
    description: '10 sessions Pomodoro complétées',
    unlocked: true,
    unlockedAt: DateTime.now().subtract(const Duration(days: 5)),
    color: const Color(0xFFFF9F1C),
  ),
  UserBadge(
    emoji: '😴',
    title: 'Dormeur d\'or',
    description: '7h+ de sommeil 3 nuits de suite',
    unlocked: true,
    unlockedAt: DateTime.now().subtract(const Duration(days: 2)),
    color: const Color(0xFF3D35CC),
  ),
  UserBadge(
    emoji: '🧠',
    title: 'Deep Worker',
    description: 'Première session Deep Work terminée',
    unlocked: false,
    color: const Color(0xFF4CAF50),
  ),
  UserBadge(
    emoji: '⚡',
    title: 'Énergie max',
    description: 'Score énergie 9+ trois jours de suite',
    unlocked: false,
    color: const Color(0xFFFFD93D),
  ),
  UserBadge(
    emoji: '🏆',
    title: 'Semaine parfaite',
    description: 'Check-in matin + soir 7 jours consécutifs',
    unlocked: false,
    color: const Color(0xFFFFD700),
  ),
  UserBadge(
    emoji: '👥',
    title: 'Tribu founding',
    description: 'Premier post dans la communauté',
    unlocked: false,
    color: const Color(0xFF00BCD4),
  ),
];

// ─── Mock profil ──────────────────────────────────────────────────────────────

final UserProfile mockProfile = UserProfile(
  prenom: 'Alex',
  metier: 'Freelance',
  objectif: 'Booster ma productivité',
  emoji: '🧑',
  memberSince: DateTime.now().subtract(const Duration(days: 12)),
  streak: 3,
  longestStreak: 7,
  totalCheckins: 18,
  totalPomodoros: 12,
  avgEnergyScore: 7.4,
  avgSleepHours: 7.2,
  badges: allUserBadges,
);

// ─── Calcul du niveau ─────────────────────────────────────────────────────────

int userLevel(int totalCheckins) => (totalCheckins / 7).floor() + 1;

int xpCurrent(int totalCheckins) => totalCheckins % 7;

int xpNeeded() => 7;

String levelTitle(int level) {
  if (level >= 10) return 'Maître Solopreneur';
  if (level >= 7) return 'Expert productivité';
  if (level >= 5) return 'Pro confirmé';
  if (level >= 3) return 'En progression';
  return 'Débutant motivé';
}
