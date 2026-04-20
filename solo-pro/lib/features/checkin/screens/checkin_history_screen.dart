import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../models/checkin_models.dart';

class CheckinHistoryScreen extends StatelessWidget {
  const CheckinHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final entries = mockHistory;
    final avg = entries.isEmpty
        ? 0.0
        : entries.fold<double>(0, (s, e) => s + e.energyScore) / entries.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Historique émotionnel'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, size: 20),
            onPressed: () {},
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            _buildSummaryRow(avg, entries.length),
            const SizedBox(height: 24),
            const Text('Énergie sur 7 jours',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 16),
            _EnergyBarChart(entries: entries),
            const SizedBox(height: 28),
            const Text('Derniers check-ins',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            ...entries.reversed.map((e) => _CheckinCard(entry: e)),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(double avg, int count) {
    Color avgColor;
    String avgLabel;
    if (avg >= 7) {
      avgColor = AppColors.accentGreen;
      avgLabel = 'Excellent';
    } else if (avg >= 5) {
      avgColor = AppColors.accentYellow;
      avgLabel = 'Bien';
    } else {
      avgColor = AppColors.accent;
      avgLabel = 'À améliorer';
    }

    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            label: 'Moyenne énergie',
            value: avg.toStringAsFixed(1),
            unit: '/10',
            color: avgColor,
            sub: avgLabel,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(
            label: 'Check-ins réalisés',
            value: '$count',
            unit: ' jours',
            color: AppColors.primary,
            sub: 'cette semaine',
          ),
        ),
      ],
    );
  }
}

// ─── Graphique barres ─────────────────────────────────────────────────────────

class _EnergyBarChart extends StatelessWidget {
  final List<CheckinEntry> entries;

  const _EnergyBarChart({required this.entries});

  Color _barColor(double score) {
    if (score >= 7) return AppColors.accentGreen;
    if (score >= 4) return AppColors.accentYellow;
    return AppColors.accent;
  }

  String _dayLabel(DateTime d) {
    const labels = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
    return labels[d.weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    const chartHeight = 140.0;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          SizedBox(
            height: chartHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: entries.map((e) {
                final ratio = e.energyScore / 10;
                final color = _barColor(e.energyScore);
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Valeur au-dessus
                        Text(
                          e.energyScore.toStringAsFixed(0),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: color,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Barre
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 600),
                          height: (chartHeight - 24) * ratio,
                          decoration: BoxDecoration(
                            color: color,
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
          const SizedBox(height: 8),
          // Labels jours
          Row(
            children: entries.map((e) {
              final isToday = _isSameDay(e.date, DateTime.now());
              return Expanded(
                child: Text(
                  isToday ? 'Auj.' : _dayLabel(e.date),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight:
                        isToday ? FontWeight.w800 : FontWeight.w500,
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
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

// ─── Carte check-in ───────────────────────────────────────────────────────────

class _CheckinCard extends StatelessWidget {
  final CheckinEntry entry;

  const _CheckinCard({required this.entry});

  Color get _scoreColor {
    if (entry.energyScore >= 7) return AppColors.accentGreen;
    if (entry.energyScore >= 4) return AppColors.accentYellow;
    return AppColors.accent;
  }

  String get _dateLabel {
    final now = DateTime.now();
    final diff = now.difference(entry.date).inDays;
    if (diff == 0) return 'Aujourd\'hui';
    if (diff == 1) return 'Hier';
    const mois = [
      'jan', 'fév', 'mar', 'avr', 'mai', 'jun',
      'jul', 'aoû', 'sep', 'oct', 'nov', 'déc'
    ];
    return '${entry.date.day} ${mois[entry.date.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: _scoreColor.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _scoreColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                entry.isMorning ? '☀️' : '🌙',
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.isMorning ? 'Check-in matin' : 'Check-in soir',
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: AppColors.textPrimary),
                ),
                Text(
                  _dateLabel,
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${entry.energyScore}/10',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: _scoreColor,
                ),
              ),
              // Mini dots réponses
              Row(
                children: entry.answers.map((a) {
                  return Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(left: 3),
                    decoration: BoxDecoration(
                      color: _dotColor(a),
                      shape: BoxShape.circle,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _dotColor(int val) {
    if (val >= 4) return AppColors.accentGreen;
    if (val == 3) return AppColors.accentYellow;
    return AppColors.accent;
  }
}

// ─── Carte résumé ─────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color color;
  final String sub;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
    required this.sub,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 11, color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                TextSpan(
                  text: unit,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(sub,
              style: TextStyle(
                  fontSize: 11,
                  color: color,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
