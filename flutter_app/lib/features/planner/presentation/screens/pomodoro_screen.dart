import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/services/focus_audio_service.dart';
import '../providers/timer_session_provider.dart';
import '../../data/session_context_model.dart';
import '../widgets/session_context_picker.dart';
import '../widgets/session_end_popup.dart';

enum PomodoroPhase { work, shortBreak }

// ── Arc gradient + glow CustomPainter (partagé avec Flow) ────────────────────
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

    // Glow extérieur
    canvas.drawArc(
      rect, startAngle, sweep, false,
      Paint()
        ..color      = colors.last.withValues(alpha: glowOpacity * 0.45)
        ..strokeWidth = strokeWidth * 2.8
        ..style      = PaintingStyle.stroke
        ..strokeCap  = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );

    // Arc principal avec gradient
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

    // Point lumineux au bout
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

// ── Contenu Pomodoro ──────────────────────────────────────────────────────────
class PomodoroContent extends ConsumerStatefulWidget {
  const PomodoroContent({super.key});

  @override
  ConsumerState<PomodoroContent> createState() => _PomodoroContentState();
}

class _PomodoroContentState extends ConsumerState<PomodoroContent>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  static const int _workSeconds  = 25 * 60;
  static const int _breakSeconds = 5 * 60;

  PomodoroPhase _phase    = PomodoroPhase.work;
  int _secondsLeft        = _workSeconds;
  bool _isRunning         = false;
  int _completedPomodoros = 0;
  Timer? _timer;

  late AnimationController _pulseCtrl;
  late AnimationController _glowCtrl;

  FocusAudio _selectedAudio = FocusAudio.silence;
  SessionContext? _sessionContext;
  bool _isFirstStart = true;
  DateTime? _backgroundAt;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _pulseCtrl.dispose();
    _glowCtrl.dispose();
    super.dispose();
  }

  // ── Gestion arrière-plan ──────────────────────────────────────
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused && _isRunning) {
      _backgroundAt = DateTime.now();
    }
    if (state == AppLifecycleState.resumed && _backgroundAt != null) {
      _onResumedFromBackground();
    }
  }

  void _onResumedFromBackground() {
    final bg = _backgroundAt;
    if (bg == null || !_isRunning) return;
    _backgroundAt = null;

    final elapsed      = DateTime.now().difference(bg).inSeconds;
    if (elapsed < 3) return;
    final newLeft = _secondsLeft - elapsed;

    if (newLeft <= 0) { _onPhaseComplete(); return; }

    if (elapsed >= 180 && mounted) {
      showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Tu étais absent·e'),
          content: Text('${_formatElapsed(elapsed)} se sont écoulées.\nOn compte ce temps ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Non, mettre en pause'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Oui, continuer'),
            ),
          ],
        ),
      ).then((count) {
        if (!mounted) return;
        if (count == true) {
          setState(() => _secondsLeft = newLeft);
        } else {
          _timer?.cancel();
          setState(() => _isRunning = false);
          FocusAudioService.instance.pause();
        }
      });
    } else {
      setState(() => _secondsLeft = newLeft);
    }
  }

  String _formatElapsed(int s) {
    if (s < 60) return '${s}s';
    final m = s ~/ 60; final r = s % 60;
    return r > 0 ? '${m}min ${r}s' : '${m}min';
  }

  // ── Audio ────────────────────────────────────────────────────
  Future<void> _selectAudio(FocusAudio audio) async {
    setState(() => _selectedAudio = audio);
    await FocusAudioService.instance.select(audio);
  }

  // ── Timer ────────────────────────────────────────────────────
  Future<void> _startPause() async {
    if (_isRunning) {
      _timer?.cancel();
      setState(() => _isRunning = false);
      FocusAudioService.instance.pause();
      return;
    }

    final wasPaused = _secondsLeft < _workSeconds;

    if (_isFirstStart && _phase == PomodoroPhase.work) {
      final ctx = await SessionContextPicker.show(
          context, timerType: 'pomodoro');
      if (!mounted) return;
      setState(() {
        _sessionContext = ctx;
        _isFirstStart = false;
      });
    }

    setState(() => _isRunning = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_secondsLeft > 0) {
        setState(() => _secondsLeft--);
      } else {
        _onPhaseComplete();
      }
    });
    wasPaused
        ? FocusAudioService.instance.resume()
        : FocusAudioService.instance.play();
  }

  void _onPhaseComplete() {
    _timer?.cancel();
    FocusAudioService.instance.stop();

    if (_phase == PomodoroPhase.work) {
      setState(() { _isRunning = false; _completedPomodoros++; });
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        final repo = ref.read(timerSessionRepositoryProvider);
        await repo.save(
          type: 'pomodoro',
          durationMinutes: _workSeconds ~/ 60,
          context: _sessionContext,
        );
        if (!mounted) return;
        final action = await SessionEndPopup.show(
          context,
          timerType: 'pomodoro',
          durationMinutes: _workSeconds ~/ 60,
          sessionContext: _sessionContext,
        );
        if (!mounted) return;
        setState(() {
          _phase = PomodoroPhase.shortBreak;
          _secondsLeft = _breakSeconds;
          _isFirstStart = true;
        });
        if (action == SessionEndAction.restart) {
          setState(() => _isRunning = true);
          _timer = Timer.periodic(const Duration(seconds: 1), (_) {
            if (_secondsLeft > 0) {
              setState(() => _secondsLeft--);
            } else {
              _onPhaseComplete();
            }
          });
          FocusAudioService.instance.play();
        }
      });
    } else {
      setState(() {
        _isRunning = false;
        _phase = PomodoroPhase.work;
        _secondsLeft = _workSeconds;
        _isFirstStart = true;
      });
    }
  }

  void _reset() {
    _timer?.cancel();
    FocusAudioService.instance.stop();
    setState(() {
      _isRunning = false;
      _secondsLeft = _phase == PomodoroPhase.work ? _workSeconds : _breakSeconds;
      _sessionContext = null;
      _isFirstStart = true;
    });
  }

  String get _timeDisplay {
    final m = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final s = (_secondsLeft % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  double get _progress =>
      _phase == PomodoroPhase.work
          ? 1 - _secondsLeft / _workSeconds
          : 1 - _secondsLeft / _breakSeconds;

  // Couleurs selon phase
  Color get _phaseColor =>
      _phase == PomodoroPhase.work ? AppColors.secondary : AppColors.accent;

  List<Color> get _arcColors =>
      _phase == PomodoroPhase.work
          ? [AppColors.secondary, AppColors.chartAmber]
          : [AppColors.accent, AppColors.primaryLight];

  String get _phaseLabel =>
      _phase == PomodoroPhase.work ? 'Concentration' : 'Pause courte';

  String get _statusLabel {
    if (_isRunning) return 'En cours...';
    if (_secondsLeft < (_phase == PomodoroPhase.work ? _workSeconds : _breakSeconds)) {
      return 'En pause';
    }
    return 'Prêt à démarrer';
  }

  void _openConfig() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _PomodoroConfigSheet(
        selected: _selectedAudio,
        onSelect: _selectAudio,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
          // ── Ligne ⚙ + dots (le header titre vient de planner_screen) ─
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: _openConfig,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
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
                _PomodoroDots(
                    completed: _completedPomodoros, color: _phaseColor),
              ],
            ),
          ),

          // ── Timer hero ──────────────────────────────────────
          Expanded(
            child: Center(
              child: AnimatedBuilder(
                animation: Listenable.merge([_pulseCtrl, _glowCtrl]),
                builder: (context, _) {
                  final glowAlpha = _isRunning
                      ? 0.18 + 0.12 * _glowCtrl.value
                      : 0.08;
                  final timeOpacity = _isRunning
                      ? 0.8 + 0.2 * _pulseCtrl.value
                      : 1.0;

                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      // Halo radial pulsant
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 320,
                        height: 320,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              _phaseColor.withValues(alpha: glowAlpha),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.75],
                          ),
                        ),
                      ),

                      // Arc — 280px, stroke 12 pour plus d'espace intérieur
                      SizedBox(
                        width: 280,
                        height: 280,
                        child: CustomPaint(
                          painter: _ArcPainter(
                            progress: _progress,
                            colors: _arcColors,
                            trackColor: _phaseColor.withValues(alpha: 0.1),
                            strokeWidth: 12,
                            glowOpacity: _isRunning
                                ? 0.5 + 0.3 * _glowCtrl.value
                                : 0.3,
                          ),
                        ),
                      ),

                      // Contenu central
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Badge phase
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 400),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: _phaseColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _phaseLabel,
                              style: AppTextStyles.caption(
                                color: _phaseColor,
                              ).copyWith(
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Temps
                          Opacity(
                            opacity: timeOpacity,
                            child: Text(
                              _timeDisplay,
                              style: TextStyle(
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
                            _statusLabel,
                            style: AppTextStyles.bodySmall(
                              color: _isRunning
                                  ? _phaseColor
                                  : AppColors.textDarkMuted,
                            ).copyWith(
                              letterSpacing: 0.5,
                              decoration: TextDecoration.none,
                            ),
                          ),

                          // Pill contexte de tâche
                          if (_sessionContext != null) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(
                                color: _phaseColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color:
                                      _phaseColor.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.push_pin_rounded,
                                      size: 11, color: _phaseColor),
                                  const SizedBox(width: 5),
                                  Text(
                                    _sessionContext!.label,
                                    style: AppTextStyles.caption(
                                      color: _phaseColor,
                                    ).copyWith(
                                      fontWeight: FontWeight.w600,
                                      decoration: TextDecoration.none,
                                    ),
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

          // ── Zone basse ───────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Column(
              children: [
                // Audio chips
                _AudioChips(
                  selected: _selectedAudio,
                  color: _phaseColor,
                  onSelect: _selectAudio,
                ),
                const SizedBox(height: 16),

                // Boutons
                Row(
                  children: [
                    _CircleButton(
                      icon: Icons.refresh_rounded,
                      onTap: _reset,
                      color: AppColors.textDarkMuted,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _MainButton(
                        isRunning: _isRunning,
                        isPaused: _secondsLeft <
                            (_phase == PomodoroPhase.work
                                ? _workSeconds
                                : _breakSeconds),
                        disabled: false,
                        color: _phaseColor,
                        onTap: _startPause,
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
}

// ── Dots pomodoros ────────────────────────────────────────────────────────────
class _PomodoroDots extends StatelessWidget {
  const _PomodoroDots({required this.completed, required this.color});
  final int completed;
  final Color color;

  @override
  Widget build(BuildContext context) {
    // On affiche jusqu'à 8 dots max, puis "×N"
    final display = completed.clamp(0, 8);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(display, (i) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: 6,
              ),
            ],
          ),
        )),
        if (completed > 8) ...[
          const SizedBox(width: 4),
          Text(
            '×$completed',
            style: AppTextStyles.caption(color: color)
                .copyWith(fontWeight: FontWeight.w700),
          ),
        ],
        if (completed == 0)
          Text(
            '🍅 Premier pomodoro',
            style: AppTextStyles.caption(color: AppColors.textDarkMuted),
          ),
      ],
    );
  }
}

// ── Chips audio ───────────────────────────────────────────────────────────────
class _AudioChips extends StatelessWidget {
  const _AudioChips({
    required this.selected,
    required this.color,
    required this.onSelect,
  });
  final FocusAudio selected;
  final Color color;
  final ValueChanged<FocusAudio> onSelect;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: FocusAudio.values.map((audio) {
          final on = audio == selected;
          return GestureDetector(
            onTap: () => onSelect(audio),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: on
                    ? color.withValues(alpha: 0.18)
                    : Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: on
                      ? color.withValues(alpha: 0.5)
                      : Colors.white.withValues(alpha: 0.07),
                  width: on ? 1.5 : 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(audio.emoji,
                      style: const TextStyle(fontSize: 12)),
                  const SizedBox(width: 5),
                  Text(
                    audio.label,
                    style: AppTextStyles.caption(
                      color: on ? color : AppColors.textDarkMuted,
                    ).copyWith(
                        fontWeight:
                            on ? FontWeight.w600 : FontWeight.w400),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
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
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
    );
  }
}

// ── Bouton principal ──────────────────────────────────────────────────────────
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
    final icon =
        isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded;

    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 52,
        decoration: BoxDecoration(
          gradient: disabled
              ? null
              : LinearGradient(
                  colors: [color, color.withValues(alpha: 0.7)],
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

// ── Bottom sheet config Pomodoro ──────────────────────────────────────────────
class _PomodoroConfigSheet extends StatefulWidget {
  const _PomodoroConfigSheet({
    required this.selected,
    required this.onSelect,
  });
  final FocusAudio selected;
  final ValueChanged<FocusAudio> onSelect;

  @override
  State<_PomodoroConfigSheet> createState() => _PomodoroConfigSheetState();
}

class _PomodoroConfigSheetState extends State<_PomodoroConfigSheet> {
  late FocusAudio _current;

  @override
  void initState() {
    super.initState();
    _current = widget.selected;
  }

  @override
  Widget build(BuildContext context) {
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
            'Configuration Pomodoro',
            style: AppTextStyles.headingSmall(color: AppColors.textDark),
          ),
          const SizedBox(height: 8),
          Text(
            '25 min de travail · 5 min de pause · classique & éprouvé',
            style: AppTextStyles.caption(color: AppColors.textDarkMuted),
          ),
          const SizedBox(height: 24),
          Text(
            'Ambiance sonore',
            style: AppTextStyles.caption(color: AppColors.textDarkMuted),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: FocusAudio.values.map((audio) {
              final on = audio == _current;
              return GestureDetector(
                onTap: () {
                  setState(() => _current = audio);
                  widget.onSelect(audio);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: on
                        ? AppColors.secondary.withValues(alpha: 0.18)
                        : Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: on
                          ? AppColors.secondary.withValues(alpha: 0.5)
                          : Colors.white.withValues(alpha: 0.08),
                      width: on ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(audio.emoji,
                          style: const TextStyle(fontSize: 14)),
                      const SizedBox(width: 6),
                      Text(
                        audio.label,
                        style: AppTextStyles.bodySmall(
                          color: on
                              ? AppColors.secondary
                              : AppColors.textDarkMuted,
                        ).copyWith(
                          fontWeight:
                              on ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ── Écran autonome Pomodoro (route dédiée) ────────────────────────────────────
class PomodoroScreen extends StatelessWidget {
  const PomodoroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(child: PomodoroContent()),
    );
  }
}
