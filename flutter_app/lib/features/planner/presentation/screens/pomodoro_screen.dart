import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/constants/app_constants.dart';
import '../../../../shared/services/focus_audio_service.dart';
import '../providers/timer_session_provider.dart';
import '../../data/session_context_model.dart';
import '../widgets/session_context_picker.dart';
import '../widgets/session_end_popup.dart';

enum PomodoroPhase { work, shortBreak }

// ── Contenu Pomodoro (sans Scaffold) — utilisable en onglet ──
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
  FocusAudio _selectedAudio = FocusAudio.silence;

  // Contexte de session
  SessionContext? _sessionContext;
  bool _isFirstStart = true;

  // Suivi background
  DateTime? _backgroundAt;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _pulseCtrl.dispose();
    super.dispose();
  }

  // ── Détection arrière-plan ───────────────────────────────────
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
    if (bg == null) return;
    _backgroundAt = null;

    if (!_isRunning) return;

    final elapsed = DateTime.now().difference(bg).inSeconds;
    if (elapsed < 3) return;

    final newSecondsLeft = _secondsLeft - elapsed;

    if (newSecondsLeft <= 0) {
      _onPhaseComplete();
      return;
    }

    if (elapsed >= 180 && mounted) {
      // Absence >= 3 min : on propose un choix
      showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Tu étais absent·e'),
          content: Text(
            '${_formatElapsed(elapsed)} se sont écoulées.\nOn compte ce temps ?',
          ),
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
      ).then((countTime) {
        if (!mounted) return;
        if (countTime == true) {
          setState(() => _secondsLeft = newSecondsLeft);
        } else {
          // Pause
          _timer?.cancel();
          setState(() => _isRunning = false);
          FocusAudioService.instance.pause();
        }
      });
    } else {
      setState(() => _secondsLeft = newSecondsLeft);
    }
  }

  String _formatElapsed(int seconds) {
    if (seconds < 60) return '${seconds}s';
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return s > 0 ? '${m}min ${s}s' : '${m}min';
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

    // Picker uniquement au tout premier démarrage d'une session de travail
    if (_isFirstStart && _phase == PomodoroPhase.work) {
      final ctx = await SessionContextPicker.show(context, timerType: 'pomodoro');
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
    if (wasPaused) {
      FocusAudioService.instance.resume();
    } else {
      FocusAudioService.instance.play();
    }
  }

  void _onPhaseComplete() {
    _timer?.cancel();
    FocusAudioService.instance.stop();

    if (_phase == PomodoroPhase.work) {
      // Fin de phase travail : afficher le popup avant de passer à la pause
      setState(() => _isRunning = false);
      _completedPomodoros++;
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

        // Passer en mode pause dans tous les cas
        setState(() {
          _phase = PomodoroPhase.shortBreak;
          _secondsLeft = _breakSeconds;
          _isFirstStart = true;
        });

        if (action == SessionEndAction.restart) {
          // Démarrer la pause automatiquement
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
        // completed ou later : pause manuelle, l'utilisateur démarre quand il veut
      });
    } else {
      // Fin de pause : retour en mode travail
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

  Color get _phaseColor =>
      _phase == PomodoroPhase.work
          ? AppColors.secondary
          : AppColors.accent;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.spacing24),
      child: Column(
        children: [
          const SizedBox(height: AppConstants.spacing16),

          // Contexte de session affiché pendant la session
          if (_sessionContext != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.secondary.withValues(alpha: 0.25),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.push_pin_rounded,
                      size: 12, color: AppColors.secondary),
                  const SizedBox(width: 6),
                  Text(
                    _sessionContext!.label,
                    style: AppTextStyles.caption(color: AppColors.secondary)
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppConstants.spacing16),
          ],

          // Phase label
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _phaseColor.withValues(alpha: 0.12),
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
                      style: AppTextStyles.bodySmall(
                          color: AppColors.grey400),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: AppConstants.spacing32),

          // Compteur pomodoros
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Pomodoros complétés : ',
                style: AppTextStyles.bodyMedium(color: AppColors.grey400),
              ),
              Text(
                '$_completedPomodoros',
                style: AppTextStyles.headingSmall(color: _phaseColor),
              ),
              const Text(' 🍅', style: TextStyle(fontSize: 16)),
            ],
          ),

          const SizedBox(height: AppConstants.spacing32),

          // ── Ambiance sonore ────────────────────────────────────
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Ambiance sonore',
              style: AppTextStyles.labelMedium(color: AppColors.grey400),
            ),
          ),
          const SizedBox(height: 8),
          _PomodoroAudioPicker(
            selected: _selectedAudio,
            onSelect: _selectAudio,
          ),

          const SizedBox(height: AppConstants.spacing32),

          // Boutons contrôle
          Row(
            children: [
              IconButton.outlined(
                onPressed: _reset,
                icon: const Icon(Icons.refresh_rounded),
                style: IconButton.styleFrom(padding: const EdgeInsets.all(16)),
              ),
              const SizedBox(width: AppConstants.spacing16),
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

// ── Sélecteur d'ambiance sonore (Pomodoro) ────────────────────
class _PomodoroAudioPicker extends StatelessWidget {
  final FocusAudio selected;
  final ValueChanged<FocusAudio> onSelect;

  const _PomodoroAudioPicker(
      {required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: FocusAudio.values.map((audio) {
          final isSelected = audio == selected;
          return GestureDetector(
            onTap: () => onSelect(audio),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.secondary.withValues(alpha: 0.15)
                    : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? AppColors.secondary
                      : AppColors.grey200,
                  width: isSelected ? 1.5 : 1,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(audio.emoji,
                      style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 5),
                  Text(
                    audio.label,
                    style: AppTextStyles.caption(
                      color: isSelected
                          ? AppColors.secondary
                          : AppColors.grey400,
                    ).copyWith(
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
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

// ── Écran autonome Pomodoro (avec Scaffold) ───────────────────
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
