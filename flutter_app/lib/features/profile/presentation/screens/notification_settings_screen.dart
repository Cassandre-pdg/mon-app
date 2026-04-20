import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/constants/app_constants.dart';
import '../../domain/notification_settings_model.dart';
import '../providers/notification_settings_provider.dart';

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(notificationSettingsNotifierProvider);

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor:
            isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? AppColors.textDark : AppColors.textLight,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Notifications',
          style: AppTextStyles.headingSmall(
            color: isDark ? AppColors.textDark : AppColors.textLight,
          ),
        ),
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Impossible de charger tes préférences',
                style: AppTextStyles.bodyMedium(color: AppColors.grey400),
              ),
              const SizedBox(height: AppConstants.spacing16),
              ElevatedButton(
                onPressed: () =>
                    ref.invalidate(notificationSettingsNotifierProvider),
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
        data: (settings) => _NotificationSettingsList(
          settings: settings,
          isDark: isDark,
        ),
      ),
    );
  }
}

// ── Liste des préférences ─────────────────────────────────────

class _NotificationSettingsList extends ConsumerWidget {
  final NotificationSettings settings;
  final bool isDark;

  const _NotificationSettingsList({
    required this.settings,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(notificationSettingsNotifierProvider.notifier);

    return ListView(
      padding: const EdgeInsets.all(AppConstants.spacing24),
      children: [
        // ── Check-ins ─────────────────────────────────────────
        _SectionHeader(title: 'CHECK-INS', isDark: isDark),
        const SizedBox(height: AppConstants.spacing12),
        _NotificationCard(
          isDark: isDark,
          children: [
            _ToggleTile(
              icon: Icons.wb_sunny_rounded,
              iconColor: AppColors.warning,
              title: 'Check-in du matin',
              subtitle: 'Rappel quotidien à ${settings.morningTime}',
              value: settings.morningCheckinEnabled,
              isDark: isDark,
              onChanged: (v) => notifier.toggle(morningCheckin: v),
            ),
            if (settings.morningCheckinEnabled) ...[
              _Separator(isDark: isDark),
              _TimeTile(
                label: 'Heure du matin',
                time: settings.morningTime,
                isDark: isDark,
                onChanged: (t) => notifier.updateTime(morningTime: t),
              ),
            ],
            _Separator(isDark: isDark),
            _ToggleTile(
              icon: Icons.nights_stay_rounded,
              iconColor: AppColors.primaryLight,
              title: 'Check-in du soir',
              subtitle: 'Rappel quotidien à ${settings.eveningTime}',
              value: settings.eveningCheckinEnabled,
              isDark: isDark,
              onChanged: (v) => notifier.toggle(eveningCheckin: v),
            ),
            if (settings.eveningCheckinEnabled) ...[
              _Separator(isDark: isDark),
              _TimeTile(
                label: 'Heure du soir',
                time: settings.eveningTime,
                isDark: isDark,
                onChanged: (t) => notifier.updateTime(eveningTime: t),
              ),
            ],
          ],
        ),

        const SizedBox(height: AppConstants.spacing24),

        // ── Sommeil ───────────────────────────────────────────
        _SectionHeader(title: 'SOMMEIL', isDark: isDark),
        const SizedBox(height: AppConstants.spacing12),
        _NotificationCard(
          isDark: isDark,
          children: [
            _ToggleTile(
              icon: Icons.bedtime_rounded,
              iconColor: AppColors.accent,
              title: 'Rappel sommeil',
              subtitle: 'Pense à renseigner ton sommeil',
              value: settings.sleepReminderEnabled,
              isDark: isDark,
              onChanged: (v) => notifier.toggle(sleepReminder: v),
            ),
            if (settings.sleepReminderEnabled) ...[
              _Separator(isDark: isDark),
              _TimeTile(
                label: 'Heure du coucher',
                time: settings.sleepTime,
                isDark: isDark,
                onChanged: (t) => notifier.updateTime(sleepTime: t),
              ),
            ],
          ],
        ),

        const SizedBox(height: AppConstants.spacing24),

        // ── Productivité ──────────────────────────────────────
        _SectionHeader(title: 'PRODUCTIVITÉ', isDark: isDark),
        const SizedBox(height: AppConstants.spacing12),
        _NotificationCard(
          isDark: isDark,
          children: [
            _ToggleTile(
              icon: Icons.bolt_rounded,
              iconColor: AppColors.primary,
              title: 'Sessions Flow',
              subtitle: 'Rappels pour démarrer tes sessions',
              value: settings.flowSessionEnabled,
              isDark: isDark,
              onChanged: (v) => notifier.toggle(flowSession: v),
            ),
            _Separator(isDark: isDark),
            _ToggleTile(
              icon: Icons.local_fire_department_rounded,
              iconColor: AppColors.secondary,
              title: 'Alertes streak',
              subtitle: 'Protège ton élan quotidien',
              value: settings.streakAlertEnabled,
              isDark: isDark,
              onChanged: (v) => notifier.toggle(streakAlert: v),
            ),
          ],
        ),

        const SizedBox(height: AppConstants.spacing24),

        // ── Communauté ────────────────────────────────────────
        _SectionHeader(title: 'COMMUNAUTÉ', isDark: isDark),
        const SizedBox(height: AppConstants.spacing12),
        _NotificationCard(
          isDark: isDark,
          children: [
            _ToggleTile(
              icon: Icons.people_rounded,
              iconColor: AppColors.accent,
              title: 'Ma Tribu',
              subtitle: 'Réponses et activité dans tes groupes',
              value: settings.communityEnabled,
              isDark: isDark,
              onChanged: (v) => notifier.toggle(community: v),
            ),
          ],
        ),

        const SizedBox(height: AppConstants.spacing24),

        // ── Note RGPD ─────────────────────────────────────────
        Center(
          child: Text(
            'Tu peux modifier ces préférences à tout moment.\n'
            'Les notifications sont opt-in — jamais de spam.',
            style: AppTextStyles.caption(color: AppColors.grey400),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: AppConstants.spacing24),
      ],
    );
  }
}

// ── Composants ────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final bool isDark;

  const _SectionHeader({required this.title, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTextStyles.caption(color: AppColors.grey400).copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final List<Widget> children;
  final bool isDark;

  const _NotificationCard({required this.children, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        border: Border.all(
          color: isDark
              ? AppColors.grey400.withValues(alpha: 0.15)
              : AppColors.grey200,
        ),
      ),
      child: Column(children: children),
    );
  }
}

class _Separator extends StatelessWidget {
  final bool isDark;
  const _Separator({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: 52,
      color: isDark
          ? AppColors.grey400.withValues(alpha: 0.15)
          : AppColors.grey200,
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final bool isDark;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.isDark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacing16,
        vertical: AppConstants.spacing12,
      ),
      child: Row(
        children: [
          // Icône colorée
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: AppConstants.spacing12),

          // Titre + sous-titre
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium(
                    color: isDark ? AppColors.textDark : AppColors.textLight,
                  ).copyWith(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTextStyles.caption(color: AppColors.grey400),
                ),
              ],
            ),
          ),

          // Toggle
          CupertinoSwitch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

class _TimeTile extends StatelessWidget {
  final String label;
  final String time;
  final bool isDark;
  final ValueChanged<String> onChanged;

  const _TimeTile({
    required this.label,
    required this.time,
    required this.isDark,
    required this.onChanged,
  });

  TimeOfDay get _timeOfDay {
    final parts = time.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  Future<void> _pickTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _timeOfDay,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (picked == null) return;

    final formatted =
        '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    onChanged(formatted);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _pickTime(context),
      borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacing16,
          vertical: AppConstants.spacing12,
        ),
        child: Row(
          children: [
            const SizedBox(width: 48), // aligne avec les ToggleTile
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.bodySmall(color: AppColors.grey400),
              ),
            ),
            // Badge heure sélectionnée
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              ),
              child: Text(
                time,
                style: AppTextStyles.labelMedium(color: AppColors.primary)
                    .copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right_rounded, color: AppColors.grey400, size: 18),
          ],
        ),
      ),
    );
  }
}
