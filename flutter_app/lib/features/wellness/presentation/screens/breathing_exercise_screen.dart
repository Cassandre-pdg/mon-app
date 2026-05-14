import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/constants/app_constants.dart';
import '../../data/models/breathing_exercise.dart';

class BreathingExerciseScreen extends StatefulWidget {
  const BreathingExerciseScreen({super.key});

  @override
  State<BreathingExerciseScreen> createState() =>
      _BreathingExerciseScreenState();
}

class _BreathingExerciseScreenState extends State<BreathingExerciseScreen> {
  BreathingExercise? _selected;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: _selected == null
            ? _SelectionView(
                onSelect: (e) => setState(() => _selected = e),
              )
            : _SessionView(
                exercise: _selected!,
                onExit: () => setState(() => _selected = null),
              ),
      ),
    );
  }
}

// ── Vue sélection ─────────────────────────────────────────────
class _SelectionView extends StatelessWidget {
  final ValueChanged<BreathingExercise> onSelect;
  const _SelectionView({required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // En-tête
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Row(
            children: [
              IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                color: isDark ? AppColors.textDark : AppColors.textLight,
                style: IconButton.styleFrom(
                  backgroundColor: isDark
                      ? AppColors.surfaceDark
                      : AppColors.surfaceLight,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Respiration',
                style: AppTextStyles.headingMedium(
                  color: isDark ? AppColors.textDark : AppColors.textLight,
                ),
              ),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          child: Text(
            'Choisis ta technique',
            style: AppTextStyles.bodyMedium(color: AppColors.grey400),
          ),
        ),

        const SizedBox(height: AppConstants.spacing16),

        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            itemCount: BreathingExercise.catalog.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: AppConstants.spacing12),
            itemBuilder: (context, i) {
              final exercise = BreathingExercise.catalog[i];
              return _ExerciseCard(
                exercise: exercise,
                onTap: () => onSelect(exercise),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ── Carte exercice ────────────────────────────────────────────
class _ExerciseCard extends StatelessWidget {
  final BreathingExercise exercise;
  final VoidCallback onTap;
  const _ExerciseCard({required this.exercise, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = exercise.accentColor;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppConstants.spacing16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
          border: Border.all(
            color: c.withValues(alpha: 0.25),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            // Icône
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: c.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(exercise.emoji,
                    style: const TextStyle(fontSize: 28)),
              ),
            ),
            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        exercise.name,
                        style: AppTextStyles.headingSmall(
                          color: isDark ? AppColors.textDark : AppColors.textLight,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Pill rythme
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: c.withValues(alpha: 0.15),
                          borderRadius:
                              BorderRadius.circular(AppConstants.radiusPill),
                        ),
                        child: Text(
                          exercise.subtitle,
                          style: AppTextStyles.caption(color: c),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    exercise.benefit,
                    style: AppTextStyles.bodySmall(color: AppColors.grey400),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.timer_outlined, size: 12, color: c),
                      const SizedBox(width: 4),
                      Text(
                        '${exercise.sessionMinutes} min · ${exercise.totalCycles} cycles',
                        style: AppTextStyles.caption(color: c),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Icon(Icons.chevron_right_rounded,
                color: AppColors.grey400, size: 20),
          ],
        ),
      ),
    );
  }
}

// ── Vue session ───────────────────────────────────────────────
class _SessionView extends StatefulWidget {
  final BreathingExercise exercise;
  final VoidCallback onExit;
  const _SessionView({required this.exercise, required this.onExit});

  @override
  State<_SessionView> createState() => _SessionViewState();
}

class _SessionViewState extends State<_SessionView>
    with TickerProviderStateMixin {
  late AnimationController _expandCtrl;
  late AnimationController _rotateCtrl;
  late AnimationController _fadeCtrl;

  int _currentPhaseIndex = 0;
  int _phaseCountdown = 0;
  int _cyclesDone = 0;
  bool _isFinished = false;
  bool _isStarted = false;
  Timer? _countdownTimer;

  BreathingPhaseConfig get _currentPhase =>
      widget.exercise.phases[_currentPhaseIndex];

  int get _totalCycles => widget.exercise.totalCycles;

  @override
  void initState() {
    super.initState();

    _expandCtrl = AnimationController(vsync: this);

    _rotateCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();
  }

  void _startSession() {
    setState(() => _isStarted = true);
    HapticFeedback.mediumImpact();
    _startPhase(0);
  }

  void _startPhase(int index) {
    final phase = widget.exercise.phases[index];
    if (!mounted) return;

    setState(() {
      _currentPhaseIndex = index;
      _phaseCountdown = phase.seconds;
    });

    HapticFeedback.lightImpact();

    // Anime l'expansion selon la phase
    _expandCtrl.duration = Duration(
      milliseconds: phase.seconds * 1000,
    );

    if (phase.phase == BreathingPhase.inhale) {
      _expandCtrl.animateTo(1.0,
          curve: Curves.easeInOut,
          duration: Duration(milliseconds: phase.seconds * 1000));
    } else if (phase.phase == BreathingPhase.exhale) {
      _expandCtrl.animateTo(0.0,
          curve: Curves.easeInOut,
          duration: Duration(milliseconds: phase.seconds * 1000));
    }
    // hold/pause → le contrôleur reste à sa valeur actuelle

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() => _phaseCountdown--);
      if (_phaseCountdown <= 0) {
        t.cancel();
        _nextPhase();
      }
    });
  }

  void _nextPhase() {
    final phases = widget.exercise.phases;
    final nextIndex = (_currentPhaseIndex + 1) % phases.length;

    if (nextIndex == 0) {
      final newCycles = _cyclesDone + 1;
      if (newCycles >= _totalCycles) {
        _finishSession();
        return;
      }
      setState(() => _cyclesDone = newCycles);
    }

    _startPhase(nextIndex);
  }

  void _finishSession() {
    _countdownTimer?.cancel();
    HapticFeedback.heavyImpact();
    if (mounted) setState(() => _isFinished = true);
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _expandCtrl.dispose();
    _rotateCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.exercise.accentColor;

    if (_isFinished) return _FinishView(exercise: widget.exercise, onExit: widget.onExit);

    return FadeTransition(
      opacity: _fadeCtrl,
      child: Container(
        color: AppColors.backgroundDark,
        child: Stack(
          children: [
            // Fond dégradé radial
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 0.9,
                    colors: [
                      c.withValues(alpha: 0.12),
                      AppColors.backgroundDark,
                    ],
                  ),
                ),
              ),
            ),

            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isCompact = constraints.maxHeight < 480;
                  final animSize = isCompact ? 180.0 : 260.0;
                  final vSpace = isCompact ? 8.0 : 32.0;

                  return Column(
                    children: [
                      // ── Top bar ──────────────────────────────
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                _countdownTimer?.cancel();
                                widget.onExit();
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceDark,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.close_rounded,
                                  color: AppColors.textDarkMuted,
                                  size: 20,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              widget.exercise.name,
                              style: AppTextStyles.labelMedium(
                                  color: AppColors.textDarkMuted),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: c.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(
                                    AppConstants.radiusPill),
                              ),
                              child: Text(
                                '${_cyclesDone + 1} / $_totalCycles',
                                style: AppTextStyles.caption(color: c),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: vSpace),

                      // ── Animation pétales ──────────────────
                      if (!_isStarted)
                        _StartOverlay(
                          exercise: widget.exercise,
                          onStart: _startSession,
                        )
                      else
                        _AnimatedBreath(
                          expandController: _expandCtrl,
                          rotateController: _rotateCtrl,
                          accentColor: c,
                          phaseLabel: _currentPhase.phase.label,
                          countdown: _phaseCountdown,
                          size: animSize,
                        ),

                      SizedBox(height: vSpace),

                      // ── Barre progression session ──────────
                      if (_isStarted)
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                              32, 0, 32, isCompact ? 16 : 32),
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: _cyclesDone / _totalCycles,
                                  backgroundColor: c.withValues(alpha: 0.15),
                                  valueColor: AlwaysStoppedAnimation(c),
                                  minHeight: 3,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${widget.exercise.sessionMinutes} min · continue à ton rythme',
                                style: AppTextStyles.caption(
                                  color: AppColors.textDarkMuted,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        SizedBox(height: isCompact ? 16 : 32),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Overlay de démarrage ─────────────────────────────────────
class _StartOverlay extends StatelessWidget {
  final BreathingExercise exercise;
  final VoidCallback onStart;
  const _StartOverlay({required this.exercise, required this.onStart});

  @override
  Widget build(BuildContext context) {
    final c = exercise.accentColor;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          Text(
            exercise.emoji,
            style: const TextStyle(fontSize: 64),
          ),
          const SizedBox(height: AppConstants.spacing24),
          Text(
            exercise.name,
            style: AppTextStyles.headingLarge(color: AppColors.textDark),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.spacing8),
          Text(
            exercise.description,
            style: AppTextStyles.bodyMedium(color: AppColors.textDarkMuted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.spacing32),
          GestureDetector(
            onTap: onStart,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              decoration: BoxDecoration(
                color: c,
                borderRadius: BorderRadius.circular(AppConstants.radiusPill),
                boxShadow: [
                  BoxShadow(
                    color: c.withValues(alpha: 0.4),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Text(
                'Commencer',
                style: AppTextStyles.headingSmall(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Animation de respiration ──────────────────────────────────
class _AnimatedBreath extends StatelessWidget {
  final AnimationController expandController;
  final AnimationController rotateController;
  final Color accentColor;
  final String phaseLabel;
  final int countdown;
  final double size;

  const _AnimatedBreath({
    required this.expandController,
    required this.rotateController,
    required this.accentColor,
    required this.phaseLabel,
    required this.countdown,
    this.size = 260,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: AnimatedBuilder(
            animation: Listenable.merge([expandController, rotateController]),
            builder: (_, __) {
              return CustomPaint(
                size: Size(size, size),
                painter: _PetalPainter(
                  expandValue: expandController.value,
                  rotation: rotateController.value * 2 * math.pi,
                  accentColor: accentColor,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        AnimatedBuilder(
          animation: expandController,
          builder: (_, __) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                phaseLabel,
                style: AppTextStyles.headingSmall(
                  color: AppColors.textDark,
                ),
              ),
              Text(
                '$countdown',
                style: AppTextStyles.displayLarge(
                  color: AppColors.textDark,
                ).copyWith(
                  fontSize: 48,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Peintre des pétales (inspiré Apple Breath) ────────────────
class _PetalPainter extends CustomPainter {
  final double expandValue; // 0.0 = fermé, 1.0 = ouvert
  final double rotation;
  final Color accentColor;

  const _PetalPainter({
    required this.expandValue,
    required this.rotation,
    required this.accentColor,
  });

  static const int _petalCount = 6;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxR = math.min(size.width, size.height) / 2;

    // Rayon des pétales : varie avec l'expansion
    final petalR = maxR * (0.30 + 0.12 * expandValue);

    // Distance centre → centre du pétale
    // À 0 : pétales collés au centre (chevauchement maximum)
    // À 1 : pétales bien écartés
    final offsetD = petalR * 0.85 * expandValue;

    // Couleur : violet → teal selon expansion
    final petalColor = Color.lerp(
      AppColors.primary,
      accentColor,
      expandValue,
    )!;

    // Opacité des pétales (plus visible en ouverture)
    final opacity = 0.45 + 0.25 * expandValue;

    final glowPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = petalColor.withValues(alpha: 0.12)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 28);

    final petalPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = petalColor.withValues(alpha: opacity);

    // Halo extérieur global
    canvas.drawCircle(
      center,
      maxR * 0.75 * expandValue,
      Paint()
        ..color = petalColor.withValues(alpha: 0.06)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40),
    );

    // Dessine chaque pétale
    for (int i = 0; i < _petalCount; i++) {
      final angle = rotation + (i * 2 * math.pi / _petalCount);
      final petalCenter = Offset(
        center.dx + offsetD * math.cos(angle),
        center.dy + offsetD * math.sin(angle),
      );

      // Lueur douce derrière le pétale
      canvas.drawCircle(petalCenter, petalR * 1.5, glowPaint);
      // Pétale principal
      canvas.drawCircle(petalCenter, petalR, petalPaint);
    }

    // Cercle central (toujours visible, légèrement pulsé)
    final centerR = maxR * (0.12 + 0.06 * expandValue);
    canvas.drawCircle(
      center,
      centerR,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.10 + 0.08 * expandValue),
    );
    // Bord du cercle central
    canvas.drawCircle(
      center,
      centerR,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(_PetalPainter old) =>
      old.expandValue != expandValue ||
      old.rotation != rotation ||
      old.accentColor != accentColor;
}

// ── Écran de fin ──────────────────────────────────────────────
class _FinishView extends StatelessWidget {
  final BreathingExercise exercise;
  final VoidCallback onExit;
  const _FinishView({required this.exercise, required this.onExit});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.backgroundDark,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('✨', style: TextStyle(fontSize: 72)),
                const SizedBox(height: AppConstants.spacing24),
                Text(
                  'Bien joué !',
                  style: AppTextStyles.headingLarge(color: AppColors.textDark),
                ),
                const SizedBox(height: AppConstants.spacing8),
                Text(
                  'Tu viens de terminer ${exercise.sessionMinutes} minutes de ${exercise.name}.\nPrends un instant pour apprécier ce moment de calme.',
                  style: AppTextStyles.bodyMedium(color: AppColors.textDarkMuted),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppConstants.spacing32),
                GestureDetector(
                  onTap: onExit,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32, vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusPill),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.4),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Text(
                      'Terminer',
                      style: AppTextStyles.headingSmall(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
