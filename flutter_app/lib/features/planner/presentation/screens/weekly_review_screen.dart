import 'package:flutter/material.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/constants/app_constants.dart';

// ── Revue hebdomadaire guidée — 4 étapes ─────────────────────
class WeeklyReviewScreen extends StatefulWidget {
  const WeeklyReviewScreen({super.key});

  @override
  State<WeeklyReviewScreen> createState() => _WeeklyReviewScreenState();
}

class _WeeklyReviewScreenState extends State<WeeklyReviewScreen>
    with TickerProviderStateMixin {
  int _step = 0;

  // Victoires
  final List<TextEditingController> _winsCtrl = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];
  // Difficultés
  final _difficultiesCtrl = TextEditingController();
  // Objectifs J+7
  final List<TextEditingController> _goalsCtrl = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];

  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: AppConstants.animNormal,
    )..forward();
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    for (final c in _winsCtrl) {
      c.dispose();
    }
    _difficultiesCtrl.dispose();
    for (final c in _goalsCtrl) {
      c.dispose();
    }
    super.dispose();
  }

  void _next() async {
    await _fadeCtrl.reverse();
    setState(() => _step++);
    _fadeCtrl.forward();
  }

  void _prev() async {
    if (_step == 0) return;
    await _fadeCtrl.reverse();
    setState(() => _step--);
    _fadeCtrl.forward();
  }

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
          onPressed: _step == 0 ? () => Navigator.pop(context) : _prev,
        ),
        title: Text(
          'Revue hebdomadaire',
          style: AppTextStyles.headingMedium(
            color: isDark ? AppColors.textDark : AppColors.textLight,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── Indicateur de progression ──────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                children: List.generate(4, (i) {
                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      height: 4,
                      decoration: BoxDecoration(
                        color:
                            i <= _step
                                ? AppColors.primary
                                : AppColors.grey200.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_step + 1} / 4',
                    style: AppTextStyles.caption(color: AppColors.grey400),
                  ),
                  Text(
                    _stepLabel(_step),
                    style: AppTextStyles.caption(color: AppColors.primaryLight),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppConstants.spacing24),

            // ── Contenu de l'étape ─────────────────────────────
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: _buildStep(context, isDark),
              ),
            ),

            // ── Bouton suivant ─────────────────────────────────
            if (_step < 3)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: ElevatedButton(
                  onPressed: _next,
                  child: Text(_step == 2 ? 'Voir le bilan' : 'Suivant'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _stepLabel(int step) {
    switch (step) {
      case 0:
        return 'Victoires';
      case 1:
        return 'Difficultés';
      case 2:
        return 'Objectifs';
      case 3:
        return 'Bilan';
      default:
        return '';
    }
  }

  Widget _buildStep(BuildContext context, bool isDark) {
    switch (_step) {
      case 0:
        return _StepWins(controllers: _winsCtrl, isDark: isDark);
      case 1:
        return _StepDifficulties(controller: _difficultiesCtrl, isDark: isDark);
      case 2:
        return _StepGoals(controllers: _goalsCtrl, isDark: isDark);
      case 3:
        return _StepBilan(
          wins:
              _winsCtrl
                  .map((c) => c.text.trim())
                  .where((t) => t.isNotEmpty)
                  .toList(),
          difficulties: _difficultiesCtrl.text.trim(),
          goals:
              _goalsCtrl
                  .map((c) => c.text.trim())
                  .where((t) => t.isNotEmpty)
                  .toList(),
          isDark: isDark,
          onClose: () => Navigator.pop(context),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

// ── Étape 1 : Victoires ───────────────────────────────────────
class _StepWins extends StatelessWidget {
  final List<TextEditingController> controllers;
  final bool isDark;

  const _StepWins({required this.controllers, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return _StepLayout(
      icon: Icons.emoji_events_rounded,
      title: 'Tes victoires de la semaine',
      subtitle:
          'Qu\'est-ce qui t\'a rendu fier(e) cette semaine ?\nMême les petites avancées comptent.',
      isDark: isDark,
      child: Column(
        children: List.generate(
          3,
          (i) => Padding(
            padding: const EdgeInsets.only(bottom: AppConstants.spacing12),
            child: TextField(
              controller: controllers[i],
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText:
                    'Victoire ${i + 1}${i == 0 ? ' (obligatoire)' : ' (optionnelle)'}',
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Étape 2 : Difficultés ─────────────────────────────────────
class _StepDifficulties extends StatelessWidget {
  final TextEditingController controller;
  final bool isDark;

  const _StepDifficulties({required this.controller, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return _StepLayout(
      icon: Icons.waves_rounded,
      title: 'Ce qui a été difficile',
      subtitle: 'Pas pour te juger, pour mieux comprendre et avancer.',
      isDark: isDark,
      child: TextField(
        controller: controller,
        maxLines: 4,
        textCapitalization: TextCapitalization.sentences,
        decoration: const InputDecoration(
          hintText:
              'Qu\'est-ce qui a été compliqué ? Qu\'est-ce qui t\'a freiné ?',
          alignLabelWithHint: true,
        ),
      ),
    );
  }
}

// ── Étape 3 : Objectifs J+7 ───────────────────────────────────
class _StepGoals extends StatelessWidget {
  final List<TextEditingController> controllers;
  final bool isDark;

  const _StepGoals({required this.controllers, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return _StepLayout(
      icon: Icons.my_location_rounded,
      title: 'Tes objectifs pour la semaine prochaine',
      subtitle:
          'Qu\'est-ce que tu veux vraiment accomplir dans les 7 prochains jours ?',
      isDark: isDark,
      child: Column(
        children: List.generate(
          3,
          (i) => Padding(
            padding: const EdgeInsets.only(bottom: AppConstants.spacing12),
            child: TextField(
              controller: controllers[i],
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText:
                    'Objectif ${i + 1}${i == 0 ? ' (obligatoire)' : ' (optionnel)'}',
                prefixText: '→  ',
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Étape 4 : Bilan ───────────────────────────────────────────
class _StepBilan extends StatelessWidget {
  final List<String> wins;
  final String difficulties;
  final List<String> goals;
  final bool isDark;
  final VoidCallback onClose;

  const _StepBilan({
    required this.wins,
    required this.difficulties,
    required this.goals,
    required this.isDark,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        children: [
          // Illustration + message
          const Icon(Icons.star_rounded, size: 72, color: AppColors.warning),
          const SizedBox(height: AppConstants.spacing16),
          Text(
            'Belle revue !',
            style: AppTextStyles.headingLarge(),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.spacing8),
          Text(
            'Prendre du recul, c\'est déjà avancer. Tu connais ta semaine mieux que personne.',
            style: AppTextStyles.bodyMedium(color: AppColors.grey400),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.spacing32),

          // Victoires
          if (wins.isNotEmpty) ...[
            _BilanSection(
              title: 'Tes victoires',
              icon: Icons.emoji_events_rounded,
              color: AppColors.warning,
              items: wins,
              isDark: isDark,
            ),
            const SizedBox(height: AppConstants.spacing16),
          ],

          // Objectifs
          if (goals.isNotEmpty) ...[
            _BilanSection(
              title: 'Tes objectifs J+7',
              icon: Icons.my_location_rounded,
              color: AppColors.primary,
              items: goals,
              isDark: isDark,
            ),
            const SizedBox(height: AppConstants.spacing16),
          ],

          // Difficultés
          if (difficulties.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppConstants.spacing16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                border: Border.all(
                  color: AppColors.accent.withValues(alpha: 0.3),
                ),
                borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.waves_rounded, color: AppColors.accent, size: 14),
                      const SizedBox(width: 6),
                      Text('Ce qui a été difficile',
                          style: AppTextStyles.labelMedium(color: AppColors.accent)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    difficulties,
                    style: AppTextStyles.bodyMedium(
                      color: isDark ? AppColors.textDark : AppColors.textLight,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppConstants.spacing24),
          ],

          ElevatedButton(
            onPressed: onClose,
            child: const Text('Fermer la revue'),
          ),
        ],
      ),
    );
  }
}

class _BilanSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<String> items;
  final bool isDark;

  const _BilanSection({
    required this.title,
    required this.icon,
    required this.color,
    required this.items,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.spacing16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        border: Border.all(color: color.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 14),
              const SizedBox(width: 6),
              Text(title, style: AppTextStyles.labelMedium(color: color)),
            ],
          ),
          const SizedBox(height: 8),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• ', style: AppTextStyles.bodyMedium(color: color)),
                  Expanded(
                    child: Text(
                      item,
                      style: AppTextStyles.bodyMedium(
                        color:
                            isDark ? AppColors.textDark : AppColors.textLight,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Layout commun pour les étapes ─────────────────────────────
class _StepLayout extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget child;
  final bool isDark;

  const _StepLayout({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 48, color: AppColors.primaryLight),
          const SizedBox(height: AppConstants.spacing16),
          Text(
            title,
            style: AppTextStyles.headingLarge(
              color: isDark ? AppColors.textDark : AppColors.textLight,
            ),
          ),
          const SizedBox(height: AppConstants.spacing8),
          Text(
            subtitle,
            style: AppTextStyles.bodyMedium(color: AppColors.grey400),
          ),
          const SizedBox(height: AppConstants.spacing32),
          child,
        ],
      ),
    );
  }
}
