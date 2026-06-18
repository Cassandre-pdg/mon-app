import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/theme/theme_provider.dart';
import '../../../../shared/constants/app_constants.dart';
import '../../../../shared/widgets/share_card.dart';
import '../../../../shared/widgets/badge_hex_widget.dart';
import '../../../../shared/constants/app_strings.dart';
import '../../../../shared/navigation/app_router.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../rewards/data/badge_model.dart';
import '../../../rewards/data/badge_preferences_repository.dart';
import '../../../rewards/presentation/providers/rewards_provider.dart';
import '../../data/profile_repository.dart';
import '../providers/profile_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(currentUserProvider);
    final statsAsync = ref.watch(profileStatsProvider);
    final themeMode = ref.watch(themeModeProvider);

    final fullName =
        user?.userMetadata?['full_name'] as String? ?? 'Kolyb';
    final email = user?.email ?? '';

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => ref.invalidate(profileStatsProvider),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppConstants.spacing24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Titre ──────────────────────────────────────
                Text(
                  AppStrings.navProfile,
                  style: AppTextStyles.displayLarge(
                    color: isDark ? AppColors.textDark : AppColors.textLight,
                  ),
                ),
                const SizedBox(height: AppConstants.spacing24),

                // ── Header profil cliquable ─────────────────────
                statsAsync.when(
                  loading: () => _ProfileHeaderSkeleton(isDark: isDark),
                  error: (_, __) => _ProfileHeaderCard(
                    fullName: fullName,
                    email: email,
                    jobTitle: null,
                    company: null,
                    tagline: null,
                    levelLabel: 'Explorateur',
                    level: 1,
                    isDark: isDark,
                    onTap: () => _openIdentitySheet(
                      context,
                      ref,
                      fullName: fullName,
                      jobTitle: '',
                      company: '',
                      tagline: '',
                    ),
                  ),
                  data: (stats) => _ProfileHeaderCard(
                    fullName: stats.fullName ?? fullName,
                    email: stats.email,
                    jobTitle: stats.jobTitle,
                    company: stats.company,
                    tagline: stats.tagline,
                    levelLabel: stats.levelLabel,
                    level: stats.level,
                    isDark: isDark,
                    onTap: () => _openIdentitySheet(
                      context,
                      ref,
                      fullName: stats.fullName ?? fullName,
                      jobTitle: stats.jobTitle ?? '',
                      company: stats.company ?? '',
                      tagline: stats.tagline ?? '',
                    ),
                  ),
                ),
                const SizedBox(height: AppConstants.spacing16),

                // ── Stats progression ───────────────────────────
                statsAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (stats) => _StatsCard(stats: stats, isDark: isDark),
                ),
                const SizedBox(height: AppConstants.spacing24),

                // ── Trophées (badges épinglés) ──────────────────
                _SectionTitle(title: 'Mes trophées', isDark: isDark),
                const SizedBox(height: AppConstants.spacing12),
                _TrophyShowcase(isDark: isDark),
                const SizedBox(height: AppConstants.spacing24),

                // ── Mon abonnement ──────────────────────────────
                _SectionTitle(title: 'Mon abonnement', isDark: isDark),
                const SizedBox(height: AppConstants.spacing12),
                _SubscriptionSection(isDark: isDark),
                const SizedBox(height: AppConstants.spacing24),

                // ── Apparence ───────────────────────────────────
                _SectionTitle(title: 'Apparence', isDark: isDark),
                const SizedBox(height: AppConstants.spacing12),
                _ThemePicker(themeMode: themeMode, isDark: isDark),
                const SizedBox(height: AppConstants.spacing24),

                // ── Mon compte ──────────────────────────────────
                _SectionTitle(title: 'Mon compte', isDark: isDark),
                const SizedBox(height: AppConstants.spacing12),
                _AccountSection(
                  fullName: statsAsync.valueOrNull?.fullName ?? fullName,
                  jobTitle: statsAsync.valueOrNull?.jobTitle ?? '',
                  company: statsAsync.valueOrNull?.company ?? '',
                  tagline: statsAsync.valueOrNull?.tagline ?? '',
                  isDark: isDark,
                ),
                const SizedBox(height: AppConstants.spacing24),

                // ── Carte partage ───────────────────────────────
                const ShareCard(),
                const SizedBox(height: AppConstants.spacing24),

                // ── Déconnexion ─────────────────────────────────
                _SignOutButton(isDark: isDark),
                const SizedBox(height: AppConstants.spacing16),

                // ── Supprimer compte ────────────────────────────
                Center(
                  child: TextButton(
                    onPressed: () => _confirmDeleteAccount(context, ref),
                    child: Text(
                      'Supprimer mon compte',
                      style: AppTextStyles.bodySmall(
                        color: AppColors.error.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppConstants.spacing24),

                // ── RGPD + version ──────────────────────────────
                Center(
                  child: Text(
                    AppStrings.rgpdDisclaimer,
                    style: AppTextStyles.caption(color: AppColors.grey400),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: AppConstants.spacing8),
                Center(
                  child: Text(
                    'Version 1.0.0',
                    style: AppTextStyles.caption(color: AppColors.grey400),
                  ),
                ),
                const SizedBox(height: AppConstants.spacing24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openIdentitySheet(
    BuildContext context,
    WidgetRef ref, {
    required String fullName,
    required String jobTitle,
    required String company,
    required String tagline,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _IdentityBottomSheet(
        initialName: fullName,
        initialJobTitle: jobTitle,
        initialCompany: company,
        initialTagline: tagline,
        onSave: (name, job, comp, tag) async {
          await ref.read(profileActionsProvider.notifier).updateProfile(
                fullName: name,
                jobTitle: job,
                company: comp,
                tagline: tag,
              );
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profil mis à jour'),
                backgroundColor: AppColors.success,
              ),
            );
          }
        },
      ),
    );
  }

  void _confirmDeleteAccount(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer mon compte'),
        content: const Text(
          'Toutes tes données seront effacées sous 30 jours. '
          'Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref
                  .read(profileActionsProvider.notifier)
                  .deleteAccount();
            },
            child: Text(
              'Supprimer',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Header profil cliquable ───────────────────────────────────
class _ProfileHeaderCard extends StatelessWidget {
  final String fullName;
  final String email;
  final String? jobTitle;
  final String? company;
  final String? tagline;
  final String levelLabel;
  final int level;
  final bool isDark;
  final VoidCallback onTap;

  const _ProfileHeaderCard({
    required this.fullName,
    required this.email,
    required this.jobTitle,
    required this.company,
    required this.tagline,
    required this.levelLabel,
    required this.level,
    required this.isDark,
    required this.onTap,
  });

  String get _initials {
    final parts = fullName.trim().split(' ');
    if (parts.isEmpty) return 'S';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  String get _levelEmoji {
    switch (level) {
      case 1:
        return '🌱';
      case 2:
        return '💼';
      case 3:
        return '🚀';
      case 4:
        return '🏗️';
      case 5:
        return '👑';
      default:
        return '🌱';
    }
  }

  // Ligne secondaire sous le nom : métier + entreprise, ou tagline, ou email
  String get _subtitle {
    final parts = <String>[];
    if (jobTitle != null && jobTitle!.isNotEmpty) parts.add(jobTitle!);
    if (company != null && company!.isNotEmpty) parts.add(company!);
    if (parts.isNotEmpty) return parts.join(' · ');
    if (tagline != null && tagline!.isNotEmpty) return tagline!;
    return email;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppConstants.spacing16),
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: BorderRadius.circular(AppConstants.radiusXL),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.20),
          ),
        ),
        child: Row(
          children: [
            // Avatar avec initiales + anneau violet
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primary, AppColors.primaryLight],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.30),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  _initials,
                  style: AppTextStyles.headingMedium(
                    color: Colors.white,
                  ).copyWith(fontWeight: FontWeight.w700, fontSize: 22),
                ),
              ),
            ),
            const SizedBox(width: AppConstants.spacing16),

            // Nom + sous-titre + niveau
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fullName,
                    style: AppTextStyles.headingSmall(
                      color: isDark ? AppColors.textDark : AppColors.textLight,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _subtitle,
                    style: AppTextStyles.bodySmall(color: AppColors.grey400),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$_levelEmoji $levelLabel',
                          style: AppTextStyles.caption(
                            color: AppColors.primaryLight,
                          ).copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Indicateur "modifier"
            Icon(
              Icons.edit_outlined,
              color: AppColors.grey400,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Header squelette (état loading) ──────────────────────────
class _ProfileHeaderSkeleton extends StatelessWidget {
  final bool isDark;
  const _ProfileHeaderSkeleton({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacing16),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(AppConstants.radiusXL),
      ),
      child: Row(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.grey200,
            ),
          ),
          const SizedBox(width: AppConstants.spacing16),
          const CircularProgressIndicator(),
        ],
      ),
    );
  }
}

// ── Bottom sheet — Mon identité ───────────────────────────────
class _IdentityBottomSheet extends StatefulWidget {
  final String initialName;
  final String initialJobTitle;
  final String initialCompany;
  final String initialTagline;
  final Future<void> Function(
    String name,
    String jobTitle,
    String company,
    String tagline,
  ) onSave;

  const _IdentityBottomSheet({
    required this.initialName,
    required this.initialJobTitle,
    required this.initialCompany,
    required this.initialTagline,
    required this.onSave,
  });

  @override
  State<_IdentityBottomSheet> createState() => _IdentityBottomSheetState();
}

class _IdentityBottomSheetState extends State<_IdentityBottomSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _jobCtrl;
  late final TextEditingController _companyCtrl;
  late final TextEditingController _taglineCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.initialName);
    _jobCtrl = TextEditingController(text: widget.initialJobTitle);
    _companyCtrl = TextEditingController(text: widget.initialCompany);
    _taglineCtrl = TextEditingController(text: widget.initialTagline);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _jobCtrl.dispose();
    _companyCtrl.dispose();
    _taglineCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    setState(() => _saving = true);
    try {
      await widget.onSave(
        name,
        _jobCtrl.text.trim(),
        _companyCtrl.text.trim(),
        _taglineCtrl.text.trim(),
      );
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomPad = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomPad),
      child: Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceEl(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
        child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Poignée
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.grey400.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          Text(
            'Mon identité',
            style: AppTextStyles.headingSmall(
              color: isDark ? AppColors.textDark : AppColors.textLight,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Ces informations s\'affichent sur ton profil',
            style: AppTextStyles.bodySmall(color: AppColors.grey400),
          ),
          const SizedBox(height: 24),

          _IdentityField(
            controller: _nameCtrl,
            label: 'Prénom ou nom affiché',
            hint: 'Ex. Cassandre',
            icon: Icons.person_outline_rounded,
            isDark: isDark,
            capitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 16),
          _IdentityField(
            controller: _jobCtrl,
            label: 'Métier / Fonction',
            hint: 'Ex. Graphiste freelance, Coach business',
            icon: Icons.work_outline_rounded,
            isDark: isDark,
          ),
          const SizedBox(height: 16),
          _IdentityField(
            controller: _companyCtrl,
            label: 'Entreprise ou nom de ton activité',
            hint: 'Ex. Studio Lumière (optionnel)',
            icon: Icons.business_outlined,
            isDark: isDark,
          ),
          const SizedBox(height: 16),
          _IdentityField(
            controller: _taglineCtrl,
            label: 'Ta phrase (optionnel)',
            hint: 'Ex. Je crée des marques qui ont du sens',
            icon: Icons.format_quote_outlined,
            isDark: isDark,
            maxLength: 80,
          ),
          const SizedBox(height: 28),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: const StadiumBorder(),
              ),
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Enregistrer'),
            ),
          ),
        ],
        ),
      ),
      ),
    );
  }
}

class _IdentityField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool isDark;
  final TextCapitalization capitalization;
  final int? maxLength;

  const _IdentityField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    required this.isDark,
    this.capitalization = TextCapitalization.sentences,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelMedium(
            color: isDark ? AppColors.textDark : AppColors.textLight,
          ).copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          textCapitalization: capitalization,
          maxLength: maxLength,
          style: AppTextStyles.bodyMedium(
            color: isDark ? AppColors.textDark : AppColors.textLight,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.bodyMedium(color: AppColors.grey400),
            prefixIcon: Icon(icon, color: AppColors.grey400, size: 20),
            counterText: '',
            filled: true,
            fillColor: isDark
                ? AppColors.surfaceDark
                : AppColors.backgroundLight, // intentionnel : champ de texte plus foncé en light
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark
                    ? AppColors.grey400.withValues(alpha: 0.2)
                    : AppColors.grey200,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark
                    ? AppColors.grey400.withValues(alpha: 0.2)
                    : AppColors.grey200,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Section abonnement ────────────────────────────────────────
class _SubscriptionSection extends StatelessWidget {
  final bool isDark;

  const _SubscriptionSection({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        border: Border.all(
          color: isDark
              ? AppColors.grey400.withValues(alpha: 0.15)
              : AppColors.grey200,
        ),
      ),
      child: Column(
        children: [
          // Plan actuel
          Padding(
            padding: const EdgeInsets.all(AppConstants.spacing16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.workspace_premium_outlined,
                    color: AppColors.primaryLight,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppConstants.spacing16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Plan Gratuit',
                        style: AppTextStyles.bodyMedium(
                          color: isDark
                              ? AppColors.textDark
                              : AppColors.textLight,
                        ).copyWith(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '3 posts/semaine · fonctionnalités de base',
                        style:
                            AppTextStyles.caption(color: AppColors.grey400),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.grey400.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Gratuit',
                    style: AppTextStyles.caption(color: AppColors.grey400)
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),

          // CTA passer à Pro
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppConstants.spacing16,
              0,
              AppConstants.spacing16,
              AppConstants.spacing16,
            ),
            child: GestureDetector(
              onTap: () => context.push('/paywall'),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryLight],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('✨', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    Text(
                      'Passer à Pro · 9,99 €/mois',
                      style: AppTextStyles.bodyMedium(
                        color: Colors.white,
                      ).copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
            color: isDark
                ? AppColors.grey400.withValues(alpha: 0.15)
                : AppColors.grey200,
          ),

          // Restaurer les achats
          InkWell(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      'La restauration des achats sera disponible prochainement.'),
                ),
              );
            },
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(AppConstants.radiusLarge),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacing16,
                vertical: AppConstants.spacing16,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.restore_rounded,
                    color: AppColors.grey400,
                    size: 20,
                  ),
                  const SizedBox(width: AppConstants.spacing16),
                  Expanded(
                    child: Text(
                      'Restaurer mes achats',
                      style: AppTextStyles.bodyMedium(
                        color: isDark
                            ? AppColors.textDark
                            : AppColors.textLight,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.grey400,
                    size: 20,
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

// ── Carte stats ───────────────────────────────────────────────
class _StatsCard extends StatelessWidget {
  final ProfileStats stats;
  final bool isDark;

  const _StatsCard({required this.stats, required this.isDark});

  double get _levelProgress {
    switch (stats.level) {
      case 1:
        return (stats.totalPoints / 100).clamp(0.0, 1.0);
      case 2:
        return ((stats.totalPoints - 101) / 199).clamp(0.0, 1.0);
      case 3:
        return ((stats.totalPoints - 301) / 299).clamp(0.0, 1.0);
      case 4:
        return ((stats.totalPoints - 601) / 399).clamp(0.0, 1.0);
      default:
        return 1.0;
    }
  }

  int get _nextLevelPoints {
    switch (stats.level) {
      case 1:
        return 101;
      case 2:
        return 301;
      case 3:
        return 601;
      case 4:
        return 1001;
      default:
        return stats.totalPoints;
    }
  }

  String get _nextLevelLabel {
    switch (stats.level) {
      case 1:
        return 'Indépendant';
      case 2:
        return 'Entrepreneur';
      case 3:
        return 'Bâtisseur';
      case 4:
        return 'Visionnaire';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacing16),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        border: Border.all(
          color: isDark
              ? AppColors.grey400.withValues(alpha: 0.15)
              : AppColors.grey200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ma progression',
            style: AppTextStyles.labelMedium(
              color: isDark ? AppColors.textDark : AppColors.textLight,
            ).copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppConstants.spacing16),

          Row(
            children: [
              _StatItem(
                emoji: '🔥',
                value: '${stats.currentStreak}',
                label: 'Streak',
                color: AppColors.secondary,
                isDark: isDark,
              ),
              _StatDivider(isDark: isDark),
              _StatItem(
                emoji: '🏆',
                value: '${stats.longestStreak}',
                label: 'Record',
                color: AppColors.warning,
                isDark: isDark,
              ),
              _StatDivider(isDark: isDark),
              _StatItem(
                emoji: '⭐',
                value: '${stats.totalPoints}',
                label: 'Points',
                color: AppColors.primary,
                isDark: isDark,
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacing16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Niv. ${stats.level} · ${stats.levelLabel}',
                style: AppTextStyles.bodySmall(
                  color: isDark ? AppColors.textDark : AppColors.textLight,
                ).copyWith(fontWeight: FontWeight.w600),
              ),
              if (stats.level < 5)
                Text(
                  '${stats.totalPoints} / $_nextLevelPoints pts',
                  style: AppTextStyles.caption(color: AppColors.grey400),
                ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _levelProgress,
              minHeight: 8,
              backgroundColor: AppColors.grey200,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          if (stats.level < 5) ...[
            const SizedBox(height: 6),
            Text(
              'Prochain niveau : $_nextLevelLabel',
              style: AppTextStyles.caption(color: AppColors.grey400),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;
  final Color color;
  final bool isDark;

  const _StatItem({
    required this.emoji,
    required this.value,
    required this.label,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.headingSmall(color: color)
                .copyWith(fontWeight: FontWeight.w700),
          ),
          Text(
            label,
            style: AppTextStyles.caption(color: AppColors.grey400),
          ),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  final bool isDark;
  const _StatDivider({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 48,
      color: isDark
          ? AppColors.grey400.withValues(alpha: 0.2)
          : AppColors.grey200,
    );
  }
}

// ── Titre de section ──────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  final String title;
  final bool isDark;

  const _SectionTitle({required this.title, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTextStyles.labelMedium(
        color: AppColors.grey400,
      ).copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }
}

// ── Sélecteur de thème ────────────────────────────────────────
class _ThemePicker extends ConsumerWidget {
  final ThemeMode themeMode;
  final bool isDark;

  const _ThemePicker({required this.themeMode, required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacing8),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        border: Border.all(
          color: isDark
              ? AppColors.grey400.withValues(alpha: 0.15)
              : AppColors.grey200,
        ),
      ),
      child: Row(
        children: [
          _ThemeChip(
            label: '🌙 Sombre',
            selected: themeMode == ThemeMode.dark,
            isDark: isDark,
            onTap: () =>
                ref.read(themeModeProvider.notifier).setTheme(ThemeMode.dark),
          ),
          _ThemeChip(
            label: '☀️ Clair',
            selected: themeMode == ThemeMode.light,
            isDark: isDark,
            onTap: () =>
                ref.read(themeModeProvider.notifier).setTheme(ThemeMode.light),
          ),
          _ThemeChip(
            label: '⚙️ Auto',
            selected: themeMode == ThemeMode.system,
            isDark: isDark,
            onTap: () => ref
                .read(themeModeProvider.notifier)
                .setTheme(ThemeMode.system),
          ),
        ],
      ),
    );
  }
}

class _ThemeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final bool isDark;
  final VoidCallback onTap;

  const _ThemeChip({
    required this.label,
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
          duration: AppConstants.animFast,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
            border: Border.all(
              color: selected ? AppColors.primary : Colors.transparent,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall(
              color: selected ? AppColors.primary : AppColors.grey400,
            ).copyWith(
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Section compte ────────────────────────────────────────────
class _AccountSection extends ConsumerWidget {
  final String fullName;
  final String jobTitle;
  final String company;
  final String tagline;
  final bool isDark;

  const _AccountSection({
    required this.fullName,
    required this.jobTitle,
    required this.company,
    required this.tagline,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        border: Border.all(
          color: isDark
              ? AppColors.grey400.withValues(alpha: 0.15)
              : AppColors.grey200,
        ),
      ),
      child: Column(
        children: [
          _AccountTile(
            icon: Icons.emoji_events_rounded,
            label: 'Mes Badges',
            isDark: isDark,
            onTap: () => context.push(AppRoutes.rewards),
          ),
          _divider(isDark),
          _AccountTile(
            icon: Icons.notifications_outlined,
            label: 'Notifications',
            isDark: isDark,
            onTap: () => context.push(AppRoutes.notificationSettings),
          ),
          _divider(isDark),
          _AccountTile(
            icon: Icons.badge_outlined,
            label: 'Mon identité',
            isDark: isDark,
            onTap: () => _openIdentitySheet(context, ref),
          ),
          _divider(isDark),
          _AccountTile(
            icon: Icons.lock_outline_rounded,
            label: 'Réinitialiser mon mot de passe',
            isDark: isDark,
            onTap: () => _resetPassword(context, ref),
          ),
        ],
      ),
    );
  }

  Widget _divider(bool isDark) => Divider(
        height: 1,
        indent: 52,
        color: isDark
            ? AppColors.grey400.withValues(alpha: 0.15)
            : AppColors.grey200,
      );

  void _openIdentitySheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _IdentityBottomSheet(
        initialName: fullName,
        initialJobTitle: jobTitle,
        initialCompany: company,
        initialTagline: tagline,
        onSave: (name, job, comp, tag) async {
          await ref.read(profileActionsProvider.notifier).updateProfile(
                fullName: name,
                jobTitle: job,
                company: comp,
                tagline: tag,
              );
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profil mis à jour'),
                backgroundColor: AppColors.success,
              ),
            );
          }
        },
      ),
    );
  }

  void _resetPassword(BuildContext context, WidgetRef ref) async {
    await ref.read(profileActionsProvider.notifier).resetPassword();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email envoyé, vérifie ta boîte 📧'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }
}

class _AccountTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  final VoidCallback onTap;

  const _AccountTile({
    required this.icon,
    required this.label,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacing16,
          vertical: AppConstants.spacing16,
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.grey400, size: 20),
            const SizedBox(width: AppConstants.spacing16),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.bodyMedium(
                  color: isDark ? AppColors.textDark : AppColors.textLight,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.grey400,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Bouton déconnexion ────────────────────────────────────────
class _SignOutButton extends ConsumerWidget {
  final bool isDark;
  const _SignOutButton({required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState is AsyncLoading;

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: isLoading ? null : () => _confirmSignOut(context, ref),
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: AppColors.secondary.withValues(alpha: 0.5),
          ),
          foregroundColor: AppColors.secondary,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          ),
        ),
        icon: isLoading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.logout_rounded, size: 20),
        label: Text(isLoading ? 'Déconnexion...' : 'Me déconnecter'),
      ),
    );
  }

  void _confirmSignOut(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Se déconnecter ?'),
        content: const Text('Tu pourras te reconnecter à tout moment.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(authNotifierProvider.notifier).signOut();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
            ),
            child: const Text('Se déconnecter'),
          ),
        ],
      ),
    );
  }
}

// ── Vitrine trophées (badges épinglés sur le profil) ─────────
class _TrophyShowcase extends ConsumerWidget {
  final bool isDark;
  const _TrophyShowcase({required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pinnedAsync = ref.watch(pinnedBadgesProvider);
    final badgesAsync = ref.watch(badgesProvider);

    return pinnedAsync.when(
      loading: () => const SizedBox(height: 100),
      error: (_, __) => const SizedBox.shrink(),
      data: (pinnedIds) => badgesAsync.when(
        loading: () => const SizedBox(height: 100),
        error: (_, __) => const SizedBox.shrink(),
        data: (allBadges) {
          final pinned = pinnedIds
              .map((id) => allBadges.firstWhere(
                    (b) => b.id == id,
                    orElse: () => allBadges.first,
                  ))
              .where((b) => pinnedIds.contains(b.id))
              .toList();

          final cardColor = AppColors.surface(context);
          final borderColor = AppColors.cardBorder(context);

          return Container(
            padding: const EdgeInsets.all(AppConstants.spacing16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              children: [
                if (pinned.isEmpty)
                  _EmptyTrophy(isDark: isDark)
                else
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      for (final badge in pinned)
                        _PinnedBadgeTile(badge: badge, isDark: isDark),
                      // Slots vides
                      for (int i = pinned.length;
                          i < BadgePreferencesRepository.maxPinned;
                          i++)
                        _EmptySlot(isDark: isDark),
                    ],
                  ),
                const SizedBox(height: AppConstants.spacing12),
                GestureDetector(
                  onTap: () => context.push(AppRoutes.rewards),
                  child: Text(
                    pinned.isEmpty
                        ? 'Choisir mes trophées dans Mes Badges'
                        : 'Modifier mes trophées',
                    style: AppTextStyles.bodySmall(
                      color: AppColors.primaryLight,
                    ).copyWith(fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PinnedBadgeTile extends StatelessWidget {
  final AppBadge badge;
  final bool isDark;
  const _PinnedBadgeTile({required this.badge, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        BadgeHexWidget(
          gradientColors: badge.gradientColors,
          icon: badge.icon,
          isUnlocked: true,
          isLegendary: badge.tier == BadgeTier.legendary,
          isRare: badge.tier == BadgeTier.rare,
          categoryColor: badge.categoryColor,
          size: 56,
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 72,
          child: Text(
            badge.name,
            style: AppTextStyles.caption(color: badge.categoryColor)
                .copyWith(fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _EmptySlot extends StatelessWidget {
  final bool isDark;
  const _EmptySlot({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: (isDark ? Colors.white : Colors.black)
                  .withValues(alpha: 0.1),
              width: 1.5,
            ),
          ),
          child: Icon(
            Icons.add_rounded,
            color: (isDark ? Colors.white : Colors.black)
                .withValues(alpha: 0.2),
            size: 22,
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 72,
          child: Text(
            'Ajouter',
            style: AppTextStyles.caption(
              color: (isDark ? Colors.white : Colors.black)
                  .withValues(alpha: 0.22),
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

class _EmptyTrophy extends StatelessWidget {
  final bool isDark;
  const _EmptyTrophy({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          Icons.workspace_premium_rounded,
          size: 36,
          color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.15),
        ),
        const SizedBox(height: 8),
        Text(
          'Épingle ici tes 3 badges préférés',
          style: AppTextStyles.bodySmall(
            color: (isDark ? Colors.white : Colors.black)
                .withValues(alpha: 0.35),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
