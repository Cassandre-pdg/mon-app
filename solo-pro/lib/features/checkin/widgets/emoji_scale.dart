import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class EmojiScale extends StatelessWidget {
  final List<String> emojis;
  final int? selected; // 1–5
  final ValueChanged<int> onSelect;

  const EmojiScale({
    super.key,
    required this.emojis,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(5, (i) {
        final val = i + 1;
        final isSelected = selected == val;
        return GestureDetector(
          onTap: () => onSelect(val),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            width: isSelected ? 66 : 56,
            height: isSelected ? 66 : 56,
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.12)
                  : AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(18),
              border: isSelected
                  ? Border.all(color: AppColors.primary, width: 2)
                  : Border.all(color: Colors.transparent, width: 2),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      )
                    ]
                  : [],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(emojis[i],
                    style: TextStyle(fontSize: isSelected ? 28 : 22)),
                const SizedBox(height: 2),
                Text(
                  '$val',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
