import 'package:flutter/material.dart';
import '../../../../shared/theme/app_colors.dart';

enum MeditationTheme { focus, stress, sleep, confidence, energy }

extension MeditationThemeExt on MeditationTheme {
  String get label {
    switch (this) {
      case MeditationTheme.focus:      return 'Focus';
      case MeditationTheme.stress:     return 'Anti-stress';
      case MeditationTheme.sleep:      return 'Sommeil';
      case MeditationTheme.confidence: return 'Confiance';
      case MeditationTheme.energy:     return 'Énergie';
    }
  }

  String get emoji {
    switch (this) {
      case MeditationTheme.focus:      return '🧠';
      case MeditationTheme.stress:     return '🌿';
      case MeditationTheme.sleep:      return '🌙';
      case MeditationTheme.confidence: return '💪';
      case MeditationTheme.energy:     return '⚡';
    }
  }

  Color get color {
    switch (this) {
      case MeditationTheme.focus:      return AppColors.primary;
      case MeditationTheme.stress:     return AppColors.accent;
      case MeditationTheme.sleep:      return AppColors.primaryLight;
      case MeditationTheme.confidence: return AppColors.chartAmber;
      case MeditationTheme.energy:     return AppColors.secondary;
    }
  }

  List<Color> get gradient {
    switch (this) {
      case MeditationTheme.focus:
        return [const Color(0xFF3B1FA3), AppColors.primary];
      case MeditationTheme.stress:
        return [const Color(0xFF006B65), AppColors.accent];
      case MeditationTheme.sleep:
        return [const Color(0xFF0D0B1E), AppColors.primaryLight];
      case MeditationTheme.confidence:
        return [const Color(0xFF7A5500), AppColors.chartAmber];
      case MeditationTheme.energy:
        return [const Color(0xFF8A1A2E), AppColors.secondary];
    }
  }
}

class Meditation {
  final String id;
  final String title;
  final String description;
  final MeditationTheme theme;
  final int durationMinutes;
  // Chemin vers le fichier audio dans assets/audio/meditations/
  final String audioAssetPath;
  // Optionnel : image dans assets/images/meditations/
  final String? imageAssetPath;

  /// true = réservé aux abonnés Pro
  final bool isPro;

  /// true = disponible gratuitement mais audio pas encore enregistré
  final bool isComingSoon;

  const Meditation({
    required this.id,
    required this.title,
    required this.description,
    required this.theme,
    required this.durationMinutes,
    required this.audioAssetPath,
    this.imageAssetPath,
    this.isPro = false,
    this.isComingSoon = false,
  });

  String get durationLabel => '$durationMinutes min';

  // ── Catalogue des méditations ─────────────────────────────────
  // Pour ajouter une méditation : copie un bloc et modifie les valeurs.
  // Place le fichier audio dans : assets/audio/meditations/
  // Place l'image (optionnel) dans : assets/images/meditations/
  static final List<Meditation> catalog = const [
    // ── GRATUIT — Boost du matin (énergie) ───────────────
    // Disponible gratuitement, audio en cours d'enregistrement
    Meditation(
      id: 'energy_3min',
      title: 'Boost du matin',
      description: 'Réveille ton énergie en 3 minutes et commence la journée avec élan.',
      theme: MeditationTheme.energy,
      durationMinutes: 3,
      audioAssetPath: 'assets/audio/meditations/energy_3min.mp3',
      imageAssetPath: 'images/meditations/energy.jpg',
    ),

    // ── GRATUIT — Voyage nocturne (sommeil) ───────────────
    Meditation(
      id: 'sleep_7min',
      title: 'Voyage nocturne',
      description: 'Laisse ton corps se détendre et glisser doucement vers le sommeil.',
      theme: MeditationTheme.sleep,
      durationMinutes: 7,
      audioAssetPath: 'assets/audio/meditations/sleep_7min.mp3',
      imageAssetPath: 'images/meditations/sleep.jpg',
    ),

    // ── PRO — Focus ───────────────────────────────────────
    Meditation(
      id: 'focus_3min',
      title: 'Clarté immédiate',
      description: 'Une pause de 3 minutes pour retrouver ta concentration et reprendre le fil.',
      theme: MeditationTheme.focus,
      durationMinutes: 3,
      audioAssetPath: 'assets/audio/meditations/focus_3min.mp3',
      imageAssetPath: 'images/meditations/focus.jpg',
      isPro: true,
    ),
    Meditation(
      id: 'focus_7min',
      title: 'Zone de concentration',
      description: 'Entre dans ta zone. 7 minutes pour ancrer ton attention et avancer avec clarté.',
      theme: MeditationTheme.focus,
      durationMinutes: 7,
      audioAssetPath: 'assets/audio/meditations/focus_7min.mp3',
      imageAssetPath: 'images/meditations/focus.jpg',
      isPro: true,
    ),

    // ── PRO — Anti-stress ─────────────────────────────────
    Meditation(
      id: 'stress_5min',
      title: 'Lâcher prise',
      description: '5 minutes pour relâcher la tension et revenir à toi, ici et maintenant.',
      theme: MeditationTheme.stress,
      durationMinutes: 5,
      audioAssetPath: 'assets/audio/meditations/stress_5min.mp3',
      imageAssetPath: 'images/meditations/stress.jpg',
      isPro: true,
    ),
    Meditation(
      id: 'stress_10min',
      title: 'Océan de calme',
      description: 'Plonge dans un espace de sérénité. 15 minutes pour dissoudre le stress.',
      theme: MeditationTheme.stress,
      durationMinutes: 15,
      audioAssetPath: 'assets/audio/meditations/stress_10min.mp3',
      imageAssetPath: 'images/meditations/stress.jpg',
      isPro: true,
    ),

    // ── PRO — Sommeil ─────────────────────────────────────
    Meditation(
      id: 'sleep_10min',
      title: 'Détente profonde',
      description: 'Un scan corporel complet pour relâcher chaque tension avant de dormir.',
      theme: MeditationTheme.sleep,
      durationMinutes: 15,
      audioAssetPath: 'assets/audio/meditations/sleep_10min.mp3',
      imageAssetPath: 'images/meditations/sleep.jpg',
      isPro: true,
    ),

    // ── PRO — Confiance ───────────────────────────────────
    Meditation(
      id: 'confidence_5min',
      title: 'Ancrage intérieur',
      description: 'Reconnecte-toi à ta force et à ce qui te rend unique en tant qu\'indépendant.',
      theme: MeditationTheme.confidence,
      durationMinutes: 5,
      audioAssetPath: 'assets/audio/meditations/confidence_5min.mp3',
      imageAssetPath: 'images/meditations/confidence.jpg',
      isPro: true,
    ),
    Meditation(
      id: 'confidence_10min',
      title: 'Ta propre lumière',
      description: 'Explore ta valeur profonde et avance avec confiance vers tes projets.',
      theme: MeditationTheme.confidence,
      durationMinutes: 10,
      audioAssetPath: 'assets/audio/meditations/confidence_10min.mp3',
      imageAssetPath: 'images/meditations/confidence.jpg',
      isPro: true,
    ),

    // ── PRO — Énergie ─────────────────────────────────────
    Meditation(
      id: 'energy_5min',
      title: 'Souffle vital',
      description: 'Retrouve ton élan et ta vitalité en 5 minutes de pleine conscience dynamique.',
      theme: MeditationTheme.energy,
      durationMinutes: 5,
      audioAssetPath: 'assets/audio/meditations/energy_5min.mp3',
      imageAssetPath: 'images/meditations/energy.jpg',
      isPro: true,
    ),
  ];
}
