import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/planner/data/kanban_model.dart';
import '../../features/planner/presentation/providers/kanban_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'kolyb_loader.dart';

/// Sheet de configuration projet — utilisé depuis Mes Objectifs ET le Kanban.
/// project == null → mode création, non null → mode édition.
/// onCreated est appelé avec l'id du projet après création (optionnel).
class ProjectConfigSheet extends ConsumerStatefulWidget {
  const ProjectConfigSheet({super.key, this.project, this.onCreated});

  final KanbanProject? project;
  final void Function(String id)? onCreated;

  @override
  ConsumerState<ProjectConfigSheet> createState() => _ProjectConfigSheetState();
}

class _ProjectConfigSheetState extends ConsumerState<ProjectConfigSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _whyCtrl;
  late final TextEditingController _visionCtrl;
  late final TextEditingController _blockerCtrl;
  late final List<TextEditingController> _criteriaCtrl;

  ProjectCategory? _category;
  DateTime? _targetDate;
  bool _loading = false;
  bool _deleteConfirm = false;

  bool get _isEdit => widget.project != null;

  @override
  void initState() {
    super.initState();
    final p = widget.project;
    _nameCtrl    = TextEditingController(text: p?.name ?? '');
    _whyCtrl     = TextEditingController(text: p?.why ?? '');
    _visionCtrl  = TextEditingController(text: p?.vision ?? '');
    _blockerCtrl = TextEditingController(text: p?.currentBlocker ?? '');
    _category    = p?.category;
    _targetDate  = p?.targetDate;

    final existing = p?.successCriteria ?? [];
    // 3 champs par défaut, plus si l'utilisateur en a déjà davantage
    _criteriaCtrl = List.generate(
      max(3, existing.length),
      (i) => TextEditingController(text: i < existing.length ? existing[i] : ''),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _whyCtrl.dispose();
    _visionCtrl.dispose();
    _blockerCtrl.dispose();
    for (final c in _criteriaCtrl) {
      c.dispose();
    }
    super.dispose();
  }

  List<String> get _criteria =>
      _criteriaCtrl.map((c) => c.text.trim()).where((s) => s.isNotEmpty).toList();

  void _addCriterion() {
    setState(() => _criteriaCtrl.add(TextEditingController()));
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) return;
    setState(() => _loading = true);
    try {
      if (_isEdit) {
        await ref.read(kanbanProvider.notifier).updateProject(
          projectId: widget.project!.id,
          name: _nameCtrl.text,
          why: _whyCtrl.text.isNotEmpty ? _whyCtrl.text : null,
          vision: _visionCtrl.text.isNotEmpty ? _visionCtrl.text : null,
          successCriteria: _criteria,
          targetDate: _targetDate,
          category: _category,
          currentBlocker: _blockerCtrl.text.isNotEmpty ? _blockerCtrl.text : null,
          clearWhy: _whyCtrl.text.isEmpty,
          clearVision: _visionCtrl.text.isEmpty,
          clearTargetDate: _targetDate == null,
          clearCategory: _category == null,
          clearCurrentBlocker: _blockerCtrl.text.isEmpty,
        );
      } else {
        await ref.read(kanbanProvider.notifier).addProject(
          name: _nameCtrl.text,
          why: _whyCtrl.text.isNotEmpty ? _whyCtrl.text : null,
          vision: _visionCtrl.text.isNotEmpty ? _visionCtrl.text : null,
          successCriteria: _criteria,
          targetDate: _targetDate,
          category: _category,
          currentBlocker: _blockerCtrl.text.isNotEmpty ? _blockerCtrl.text : null,
        );
        if (widget.onCreated != null) {
          final projects = ref.read(kanbanProvider).valueOrNull ?? [];
          if (projects.isNotEmpty && mounted) {
            widget.onCreated!(projects.last.id);
          }
        }
      }
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _delete() async {
    if (!_deleteConfirm) {
      setState(() => _deleteConfirm = true);
      return;
    }
    setState(() => _loading = true);
    try {
      await ref.read(kanbanProvider.notifier).deleteProject(widget.project!.id);
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _targetDate ?? now.add(const Duration(days: 30)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 5)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.primary,
            onPrimary: Colors.white,
            surface: AppColors.surfaceDark,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _targetDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.backgroundLight,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: DraggableScrollableSheet(
          initialChildSize: 0.92,
          minChildSize: 0.50,
          maxChildSize: 0.97,
          expand: false,
          builder: (_, scrollCtrl) => CustomScrollView(
            controller: scrollCtrl,
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Handle ──────────────────────────────
                    Center(
                      child: Container(
                        margin: const EdgeInsets.only(top: 12, bottom: 20),
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.grey400.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),

                    // ── Titre ────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        children: [
                          const Text('📋', style: TextStyle(fontSize: 24)),
                          const SizedBox(width: 10),
                          Text(
                            _isEdit ? 'Configurer le projet' : 'Nouveau projet',
                            style: AppTextStyles.headingMedium(
                              color: isDark ? AppColors.textDark : AppColors.textLight,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── 1. Nom ────────────────────────────────
                    _SectionLabel(label: 'Nom du projet', isDark: isDark),
                    _TextField(
                      controller: _nameCtrl,
                      hint: 'Ex. Lancer mon podcast',
                      isDark: isDark,
                      autofocus: !_isEdit,
                    ),

                    const SizedBox(height: 20),

                    // ── 2. Catégorie ──────────────────────────
                    _SectionLabel(
                      label: 'Catégorie',
                      subtitle: 'Quel domaine de ton activité ?',
                      isDark: isDark,
                    ),
                    _CategoryPicker(
                      selected: _category,
                      isDark: isDark,
                      onSelected: (cat) => setState(() => _category = cat),
                    ),

                    const SizedBox(height: 20),

                    // ── 3. Pourquoi ? ─────────────────────────
                    _SectionLabel(
                      label: 'Pourquoi ?',
                      subtitle: 'Ton ancrage motivationnel',
                      isDark: isDark,
                    ),
                    _TextField(
                      controller: _whyCtrl,
                      hint: 'Ce projet compte parce que...',
                      isDark: isDark,
                      maxLines: 2,
                    ),

                    const SizedBox(height: 20),

                    // ── 4. Vision ─────────────────────────────
                    _SectionLabel(
                      label: 'Où on va ?',
                      subtitle: 'Ta vision en 1 phrase',
                      isDark: isDark,
                    ),
                    _TextField(
                      controller: _visionCtrl,
                      hint: 'Dans 3 mois, j\'aurai...',
                      isDark: isDark,
                      maxLines: 2,
                    ),

                    const SizedBox(height: 20),

                    // ── 5. Date cible ─────────────────────────
                    _SectionLabel(
                      label: 'Date cible',
                      subtitle: 'Optionnelle',
                      isDark: isDark,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: GestureDetector(
                        onTap: () => _pickDate(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.surfaceElevatedDark
                                : AppColors.grey200.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today_rounded,
                                  size: 18,
                                  color: _targetDate != null
                                      ? AppColors.primaryLight
                                      : AppColors.grey400),
                              const SizedBox(width: 10),
                              Text(
                                _targetDate != null
                                    ? '${_targetDate!.day}/${_targetDate!.month}/${_targetDate!.year}'
                                    : 'Choisir une date',
                                style: AppTextStyles.bodyMedium(
                                  color: _targetDate != null
                                      ? (isDark
                                          ? AppColors.textDark
                                          : AppColors.textLight)
                                      : AppColors.grey400,
                                ),
                              ),
                              const Spacer(),
                              if (_targetDate != null)
                                GestureDetector(
                                  onTap: () =>
                                      setState(() => _targetDate = null),
                                  child: Icon(Icons.close_rounded,
                                      size: 16, color: AppColors.grey400),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── 6. Critères de réussite ───────────────
                    _SectionLabel(
                      label: 'Critères de réussite',
                      subtitle: 'Comment sauras-tu que tu as réussi ?',
                      isDark: isDark,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          ...List.generate(_criteriaCtrl.length, (i) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Row(
                                children: [
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: _criteriaCtrl[i]
                                              .text
                                              .trim()
                                              .isNotEmpty
                                          ? AppColors.primary
                                              .withValues(alpha: 0.15)
                                          : Colors.transparent,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: _criteriaCtrl[i]
                                                .text
                                                .trim()
                                                .isNotEmpty
                                            ? AppColors.primaryLight
                                            : AppColors.grey400
                                                .withValues(alpha: 0.4),
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${i + 1}',
                                        style: AppTextStyles.caption(
                                          color: _criteriaCtrl[i]
                                                  .text
                                                  .trim()
                                                  .isNotEmpty
                                              ? AppColors.primaryLight
                                              : AppColors.grey400,
                                        ).copyWith(fontSize: 10),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: TextField(
                                      controller: _criteriaCtrl[i],
                                      onChanged: (_) => setState(() {}),
                                      textCapitalization:
                                          TextCapitalization.sentences,
                                      style: AppTextStyles.bodySmall(
                                        color: isDark
                                            ? AppColors.textDark
                                            : AppColors.textLight,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: i == 0
                                            ? 'Mon premier critère de réussite...'
                                            : 'Critère ${i + 1} (optionnel)',
                                        hintStyle: AppTextStyles.bodySmall(
                                            color: AppColors.grey400),
                                        filled: true,
                                        fillColor: isDark
                                            ? AppColors.surfaceElevatedDark
                                            : AppColors.grey200
                                                .withValues(alpha: 0.5),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: BorderSide.none,
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 14, vertical: 11),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                          // Bouton ajouter un critère
                          GestureDetector(
                            onTap: _addCriterion,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 11),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.primary.withValues(alpha: 0.08)
                                    : AppColors.primary.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color:
                                      AppColors.primary.withValues(alpha: 0.25),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_rounded,
                                      size: 16,
                                      color: AppColors.primaryLight),
                                  const SizedBox(width: 6),
                                  Text(
                                    '+ Ajouter un critère',
                                    style: AppTextStyles.labelMedium(
                                        color: AppColors.primaryLight),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── 7. Blocage actuel ─────────────────────
                    _SectionLabel(
                      label: 'Blocage actuel',
                      subtitle: 'Optionnel — nommer un blocage aide à le surmonter',
                      isDark: isDark,
                    ),
                    _TextField(
                      controller: _blockerCtrl,
                      hint: 'Ce qui me bloque en ce moment...',
                      isDark: isDark,
                      maxLines: 2,
                    ),

                    const SizedBox(height: 28),

                    // ── Enregistrer ───────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding:
                                const EdgeInsets.symmetric(vertical: 16),
                            shape: const StadiumBorder(),
                            elevation: 0,
                          ),
                          child: _loading
                              ? const KolybLoader(size: 6, color: Colors.white)
                              : Text(
                                  _isEdit
                                      ? 'Enregistrer les modifications'
                                      : 'Créer ce projet',
                                  style: AppTextStyles.labelMedium(
                                      color: Colors.white),
                                ),
                        ),
                      ),
                    ),

                    // ── Supprimer (mode édition) ──────────────
                    if (_isEdit) ...[
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: SizedBox(
                          width: double.infinity,
                          child: TextButton(
                            onPressed: _loading ? null : _delete,
                            child: Text(
                              _deleteConfirm
                                  ? 'Confirmer la suppression ?'
                                  : 'Supprimer ce projet',
                              style: AppTextStyles.labelMedium(
                                color: _deleteConfirm
                                    ? AppColors.error
                                    : AppColors.grey400,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Sélecteur de catégorie ────────────────────────────────────────
class _CategoryPicker extends StatelessWidget {
  const _CategoryPicker({
    required this.selected,
    required this.isDark,
    required this.onSelected,
  });

  final ProjectCategory? selected;
  final bool isDark;
  final void Function(ProjectCategory?) onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: ProjectCategory.values.map((cat) {
          final isActive = selected == cat;
          return GestureDetector(
            onTap: () => onSelected(isActive ? null : cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.only(right: 8),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.primary.withValues(alpha: 0.18)
                    : (isDark
                        ? AppColors.surfaceElevatedDark
                        : AppColors.grey200.withValues(alpha: 0.5)),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isActive
                      ? AppColors.primaryLight.withValues(alpha: 0.6)
                      : Colors.transparent,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(cat.emoji, style: const TextStyle(fontSize: 13)),
                  const SizedBox(width: 5),
                  Text(
                    cat.label,
                    style: AppTextStyles.labelMedium(
                      color: isActive
                          ? AppColors.primaryLight
                          : AppColors.grey400,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Helpers internes ──────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  const _SectionLabel({
    required this.label,
    required this.isDark,
    this.subtitle,
  });

  final String label;
  final bool isDark;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.labelMedium(
              color: isDark ? AppColors.textDark : AppColors.textLight,
            ),
          ),
          if (subtitle != null)
            Text(subtitle!,
                style: AppTextStyles.caption(color: AppColors.grey400)),
        ],
      ),
    );
  }
}

class _TextField extends StatelessWidget {
  const _TextField({
    required this.controller,
    required this.hint,
    required this.isDark,
    this.maxLines = 1,
    this.autofocus = false,
  });

  final TextEditingController controller;
  final String hint;
  final bool isDark;
  final int maxLines;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: TextField(
        controller: controller,
        autofocus: autofocus,
        maxLines: maxLines,
        textCapitalization: TextCapitalization.sentences,
        style: AppTextStyles.bodyMedium(
          color: isDark ? AppColors.textDark : AppColors.textLight,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.bodyMedium(color: AppColors.grey400),
          filled: true,
          fillColor: isDark
              ? AppColors.surfaceElevatedDark
              : AppColors.grey200.withValues(alpha: 0.5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}
