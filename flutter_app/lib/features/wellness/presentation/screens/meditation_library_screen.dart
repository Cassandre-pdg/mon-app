import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/constants/app_constants.dart';
import '../../data/models/meditation.dart';

class MeditationLibraryScreen extends StatefulWidget {
  const MeditationLibraryScreen({super.key});

  @override
  State<MeditationLibraryScreen> createState() => _MeditationLibraryScreenState();
}

class _MeditationLibraryScreenState extends State<MeditationLibraryScreen> {
  MeditationTheme? _selectedTheme;
  int? _selectedDuration; // null = tous, sinon minutes exactes

  List<Meditation> get _filtered {
    return Meditation.catalog.where((m) {
      final themeOk = _selectedTheme == null || m.theme == _selectedTheme;
      final durOk = _selectedDuration == null || m.durationMinutes == _selectedDuration;
      return themeOk && durOk;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;

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
                      backgroundColor: isDark
                          ? AppColors.surfaceDark
                          : AppColors.surfaceLight,
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
                ],
              ),
            ),

            const SizedBox(height: AppConstants.spacing16),

            // ── Filtre thèmes ──────────────────────────────────
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _ThemeChip(
                    label: 'Tous',
                    emoji: '✨',
                    selected: _selectedTheme == null,
                    onTap: () => setState(() => _selectedTheme = null),
                  ),
                  ...MeditationTheme.values.map((t) => _ThemeChip(
                    label: t.label,
                    emoji: t.emoji,
                    selected: _selectedTheme == t,
                    onTap: () => setState(
                      () => _selectedTheme = _selectedTheme == t ? null : t,
                    ),
                    color: t.color,
                  )),
                ],
              ),
            ),

            const SizedBox(height: AppConstants.spacing12),

            // ── Filtre durées ──────────────────────────────────
            SizedBox(
              height: 36,
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
                        () => _selectedDuration = _selectedDuration == d ? null : d,
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: AppConstants.spacing16),

            // ── Résultats ──────────────────────────────────────
            Expanded(
              child: _filtered.isEmpty
                  ? _EmptyState()
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      itemCount: _filtered.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppConstants.spacing12),
                      itemBuilder: (context, i) =>
                          _MeditationCard(meditation: _filtered[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Chip thème ───────────────────────────────────────────────
class _ThemeChip extends StatelessWidget {
  final String label;
  final String emoji;
  final bool selected;
  final VoidCallback onTap;
  final Color? color;

  const _ThemeChip({
    required this.label,
    required this.emoji,
    required this.selected,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.primary;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: AppConstants.animFast,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? c.withValues(alpha: 0.18) : Colors.transparent,
            borderRadius: BorderRadius.circular(AppConstants.radiusPill),
            border: Border.all(
              color: selected ? c : AppColors.grey200,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Text(
            '$emoji $label',
            style: AppTextStyles.labelMedium(
              color: selected ? c : AppColors.grey400,
            ),
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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppConstants.radiusPill),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.grey200,
            ),
          ),
          child: Text(
            label,
            style: AppTextStyles.caption(
              color: selected ? AppColors.primary : AppColors.grey400,
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
  const _MeditationCard({required this.meditation});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = meditation.theme;

    return GestureDetector(
      onTap: () => context.push(
        '/wellness/meditation/player',
        extra: meditation,
      ),
      child: Container(
        constraints: const BoxConstraints(minHeight: 100),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
          border: Border.all(
            color: isDark
                ? AppColors.surfaceElevatedDark
                : AppColors.grey200,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Illustration thème ──────────────────────────
            Container(
              width: 90,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: theme.gradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppConstants.radiusLarge),
                  bottomLeft: Radius.circular(AppConstants.radiusLarge),
                ),
              ),
              child: Center(
                child: Text(
                  theme.emoji,
                  style: const TextStyle(fontSize: 32),
                ),
              ),
            ),

            // ── Contenu ─────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Pill thème
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
                        style: AppTextStyles.caption(color: theme.color),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      meditation.title,
                      style: AppTextStyles.headingSmall(
                        color: isDark ? AppColors.textDark : AppColors.textLight,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      meditation.description,
                      style: AppTextStyles.caption(color: AppColors.grey400),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),

            // ── Durée + play ────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(right: 14),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: theme.color.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.play_arrow_rounded,
                      color: theme.color,
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    meditation.durationLabel,
                    style: AppTextStyles.caption(color: AppColors.grey400),
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
