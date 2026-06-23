import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/constants/app_constants.dart';
import '../../../../shared/widgets/app_background.dart';
import '../../../capture/data/capture_model.dart';
import '../../../capture/presentation/providers/capture_provider.dart';
import '../../../objectives/presentation/providers/habits_provider.dart';
import '../../data/weekly_review_model.dart';
import '../../data/weekly_review_repository.dart';
import '../providers/weekly_review_provider.dart';

// ── Écran de revue hebdomadaire refondu ──────────────────────────
class WeeklyReviewScreen extends ConsumerStatefulWidget {
  const WeeklyReviewScreen({super.key});

  @override
  ConsumerState<WeeklyReviewScreen> createState() => _WeeklyReviewScreenState();
}

class _WeeklyReviewScreenState extends ConsumerState<WeeklyReviewScreen>
    with TickerProviderStateMixin {

  int _step = 0; // 0=Bilan 1=Trier 2=Comprendre 3=Préparer

  final _bestMomentCtrl  = TextEditingController();
  final _mainBlockerCtrl = TextEditingController();
  final _intentionCtrl   = TextEditingController();
  String? _selectedHabit;
  int _capturesProcessed = 0;

  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: AppConstants.animNormal)
      ..forward();
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _bestMomentCtrl.dispose();
    _mainBlockerCtrl.dispose();
    _intentionCtrl.dispose();
    super.dispose();
  }

  void _next() async {
    await _fadeCtrl.reverse();
    setState(() => _step = math.min(_step + 1, 3));
    _fadeCtrl.forward();
  }

  void _prev() async {
    if (_step == 0) return;
    await _fadeCtrl.reverse();
    setState(() => _step--);
    _fadeCtrl.forward();
  }

  Future<void> _finish(WeeklySummary summary) async {
    final weekStart = WeeklyReviewRepository.weekStartFor(DateTime.now());
    final review = WeeklyReview(
      userId: '',
      weekStart: weekStart,
      tasksCompleted: summary.tasksCompleted,
      tasksTotal: summary.tasksTotal,
      focusMinutes: summary.focusMinutes,
      checkinsDone: summary.checkinsDone,
      avgMood: summary.avgMood,
      avgEnergy: summary.avgEnergy,
      completionRate: summary.completionRate,
      badge: summary.badge,
      bestMoment: _bestMomentCtrl.text.trim().isEmpty
          ? null : _bestMomentCtrl.text.trim(),
      mainBlocker: _mainBlockerCtrl.text.trim().isEmpty
          ? null : _mainBlockerCtrl.text.trim(),
      weeklyIntention: _intentionCtrl.text.trim().isEmpty
          ? null : _intentionCtrl.text.trim(),
      focusHabit: _selectedHabit,
      capturesProcessed: _capturesProcessed,
      createdAt: DateTime.now(),
    );
    await ref.read(currentWeekReviewProvider.notifier).save(review);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final summaryAsync = ref.watch(currentWeekSummaryProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: SafeArea(
          child: summaryAsync.when(
            loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primary)),
            error: (_, __) => Center(
                child: Text('Erreur de chargement',
                    style: AppTextStyles.bodyMedium(color: AppColors.textDark))),
            data: (summary) => Column(
              children: [
                _Header(
                  step: _step,
                  onBack: _step == 0 ? null : _prev,
                  onClose: () => context.pop(),
                ),
                _ProgressBar(step: _step),
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: _buildStep(summary, isDark),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep(WeeklySummary summary, bool isDark) {
    switch (_step) {
      case 0:
        return _StepBilan(summary: summary, isDark: isDark, onNext: _next);
      case 1:
        return _StepTrier(
          onProcessed: (count) => setState(() => _capturesProcessed += count),
          onNext: _next,
          isDark: isDark,
        );
      case 2:
        return _StepComprendre(
          bestCtrl: _bestMomentCtrl,
          blockerCtrl: _mainBlockerCtrl,
          onNext: _next,
          isDark: isDark,
        );
      case 3:
        return _StepPreparer(
          intentionCtrl: _intentionCtrl,
          selectedHabit: _selectedHabit,
          onHabitSelected: (h) => setState(() => _selectedHabit = h),
          onFinish: () => _finish(summary),
          isDark: isDark,
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

// ── Header ────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  const _Header({required this.step, this.onBack, required this.onClose});
  final int step;
  final VoidCallback? onBack;
  final VoidCallback onClose;

  static const _titles = [
    'Ton bilan', 'Vide ta tête', 'Ce qui compte', 'La semaine prochaine'
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: Icon(
              Icons.arrow_back_ios_rounded,
              color: onBack != null
                  ? AppColors.primaryLight
                  : Colors.transparent,
              size: 20,
            ),
          ),
          const Spacer(),
          Column(
            children: [
              Text(_titles[step],
                  style: AppTextStyles.headingMedium(color: AppColors.textDark)),
              Text('5 min · Étape ${step + 1}/4',
                  style: AppTextStyles.caption(color: AppColors.textDarkMuted)),
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: onClose,
            child: const Icon(Icons.close_rounded,
                color: AppColors.textDarkMuted, size: 22),
          ),
        ],
      ),
    );
  }
}

// ── Barre de progression ──────────────────────────────────────────
class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.step});
  final int step;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: List.generate(4, (i) {
          final active = i <= step;
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
              height: 4,
              decoration: BoxDecoration(
                color: active
                    ? AppColors.primary
                    : AppColors.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// ÉTAPE 1 — BILAN AUTO
// ══════════════════════════════════════════════════════════════════
class _StepBilan extends StatelessWidget {
  const _StepBilan(
      {required this.summary, required this.isDark, required this.onNext});
  final WeeklySummary summary;
  final bool isDark;
  final VoidCallback onNext;

  String get _focusLabel {
    final h = summary.focusMinutes ~/ 60;
    final m = summary.focusMinutes % 60;
    if (h == 0) return '${m}min';
    if (m == 0) return '${h}h';
    return '${h}h${m}min';
  }

  @override
  Widget build(BuildContext context) {
    final badge = summary.badge;
    final isResilient = badge == ReviewBadge.resilient;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _BadgeCard(badge: badge),
          const SizedBox(height: 16),

          if (isResilient)
            _InsightCard(
              emoji: '💪',
              text: 'Tu as avancé malgré une humeur basse — '
                  'tu es plus solide que tu ne le crois.',
              color: AppColors.chartAmber,
            ),

          Row(children: [
            Expanded(child: _StatCard(
              emoji: '✅',
              value: '${summary.tasksCompleted}/${summary.tasksTotal}',
              label: 'tâches faites',
              subLabel: '${summary.completionRate.toStringAsFixed(0)}%',
              color: AppColors.accent,
            )),
            const SizedBox(width: 12),
            Expanded(child: _StatCard(
              emoji: '⏱',
              value: _focusLabel,
              label: 'de focus',
              color: AppColors.primary,
            )),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _StatCard(
              emoji: '🌅',
              value: '${summary.checkinsDone}/14',
              label: 'check-ins',
              color: AppColors.chartAmber,
            )),
            const SizedBox(width: 12),
            Expanded(child: _StatCard(
              emoji: '😊',
              value: summary.avgMood != null
                  ? '${summary.avgMood!.toStringAsFixed(1)}/10'
                  : 'N/A',
              label: 'humeur moy.',
              color: AppColors.secondary,
            )),
          ]),
          const SizedBox(height: 20),

          Text('Tâches par jour',
              style: AppTextStyles.labelMedium(color: AppColors.textDarkMuted)),
          const SizedBox(height: 10),
          _TasksBarChart(tasksByDay: summary.tasksByDay),
          const SizedBox(height: 20),

          if (summary.moodByDay.any((m) => m != null)) ...[
            Text('Humeur & énergie',
                style: AppTextStyles.labelMedium(color: AppColors.textDarkMuted)),
            const SizedBox(height: 6),
            Row(children: [
              _LegendDot(color: AppColors.primary, label: 'Humeur'),
              const SizedBox(width: 12),
              _LegendDot(color: AppColors.accent, label: 'Énergie'),
            ]),
            const SizedBox(height: 8),
            _MoodLineChart(
              moodByDay: summary.moodByDay,
              energyByDay: summary.energyByDay,
            ),
            const SizedBox(height: 20),
          ],

          _NextButton(label: 'Trier mes captures', onTap: onNext),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label,
            style: AppTextStyles.caption(color: AppColors.textDarkMuted)),
      ],
    );
  }
}

class _BadgeCard extends StatelessWidget {
  const _BadgeCard({required this.badge});
  final ReviewBadge badge;

  Color get _color {
    switch (badge) {
      case ReviewBadge.fire:      return AppColors.secondary;
      case ReviewBadge.solid:     return AppColors.primary;
      case ReviewBadge.resilient: return AppColors.chartAmber;
      case ReviewBadge.gentle:    return AppColors.accent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        border: Border.all(color: _color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Text(badge.emoji, style: const TextStyle(fontSize: 36)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(badge.label,
                    style: AppTextStyles.headingSmall(color: AppColors.textDark)),
                const SizedBox(height: 4),
                Text(badge.message,
                    style: AppTextStyles.bodySmall(color: AppColors.textDarkMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard(
      {required this.emoji, required this.text, required this.color});
  final String emoji;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(child: Text(text,
              style: AppTextStyles.bodySmall(color: AppColors.textDark))),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.emoji, required this.value,
      required this.label, this.subLabel, required this.color});
  final String emoji;
  final String value;
  final String label;
  final String? subLabel;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 8),
          Text(value,
              style: AppTextStyles.headingMedium(color: AppColors.textDark)),
          Text(label,
              style: AppTextStyles.caption(color: AppColors.textDarkMuted)),
          if (subLabel != null) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(subLabel!,
                  style: AppTextStyles.caption(color: color)
                      .copyWith(fontWeight: FontWeight.w700)),
            ),
          ],
        ],
      ),
    );
  }
}

class _TasksBarChart extends StatelessWidget {
  const _TasksBarChart({required this.tasksByDay});
  final List<int> tasksByDay;

  static const _days = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

  @override
  Widget build(BuildContext context) {
    final maxVal = tasksByDay.fold(0, math.max).toDouble();
    if (maxVal == 0) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(child: Text('Aucune tâche complétée cette semaine',
            style: AppTextStyles.caption(color: AppColors.textDarkMuted))),
      );
    }
    return SizedBox(
      height: 120,
      child: BarChart(BarChartData(
        maxY: maxVal + 1,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (val, _) => Text(_days[val.toInt()],
                style: AppTextStyles.caption(color: AppColors.textDarkMuted)),
          )),
        ),
        barGroups: List.generate(7, (i) => BarChartGroupData(
          x: i,
          barRods: [BarChartRodData(
            toY: tasksByDay[i].toDouble(),
            color: AppColors.primary,
            width: 20,
            borderRadius: BorderRadius.circular(6),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: maxVal + 1,
              color: AppColors.primary.withValues(alpha: 0.08),
            ),
          )],
        )),
      )),
    );
  }
}

class _MoodLineChart extends StatelessWidget {
  const _MoodLineChart(
      {required this.moodByDay, required this.energyByDay});
  final List<double?> moodByDay;
  final List<double?> energyByDay;

  LineChartBarData _line(List<double?> data, Color color) {
    final spots = <FlSpot>[];
    for (var i = 0; i < data.length; i++) {
      if (data[i] != null) spots.add(FlSpot(i.toDouble(), data[i]!));
    }
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      color: color,
      barWidth: 2.5,
      dotData: FlDotData(
        show: true,
        getDotPainter: (_, __, ___, ____) =>
            FlDotCirclePainter(radius: 3, color: color, strokeWidth: 0),
      ),
      belowBarData: BarAreaData(
          show: true, color: color.withValues(alpha: 0.08)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 130,
      child: LineChart(LineChartData(
        minY: 0,
        maxY: 10,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 5,
          getDrawingHorizontalLine: (_) => FlLine(
            color: Colors.white.withValues(alpha: 0.06),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(
            showTitles: true,
            interval: 5,
            reservedSize: 24,
            getTitlesWidget: (v, _) => Text(v.toInt().toString(),
                style: AppTextStyles.caption(color: AppColors.textDarkMuted)),
          )),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        lineBarsData: [
          _line(moodByDay, AppColors.primary),
          _line(energyByDay, AppColors.accent),
        ],
      )),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// ÉTAPE 2 — TRIER LES CAPTURES
// ══════════════════════════════════════════════════════════════════
class _StepTrier extends ConsumerStatefulWidget {
  const _StepTrier(
      {required this.onProcessed, required this.onNext, required this.isDark});
  final ValueChanged<int> onProcessed;
  final VoidCallback onNext;
  final bool isDark;

  @override
  ConsumerState<_StepTrier> createState() => _StepTrierState();
}

class _StepTrierState extends ConsumerState<_StepTrier> {
  List<CaptureItem> _remaining = [];
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  void _load() {
    final captures = ref.read(captureProvider).value ?? [];
    setState(() {
      _remaining = captures.where((c) => !c.isProcessed).toList();
      _loaded = true;
    });
  }

  Future<void> _process(CaptureItem item, String destination) async {
    await ref.read(captureProvider.notifier).markProcessed(
        item.id, destination: destination);
    setState(() => _remaining.remove(item));
    widget.onProcessed(1);
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primary));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Vide ta tête',
              style: AppTextStyles.headingLarge(color: AppColors.textDark)),
          const SizedBox(height: 4),
          Text('Décide quoi faire de chaque capture. Aucune ne se perd.',
              style: AppTextStyles.bodySmall(color: AppColors.textDarkMuted)),
          const SizedBox(height: 20),

          if (_remaining.isEmpty)
            _InsightCard(
              emoji: '✨',
              text: 'Aucune capture en attente. Ta tête est déjà claire !',
              color: AppColors.accent,
            )
          else ...[
            Text(
              '${_remaining.length} capture${_remaining.length > 1 ? 's' : ''} à trier',
              style: AppTextStyles.labelMedium(color: AppColors.textDarkMuted),
            ),
            const SizedBox(height: 12),
            ..._remaining.map((c) => _CaptureCard(
              item: c,
              onFlash:   () => _process(c, 'flash'),
              onProject: () => _process(c, 'project'),
              onIgnore:  () => _process(c, 'ignore'),
            )),
          ],

          const SizedBox(height: 8),
          _NextButton(label: 'Continuer', onTap: widget.onNext),
        ],
      ),
    );
  }
}

class _CaptureCard extends StatelessWidget {
  const _CaptureCard({required this.item, required this.onFlash,
      required this.onProject, required this.onIgnore});
  final CaptureItem item;
  final VoidCallback onFlash;
  final VoidCallback onProject;
  final VoidCallback onIgnore;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item.content,
              style: AppTextStyles.bodyMedium(color: AppColors.textDark)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _ActionChip(label: '⚡ Flash',  color: AppColors.chartAmber, onTap: onFlash),
              _ActionChip(label: '📁 Projet', color: AppColors.primary,    onTap: onProject),
              _ActionChip(label: 'Ignorer',   color: AppColors.textDarkMuted, onTap: onIgnore),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip(
      {required this.label, required this.color, required this.onTap});
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Text(label,
            style: AppTextStyles.caption(color: color)
                .copyWith(fontWeight: FontWeight.w600)),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// ÉTAPE 3 — COMPRENDRE
// ══════════════════════════════════════════════════════════════════
class _StepComprendre extends StatelessWidget {
  const _StepComprendre({required this.bestCtrl, required this.blockerCtrl,
      required this.onNext, required this.isDark});
  final TextEditingController bestCtrl;
  final TextEditingController blockerCtrl;
  final VoidCallback onNext;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Prends un moment',
              style: AppTextStyles.headingLarge(color: AppColors.textDark)),
          const SizedBox(height: 4),
          Text(
            'Deux questions, tout optionnel. Tes réponses s\'accumulent semaine après semaine.',
            style: AppTextStyles.bodySmall(color: AppColors.textDarkMuted),
          ),
          const SizedBox(height: 24),
          _ReviewQuestion(
            emoji: '🌟',
            question: 'Qu\'est-ce qui t\'a le plus aidé à avancer cette semaine ?',
            controller: bestCtrl,
            hint: 'Une routine, une décision, une personne...',
          ),
          const SizedBox(height: 20),
          _ReviewQuestion(
            emoji: '🔍',
            question: 'Qu\'est-ce qui t\'a freiné ?',
            controller: blockerCtrl,
            hint: 'Un obstacle, une distraction, un manque...',
          ),
          const SizedBox(height: 32),
          _NextButton(label: 'Préparer la suite', onTap: onNext),
        ],
      ),
    );
  }
}

class _ReviewQuestion extends StatelessWidget {
  const _ReviewQuestion({required this.emoji, required this.question,
      required this.controller, required this.hint});
  final String emoji;
  final String question;
  final TextEditingController controller;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Expanded(child: Text(question,
                style: AppTextStyles.bodyLarge(color: AppColors.textDark))),
          ],
        ),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          style: AppTextStyles.bodyMedium(color: AppColors.textDark),
          maxLines: 3,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.bodySmall(color: AppColors.textDarkMuted),
            filled: true,
            fillColor: AppColors.surfaceDark,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  BorderSide(color: AppColors.primary.withValues(alpha: 0.2)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  BorderSide(color: AppColors.primary.withValues(alpha: 0.2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            contentPadding: const EdgeInsets.all(14),
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// ÉTAPE 4 — PRÉPARER
// ══════════════════════════════════════════════════════════════════
class _StepPreparer extends ConsumerWidget {
  const _StepPreparer({required this.intentionCtrl, required this.selectedHabit,
      required this.onHabitSelected, required this.onFinish, required this.isDark});
  final TextEditingController intentionCtrl;
  final String? selectedHabit;
  final ValueChanged<String?> onHabitSelected;
  final VoidCallback onFinish;
  final bool isDark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(habitsProvider).valueOrNull ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('La semaine prochaine',
              style: AppTextStyles.headingLarge(color: AppColors.textDark)),
          const SizedBox(height: 4),
          Text(
            'Pose ton intention. Elle apparaîtra sur ton tableau de bord toute la semaine.',
            style: AppTextStyles.bodySmall(color: AppColors.textDarkMuted),
          ),
          const SizedBox(height: 24),

          _ReviewQuestion(
            emoji: '🎯',
            question: 'Mon intention pour la semaine prochaine',
            controller: intentionCtrl,
            hint: 'Ex : Finir la démo client et avancer sur ma prospection.',
          ),
          const SizedBox(height: 24),

          if (habits.isNotEmpty) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('✨', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Expanded(child: Text(
                  'Une habitude à soigner particulièrement',
                  style: AppTextStyles.bodyLarge(color: AppColors.textDark),
                )),
              ],
            ),
            const SizedBox(height: 4),
            Text('Elle sera mise en avant dans ton Suivi du jour.',
                style: AppTextStyles.caption(color: AppColors.textDarkMuted)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: habits.map((h) {
                final selected = selectedHabit == h.id;
                return GestureDetector(
                  onTap: () => onHabitSelected(selected ? null : h.id),
                  child: AnimatedContainer(
                    duration: AppConstants.animFast,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primary.withValues(alpha: 0.2)
                          : AppColors.surfaceDark,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected
                            ? AppColors.primary
                            : AppColors.primary.withValues(alpha: 0.2),
                        width: selected ? 1.5 : 1,
                      ),
                    ),
                    child: Text('${h.emoji} ${h.title}',
                        style: AppTextStyles.labelMedium(
                            color: selected
                                ? AppColors.primaryLight
                                : AppColors.textDark)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
          ] else
            const SizedBox(height: 32),

          GestureDetector(
            onTap: onFinish,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: AppColors.gradientMain),
                borderRadius: BorderRadius.circular(AppConstants.radiusPill),
              ),
              child: Text(
                'Terminer ma revue',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyLarge(color: Colors.white)
                    .copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Bouton suivant générique ──────────────────────────────────────
class _NextButton extends StatelessWidget {
  const _NextButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(AppConstants.radiusPill),
        ),
        child: Text(label,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyLarge(color: Colors.white)
                .copyWith(fontWeight: FontWeight.w700)),
      ),
    );
  }
}
