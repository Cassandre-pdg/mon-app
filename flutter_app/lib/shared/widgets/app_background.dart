import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Fond dégradé dark mode : noir pur → indigo nuit (180°)
/// À placer comme parent direct du Scaffold pour garantir le rendu.
class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.child});

  final Widget child;

  static const _gradient = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        AppColors.backgroundDarkGradientStart,
        AppColors.backgroundDarkGradientEnd,
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    if (Theme.of(context).brightness != Brightness.dark) return child;
    return DecoratedBox(
      decoration: _gradient,
      child: child,
    );
  }
}
