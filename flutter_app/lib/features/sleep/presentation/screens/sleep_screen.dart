import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/constants/app_constants.dart';
import '../../../../shared/constants/app_strings.dart';
import '../providers/sleep_provider.dart';
import '../../data/sleep_model.dart';

class SleepScreen extends ConsumerWidget {
  const SleepScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(sleepLogsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(AppStrings.navSleep,
                      style: AppTextStyles.headingLarge(
                          color: isDark ? AppColors.textDark : AppColors.textLight)),
                  ElevatedButton.icon(
                    onPressed: () => _showAddSleepSheet(context, ref),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Ajouter'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(0, 40),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppConstants.spacing24),

            Expanded(
              child: logsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Erreur', style: AppTextStyles.bodyMedium())),
                data: (logs) => logs.isEmpty
                    ? _EmptyState()
                    : _SleepList(logs: logs),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddSleepSheet(BuildContext context, WidgetRef ref) {
    TimeOfDay bedtime  = const TimeOfDay(hour: 23, minute: 0);
    TimeOfDay wakeTime = const TimeOfDay(hour: 7,  minute: 0);
    int quality = 3;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => Padding(
          padding: EdgeInsets.only(
            left: 24, right: 24, top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 32,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Mon sommeil 😴', style: AppTextStyles.headingMedium()),
              const SizedBox(height: AppConstants.spacing24),

              // Heure coucher / réveil
              Row(
                children: [
                  Expanded(
                    child: _TimePicker(
                      label: '🌙 Coucher',
                      time: bedtime,
                      onPicked: (t) => setState(() => bedtime = t),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TimePicker(
                      label: '🌅 Réveil',
                      time: wakeTime,
                      onPicked: (t) => setState(() => wakeTime = t),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spacing16),

              // Qualité
              Text('Qualité du sommeil', style: AppTextStyles.labelMedium()),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(5, (i) {
                  final emojis = ['😴', '😕', '😐', '🙂', '😄'];
                  final score = i + 1;
                  return GestureDetector(
                    onTap: () => setState(() => quality = score),
                    child: AnimatedContainer(
                      duration: AppConstants.animFast,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: quality == score
                            ? AppColors.primary.withValues(alpha:0.15)
                            : Colors.transparent,
                        border: Border.all(
                          color: quality == score ? AppColors.primary : AppColors.grey200,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(emojis[i], style: const TextStyle(fontSize: 24)),
                    ),
                  );
                }),
              ),
              const SizedBox(height: AppConstants.spacing24),

              ElevatedButton(
                onPressed: () {
                  String fmt(TimeOfDay t) =>
                      '${t.hour.toString().padLeft(2,'0')}:${t.minute.toString().padLeft(2,'0')}';
                  ref.read(sleepLogsProvider.notifier).addLog(
                        sleepDate: DateTime.now().toIso8601String().split('T')[0],
                        bedtime: fmt(bedtime),
                        wakeTime: fmt(wakeTime),
                        qualityScore: quality,
                      );
                  Navigator.pop(ctx);
                },
                child: const Text('Enregistrer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimePicker extends StatelessWidget {
  final String label;
  final TimeOfDay time;
  final ValueChanged<TimeOfDay> onPicked;
  const _TimePicker({required this.label, required this.time, required this.onPicked});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () async {
        final picked = await showTimePicker(context: context, initialTime: time);
        if (picked != null) onPicked(picked);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.grey100,
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        ),
        child: Column(
          children: [
            Text(label, style: AppTextStyles.caption()),
            const SizedBox(height: 4),
            Text(
              '${time.hour.toString().padLeft(2,'0')}:${time.minute.toString().padLeft(2,'0')}',
              style: AppTextStyles.headingMedium(color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}

class _SleepList extends StatelessWidget {
  final List<SleepLog> logs;
  const _SleepList({required this.logs});

  static const _qualityEmojis = {1: '😴', 2: '😕', 3: '😐', 4: '🙂', 5: '😄'};

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final avg = logs.isEmpty ? 0.0
        : logs.map((l) => l.durationMinutes).reduce((a, b) => a + b) / logs.length;

    return Column(
      children: [
        // Carte résumé
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.all(AppConstants.spacing16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2D1B69), Color(0xFF6C47FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatItem(label: 'Moyenne', value: SleepLog(
                  id: '', userId: '', sleepDate: DateTime.now(),
                  bedtime: '23:00', wakeTime: '07:00',
                  durationMinutes: avg.round(), createdAt: DateTime.now(),
                ).durationDisplay, color: Colors.white),
                _StatItem(label: '7 derniers jours', value: '${logs.length} nuits', color: Colors.white70),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppConstants.spacing16),

        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: logs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final log = logs[i];
              return Container(
                padding: const EdgeInsets.all(AppConstants.spacing16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                ),
                child: Row(
                  children: [
                    Text(_qualityEmojis[log.qualityScore ?? 3] ?? '😐',
                        style: const TextStyle(fontSize: 32)),
                    const SizedBox(width: AppConstants.spacing12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat('EEE d MMM', 'fr_FR').format(log.sleepDate),
                            style: AppTextStyles.labelMedium(
                                color: isDark ? AppColors.textDark : AppColors.textLight),
                          ),
                          Text('${log.bedtime} → ${log.wakeTime}',
                              style: AppTextStyles.bodySmall(color: AppColors.grey400)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(log.durationDisplay,
                            style: AppTextStyles.headingSmall(color: AppColors.primary)),
                        Text('de sommeil',
                            style: AppTextStyles.caption()),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label, value;
  final Color color;
  const _StatItem({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text(value, style: AppTextStyles.headingMedium(color: color)),
          Text(label, style: AppTextStyles.caption(color: color.withValues(alpha:0.7))),
        ],
      );
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacing32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('😴', style: TextStyle(fontSize: 56)),
              const SizedBox(height: AppConstants.spacing16),
              Text(AppStrings.emptySleep,
                  style: AppTextStyles.bodyLarge(color: AppColors.grey400),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      );
}
