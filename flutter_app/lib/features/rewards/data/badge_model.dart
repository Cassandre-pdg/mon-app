import 'package:flutter/material.dart';
import '../../../../shared/theme/app_colors.dart';

enum BadgeCategory {
  streak,
  level,
  flash,
  checkin,
  project,
  community,
  special,
}

enum BadgeTier {
  common,    // hex simple
  rare,      // hex + anneau intérieur
  legendary, // hex + double anneau + glow pulsant
}

class AppBadge {
  final String id;
  final String name;
  final String description;
  final String hint;
  final BadgeCategory category;
  final BadgeTier tier;
  final bool isUnlocked;
  final List<Color> gradientColors;
  final IconData icon;
  final int? progressCurrent;
  final int? progressGoal;
  final String? progressUnit;

  const AppBadge({
    required this.id,
    required this.name,
    required this.description,
    required this.hint,
    required this.category,
    required this.tier,
    required this.isUnlocked,
    required this.gradientColors,
    required this.icon,
    this.progressCurrent,
    this.progressGoal,
    this.progressUnit,
  });

  double? get progressFraction {
    if (progressGoal == null || progressGoal == 0) return null;
    return (progressCurrent! / progressGoal!).clamp(0.0, 1.0);
  }

  Color get categoryColor {
    switch (category) {
      case BadgeCategory.streak:    return AppColors.secondary;
      case BadgeCategory.level:     return AppColors.primaryLight;
      case BadgeCategory.flash:     return AppColors.chartAmber;
      case BadgeCategory.checkin:   return AppColors.accent;
      case BadgeCategory.project:   return AppColors.primary;
      case BadgeCategory.community: return AppColors.primaryLight;
      case BadgeCategory.special:   return AppColors.chartAmber;
    }
  }

  String get categoryLabel {
    switch (category) {
      case BadgeCategory.streak:    return 'Régularité';
      case BadgeCategory.level:     return 'Progression';
      case BadgeCategory.flash:     return 'Flash';
      case BadgeCategory.checkin:   return 'Check-ins';
      case BadgeCategory.project:   return 'Projets';
      case BadgeCategory.community: return 'Le Salon';
      case BadgeCategory.special:   return 'Spécial';
    }
  }

  String get tierLabel {
    switch (tier) {
      case BadgeTier.common:    return 'Courant';
      case BadgeTier.rare:      return 'Rare';
      case BadgeTier.legendary: return 'Légendaire';
    }
  }
}
