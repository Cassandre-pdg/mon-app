import 'dart:async';
import 'package:flutter/material.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/constants/app_constants.dart';

// ── Écran Focus Mode — blocage de distractions ────────────────
class FocusBlockScreen extends StatefulWidget {
  const FocusBlockScreen({super.key});

  @override
  State<FocusBlockScreen> createState() => _FocusBlockScreenState();
}

class _FocusBlockScreenState extends State<FocusBlockScreen>
    with TickerProviderStateMixin {
  static const _durations = [30, 60, 90, 120];
  int _selectedMinutes = 60;
  bool _isActive       = false;
  int _secondsLeft     = 0;
  Timer? _timer;

  late final AnimationController _pulseCtrl;
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
    _timer?.cancel();
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _startFocus() {
    setState(() {
      _isActive    = true;
      _secondsLeft = _selectedMinutes * 60;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_secondsLeft <= 0) {
        _endFocus(completed: true);
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  void _stopFocus() {
    _timer?.cancel();
    setState(() => _isActive = false);
  }

  void _endFocus({bool completed = false}) {
    _timer?.cancel();
    setState(() => _isActive = false);
    if (completed && mounted) {
      _showCompletionDialog();
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('🎉 Focus terminé !'),
        content: Text(
          'Tu as tenu $_selectedMinutes minutes sans distraction. Belle avancée !',
          style: AppTextStyles.bodyMedium(),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Terminé'),
          ),
        ],
      ),
    );
  }

  String get _timeDisplay {
    final m = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final s = (_secondsLeft % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  double get _progress =>
      _isActive ? 1 - _secondsLeft / (_selectedMinutes * 60) : 0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () {
            if (_isActive) {
              _showExitConfirm(context);
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          '🔕 Mode Focus',
          style: AppTextStyles.headingMedium(
            color: isDark ? AppColors.textDark : AppColors.textLight,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.spacing24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: AppConstants.spacing16),

              // ── Description ────────────────────────────────────
              if (!_isActive) ...[
                Container(
                  padding: const EdgeInsets.all(AppConstants.spacing16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius:
                        BorderRadius.circular(AppConstants.radiusLarge),
                  ),
                  child: Column(
                    children: [
                      const Text('🔕', style: TextStyle(fontSize: 32)),
                      const SizedBox(height: 8),
                      Text(
                        'Protège ton focus',
                        style: AppTextStyles.headingSmall(
                          color: isDark
                              ? AppColors.textDark
                              : AppColors.textLight,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Lance un bloc de concentration et mets de côté les distractions. Ton téléphone peut attendre.',
                        style: AppTextStyles.bodyMedium(
                            color: AppColors.grey400),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppConstants.spacing32),

                // ── Sélecteur de durée ───────────────────────────
                Text(
                  'Choisie ta durée',
                  style: AppTextStyles.labelMedium(
                    color: isDark ? AppColors.textDark : AppColors.textLight,
                  ),
                ),
                const SizedBox(height: AppConstants.spacing16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: _durations.map((min) {
                    final isSelected = min == _selectedMinutes;
                    return GestureDetector(
                      onTap: () =>
                          setState(() => _selectedMinutes = min),
                      child: AnimatedContainer(
                        duration: AppConstants.animFast,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : isDark
                                  ? AppColors.surfaceDark
                                  : AppColors.surfaceLight,
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.grey200.withValues(alpha: 0.5),
                          ),
                          borderRadius: BorderRadius.circular(
                              AppConstants.radiusPill),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '$min min',
                              style: AppTextStyles.labelMedium(
                                color: isSelected
                                    ? Colors.white
                                    : isDark
                                        ? AppColors.textDark
                                        : AppColors.textLight,
                              ),
                            ),
                            if (min == 30)
                              Text('Court',
                                  style: AppTextStyles.caption(
                                      color: isSelected
                                          ? Colors.white70
                                          : AppColors.grey400))
                            else if (min == 60)
                              Text('Équilibré',
                                  style: AppTextStyles.caption(
                                      color: isSelected
                                          ? Colors.white70
                                          : AppColors.grey400))
                            else if (min == 90)
                              Text('Profond',
                                  style: AppTextStyles.caption(
                                      color: isSelected
                                          ? Colors.white70
                                          : AppColors.grey400))
                            else
                              Text('Intense',
                                  style: AppTextStyles.caption(
                                      color: isSelected
                                          ? Colors.white70
                                          : AppColors.grey400)),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppConstants.spacing48),

                // ── Bouton démarrer ──────────────────────────────
                ElevatedButton.icon(
                  onPressed: _startFocus,
                  icon: const Icon(Icons.do_not_disturb_on_rounded),
                  label: Text('Démarrer $_selectedMinutes min de focus'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 14),
                  ),
                ),
              ],

              // ── Timer actif ────────────────────────────────────
              if (_isActive) ...[
                const SizedBox(height: AppConstants.spacing16),

                // Halo pulsant + cercle de progression
                AnimatedBuilder(
                  animation: _pulseCtrl,
                  builder: (_, child) => Container(
                    width: 260,
                    height: 260,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(
                              alpha: 0.15 + 0.1 * _pulseCtrl.value),
                          blurRadius: 40 + 20 * _pulseCtrl.value,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: child,
                  ),
                  child: SizedBox(
                    width: 260,
                    height: 260,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox.expand(
                          child: CircularProgressIndicator(
                            value: _progress,
                            strokeWidth: 8,
                            backgroundColor:
                                AppColors.grey200.withValues(alpha: 0.2),
                            valueColor: const AlwaysStoppedAnimation(
                                AppColors.primary),
                            strokeCap: StrokeCap.round,
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('🔕',
                                style: TextStyle(fontSize: 32)),
                            const SizedBox(height: 8),
                            Text(
                              _timeDisplay,
                              style: AppTextStyles.displayLarge(
                                      color: isDark
                                          ? AppColors.textDark
                                          : AppColors.textLight)
                                  .copyWith(
                                fontSize: 44,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'Focus en cours...',
                              style: AppTextStyles.caption(
                                  color: AppColors.primaryLight),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppConstants.spacing32),

                // Message encourageant
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius:
                        BorderRadius.circular(AppConstants.radiusPill),
                  ),
                  child: Text(
                    'Tu avances, les distractions peuvent attendre 💜',
                    style: AppTextStyles.bodySmall(
                        color: AppColors.primaryLight),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: AppConstants.spacing48),

                // Bouton arrêter
                TextButton.icon(
                  onPressed: () => _showExitConfirm(context),
                  icon: const Icon(Icons.stop_rounded,
                      color: AppColors.grey400),
                  label: Text(
                    'Arrêter le focus',
                    style: AppTextStyles.bodySmall(
                        color: AppColors.grey400),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showExitConfirm(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Arrêter le focus ?'),
        content: const Text(
            'Tu es sur le point d\'interrompre ton bloc de concentration.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Continuer le focus'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (_isActive) {
                _stopFocus();
              } else {
                Navigator.pop(context);
              }
            },
            child: const Text('Arrêter',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
