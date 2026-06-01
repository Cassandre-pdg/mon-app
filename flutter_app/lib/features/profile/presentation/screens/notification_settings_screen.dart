import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
              _WheelTimeTile(
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
              _WheelTimeTile(
                label: 'Heure du soir',
                time: settings.eveningTime,
                isDark: isDark,
                onChanged: (t) => notifier.updateTime(eveningTime: t),
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
              title: 'Le Salon',
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
            'Les notifications sont opt-in : jamais de spam.',
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

// ── Sélecteur d'heure : row cliquable ─────────────────────────

class _WheelTimeTile extends StatelessWidget {
  final String label;
  final String time;
  final bool isDark;
  final ValueChanged<String> onChanged;

  const _WheelTimeTile({
    required this.label,
    required this.time,
    required this.isDark,
    required this.onChanged,
  });

  Future<void> _openPicker(BuildContext context) async {
    final parts = time.split(':');
    final initialTime = DateTime(
      2024, 1, 1,
      int.tryParse(parts[0]) ?? 7,
      int.tryParse(parts[1]) ?? 30,
    );

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _WheelPickerSheet(
        label: label,
        initialTime: initialTime,
        isDark: isDark,
        onConfirm: (dt) {
          final formatted =
              '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
          onChanged(formatted);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _openPicker(context),
      borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacing16,
          vertical: AppConstants.spacing12,
        ),
        child: Row(
          children: [
            const SizedBox(width: 48),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.bodySmall(color: AppColors.grey400),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius:
                    BorderRadius.circular(AppConstants.radiusMedium),
              ),
              child: Text(
                time,
                style: AppTextStyles.labelMedium(color: AppColors.primary)
                    .copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right_rounded,
                color: AppColors.grey400, size: 18),
          ],
        ),
      ),
    );
  }
}

// ── Bottom sheet avec molette CupertinoDatePicker ─────────────

class _WheelPickerSheet extends StatefulWidget {
  final String label;
  final DateTime initialTime;
  final bool isDark;
  final ValueChanged<DateTime> onConfirm;

  const _WheelPickerSheet({
    required this.label,
    required this.initialTime,
    required this.isDark,
    required this.onConfirm,
  });

  @override
  State<_WheelPickerSheet> createState() => _WheelPickerSheetState();
}

class _WheelPickerSheetState extends State<_WheelPickerSheet> {
  late DateTime _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialTime;
  }

  @override
  Widget build(BuildContext context) {
    final bgColor =
        widget.isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final textColor =
        widget.isDark ? AppColors.textDark : AppColors.textLight;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.18),
            blurRadius: 40,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: widget.isDark
                    ? Colors.white.withValues(alpha: 0.18)
                    : Colors.black.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Titre
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
              child: Text(
                widget.label,
                style: AppTextStyles.headingSmall(color: textColor),
              ),
            ),

            // Molette
            SizedBox(
              height: 200,
              child: CupertinoTheme(
                data: CupertinoThemeData(
                  brightness: widget.isDark ? Brightness.dark : Brightness.light,
                  primaryColor: AppColors.primary,
                  textTheme: CupertinoTextThemeData(
                    dateTimePickerTextStyle: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ),
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  use24hFormat: true,
                  initialDateTime: _selected,
                  backgroundColor: Colors.transparent,
                  onDateTimeChanged: (dt) => setState(() => _selected = dt),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Bouton Confirmer
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6D28D9), Color(0xFF8B5CF6)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextButton(
                    onPressed: () {
                      widget.onConfirm(_selected);
                      Navigator.of(context).pop();
                    },
                    style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'Confirmer',
                      style: AppTextStyles.bodyLarge(color: Colors.white)
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
