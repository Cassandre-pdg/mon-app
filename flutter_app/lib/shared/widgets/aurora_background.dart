import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Fond aurora animé — orbes colorés floutés qui dérivent
/// Inspiré du style SaaS dark-mode premium / Apple Vision Pro
class AuroraBackground extends StatefulWidget {
  const AuroraBackground({
    super.key,
    required this.child,
    this.orb1Color = AppColors.auroraViolet,
    this.orb2Color = AppColors.auroraPink,
    this.orb3Color = AppColors.auroraTeal,
    this.baseColor = AppColors.backgroundDark,
    this.blurSigma = 60.0,
  });

  final Widget child;
  final Color orb1Color;
  final Color orb2Color;
  final Color orb3Color;
  final Color baseColor;
  final double blurSigma;

  @override
  State<AuroraBackground> createState() => _AuroraBackgroundState();
}

class _AuroraBackgroundState extends State<AuroraBackground>
    with TickerProviderStateMixin {
  late final AnimationController _ctrl1;
  late final AnimationController _ctrl2;
  late final AnimationController _ctrl3;

  late final Animation<Offset> _orb1Anim;
  late final Animation<Offset> _orb2Anim;
  late final Animation<Offset> _orb3Anim;

  @override
  void initState() {
    super.initState();

    _ctrl1 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    _ctrl2 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);

    _ctrl3 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);

    _orb1Anim = Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(30, 20),
    ).animate(CurvedAnimation(parent: _ctrl1, curve: Curves.easeInOut));

    _orb2Anim = Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(-25, 15),
    ).animate(CurvedAnimation(parent: _ctrl2, curve: Curves.easeInOut));

    _orb3Anim = Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(20, -18),
    ).animate(CurvedAnimation(parent: _ctrl3, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl1.dispose();
    _ctrl2.dispose();
    _ctrl3.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Fond de base
        Container(color: widget.baseColor),

        // Orbe 1 — haut gauche, violet
        AnimatedBuilder(
          animation: _orb1Anim,
          builder: (_, __) => Positioned(
            top: -80 + _orb1Anim.value.dy,
            left: -60 + _orb1Anim.value.dx,
            child: _AuroraOrb(color: widget.orb1Color, size: 280, blur: widget.blurSigma),
          ),
        ),

        // Orbe 2 — bas droite, rose
        AnimatedBuilder(
          animation: _orb2Anim,
          builder: (_, __) => Positioned(
            bottom: -90 + _orb2Anim.value.dy,
            right: -40 + _orb2Anim.value.dx,
            child: _AuroraOrb(color: widget.orb2Color, size: 240, blur: widget.blurSigma),
          ),
        ),

        // Orbe 3 — milieu bas gauche, teal
        AnimatedBuilder(
          animation: _orb3Anim,
          builder: (_, __) => Positioned(
            bottom: 60 + _orb3Anim.value.dy,
            left: 50 + _orb3Anim.value.dx,
            child: _AuroraOrb(color: widget.orb3Color, size: 180, blur: widget.blurSigma),
          ),
        ),

        // Contenu
        widget.child,
      ],
    );
  }
}

class _AuroraOrb extends StatelessWidget {
  const _AuroraOrb({
    required this.color,
    required this.size,
    required this.blur,
  });

  final Color color;
  final double size;
  final double blur;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(color: color),
      ),
    );
  }
}


/// Version compacte utilisant CustomPaint + MaskFilter.blur (plus performant)
/// 4 orbes indépendantes, mouvements lents organiques, respiration de taille
class AuroraBackgroundPaint extends StatefulWidget {
  const AuroraBackgroundPaint({
    super.key,
    required this.child,
    this.orb1Color = AppColors.auroraViolet,
    this.orb2Color = AppColors.auroraPink,
    this.orb3Color = AppColors.auroraTeal,
    this.baseColor = AppColors.backgroundDark,
  });

  final Widget child;
  final Color orb1Color;
  final Color orb2Color;
  final Color orb3Color;
  final Color baseColor;

  @override
  State<AuroraBackgroundPaint> createState() => _AuroraBackgroundPaintState();
}

class _AuroraBackgroundPaintState extends State<AuroraBackgroundPaint>
    with TickerProviderStateMixin {
  // 3 dérives indépendantes + 1 respiration globale
  late final AnimationController _c1; // 18s — orbe violet, lent
  late final AnimationController _c2; // 26s — orbe rose, très lent
  late final AnimationController _c3; // 14s — orbe teal, moyen
  late final AnimationController _cp; // 9s  — respiration taille

  late final Animation<double> _a1, _a2, _a3, _ap;

  @override
  void initState() {
    super.initState();
    _c1 = AnimationController(vsync: this, duration: const Duration(seconds: 18))..repeat(reverse: true);
    _c2 = AnimationController(vsync: this, duration: const Duration(seconds: 26))..repeat(reverse: true);
    _c3 = AnimationController(vsync: this, duration: const Duration(seconds: 14))..repeat(reverse: true);
    _cp = AnimationController(vsync: this, duration: const Duration(seconds: 9))..repeat(reverse: true);
    _a1 = CurvedAnimation(parent: _c1, curve: Curves.easeInOut);
    _a2 = CurvedAnimation(parent: _c2, curve: Curves.easeInOut);
    _a3 = CurvedAnimation(parent: _c3, curve: Curves.easeInOut);
    _ap = CurvedAnimation(parent: _cp, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _c1.dispose(); _c2.dispose(); _c3.dispose(); _cp.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(color: widget.baseColor),
        // RepaintBoundary isole l'aurora du reste du widget tree
        RepaintBoundary(
          child: AnimatedBuilder(
            animation: Listenable.merge([_a1, _a2, _a3, _ap]),
            builder: (_, __) => CustomPaint(
              size: MediaQuery.sizeOf(context),
              painter: _AuroraPainter(
                t1: _a1.value,
                t2: _a2.value,
                t3: _a3.value,
                pulse: _ap.value,
                orb1: widget.orb1Color,
                orb2: widget.orb2Color,
                orb3: widget.orb3Color,
              ),
            ),
          ),
        ),
        widget.child,
      ],
    );
  }
}

class _AuroraPainter extends CustomPainter {
  const _AuroraPainter({
    required this.t1,
    required this.t2,
    required this.t3,
    required this.pulse,
    required this.orb1,
    required this.orb2,
    required this.orb3,
  });

  final double t1, t2, t3, pulse;
  final Color orb1, orb2, orb3;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Orbe 1 — haut gauche, violet, grande dérive
    _drawOrb(canvas,
      center: Offset(w * 0.12 + 75 * t1, h * 0.10 + 55 * t1),
      radius: w * (0.62 + 0.07 * pulse),
      color: orb1,
      blur: 88,
    );

    // Orbe 2 — bas droite, rose/mauve
    _drawOrb(canvas,
      center: Offset(w * 0.90 - 65 * t2, h * 0.84 + 48 * t2),
      radius: w * (0.54 + 0.06 * pulse),
      color: orb2,
      blur: 82,
    );

    // Orbe 3 — bas gauche, teal
    _drawOrb(canvas,
      center: Offset(w * 0.22 + 50 * t3, h * 0.76 - 42 * t3),
      radius: w * (0.40 + 0.05 * pulse),
      color: orb3,
      blur: 75,
    );

    // Orbe 4 — centre, violet pâle subtil, contre-mouvement
    _drawOrb(canvas,
      center: Offset(w * 0.60 - 35 * t1 + 20 * t2, h * 0.42 + 30 * t3),
      radius: w * (0.28 + 0.04 * pulse),
      color: orb1.withValues(alpha: orb1.a * 0.45),
      blur: 95,
    );
  }

  void _drawOrb(Canvas canvas, {
    required Offset center,
    required double radius,
    required Color color,
    required double blur,
  }) {
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = color
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur),
    );
  }

  @override
  bool shouldRepaint(_AuroraPainter old) =>
      old.t1 != t1 || old.t2 != t2 || old.t3 != t3 || old.pulse != pulse;
}
