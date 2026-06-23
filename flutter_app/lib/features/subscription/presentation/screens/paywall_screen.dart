import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/constants/app_constants.dart';
import '../providers/subscription_provider.dart';

// ─────────────────────────────────────────────────────────────
// Données, features par plan
// ─────────────────────────────────────────────────────────────

class _Feature {
  final String emoji;
  final String label;
  final String? sublabel;
  const _Feature(this.emoji, this.label, [this.sublabel]);
}

const _freeFeatures = [
  _Feature('🌅', 'Check-in matin et soir', 'Humeur, énergie, focus du jour'),
  _Feature('⏱', 'Pomodoro et Flow', 'Timers pour rester dans le mouvement'),
  _Feature('🏠', 'Tableau de bord 7 jours', 'Suivi de ta semaine en cours'),
  _Feature('🧘', '2 méditations guidées', 'Pour commencer et souffler'),
  _Feature('👥', 'Le Salon (lecture)', 'Inspire-toi de la communauté'),
  _Feature('📁', '1 projet actif', 'Pour poser les bases de ton activité'),
];

const _proFeatures = [
  _Feature('📁', 'Projets illimités', 'Autant de projets que tu as d\'ambitions'),
  _Feature('📈', 'Historique complet illimité', 'Tes données, pour toujours'),
  _Feature('🎯', 'Graphiques et analytics', 'Vois vraiment ta progression'),
  _Feature('🌟', 'Radar bien-être hebdo', 'Vue 360° productivité et équilibre'),
  _Feature('🌙', 'Routines personnalisées', 'Matin et soir adaptées à toi'),
  _Feature('🧘', 'Méditations complètes', 'Toute la bibliothèque débloquée'),
  _Feature('💬', 'Communauté active', 'Poster, interagir, progresser ensemble'),
  _Feature('📄', 'Export PDF mensuel', 'Ton bilan entre tes mains'),
  _Feature('🔔', 'Notifications intelligentes', 'Rappels adaptés à ton rythme'),
];

// ─────────────────────────────────────────────────────────────
// Écran principal
// ─────────────────────────────────────────────────────────────

class PaywallScreen extends ConsumerWidget {
  /// true → bouton fermer visible (accès depuis Profil).
  final bool isDismissible;

  const PaywallScreen({super.key, this.isDismissible = true});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offeringAsync = ref.watch(activeOfferingProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: offeringAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (_, __) => _ErrorBody(
          onRetry: () => ref.invalidate(activeOfferingProvider),
        ),
        data: (offering) => offering == null
            ? _ErrorBody(onRetry: () => ref.invalidate(activeOfferingProvider))
            : _PaywallContent(
                offering: offering,
                isDismissible: isDismissible,
                isDark: isDark,
              ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Corps principal, partagé entre V1 (sans offering) et V2
// ─────────────────────────────────────────────────────────────

class _PaywallContent extends ConsumerStatefulWidget {
  final Offering offering;
  final bool isDismissible;
  final bool isDark;

  const _PaywallContent({
    required this.offering,
    required this.isDismissible,
    required this.isDark,
  });

  @override
  ConsumerState<_PaywallContent> createState() => _PaywallContentState();
}

class _PaywallContentState extends ConsumerState<_PaywallContent>
    with SingleTickerProviderStateMixin {
  PackageType _selected = PackageType.annual;
  bool _showAllProFeatures = false;
  late AnimationController _glowController;

  Package? get _monthlyPackage => widget.offering.availablePackages
      .where((p) => p.packageType == PackageType.monthly)
      .firstOrNull;

  Package? get _annualPackage => widget.offering.availablePackages
      .where((p) => p.packageType == PackageType.annual)
      .firstOrNull;

  Package? get _activePackage =>
      _selected == PackageType.annual ? _annualPackage : _monthlyPackage;

  bool get _hasOffering => true;

  String get _displayPrice {
    if (_selected == PackageType.annual) {
      return _annualPackage?.storeProduct.priceString ?? AppConstants.priceAnnual;
    }
    return _monthlyPackage?.storeProduct.priceString ?? AppConstants.priceMonthly;
  }

  String get _displayPriceMonthly {
    if (_selected == PackageType.annual) {
      return _annualPackage != null
          ? '${(_annualPackage!.storeProduct.price / 12).toStringAsFixed(2)} € / mois'
          : AppConstants.priceAnnualMonthly;
    }
    return AppConstants.priceMonthly;
  }

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  Future<void> _purchase() async {
    final pkg = _activePackage;
    if (pkg == null) return;
    await ref.read(subscriptionStatusProvider.notifier).purchase(pkg);
  }

  Future<void> _restore() async {
    await ref.read(subscriptionStatusProvider.notifier).restorePurchases();
  }

  @override
  Widget build(BuildContext context) {
    final isPro = ref.watch(isProProvider);
    final subState = ref.watch(subscriptionStatusProvider);
    final isLoading = subState is AsyncLoading;
    final hasError = subState is AsyncError;

    if (isPro) return _SuccessBody(isDark: widget.isDark);

    return Column(
      children: [
        // ── Corps scrollable ──────────────────────────────────
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Section hero avec aurora (inclut le bouton fermer) ──
                _HeroSection(
                  glowController: _glowController,
                  isDark: widget.isDark,
                  isDismissible: widget.isDismissible,
                  onClose: () => context.pop(),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: AppConstants.spacing24),

                      // ── Toggle mensuel / annuel ──────────────
                      _BillingToggle(
                        selected: _selected,
                        isDark: widget.isDark,
                        onSelect: (type) => setState(() => _selected = type),
                      ),

                      const SizedBox(height: AppConstants.spacing16),

                      // ── Carte Pro (mise en avant) ─────────────
                      _ProCard(
                        isDark: widget.isDark,
                        isAnnual: _selected == PackageType.annual,
                        price: _displayPrice,
                        priceMonthly: _displayPriceMonthly,
                        isComingSoon: !_hasOffering,
                      ),

                      const SizedBox(height: AppConstants.spacing12),

                      // ── Features Pro complètes ────────────────
                      _ProFeaturesCard(
                        isDark: widget.isDark,
                        showAll: _showAllProFeatures,
                        onToggle: () => setState(
                          () => _showAllProFeatures = !_showAllProFeatures,
                        ),
                      ),

                      const SizedBox(height: AppConstants.spacing16),

                      // ── Carte Gratuit ────────────────────────
                      _FreeCard(isDark: widget.isDark),

                      const SizedBox(height: AppConstants.spacing24),

                      // ── Erreur achat ─────────────────────────
                      if (hasError) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.1),
                            borderRadius:
                                BorderRadius.circular(AppConstants.radiusMedium),
                          ),
                          child: Text(
                            'Une erreur est survenue. Réessaie dans un instant.',
                            style: AppTextStyles.bodySmall(color: AppColors.error),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: AppConstants.spacing16),
                      ],

                      // ── CTA principal ────────────────────────
                      _MainCta(
                        isLoading: isLoading,
                        isComingSoon: !_hasOffering,
                        isAnnual: _selected == PackageType.annual,
                        onTap: _hasOffering && _activePackage != null && !isLoading
                            ? _purchase
                            : null,
                      ),

                      const SizedBox(height: AppConstants.spacing12),

                      // ── Liens légaux Apple (3.1.2c) — visibles dans le flow d'achat ──
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _LegalLink(
                            label: 'CGU',
                            url: 'https://cassandre-pdg.github.io/kolyb-support/cgu.html',
                            isDark: widget.isDark,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              '·',
                              style: AppTextStyles.caption().copyWith(
                                color: widget.isDark
                                    ? AppColors.textDarkMuted
                                    : AppColors.grey400,
                              ),
                            ),
                          ),
                          _LegalLink(
                            label: 'Politique de confidentialité',
                            url: 'https://cassandre-pdg.github.io/kolyb-support/confidentialite.html',
                            isDark: widget.isDark,
                          ),
                        ],
                      ),

                      const SizedBox(height: AppConstants.spacing8),

                      // ── Continuer en gratuit ─────────────────
                      if (widget.isDismissible)
                        Center(
                          child: TextButton(
                            onPressed: isLoading ? null : () => context.pop(),
                            child: Text(
                              'Continuer en gratuit',
                              style: AppTextStyles.bodySmall().copyWith(
                                color: widget.isDark
                                    ? AppColors.textDarkMuted
                                    : AppColors.grey400,
                              ),
                            ),
                          ),
                        ),

                      const SizedBox(height: AppConstants.spacing16),

                      // ── Restaurer ────────────────────────────
                      Center(
                        child: TextButton(
                          onPressed: isLoading ? null : _restore,
                          child: Text(
                            'Restaurer mes achats',
                            style: AppTextStyles.caption().copyWith(
                              color: AppColors.primaryLight,
                              decoration: TextDecoration.underline,
                              decorationColor: AppColors.primaryLight,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: AppConstants.spacing4),

                      Text(
                        'Renouvellement automatique. Annulation à tout moment depuis les réglages de l\'App Store. Conforme RGPD, données hébergées en Europe.',
                        style: AppTextStyles.caption().copyWith(
                          color: widget.isDark
                              ? AppColors.textDarkMuted
                              : AppColors.grey400,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: AppConstants.spacing32),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Section hero, aurora + headline
// ─────────────────────────────────────────────────────────────

class _HeroSection extends StatelessWidget {
  final AnimationController glowController;
  final bool isDark;
  final bool isDismissible;
  final VoidCallback onClose;

  const _HeroSection({
    required this.glowController,
    required this.isDark,
    required this.isDismissible,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return SizedBox(
      height: 260 + topPadding,
      child: Stack(
        children: [
          // Aurora, couvre toute la zone y compris status bar
          Positioned.fill(
            child: AnimatedBuilder(
              animation: glowController,
              builder: (_, __) => CustomPaint(
                painter: _AuroraPainter(t: glowController.value, isDark: isDark),
              ),
            ),
          ),

          // Bouton fermer en haut à droite (sous la status bar)
          if (isDismissible)
            Positioned(
              top: topPadding + 4,
              right: 8,
              child: IconButton(
                icon: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
                onPressed: onClose,
              ),
            ),

          // Contenu texte centré
          Positioned.fill(
            top: topPadding + 36,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Badge couronne
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.chartAmber, Color(0xFFFFD966)],
                      ),
                      borderRadius: BorderRadius.circular(AppConstants.radiusPill),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.chartAmber.withValues(alpha: 0.4),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('👑', style: TextStyle(fontSize: 13)),
                        const SizedBox(width: 6),
                        Text(
                          'Kolyb Pro',
                          style: AppTextStyles.caption().copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    'Passe à la\nvitesse supérieure.',
                    style: AppTextStyles.displayLarge().copyWith(
                      color: Colors.white,
                      height: 1.15,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 10),

                  Text(
                    'Tout Kolyb, sans limites.\nAvance à ton rythme, pour de vrai.',
                    style: AppTextStyles.bodySmall().copyWith(
                      color: AppColors.primaryPale,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
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

class _AuroraPainter extends CustomPainter {
  final double t;
  final bool isDark;
  const _AuroraPainter({required this.t, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final bg = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    canvas.drawRect(Offset.zero & size, Paint()..color = bg);

    void drawOrb(
      double cx, double cy, double r, Color color, double alpha,
    ) {
      final paint = Paint()
        ..shader = RadialGradient(
          colors: [color.withValues(alpha: alpha), Colors.transparent],
        ).createShader(
          Rect.fromCircle(center: Offset(cx, cy), radius: r),
        );
      canvas.drawCircle(Offset(cx, cy), r, paint);
    }

    final pulse = 0.85 + 0.15 * math.sin(t * math.pi);
    drawOrb(size.width * 0.3, size.height * 0.4, size.width * 0.6 * pulse,
        AppColors.primary, 0.45);
    drawOrb(size.width * 0.75, size.height * 0.3, size.width * 0.5 * pulse,
        AppColors.accent, 0.25);
    drawOrb(size.width * 0.5, size.height * 0.9, size.width * 0.4,
        AppColors.primary, 0.15);
  }

  @override
  bool shouldRepaint(_AuroraPainter old) => old.t != t;
}

// ─────────────────────────────────────────────────────────────
// Toggle facturation mensuel / annuel
// ─────────────────────────────────────────────────────────────

class _BillingToggle extends StatelessWidget {
  final PackageType selected;
  final bool isDark;
  final void Function(PackageType) onSelect;

  const _BillingToggle({
    required this.selected,
    required this.isDark,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.grey100,
        borderRadius: BorderRadius.circular(AppConstants.radiusPill),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _ToggleOption(
            label: 'Mensuel',
            selected: selected == PackageType.monthly,
            isDark: isDark,
            onTap: () => onSelect(PackageType.monthly),
          ),
          _ToggleOption(
            label: 'Annuel',
                        badge: '−34 %',
            selected: selected == PackageType.annual,
            isDark: isDark,
            onTap: () => onSelect(PackageType.annual),
          ),
        ],
      ),
    );
  }
}

class _ToggleOption extends StatelessWidget {
  final String label;
  final String? badge;
  final bool selected;
  final bool isDark;
  final VoidCallback onTap;

  const _ToggleOption({
    required this.label,
    this.badge,
    required this.selected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: AppConstants.animNormal,
          decoration: BoxDecoration(
            color: selected
                ? (isDark ? AppColors.surfaceElevatedDark : Colors.white)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppConstants.radiusPill),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ]
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: AppTextStyles.labelMedium().copyWith(
                        color: selected
                            ? (isDark ? AppColors.textDark : AppColors.textLight)
                            : (isDark
                                ? AppColors.textDarkMuted
                                : AppColors.grey400),
                        fontWeight:
                            selected ? FontWeight.w700 : FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),

                  ],
                ),
                if (badge != null) ...[
                  const SizedBox(width: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.2),
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusPill),
                    ),
                    child: Text(
                      badge!,
                      style: AppTextStyles.caption().copyWith(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w700,
                        fontSize: 9,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Carte Pro, gradient border + mise en avant
// ─────────────────────────────────────────────────────────────

class _ProCard extends StatelessWidget {
  final bool isDark;
  final bool isAnnual;
  final String price;
  final String priceMonthly;
  final bool isComingSoon;

  const _ProCard({
    required this.isDark,
    required this.isAnnual,
    required this.price,
    required this.priceMonthly,
    required this.isComingSoon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.accent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(2),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : const Color(0xFF1E1C3C),
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge - 2),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête : titre + badge
            Row(
              children: [
                Text(
                  'Pro',
                  style: AppTextStyles.headingLarge().copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.chartAmber, Color(0xFFFFD966)],
                    ),
                    borderRadius:
                        BorderRadius.circular(AppConstants.radiusPill),
                  ),
                  child: Text(
                    isComingSoon ? 'Bientôt' : 'Recommandé',
                    style: AppTextStyles.caption().copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Spacer(),
                if (isAnnual)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.2),
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusPill),
                    ),
                    child: Text(
                      '−34 %',
                      style: AppTextStyles.caption().copyWith(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 12),

            // Badge essai gratuit
            if (!isComingSoon)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppConstants.radiusPill),
                  border: Border.all(
                    color: AppColors.accent.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🎁', style: TextStyle(fontSize: 12)),
                    const SizedBox(width: 6),
                    Text(
                      '7 jours gratuits, sans engagement',
                      style: AppTextStyles.caption().copyWith(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 16),

            // Prix
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  isAnnual ? '79,99 €' : '9,99 €',
                  style: AppTextStyles.displayLarge().copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 38,
                    height: 1,
                  ),
                ),
                const SizedBox(width: 6),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    isAnnual ? '/an' : '/mois',
                    style: AppTextStyles.bodyMedium().copyWith(
                      color: AppColors.primaryPale,
                    ),
                  ),
                ),
              ],
            ),

            if (isAnnual)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'soit 6,67 €/mois, économise 40 €/an',
                  style: AppTextStyles.bodySmall().copyWith(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // 3 features clés dans la carte
            const _ProCardFeature('📈', 'Historique complet illimité'),
            const _ProCardFeature('🎯', 'Graphiques et analytics de progression'),
            const _ProCardFeature('💬', 'Communauté active, poster et interagir'),
          ],
        ),
      ),
    );
  }
}

class _ProCardFeature extends StatelessWidget {
  final String emoji;
  final String label;

  const _ProCardFeature(this.emoji, this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodySmall().copyWith(
                color: AppColors.primaryPale,
              ),
            ),
          ),
          const Icon(Icons.check_rounded, size: 16, color: AppColors.accent),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Features Pro complètes, expandable
// ─────────────────────────────────────────────────────────────

class _ProFeaturesCard extends StatelessWidget {
  final bool isDark;
  final bool showAll;
  final VoidCallback onToggle;

  const _ProFeaturesCard({
    required this.isDark,
    required this.showAll,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final features = showAll ? _proFeatures : _proFeatures.take(4).toList();

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        border: Border.all(
          color: isDark ? AppColors.glassBorder : AppColors.grey200,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tout ce qu\'inclut Pro',
            style: AppTextStyles.labelMedium().copyWith(
              color: AppColors.primaryLight,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          ...features.map((f) => _FeatureRow(f: f, isDark: isDark, isPro: true)),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: onToggle,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  showAll ? 'Voir moins' : 'Voir tout (${_proFeatures.length} avantages)',
                  style: AppTextStyles.caption().copyWith(
                    color: AppColors.primaryLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  showAll
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  size: 16,
                  color: AppColors.primaryLight,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Carte Gratuit
// ─────────────────────────────────────────────────────────────

class _FreeCard extends StatelessWidget {
  final bool isDark;
  const _FreeCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        border: Border.all(
          color: isDark ? AppColors.glassBorder : AppColors.grey200,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Gratuit',
                style: AppTextStyles.headingSmall().copyWith(
                  color: isDark ? AppColors.textDark : AppColors.textLight,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                '0 €/mois',
                style: AppTextStyles.headingSmall().copyWith(
                  color: isDark ? AppColors.textDarkMuted : AppColors.grey400,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Pour commencer et créer l\'habitude.',
            style: AppTextStyles.bodySmall().copyWith(
              color: isDark ? AppColors.textDarkMuted : AppColors.grey400,
            ),
          ),
          const SizedBox(height: 12),
          ..._freeFeatures.map((f) => _FeatureRow(f: f, isDark: isDark, isPro: false)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Ligne feature réutilisable
// ─────────────────────────────────────────────────────────────

class _FeatureRow extends StatelessWidget {
  final _Feature f;
  final bool isDark;
  final bool isPro;

  const _FeatureRow({
    required this.f,
    required this.isDark,
    required this.isPro,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 24,
            child: Text(f.emoji, style: const TextStyle(fontSize: 14)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  f.label,
                  style: AppTextStyles.bodySmall().copyWith(
                    color: isDark ? AppColors.textDark : AppColors.textLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (f.sublabel != null)
                  Text(
                    f.sublabel!,
                    style: AppTextStyles.caption().copyWith(
                      color: isDark
                          ? AppColors.textDarkMuted
                          : AppColors.grey400,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.check_rounded,
            size: 16,
            color: isPro ? AppColors.primaryLight : AppColors.accent,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// CTA principal
// ─────────────────────────────────────────────────────────────

class _MainCta extends StatelessWidget {
  final bool isLoading;
  final bool isComingSoon;
  final bool isAnnual;
  final VoidCallback? onTap;

  const _MainCta({
    required this.isLoading,
    required this.isComingSoon,
    required this.isAnnual,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isComingSoon ? null : onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          gradient: isComingSoon
              ? null
              : const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryLight],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
          color: isComingSoon
              ? AppColors.primary.withValues(alpha: 0.4)
              : null,
          borderRadius: BorderRadius.circular(AppConstants.radiusPill),
          boxShadow: isComingSoon
              ? null
              : [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    blurRadius: 16,
                    spreadRadius: 0,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isComingSoon
                          ? '✨  Bientôt disponible'
                          : '🎁  7 jours gratuits, puis ${isAnnual ? '79,99 €/an' : '9,99 €/mois'}',
                      style: AppTextStyles.labelMedium().copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    if (!isComingSoon) ...[
                      const SizedBox(width: 6),
                      const Icon(Icons.arrow_forward_rounded,
                          color: Colors.white, size: 18),
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}


// ─────────────────────────────────────────────────────────────
// Écran succès après achat
// ─────────────────────────────────────────────────────────────

class _SuccessBody extends StatelessWidget {
  final bool isDark;
  const _SuccessBody({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.accent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    blurRadius: 24,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: const Center(
                child: Text('🚀', style: TextStyle(fontSize: 46)),
              ),
            ),
            const SizedBox(height: AppConstants.spacing32),
            Text(
              'Bienvenue dans Pro 👑',
              style: AppTextStyles.headingLarge().copyWith(
                color: isDark ? AppColors.textDark : AppColors.textLight,
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.spacing12),
            Text(
              'Tu viens de t\'engager envers ta meilleure version.\nTon élan commence maintenant.',
              style: AppTextStyles.bodyMedium().copyWith(
                color: isDark ? AppColors.textDarkMuted : AppColors.grey400,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.spacing48),
            GestureDetector(
              onTap: () => context.go('/home'),
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryLight],
                  ),
                  borderRadius:
                      BorderRadius.circular(AppConstants.radiusPill),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'Retour à Mon Espace',
                    style: AppTextStyles.labelMedium().copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Lien légal cliquable (CGU / Politique de confidentialité)
// ─────────────────────────────────────────────────────────────

class _LegalLink extends StatelessWidget {
  final String label;
  final String url;
  final bool isDark;

  const _LegalLink({
    required this.label,
    required this.url,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        minimumSize: const Size(44, 44),
        tapTargetSize: MaterialTapTargetSize.padded,
      ),
      child: Text(
        label,
        style: AppTextStyles.caption().copyWith(
          color: AppColors.primaryLight,
          decoration: TextDecoration.underline,
          decorationColor: AppColors.primaryLight,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Écran erreur chargement
// ─────────────────────────────────────────────────────────────

class _ErrorBody extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorBody({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 48, color: AppColors.grey400),
            const SizedBox(height: AppConstants.spacing16),
            Text(
              'Impossible de charger les offres.\nVérifie ta connexion.',
              style: AppTextStyles.bodyMedium(color: AppColors.grey400),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.spacing24),
            TextButton(
              onPressed: onRetry,
              child: Text(
                'Réessayer',
                style: AppTextStyles.labelMedium()
                    .copyWith(color: AppColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
