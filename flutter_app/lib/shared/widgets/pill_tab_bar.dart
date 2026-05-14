import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

// ── Barre d'onglets style pill — utilisée dans Planner et Le Salon ──
class PillTabBar extends StatelessWidget implements PreferredSizeWidget {
  final List<String> tabs;
  final bool scrollable;

  const PillTabBar({
    super.key,
    required this.tabs,
    this.scrollable = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(44);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TabBar(
        isScrollable: scrollable,
        tabAlignment: scrollable ? TabAlignment.start : TabAlignment.fill,
        indicator: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(20),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: isDark
            ? AppColors.textDarkMuted
            : AppColors.grey600,
        labelStyle: AppTextStyles.labelMedium().copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: AppTextStyles.labelMedium(),
        padding: EdgeInsets.zero,
        labelPadding: scrollable
            ? const EdgeInsets.symmetric(horizontal: 4)
            : EdgeInsets.zero,
        tabs: tabs
            .map((t) => Tab(
                  height: 36,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(t, overflow: TextOverflow.ellipsis),
                  ),
                ))
            .toList(),
      ),
    );
  }
}
