import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/constants/app_constants.dart';
import '../../../../shared/navigation/app_router.dart';
import '../providers/dashboard_provider.dart';
import '../../data/dashboard_repository.dart';
import '../../../planner/presentation/providers/flow_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashAsync = ref.watch(dashboardProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();
    final greeting = now.hour < 12 ? 'Bonjour' : now.hour < 18 ? 'Bon après-midi' : 'Bonsoir';
    final dateStr = DateFormat('EEEE d MMMM', 'fr_FR').format(now);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => ref.invalidate(dashboardProvider),
          color: AppColors.primary,
          child: CustomScrollView(
            slivers: [
              // En-tête
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$greeting 👋',
                        style: AppTextStyles.headingLarge(
                          color: isDark ? AppColors.textDark : AppColors.textLight,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dateStr,
                        style: AppTextStyles.bodyMedium(color: AppColors.grey400),
                      ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: dashAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.all(48),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (e, _) => _ErrorState(onRetry: () => ref.invalidate(dashboardProvider)),
                  data: (data) {
                    // Injecte les minutes de focus depuis le FlowProvider (temps réel)
                    final flowMinutes = ref.watch(
                      flowProvider.select((s) => s.totalFocusMinutesToday),
                    );
                    final enriched = data.copyWith(focusMinutes: flowMinutes);
                    return _DashboardContent(data: enriched);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardContent extends ConsumerWidget {
  final DashboardData data;
  const _DashboardContent({required this.data});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(AppConstants.spacing24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Carte streak ──────────────────────────────────
          _StreakCard(data: data),
          const SizedBox(height: AppConstants.spacing16),

          // ── Suivi général (anneaux) ───────────────────────
          _OverviewCard(data: data),
          const SizedBox(height: AppConstants.spacing24),

          // ── Check-ins du jour ─────────────────────────────
          Text(
            'Mon Check-in',
            style: AppTextStyles.headingSmall(
              color: isDark ? AppColors.textDark : AppColors.textLight,
            ),
          ),
          const SizedBox(height: AppConstants.spacing12),
          Row(
            children: [
              Expanded(
                child: _CheckinCard(
                  emoji: '🌅',
                  label: 'Matin',
                  isDone: data.morningDone,
                  route: AppRoutes.checkinMorning,
                ),
              ),
              const SizedBox(width: AppConstants.spacing12),
              Expanded(
                child: _CheckinCard(
                  emoji: '🌙',
                  label: 'Soir',
                  isDone: data.eveningDone,
                  route: AppRoutes.checkinEvening,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacing24),

          // ── Niveau ───────────────────────────────────────
          _LevelCard(data: data),
          const SizedBox(height: AppConstants.spacing24),

          // ── Message bienveillant ─────────────────────────
          _MotivationBanner(data: data),
        ],
      ),
    );
  }
}

// ── Carte Streak — dark glass premium ────────────────────────
class _StreakCard extends StatelessWidget {
  final DashboardData data;
  const _StreakCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.spacing24),
      decoration: BoxDecoration(
        // Fond dark glass — pas de gradient agressif
        gradient: const LinearGradient(
          colors: [Color(0xFF0E0E24), Color(0xFF13102E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.35),
          width: 1.5,
        ),
        boxShadow: [
          // Glow violet subtil sous la carte
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.18),
            blurRadius: 32,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Streak principal
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Label pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Streak actuel 🔥',
                    style: AppTextStyles.labelMedium(
                        color: AppColors.primaryLight),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '${data.currentStreak} jour${data.currentStreak > 1 ? 's' : ''}',
                  style: AppTextStyles.displayLarge(color: AppColors.textDark)
                      .copyWith(fontSize: 36, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
                Text(
                  'Record : ${data.longestStreak} jours',
                  style: AppTextStyles.bodySmall(
                      color: AppColors.textDarkMuted),
                ),
              ],
            ),
          ),
          // Points — badge discret
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1A40),
                  borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      '${data.totalPoints}',
                      style: AppTextStyles.headingLarge(
                          color: AppColors.primary),
                    ),
                    Text(
                      'pts',
                      style: AppTextStyles.caption(
                          color: AppColors.grey400),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Carte Check-in ──────────────────────────────────────────
class _CheckinCard extends StatelessWidget {
  final String emoji;
  final String label;
  final bool isDone;
  final String route;

  const _CheckinCard({
    required this.emoji,
    required this.label,
    required this.isDone,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: isDone ? null : () => context.push(route),
      child: AnimatedContainer(
        duration: AppConstants.animFast,
        padding: const EdgeInsets.all(AppConstants.spacing16),
        decoration: BoxDecoration(
          color: isDone
              ? AppColors.success.withValues(alpha:0.12)
              : isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          border: Border.all(
            color: isDone ? AppColors.success : AppColors.grey200,
            width: isDone ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 28)),
                if (isDone)
                  const Icon(Icons.check_circle_rounded,
                      color: AppColors.success, size: 20),
              ],
            ),
            const SizedBox(height: AppConstants.spacing8),
            Text(
              label,
              style: AppTextStyles.headingSmall(
                color: isDark ? AppColors.textDark : AppColors.textLight,
              ),
            ),
            Text(
              isDone ? 'Fait ✅' : 'À faire',
              style: AppTextStyles.bodySmall(
                color: isDone ? AppColors.success : AppColors.grey400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Carte Niveau ────────────────────────────────────────────
class _LevelCard extends StatelessWidget {
  final DashboardData data;
  const _LevelCard({required this.data});

  static const _pointsPerLevel = {
    1: 100, 2: 300, 3: 600, 4: 1000, 5: 1000,
  };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final maxPts = _pointsPerLevel[data.level] ?? 100;
    final progress = (data.totalPoints / maxPts).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(AppConstants.spacing16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Niveau ${data.level} — ${data.levelLabel}',
                style: AppTextStyles.headingSmall(
                  color: isDark ? AppColors.textDark : AppColors.textLight,
                ),
              ),
              Text(
                '${data.totalPoints} pts',
                style: AppTextStyles.labelMedium(color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacing12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.grey200,
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            data.level < 5
                ? '${maxPts - data.totalPoints} pts pour le niveau suivant'
                : 'Niveau maximum atteint 👑',
            style: AppTextStyles.caption(),
          ),
        ],
      ),
    );
  }
}

// ── Bandeau motivation ──────────────────────────────────────
class _MotivationBanner extends StatelessWidget {
  final DashboardData data;
  const _MotivationBanner({required this.data});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    String message;

    if (data.currentStreak == 0) {
      message = 'Commence aujourd\'hui — chaque grand voyage commence par un premier pas 🌱';
    } else if (data.currentStreak < 3) {
      message = 'Tu avances — continue à ton rythme, ça compte 💪';
    } else if (data.currentStreak < 7) {
      message = '${data.currentStreak} jours de suite — tu construis quelque chose de solide 🔥';
    } else {
      message = '${data.currentStreak} jours — tu es en train de créer une vraie habitude 🏆';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.spacing16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha:0.08),
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        border: Border.all(color: AppColors.primary.withValues(alpha:0.2)),
      ),
      child: Text(
        message,
        style: AppTextStyles.bodyMedium(
          color: isDark ? AppColors.textDark : AppColors.textLight,
        ),
      ),
    );
  }
}

// ── Encart Suivi général ─────────────────────────────────────
class _OverviewCard extends StatelessWidget {
  final DashboardData data;
  const _OverviewCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Progression de chaque anneau (0.0 → 1.0)
    final focusProgress  = data.focusGoalMinutes > 0
        ? (data.focusMinutes / data.focusGoalMinutes).clamp(0.0, 1.0)
        : 0.0;
    final habitsProgress = data.habitsTotalToday > 0
        ? (data.habitsCompleted / data.habitsTotalToday).clamp(0.0, 1.0)
        : 0.0;
    final sleepProgress  = data.sleepQualityScore != null
        ? (data.sleepQualityScore! / 5.0).clamp(0.0, 1.0)
        : 0.0;

    // Label durée focus
    final fH = data.focusMinutes ~/ 60;
    final fM = data.focusMinutes % 60;
    final focusLabel = fH > 0 ? '${fH}h${fM.toString().padLeft(2, '0')}' : '${fM}min';

    // Label sommeil
    final sH = data.sleepDurationMinutes ~/ 60;
    final sM = data.sleepDurationMinutes % 60;
    final sleepLabel = data.sleepDurationMinutes > 0
        ? '${sH}h${sM.toString().padLeft(2, '0')}'
        : '--';
    final sleepQualityLabel = data.sleepQualityScore != null
        ? _sleepQualityText(data.sleepQualityScore!)
        : 'Non renseigné';

    return Container(
      padding: const EdgeInsets.all(AppConstants.spacing16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        border: Border.all(
          color: isDark
              ? const Color(0x0FFFFFFF)
              : const Color(0x14000000),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre section
          Text(
            'Suivi du jour',
            style: AppTextStyles.headingSmall(
              color: isDark ? AppColors.textDark : AppColors.textLight,
            ),
          ),
          const SizedBox(height: AppConstants.spacing16),

          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Anneaux ──────────────────────────────────
              SizedBox(
                width: 130,
                height: 130,
                child: _ActivityRings(
                  focusProgress: focusProgress,
                  habitsProgress: habitsProgress,
                  sleepProgress: sleepProgress,
                ),
              ),
              const SizedBox(width: AppConstants.spacing24),

              // ── Légende ───────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _RingLegendItem(
                      color: AppColors.primary,
                      icon: Icons.bolt_rounded,
                      label: 'Focus',
                      value: focusLabel,
                      subtitle: 'objectif ${data.focusGoalMinutes ~/ 60}h',
                      progress: focusProgress,
                    ),
                    const SizedBox(height: AppConstants.spacing12),
                    _RingLegendItem(
                      color: AppColors.accent,
                      icon: Icons.check_circle_outline_rounded,
                      label: 'Habitudes',
                      value: '${data.habitsCompleted}/${data.habitsTotalToday}',
                      subtitle: data.habitsTotalToday == 0 ? 'aucune planifiée' : 'tâches',
                      progress: habitsProgress,
                    ),
                    const SizedBox(height: AppConstants.spacing12),
                    _RingLegendItem(
                      color: AppColors.chartAmber,
                      icon: Icons.bedtime_outlined,
                      label: 'Sommeil',
                      value: sleepLabel,
                      subtitle: sleepQualityLabel,
                      progress: sleepProgress,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _sleepQualityText(int score) {
    switch (score) {
      case 1: return 'Difficile';
      case 2: return 'Agité';
      case 3: return 'Correct';
      case 4: return 'Bon';
      case 5: return 'Excellent';
      default: return '--';
    }
  }
}

// ── Item légende ─────────────────────────────────────────────
class _RingLegendItem extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String label;
  final String value;
  final String subtitle;
  final double progress;

  const _RingLegendItem({
    required this.color,
    required this.icon,
    required this.label,
    required this.value,
    required this.subtitle,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        // Indicateur couleur
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    label,
                    style: AppTextStyles.caption(
                      color: isDark
                          ? AppColors.textDarkMuted
                          : AppColors.grey400,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    value,
                    style: AppTextStyles.labelMedium(color: color),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: color.withValues(alpha: 0.15),
                  valueColor: AlwaysStoppedAnimation(color),
                  minHeight: 3,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: AppTextStyles.caption(color: AppColors.grey400),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Anneaux concentrique style Apple Watch ────────────────────
class _ActivityRings extends StatefulWidget {
  final double focusProgress;
  final double habitsProgress;
  final double sleepProgress;

  const _ActivityRings({
    required this.focusProgress,
    required this.habitsProgress,
    required this.sleepProgress,
  });

  @override
  State<_ActivityRings> createState() => _ActivityRingsState();
}

class _ActivityRingsState extends State<_ActivityRings>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => CustomPaint(
        painter: _RingsPainter(
          focusProgress:  widget.focusProgress  * _anim.value,
          habitsProgress: widget.habitsProgress * _anim.value,
          sleepProgress:  widget.sleepProgress  * _anim.value,
        ),
      ),
    );
  }
}

// ── Peintre des anneaux ───────────────────────────────────────
class _RingsPainter extends CustomPainter {
  final double focusProgress;
  final double habitsProgress;
  final double sleepProgress;

  _RingsPainter({
    required this.focusProgress,
    required this.habitsProgress,
    required this.sleepProgress,
  });

  static const _strokeWidth = 12.0;
  static const _gap         = 7.0;  // espace entre les anneaux

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxR   = math.min(size.width, size.height) / 2 - 2;

    // Anneau extérieur : Focus (violet)
    _drawRing(canvas, center, maxR, focusProgress, AppColors.primary);
    // Anneau milieu : Habitudes (teal)
    _drawRing(canvas, center, maxR - _strokeWidth - _gap, habitsProgress, AppColors.accent);
    // Anneau intérieur : Sommeil (amber)
    _drawRing(canvas, center, maxR - (_strokeWidth + _gap) * 2, sleepProgress, AppColors.chartAmber);
  }

  void _drawRing(Canvas canvas, Offset center, double radius, double progress, Color color) {
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Fond (piste)
    final trackPaint = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    if (progress <= 0) return;

    // Progression
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeWidth
      ..strokeCap = StrokeCap.round;

    // Départ : 12h (−π/2), sens horaire
    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );

    // Halo lumineux (glow)
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeWidth + 4
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      glowPaint,
    );
  }

  @override
  bool shouldRepaint(_RingsPainter old) =>
      old.focusProgress  != focusProgress  ||
      old.habitsProgress != habitsProgress ||
      old.sleepProgress  != sleepProgress;
}

// ── État d'erreur ────────────────────────────────────────────
class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacing32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('😕', style: TextStyle(fontSize: 48)),
            const SizedBox(height: AppConstants.spacing16),
            Text('Oops, une erreur est survenue.',
                style: AppTextStyles.bodyMedium()),
            const SizedBox(height: AppConstants.spacing16),
            ElevatedButton(onPressed: onRetry, child: const Text('Réessayer')),
          ],
        ),
      ),
    );
  }
}
