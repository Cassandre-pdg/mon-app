import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/constants/app_constants.dart';
import '../../data/session_context_model.dart';
import '../../data/planner_model.dart';
import '../providers/planner_provider.dart';
import '../providers/flash_provider.dart';

enum _Selection { none, flash, other }

class SessionContextPicker extends ConsumerStatefulWidget {
  final String timerType; // 'flow' | 'pomodoro'

  const SessionContextPicker({super.key, required this.timerType});

  static Future<SessionContext?> show(
    BuildContext context, {
    required String timerType,
  }) {
    return showModalBottomSheet<SessionContext?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SessionContextPicker(timerType: timerType),
    );
  }

  @override
  ConsumerState<SessionContextPicker> createState() =>
      _SessionContextPickerState();
}

class _SessionContextPickerState extends ConsumerState<SessionContextPicker> {
  PlannerTask? _selectedTask;
  _Selection _selection = _Selection.none;
  final _otherCtrl = TextEditingController();

  @override
  void dispose() {
    _otherCtrl.dispose();
    super.dispose();
  }

  Color get _accentColor => widget.timerType == 'flow'
      ? AppColors.primary
      : AppColors.secondary;

  void _selectTask(PlannerTask task) {
    setState(() {
      _selectedTask = task;
      _selection = _Selection.none;
    });
  }

  void _confirm() {
    SessionContext? ctx;
    if (_selectedTask != null) {
      ctx = SessionContext(
        type: SessionContextType.priority,
        label: _selectedTask!.title,
        projectId: _selectedTask!.projectId,
        projectName: _selectedTask!.projectName,
      );
    } else if (_selection == _Selection.flash) {
      ctx = const SessionContext(
        type: SessionContextType.flash,
        label: 'Bloc Flash',
      );
    } else if (_selection == _Selection.other &&
        _otherCtrl.text.trim().isNotEmpty) {
      ctx = SessionContext(
        type: SessionContextType.other,
        label: _otherCtrl.text.trim(),
      );
    }
    Navigator.pop(context, ctx);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tasksAsync = ref.watch(plannerProvider);
    final flashCount = ref.watch(flashPendingCountProvider);
    final bottomPad = MediaQuery.of(context).viewInsets.bottom;

    final tasks = tasksAsync.valueOrNull
            ?.where((t) => !t.isCompleted)
            .toList() ??
        [];

    return Padding(
      padding: EdgeInsets.only(bottom: bottomPad),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceElevatedDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bande gradient en haut
            Container(
              height: 5,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: widget.timerType == 'flow'
                      ? [AppColors.primary, AppColors.primaryLight]
                      : [AppColors.secondary, AppColors.chartAmber],
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Text(
                        'Sur quoi tu travailles ?',
                        style: AppTextStyles.headingSmall(
                          color: isDark ? AppColors.textDark : AppColors.textLight,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () => Navigator.pop(context, null),
                        child: Text(
                          'Passer',
                          style: AppTextStyles.bodySmall(
                              color: AppColors.grey400),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Optionnel. La session démarre quoi qu\'il arrive.',
                    style: AppTextStyles.bodySmall(color: AppColors.grey400),
                  ),
                  const SizedBox(height: 20),

                  // Section priorités
                  if (tasks.isNotEmpty) ...[
                    _SectionLabel(label: 'Priorités du jour', isDark: isDark),
                    const SizedBox(height: 10),
                    ...tasks.map((t) => _TaskRow(
                          task: t,
                          isSelected: _selectedTask?.id == t.id,
                          accentColor: _accentColor,
                          isDark: isDark,
                          onTap: () => _selectTask(t),
                        )),
                    const SizedBox(height: 16),
                  ],

                  // Section Flash
                  if (flashCount > 0) ...[
                    _SectionLabel(label: 'Bloc Flash', isDark: isDark),
                    const SizedBox(height: 10),
                    _SelectableRow(
                      isSelected: _selection == _Selection.flash,
                      accentColor: AppColors.chartAmber,
                      isDark: isDark,
                      onTap: () => setState(() {
                        _selection = _Selection.flash;
                        _selectedTask = null;
                      }),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.chartAmber.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '$flashCount tâches',
                              style: AppTextStyles.caption(
                                      color: AppColors.chartAmber)
                                  .copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'en attente dans ton Bloc Flash',
                            style: AppTextStyles.bodyMedium(
                              color: isDark
                                  ? AppColors.textDark
                                  : AppColors.textLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Section Autre
                  _SectionLabel(label: 'Autre', isDark: isDark),
                  const SizedBox(height: 10),
                  _SelectableRow(
                    isSelected: _selection == _Selection.other,
                    accentColor: AppColors.accent,
                    isDark: isDark,
                    onTap: () => setState(() {
                      _selection = _Selection.other;
                      _selectedTask = null;
                    }),
                    child: Expanded(
                      child: TextField(
                        controller: _otherCtrl,
                        onTap: () => setState(() {
                          _selection = _Selection.other;
                          _selectedTask = null;
                        }),
                        style: AppTextStyles.bodyMedium(
                          color: isDark ? AppColors.textDark : AppColors.textLight,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Décris ta session librement...',
                          hintStyle: AppTextStyles.bodyMedium(
                              color: AppColors.grey400),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // CTA
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _confirm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _accentColor,
                        foregroundColor: Colors.white,
                        padding:
                            const EdgeInsets.symmetric(vertical: 16),
                        shape: const StadiumBorder(),
                      ),
                      icon: const Icon(Icons.play_arrow_rounded, size: 20),
                      label: Text(
                        widget.timerType == 'flow'
                            ? 'Démarrer le Flow'
                            : 'Démarrer le Pomodoro',
                        style: AppTextStyles.headingSmall(
                            color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Label de section ──────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  final bool isDark;
  const _SectionLabel({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: AppTextStyles.caption(color: AppColors.grey400).copyWith(
        letterSpacing: 0.8,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

// ── Ligne de tâche MIT sélectionnable ─────────────────────────
class _TaskRow extends StatelessWidget {
  final PlannerTask task;
  final bool isSelected;
  final Color accentColor;
  final bool isDark;
  final VoidCallback onTap;

  const _TaskRow({
    required this.task,
    required this.isSelected,
    required this.accentColor,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _SelectableRow(
      isSelected: isSelected,
      accentColor: accentColor,
      isDark: isDark,
      onTap: onTap,
      child: Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              task.title,
              style: AppTextStyles.bodyMedium(
                color: isDark ? AppColors.textDark : AppColors.textLight,
              ).copyWith(fontWeight: FontWeight.w600),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (task.projectName != null) ...[
              const SizedBox(height: 2),
              Text(
                task.projectName!,
                style: AppTextStyles.caption(
                    color: accentColor.withValues(alpha: 0.8)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Conteneur sélectionnable générique ───────────────────────
class _SelectableRow extends StatelessWidget {
  final bool isSelected;
  final Color accentColor;
  final bool isDark;
  final VoidCallback onTap;
  final Widget child;

  const _SelectableRow({
    required this.isSelected,
    required this.accentColor,
    required this.isDark,
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppConstants.animFast,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? accentColor.withValues(alpha: 0.10)
              : (isDark ? AppColors.surfaceDark : AppColors.grey100),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? accentColor
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: AppConstants.animFast,
              width: 20,
              height: 20,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? accentColor : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? accentColor
                      : AppColors.grey400.withValues(alpha: 0.4),
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check_rounded,
                      color: Colors.white, size: 13)
                  : null,
            ),
            child,
          ],
        ),
      ),
    );
  }
}
