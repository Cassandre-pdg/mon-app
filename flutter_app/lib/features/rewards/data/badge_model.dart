import 'package:flutter/material.dart';
import '../../../../shared/theme/app_colors.dart';

enum BadgeCategory { streak, level, special }

// ── Modèle d'un badge ─────────────────────────────────────────
class AppBadge {
  final String id;
  final String emoji;
  final String name;
  final String description;
  final BadgeCategory category;
  final bool isUnlocked;

  const AppBadge({
    required this.id,
    required this.emoji,
    required this.name,
    required this.description,
    required this.category,
    required this.isUnlocked,
  });

  Color get categoryColor {
    switch (category) {
      case BadgeCategory.streak:  return AppColors.secondary;
      case BadgeCategory.level:   return AppColors.primary;
      case BadgeCategory.special: return AppColors.warning;
    }
  }
}
