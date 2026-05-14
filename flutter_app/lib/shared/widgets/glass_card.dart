import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../constants/app_constants.dart';

/// Carte glassmorphism — BackdropFilter blur + surface translucide
/// Utilisation : envelopper n'importe quel contenu sur fond aurora/coloré
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppConstants.spacing16),
    this.borderRadius = AppConstants.radiusLarge,
    this.blurSigma = 20.0,
    this.backgroundColor = AppColors.glassWhite8,
    this.borderColor = AppColors.glassBorderWhite,
    this.borderWidth = 1.0,
    this.topHighlight = true,
    this.boxShadow,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double blurSigma;
  final Color backgroundColor;
  final Color borderColor;
  final double borderWidth;

  /// Ligne de lumière en haut de la carte (effet verre)
  final bool topHighlight;
  final List<BoxShadow>? boxShadow;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: borderColor, width: borderWidth),
            boxShadow: boxShadow,
          ),
          child: topHighlight
              ? Stack(
                  children: [
                    // Inset highlight en haut — ligne de lumière
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 1,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              AppColors.glassHighlight,
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    child,
                  ],
                )
              : child,
        ),
      ),
    );
  }
}

/// Variante dark — fond sombre semi-opaque pour les cards sur fond neutre
class GlassDarkCard extends StatelessWidget {
  const GlassDarkCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppConstants.spacing16),
    this.borderRadius = AppConstants.radiusLarge,
    this.blurSigma = 16.0,
    this.boxShadow,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double blurSigma;
  final List<BoxShadow>? boxShadow;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: AppColors.gradientDark,
            ),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.28),
              width: 1,
            ),
            boxShadow: boxShadow ?? [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.15),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Badge / pill tag glassmorphism
class GlassPill extends StatelessWidget {
  const GlassPill({
    super.key,
    required this.child,
    this.color,
  });

  final Widget child;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: color ?? AppColors.glassWhite12,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: AppColors.glassBorderWhite,
              width: 0.8,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Carte liquid glass Z2 — pour les éléments hero (streak, modals, CTA)
/// Blur 28, specular highlight, refraction gradient, glow coloré
class LiquidGlassCard extends StatelessWidget {
  const LiquidGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = 24.0,
    this.accentColor = AppColors.primary,
    this.boxShadow,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color accentColor;
  final List<BoxShadow>? boxShadow;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final r = borderRadius;

    return ClipRRect(
      borderRadius: BorderRadius.circular(r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
        child: Container(
          decoration: BoxDecoration(
            // Fond teinté couleur — le violet "transparaît"
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: const [0.0, 0.50, 1.0],
              colors: isDark
                  ? [
                      accentColor.withValues(alpha: 0.20),
                      Colors.white.withValues(alpha: 0.04),
                      accentColor.withValues(alpha: 0.08),
                    ]
                  : [
                      Colors.white.withValues(alpha: 0.70),
                      accentColor.withValues(alpha: 0.06),
                      Colors.white.withValues(alpha: 0.50),
                    ],
            ),
            borderRadius: BorderRadius.circular(r),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.18)
                  : Colors.white.withValues(alpha: 0.85),
              width: 1.0,
            ),
            boxShadow: boxShadow ??
                [
                  // Glow couleur en dessous
                  BoxShadow(
                    color: accentColor.withValues(alpha: isDark ? 0.30 : 0.14),
                    blurRadius: 40,
                    spreadRadius: -4,
                    offset: const Offset(0, 14),
                  ),
                  // Ombre portée naturelle
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.40 : 0.08),
                    blurRadius: 18,
                    offset: const Offset(0, 4),
                  ),
                ],
          ),
          child: Stack(
            children: [
              // Refraction gradient diagonal — simule la lumière qui traverse
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(r),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        stops: const [0.0, 0.40, 1.0],
                        colors: [
                          Colors.white.withValues(alpha: isDark ? 0.09 : 0.32),
                          Colors.transparent,
                          Colors.white.withValues(alpha: isDark ? 0.02 : 0.06),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Specular highlight — fine ligne brillante en haut
              Positioned(
                top: 0,
                left: r * 0.5,
                right: r * 0.5,
                child: IgnorePointer(
                  child: Container(
                    height: 1.0,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.white.withValues(alpha: isDark ? 0.60 : 0.95),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Contenu
              Padding(padding: padding, child: child),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bouton glassmorphism
class GlassButton extends StatefulWidget {
  const GlassButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
  });

  final VoidCallback? onPressed;
  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  State<GlassButton> createState() => _GlassButtonState();
}

class _GlassButtonState extends State<GlassButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    _scale = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) => _ctrl.reverse(),
      onTapCancel: () => _ctrl.reverse(),
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) => Transform.scale(scale: _scale.value, child: child),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              padding: widget.padding,
              decoration: BoxDecoration(
                color: AppColors.glassWhite12,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: AppColors.glassBorderWhite, width: 1),
              ),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
