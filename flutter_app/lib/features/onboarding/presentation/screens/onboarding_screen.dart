import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/navigation/app_router.dart';

const String _kOnboardingDone = 'onboarding_done';

// Config des 4 pages — aurora unique par page
const _pages = [
  _OnboardingPage(
    icon: Icons.rocket_launch_rounded,
    title: 'Bienvenue dans Kolyb',
    subtitle:
        'Pose tes objectifs à court, moyen et long terme.\nCrée tes projets. Chaque jour, 3 priorités claires pour avancer vraiment.',
    orb1: AppColors.auroraViolet,
    orb2: AppColors.auroraPink,
    orb3: AppColors.auroraTeal,
    accentColor: AppColors.primaryLight,
  ),
  _OnboardingPage(
    icon: Icons.bolt_rounded,
    title: 'Exécute, sans te disperser',
    subtitle:
        'Timer Flow (90 min) ou Pomodoro, ambiance sonore incluse.\nCapture rapide pour noter à la volée.\nFlash : toutes tes petites tâches en un seul bloc, plié d\'un coup.',
    orb1: Color(0x7A5B5FFF),
    orb2: AppColors.auroraViolet,
    orb3: Color(0x4D8B7FE8),
    accentColor: Color(0xFF8B7FE8),
  ),
  _OnboardingPage(
    icon: Icons.people_rounded,
    title: 'Le Salon, ton espace commun',
    subtitle:
        'Pose tes questions, partage tes avancées.\nRejoins le défi du mois avec la communauté.\nIci, tu n\'avances plus seul.',
    orb1: AppColors.auroraCorail,
    orb2: AppColors.auroraAmber,
    orb3: AppColors.auroraPink,
    accentColor: AppColors.secondary,
  ),
  _OnboardingPage(
    icon: Icons.favorite_rounded,
    title: 'Prends soin de toi',
    subtitle:
        'Check-in matin et soir pour suivre ton état.\nMéditation, respiration guidée.\nChaque habitude tenue : des points, un niveau, des badges.',
    orb1: AppColors.auroraTeal,
    orb2: AppColors.auroraAmber,
    orb3: AppColors.auroraViolet,
    accentColor: AppColors.accent,
  ),
];

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with TickerProviderStateMixin {
  final _pageController = PageController();
  int _currentPage = 0;

  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _initFade();
  }

  void _initFade() {
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    )..forward();
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kOnboardingDone, true);
    if (mounted) context.go(AppRoutes.home);
  }

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _finish();
    }
  }

  void _onPageChanged(int index) {
    setState(() => _currentPage = index);
    _fadeCtrl
      ..reset()
      ..forward();
  }

  @override
  Widget build(BuildContext context) {
    final page = _pages[_currentPage];
    final isLastPage = _currentPage == _pages.length - 1;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Stack(
        children: [
          // Aurora animée — change par page avec fondu
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 700),
            child: _AuroraLayer(
              key: ValueKey(_currentPage),
              orb1: page.orb1,
              orb2: page.orb2,
              orb3: page.orb3,
            ),
          ),

          // Contenu
          SafeArea(
            child: Column(
              children: [
                // Barre de progression + passer
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 18, 20, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: List.generate(_pages.length, (i) {
                            return Expanded(
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: EdgeInsets.only(
                                  right: i < _pages.length - 1 ? 5 : 0,
                                ),
                                height: 3,
                                decoration: BoxDecoration(
                                  color:
                                      i <= _currentPage
                                          ? page.accentColor
                                          : Colors.white.withValues(
                                            alpha: 0.18,
                                          ),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                      const SizedBox(width: 14),
                      GestureDetector(
                        onTap: _finish,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.15),
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            'Passer',
                            style: AppTextStyles.caption(
                              color: Colors.white.withValues(alpha: 0.55),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // PageView
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: _onPageChanged,
                    itemCount: _pages.length,
                    itemBuilder:
                        (ctx, i) => _OnboardingPageWidget(
                          page: _pages[i],
                          isActive: i == _currentPage,
                          fadeAnim: _fadeAnim,
                        ),
                  ),
                ),

                // CTA
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 44),
                  child: _OnboardingCTA(
                    label: isLastPage ? 'C\'est parti' : 'Suivant',
                    accentColor: page.accentColor,
                    onTap: _next,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Aurora layer animée ───────────────────────────────────────
class _AuroraLayer extends StatefulWidget {
  const _AuroraLayer({
    super.key,
    required this.orb1,
    required this.orb2,
    required this.orb3,
  });

  final Color orb1;
  final Color orb2;
  final Color orb3;

  @override
  State<_AuroraLayer> createState() => _AuroraLayerState();
}

class _AuroraLayerState extends State<_AuroraLayer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    )..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: AnimatedBuilder(
        animation: _anim,
        builder:
            (_, __) => CustomPaint(
              painter: _AuroraPainter(
                t: _anim.value,
                orb1: widget.orb1,
                orb2: widget.orb2,
                orb3: widget.orb3,
              ),
            ),
      ),
    );
  }
}

class _AuroraPainter extends CustomPainter {
  const _AuroraPainter({
    required this.t,
    required this.orb1,
    required this.orb2,
    required this.orb3,
  });
  final double t;
  final Color orb1, orb2, orb3;

  void _orb(Canvas c, Offset center, double r, Color color) {
    c.drawCircle(
      center,
      r,
      Paint()
        ..color = color
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 90),
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = AppColors.backgroundDark,
    );
    _orb(
      canvas,
      Offset(size.width * 0.15 + 40 * t, size.height * 0.18 + 25 * t),
      size.width * 0.55,
      orb1,
    );
    _orb(
      canvas,
      Offset(size.width * 0.85 - 30 * t, size.height * 0.75 + 20 * t),
      size.width * 0.50,
      orb2,
    );
    _orb(
      canvas,
      Offset(size.width * 0.3 + 18 * t, size.height * 0.85 - 18 * t),
      size.width * 0.36,
      orb3,
    );
  }

  @override
  bool shouldRepaint(_AuroraPainter old) => old.t != t;
}

// ── Widget page ───────────────────────────────────────────────
class _OnboardingPageWidget extends StatelessWidget {
  const _OnboardingPageWidget({
    required this.page,
    required this.isActive,
    required this.fadeAnim,
  });

  final _OnboardingPage page;
  final bool isActive;
  final Animation<double> fadeAnim;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: FadeTransition(
        opacity: isActive ? fadeAnim : const AlwaysStoppedAnimation(1.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icône glassmorphism
            ClipRRect(
              borderRadius: BorderRadius.circular(36),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    color: page.accentColor.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(36),
                    border: Border.all(
                      color: page.accentColor.withValues(alpha: 0.35),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: page.accentColor.withValues(alpha: 0.28),
                        blurRadius: 44,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(page.icon,
                        color: page.accentColor, size: 60),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 44),

            // Titre gradient
            ShaderMask(
              shaderCallback:
                  (bounds) => LinearGradient(
                    colors: [Colors.white, page.accentColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds),
              blendMode: BlendMode.srcIn,
              child: Text(
                page.title,
                style: AppTextStyles.displayLarge(),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 22),

            Text(
              page.subtitle,
              style: AppTextStyles.bodyLarge(
                color: Colors.white.withValues(alpha: 0.58),
              ).copyWith(height: 1.65),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── CTA bouton spring ─────────────────────────────────────────
class _OnboardingCTA extends StatefulWidget {
  const _OnboardingCTA({
    required this.label,
    required this.accentColor,
    required this.onTap,
  });
  final String label;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  State<_OnboardingCTA> createState() => _OnboardingCTAState();
}

class _OnboardingCTAState extends State<_OnboardingCTA>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder:
            (_, child) => Transform.scale(scale: _scale.value, child: child),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          width: double.infinity,
          height: 58,
          decoration: BoxDecoration(
            color: widget.accentColor,
            borderRadius: BorderRadius.circular(29),
            boxShadow: [
              BoxShadow(
                color: widget.accentColor.withValues(alpha: 0.42),
                blurRadius: 26,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: Text(
              widget.label,
              style: AppTextStyles.headingSmall(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Modèle ────────────────────────────────────────────────────
class _OnboardingPage {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color orb1;
  final Color orb2;
  final Color orb3;
  final Color accentColor;

  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.orb1,
    required this.orb2,
    required this.orb3,
    required this.accentColor,
  });
}
