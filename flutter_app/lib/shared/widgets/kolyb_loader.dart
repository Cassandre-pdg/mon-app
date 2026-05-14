import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

// ── Peintre du spinner ────────────────────────────────────────
class _SpinnerPainter extends CustomPainter {
  final double progress; // 0.0 → 1.0 (angle de la tête)
  final Color color;
  static const _count = 9;

  const _SpinnerPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;

    // Dimensions des segments (proportionnées à la taille totale)
    final spokeW = r * 0.26;
    final spokeH = r * 0.44;
    final innerR = r * 0.42;

    // Angle courant de la tête du spinner
    final leadAngle = 2 * pi * progress - pi / 2;

    for (int i = 0; i < _count; i++) {
      final angle = (2 * pi * i / _count) - pi / 2;

      // Distance angulaire depuis la tête (dans le sens horaire)
      double dist = (angle - leadAngle) % (2 * pi);
      if (dist < 0) dist += 2 * pi;

      // Opacité : 1.0 à la tête → 0.08 en queue
      final opacity = (1.0 - dist / (2 * pi)).clamp(0.08, 1.0);

      final paint = Paint()
        ..color = color.withValues(alpha: opacity)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(angle);

      final segmentCenter = Offset(0, -(innerR + spokeH / 2));
      final rrect = RRect.fromRectAndRadius(
        Rect.fromCenter(center: segmentCenter, width: spokeW, height: spokeH),
        Radius.circular(spokeW / 2),
      );

      canvas.drawRRect(rrect, paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_SpinnerPainter old) =>
      old.progress != progress || old.color != color;
}

// ── Widget principal ──────────────────────────────────────────
/// Loader Kolyb — spinner 9 segments en cercle.
/// Clair sur fond sombre, sombre sur fond clair. Léger et subtil.
class KolybLoader extends StatefulWidget {
  /// Diamètre total du spinner en pixels.
  final double size;

  /// Couleur de base (override automatique dark/light si non fourni).
  final Color? color;

  const KolybLoader({super.key, this.size = 24.0, this.color});

  @override
  State<KolybLoader> createState() => _KolybLoaderState();
}

class _KolybLoaderState extends State<KolybLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = widget.color ??
        (isDark
            ? Colors.white
            : AppColors.textLight);

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => CustomPaint(
        size: Size(widget.size, widget.size),
        painter: _SpinnerPainter(
          progress: _ctrl.value,
          color: baseColor,
        ),
      ),
    );
  }
}

// ── Variante plein écran ──────────────────────────────────────
class KolybLoaderScreen extends StatelessWidget {
  const KolybLoaderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: KolybLoader(size: 32));
  }
}
