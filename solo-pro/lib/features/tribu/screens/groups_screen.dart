import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../models/tribu_models.dart';
import '../widgets/post_card.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  late List<TribuGroup> _groups;
  TribuGroup? _openGroup;

  @override
  void initState() {
    super.initState();
    _groups = List.from(mockGroups);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_openGroup == null
            ? 'Groupes thématiques'
            : '${_openGroup!.emoji} ${_openGroup!.name}'),
        leading: _openGroup != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                onPressed: () => setState(() => _openGroup = null),
              )
            : null,
      ),
      body: _openGroup == null
          ? _buildGroupList()
          : _buildGroupDetail(_openGroup!),
    );
  }

  // ─── Liste des groupes ────────────────────────────────────────────────────

  Widget _buildGroupList() {
    final joined = _groups.where((g) => g.joined).toList();
    final explore = _groups.where((g) => !g.joined).toList();

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      children: [
        if (joined.isNotEmpty) ...[
          _sectionLabel('Mes groupes'),
          const SizedBox(height: 8),
          ...joined.map((g) => _buildGroupTile(g)),
          const SizedBox(height: 16),
        ],
        _sectionLabel('Explorer'),
        const SizedBox(height: 8),
        ...explore.map((g) => _buildGroupTile(g)),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _sectionLabel(String text) {
    return Text(text.toUpperCase(),
        style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
            letterSpacing: 0.8));
  }

  Widget _buildGroupTile(TribuGroup group) {
    return GestureDetector(
      onTap: () => setState(() => _openGroup = group),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: group.joined
              ? Border.all(
                  color: AppColors.primary.withValues(alpha: 0.25))
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(group.emoji,
                    style: const TextStyle(fontSize: 26)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(group.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14)),
                      if (group.joined) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppColors.primary
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('Rejoint',
                              style: TextStyle(
                                  fontSize: 9,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(group.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  Text('👥 ${group.memberCount} membres',
                      style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textLight)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios,
                size: 13,
                color: group.joined
                    ? AppColors.primary
                    : AppColors.textLight),
          ],
        ),
      ),
    );
  }

  // ─── Intérieur groupe ─────────────────────────────────────────────────────

  Widget _buildGroupDetail(TribuGroup group) {
    final mockGroupPosts = mockFeed.take(3).toList();

    return Column(
      children: [
        // Header groupe
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          color: AppColors.surface,
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(group.emoji,
                      style: const TextStyle(fontSize: 30)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(group.description,
                        style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            height: 1.4)),
                    const SizedBox(height: 6),
                    Text('👥 ${group.memberCount} membres',
                        style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textLight)),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Bouton rejoindre / quitter
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
          child: SizedBox(
            width: double.infinity,
            child: group.joined
                ? OutlinedButton(
                    onPressed: () => setState(() {
                      final idx = _groups.indexWhere(
                          (g) => g.id == group.id);
                      _groups[idx] = TribuGroup(
                        id: group.id,
                        name: group.name,
                        description: group.description,
                        emoji: group.emoji,
                        memberCount: group.memberCount - 1,
                        joined: false,
                      );
                      _openGroup = _groups[idx];
                    }),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                          color: AppColors.textLight),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Quitter le groupe',
                        style: TextStyle(
                            color: AppColors.textSecondary)),
                  )
                : ElevatedButton(
                    onPressed: () => setState(() {
                      final idx = _groups.indexWhere(
                          (g) => g.id == group.id);
                      _groups[idx] = TribuGroup(
                        id: group.id,
                        name: group.name,
                        description: group.description,
                        emoji: group.emoji,
                        memberCount: group.memberCount + 1,
                        joined: true,
                      );
                      _openGroup = _groups[idx];
                    }),
                    child: Text(
                        'Rejoindre ${group.emoji} ${group.name}'),
                  ),
          ),
        ),

        const SizedBox(height: 14),

        // Posts du groupe
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: mockGroupPosts.length,
            separatorBuilder: (_, __) => const SizedBox.shrink(),
            itemBuilder: (_, i) => PostCard(post: mockGroupPosts[i]),
          ),
        ),
      ],
    );
  }
}
