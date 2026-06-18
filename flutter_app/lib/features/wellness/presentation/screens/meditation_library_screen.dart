import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/constants/app_constants.dart';
import '../../../subscription/presentation/providers/subscription_provider.dart';
import '../../data/models/meditation.dart';

class MeditationLibraryScreen extends ConsumerStatefulWidget {
  const MeditationLibraryScreen({super.key});

  @override
  ConsumerState<MeditationLibraryScreen> createState() =>
      _MeditationLibraryScreenState();
}

class _MeditationLibraryScreenState
    extends ConsumerState<MeditationLibraryScreen> {
  MeditationTheme? _selectedTheme;
  int? _selectedDuration;

  List<Meditation> get _filtered {
    return Meditation.catalog.where((m) {
      final themeOk = _selectedTheme == null || m.theme == _selectedTheme;
      final durOk =
          _selectedDuration == null || m.durationMinutes == _selectedDuration;
      return themeOk && durOk;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final isPro = ref.watch(isProProvider);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── En-tête ────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    color: isDark ? AppColors.textDark : AppColors.textLight,
                    style: IconButton.styleFrom(
                      backgroundColor:
                          isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Méditations',
                    style: AppTextStyles.headingMedium(
                      color: isDark ? AppColors.textDark : AppColors.textLight,
                    ),
                  ),
                  const Spacer(),
                  // Badge Pro si pas abonné
                  if (!isPro)
                    GestureDetector(
                      onTap: () => context.push('/paywall'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6D28D9), Color(0xFF8B7FE8)],
                          ),
                          borderRadius: BorderRadius.circular(
                              AppConstants.radiusPill),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.workspace_premium_rounded,
                                color: Colors.white, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              'Passer Pro',
                              style: AppTextStyles.caption(
                                  color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: AppConstants.spacing16),

            // ── Filtre thèmes — tuiles visuelles ──────────────
            SizedBox(
              height: 86,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _ThemeTile(
                    label: 'Tous',
                    emoji: '✨',
                    gradient: [AppColors.primary, AppColors.primaryLight],
                    selected: _selectedTheme == null,
                    onTap: () => setState(() => _selectedTheme = null),
                  ),
                  ...MeditationTheme.values.map((t) => _ThemeTile(
                        label: t.label,
                        emoji: t.emoji,
                        gradient: t.gradient,
                        selected: _selectedTheme == t,
                        onTap: () => setState(
                          () => _selectedTheme =
                              _selectedTheme == t ? null : t,
                        ),
                      )),
                ],
              ),
            ),

            const SizedBox(height: AppConstants.spacing16),

            // ── Filtre durées ──────────────────────────────────
            SizedBox(
              height: 34,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _DurationChip(
                    label: 'Toutes',
                    selected: _selectedDuration == null,
                    onTap: () => setState(() => _selectedDuration = null),
                  ),
                  for (final d in [3, 5, 7, 10])
                    _DurationChip(
                      label: '$d min',
                      selected: _selectedDuration == d,
                      onTap: () => setState(
                        () => _selectedDuration =
                            _selectedDuration == d ? null : d,
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: AppConstants.spacing32),

            // ── Résultats ──────────────────────────────────────
            Expanded(
              child: _filtered.isEmpty
                  ? _EmptyState()
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                      itemCount: _filtered.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppConstants.spacing16),
                      itemBuilder: (context, i) => _MeditationCard(
                        meditation: _filtered[i],
                        isPro: isPro,
                        onTap: () => _handleTap(_filtered[i], isPro),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  /// Gère le tap selon l'état de la méditation
  void _handleTap(Meditation meditation, bool isPro) {
    // Méditation Pro sans abonnement → paywall
    if (meditation.isPro && !isPro) {
      context.push('/paywall');
      return;
    }
    // Méditation gratuite mais pas encore disponible
    if (meditation.isComingSoon) {
      _showComingSoonSnackbar();
      return;
    }
    // Méditation disponible → player
    context.push('/wellness/meditation/player', extra: meditation);
  }

  void _showComingSoonSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Text('🎵', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Cette méditation arrive très bientôt !',
                style: AppTextStyles.bodyMedium(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

// ── Tuile thème — visuel gradient + emoji ────────────────────
class _ThemeTile extends StatelessWidget {
  final String label;
  final String emoji;
  final List<Color> gradient;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeTile({
    required this.label,
    required this.emoji,
    required this.gradient,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: AppConstants.animFast,
          width: 72,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: selected
                  ? gradient
                  : [
                      gradient[0].withValues(alpha: 0.25),
                      gradient[1].withValues(alpha: 0.25),
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: selected
                  ? gradient[1].withValues(alpha: 0.8)
                  : Colors.transparent,
              width: 1.5,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: gradient[1].withValues(alpha: 0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    )
                  ]
                : [],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 26)),
              const SizedBox(height: 5),
              Text(
                label,
                style: AppTextStyles.caption(
                  color: selected
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Chip durée ────────────────────────────────────────────────
class _DurationChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _DurationChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: AppConstants.animFast,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary
                : AppColors.surfaceDark,
            borderRadius: BorderRadius.circular(AppConstants.radiusPill),
            border: Border.all(
              color: selected
                  ? AppColors.primary
                  : AppColors.surfaceElevatedDark,
              width: 1.5,
            ),
          ),
          child: Text(
            label,
            style: AppTextStyles.caption(
              color: selected ? Colors.white : AppColors.textDarkMuted,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Carte méditation ──────────────────────────────────────────
class _MeditationCard extends StatelessWidget {
  final Meditation meditation;
  final bool isPro;
  final VoidCallback onTap;

  const _MeditationCard({
    required this.meditation,
    required this.isPro,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = meditation.theme;

    // La carte est "locked" si Pro sans abonnement
    final isLocked = meditation.isPro && !isPro;
    final isComingSoon = meditation.isComingSoon;

    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: isLocked ? 0.7 : 1.0,
        child: Container(
          constraints: const BoxConstraints(minHeight: 112),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
            border: Border.all(
              color: isLocked
                  ? AppColors.primary.withValues(alpha: 0.3)
                  : isDark
                      ? AppColors.surfaceElevatedDark
                      : AppColors.grey200,
            ),
          ),
          child: IntrinsicHeight(
            child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Illustration thème ──────────────────────────
              Container(
                width: 96,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isLocked
                        ? [
                            theme.gradient[0].withValues(alpha: 0.5),
                            theme.gradient[1].withValues(alpha: 0.5),
                          ]
                        : theme.gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppConstants.radiusLarge),
                    bottomLeft: Radius.circular(AppConstants.radiusLarge),
                  ),
                ),
                child: Center(
                  child: isLocked
                      ? const Icon(Icons.lock_rounded,
                          color: Colors.white, size: 28)
                      : Text(
                          theme.emoji,
                          style: const TextStyle(fontSize: 32),
                        ),
                ),
              ),

              // ── Contenu ─────────────────────────────────────
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Badges
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: theme.color.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              theme.label,
                              style:
                                  AppTextStyles.caption(color: theme.color),
                            ),
                          ),
                          const SizedBox(width: 6),
                          // Badge Pro ou Bientôt disponible
                          if (isLocked)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF6D28D9),
                                    Color(0xFF8B7FE8)
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '✨ Pro',
                                style: AppTextStyles.caption(
                                    color: Colors.white),
                              ),
                            )
                          else if (isComingSoon)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.chartAmber
                                    .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '🔜 Bientôt',
                                style: AppTextStyles.caption(
                                    color: AppColors.chartAmber),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        meditation.title,
                        style: AppTextStyles.headingSmall(
                          color: isDark
                              ? AppColors.textDark
                              : AppColors.textLight,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        meditation.description,
                        style:
                            AppTextStyles.caption(color: AppColors.grey400),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),

              // ── Durée + icône action ────────────────────────
              Padding(
                padding: const EdgeInsets.only(right: 14),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isLocked
                            ? AppColors.primary.withValues(alpha: 0.12)
                            : theme.color.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isLocked
                            ? Icons.workspace_premium_rounded
                            : isComingSoon
                                ? Icons.hourglass_top_rounded
                                : Icons.play_arrow_rounded,
                        color: isLocked
                            ? AppColors.primary
                            : isComingSoon
                                ? AppColors.chartAmber
                                : theme.color,
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      meditation.durationLabel,
                      style:
                          AppTextStyles.caption(color: AppColors.grey400),
                    ),
                  ],
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

// ── État vide ─────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🔍', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text(
            'Aucune méditation pour ce filtre',
            style: AppTextStyles.bodyMedium(color: AppColors.grey400),
          ),
          const SizedBox(height: 8),
          Text(
            'Essaie un autre thème ou une autre durée',
            style: AppTextStyles.caption(color: AppColors.grey400),
          ),
        ],
      ),
    );
  }
}
