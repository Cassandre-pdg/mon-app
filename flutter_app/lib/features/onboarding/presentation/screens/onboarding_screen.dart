import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/constants/app_constants.dart';
import '../../../../shared/navigation/app_router.dart';

// Clé SharedPrefs pour savoir si l'onboarding a été vu
const String _kOnboardingDone = 'onboarding_done';

// Données des 4 écrans d'onboarding
const _pages = [
  _OnboardingPage(
    emoji: '🚀',
    title: 'Bienvenue dans Kolyb',
    subtitle:
        'Ton compagnon de route.\nTon élan, au quotidien — à ton rythme, jamais seul.',
    color: AppColors.primary,
  ),
  _OnboardingPage(
    emoji: '✅',
    title: 'Avance chaque jour',
    subtitle:
        'Un check-in matin et soir pour rester connecté à ton énergie. 3 priorités pour avancer sans te perdre.',
    color: Color(0xFF5B5FFF),
  ),
  _OnboardingPage(
    emoji: '👥',
    title: 'Tu n\'es pas seul',
    subtitle:
        'Rejoins la tribu des indépendants. Partage, encourage, progresse ensemble — à ton image.',
    color: AppColors.secondary,
  ),
  _OnboardingPage(
    emoji: '🏆',
    title: 'Célèbre tes victoires',
    subtitle:
        'Streaks, badges, niveaux... Chaque jour compte. Chaque progrès mérite d\'être célébré.',
    color: AppColors.accent,
  ),
];

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    // Marquer l'onboarding comme terminé
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kOnboardingDone, true);
    if (mounted) context.go(AppRoutes.home);
  }

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: AppConstants.animNormal,
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentPage == _pages.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Bouton passer
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.spacing16),
                child: TextButton(
                  onPressed: _finish,
                  child: Text(
                    'Passer',
                    style: AppTextStyles.bodyMedium(color: AppColors.grey400),
                  ),
                ),
              ),
            ),

            // Pages
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _pages.length,
                itemBuilder: (context, index) =>
                    _OnboardingPageWidget(page: _pages[index]),
              ),
            ),

            // Indicateurs + bouton
            Padding(
              padding: const EdgeInsets.all(AppConstants.spacing24),
              child: Column(
                children: [
                  // Points indicateurs
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (i) => AnimatedContainer(
                        duration: AppConstants.animFast,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: i == _currentPage ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: i == _currentPage
                              ? AppColors.primary
                              : AppColors.grey200,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacing24),

                  // Bouton suivant / commencer
                  ElevatedButton(
                    onPressed: _next,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _pages[_currentPage].color,
                    ),
                    child: Text(
                      isLastPage ? 'C\'est parti 🚀' : 'Suivant',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget d'une page d'onboarding
class _OnboardingPageWidget extends StatelessWidget {
  const _OnboardingPageWidget({required this.page});
  final _OnboardingPage page;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacing32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration emoji
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: page.color.withValues(alpha:0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                page.emoji,
                style: const TextStyle(fontSize: 64),
              ),
            ),
          ),
          const SizedBox(height: AppConstants.spacing32),

          // Titre
          Text(
            page.title,
            style: AppTextStyles.headingLarge(
              color: isDark ? AppColors.textDark : AppColors.textLight,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.spacing16),

          // Sous-titre
          Text(
            page.subtitle,
            style: AppTextStyles.bodyLarge(color: AppColors.grey400),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// Modèle de données pour une page
class _OnboardingPage {
  final String emoji;
  final String title;
  final String subtitle;
  final Color color;

  const _OnboardingPage({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.color,
  });
}
