import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_routes.dart';
import '../models/tribu_models.dart';
import '../widgets/post_card.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  late List<TribuPost> _posts;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _posts = List.from(mockFeed);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          _buildSliverHeader(),
        ],
        body: TabBarView(
          controller: _tabCtrl,
          children: [
            _buildFeedTab(),
            _buildMembersTab(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showNewPostSheet(),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.edit_outlined, color: Colors.white),
        label: const Text('Partager',
            style:
                TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }

  // ─── Sliver header ────────────────────────────────────────────────────────

  Widget _buildSliverHeader() {
    return SliverAppBar(
      floating: true,
      snap: true,
      backgroundColor: AppColors.background,
      title: const Text('Ma Tribu 👥',
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary)),
      actions: [
        IconButton(
          icon: const Icon(Icons.group_outlined,
              color: AppColors.textPrimary, size: 22),
          onPressed: () =>
              Navigator.pushNamed(context, AppRoutes.tribuGroups),
          tooltip: 'Groupes',
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(52),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(14),
            ),
            child: TabBar(
              controller: _tabCtrl,
              indicator: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 4),
                ],
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              labelStyle: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w700),
              tabs: const [
                Tab(text: '💬 Feed'),
                Tab(text: '👥 Membres'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Tab Feed ─────────────────────────────────────────────────────────────

  Widget _buildFeedTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      children: [
        _buildOnlineMembersRow(),
        const SizedBox(height: 16),
        ..._posts.map((post) => PostCard(
              post: post,
              onAuthorTap: () => Navigator.pushNamed(
                context,
                AppRoutes.memberProfile,
                arguments: post.author,
              ),
            )),
      ],
    );
  }

  // ─── Membres en ligne ─────────────────────────────────────────────────────

  Widget _buildOnlineMembersRow() {
    final online =
        mockMembers.where((m) => m.isOnline).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.accentGreen,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text('${online.length} membres en ligne',
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary)),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 64,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: online.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, i) {
              final m = online[i];
              return GestureDetector(
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRoutes.memberProfile,
                  arguments: m,
                ),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: Text(m.emoji,
                                style: const TextStyle(fontSize: 22)),
                          ),
                        ),
                        Positioned(
                          right: 2,
                          bottom: 2,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: AppColors.accentGreen,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: AppColors.background,
                                  width: 1.5),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(m.prenom,
                        style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.textSecondary)),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ─── Tab Membres ──────────────────────────────────────────────────────────

  Widget _buildMembersTab() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: mockMembers.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final m = mockMembers[i];
        return GestureDetector(
          onTap: () => Navigator.pushNamed(
            context,
            AppRoutes.memberProfile,
            arguments: m,
          ),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Stack(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text(m.emoji,
                            style: const TextStyle(fontSize: 24)),
                      ),
                    ),
                    if (m.isOnline)
                      Positioned(
                        right: 2,
                        bottom: 2,
                        child: Container(
                          width: 11,
                          height: 11,
                          decoration: BoxDecoration(
                            color: AppColors.accentGreen,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: AppColors.surface, width: 1.5),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(m.prenom,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14)),
                          const SizedBox(width: 6),
                          if (m.isFriend)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: AppColors.primary
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text('Ami',
                                  style: TextStyle(
                                      fontSize: 9,
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w700)),
                            ),
                        ],
                      ),
                      Text(m.metier,
                          style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('🔥 ${m.streak}j',
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.accent)),
                    Text('Niv. ${m.level}',
                        style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─── Nouveau post ─────────────────────────────────────────────────────────

  void _showNewPostSheet() {
    final ctrl = TextEditingController();
    PostType selectedType = PostType.text;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                          color: AppColors.textLight,
                          borderRadius: BorderRadius.circular(2))),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(12)),
                      child: Center(
                          child: Text(me.emoji,
                              style: const TextStyle(fontSize: 20))),
                    ),
                    const SizedBox(width: 10),
                    const Text('Partager avec la Tribu',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: 16),
                // Sélecteur type
                Row(
                  children: PostType.values.map((t) {
                    final isSelected = selectedType == t;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () =>
                            setModal(() => selectedType = t),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          margin: const EdgeInsets.symmetric(
                              horizontal: 3),
                          padding: const EdgeInsets.symmetric(
                              vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                    .withValues(alpha: 0.1)
                                : AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(10),
                            border: isSelected
                                ? Border.all(
                                    color: AppColors.primary,
                                    width: 1.5)
                                : null,
                          ),
                          child: Column(
                            children: [
                              Text(t.emoji,
                                  style:
                                      const TextStyle(fontSize: 16)),
                              Text(t.label,
                                  style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppColors.textSecondary)),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: ctrl,
                  maxLines: 4,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Partage une victoire, une astuce, une question...',
                    hintStyle: const TextStyle(fontSize: 13),
                    filled: true,
                    fillColor: AppColors.surfaceVariant,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      final text = ctrl.text.trim();
                      if (text.isEmpty) return;
                      setState(() {
                        _posts.insert(
                          0,
                          TribuPost(
                            id: DateTime.now()
                                .millisecondsSinceEpoch
                                .toString(),
                            author: me,
                            content: text,
                            type: selectedType,
                            createdAt: DateTime.now(),
                          ),
                        );
                      });
                      Navigator.pop(ctx);
                    },
                    child: const Text('Publier',
                        style: TextStyle(fontWeight: FontWeight.w700)),
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
