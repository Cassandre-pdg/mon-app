import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_routes.dart';
import '../models/profile_model.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = mockProfile;
    final level = userLevel(p.totalCheckins);
    final xp = xpCurrent(p.totalCheckins);
    final unlockedUserBadges = p.badges.where((b) => b.unlocked).toList();
    final lockedUserBadges = p.badges.where((b) => !b.unlocked).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildSliverHeader(context, p, level, xp),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 20),
                _buildStatsGrid(p),
                const SizedBox(height: 24),
                _buildStreakSection(p),
                const SizedBox(height: 24),
                _buildUserBadgesSection(
                    context, unlockedUserBadges, lockedUserBadges),
                const SizedBox(height: 24),
                _buildObjectifSection(p),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Sliver header ────────────────────────────────────────────────────────

  Widget _buildSliverHeader(
      BuildContext context, UserProfile p, int level, int xp) {
    return SliverAppBar(
      expandedHeight: 260,
      pinned: true,
      backgroundColor: AppColors.primary,
      actions: [
        IconButton(
          icon: const Icon(Icons.settings_outlined,
              color: Colors.white, size: 22),
          onPressed: () =>
              Navigator.pushNamed(context, AppRoutes.settings),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF3D35CC), Color(0xFF6C63FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Avatar
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.4),
                          width: 2),
                    ),
                    child: Center(
                      child: Text(p.emoji,
                          style: const TextStyle(fontSize: 40)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(p.prenom,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(height: 2),
                  Text(p.metier,
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 12),
                  // Niveau + XP bar
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Niv. $level · ${levelTitle(level)}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('$xp/${xpNeeded()} XP',
                                style: const TextStyle(
                                    color: Colors.white60,
                                    fontSize: 10)),
                            const SizedBox(height: 3),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: xp / xpNeeded(),
                                minHeight: 6,
                                backgroundColor:
                                    Colors.white.withValues(alpha: 0.2),
                                valueColor:
                                    const AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── Grille stats ─────────────────────────────────────────────────────────

  Widget _buildStatsGrid(UserProfile p) {
    final stats = [
      _StatItem('🔥', '${p.streak}j', 'Streak actuel',
          AppColors.accent),
      _StatItem('⚡', p.avgEnergyScore.toStringAsFixed(1),
          'Énergie moy.', AppColors.primary),
      _StatItem('✅', '${p.totalCheckins}', 'Check-ins',
          AppColors.accentGreen),
      _StatItem('🍅', '${p.totalPomodoros}', 'Pomodoros',
          const Color(0xFFFF9F1C)),
      _StatItem('😴', '${p.avgSleepHours}h', 'Sommeil moy.',
          const Color(0xFF3D35CC)),
      _StatItem('🏅', '${p.longestStreak}j', 'Record streak',
          AppColors.accentYellow),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.1,
      ),
      itemCount: stats.length,
      itemBuilder: (_, i) {
        final s = stats[i];
        return Container(
          decoration: BoxDecoration(
            color: s.color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: s.color.withValues(alpha: 0.2)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(s.emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(height: 4),
              Text(s.value,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: s.color)),
              Text(s.label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 10, color: AppColors.textSecondary)),
            ],
          ),
        );
      },
    );
  }

  // ─── Streak visuel ────────────────────────────────────────────────────────

  Widget _buildStreakSection(UserProfile p) {
    // 7 derniers jours mock
    final days = [true, true, true, false, true, true, true];
    const dayLabels = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
    final todayIdx = DateTime.now().weekday - 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Streak de la semaine',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '🔥 ${p.streak} jours',
                style: const TextStyle(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w700,
                    fontSize: 12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (i) {
              final done = days[i];
              final isToday = i == todayIdx;
              return Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: done
                          ? AppColors.accent
                          : isToday
                              ? AppColors.accent.withValues(alpha: 0.15)
                              : AppColors.surfaceVariant,
                      shape: BoxShape.circle,
                      border: isToday
                          ? Border.all(
                              color: AppColors.accent, width: 2)
                          : null,
                    ),
                    child: Center(
                      child: done
                          ? const Text('🔥',
                              style: TextStyle(fontSize: 16))
                          : isToday
                              ? const Icon(Icons.access_time,
                                  size: 14,
                                  color: AppColors.accent)
                              : const Icon(Icons.close,
                                  size: 14,
                                  color: AppColors.textLight),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    dayLabels[i],
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: isToday
                          ? FontWeight.w800
                          : FontWeight.w500,
                      color: isToday
                          ? AppColors.accent
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }

  // ─── UserBadges ───────────────────────────────────────────────────────────────

  Widget _buildUserBadgesSection(BuildContext context,
      List<UserBadge> unlocked, List<UserBadge> locked) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Mes badges',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            Text(
              '${unlocked.length}/${unlocked.length + locked.length} débloqués',
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // UserBadges débloqués
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            ...unlocked.map((b) => _UserBadgeTile(badge: b)),
            ...locked.map((b) => _UserBadgeTile(badge: b)),
          ],
        ),
      ],
    );
  }

  // ─── Objectif ─────────────────────────────────────────────────────────────

  Widget _buildObjectifSection(UserProfile p) {
    final daysSince =
        DateTime.now().difference(p.memberSince).inDays;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.08),
            AppColors.primaryLight.withValues(alpha: 0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🎯',
                  style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              const Text('Mon objectif',
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: AppColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 8),
          Text(p.objectif,
              style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Row(
            children: [
              _InfoChip('📅', 'Membre depuis $daysSince jours'),
              const SizedBox(width: 8),
              _InfoChip('💼', p.metier),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Widgets locaux ───────────────────────────────────────────────────────────

class _StatItem {
  final String emoji;
  final String value;
  final String label;
  final Color color;

  const _StatItem(this.emoji, this.value, this.label, this.color);
}

class _UserBadgeTile extends StatelessWidget {
  final UserBadge badge;

  const _UserBadgeTile({required this.badge});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showUserBadgeDetail(context),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 72,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        decoration: BoxDecoration(
          color: badge.unlocked
              ? badge.color.withValues(alpha: 0.1)
              : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: badge.unlocked
                ? badge.color.withValues(alpha: 0.3)
                : Colors.transparent,
          ),
        ),
        child: Column(
          children: [
            ColorFiltered(
              colorFilter: badge.unlocked
                  ? const ColorFilter.mode(
                      Colors.transparent, BlendMode.multiply)
                  : const ColorFilter.matrix([
                      0.2, 0.2, 0.2, 0, 0,
                      0.2, 0.2, 0.2, 0, 0,
                      0.2, 0.2, 0.2, 0, 0,
                      0,   0,   0,   1, 0,
                    ]),
              child: Text(badge.emoji,
                  style: TextStyle(
                      fontSize: badge.unlocked ? 28 : 24)),
            ),
            const SizedBox(height: 4),
            Text(
              badge.title,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: badge.unlocked
                    ? badge.color
                    : AppColors.textLight,
              ),
            ),
            if (!badge.unlocked)
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: Icon(Icons.lock_outline,
                    size: 10, color: AppColors.textLight),
              ),
          ],
        ),
      ),
    );
  }

  void _showUserBadgeDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                    color: AppColors.textLight,
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: badge.unlocked
                    ? badge.color.withValues(alpha: 0.12)
                    : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                  child: Text(badge.emoji,
                      style: const TextStyle(fontSize: 36))),
            ),
            const SizedBox(height: 16),
            Text(badge.title,
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text(badge.description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 14)),
            const SizedBox(height: 12),
            if (badge.unlocked && badge.unlockedAt != null)
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: badge.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '✅ Débloqué le ${badge.unlockedAt!.day}/${badge.unlockedAt!.month}/${badge.unlockedAt!.year}',
                  style: TextStyle(
                      color: badge.color,
                      fontWeight: FontWeight.w600,
                      fontSize: 12),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('🔒 Pas encore débloqué',
                    style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12)),
              ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String emoji;
  final String label;

  const _InfoChip(this.emoji, this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 5),
          Text(label,
              style: const TextStyle(
                  fontSize: 11, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
