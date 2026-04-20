import 'package:flutter/material.dart';

class SleepEntry {
  final DateTime date;
  final TimeOfDay bedtime;
  final TimeOfDay wakeTime;
  final int quality; // 1–5
  final String? note;

  const SleepEntry({
    required this.date,
    required this.bedtime,
    required this.wakeTime,
    required this.quality,
    this.note,
  });

  /// Durée totale en heures (gère le passage minuit)
  double get durationHours {
    final bedMinutes = bedtime.hour * 60 + bedtime.minute;
    final wakeMinutes = wakeTime.hour * 60 + wakeTime.minute;
    final diff = wakeMinutes < bedMinutes
        ? (24 * 60 - bedMinutes) + wakeMinutes
        : wakeMinutes - bedMinutes;
    return diff / 60.0;
  }

  String get durationLabel {
    final h = durationHours.floor();
    final m = ((durationHours - h) * 60).round();
    return m == 0 ? '${h}h' : '${h}h${m.toString().padLeft(2, '0')}';
  }

  String get qualityEmoji {
    switch (quality) {
      case 1: return '💀';
      case 2: return '😩';
      case 3: return '😐';
      case 4: return '😌';
      case 5: return '🌟';
      default: return '😐';
    }
  }

  String get qualityLabel {
    switch (quality) {
      case 1: return 'Catastrophique';
      case 2: return 'Mauvais';
      case 3: return 'Correct';
      case 4: return 'Bon';
      case 5: return 'Excellent';
      default: return 'Correct';
    }
  }
}

// ─── Mock data 7 derniers jours ───────────────────────────────────────────────

final List<SleepEntry> mockSleepHistory = [
  SleepEntry(
    date: DateTime.now().subtract(const Duration(days: 6)),
    bedtime: const TimeOfDay(hour: 23, minute: 30),
    wakeTime: const TimeOfDay(hour: 7, minute: 15),
    quality: 4,
  ),
  SleepEntry(
    date: DateTime.now().subtract(const Duration(days: 5)),
    bedtime: const TimeOfDay(hour: 0, minute: 45),
    wakeTime: const TimeOfDay(hour: 7, minute: 30),
    quality: 3,
  ),
  SleepEntry(
    date: DateTime.now().subtract(const Duration(days: 4)),
    bedtime: const TimeOfDay(hour: 22, minute: 0),
    wakeTime: const TimeOfDay(hour: 6, minute: 30),
    quality: 5,
  ),
  SleepEntry(
    date: DateTime.now().subtract(const Duration(days: 3)),
    bedtime: const TimeOfDay(hour: 1, minute: 0),
    wakeTime: const TimeOfDay(hour: 7, minute: 45),
    quality: 2,
  ),
  SleepEntry(
    date: DateTime.now().subtract(const Duration(days: 2)),
    bedtime: const TimeOfDay(hour: 23, minute: 0),
    wakeTime: const TimeOfDay(hour: 7, minute: 0),
    quality: 4,
  ),
  SleepEntry(
    date: DateTime.now().subtract(const Duration(days: 1)),
    bedtime: const TimeOfDay(hour: 23, minute: 45),
    wakeTime: const TimeOfDay(hour: 7, minute: 30),
    quality: 4,
    note: 'Bonne nuit, réveillé une fois',
  ),
];

// ─── Helpers ──────────────────────────────────────────────────────────────────

double avgSleepDuration(List<SleepEntry> entries) {
  if (entries.isEmpty) return 0;
  return entries.fold(0.0, (s, e) => s + e.durationHours) / entries.length;
}

double avgSleepQuality(List<SleepEntry> entries) {
  if (entries.isEmpty) return 0;
  return entries.fold(0.0, (s, e) => s + e.quality) / entries.length;
}

String sleepTip(double avgHours, double avgQuality) {
  if (avgHours < 6) return 'Tu dors moins de 6h en moyenne. C\'est insuffisant pour récupérer. Essaie de te coucher 30 min plus tôt chaque soir.';
  if (avgHours > 9) return 'Tu dors beaucoup. Si tu te sens toujours fatigué(e), une consultation peut aider.';
  if (avgQuality < 3) return 'Ta qualité de sommeil est faible. Essaie d\'éviter les écrans 1h avant de dormir.';
  if (avgQuality >= 4 && avgHours >= 7) return 'Excellent sommeil ! Continue comme ça, tu récupères bien.';
  return 'Ton sommeil est correct. Vise 7-8h pour optimiser ton énergie.';
}
