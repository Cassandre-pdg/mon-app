import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/theme/theme_provider.dart';
import '../../../../shared/constants/app_constants.dart';
import '../../../../shared/constants/app_strings.dart';
import '../../../../shared/navigation/app_router.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
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
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
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
                  style: AppTextStyles.headingLarge(
                    color: isDark ? AppColors.textDark : AppColors.textLight,
                  ),
                ),
                const SizedBox(height: AppConstants.spacing24),

                // ── Header profil ───────────────────────────────
                statsAsync.when(
                  loading: () => _ProfileHeaderSkeleton(isDark: isDark),
                  error: (_, __) => _ProfileHeaderSimple(
                    fullName: fullName,
                    email: email,
                    levelLabel: 'Explorateur',
                    level: 1,
                    isDark: isDark,
                  ),
                  data: (stats) => _ProfileHeader(
                    fullName: stats.fullName ?? fullName,
                    email: stats.email,
                    levelLabel: stats.levelLabel,
                    level: stats.level,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(height: AppConstants.spacing16),

                // ── Stats ───────────────────────────────────────
                statsAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (stats) => _StatsCard(stats: stats, isDark: isDark),
                ),
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
                  fullName: fullName,
                  isDark: isDark,
                ),
                const SizedBox(height: AppConstants.spacing32),

                // ── Déconnexion ─────────────────────────────────
                _SignOutButton(isDark: isDark),
                const SizedBox(height: AppConstants.spacing24),

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
                const SizedBox(height: AppConstants.spacing32),

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

// ── Header profil ─────────────────────────────────────────────
class _ProfileHeader extends StatelessWidget {
  final String fullName;
  final String email;
  final String levelLabel;
  final int level;
  final bool isDark;

  const _ProfileHeader({
    required this.fullName,
    required this.email,
    required this.levelLabel,
    required this.level,
    required this.isDark,
  });

  String get _initials {
    final parts = fullName.trim().split(' ');
    if (parts.isEmpty) return 'S';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  String get _levelEmoji {
    switch (level) {
      case 1: return '🌱';
      case 2: return '💼';
      case 3: return '🚀';
      case 4: return '🏗️';
      case 5: return '👑';
      default: return '🌱';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacing16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppConstants.radiusXL),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          // Avatar avec initiales
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, AppColors.primaryLight],
              ),
            ),
            child: Center(
              child: Text(
                _initials,
                style: AppTextStyles.headingMedium(
                  color: Colors.white,
                ).copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(width: AppConstants.spacing16),

          // Nom + email + niveau
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
                const SizedBox(height: 2),
                Text(
                  email,
                  style: AppTextStyles.bodySmall(color: AppColors.grey400),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                // Badge niveau
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius:
                        BorderRadius.circular(AppConstants.radiusSmall),
                  ),
                  child: Text(
                    '$_levelEmoji $levelLabel',
                    style: AppTextStyles.caption(color: AppColors.primary)
                        .copyWith(fontWeight: FontWeight.w600),
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

// ── Header simplifié (état erreur) ────────────────────────────
class _ProfileHeaderSimple extends _ProfileHeader {
  const _ProfileHeaderSimple({
    required super.fullName,
    required super.email,
    required super.levelLabel,
    required super.level,
    required super.isDark,
  });
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
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppConstants.radiusXL),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
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

// ── Carte stats ───────────────────────────────────────────────
class _StatsCard extends StatelessWidget {
  final ProfileStats stats;
  final bool isDark;

  const _StatsCard({required this.stats, required this.isDark});

  // Seuils de progression par niveau
  double get _levelProgress {
    switch (stats.level) {
      case 1: return (stats.totalPoints / 100).clamp(0.0, 1.0);
      case 2: return ((stats.totalPoints - 101) / 199).clamp(0.0, 1.0);
      case 3: return ((stats.totalPoints - 301) / 299).clamp(0.0, 1.0);
      case 4: return ((stats.totalPoints - 601) / 399).clamp(0.0, 1.0);
      default: return 1.0;
    }
  }

  int get _nextLevelPoints {
    switch (stats.level) {
      case 1: return 101;
      case 2: return 301;
      case 3: return 601;
      case 4: return 1001;
      default: return stats.totalPoints;
    }
  }

  String get _nextLevelLabel {
    switch (stats.level) {
      case 1: return 'Indépendant';
      case 2: return 'Entrepreneur';
      case 3: return 'Bâtisseur';
      case 4: return 'Visionnaire';
      default: return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacing16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
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

          // 3 stats
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

          // Barre de progression du niveau
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
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
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
            onTap: () => ref
                .read(themeModeProvider.notifier)
                .setTheme(ThemeMode.dark),
          ),
          _ThemeChip(
            label: '☀️ Clair',
            selected: themeMode == ThemeMode.light,
            isDark: isDark,
            onTap: () => ref
                .read(themeModeProvider.notifier)
                .setTheme(ThemeMode.light),
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
              color: selected
                  ? AppColors.primary
                  : AppColors.grey400,
            ).copyWith(fontWeight: selected ? FontWeight.w600 : FontWeight.w400),
          ),
        ),
      ),
    );
  }
}

// ── Section compte ────────────────────────────────────────────
class _AccountSection extends ConsumerWidget {
  final String fullName;
  final bool isDark;

  const _AccountSection({required this.fullName, required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
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
          Divider(
            height: 1,
            indent: 52,
            color: isDark
                ? AppColors.grey400.withValues(alpha: 0.15)
                : AppColors.grey200,
          ),
          _AccountTile(
            icon: Icons.notifications_outlined,
            label: 'Notifications',
            isDark: isDark,
            onTap: () => context.push(AppRoutes.notificationSettings),
          ),
          Divider(
            height: 1,
            indent: 52,
            color: isDark
                ? AppColors.grey400.withValues(alpha: 0.15)
                : AppColors.grey200,
          ),
          _AccountTile(
            icon: Icons.person_outline_rounded,
            label: 'Modifier mon prénom',
            isDark: isDark,
            onTap: () => _showEditNameDialog(context, ref, fullName),
          ),
          Divider(
            height: 1,
            indent: 52,
            color: isDark
                ? AppColors.grey400.withValues(alpha: 0.15)
                : AppColors.grey200,
          ),
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

  void _showEditNameDialog(
    BuildContext context,
    WidgetRef ref,
    String currentName,
  ) {
    final ctrl = TextEditingController(text: currentName);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Modifier mon prénom'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            hintText: 'Ton prénom ou pseudo',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = ctrl.text.trim();
              if (name.isEmpty) return;
              Navigator.pop(ctx);
              await ref
                  .read(profileActionsProvider.notifier)
                  .updateName(name);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Prénom mis à jour ✅'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  void _resetPassword(BuildContext context, WidgetRef ref) async {
    await ref.read(profileActionsProvider.notifier).resetPassword();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email envoyé — vérifie ta boîte 📧'),
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
            Icon(
              icon,
              color: AppColors.grey400,
              size: 20,
            ),
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
        onPressed: isLoading
            ? null
            : () => _confirmSignOut(context, ref),
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

