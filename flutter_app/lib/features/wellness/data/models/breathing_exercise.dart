import 'package:flutter/material.dart';
import '../../../../shared/theme/app_colors.dart';

enum BreathingPhase { inhale, hold, exhale, pause }

extension BreathingPhaseExt on BreathingPhase {
  String get label {
    switch (this) {
      case BreathingPhase.inhale: return 'Inspire';
      case BreathingPhase.hold:   return 'Retiens';
      case BreathingPhase.exhale: return 'Expire';
      case BreathingPhase.pause:  return 'Pause';
    }
  }

  // true = pétales s'ouvrent, false = se ferment
  bool get isExpanding => this == BreathingPhase.inhale;
  // true = animation figée (hold ou pause)
  bool get isStatic => this == BreathingPhase.hold || this == BreathingPhase.pause;
  // Valeur cible de l'expansion (0.0 ou 1.0)
  double get targetExpandValue => isExpanding ? 1.0 : (this == BreathingPhase.hold ? 1.0 : 0.0);
}

class BreathingPhaseConfig {
  final BreathingPhase phase;
  final int seconds;

  const BreathingPhaseConfig({required this.phase, required this.seconds});
}

class BreathingExercise {
  final String id;
  final String name;
  final String subtitle;   // ex. "5 · 5" ou "4 · 4 · 4 · 4"
  final String emoji;
  final String description;
  final String benefit;
  final List<BreathingPhaseConfig> phases;
  final int sessionMinutes;
  final Color accentColor;

  const BreathingExercise({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.emoji,
    required this.description,
    required this.benefit,
    required this.phases,
    required this.sessionMinutes,
    required this.accentColor,
  });

  int get cycleSeconds => phases.fold(0, (sum, p) => sum + p.seconds);
  int get totalCycles => ((sessionMinutes * 60) / cycleSeconds).floor();

  static const List<BreathingExercise> catalog = [
    // ── Cohérence cardiaque ──────────────────────────────────
    BreathingExercise(
      id: 'cardiac_coherence',
      name: 'Cohérence cardiaque',
      subtitle: '5 · 5',
      emoji: '💜',
      description: 'La technique la plus étudiée pour réduire le stress. 5 secondes d\'inspiration, 5 secondes d\'expiration, pendant 5 minutes.',
      benefit: 'Réduit le cortisol, améliore la clarté mentale',
      phases: [
        BreathingPhaseConfig(phase: BreathingPhase.inhale, seconds: 5),
        BreathingPhaseConfig(phase: BreathingPhase.exhale, seconds: 5),
      ],
      sessionMinutes: 5,
      accentColor: AppColors.primary,
    ),

    // ── Box Breathing ─────────────────────────────────────────
    BreathingExercise(
      id: 'box_breathing',
      name: 'Box Breathing',
      subtitle: '4 · 4 · 4 · 4',
      emoji: '🟦',
      description: 'La technique des forces spéciales. 4 temps égaux forment un carré parfait : inspire, retiens, expire, pause.',
      benefit: 'Gestion du stress intense, recentrage immédiat',
      phases: [
        BreathingPhaseConfig(phase: BreathingPhase.inhale, seconds: 4),
        BreathingPhaseConfig(phase: BreathingPhase.hold,   seconds: 4),
        BreathingPhaseConfig(phase: BreathingPhase.exhale, seconds: 4),
        BreathingPhaseConfig(phase: BreathingPhase.pause,  seconds: 4),
      ],
      sessionMinutes: 4,
      accentColor: AppColors.accent,
    ),

    // ── Respiration en carré (version longue) ─────────────────
    BreathingExercise(
      id: 'square_breathing',
      name: 'Respiration en carré',
      subtitle: '6 · 6 · 6 · 6',
      emoji: '🌊',
      description: 'Une version plus profonde et lente. 6 secondes par côté pour une relaxation en profondeur et une récupération complète.',
      benefit: 'Récupération profonde, sommeil, anxiété chronique',
      phases: [
        BreathingPhaseConfig(phase: BreathingPhase.inhale, seconds: 6),
        BreathingPhaseConfig(phase: BreathingPhase.hold,   seconds: 6),
        BreathingPhaseConfig(phase: BreathingPhase.exhale, seconds: 6),
        BreathingPhaseConfig(phase: BreathingPhase.pause,  seconds: 6),
      ],
      sessionMinutes: 6,
      accentColor: AppColors.chartAmber,
    ),
  ];
}
