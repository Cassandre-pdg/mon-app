import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/constants/app_constants.dart';
import '../../../../shared/constants/app_strings.dart';
import '../providers/checkin_provider.dart';

// ── Écran principal ───────────────────────────────────────────
class CheckinScreen extends ConsumerStatefulWidget {
  final String type; // 'morning' | 'evening'
  const CheckinScreen({super.key, required this.type});

  @override
  ConsumerState<CheckinScreen> createState() => _CheckinScreenState();
}

class _CheckinScreenState extends ConsumerState<CheckinScreen> {
  int _moodScore   = 3;
  int _energyScore = 3;
  int _focusScore  = 3;
  final _notesCtrl = TextEditingController();

  // Étapes : 0, 1, 2 = questions | 3 = célébration
  int _currentStep = 0;

  bool get isMorning => widget.type == 'morning';

  // ── Options matin ─────────────────────────────────────────────
  static const _moodMorningEmojis  = ['😴', '😕', '😐', '🙂', '😄'];
  static const _moodMorningLabels  = ['Pas terrible', 'Pas top', 'Bof', 'Plutôt bien', 'Au top !'];
  static const _moodEveningEmojis  = ['😩', '😔', '😐', '😌', '🌟'];
  static const _moodEveningLabels  = ['Épuisé(e)', 'Difficile', 'Correct', 'Bien', 'Excellent'];
  static const _energyEmojis       = ['🪫', '😪', '⚡', '🔋', '💥'];
  static const _energyLabels       = ['À plat', 'Fatigué(e)', 'Correct', 'Chargé(e)', 'Full énergie'];
  static const _focusMorningEmojis = ['😵', '😶', '🎯', '🧠', '🚀'];
  static const _focusMorningLabels = ['Dispersé(e)', 'Distrait(e)', 'Focus', 'Concentré(e)', 'Dans la zone'];
  static const _satisEveningEmojis = ['😞', '😕', '😐', '😊', '🏆'];
  static const _satisEveningLabels = ['Décevant', 'Mitigé', 'Correct', 'Bien', 'Fière de moi'];

  List<_QuestionData> get _questions => isMorning
      ? [
          _QuestionData(
            label: AppStrings.morningQ1,
            icon: '🌅',
            color: AppColors.chartAmber,
            emojis: _moodMorningEmojis,
            labels: _moodMorningLabels,
          ),
          _QuestionData(
            label: AppStrings.morningQ2,
            icon: '⚡',
            color: AppColors.primary,
            emojis: _energyEmojis,
            labels: _energyLabels,
          ),
          _QuestionData(
            label: AppStrings.morningQ3,
            icon: '🎯',
            color: AppColors.accent,
            emojis: _focusMorningEmojis,
            labels: _focusMorningLabels,
          ),
        ]
      : [
          _QuestionData(
            label: AppStrings.eveningQ1,
            icon: '🌙',
            color: AppColors.secondary,
            emojis: _moodEveningEmojis,
            labels: _moodEveningLabels,
          ),
          _QuestionData(
            label: AppStrings.eveningQ2,
            icon: '⚡',
            color: AppColors.warning,
            emojis: _energyEmojis,
            labels: _energyLabels,
          ),
          _QuestionData(
            label: AppStrings.eveningQ3,
            icon: '🌟',
            color: AppColors.accent,
            emojis: _satisEveningEmojis,
            labels: _satisEveningLabels,
          ),
        ];

  int _getScore(int step) {
    switch (step) {
      case 0: return _moodScore;
      case 1: return _energyScore;
      case 2: return _focusScore;
      default: return 3;
    }
  }

  void _setScore(int step, int val) => setState(() {
    switch (step) {
      case 0: _moodScore   = val; break;
      case 1: _energyScore = val; break;
      case 2: _focusScore  = val; break;
    }
  });

  void _next() {
    if (_currentStep < 2) {
      setState(() => _currentStep++);
    } else {
      _submit();
    }
  }

  Future<void> _submit() async {
    await ref.read(checkinNotifierProvider.notifier).submit(
      type: widget.type,
      moodScore: _moodScore,
      energyScore: _energyScore,
      focusScore: _focusScore,
      notes: _notesCtrl.text.isNotEmpty ? _notesCtrl.text : null,
    );
    if (!mounted) return;
    setState(() => _currentStep = 3);
    // Retour automatique au dashboard après 2,5 secondes
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) context.pop();
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

    // Fond légèrement plus sombre pour le soir
    final bg = isMorning
        ? (isDark ? AppColors.backgroundDark : AppColors.backgroundLight)
        : (isDark ? const Color(0xFF08091A) : AppColors.backgroundLight);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) => SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.08, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: FadeTransition(opacity: animation, child: child),
          ),
          child: _currentStep == 3
              ? _CelebrationStep(
                  key: const ValueKey(3),
                  isMorning: isMorning,
                  isDark: isDark,
                )
              : _QuestionStep(
                  key: ValueKey(_currentStep),
                  step: _currentStep,
                  question: _questions[_currentStep],
                  score: _getScore(_currentStep),
                  onScore: (v) => _setScore(_currentStep, v),
                  isLast: _currentStep == 2,
                  onNext: _next,
                  notesCtrl: _currentStep == 2 ? _notesCtrl : null,
                  isDark: isDark,
                  isMorning: isMorning,
                  onClose: () => context.pop(),
                ),
        ),
      ),
    );
  }
}

// ── Modèle d'une question ─────────────────────────────────────
class _QuestionData {
  final String label;
  final String icon;
  final Color color;
  final List<String> emojis;
  final List<String> labels;

  const _QuestionData({
    required this.label,
    required this.icon,
    required this.color,
    required this.emojis,
    required this.labels,
  });
}

// ── Étape question (plein écran) ──────────────────────────────
class _QuestionStep extends StatelessWidget {
  final int step;
  final _QuestionData question;
  final int score;
  final ValueChanged<int> onScore;
  final bool isLast;
  final VoidCallback onNext;
  final TextEditingController? notesCtrl;
  final bool isDark;
  final bool isMorning;
  final VoidCallback onClose;

  const _QuestionStep({
    super.key,
    required this.step,
    required this.question,
    required this.score,
    required this.onScore,
    required this.isLast,
    required this.onNext,
    this.notesCtrl,
    required this.isDark,
    required this.isMorning,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Header : fermer + barre de progression ───────────
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
          child: Row(
            children: [
              IconButton(
                icon: Icon(
                  Icons.close_rounded,
                  color: isDark
                      ? AppColors.textDarkMuted
                      : AppColors.grey400,
                ),
                onPressed: onClose,
              ),
              Expanded(
                child: _ProgressBar(
                  current: step,
                  total: 3,
                  color: question.color,
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
        ),

        // ── Contenu scrollable ────────────────────────────────
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icône grande
                Text(
                  question.icon,
                  style: const TextStyle(fontSize: 52),
                ),
                const SizedBox(height: 18),

                // Question
                Text(
                  question.label,
                  style: AppTextStyles.headingLarge(
                    color: isDark ? AppColors.textDark : AppColors.textLight,
                  ).copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.4,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 32),

                // Pills de réponse verticales
                ...List.generate(5, (i) {
                  final scoreVal  = i + 1;
                  final isSelected = scoreVal == score;

                  return GestureDetector(
                    onTap: () => onScore(scoreVal),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOut,
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 15,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? question.color.withValues(alpha: 0.13)
                            : AppColors.surface(context),
                        border: Border.all(
                          color: isSelected
                              ? question.color
                              : (isDark
                                  ? const Color(0x1AFFFFFF)
                                  : const Color(0x18000000)),
                          width: isSelected ? 1.5 : 1,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: question.color
                                      .withValues(alpha: 0.12),
                                  blurRadius: 12,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        children: [
                          Text(
                            question.emojis[i],
                            style: TextStyle(
                              fontSize: isSelected ? 22 : 20,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              question.labels[i],
                              style: AppTextStyles.bodyMedium(
                                color: isSelected
                                    ? question.color
                                    : AppColors.txt(context),
                              ).copyWith(
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                          ),
                          AnimatedOpacity(
                            opacity: isSelected ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 150),
                            child: Icon(
                              Icons.check_rounded,
                              color: question.color,
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),

                // Note libre — dernière question seulement
                if (isLast && notesCtrl != null) ...[
                  const SizedBox(height: 20),
                  Text(
                    'Une note ? (optionnel)',
                    style: AppTextStyles.labelMedium(
                      color: AppColors.txt(context),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: notesCtrl,
                    maxLines: 3,
                    maxLength: 280,
                    decoration: const InputDecoration(
                      hintText: 'Ce qui me passe par la tête...',
                      counterText: '',
                    ),
                  ),
                ],

                const SizedBox(height: 28),
              ],
            ),
          ),
        ),

        // ── Bouton ancré en bas ───────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
          child: ElevatedButton(
            onPressed: onNext,
            style: ElevatedButton.styleFrom(
              backgroundColor: question.color,
            ),
            child: Text(
              isLast ? 'Valider mon check-in ✅' : 'Suivant →',
            ),
          ),
        ),
      ],
    );
  }
}

// ── Barre de progression fine ─────────────────────────────────
class _ProgressBar extends StatelessWidget {
  final int current;
  final int total;
  final Color color;

  const _ProgressBar({
    required this.current,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (i) {
        return Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            height: 3,
            margin: EdgeInsets.only(right: i < total - 1 ? 4 : 0),
            decoration: BoxDecoration(
              color: i <= current ? color : AppColors.grey200,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}

// ── Écran de célébration (remplace le dialog) ─────────────────
class _CelebrationStep extends StatefulWidget {
  final bool isMorning;
  final bool isDark;

  const _CelebrationStep({
    super.key,
    required this.isMorning,
    required this.isDark,
  });

  @override
  State<_CelebrationStep> createState() => _CelebrationStepState();
}

class _CelebrationStepState extends State<_CelebrationStep>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _fade  = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textColor = widget.isDark
        ? AppColors.textDark
        : AppColors.textLight;

    return FadeTransition(
      opacity: _fade,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacing32),
          child: ScaleTransition(
            scale: _scale,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Emoji principal
                Text(
                  widget.isMorning ? '☀️' : '🌙',
                  style: const TextStyle(fontSize: 72),
                ),
                const SizedBox(height: AppConstants.spacing24),

                // Titre
                Text(
                  AppStrings.checkinDone,
                  style: AppTextStyles.headingLarge(color: textColor)
                      .copyWith(fontSize: 22, fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppConstants.spacing8),

                // Sous-titre contextuel
                Text(
                  widget.isMorning
                      ? 'Belle journée en perspective ☀️'
                      : 'Bonne soirée, tu le mérites 🌙',
                  style: AppTextStyles.bodyMedium(color: AppColors.grey400),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppConstants.spacing16),

                // Badge points
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Text(
                    '+5 pts 🏅',
                    style: AppTextStyles.labelMedium(
                      color: AppColors.primary,
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
