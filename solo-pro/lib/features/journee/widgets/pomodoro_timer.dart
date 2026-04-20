import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';

enum PomodoroPhase { focus, shortBreak, longBreak }

class PomodoroTimer extends StatefulWidget {
  const PomodoroTimer({super.key});

  @override
  State<PomodoroTimer> createState() => _PomodoroTimerState();
}

class _PomodoroTimerState extends State<PomodoroTimer>
    with SingleTickerProviderStateMixin {
  static const int _focusDuration = 25 * 60;
  static const int _shortBreak = 5 * 60;
  static const int _longBreak = 15 * 60;

  PomodoroPhase _phase = PomodoroPhase.focus;
  int _secondsLeft = _focusDuration;
  bool _running = false;
  int _completedPomodoros = 0;
  Timer? _timer;

  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.97, end: 1.03)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseCtrl.dispose();
    super.dispose();
  }

  int get _totalSeconds {
    switch (_phase) {
      case PomodoroPhase.focus: return _focusDuration;
      case PomodoroPhase.shortBreak: return _shortBreak;
      case PomodoroPhase.longBreak: return _longBreak;
    }
  }

  double get _progress => 1 - (_secondsLeft / _totalSeconds);

  String get _timeLabel {
    final m = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final s = (_secondsLeft % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Color get _phaseColor {
    switch (_phase) {
      case PomodoroPhase.focus: return const Color(0xFFFF6B6B);
      case PomodoroPhase.shortBreak: return AppColors.accentGreen;
      case PomodoroPhase.longBreak: return AppColors.primary;
    }
  }

  String get _phaseLabel {
    switch (_phase) {
      case PomodoroPhase.focus: return 'Focus 🍅';
      case PomodoroPhase.shortBreak: return 'Pause courte ☕';
      case PomodoroPhase.longBreak: return 'Grande pause 🌿';
    }
  }

  void _toggleTimer() {
    HapticFeedback.mediumImpact();
    if (_running) {
      _timer?.cancel();
      _pulseCtrl.stop();
    } else {
      _pulseCtrl.repeat(reverse: true);
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (_secondsLeft > 0) {
          setState(() => _secondsLeft--);
        } else {
          _onPhaseEnd();
        }
      });
    }
    setState(() => _running = !_running);
  }

  void _onPhaseEnd() {
    HapticFeedback.heavyImpact();
    _timer?.cancel();
    setState(() {
      _running = false;
      if (_phase == PomodoroPhase.focus) {
        _completedPomodoros++;
        _phase = (_completedPomodoros % 4 == 0)
            ? PomodoroPhase.longBreak
            : PomodoroPhase.shortBreak;
      } else {
        _phase = PomodoroPhase.focus;
      }
      _secondsLeft = _totalSeconds;
    });
  }

  void _reset() {
    _timer?.cancel();
    setState(() {
      _running = false;
      _secondsLeft = _totalSeconds;
    });
  }

  void _switchPhase(PomodoroPhase phase) {
    _timer?.cancel();
    setState(() {
      _phase = phase;
      _running = false;
      _secondsLeft = _totalSeconds;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 16),

          // Sélecteur de phase
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: PomodoroPhase.values.map((p) {
                final isActive = _phase == p;
                final labels = ['Focus', 'Pause 5\'', 'Pause 15\''];
                return Expanded(
                  child: GestureDetector(
                    onTap: () => _switchPhase(p),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isActive ? AppColors.surface : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: isActive
                            ? [BoxShadow(
                                color: Colors.black.withValues(alpha: 0.06),
                                blurRadius: 4)]
                            : [],
                      ),
                      child: Text(
                        labels[p.index],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isActive
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isActive
                              ? _phaseColor
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 48),

          // Cercle animé
          AnimatedBuilder(
            animation: _pulseAnim,
            builder: (_, child) => Transform.scale(
              scale: _running ? _pulseAnim.value : 1.0,
              child: child,
            ),
            child: SizedBox(
              width: 220,
              height: 220,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Cercle de fond
                  SizedBox(
                    width: 220,
                    height: 220,
                    child: CircularProgressIndicator(
                      value: _progress,
                      strokeWidth: 14,
                      backgroundColor: _phaseColor.withValues(alpha: 0.12),
                      valueColor: AlwaysStoppedAnimation<Color>(_phaseColor),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  // Contenu central
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _timeLabel,
                        style: TextStyle(
                          fontSize: 52,
                          fontWeight: FontWeight.w900,
                          color: _phaseColor,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      Text(
                        _phaseLabel,
                        style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 40),

          // Boutons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Reset
              GestureDetector(
                onTap: _reset,
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.refresh,
                      color: AppColors.textSecondary, size: 22),
                ),
              ),
              const SizedBox(width: 20),
              // Play/Pause principal
              GestureDetector(
                onTap: _toggleTimer,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: _phaseColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _phaseColor.withValues(alpha: 0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      )
                    ],
                  ),
                  child: Icon(
                    _running ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              // Skip
              GestureDetector(
                onTap: _onPhaseEnd,
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.skip_next,
                      color: AppColors.textSecondary, size: 22),
                ),
              ),
            ],
          ),

          const SizedBox(height: 36),

          // Compteur tomates
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Pomodoros aujourd\'hui : ',
                  style: TextStyle(
                      color: AppColors.textSecondary, fontSize: 13)),
              ...List.generate(
                max(_completedPomodoros, 1),
                (i) => Text(
                  i < _completedPomodoros ? '🍅' : '⭕',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Conseil
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _phaseColor.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Text('💡', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _phase == PomodoroPhase.focus
                        ? 'Ferme tes notifications. 25 min, une seule tâche.'
                        : 'Lève-toi, étire-toi, bois de l\'eau. Le cerveau a besoin de pauses !',
                    style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
