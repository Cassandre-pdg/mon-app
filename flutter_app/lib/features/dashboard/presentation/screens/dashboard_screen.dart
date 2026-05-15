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
import '../../../planner/presentation/providers/kanban_provider.dart';
import '../../../planner/data/kanban_model.dart';

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
    final focusProject = ref.watch(focusProjectProvider);
    final hour = DateTime.now().hour;
    // Avant 13h : matin est plus grand (3:2) ; après 17h : soir est plus grand (2:3)
    final morningFlex = hour < 13 ? 3 : 2;
    final eveningFlex = hour >= 17 ? 3 : 2;

    return Padding(
      padding: const EdgeInsets.all(AppConstants.spacing24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Carte streak ──────────────────────────────────
          _GlowPulse(
            color: AppColors.primary,
            maxAlpha: 0.22,
            blurRadius: 36,
            child: _StreakCard(data: data),
          ),
          const SizedBox(height: AppConstants.spacing16),

          // ── Suivi du jour (anneaux) — juste sous le streak ─
          _GlowPulse(
            color: AppColors.accent,
            maxAlpha: 0.12,
            blurRadius: 28,
            child: _OverviewCard(data: data),
          ),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: morningFlex,
                child: _CheckinCard(
                  isMorning: true,
                  isDone: data.morningDone,
                  route: AppRoutes.checkinMorning,
                  isBig: hour < 13,
                ),
              ),
              const SizedBox(width: AppConstants.spacing12),
              Expanded(
                flex: eveningFlex,
                child: _CheckinCard(
                  isMorning: false,
                  isDone: data.eveningDone,
                  route: AppRoutes.checkinEvening,
                  isBig: hour >= 17,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacing24),

          // ── Mon Projet en cours ───────────────────────────
          Text(
            'Mon Projet en cours',
            style: AppTextStyles.headingSmall(
              color: isDark ? AppColors.textDark : AppColors.textLight,
            ),
          ),
          const SizedBox(height: AppConstants.spacing12),
          _GlowPulse(
            color: AppColors.primary,
            maxAlpha: 0.18,
            blurRadius: 32,
            child: _FocusProjectCard(project: focusProject),
          ),
          const SizedBox(height: AppConstants.spacing24),

          // ── Prendre soin de moi ───────────────────────────
          Text(
            'Prendre soin de moi',
            style: AppTextStyles.headingSmall(
              color: isDark ? AppColors.textDark : AppColors.textLight,
            ),
          ),
          const SizedBox(height: AppConstants.spacing12),
          const _WellnessSection(),
          const SizedBox(height: AppConstants.spacing24),

          // ── Niveau ───────────────────────────────────────
          _GlowPulse(
            color: AppColors.primaryLight,
            maxAlpha: 0.10,
            blurRadius: 20,
            child: _LevelCard(data: data),
          ),
          const SizedBox(height: AppConstants.spacing24),

          // ── Message bienveillant ─────────────────────────
          _MotivationBanner(data: data),
          const SizedBox(height: AppConstants.spacing16),
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

// ── Carte Check-in — gradient contextuel + taille dynamique ─
class _CheckinCard extends StatelessWidget {
  final bool isMorning;
  final bool isDone;
  final String route;
  final bool isBig;

  const _CheckinCard({
    required this.isMorning,
    required this.isDone,
    required this.route,
    required this.isBig,
  });

  @override
  Widget build(BuildContext context) {
    final emoji      = isMorning ? '🌅' : '🌙';
    final label      = isMorning ? 'Matin' : 'Soir';
    final accentColor = isMorning ? AppColors.chartAmber : AppColors.primaryLight;

    final List<Color> gradient = isDone
        ? [const Color(0xFF00241E), const Color(0xFF003D32)]
        : isMorning
            ? [const Color(0xFF1E0E00), const Color(0xFF3D2000)]
            : [const Color(0xFF0A0620), const Color(0xFF18094A)];

    final borderColor = isDone
        ? AppColors.accent.withValues(alpha: 0.55)
        : isMorning
            ? AppColors.chartAmber.withValues(alpha: 0.35)
            : AppColors.primary.withValues(alpha: 0.35);

    final double pad         = isBig ? 20.0 : 14.0;
    final double emojiSmall  = isBig ? 28.0 : 22.0;
    final double emojiBg     = isBig ? 66.0 : 50.0;

    return GestureDetector(
      onTap: isDone ? null : () => context.push(route),
      child: Container(
        padding: EdgeInsets.all(pad),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Stack(
          children: [
            // Emoji géant en fond semi-transparent
            Positioned(
              right: -8,
              bottom: -10,
              child: Opacity(
                opacity: 0.11,
                child: Text(emoji, style: TextStyle(fontSize: emojiBg)),
              ),
            ),
            // Contenu
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isDone)
                  const Icon(Icons.check_circle_rounded,
                      color: AppColors.accent, size: 22)
                else
                  Text(emoji, style: TextStyle(fontSize: emojiSmall)),
                SizedBox(height: isBig ? 14.0 : 10.0),
                Text(
                  label,
                  style: AppTextStyles.headingSmall(color: AppColors.textDark)
                      .copyWith(fontSize: isBig ? 16.0 : 14.0),
                ),
                const SizedBox(height: 3),
                Text(
                  isDone ? 'Fait ✓' : 'À faire',
                  style: AppTextStyles.bodySmall(
                    color: isDone
                        ? AppColors.accent
                        : accentColor.withValues(alpha: 0.7),
                  ),
                ),
                if (isBig && !isDone) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.18),
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusPill),
                      border: Border.all(
                          color: accentColor.withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      'Commencer',
                      style: AppTextStyles.caption(color: accentColor),
                    ),
                  ),
                ],
              ],
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

// ── Card Projet en cours ─────────────────────────────────────
class _FocusProjectCard extends StatelessWidget {
  final KanbanProject? project;
  const _FocusProjectCard({required this.project});

  @override
  Widget build(BuildContext context) {
    if (project == null) return _EmptyProjectCard();
    return _FilledProjectCard(project: project!);
  }
}

class _EmptyProjectCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/planner/kanban'),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacing24,
          vertical: AppConstants.spacing32,
        ),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0A0820), Color(0xFF140F30)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            const Text('🎯', style: TextStyle(fontSize: 36)),
            const SizedBox(height: AppConstants.spacing12),
            Text(
              'Aucun projet épinglé',
              style: AppTextStyles.headingSmall(color: AppColors.textDark),
            ),
            const SizedBox(height: 6),
            Text(
              'Épingle un projet dans Mes Objectifs pour le suivre ici',
              style: AppTextStyles.bodySmall(color: AppColors.textDarkMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.spacing16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(AppConstants.radiusPill),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
              ),
              child: Text(
                'Voir mes projets',
                style: AppTextStyles.labelMedium(color: AppColors.primaryLight),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilledProjectCard extends StatelessWidget {
  final KanbanProject project;
  const _FilledProjectCard({required this.project});

  @override
  Widget build(BuildContext context) {
    final pct = (project.progressPercent * 100).round();
    final daysLeft = project.daysLeft;
    final isOverdue = project.isOverdue;

    return GestureDetector(
      onTap: () => context.push('/planner/kanban'),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0A0820), Color(0xFF140F30)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.45),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.12),
              blurRadius: 24,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── En-tête : nom + badge statut ──────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${project.projectStatus.emoji} ${project.projectStatus.label}',
                          style: AppTextStyles.caption(color: AppColors.primaryLight),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        project.name,
                        style: AppTextStyles.headingMedium(color: AppColors.textDark),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppConstants.spacing12),
                // ── % progression ───────────────────────
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      width: 2,
                    ),
                    color: AppColors.primary.withValues(alpha: 0.10),
                  ),
                  child: Center(
                    child: Text(
                      '$pct%',
                      style: AppTextStyles.headingSmall(color: AppColors.primaryLight)
                          .copyWith(fontSize: 15, fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ),

            // ── Pourquoi (ancre motivation) ───────────────
            if (project.why != null && project.why!.isNotEmpty) ...[
              const SizedBox(height: AppConstants.spacing12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spacing12,
                  vertical: AppConstants.spacing8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1040),
                  borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.15),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '💡',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        project.why!,
                        style: AppTextStyles.bodySmall(color: AppColors.textDarkMuted)
                            .copyWith(fontStyle: FontStyle.italic),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: AppConstants.spacing16),

            // ── Barre de progression ──────────────────────
            Row(
              children: [
                Text(
                  'Avancement',
                  style: AppTextStyles.caption(color: AppColors.textDarkMuted),
                ),
                const Spacer(),
                Text(
                  project.progressLabel,
                  style: AppTextStyles.caption(color: AppColors.primaryLight),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: project.progressPercent,
                backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                minHeight: 7,
              ),
            ),

            const SizedBox(height: AppConstants.spacing16),

            // ── Footer : stats tâches + jours restants ────
            Row(
              children: [
                _TaskPill(
                  label: '${project.todoCount} à faire',
                  color: AppColors.textDarkMuted,
                ),
                const SizedBox(width: 8),
                _TaskPill(
                  label: '${project.inProgressCount} en cours',
                  color: AppColors.chartAmber,
                ),
                const SizedBox(width: 8),
                _TaskPill(
                  label: '${project.doneCount} ✓',
                  color: AppColors.accent,
                ),
                const Spacer(),
                if (daysLeft != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isOverdue
                          ? AppColors.secondary.withValues(alpha: 0.15)
                          : AppColors.accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isOverdue
                          ? '${(-daysLeft).abs()}j de retard'
                          : 'J-$daysLeft',
                      style: AppTextStyles.caption(
                        color: isOverdue ? AppColors.secondary : AppColors.accent,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskPill extends StatelessWidget {
  final String label;
  final Color color;
  const _TaskPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: AppTextStyles.caption(color: color)),
    );
  }
}

// ── Section Bien-être ─────────────────────────────────────────
class _WellnessSection extends StatelessWidget {
  const _WellnessSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Méditation + Respiration côte à côte
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _WellnessCard(
                  route: '/wellness/meditation',
                  emoji: '🧘',
                  title: 'Méditer',
                  subtitle: 'Prendre du recul',
                  gradientColors: const [Color(0xFF004D47), Color(0xFF00A89A)],
                  glowColor: AppColors.accent,
                  shimmerColor: const Color(0xFF00D4C8),
                ),
              ),
              const SizedBox(width: AppConstants.spacing12),
              Expanded(
                child: _WellnessCard(
                  route: '/wellness/breathing',
                  emoji: '🌬️',
                  title: 'Respirer',
                  subtitle: 'Recentre-toi',
                  gradientColors: const [Color(0xFF2A0A6B), Color(0xFF6D28D9)],
                  glowColor: AppColors.primary,
                  shimmerColor: AppColors.primaryLight,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppConstants.spacing12),
        // Revue hebdo — pleine largeur
        _WeeklyReviewCard(),
      ],
    );
  }
}

class _WellnessCard extends StatefulWidget {
  final String route;
  final String emoji;
  final String title;
  final String subtitle;
  final List<Color> gradientColors;
  final Color glowColor;
  final Color shimmerColor;

  const _WellnessCard({
    required this.route,
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.gradientColors,
    required this.glowColor,
    required this.shimmerColor,
  });

  @override
  State<_WellnessCard> createState() => _WellnessCardState();
}

class _WellnessCardState extends State<_WellnessCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(widget.route),
      child: AnimatedBuilder(
        animation: _anim,
        builder: (_, child) => DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
            boxShadow: [
              BoxShadow(
                color: widget.glowColor.withValues(
                  alpha: 0.10 + 0.22 * _anim.value,
                ),
                blurRadius: 28 + 12 * _anim.value,
                spreadRadius: 1,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: child,
        ),
        child: Container(
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
            border: Border.all(
              color: widget.shimmerColor.withValues(alpha: 0.35),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.emoji, style: const TextStyle(fontSize: 34)),
              const SizedBox(height: AppConstants.spacing12),
              Text(
                widget.title,
                style: AppTextStyles.headingSmall(color: Colors.white)
                    .copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(
                widget.subtitle,
                style: AppTextStyles.bodySmall(
                  color: Colors.white.withValues(alpha: 0.75),
                ),
              ),
              const SizedBox(height: AppConstants.spacing12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppConstants.radiusPill),
                ),
                child: Text(
                  'Commencer',
                  style: AppTextStyles.caption(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WeeklyReviewCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();
    final isWeekend = now.weekday >= 5; // vendredi, samedi, dimanche

    return GestureDetector(
      onTap: () => context.push('/planner/weekly-review'),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 20.0,
          vertical: AppConstants.spacing16,
        ),
        decoration: BoxDecoration(
          color: AppColors.chartAmber.withValues(alpha: isDark ? 0.10 : 0.08),
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
          border: Border.all(
            color: AppColors.chartAmber.withValues(alpha: 0.35),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Text(
              isWeekend ? '📋' : '📝',
              style: const TextStyle(fontSize: 28),
            ),
            const SizedBox(width: AppConstants.spacing16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Revue de semaine',
                    style: AppTextStyles.headingSmall(
                      color: isDark ? AppColors.textDark : AppColors.textLight,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isWeekend
                        ? 'C\'est le bon moment, fais le point'
                        : 'Fais le point, ajuste, avance',
                    style: AppTextStyles.bodySmall(color: AppColors.grey400),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.chartAmber.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(AppConstants.radiusPill),
              ),
              child: Text(
                'Ouvrir',
                style: AppTextStyles.labelMedium(color: AppColors.chartAmber),
              ),
            ),
          ],
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
    final focusProgress   = data.focusGoalMinutes > 0
        ? (data.focusMinutes / data.focusGoalMinutes).clamp(0.0, 1.0)
        : 0.0;
    final habitsProgress  = data.habitsTotalToday > 0
        ? (data.habitsCompleted / data.habitsTotalToday).clamp(0.0, 1.0)
        : 0.0;
    // Anneau 3 : check-ins du jour (matin + soir = 2 maximum)
    final checkinsDone    = (data.morningDone ? 1 : 0) + (data.eveningDone ? 1 : 0);
    final checkinsProgress = checkinsDone / 2.0;

    // Labels
    final fH = data.focusMinutes ~/ 60;
    final fM = data.focusMinutes % 60;
    final focusLabel = fH > 0
        ? '${fH}h${fM.toString().padLeft(2, '0')}'
        : '${fM}min';

    final checkinsLabel   = '$checkinsDone/2';
    final checkinsSub     = checkinsDone == 2
        ? 'les deux faits ✓'
        : checkinsDone == 1
            ? 'un sur deux'
            : 'à faire aujourd\'hui';

    return Container(
      padding: const EdgeInsets.all(AppConstants.spacing16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        border: Border.all(
          color: isDark
              ? const Color(0x14FFFFFF)
              : const Color(0x14000000),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
              // ── Anneaux Apple Watch ───────────────────────
              SizedBox(
                width: 136,
                height: 136,
                child: _ActivityRings(
                  focusProgress:    focusProgress,
                  habitsProgress:   habitsProgress,
                  checkinsProgress: checkinsProgress,
                ),
              ),
              const SizedBox(width: AppConstants.spacing24),

              // ── Légende enrichie ──────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _RingLegendItem(
                      color: AppColors.primary,
                      label: 'Focus',
                      value: focusLabel,
                      subtitle: 'objectif ${data.focusGoalMinutes ~/ 60}h',
                      progress: focusProgress,
                    ),
                    const SizedBox(height: AppConstants.spacing12),
                    _RingLegendItem(
                      color: AppColors.accent,
                      label: 'Habitudes',
                      value: '${data.habitsCompleted}/${data.habitsTotalToday}',
                      subtitle: data.habitsTotalToday == 0
                          ? 'aucune planifiée'
                          : 'complétées',
                      progress: habitsProgress,
                    ),
                    const SizedBox(height: AppConstants.spacing12),
                    _RingLegendItem(
                      color: AppColors.chartAmber,
                      label: 'Check-ins',
                      value: checkinsLabel,
                      subtitle: checkinsSub,
                      progress: checkinsProgress,
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

// ── Item légende ─────────────────────────────────────────────
class _RingLegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final String value;
  final String subtitle;
  final double progress;

  const _RingLegendItem({
    required this.color,
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
  final double checkinsProgress;

  const _ActivityRings({
    required this.focusProgress,
    required this.habitsProgress,
    required this.checkinsProgress,
  });

  @override
  State<_ActivityRings> createState() => _ActivityRingsState();
}

class _ActivityRingsState extends State<_ActivityRings>
    with TickerProviderStateMixin {
  late AnimationController _entryCtrl;
  late AnimationController _pulseCtrl;
  late Animation<double> _entryAnim;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _entryAnim = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutCubic);
    _entryCtrl.forward();

    // Pulse curseur — respiration lente
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _pulseAnim = CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_entryAnim, _pulseAnim]),
      builder: (_, __) => CustomPaint(
        size: const Size(136, 136),
        painter: _RingsPainter(
          focusProgress:    widget.focusProgress    * _entryAnim.value,
          habitsProgress:   widget.habitsProgress   * _entryAnim.value,
          checkinsProgress: widget.checkinsProgress * _entryAnim.value,
          pulseValue:       _pulseAnim.value,
        ),
      ),
    );
  }
}

// ── Peintre des anneaux ───────────────────────────────────────
class _RingsPainter extends CustomPainter {
  final double focusProgress;
  final double habitsProgress;
  final double checkinsProgress;
  final double pulseValue;

  _RingsPainter({
    required this.focusProgress,
    required this.habitsProgress,
    required this.checkinsProgress,
    required this.pulseValue,
  });

  static const _strokeWidth  = 13.0;
  static const _gap          = 6.0;
  // Curseur : arc de ~10° en radians
  static const _cursorSweep  = 0.18;

  // Couleurs curseur : teinte flashy de chaque anneau
  static const _cursorFocus    = Color(0xFFB39DFB); // violet clair vif
  static const _cursorHabits   = Color(0xFF5EEAD4); // teal clair
  static const _cursorCheckins = Color(0xFFFFE566); // amber jaune vif

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxR   = math.min(size.width, size.height) / 2 - 2;

    _drawRing(canvas, center, maxR,
        focusProgress,    AppColors.primary,     _cursorFocus);
    _drawRing(canvas, center, maxR - _strokeWidth - _gap,
        habitsProgress,   AppColors.accent,      _cursorHabits);
    _drawRing(canvas, center, maxR - (_strokeWidth + _gap) * 2,
        checkinsProgress, AppColors.chartAmber,  _cursorCheckins);
  }

  void _drawRing(Canvas canvas, Offset center, double radius,
      double progress, Color color, Color cursorColor) {
    final rect   = Rect.fromCircle(center: center, radius: radius);
    final startA = -math.pi / 2;

    // ── 1. Track visible — "attend d'être rempli" ─────────────
    canvas.drawCircle(
      center, radius,
      Paint()
        ..color = color.withValues(alpha: 0.30)
        ..style = PaintingStyle.stroke
        ..strokeWidth = _strokeWidth
        ..strokeCap = StrokeCap.round,
    );

    if (progress <= 0) return;

    final sweepA = 2 * math.pi * progress;

    // ── 2. Arc rempli (couleur normale) ───────────────────────
    canvas.drawArc(rect, startA, sweepA, false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = _strokeWidth
        ..strokeCap = StrokeCap.round,
    );

    // ── 3. Curseur flashy au bout de l'arc ────────────────────
    // Le curseur couvre les derniers ~10° de l'arc rempli
    final cursorLen   = math.min(_cursorSweep, sweepA);
    final cursorStart = startA + sweepA - cursorLen;

    // Halo large du curseur (pulse)
    canvas.drawArc(rect, cursorStart, cursorLen, false,
      Paint()
        ..color = cursorColor.withValues(alpha: 0.35 + 0.30 * pulseValue)
        ..style = PaintingStyle.stroke
        ..strokeWidth = _strokeWidth + 5
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    // Arc curseur principal (couleur flashy, pleine opacité)
    canvas.drawArc(rect, cursorStart, cursorLen, false,
      Paint()
        ..color = cursorColor.withValues(alpha: 0.80 + 0.20 * pulseValue)
        ..style = PaintingStyle.stroke
        ..strokeWidth = _strokeWidth
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_RingsPainter old) =>
      old.focusProgress    != focusProgress    ||
      old.habitsProgress   != habitsProgress   ||
      old.checkinsProgress != checkinsProgress ||
      old.pulseValue       != pulseValue;
}

// ── Halo ambiant animé — respire lentement autour des cards ──
class _GlowPulse extends StatefulWidget {
  final Widget child;
  final Color color;
  final double maxAlpha;
  final double blurRadius;

  const _GlowPulse({
    required this.child,
    required this.color,
    this.maxAlpha = 0.18,
    this.blurRadius = 28,
  });

  @override
  State<_GlowPulse> createState() => _GlowPulseState();
}

class _GlowPulseState extends State<_GlowPulse>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
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
      builder: (_, child) {
        final alpha = 0.06 + (widget.maxAlpha - 0.06) * _anim.value;
        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: alpha),
                blurRadius: widget.blurRadius,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
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
