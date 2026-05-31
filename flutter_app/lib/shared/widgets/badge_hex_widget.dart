import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Widget hexagonal pour afficher un badge — 3 niveaux de rareté :
/// - common   : hex + gradient
/// - rare     : hex + anneau intérieur concentrique
/// - legendary: hex + double anneau + glow pulsant animé
class BadgeHexWidget extends StatefulWidget {
  final List<Color> gradientColors;
  final IconData icon;
  final bool isUnlocked;
  final bool isLegendary;
  final bool isRare;
  final Color categoryColor;
  final double size;
  final double? progress; // 0.0–1.0 pour l'anneau de progression (badges verrouillés)

  const BadgeHexWidget({
    super.key,
    required this.gradientColors,
    required this.icon,
    required this.isUnlocked,
    this.isLegendary = false,
    this.isRare = false,
    required this.categoryColor,
    this.size = 68,
    this.progress,
  });

  @override
  State<BadgeHexWidget> createState() => _BadgeHexWidgetState();
}

class _BadgeHexWidgetState extends State<BadgeHexWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
    if (widget.isUnlocked && widget.isLegendary) {
      _ctrl.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isUnlocked) return _buildLocked();
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => _buildUnlocked(_anim.value),
    );
  }

  Widget _buildLocked() {
    final s = widget.size;
    final totalSize = s + 16;
    final progress = (widget.progress ?? 0.0).clamp(0.0, 1.0);
    final hasArc = widget.progress != null && progress > 0;

    return SizedBox(
      width: totalSize,
      height: totalSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (hasArc)
            CustomPaint(
              size: Size(totalSize, totalSize),
              painter: ProgressArcPainter(
                progress: progress,
                color: widget.categoryColor,
              ),
            ),
          SizedBox(
            width: s,
            height: s,
            child: Stack(
              children: [
                CustomPaint(
                  size: Size(s, s),
                  painter: HexFillPainter(const [
                    Color(0xFF1E1C38),
                    Color(0xFF15132E),
                  ]),
                ),
                const Center(
                  child: Icon(
                    Icons.lock_rounded,
                    color: Color(0x36EDEDED),
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnlocked(double t) {
    final s = widget.size;
    final totalSize = s + (widget.isLegendary ? 24.0 : 16.0);
    final isRare = widget.isRare || widget.isLegendary;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Halo radial
        Container(
          width: widget.isLegendary ? totalSize + 8 * t : totalSize,
          height: widget.isLegendary ? totalSize + 8 * t : totalSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                widget.gradientColors.first.withValues(
                  alpha: widget.isLegendary
                      ? 0.28 + 0.24 * t
                      : (isRare ? 0.22 : 0.16),
                ),
                Colors.transparent,
              ],
            ),
          ),
        ),
        // Hex
        SizedBox(
          width: s,
          height: s,
          child: Stack(
            children: [
              CustomPaint(
                size: Size(s, s),
                painter: HexFillPainter(widget.gradientColors),
              ),
              // Anneau concentrique interne (rare + legendary)
              if (isRare)
                CustomPaint(
                  size: Size(s, s),
                  painter: _HexRingPainter(
                    color: Colors.white.withValues(
                      alpha: widget.isLegendary ? 0.18 + 0.18 * t : 0.18,
                    ),
                    radiusRatio: 0.88 * 0.76,
                  ),
                ),
              // Anneau externe légendaire (pulsant)
              if (widget.isLegendary)
                CustomPaint(
                  size: Size(s, s),
                  painter: _HexRingPainter(
                    color: widget.gradientColors.last.withValues(
                      alpha: 0.28 + 0.28 * t,
                    ),
                    radiusRatio: 0.88 * 0.92,
                  ),
                ),
              Center(
                child: Icon(
                  widget.icon,
                  color: Colors.white,
                  size: s * 0.40,
                  shadows: const [
                    Shadow(color: Color(0x55000000), blurRadius: 8),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Hex rempli gradient ───────────────────────────────────────
class HexFillPainter extends CustomPainter {
  final List<Color> colors;
  const HexFillPainter(this.colors);

  @override
  void paint(Canvas canvas, Size size) {
    final path = hexPath(size, 0.88);
    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors.length >= 2 ? colors : [colors.first, colors.first],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.16)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(HexFillPainter old) => false;
}

// ── Anneau hex interne ────────────────────────────────────────
class _HexRingPainter extends CustomPainter {
  final Color color;
  final double radiusRatio;
  const _HexRingPainter({required this.color, required this.radiusRatio});

  @override
  void paint(Canvas canvas, Size size) {
    final path = hexPath(size, radiusRatio);
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
  }

  @override
  bool shouldRepaint(_HexRingPainter old) => old.color != color;
}

// ── Arc de progression ────────────────────────────────────────
class ProgressArcPainter extends CustomPainter {
  final double progress;
  final Color color;
  const ProgressArcPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 2;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.07)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(ProgressArcPainter old) => old.progress != progress;
}

// ── Helper : chemin hexagonal ─────────────────────────────────
Path hexPath(Size size, double radiusRatio) {
  final cx = size.width / 2;
  final cy = size.height / 2;
  final r = math.min(cx, cy) * radiusRatio;
  final path = Path();
  for (int i = 0; i < 6; i++) {
    final angle = (i * 60 - 90) * math.pi / 180;
    final x = cx + r * math.cos(angle);
    final y = cy + r * math.sin(angle);
    i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
  }
  path.close();
  return path;
}
