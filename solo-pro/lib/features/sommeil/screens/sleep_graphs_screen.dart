import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_routes.dart';
import '../models/sleep_model.dart';

class SleepGraphsScreen extends StatelessWidget {
  const SleepGraphsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final entries = mockSleepHistory;
    final avgDuration = avgSleepDuration(entries);
    final avgQuality = avgSleepQuality(entries);
    final tip = sleepTip(avgDuration, avgQuality);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(context),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatsRow(avgDuration, avgQuality, entries),
                    const SizedBox(height: 24),
                    _buildDurationChart(entries),
                    const SizedBox(height: 20),
                    _buildQualityChart(entries),
                    const SizedBox(height: 20),
                    _buildSoloTip(tip, avgDuration, avgQuality),
                    const SizedBox(height: 20),
                    _buildSleepTips(),
                    const SizedBox(height: 20),
                    _buildHistoryList(entries),
                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            Navigator.pushReplacementNamed(context, AppRoutes.sleepEntry),
        backgroundColor: const Color(0xFF3D35CC),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Saisir cette nuit',
            style:
                TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }

  // ─── Header ───────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A2E),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back_ios_new,
                    color: Colors.white60, size: 18),
              ),
              const SizedBox(width: 12),
              const Text('Mon sommeil 😴',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 20),
          const Text('7 derniers jours',
              style: TextStyle(color: Colors.white54, fontSize: 12)),
          const SizedBox(height: 4),
          const Text('Analyse de ton sommeil',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  // ─── Stats résumé ─────────────────────────────────────────────────────────

  Widget _buildStatsRow(
      double avgDuration, double avgQuality, List<SleepEntry> entries) {
    Color durationColor;
    if (avgDuration >= 7) {
      durationColor = AppColors.accentGreen;
    } else if (avgDuration >= 6) {
      durationColor = AppColors.accentYellow;
    } else {
      durationColor = AppColors.accent;
    }

    Color qualityColor;
    if (avgQuality >= 4) {
      qualityColor = AppColors.accentGreen;
    } else if (avgQuality >= 3) {
      qualityColor = AppColors.accentYellow;
    } else {
      qualityColor = AppColors.accent;
    }

    final best = entries.isEmpty
        ? null
        : entries.reduce((a, b) =>
            a.durationHours > b.durationHours ? a : b);

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            emoji: '⏱️',
            value: '${avgDuration.toStringAsFixed(1)}h',
            label: 'Durée moyenne',
            color: durationColor,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            emoji: '⭐',
            value: avgQuality.toStringAsFixed(1),
            label: 'Qualité /5',
            color: qualityColor,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            emoji: '🏆',
            value: best != null ? best.durationLabel : '—',
            label: 'Meilleure nuit',
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  // ─── Graphique durée ──────────────────────────────────────────────────────

  Widget _buildDurationChart(List<SleepEntry> entries) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Durée de sommeil',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary)),
        const SizedBox(height: 4),
        const Text('En heures par nuit',
            style: TextStyle(
                color: AppColors.textSecondary, fontSize: 12)),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.fromLTRB(14, 16, 14, 10),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              // Ligne de référence 8h
              Stack(
                children: [
                  // Zone verte "idéal"
                  Positioned(
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 2,
                      color: AppColors.accentGreen.withValues(alpha: 0.2),
                    ),
                  ),
                  SizedBox(
                    height: 120,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: entries.map((e) {
                        final ratio = (e.durationHours / 10).clamp(0.0, 1.0);
                        Color barColor;
                        if (e.durationHours >= 7) {
                          barColor = AppColors.accentGreen;
                        } else if (e.durationHours >= 6) {
                          barColor = AppColors.accentYellow;
                        } else {
                          barColor = AppColors.accent;
                        }
                        return Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 4),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  e.durationLabel,
                                  style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      color: barColor),
                                ),
                                const SizedBox(height: 3),
                                Container(
                                  height: 100 * ratio,
                                  decoration: BoxDecoration(
                                    color: barColor,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: entries.map((e) {
                  final isToday = _isSameDay(
                      e.date, DateTime.now());
                  return Expanded(
                    child: Text(
                      _dayLabel(e.date),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: isToday
                            ? FontWeight.w800
                            : FontWeight.w500,
                        color: isToday
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Graphique qualité ────────────────────────────────────────────────────

  Widget _buildQualityChart(List<SleepEntry> entries) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Qualité de sommeil',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary)),
        const SizedBox(height: 4),
        const Text('Score 1–5 sur 7 jours',
            style: TextStyle(
                color: AppColors.textSecondary, fontSize: 12)),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              // Ligne avec points connectés (simulation)
              SizedBox(
                height: 80,
                child: CustomPaint(
                  size: const Size(double.infinity, 80),
                  painter: _QualityLinePainter(
                      entries.map((e) => e.quality.toDouble()).toList()),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: entries.map((e) {
                  return Column(
                    children: [
                      Text(e.qualityEmoji,
                          style: const TextStyle(fontSize: 16)),
                      Text(
                        _dayLabel(e.date),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight:
                              _isSameDay(e.date, DateTime.now())
                                  ? FontWeight.w800
                                  : FontWeight.w500,
                          color:
                              _isSameDay(e.date, DateTime.now())
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Conseil Solo ─────────────────────────────────────────────────────────

  Widget _buildSoloTip(
      String tip, double avgDuration, double avgQuality) {
    final isGood = avgDuration >= 7 && avgQuality >= 4;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isGood
            ? AppColors.accentGreen.withValues(alpha: 0.07)
            : AppColors.primary.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isGood
              ? AppColors.accentGreen.withValues(alpha: 0.2)
              : AppColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
                child: Text('🤖', style: TextStyle(fontSize: 20))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Analyse de Solo',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: AppColors.textSecondary)),
                const SizedBox(height: 4),
                Text(tip,
                    style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textPrimary,
                        height: 1.45)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Conseils hygiène du sommeil ──────────────────────────────────────────

  Widget _buildSleepTips() {
    const tips = [
      _SleepTip('🌑', 'Chambre sombre', 'Ton cerveau associe l\'obscurité totale à l\'endormissement.'),
      _SleepTip('🌡️', 'Température fraîche', '18–19°C favorise un sommeil profond.'),
      _SleepTip('📵', 'Pas d\'écran -1h', 'La lumière bleue bloque la mélatonine.'),
      _SleepTip('⏰', 'Horaires réguliers', 'Se lever à la même heure est plus puissant que l\'heure de coucher.'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Conseils hygiène du sommeil',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary)),
        const SizedBox(height: 12),
        ...tips.map((t) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.emoji,
                      style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t.title,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13)),
                        const SizedBox(height: 2),
                        Text(t.desc,
                            style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                                height: 1.4)),
                      ],
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  // ─── Liste historique ─────────────────────────────────────────────────────

  Widget _buildHistoryList(List<SleepEntry> entries) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Dernières nuits',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary)),
        const SizedBox(height: 12),
        ...entries.reversed.map((e) => _buildHistoryTile(e)),
      ],
    );
  }

  Widget _buildHistoryTile(SleepEntry entry) {
    Color qualityColor;
    if (entry.quality >= 4) {
      qualityColor = AppColors.accentGreen;
    } else if (entry.quality == 3) {
      qualityColor = AppColors.accentYellow;
    } else {
      qualityColor = AppColors.accent;
    }

    final bedH = entry.bedtime.hour.toString().padLeft(2, '0');
    final bedM = entry.bedtime.minute.toString().padLeft(2, '0');
    final wakeH = entry.wakeTime.hour.toString().padLeft(2, '0');
    final wakeM = entry.wakeTime.minute.toString().padLeft(2, '0');

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: qualityColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: qualityColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(entry.qualityEmoji,
                  style: const TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _dateLabel(entry.date),
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: AppColors.textPrimary),
                ),
                Text(
                  '$bedH:$bedM → $wakeH:$wakeM',
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textSecondary),
                ),
                if (entry.note != null)
                  Text(
                    entry.note!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textLight,
                        fontStyle: FontStyle.italic),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                entry.durationLabel,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: qualityColor),
              ),
              Row(
                children: List.generate(
                  entry.quality,
                  (_) => const Icon(Icons.star_rounded,
                      size: 10, color: AppColors.accentYellow),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _dayLabel(DateTime d) {
    const labels = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
    return labels[d.weekday - 1];
  }

  String _dateLabel(DateTime d) {
    final now = DateTime.now();
    final diff = now.difference(d).inDays;
    if (diff == 0) return 'Cette nuit';
    if (diff == 1) return 'Hier';
    const mois = ['jan', 'fév', 'mar', 'avr', 'mai', 'jun',
                  'jul', 'aoû', 'sep', 'oct', 'nov', 'déc'];
    return '${d.day} ${mois[d.month - 1]}';
  }
}

// ─── Painter courbe qualité ───────────────────────────────────────────────────

class _QualityLinePainter extends CustomPainter {
  final List<double> values; // 1–5

  _QualityLinePainter(this.values);

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;

    final paintLine = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final paintFill = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.primary.withValues(alpha: 0.15),
          AppColors.primary.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final paintDot = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;

    final stepX = size.width / (values.length - 1);

    Offset getPoint(int i) {
      final x = i * stepX;
      final y = size.height - ((values[i] - 1) / 4) * (size.height - 10) - 5;
      return Offset(x, y);
    }

    // Remplissage
    final fillPath = Path();
    fillPath.moveTo(0, size.height);
    for (int i = 0; i < values.length; i++) {
      fillPath.lineTo(getPoint(i).dx, getPoint(i).dy);
    }
    fillPath.lineTo(size.width, size.height);
    fillPath.close();
    canvas.drawPath(fillPath, paintFill);

    // Ligne
    final linePath = Path();
    linePath.moveTo(getPoint(0).dx, getPoint(0).dy);
    for (int i = 1; i < values.length; i++) {
      linePath.lineTo(getPoint(i).dx, getPoint(i).dy);
    }
    canvas.drawPath(linePath, paintLine);

    // Points
    for (int i = 0; i < values.length; i++) {
      canvas.drawCircle(getPoint(i), 4, paintDot);
      canvas.drawCircle(getPoint(i), 4,
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ─── Data classes locales ─────────────────────────────────────────────────────

class _SleepTip {
  final String emoji;
  final String title;
  final String desc;

  const _SleepTip(this.emoji, this.title, this.desc);
}

class _StatCard extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.emoji,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: color)),
          Text(label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 9, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
