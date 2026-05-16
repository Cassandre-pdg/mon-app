import 'dart:ui';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/constants/app_constants.dart';
import '../../../../shared/widgets/aurora_background.dart';
import '../../../../shared/widgets/kolyb_loader.dart';
import '../../../../shared/widgets/project_config_sheet.dart';
import '../../data/kanban_model.dart';
import '../providers/kanban_provider.dart';

class KanbanScreen extends ConsumerStatefulWidget {
  const KanbanScreen({super.key});

  @override
  ConsumerState<KanbanScreen> createState() => _KanbanScreenState();
}

class _KanbanScreenState extends ConsumerState<KanbanScreen> {
  String? _selectedProjectId;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final kanbanAsync = ref.watch(kanbanProvider);

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: AuroraBackgroundPaint(
        orb1Color: AppColors.auroraViolet,
        orb2Color: AppColors.chartViolet.withValues(alpha: 0.25),
        orb3Color: AppColors.auroraTeal,
        baseColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _AppBarRow(
                isDark: isDark,
                onAdd: () => _showAddProjectSheet(context),
              ),
              Expanded(
                child: kanbanAsync.when(
                  loading: () => const KolybLoaderScreen(),
                  error: (e, _) => _ErrorState(
                    onRetry: () => ref.invalidate(kanbanProvider),
                  ),
                  data: (projects) {
                    if (_selectedProjectId == null && projects.isNotEmpty) {
                      _selectedProjectId = projects.first.id;
                    }
                    if (projects.isNotEmpty &&
                        !projects.any((p) => p.id == _selectedProjectId)) {
                      _selectedProjectId = projects.first.id;
                    }

                    if (projects.isEmpty) {
                      return _EmptyKanban(
                          onAdd: () => _showAddProjectSheet(context));
                    }

                    final selected = projects
                        .where((p) => p.id == _selectedProjectId)
                        .firstOrNull;

                    return Column(
                      children: [
                        // Sélecteur projets (pills)
                        _ProjectSelector(
                          projects: projects,
                          selectedId: _selectedProjectId,
                          isDark: isDark,
                          onSelect: (id) =>
                              setState(() => _selectedProjectId = id),
                          onLongPress: (p) =>
                              _showProjectOptions(context, p),
                        ),

                        // Fiche projet enrichie
                        if (selected != null)
                          _ProjectHeader(
                            project: selected,
                            isDark: isDark,
                            onFocusTap: () => _toggleFocus(selected),
                            onEditTap: () =>
                                _showEditProjectSheet(context, selected),
                          ),

                        // Board Kanban
                        if (selected != null)
                          Expanded(
                            child: _KanbanBoard(
                              project: selected,
                              isDark: isDark,
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleFocus(KanbanProject project) {
    if (project.isFocusProject) {
      ref.read(kanbanProvider.notifier).clearFocusProject();
    } else {
      ref.read(kanbanProvider.notifier).setFocusProject(project.id);
    }
  }

  // ── Sheets & dialogs ─────────────────────────────────────────

  void _showAddProjectSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ProjectConfigSheet(
        onCreated: (id) => setState(() => _selectedProjectId = id),
      ),
    );
  }

  void _showEditProjectSheet(BuildContext context, KanbanProject project) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ProjectConfigSheet(project: project),
    );
  }

  void _showProjectOptions(BuildContext context, KanbanProject project) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.backgroundLight,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 36, height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.grey400.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(project.name,
                  style: AppTextStyles.headingSmall(
                    color: isDark ? AppColors.textDark : AppColors.textLight,
                  )),
              const SizedBox(height: 20),
              _OptionTile(
                icon: project.isFocusProject
                    ? Icons.star_rounded
                    : Icons.star_outline_rounded,
                label: project.isFocusProject
                    ? 'Retirer du focus'
                    : 'Définir comme projet du moment',
                color: AppColors.warning,
                onTap: () {
                  Navigator.pop(ctx);
                  _toggleFocus(project);
                },
              ),
              _OptionTile(
                icon: Icons.edit_rounded,
                label: 'Modifier le projet',
                color: AppColors.primaryLight,
                onTap: () {
                  Navigator.pop(ctx);
                  _showEditProjectSheet(context, project);
                },
              ),
              _OptionTile(
                icon: project.projectStatus == ProjectStatus.paused
                    ? Icons.play_arrow_rounded
                    : Icons.pause_rounded,
                label: project.projectStatus == ProjectStatus.paused
                    ? 'Reprendre le projet'
                    : 'Mettre en pause',
                color: AppColors.accent,
                onTap: () {
                  Navigator.pop(ctx);
                  ref.read(kanbanProvider.notifier).updateProject(
                    projectId: project.id,
                    projectStatus: project.projectStatus == ProjectStatus.paused
                        ? ProjectStatus.active
                        : ProjectStatus.paused,
                  );
                },
              ),
              _OptionTile(
                icon: Icons.archive_rounded,
                label: 'Marquer comme terminé',
                color: AppColors.success,
                onTap: () {
                  Navigator.pop(ctx);
                  ref.read(kanbanProvider.notifier).updateProject(
                    projectId: project.id,
                    projectStatus: ProjectStatus.done,
                  );
                  setState(() => _selectedProjectId = null);
                },
              ),
              _OptionTile(
                icon: Icons.delete_outline_rounded,
                label: 'Supprimer définitivement',
                color: AppColors.error,
                onTap: () {
                  Navigator.pop(ctx);
                  _confirmDelete(context, project);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, KanbanProject project) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor:
            isDark ? AppColors.surfaceDark : AppColors.backgroundLight,
        title: Text('Supprimer ce projet ?',
            style: AppTextStyles.headingSmall(
              color: isDark ? AppColors.textDark : AppColors.textLight,
            )),
        content: Text(
            '"${project.name}" et toutes ses tâches seront supprimés.',
            style: AppTextStyles.bodyMedium(color: AppColors.grey400)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Annuler')),
          TextButton(
            onPressed: () {
              ref.read(kanbanProvider.notifier).deleteProject(project.id);
              Navigator.pop(ctx);
            },
            child: const Text('Supprimer',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

// ── AppBar ────────────────────────────────────────────────────
class _AppBarRow extends StatelessWidget {
  const _AppBarRow({required this.isDark, required this.onAdd});
  final bool isDark;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded,
                size: 20,
                color: isDark ? AppColors.textDark : AppColors.textLight),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text('Mes Projets',
                style: AppTextStyles.headingMedium(
                  color: isDark ? AppColors.textDark : AppColors.textLight,
                )),
          ),
          GestureDetector(
            onTap: onAdd,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius:
                    BorderRadius.circular(AppConstants.radiusPill),
                border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add_rounded,
                      color: AppColors.primaryLight, size: 16),
                  const SizedBox(width: 4),
                  Text('Projet',
                      style:
                          AppTextStyles.labelSmall(color: AppColors.primaryLight)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sélecteur de projets ──────────────────────────────────────
class _ProjectSelector extends StatelessWidget {
  const _ProjectSelector({
    required this.projects,
    required this.selectedId,
    required this.isDark,
    required this.onSelect,
    required this.onLongPress,
  });
  final List<KanbanProject> projects;
  final String? selectedId;
  final bool isDark;
  final void Function(String) onSelect;
  final void Function(KanbanProject) onLongPress;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: projects.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final p = projects[i];
          final isActive = p.id == selectedId;
          return GestureDetector(
            onTap: () => onSelect(p.id),
            onLongPress: () => onLongPress(p),
            child: AnimatedContainer(
              duration: AppConstants.animFast,
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.primary
                    : isDark
                        ? AppColors.surfaceDark.withValues(alpha: 0.80)
                        : AppColors.surfaceLight,
                border: Border.all(
                  color: isActive
                      ? AppColors.primary
                      : AppColors.grey200.withValues(alpha: 0.4),
                ),
                borderRadius:
                    BorderRadius.circular(AppConstants.radiusPill),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (p.isFocusProject) ...[
                    const Icon(Icons.star_rounded,
                        color: AppColors.warning, size: 13),
                    const SizedBox(width: 4),
                  ],
                  if (p.projectStatus == ProjectStatus.paused)
                    const Icon(Icons.pause_circle_outline_rounded,
                        color: AppColors.grey400, size: 13),
                  Text(
                    p.name,
                    style: AppTextStyles.labelMedium(
                      color: isActive
                          ? Colors.white
                          : isDark
                              ? AppColors.textDarkMuted
                              : AppColors.textLight,
                    ),
                  ),
                  if (p.inProgressCount > 0) ...[
                    const SizedBox(width: 6),
                    Container(
                      width: 18, height: 18,
                      decoration: BoxDecoration(
                        color: isActive
                            ? Colors.white.withValues(alpha: 0.25)
                            : AppColors.warning.withValues(alpha: 0.20),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${p.inProgressCount}',
                          style: AppTextStyles.caption(
                            color: isActive
                                ? Colors.white
                                : AppColors.warning,
                          ).copyWith(fontSize: 9),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Fiche projet enrichie ─────────────────────────────────────
class _ProjectHeader extends StatelessWidget {
  const _ProjectHeader({
    required this.project,
    required this.isDark,
    required this.onFocusTap,
    required this.onEditTap,
  });
  final KanbanProject project;
  final bool isDark;
  final VoidCallback onFocusTap;
  final VoidCallback onEditTap;

  @override
  Widget build(BuildContext context) {
    final pct = project.progressPercent;
    final daysLeft = project.daysLeft;
    final isOverdue = project.isOverdue;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.surfaceDark.withValues(alpha: 0.75)
                  : AppColors.surfaceLight.withValues(alpha: 0.85),
              borderRadius:
                  BorderRadius.circular(AppConstants.radiusLarge),
              border: Border.all(
                color: project.isFocusProject
                    ? AppColors.warning.withValues(alpha: 0.4)
                    : isDark
                        ? AppColors.glassBorder
                        : AppColors.grey200,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Ligne titre + actions ──
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          if (project.isFocusProject) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.warning
                                    .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.star_rounded,
                                      color: AppColors.warning, size: 12),
                                  const SizedBox(width: 4),
                                  Text('Focus',
                                      style: AppTextStyles.caption(
                                          color: AppColors.warning)),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Flexible(
                            child: Text(
                              project.name,
                              style: AppTextStyles.headingSmall(
                                color: isDark
                                    ? AppColors.textDark
                                    : AppColors.textLight,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: onFocusTap,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Icon(
                          project.isFocusProject
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          color: project.isFocusProject
                              ? AppColors.warning
                              : AppColors.grey400,
                          size: 22,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: onEditTap,
                      child: const Padding(
                        padding: EdgeInsets.only(left: 4),
                        child: Icon(Icons.edit_outlined,
                            color: AppColors.grey400, size: 18),
                      ),
                    ),
                  ],
                ),

                // ── WHY ──
                if (project.why != null && project.why!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('💡 ',
                          style: TextStyle(fontSize: 13)),
                      Expanded(
                        child: Text(
                          project.why!,
                          style: AppTextStyles.bodyMedium(
                            color: isDark
                                ? AppColors.primaryPale
                                : AppColors.primary,
                          ).copyWith(
                            fontStyle: FontStyle.italic,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 12),

                // ── Ligne date + stats ──
                Row(
                  children: [
                    if (daysLeft != null) ...[
                      _DateChip(
                          daysLeft: daysLeft,
                          isOverdue: isOverdue,
                          targetDate: project.targetDate!),
                      const SizedBox(width: 8),
                    ],
                    _StatChip(
                        label: '${project.todoCount} à faire',
                        color: AppColors.grey400),
                    const SizedBox(width: 6),
                    _StatChip(
                        label: '${project.inProgressCount} en cours',
                        color: AppColors.warning),
                    const SizedBox(width: 6),
                    _StatChip(
                        label: '${project.doneCount} ✓',
                        color: AppColors.success),
                  ],
                ),

                const SizedBox(height: 14),

                // ── Graphique donut + barre progression ──
                Row(
                  children: [
                    // Donut
                    if (project.tasks.isNotEmpty)
                      _ProjectDonut(project: project),
                    if (project.tasks.isNotEmpty)
                      const SizedBox(width: 16),
                    // Barre progression
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text(project.progressLabel,
                                  style: AppTextStyles.labelSmall(
                                    color: isDark
                                        ? AppColors.textDarkMuted
                                        : AppColors.grey600,
                                  )),
                              Text(
                                '${(pct * 100).round()}%',
                                style: AppTextStyles.labelSmall(
                                    color: AppColors.primaryLight),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Stack(
                            children: [
                              Container(
                                height: 6,
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppColors.grey800
                                      : AppColors.grey200,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                              AnimatedFractionallySizedBox(
                                duration:
                                    const Duration(milliseconds: 600),
                                curve: Curves.easeOutCubic,
                                widthFactor: pct,
                                child: Container(
                                  height: 6,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        AppColors.primary,
                                        AppColors.primaryLight,
                                      ],
                                    ),
                                    borderRadius:
                                        BorderRadius.circular(3),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primary
                                            .withValues(alpha: 0.4),
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
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
    );
  }
}

// ── Graphique donut (fl_chart) ────────────────────────────────
class _ProjectDonut extends StatefulWidget {
  const _ProjectDonut({required this.project});
  final KanbanProject project;

  @override
  State<_ProjectDonut> createState() => _ProjectDonutState();
}

class _ProjectDonutState extends State<_ProjectDonut>
    with TickerProviderStateMixin {
  late final AnimationController _sweepCtrl;
  late final Animation<double> _sweepAnim;
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _sweepCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _sweepAnim = CurvedAnimation(
      parent: _sweepCtrl,
      curve: Curves.easeOutCubic,
    );
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
    _sweepCtrl.forward().then((_) {
      if (widget.project.progressPercent >= 1.0 && mounted) {
        _pulseCtrl.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _sweepCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.project.tasks.isEmpty) return const SizedBox.shrink();
    final isComplete = widget.project.progressPercent >= 1.0;

    return AnimatedBuilder(
      animation: Listenable.merge([_sweepAnim, _pulseAnim]),
      builder: (_, __) {
        final t = _sweepAnim.value;
        final scale = isComplete ? _pulseAnim.value : 1.0;

        final List<PieChartSectionData> sections;
        if (t < 0.01) {
          sections = [
            PieChartSectionData(
              value: 1,
              color: AppColors.grey400.withValues(alpha: 0.2),
              radius: 12,
              showTitle: false,
            ),
          ];
        } else {
          sections = [
            if (widget.project.doneCount > 0)
              PieChartSectionData(
                value: widget.project.doneCount.toDouble() * t,
                color: AppColors.success,
                radius: 12,
                showTitle: false,
              ),
            if (widget.project.inProgressCount > 0)
              PieChartSectionData(
                value: widget.project.inProgressCount.toDouble() * t,
                color: AppColors.warning,
                radius: 12,
                showTitle: false,
              ),
            if (widget.project.todoCount > 0)
              PieChartSectionData(
                value: widget.project.todoCount.toDouble() * t,
                color: AppColors.grey400.withValues(alpha: 0.3),
                radius: 12,
                showTitle: false,
              ),
          ];
          if (sections.isEmpty) {
            sections.add(PieChartSectionData(
              value: 1,
              color: AppColors.grey400.withValues(alpha: 0.2),
              radius: 12,
              showTitle: false,
            ));
          }
        }

        final pct = (widget.project.progressPercent * 100 * t).round();

        return Transform.scale(
          scale: scale,
          child: Container(
            width: 68,
            height: 68,
            decoration: isComplete
                ? BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.success.withValues(alpha: 0.30),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ],
                  )
                : null,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sections: sections,
                    centerSpaceRadius: 22,
                    sectionsSpace: 2,
                    startDegreeOffset: -90,
                  ),
                  duration: Duration.zero,
                ),
                Text(
                  '$pct%',
                  style: TextStyle(
                    color: isComplete
                        ? AppColors.success
                        : AppColors.primaryLight,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DateChip extends StatelessWidget {
  const _DateChip({
    required this.daysLeft,
    required this.isOverdue,
    required this.targetDate,
  });
  final int daysLeft;
  final bool isOverdue;
  final DateTime targetDate;

  @override
  Widget build(BuildContext context) {
    final color = isOverdue
        ? AppColors.error
        : daysLeft <= 7
            ? AppColors.warning
            : AppColors.accent;
    final label = isOverdue
        ? 'En retard'
        : daysLeft == 0
            ? "Aujourd'hui"
            : daysLeft == 1
                ? 'Demain'
                : 'J$daysLeft';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.calendar_today_rounded, size: 10, color: color),
          const SizedBox(width: 4),
          Text(label, style: AppTextStyles.caption(color: color)),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label, style: AppTextStyles.caption(color: color)),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: color, size: 22),
      title: Text(label,
          style: AppTextStyles.bodyMedium(color: color)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
      dense: true,
    );
  }
}

// ── Board Kanban ──────────────────────────────────────────────
class _KanbanBoard extends ConsumerWidget {
  const _KanbanBoard({required this.project, required this.isDark});
  final KanbanProject project;
  final bool isDark;

  static const _columns = [
    KanbanStatus.todo,
    KanbanStatus.inProgress,
    KanbanStatus.done,
  ];

  static const _columnColors = {
    KanbanStatus.todo:       AppColors.grey400,
    KanbanStatus.inProgress: AppColors.warning,
    KanbanStatus.done:       AppColors.success,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
      itemCount: _columns.length,
      itemBuilder: (_, i) {
        final status = _columns[i];
        final tasks =
            project.tasks.where((t) => t.status == status).toList();
        final color = _columnColors[status]!;

        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: _KanbanColumn(
            status: status,
            tasks: tasks,
            color: color,
            projectId: project.id,
            isDark: isDark,
          ),
        );
      },
    );
  }
}

// ── Colonne Kanban ────────────────────────────────────────────
class _KanbanColumn extends StatelessWidget {
  const _KanbanColumn({
    required this.status,
    required this.tasks,
    required this.color,
    required this.projectId,
    required this.isDark,
  });
  final KanbanStatus status;
  final List<KanbanTask> tasks;
  final Color color;
  final String projectId;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 10, height: 10,
              decoration:
                  BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(
              '${status.emoji}  ${status.label}',
              style: AppTextStyles.labelMedium(color: color),
            ),
            const SizedBox(width: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius:
                    BorderRadius.circular(AppConstants.radiusPill),
              ),
              child: Text('${tasks.length}',
                  style: AppTextStyles.caption(color: color)),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () =>
                  _showAddTaskSheet(context, projectId, status),
              child: Container(
                width: 30, height: 30,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.add_rounded, size: 18, color: color),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        if (tasks.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              border: Border.all(
                color: color.withValues(alpha: 0.18),
                style: BorderStyle.solid,
              ),
              borderRadius:
                  BorderRadius.circular(AppConstants.radiusMedium),
            ),
            child: Text(
              'Rien ici pour l\'instant',
              style: AppTextStyles.caption(color: AppColors.grey400),
              textAlign: TextAlign.center,
            ),
          )
        else
          ...tasks.map((task) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _KanbanTaskCard(
                  task: task,
                  projectId: projectId,
                  isDark: isDark,
                  color: color,
                ),
              )),
      ],
    );
  }
}

// ── Carte de tâche ────────────────────────────────────────────
class _KanbanTaskCard extends ConsumerWidget {
  const _KanbanTaskCard({
    required this.task,
    required this.projectId,
    required this.isDark,
    required this.color,
  });
  final KanbanTask task;
  final String projectId;
  final bool isDark;
  final Color color;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: ValueKey(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.15),
          borderRadius:
              BorderRadius.circular(AppConstants.radiusMedium),
        ),
        child: const Icon(Icons.delete_rounded, color: AppColors.error),
      ),
      onDismissed: (_) =>
          ref.read(kanbanProvider.notifier).deleteTask(projectId, task.id),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.surfaceDark.withValues(alpha: 0.85)
                  : AppColors.surfaceLight.withValues(alpha: 0.90),
              borderRadius:
                  BorderRadius.circular(AppConstants.radiusMedium),
              border: Border.all(color: color.withValues(alpha: 0.20)),
            ),
            child: Row(
              children: [
                Container(
                  width: 6, height: 36,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    task.title,
                    style: AppTextStyles.bodyMedium(
                      color: isDark
                          ? AppColors.textDark
                          : AppColors.textLight,
                    ).copyWith(
                      decoration: task.status == KanbanStatus.done
                          ? TextDecoration.lineThrough
                          : null,
                      color: task.status == KanbanStatus.done
                          ? AppColors.grey400
                          : null,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (task.status != KanbanStatus.done)
                  GestureDetector(
                    onTap: () {
                      final next = task.status == KanbanStatus.todo
                          ? KanbanStatus.inProgress
                          : KanbanStatus.done;
                      ref
                          .read(kanbanProvider.notifier)
                          .moveTask(projectId, task.id, next);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(
                            AppConstants.radiusPill),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            task.status == KanbanStatus.todo
                                ? 'Démarrer'
                                : 'Terminer',
                            style: AppTextStyles.caption(color: color),
                          ),
                          const SizedBox(width: 3),
                          Icon(Icons.arrow_forward_rounded,
                              size: 11, color: color),
                        ],
                      ),
                    ),
                  )
                else
                  const Icon(Icons.check_circle_rounded,
                      color: AppColors.success, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Sheet ajout de tâche ──────────────────────────────────────
void _showAddTaskSheet(
  BuildContext context,
  String projectId,
  KanbanStatus status,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _AddTaskSheet(projectId: projectId, status: status),
  );
}

class _AddTaskSheet extends ConsumerStatefulWidget {
  const _AddTaskSheet({required this.projectId, required this.status});
  final String projectId;
  final KanbanStatus status;

  @override
  ConsumerState<_AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends ConsumerState<_AddTaskSheet> {
  final _ctrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_ctrl.text.trim().isEmpty) return;
    setState(() => _loading = true);
    try {
      await ref.read(kanbanProvider.notifier).addTask(
            widget.projectId, _ctrl.text, widget.status);
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const colors = {
      KanbanStatus.todo:       AppColors.grey400,
      KanbanStatus.inProgress: AppColors.warning,
      KanbanStatus.done:       AppColors.success,
    };
    final color = colors[widget.status]!;

    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.backgroundLight,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.grey400.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  width: 10, height: 10,
                  decoration:
                      BoxDecoration(color: color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                Text('Ajouter dans "${widget.status.label}"',
                    style: AppTextStyles.headingSmall(
                      color: isDark
                          ? AppColors.textDark
                          : AppColors.textLight,
                    )),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _ctrl,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              style: AppTextStyles.bodyMedium(
                color: isDark ? AppColors.textDark : AppColors.textLight,
              ),
              onSubmitted: (_) => _save(),
              decoration: InputDecoration(
                hintText: 'Qu\'est-ce que tu veux avancer ?',
                hintStyle:
                    AppTextStyles.bodyMedium(color: AppColors.grey400),
                filled: true,
                fillColor: isDark
                    ? AppColors.surfaceElevatedDark
                    : AppColors.grey200.withValues(alpha: 0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: const StadiumBorder(),
                  elevation: 0,
                ),
                child: _loading
                    ? const KolybLoader(size: 6, color: Colors.white)
                    : Text('Ajouter la tâche',
                        style:
                            AppTextStyles.labelMedium(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── État vide ─────────────────────────────────────────────────
class _EmptyKanban extends StatelessWidget {
  const _EmptyKanban({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('📋', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 24),
            Text(
              'Aucun projet pour l\'instant',
              style: AppTextStyles.headingSmall(
                color: isDark ? AppColors.textDark : AppColors.textLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Crée ton premier projet, définis ton pourquoi et organise tes actions.',
              style:
                  AppTextStyles.bodyMedium(color: AppColors.grey400),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: onAdd,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.chartViolet],
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.35),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add_rounded,
                        color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Text('Créer un projet',
                        style: AppTextStyles.labelMedium(
                            color: Colors.white)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Erreur ────────────────────────────────────────────────────
class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('😕', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text('Une erreur est survenue.',
              style:
                  AppTextStyles.bodyMedium(color: AppColors.textDarkMuted)),
          const SizedBox(height: 16),
          ElevatedButton(
              onPressed: onRetry, child: const Text('Réessayer')),
        ],
      ),
    );
  }
}
