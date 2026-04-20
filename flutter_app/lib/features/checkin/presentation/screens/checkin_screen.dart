import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/constants/app_constants.dart';
import '../../../../shared/constants/app_strings.dart';
import '../providers/checkin_provider.dart';

class CheckinScreen extends ConsumerStatefulWidget {
  final String type; // 'morning' | 'evening'
  const CheckinScreen({super.key, required this.type});

  @override
  ConsumerState<CheckinScreen> createState() => _CheckinScreenState();
}

class _CheckinScreenState extends ConsumerState<CheckinScreen> {
  int _moodScore    = 3;
  int _energyScore  = 3;
  int _focusScore   = 3;
  final _notesCtrl  = TextEditingController();
  int _currentStep  = 0;

  bool get isMorning => widget.type == 'morning';

  List<_Question> get questions => isMorning
      ? [
          _Question(AppStrings.morningQ1, Icons.mood_rounded,       AppColors.primary),
          _Question(AppStrings.morningQ2, Icons.bolt_rounded,        AppColors.warning),
          _Question(AppStrings.morningQ3, Icons.center_focus_strong, AppColors.accent),
        ]
      : [
          _Question(AppStrings.eveningQ1, Icons.wb_sunny_rounded,    AppColors.secondary),
          _Question(AppStrings.eveningQ2, Icons.bolt_rounded,        AppColors.warning),
          _Question(AppStrings.eveningQ3, Icons.thumb_up_rounded,    AppColors.success),
        ];

  int get _currentScore {
    switch (_currentStep) {
      case 0: return _moodScore;
      case 1: return _energyScore;
      case 2: return _focusScore;
      default: return 3;
    }
  }

  void _setScore(int v) => setState(() {
        switch (_currentStep) {
          case 0: _moodScore   = v; break;
          case 1: _energyScore = v; break;
          case 2: _focusScore  = v; break;
        }
      });

  Future<void> _submit() async {
    await ref.read(checkinNotifierProvider.notifier).submit(
          type: widget.type,
          moodScore: _moodScore,
          energyScore: _energyScore,
          focusScore: _focusScore,
          notes: _notesCtrl.text.isNotEmpty ? _notesCtrl.text : null,
        );
    if (mounted) {
      _showSuccessAndPop();
    }
  }

  void _showSuccessAndPop() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _SuccessDialog(isMorning: isMorning),
    );
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pop(); // ferme dialog
        context.pop();               // retour dashboard
      }
    });
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final q = questions[_currentStep];
    final isLastStep = _currentStep == 2;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(isMorning
            ? AppStrings.checkinMorningTitle
            : AppStrings.checkinEveningTitle),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacing24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Barre de progression
              Row(
                children: List.generate(3, (i) => Expanded(
                  child: Container(
                    height: 4,
                    margin: EdgeInsets.only(right: i < 2 ? 6 : 0),
                    decoration: BoxDecoration(
                      color: i <= _currentStep
                          ? AppColors.primary
                          : AppColors.grey200,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                )),
              ),
              const SizedBox(height: AppConstants.spacing32),

              // Icône de la question
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: q.color.withValues(alpha:0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(q.icon, color: q.color, size: 32),
              ),
              const SizedBox(height: AppConstants.spacing24),

              // Question
              Text(
                q.label,
                style: AppTextStyles.headingMedium(
                  color: isDark ? AppColors.textDark : AppColors.textLight,
                ),
              ),
              const SizedBox(height: AppConstants.spacing8),
              Text(
                'De 1 (pas du tout) à 5 (au top)',
                style: AppTextStyles.bodySmall(color: AppColors.grey400),
              ),
              const SizedBox(height: AppConstants.spacing32),

              // Sélecteur 1-5 avec émojis
              _ScoreSelector(
                value: _currentScore,
                color: q.color,
                onChanged: _setScore,
              ),

              const SizedBox(height: AppConstants.spacing32),

              // Note libre (dernière étape seulement)
              if (isLastStep) ...[
                Text(
                  'Une note ? (optionnel)',
                  style: AppTextStyles.labelMedium(
                    color: isDark ? AppColors.textDark : AppColors.textLight,
                  ),
                ),
                const SizedBox(height: AppConstants.spacing8),
                TextField(
                  controller: _notesCtrl,
                  maxLines: 3,
                  maxLength: 280,
                  decoration: const InputDecoration(
                    hintText: 'Ce qui me passe par la tête...',
                    counterText: '',
                  ),
                ),
                const SizedBox(height: AppConstants.spacing24),
              ],

              const Spacer(),

              // Bouton suivant / valider
              ElevatedButton(
                onPressed: () {
                  if (!isLastStep) {
                    setState(() => _currentStep++);
                  } else {
                    _submit();
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: q.color),
                child: Text(isLastStep ? 'Valider mon check-in ✅' : 'Suivant'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Sélecteur de score 1-5 ───────────────────────────────────
class _ScoreSelector extends StatelessWidget {
  final int value;
  final Color color;
  final ValueChanged<int> onChanged;

  const _ScoreSelector({
    required this.value,
    required this.color,
    required this.onChanged,
  });

  static const _emojis = ['😔', '😕', '😐', '🙂', '😄'];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(5, (i) {
        final score = i + 1;
        final selected = score == value;
        return GestureDetector(
          onTap: () => onChanged(score),
          child: AnimatedContainer(
            duration: AppConstants.animFast,
            width: selected ? 64 : 52,
            height: selected ? 64 : 52,
            decoration: BoxDecoration(
              color: selected ? color.withValues(alpha:0.15) : Colors.transparent,
              border: Border.all(
                color: selected ? color : AppColors.grey200,
                width: selected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _emojis[i],
                  style: TextStyle(fontSize: selected ? 24 : 20),
                ),
                Text(
                  '$score',
                  style: AppTextStyles.caption(
                    color: selected ? color : AppColors.grey400,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

// ── Dialog de succès ────────────────────────────────────────
class _SuccessDialog extends StatelessWidget {
  final bool isMorning;
  const _SuccessDialog({required this.isMorning});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusXL),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacing32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('✅', style: TextStyle(fontSize: 56)),
            const SizedBox(height: AppConstants.spacing16),
            Text(
              AppStrings.checkinDone,
              style: AppTextStyles.headingMedium(),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.spacing8),
            Text(
              isMorning
                  ? 'Belle journée en perspective 🌅'
                  : 'Bonne soirée, tu le mérites 🌙',
              style: AppTextStyles.bodyMedium(color: AppColors.grey400),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _Question {
  final String label;
  final IconData icon;
  final Color color;
  const _Question(this.label, this.icon, this.color);
}
