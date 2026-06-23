import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../data/flow_model.dart';
import '../../data/session_context_model.dart';
import '../providers/flow_provider.dart';
import '../providers/timer_session_provider.dart';
import '../widgets/session_context_picker.dart';
import '../widgets/session_end_popup.dart';

// ── Arc gradient + glow CustomPainter ────────────────────────────────────────
class _ArcPainter extends CustomPainter {
  const _ArcPainter({
    required this.progress,
    required this.colors,
    required this.trackColor,
    required this.strokeWidth,
    required this.glowOpacity,
  });

  final double progress;
  final List<Color> colors;
  final Color trackColor;
  final double strokeWidth;
  final double glowOpacity;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - strokeWidth;
    final rect   = Rect.fromCircle(center: center, radius: radius);
    const startAngle = -math.pi / 2;

    // Track
    canvas.drawArc(
      rect, 0, 2 * math.pi, false,
      Paint()
        ..color      = trackColor
        ..strokeWidth = strokeWidth
        ..style      = PaintingStyle.stroke
        ..strokeCap  = StrokeCap.round,
    );

    if (progress <= 0.005) return;
    final sweep = 2 * math.pi * progress.clamp(0.0, 1.0);

    // Glow couche extérieure
    canvas.drawArc(
      rect, startAngle, sweep, false,
      Paint()
        ..color      = colors.last.withValues(alpha: glowOpacity * 0.45)
        ..strokeWidth = strokeWidth * 2.8
        ..style      = PaintingStyle.stroke
        ..strokeCap  = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );

    // Arc gradient principal
    canvas.drawArc(
      rect, startAngle, sweep, false,
      Paint()
        ..shader = SweepGradient(
          startAngle: startAngle,
          endAngle: startAngle + 2 * math.pi,
          colors: [...colors, colors.first],
        ).createShader(rect)
        ..strokeWidth = strokeWidth
        ..style      = PaintingStyle.stroke
        ..strokeCap  = StrokeCap.round,
    );

    // Point lumineux au bout de l'arc
    final tipAngle = startAngle + sweep;
    final tipX = center.dx + radius * math.cos(tipAngle);
    final tipY = center.dy + radius * math.sin(tipAngle);
    canvas.drawCircle(
      Offset(tipX, tipY),
      strokeWidth / 2 + 1.5,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.9)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.drawCircle(
      Offset(tipX, tipY),
      strokeWidth / 2,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(_ArcPainter old) =>
      old.progress != progress || old.glowOpacity != glowOpacity;
}

// ── Onglet Flow ───────────────────────────────────────────────────────────────
class FlowTab extends ConsumerStatefulWidget {
  const FlowTab({super.key});

  @override
  ConsumerState<FlowTab> createState() => _FlowTabState();
}

class _FlowTabState extends ConsumerState<FlowTab>
    with TickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late AnimationController _glowCtrl;
  SessionContext? _sessionContext;
  bool _popupShown = false;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _glowCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleStartPause(FlowState flow) async {
    final isRunning = flow.timerState == FlowTimerState.running;
    if (isRunning) {
      ref.read(flowProvider.notifier).startPause();
      return;
    }
    if (flow.timerState == FlowTimerState.idle) {
      final ctx = await SessionContextPicker.show(context, timerType: 'flow');
      if (!mounted) return;
      setState(() => _sessionContext = ctx);
    }
    ref.read(flowProvider.notifier).startPause();
  }

  void _openConfig(FlowState flow) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _FlowConfigSheet(flow: flow),
    );
  }

  @override
  Widget build(BuildContext context) {
    final flow      = ref.watch(flowProvider);
    final isRunning = flow.timerState == FlowTimerState.running;
    final isPaused  = flow.timerState == FlowTimerState.paused;

    // Popup de fin de session
    ref.listen(flowProvider, (prev, next) {
      if (prev?.timerState != FlowTimerState.completed &&
          next.timerState == FlowTimerState.completed &&
          !_popupShown) {
        _popupShown = true;
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          if (!mounted) return;
          final repo = ref.read(timerSessionRepositoryProvider);
          await repo.save(
            type: 'flow',
            durationMinutes: FlowState.sessionDurationSeconds ~/ 60,
            context: _sessionContext,
          );
          if (!mounted) return;
          final action = await SessionEndPopup.show(
            context,
            timerType: 'flow',
            durationMinutes: FlowState.sessionDurationSeconds ~/ 60,
            sessionContext: _sessionContext,
          );
          if (!mounted) return;
          _popupShown = false;
          setState(() => _sessionContext = null);
          ref.read(flowProvider.notifier).dismissCompletion();
          if (action == SessionEndAction.restart) {
            Future.delayed(const Duration(seconds: 1), () {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Pause terminée. Prêt pour la prochaine session ?'),
                    action: SnackBarAction(
                      label: 'Démarrer',
                      onPressed: () => ref.read(flowProvider.notifier).startPause(),
                    ),
                    duration: const Duration(seconds: 10),
                    backgroundColor: AppColors.surfaceElevatedDark,
                  ),
                );
              }
            });
          }
        });
      }
    });

    final arcColors = flow.allSessionsDone
        ? [AppColors.accent, AppColors.primaryLight]
        : [AppColors.primaryLight, AppColors.primary];

    return Column(
      children: [
          // ── Ligne dots + ⚙ (pas de top bar — le header vient de planner_screen) ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                // ⚙ à gauche — ne conflicte pas avec le bouton capture (haut-droite)
                GestureDetector(
                  onTap: () => _openConfig(flow),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.tune_rounded,
                            size: 15, color: AppColors.textDarkMuted),
                        const SizedBox(width: 5),
                        Text(
                          'Config',
                          style: AppTextStyles.caption(
                              color: AppColors.textDarkMuted),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                // Dots sessions centrées à droite
                _SessionDots(flow: flow),
              ],
            ),
          ),

          // ── Timer hero ─────────────────────────────────────────────
          Expanded(
            child: Center(
              child: AnimatedBuilder(
                animation: Listenable.merge([_pulseCtrl, _glowCtrl]),
                builder: (context, _) {
                  final glowAlpha = isRunning
                      ? 0.18 + 0.12 * _glowCtrl.value
                      : 0.08;
                  final timeOpacity = isRunning
                      ? 0.8 + 0.2 * _pulseCtrl.value
                      : 1.0;

                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      // Halo de fond pulsant
                      Container(
                        width: 320,
                        height: 320,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppColors.primary.withValues(alpha: glowAlpha),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.75],
                          ),
                        ),
                      ),

                      // Arc
                      SizedBox(
                        width: 280,
                        height: 280,
                        child: CustomPaint(
                          painter: _ArcPainter(
                            progress: flow.sessionProgress,
                            colors: arcColors,
                            trackColor: AppColors.primary.withValues(alpha: 0.12),
                            strokeWidth: 12,
                            glowOpacity: isRunning
                                ? 0.5 + 0.3 * _glowCtrl.value
                                : 0.3,
                          ),
                        ),
                      ),

                      // Contenu central
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Opacity(
                            opacity: timeOpacity,
                            child: Text(
                              flow.timeDisplay,
                              style: const TextStyle(
                                fontSize: 68,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textDark,
                                letterSpacing: -2,
                                fontFamily: 'Inter',
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _statusLabel(flow),
                            style: AppTextStyles.bodySmall(
                              color: isRunning
                                  ? AppColors.primaryLight
                                  : AppColors.textDarkMuted,
                            ).copyWith(letterSpacing: 0.5),
                          ),
                          // Pill contexte de tâche
                          if (_sessionContext != null) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: AppColors.primary.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.push_pin_rounded,
                                      size: 11,
                                      color: AppColors.primaryLight),
                                  const SizedBox(width: 5),
                                  Text(
                                    _sessionContext!.label,
                                    style: AppTextStyles.caption(
                                      color: AppColors.primaryLight,
                                    ).copyWith(fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),

          // ── Zone basse : audio + boutons ───────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Column(
              children: [
                // Résumé focus du jour
                if (flow.totalFocusMinutesToday > 0) ...[
                  _FocusPill(minutes: flow.totalFocusMinutesToday),
                  const SizedBox(height: 14),
                ],

                // Boutons contrôle
                Row(
                  children: [
                    // Reset
                    _CircleButton(
                      icon: Icons.refresh_rounded,
                      onTap: () => ref.read(flowProvider.notifier).reset(),
                      color: AppColors.textDarkMuted,
                    ),
                    const SizedBox(width: 12),
                    // Play / Pause
                    Expanded(
                      child: _MainButton(
                        isRunning: isRunning,
                        isPaused: isPaused,
                        disabled: flow.allSessionsDone,
                        color: AppColors.primary,
                        onTap: flow.allSessionsDone
                            ? null
                            : () => _handleStartPause(flow),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }

  String _statusLabel(FlowState flow) {
    if (flow.allSessionsDone) return 'Objectif du jour atteint 🏆';
    switch (flow.timerState) {
      case FlowTimerState.running: return 'En cours...';
      case FlowTimerState.paused:  return 'En pause';
      default:                     return 'Prêt à démarrer';
    }
  }
}

// ── Dots de sessions ──────────────────────────────────────────────────────────
class _SessionDots extends StatelessWidget {
  const _SessionDots({required this.flow});
  final FlowState flow;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(flow.sessionsPerDay, (i) {
        final done = i < flow.completedToday;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutBack,
          margin: const EdgeInsets.symmetric(horizontal: 5),
          width:  done ? 28 : 10,
          height: 10,
          decoration: BoxDecoration(
            color: done
                ? AppColors.primary
                : AppColors.primary.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(5),
          ),
        );
      }),
    );
  }
}

// ── Pill résumé focus ─────────────────────────────────────────────────────────
class _FocusPill extends StatelessWidget {
  const _FocusPill({required this.minutes});
  final int minutes;

  @override
  Widget build(BuildContext context) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    final label = h > 0
        ? '⚡  ${h}h${m.toString().padLeft(2, '0')} de focus aujourd\'hui'
        : '⚡  $m min de focus aujourd\'hui';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: AppTextStyles.caption(color: AppColors.primaryLight)),
    );
  }
}

// ── Bouton reset rond ─────────────────────────────────────────────────────────
class _CircleButton extends StatelessWidget {
  const _CircleButton({
    required this.icon,
    required this.onTap,
    required this.color,
  });
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
    );
  }
}

// ── Bouton principal Play/Pause ───────────────────────────────────────────────
class _MainButton extends StatelessWidget {
  const _MainButton({
    required this.isRunning,
    required this.isPaused,
    required this.disabled,
    required this.color,
    required this.onTap,
  });
  final bool isRunning;
  final bool isPaused;
  final bool disabled;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final label = isRunning
        ? 'Pause'
        : isPaused
            ? 'Reprendre'
            : 'Démarrer';
    final icon = isRunning
        ? Icons.pause_rounded
        : Icons.play_arrow_rounded;

    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 52,
        decoration: BoxDecoration(
          gradient: disabled
              ? null
              : LinearGradient(
                  colors: [
                    color,
                    color.withValues(alpha: 0.7),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
          color: disabled ? Colors.white12 : null,
          borderRadius: BorderRadius.circular(26),
          boxShadow: disabled
              ? null
              : [
                  BoxShadow(
                    color: color.withValues(alpha: 0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                fontFamily: 'Inter',
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Bottom sheet de configuration Flow ───────────────────────────────────────
class _FlowConfigSheet extends ConsumerWidget {
  const _FlowConfigSheet({required this.flow});
  final FlowState flow;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1A1836),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
          24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Configuration Flow',
            style: AppTextStyles.headingSmall(color: AppColors.textDark),
          ),
          const SizedBox(height: 20),

          // Sessions par jour
          Text(
            'Sessions par jour',
            style: AppTextStyles.caption(color: AppColors.textDarkMuted),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _SessionOptionTile(
                label: '1 session',
                subtitle: '09:00',
                selected: flow.sessionsPerDay == 1,
                onTap: () => ref
                    .read(flowProvider.notifier)
                    .setSessionsPerDay(1),
              ),
              const SizedBox(width: 10),
              _SessionOptionTile(
                label: '4 sessions',
                subtitle: '09h · 11h30 · 14h · 16h30',
                selected: flow.sessionsPerDay == 4,
                onTap: () => ref
                    .read(flowProvider.notifier)
                    .setSessionsPerDay(4),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Rappels
          Row(
            children: [
              Icon(Icons.notifications_outlined,
                  size: 15, color: AppColors.textDarkMuted),
              const SizedBox(width: 6),
              Text(
                'Rappels : ${flow.notificationTimes.join(' · ')}',
                style: AppTextStyles.caption(color: AppColors.textDarkMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SessionOptionTile extends StatelessWidget {
  const _SessionOptionTile({
    required this.label,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.15)
                : Colors.white.withValues(alpha: 0.05),
            border: Border.all(
              color: selected
                  ? AppColors.primary.withValues(alpha: 0.5)
                  : Colors.white.withValues(alpha: 0.08),
              width: selected ? 1.5 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.bodySmall(
                  color: selected
                      ? AppColors.primaryLight
                      : AppColors.textDark,
                ).copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: AppTextStyles.caption(
                    color: AppColors.textDarkMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
