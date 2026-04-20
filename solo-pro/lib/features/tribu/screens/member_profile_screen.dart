import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';
import '../models/tribu_models.dart';
import '../widgets/post_card.dart';

class MemberProfileScreen extends StatefulWidget {
  const MemberProfileScreen({super.key});

  @override
  State<MemberProfileScreen> createState() => _MemberProfileScreenState();
}

class _MemberProfileScreenState extends State<MemberProfileScreen> {
  late TribuMember _member;
  bool _initialized = false;
  bool _requestSent = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final arg = ModalRoute.of(context)?.settings.arguments;
      _member = (arg is TribuMember) ? arg : mockMembers.first;
      _requestSent = _member.hasPendingRequest;
      _initialized = true;
    }
  }

  List<TribuPost> get _memberPosts =>
      mockFeed.where((p) => p.author.id == _member.id).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildSliverHeader(),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 20),
                _buildActionButtons(),
                const SizedBox(height: 20),
                _buildStatsRow(),
                if (_member.bio != null) ...[
                  const SizedBox(height: 20),
                  _buildBio(),
                ],
                const SizedBox(height: 20),
                _buildPostsSection(),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Sliver header ────────────────────────────────────────────────────────

  Widget _buildSliverHeader() {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      backgroundColor: AppColors.primary,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new,
            color: Colors.white, size: 18),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF3D35CC), Color(0xFF9C94FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                // Avatar
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
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
                        child: Text(_member.emoji,
                            style: const TextStyle(fontSize: 40)),
                      ),
                    ),
                    if (_member.isOnline)
                      Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: AppColors.accentGreen,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Colors.white, width: 2),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(_member.prenom,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(_member.metier,
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _HeaderChip('🔥 ${_member.streak}j'),
                    const SizedBox(width: 8),
                    _HeaderChip('Niv. ${_member.level}'),
                    if (_member.isOnline) ...[
                      const SizedBox(width: 8),
                      _HeaderChip('🟢 En ligne'),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Boutons action ───────────────────────────────────────────────────────

  Widget _buildActionButtons() {
    if (_member.isFriend) {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.chat_outlined, size: 16),
              label: const Text('Message'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(width: 10),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.person_remove_outlined,
                size: 16, color: AppColors.textSecondary),
            label: const Text('Retirer',
                style: TextStyle(color: AppColors.textSecondary)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.textLight),
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      );
    }

    return SizedBox(
      width: double.infinity,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _requestSent
            ? OutlinedButton.icon(
                key: const ValueKey('pending'),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  setState(() => _requestSent = false);
                },
                icon: const Icon(Icons.access_time,
                    size: 16, color: AppColors.textSecondary),
                label: const Text('Demande envoyée',
                    style: TextStyle(color: AppColors.textSecondary)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.textLight),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              )
            : ElevatedButton.icon(
                key: const ValueKey('add'),
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  setState(() => _requestSent = true);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          '✅ Demande envoyée à ${_member.prenom} !'),
                      backgroundColor: AppColors.accentGreen,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                },
                icon: const Icon(Icons.person_add_outlined, size: 16),
                label: Text(
                    'Ajouter ${_member.prenom} à mes amis'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
      ),
    );
  }

  // ─── Stats ────────────────────────────────────────────────────────────────

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _StatBox(
              emoji: '🔥',
              value: '${_member.streak}j',
              label: 'Streak',
              color: AppColors.accent),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatBox(
              emoji: '⭐',
              value: 'Niv. ${_member.level}',
              label: 'Niveau',
              color: AppColors.primary),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatBox(
              emoji: '📝',
              value: '${_memberPosts.length}',
              label: 'Posts',
              color: AppColors.accentGreen),
        ),
      ],
    );
  }

  // ─── Bio ──────────────────────────────────────────────────────────────────

  Widget _buildBio() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('À propos',
              style: TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 13)),
          const SizedBox(height: 8),
          Text(_member.bio!,
              style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  height: 1.5)),
        ],
      ),
    );
  }

  // ─── Posts du membre ──────────────────────────────────────────────────────

  Widget _buildPostsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Posts de ${_member.prenom}',
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary)),
        const SizedBox(height: 12),
        if (_memberPosts.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Text('Aucun post pour l\'instant',
                  style: TextStyle(color: AppColors.textSecondary)),
            ),
          )
        else
          ..._memberPosts.map((p) => PostCard(post: p)),
      ],
    );
  }
}

class _HeaderChip extends StatelessWidget {
  final String label;

  const _HeaderChip(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600)),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;
  final Color color;

  const _StatBox({
    required this.emoji,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: color)),
          Text(label,
              style: const TextStyle(
                  fontSize: 10, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
