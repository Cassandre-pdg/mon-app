import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';

class DeepWorkSession extends StatefulWidget {
  const DeepWorkSession({super.key});

  @override
  State<DeepWorkSession> createState() => _DeepWorkSessionState();
}

class _DeepWorkSessionState extends State<DeepWorkSession> {
  static const List<int> _durations = [60, 90, 120];
  int _selectedMinutes = 90;
  int _secondsLeft = 90 * 60;
  bool _running = false;
  bool _started = false;
  Timer? _timer;
  String _sessionGoal = '';
  final _goalCtrl = TextEditingController();

  @override
  void dispose() {
    _timer?.cancel();
    _goalCtrl.dispose();
    super.dispose();
  }

  double get _progress =>
      1 - (_secondsLeft / (_selectedMinutes * 60));

  String get _timeLabel {
    final h = _secondsLeft ~/ 3600;
    final m = (_secondsLeft % 3600) ~/ 60;
    final s = _secondsLeft % 60;
    if (h > 0) {
      return '${h}h ${m.toString().padLeft(2, '0')}m';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void _start() {
    if (_goalCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Définis ton objectif de session avant de commencer'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    HapticFeedback.mediumImpact();
    setState(() {
      _sessionGoal = _goalCtrl.text.trim();
      _started = true;
      _running = true;
      _secondsLeft = _selectedMinutes * 60;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_secondsLeft > 0) {
        setState(() => _secondsLeft--);
      } else {
        _onEnd();
      }
    });
  }

  void _togglePause() {
    HapticFeedback.lightImpact();
    if (_running) {
      _timer?.cancel();
    } else {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (_secondsLeft > 0) {
          setState(() => _secondsLeft--);
        } else {
          _onEnd();
        }
      });
    }
    setState(() => _running = !_running);
  }

  void _onEnd() {
    HapticFeedback.heavyImpact();
    _timer?.cancel();
    setState(() => _running = false);
  }

  void _reset() {
    _timer?.cancel();
    setState(() {
      _started = false;
      _running = false;
      _secondsLeft = _selectedMinutes * 60;
      _sessionGoal = '';
      _goalCtrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: _started ? _buildActiveSession() : _buildSetup(),
    );
  }

  // ─── Setup ────────────────────────────────────────────────────────────────

  Widget _buildSetup() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text(
          'Prépare ta session',
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.w800,
              color: AppColors.textPrimary),
        ),
        const SizedBox(height: 4),
        const Text(
          'Définis ton objectif et la durée. Zéro distraction.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 28),

        // Objectif de session
        const Text('Objectif de la session',
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        TextField(
          controller: _goalCtrl,
          maxLines: 2,
          decoration: InputDecoration(
            hintText: 'Ex : Finir le rapport client, coder la feature X...',
            filled: true,
            fillColor: AppColors.surfaceVariant,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Durée
        const Text('Durée de la session',
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary)),
        const SizedBox(height: 10),
        Row(
          children: _durations.map((d) {
            final isSelected = _selectedMinutes == d;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() {
                  _selectedMinutes = d;
                  _secondsLeft = d * 60;
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.accentGreen.withValues(alpha: 0.12)
                        : AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(14),
                    border: isSelected
                        ? Border.all(
                            color: AppColors.accentGreen, width: 2)
                        : null,
                  ),
                  child: Column(
                    children: [
                      Text('${d}min',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: isSelected
                                ? AppColors.accentGreen
                                : AppColors.textPrimary,
                          )),
                      Text(
                        d == 60
                            ? 'Standard'
                            : d == 90
                                ? 'Recommandé'
                                : 'Long',
                        style: TextStyle(
                          fontSize: 10,
                          color: isSelected
                              ? AppColors.accentGreen
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 28),

        // Checklist pré-session
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.accentGreen.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: AppColors.accentGreen.withValues(alpha: 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Avant de commencer 🧘',
                  style: TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 13)),
              const SizedBox(height: 10),
              ...[
                'Téléphone en mode avion',
                'Notifications coupées',
                'Eau ou boisson à portée',
                'Un seul onglet ouvert',
              ].map((tip) => Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_outline,
                            size: 14, color: AppColors.accentGreen),
                        const SizedBox(width: 8),
                        Text(tip,
                            style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary)),
                      ],
                    ),
                  )),
            ],
          ),
        ),

        const SizedBox(height: 24),

        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: _start,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentGreen,
            ),
            child: const Text('Démarrer la session 🧠',
                style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  // ─── Session active ───────────────────────────────────────────────────────

  Widget _buildActiveSession() {
    final isDone = _secondsLeft == 0;
    return Column(
      children: [
        const SizedBox(height: 24),

        // Objectif
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.accentGreen.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              const Text('🎯', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _sessionGoal,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: AppColors.textPrimary),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 40),

        // Timer
        SizedBox(
          width: 200,
          height: 200,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 200,
                height: 200,
                child: CircularProgressIndicator(
                  value: _progress,
                  strokeWidth: 12,
                  backgroundColor:
                      AppColors.accentGreen.withValues(alpha: 0.12),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isDone
                        ? AppColors.accentYellow
                        : AppColors.accentGreen,
                  ),
                  strokeCap: StrokeCap.round,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isDone ? '🎉' : _timeLabel,
                    style: TextStyle(
                      fontSize: isDone ? 48 : 40,
                      fontWeight: FontWeight.w900,
                      color: isDone
                          ? AppColors.accentYellow
                          : AppColors.accentGreen,
                    ),
                  ),
                  Text(
                    isDone ? 'Session terminée !' : 'Deep Work',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 40),

        // Boutons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _reset,
              child: Container(
                width: 52,
                height: 52,
                decoration: const BoxDecoration(
                  color: AppColors.surfaceVariant,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.stop,
                    color: AppColors.textSecondary, size: 22),
              ),
            ),
            const SizedBox(width: 20),
            if (!isDone)
              GestureDetector(
                onTap: _togglePause,
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.accentGreen,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accentGreen.withValues(alpha: 0.3),
                        blurRadius: 14,
                        offset: const Offset(0, 5),
                      )
                    ],
                  ),
                  child: Icon(
                    _running ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              )
            else
              GestureDetector(
                onTap: _reset,
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.accentYellow,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accentYellow.withValues(alpha: 0.3),
                        blurRadius: 14,
                        offset: const Offset(0, 5),
                      )
                    ],
                  ),
                  child: const Icon(Icons.replay,
                      color: Colors.white, size: 28),
                ),
              ),
          ],
        ),

        if (isDone) ...[
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.accentYellow.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              '🏆 Excellent travail ! Tu viens de terminer une session de Deep Work. Prends 10 minutes de vraie déconnexion avant de continuer.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 13, color: AppColors.textPrimary, height: 1.5),
            ),
          ),
        ],
        const SizedBox(height: 24),
      ],
    );
  }
}
