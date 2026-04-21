import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/constants/app_constants.dart';
import '../../../../shared/constants/app_strings.dart';
import '../providers/subscription_provider.dart';

// ─────────────────────────────────────────────────────────────
// Écran principal
// ─────────────────────────────────────────────────────────────

class PaywallScreen extends ConsumerWidget {
  /// true → bouton fermer visible (accès depuis Profil).
  /// false → l'utilisateur doit choisir.
  final bool isDismissible;

  const PaywallScreen({super.key, this.isDismissible = true});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offeringAsync = ref.watch(activeOfferingProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: offeringAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
          error: (_, __) => _ErrorBody(
            message: AppStrings.paywallErrorGeneric,
            onRetry: () => ref.invalidate(activeOfferingProvider),
          ),
          data: (offering) => _PaywallBody(
            offering:      offering,
            isDismissible: isDismissible,
            isDark:        isDark,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Corps — StatefulWidget pour gérer la sélection mensuel/annuel
// ─────────────────────────────────────────────────────────────

class _PaywallBody extends ConsumerStatefulWidget {
  final Offering? offering;
  final bool      isDismissible;
  final bool      isDark;

  const _PaywallBody({
    required this.offering,
    required this.isDismissible,
    required this.isDark,
  });

  @override
  ConsumerState<_PaywallBody> createState() => _PaywallBodyState();
}

class _PaywallBodyState extends ConsumerState<_PaywallBody> {
  // Sélection par défaut : annuel (meilleure valeur)
  PackageType _selected = PackageType.annual;

  Package? get _monthlyPackage => widget.offering?.availablePackages
      .where((p) => p.packageType == PackageType.monthly)
      .firstOrNull;

  Package? get _annualPackage => widget.offering?.availablePackages
      .where((p) => p.packageType == PackageType.annual)
      .firstOrNull;

  Package? get _activePackage =>
      _selected == PackageType.annual ? _annualPackage : _monthlyPackage;

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
    final isPro     = ref.watch(isProProvider);
    final subState  = ref.watch(subscriptionStatusProvider);
    final isLoading = subState is AsyncLoading;
    final hasError  = subState is AsyncError;

    // Après achat réussi → écran succès
    if (isPro) return _SuccessBody(isDark: widget.isDark);

    return Column(
      children: [
        // Bouton fermer
        if (widget.isDismissible)
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.only(top: 8, right: 8),
              child: IconButton(
                icon: Icon(
                  Icons.close_rounded,
                  color: widget.isDark
                      ? AppColors.textDarkMuted
                      : AppColors.grey400,
                ),
                onPressed: () => context.pop(),
              ),
            ),
          ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: widget.isDismissible ? 4 : AppConstants.spacing32),

                // ── En-tête ────────────────────────────────────
                _Header(isDark: widget.isDark),

                const SizedBox(height: AppConstants.spacing32),

                // ── Ce qui est inclus dans le Free ────────────
                _SectionTitle(
                  label: 'Inclus dans Kolyb Free',
                  isDark: widget.isDark,
                ),
                const SizedBox(height: AppConstants.spacing12),
                _FeaturesSection(
                  features: _freeFeatures,
                  isDark:   widget.isDark,
                  style:    _FeatureStyle.free,
                ),

                const SizedBox(height: AppConstants.spacing24),

                // ── Ce qu'apporte Pro ─────────────────────────
                _SectionTitle(
                  label: 'En plus avec Pro',
                  isDark:    widget.isDark,
                  highlight: true,
                ),
                const SizedBox(height: AppConstants.spacing12),
                _FeaturesSection(
                  features: _proFeatures,
                  isDark:   widget.isDark,
                  style:    _FeatureStyle.pro,
                ),

                const SizedBox(height: AppConstants.spacing32),

                // ── Sélecteur mensuel / annuel ────────────────
                _PackageSelector(
                  selected:       _selected,
                  monthlyPackage: _monthlyPackage,
                  annualPackage:  _annualPackage,
                  isDark:         widget.isDark,
                  onSelect: (type) => setState(() => _selected = type),
                ),

                const SizedBox(height: AppConstants.spacing24),

                // ── Erreur ────────────────────────────────────
                if (hasError) ...[
                  Text(
                    AppStrings.paywallErrorGeneric,
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.error),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppConstants.spacing16),
                ],

                // ── CTA principal ─────────────────────────────
                _CtaButton(
                  label:     AppStrings.paywallCtaPro,
                  isLoading: isLoading,
                  onTap:     _activePackage != null && !isLoading
                      ? _purchase
                      : null,
                ),

                const SizedBox(height: AppConstants.spacing16),

                // ── Continuer en gratuit ──────────────────────
                if (widget.isDismissible)
                  TextButton(
                    onPressed: isLoading ? null : () => context.pop(),
                    child: Text(
                      AppStrings.paywallCtaFree,
                      style: AppTextStyles.labelMedium().copyWith(
                        color: widget.isDark
                            ? AppColors.textDarkMuted
                            : AppColors.grey400,
                      ),
                    ),
                  ),

                const SizedBox(height: AppConstants.spacing8),

                // ── Restaurer ─────────────────────────────────
                TextButton(
                  onPressed: isLoading ? null : _restore,
                  child: Text(
                    AppStrings.paywallRestoreLink,
                    style: AppTextStyles.caption().copyWith(
                      color: AppColors.primaryLight,
                      decoration: TextDecoration.underline,
                      decorationColor: AppColors.primaryLight,
                    ),
                  ),
                ),

                const SizedBox(height: AppConstants.spacing8),

                // ── Légal ─────────────────────────────────────
                Text(
                  AppStrings.paywallLegal,
                  style: AppTextStyles.caption().copyWith(
                    color: widget.isDark
                        ? AppColors.textDarkMuted
                        : AppColors.grey400,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppConstants.spacing24),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Listes de features
// ─────────────────────────────────────────────────────────────

const _freeFeatures = [
  ('Check-in quotidien — humeur et énergie', '🌱'),
  ('Timer Pomodoro simple',                  '⏱'),
  ('Suivi du sommeil — saisie manuelle',     '😴'),
  ('Tableau de bord personnel 7 jours',      '🏠'),
];

const _proFeatures = [
  ('Accès complet à la communauté',              '💬'),
  ('Sondage groupes — tu choisis ce qui existe', '🗳'),
  ('Tracking avancé — 30 et 90 jours',           '📈'),
  ('Alertes tendance basse — prévention burnout', '🔔'),
  ('Pomodoro personnalisé — cycles et durées',   '⏱'),
  ('Rapport hebdo bien-être par email',          '📧'),
];

enum _FeatureStyle { free, pro }

// ─────────────────────────────────────────────────────────────
// Widgets internes
// ─────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final bool isDark;
  const _Header({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Badge Pro
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.primaryLight],
            ),
            borderRadius: BorderRadius.circular(AppConstants.radiusPill),
          ),
          child: Text(
            'Pro v1 — recommandé',
            style: AppTextStyles.caption().copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        const SizedBox(height: AppConstants.spacing16),

        Text(
          AppStrings.paywallTitle,
          style: AppTextStyles.displayLarge().copyWith(
            color: isDark ? AppColors.textDark : AppColors.textLight,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: AppConstants.spacing8),

        Text(
          AppStrings.paywallSubtitle,
          style: AppTextStyles.bodyMedium().copyWith(
            color: isDark ? AppColors.textDarkMuted : AppColors.grey400,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String label;
  final bool   isDark;
  final bool   highlight;

  const _SectionTitle({
    required this.label,
    required this.isDark,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        style: AppTextStyles.headingSmall().copyWith(
          color: highlight
              ? AppColors.primaryLight
              : (isDark ? AppColors.textDarkMuted : AppColors.grey400),
        ),
      ),
    );
  }
}

class _FeaturesSection extends StatelessWidget {
  final List<(String, String)> features;
  final bool                   isDark;
  final _FeatureStyle          style;

  const _FeaturesSection({
    required this.features,
    required this.isDark,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: features
          .map((f) => _FeatureRow(
                label: f.$1,
                emoji: f.$2,
                isDark: isDark,
                style:  style,
              ))
          .toList(),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final String        label;
  final String        emoji;
  final bool          isDark;
  final _FeatureStyle style;

  const _FeatureRow({
    required this.label,
    required this.emoji,
    required this.isDark,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    final isPro = style == _FeatureStyle.pro;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: (isPro ? AppColors.primary : AppColors.accent)
                  .withAlpha(25),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 13)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodyMedium().copyWith(
                color: isDark ? AppColors.textDark : AppColors.textLight,
              ),
            ),
          ),
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
// Sélecteur mensuel / annuel
// ─────────────────────────────────────────────────────────────

class _PackageSelector extends StatelessWidget {
  final PackageType   selected;
  final Package?      monthlyPackage;
  final Package?      annualPackage;
  final bool          isDark;
  final void Function(PackageType) onSelect;

  const _PackageSelector({
    required this.selected,
    required this.monthlyPackage,
    required this.annualPackage,
    required this.isDark,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Annuel — en premier car recommandé par défaut
        _PackageCard(
          type:       PackageType.annual,
          selected:   selected == PackageType.annual,
          isDark:     isDark,
          price:      annualPackage?.storeProduct.priceString
              ?? AppConstants.priceAnnual,
          pricePerMonth: AppConstants.priceAnnualMonthly,
          caption:    'Économie de 34\u202f% — le meilleur tarif',
          savingBadge: AppStrings.paywallPriceAnnualSaving,
          onTap:      () => onSelect(PackageType.annual),
        ),

        const SizedBox(height: AppConstants.spacing12),

        // Mensuel
        _PackageCard(
          type:     PackageType.monthly,
          selected: selected == PackageType.monthly,
          isDark:   isDark,
          price:    monthlyPackage?.storeProduct.priceString
              ?? AppStrings.paywallPriceMonthly,
          caption:  AppStrings.paywallPriceMonthlyCaption,
          onTap:    () => onSelect(PackageType.monthly),
        ),
      ],
    );
  }
}

class _PackageCard extends StatelessWidget {
  final PackageType type;
  final bool        selected;
  final bool        isDark;
  final String      price;
  final String?     pricePerMonth;
  final String      caption;
  final String?     savingBadge;
  final VoidCallback onTap;

  const _PackageCard({
    required this.type,
    required this.selected,
    required this.isDark,
    required this.price,
    this.pricePerMonth,
    required this.caption,
    this.savingBadge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isAnnual = type == PackageType.annual;
    final label    = isAnnual ? 'Annuel' : 'Mensuel';

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppConstants.animNormal,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withAlpha(20)
              : (isDark ? AppColors.surfaceDark : AppColors.surfaceLight),
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          border: Border.all(
            color: selected
                ? AppColors.primary
                : (isDark
                    ? AppColors.glassBorder
                    : AppColors.grey200),
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Radio indicator
            AnimatedContainer(
              duration: AppConstants.animNormal,
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? AppColors.primary : AppColors.grey400,
                  width: 2,
                ),
                color: selected ? AppColors.primary : Colors.transparent,
              ),
              child: selected
                  ? const Icon(Icons.check, size: 12, color: Colors.white)
                  : null,
            ),

            const SizedBox(width: 12),

            // Textes
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.labelMedium().copyWith(
                      color: isDark ? AppColors.textDark : AppColors.textLight,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    caption,
                    style: AppTextStyles.caption().copyWith(
                      color: isDark
                          ? AppColors.textDarkMuted
                          : AppColors.grey400,
                    ),
                  ),
                ],
              ),
            ),

            // Prix
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  price,
                  style: AppTextStyles.headingSmall().copyWith(
                    color: selected
                        ? AppColors.primaryLight
                        : (isDark ? AppColors.textDark : AppColors.textLight),
                  ),
                ),
                if (pricePerMonth != null)
                  Text(
                    pricePerMonth!,
                    style: AppTextStyles.caption().copyWith(
                      color: isDark
                          ? AppColors.textDarkMuted
                          : AppColors.grey400,
                    ),
                  ),
              ],
            ),

            // Badge économie
            if (savingBadge != null) ...[
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.accent.withAlpha(25),
                  borderRadius:
                      BorderRadius.circular(AppConstants.radiusPill),
                ),
                child: Text(
                  savingBadge!,
                  style: AppTextStyles.caption().copyWith(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Bouton CTA
// ─────────────────────────────────────────────────────────────

class _CtaButton extends StatelessWidget {
  final String        label;
  final bool          isLoading;
  final VoidCallback? onTap;

  const _CtaButton({
    required this.label,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: AppConstants.buttonMinWidth,
        maxWidth: AppConstants.buttonMaxWidth,
      ),
      child: FilledButton(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                label,
                style: AppTextStyles.labelMedium().copyWith(
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Écran succès
// ─────────────────────────────────────────────────────────────

class _SuccessBody extends StatelessWidget {
  final bool isDark;
  const _SuccessBody({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(30),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('🚀', style: TextStyle(fontSize: 44)),
            ),
          ),
          const SizedBox(height: AppConstants.spacing32),
          Text(
            AppStrings.paywallSuccessTitle,
            style: AppTextStyles.headingLarge().copyWith(
              color: isDark ? AppColors.textDark : AppColors.textLight,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.spacing16),
          Text(
            AppStrings.paywallSuccessSubtitle,
            style: AppTextStyles.bodyMedium().copyWith(
              color: isDark ? AppColors.textDarkMuted : AppColors.grey400,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.spacing48),
          _CtaButton(
            label:     'Retour à Mon Espace',
            isLoading: false,
            onTap:     () => context.go('/home'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Écran erreur chargement offering
// ─────────────────────────────────────────────────────────────

class _ErrorBody extends StatelessWidget {
  final String       message;
  final VoidCallback onRetry;

  const _ErrorBody({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off_rounded,
              size: 48, color: AppColors.grey400),
          const SizedBox(height: AppConstants.spacing16),
          Text(message,
              style: AppTextStyles.bodyMedium(), textAlign: TextAlign.center),
          const SizedBox(height: AppConstants.spacing24),
          TextButton(
            onPressed: onRetry,
            child: Text(
              'Réessayer',
              style:
                  AppTextStyles.labelMedium().copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}
