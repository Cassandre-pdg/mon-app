import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/constants/app_constants.dart';
import '../../data/flow_model.dart';
import '../providers/flow_provider.dart';

// ── Onglet Flow ────────────────────────────────────────────────
class FlowTab extends ConsumerWidget {
  const FlowTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flow = ref.watch(flowProvider);

    return Stack(
      children: [
        // Contenu principal
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Pills sessions ─────────────────────────────
              _SessionPills(flow: flow),
              const SizedBox(height: AppConstants.spacing32),

              // ── Timer ──────────────────────────────────────
              _FlowTimer(flow: flow),
              const SizedBox(height: AppConstants.spacing32),

              // ── Configuration ──────────────────────────────
              _FlowConfig(flow: flow),
            ],
          ),
        ),

        // Overlay de célébration (affiché quand session complète)
        if (flow.timerState == FlowTimerState.completed)
          _CompletionOverlay(flow: flow),
      ],
    );
  }
}

// ── Pills indicatrices de sessions ────────────────────────────
class _SessionPills extends StatelessWidget {
  final FlowState flow;
  const _SessionPills({required this.flow});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Text(
          'Sessions du jour',
          style: AppTextStyles.labelMedium(color: AppColors.grey400),
        ),
        const SizedBox(width: 12),
        ...List.generate(flow.sessionsPerDay, (i) {
          final done = i < flow.completedToday;
          return Container(
            margin: const EdgeInsets.only(right: 6),
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: done
                  ? AppColors.primary
                  : (isDark ? AppColors.surfaceDark : AppColors.grey100),
              border: Border.all(
                color: done ? AppColors.primary : AppColors.grey200,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: done
                ? const Icon(Icons.bolt_rounded,
                    color: Colors.white, size: 16)
                : Center(
                    child: Text(
                      '${i + 1}',
                      style: AppTextStyles.caption(color: AppColors.grey400),
                    ),
                  ),
          );
        }),
      ],
    );
  }
}

// ── Timer circulaire 90 min ────────────────────────────────────
class _FlowTimer extends ConsumerStatefulWidget {
  final FlowState flow;
  const _FlowTimer({required this.flow});

  @override
  ConsumerState<_FlowTimer> createState() => _FlowTimerState();
}

class _FlowTimerState extends ConsumerState<_FlowTimer>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final flow   = widget.flow;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isRunning = flow.timerState == FlowTimerState.running;

    // Couleur selon état
    final ringColor = flow.allSessionsDone
        ? AppColors.success
        : AppColors.primary;

    return Column(
      children: [
        // ── Cercle timer ────────────────────────────────────
        Center(
          child: SizedBox(
            width: 240,
            height: 240,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Halo pulsant (actif seulement quand le timer tourne)
                if (isRunning)
                  AnimatedBuilder(
                    animation: _pulseCtrl,
                    builder: (_, __) => Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: ringColor
                                .withValues(alpha: 0.1 + 0.1 * _pulseCtrl.value),
                            blurRadius: 30 + 10 * _pulseCtrl.value,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                    ),
                  ),

                // Arc de progression
                SizedBox.expand(
                  child: CircularProgressIndicator(
                    value: flow.sessionProgress,
                    strokeWidth: 10,
                    backgroundColor: ringColor.withValues(alpha: 0.12),
                    valueColor: AlwaysStoppedAnimation(ringColor),
                    strokeCap: StrokeCap.round,
                  ),
                ),

                // Affichage central
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _pulseCtrl,
                      builder: (_, child) => Opacity(
                        opacity: isRunning
                            ? 0.75 + 0.25 * _pulseCtrl.value
                            : 1.0,
                        child: child,
                      ),
                      child: Text(
                        flow.timeDisplay,
                        style: AppTextStyles.displayLarge(
                          color: isDark
                              ? AppColors.textDark
                              : AppColors.textLight,
                        ).copyWith(
                          fontSize: 46,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _statusLabel(flow),
                      style: AppTextStyles.bodySmall(
                          color: AppColors.grey400),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: AppConstants.spacing32),

        // ── Boutons contrôle ────────────────────────────────
        Row(
          children: [
            // Reset
            IconButton.outlined(
              onPressed: () => ref.read(flowProvider.notifier).reset(),
              icon: const Icon(Icons.refresh_rounded),
              style: IconButton.styleFrom(padding: const EdgeInsets.all(14)),
            ),
            const SizedBox(width: AppConstants.spacing16),

            // Play / Pause
            Expanded(
              child: ElevatedButton.icon(
                onPressed: flow.allSessionsDone
                    ? null
                    : () => ref.read(flowProvider.notifier).startPause(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ringColor,
                  disabledBackgroundColor: AppColors.grey200,
                ),
                icon: Icon(isRunning
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded),
                label: Text(isRunning ? 'Pause' : 'Démarrer'),
              ),
            ),
          ],
        ),

        const SizedBox(height: AppConstants.spacing12),
        Text(
          '90 min de focus profond',
          style: AppTextStyles.caption(),
          textAlign: TextAlign.center,
        ),

        // Résumé du jour
        if (flow.totalFocusMinutesToday > 0) ...[
          const SizedBox(height: AppConstants.spacing8),
          _FocusSummaryPill(minutes: flow.totalFocusMinutesToday),
        ],
      ],
    );
  }

  String _statusLabel(FlowState flow) {
    if (flow.allSessionsDone) return 'Objectif atteint 🏆';
    switch (flow.timerState) {
      case FlowTimerState.running: return 'En cours...';
      case FlowTimerState.paused:  return 'En pause';
      default:                     return 'Prêt';
    }
  }
}

// ── Pill résumé focus ─────────────────────────────────────────
class _FocusSummaryPill extends StatelessWidget {
  final int minutes;
  const _FocusSummaryPill({required this.minutes});

  @override
  Widget build(BuildContext context) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    final label = h > 0
        ? '${h}h${m.toString().padLeft(2, '0')} de focus aujourd\'hui ⚡'
        : '${m}min de focus aujourd\'hui ⚡';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: AppTextStyles.caption(color: AppColors.primary)),
    );
  }
}

// ── Section configuration ─────────────────────────────────────
class _FlowConfig extends ConsumerWidget {
  final FlowState flow;
  const _FlowConfig({required this.flow});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
          Text(
            'Ma configuration',
            style: AppTextStyles.headingSmall(
              color: isDark ? AppColors.textDark : AppColors.textLight,
            ),
          ),
          const SizedBox(height: AppConstants.spacing16),

          // Sélecteur 1x / 4x
          Text(
            'Sessions par jour',
            style: AppTextStyles.labelMedium(color: AppColors.grey400),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _SessionOption(
                label: '1×  par jour',
                subtitle: '1 session · 09:00',
                selected: flow.sessionsPerDay == 1,
                onTap: () =>
                    ref.read(flowProvider.notifier).setSessionsPerDay(1),
              ),
              const SizedBox(width: AppConstants.spacing12),
              _SessionOption(
                label: '4×  par jour',
                subtitle: '09h · 11h30 · 14h · 16h30',
                selected: flow.sessionsPerDay == 4,
                onTap: () =>
                    ref.read(flowProvider.notifier).setSessionsPerDay(4),
              ),
            ],
          ),

          const SizedBox(height: AppConstants.spacing16),

          // Notifications planifiées
          Row(
            children: [
              const Icon(Icons.notifications_outlined,
                  size: 16, color: AppColors.grey400),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Rappels à : ${flow.notificationTimes.join(' · ')}',
                  style: AppTextStyles.caption(color: AppColors.grey400),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Option de session (carte sélectionnable) ──────────────────
class _SessionOption extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _SessionOption({
    required this.label,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: AppConstants.animFast,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.12)
                : Colors.transparent,
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.grey200,
              width: selected ? 2 : 1,
            ),
            borderRadius:
                BorderRadius.circular(AppConstants.radiusMedium),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.bodyMedium(
                  color: selected
                      ? AppColors.primary
                      : isDark
                          ? AppColors.textDark
                          : AppColors.textLight,
                ).copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: AppTextStyles.caption(color: AppColors.grey400),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Overlay de célébration ─────────────────────────────────────
class _CompletionOverlay extends ConsumerStatefulWidget {
  final FlowState flow;
  const _CompletionOverlay({required this.flow});

  @override
  ConsumerState<_CompletionOverlay> createState() =>
      _CompletionOverlayState();
}

class _CompletionOverlayState extends ConsumerState<_CompletionOverlay>
    with TickerProviderStateMixin {
  late AnimationController _cardCtrl;
  late AnimationController _particlesCtrl;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();

    _cardCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _particlesCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleAnim = CurvedAnimation(parent: _cardCtrl, curve: Curves.elasticOut);
    _fadeAnim  = CurvedAnimation(parent: _cardCtrl, curve: Curves.easeOut);

    _cardCtrl.forward();
    _particlesCtrl.forward();
  }

  @override
  void dispose() {
    _cardCtrl.dispose();
    _particlesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final flow   = widget.flow;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final h = (FlowState.sessionDurationSeconds ~/ 60) ~/ 60;
    final m = (FlowState.sessionDurationSeconds ~/ 60) % 60;
    final durLabel = h > 0
        ? '${h}h${m.toString().padLeft(2, '0')}'
        : '${m}min';

    final allDone = flow.allSessionsDone;

    return Container(
      color: Colors.black.withValues(alpha: 0.75),
      child: Stack(
        children: [
          // ── Particules d'éclat ────────────────────────────
          AnimatedBuilder(
            animation: _particlesCtrl,
            builder: (_, __) => CustomPaint(
              size: MediaQuery.of(context).size,
              painter: _ParticlesPainter(
                  progress: _particlesCtrl.value),
            ),
          ),

          // ── Carte de célébration ──────────────────────────
          Center(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: ScaleTransition(
                scale: _scaleAnim,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  padding: const EdgeInsets.all(AppConstants.spacing32),
                  decoration: BoxDecoration(
                    color:
                        isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                    borderRadius:
                        BorderRadius.circular(AppConstants.radiusLarge + 4),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 40,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Emoji
                      const Text('⚡', style: TextStyle(fontSize: 56)),
                      const SizedBox(height: AppConstants.spacing16),

                      // Titre
                      Text(
                        allDone
                            ? 'Objectif atteint !'
                            : 'Flow accompli !',
                        style: AppTextStyles.headingLarge(
                          color: isDark
                              ? AppColors.textDark
                              : AppColors.textLight,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Belle avancée — tu avances à ton rythme 💪',
                        style: AppTextStyles.bodySmall(
                            color: AppColors.grey400),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: AppConstants.spacing24),

                      // Stats
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _StatChip(
                            label: 'Focus',
                            value: durLabel,
                            color: AppColors.primary,
                          ),
                          _StatChip(
                            label: 'Session',
                            value:
                                '${flow.completedToday}/${flow.sessionsPerDay}',
                            color: AppColors.accent,
                          ),
                        ],
                      ),

                      const SizedBox(height: AppConstants.spacing24),

                      // CTA
                      ElevatedButton(
                        onPressed: () =>
                            ref.read(flowProvider.notifier).dismissCompletion(),
                        child: Text(
                          allDone
                              ? 'Terminé pour aujourd\'hui 🏆'
                              : 'Session suivante',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Chip stat dans la carte ───────────────────────────────────
class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: AppTextStyles.displayLarge(color: color)
                .copyWith(fontSize: 24, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.caption(color: color)),
        ],
      ),
    );
  }
}

// ── Peintre de particules ─────────────────────────────────────
class _ParticlesPainter extends CustomPainter {
  final double progress;

  static final _rng = math.Random(42);
  static final _particles = List.generate(30, (_) {
    final angle  = _rng.nextDouble() * 2 * math.pi;
    final speed  = 0.3 + _rng.nextDouble() * 0.7;
    final size   = 3.0 + _rng.nextDouble() * 5.0;
    final colors = [
      AppColors.primary,
      AppColors.accent,
      AppColors.chartAmber,
      AppColors.secondary,
    ];
    final color = colors[_rng.nextInt(colors.length)];
    return _Particle(angle: angle, speed: speed, size: size, color: color);
  });

  _ParticlesPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxDist = size.shortestSide * 0.65;

    for (final p in _particles) {
      final dist   = maxDist * p.speed * progress;
      final opacity = (1.0 - progress).clamp(0.0, 1.0);
      final pos    = center +
          Offset(math.cos(p.angle) * dist, math.sin(p.angle) * dist);

      final paint = Paint()
        ..color = p.color.withValues(alpha: opacity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(pos, p.size * (1 - progress * 0.5), paint);
    }
  }

  @override
  bool shouldRepaint(_ParticlesPainter old) => old.progress != progress;
}

class _Particle {
  final double angle;
  final double speed;
  final double size;
  final Color color;
  const _Particle({
    required this.angle,
    required this.speed,
    required this.size,
    required this.color,
  });
}
