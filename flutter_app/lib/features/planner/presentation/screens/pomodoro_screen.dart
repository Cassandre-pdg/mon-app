import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/constants/app_constants.dart';

enum PomodoroPhase { work, shortBreak }

// ── Contenu Pomodoro (sans Scaffold) — utilisable en onglet ──
class PomodoroContent extends StatefulWidget {
  const PomodoroContent({super.key});

  @override
  State<PomodoroContent> createState() => _PomodoroContentState();
}

class _PomodoroContentState extends State<PomodoroContent>
    with TickerProviderStateMixin {
  static const int _workSeconds  = 25 * 60;
  static const int _breakSeconds = 5 * 60;

  PomodoroPhase _phase    = PomodoroPhase.work;
  int _secondsLeft        = _workSeconds;
  bool _isRunning         = false;
  int _completedPomodoros = 0;
  Timer? _timer;
  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _startPause() {
    if (_isRunning) {
      _timer?.cancel();
      setState(() => _isRunning = false);
    } else {
      setState(() => _isRunning = true);
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (_secondsLeft > 0) {
          setState(() => _secondsLeft--);
        } else {
          _onPhaseComplete();
        }
      });
    }
  }

  void _onPhaseComplete() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      if (_phase == PomodoroPhase.work) {
        _completedPomodoros++;
        _phase = PomodoroPhase.shortBreak;
        _secondsLeft = _breakSeconds;
      } else {
        _phase = PomodoroPhase.work;
        _secondsLeft = _workSeconds;
      }
    });
  }

  void _reset() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _secondsLeft =
          _phase == PomodoroPhase.work ? _workSeconds : _breakSeconds;
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

  Color get _phaseColor =>
      _phase == PomodoroPhase.work ? AppColors.secondary : AppColors.accent;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.spacing24),
      child: Column(
        children: [
          const SizedBox(height: AppConstants.spacing24),

          // Phase label
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _phaseColor.withValues(alpha:0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _phase == PomodoroPhase.work
                  ? '⚡ Concentration'
                  : '☕ Pause courte',
              style: AppTextStyles.labelMedium(color: _phaseColor),
            ),
          ),
          const SizedBox(height: AppConstants.spacing32),

          // Cercle de progression
          SizedBox(
            width: 240,
            height: 240,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox.expand(
                  child: CircularProgressIndicator(
                    value: _progress,
                    strokeWidth: 8,
                    backgroundColor: AppColors.grey200,
                    valueColor: AlwaysStoppedAnimation(_phaseColor),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _pulseCtrl,
                      builder: (_, child) => Opacity(
                        opacity: _isRunning
                            ? 0.7 + 0.3 * _pulseCtrl.value
                            : 1.0,
                        child: child,
                      ),
                      child: Text(
                        _timeDisplay,
                        style: AppTextStyles.displayLarge(
                          color: isDark
                              ? AppColors.textDark
                              : AppColors.textLight,
                        ).copyWith(
                          fontSize: 48,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      _isRunning ? 'En cours...' : 'Prêt',
                      style:
                          AppTextStyles.bodySmall(color: AppColors.grey400),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: AppConstants.spacing32),

          // Compteur pomodoros complétés
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Pomodoros complétés : ',
                style: AppTextStyles.bodyMedium(color: AppColors.grey400),
              ),
              Text(
                '$_completedPomodoros',
                style:
                    AppTextStyles.headingSmall(color: _phaseColor),
              ),
              const Text(' 🍅', style: TextStyle(fontSize: 16)),
            ],
          ),

          const SizedBox(height: AppConstants.spacing48),

          // Boutons contrôle
          Row(
            children: [
              // Reset
              IconButton.outlined(
                onPressed: _reset,
                icon: const Icon(Icons.refresh_rounded),
                style: IconButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
              const SizedBox(width: AppConstants.spacing16),

              // Play / Pause
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _startPause,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _phaseColor,
                  ),
                  icon: Icon(
                    _isRunning
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                  ),
                  label: Text(_isRunning ? 'Pause' : 'Démarrer'),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacing16),

          Text(
            '25 min de travail · 5 min de pause',
            style: AppTextStyles.caption(),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.spacing24),
        ],
      ),
    );
  }
}

// ── Écran autonome Pomodoro (avec Scaffold) ───────────────────
// Conservé pour une éventuelle utilisation standalone
class PomodoroScreen extends StatelessWidget {
  const PomodoroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('🍅 Pomodoro'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: const SafeArea(child: PomodoroContent()),
    );
  }
}
