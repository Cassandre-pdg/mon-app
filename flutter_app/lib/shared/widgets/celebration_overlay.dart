import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import '../services/celebration_service.dart';
import '../theme/app_colors.dart';

// ── Config par événement ──────────────────────────────────────────────────────
class CelebrationConfig {
  const CelebrationConfig({
    required this.label,
    required this.title,
    required this.subtitle,
    required this.points,
    required this.gradientColors,
    required this.particleColors,
    required this.accentColor,
    required this.icon,
    required this.particleCount,
    required this.duration,
  });

  final String label;
  final String title;
  final String subtitle;
  final String points;
  final List<Color> gradientColors;
  final List<Color> particleColors;
  final Color accentColor;
  final IconData icon;
  final int particleCount;
  final Duration duration;

  static CelebrationConfig fromEvent(CelebrationEvent event) {
    switch (event) {
      case CelebrationEvent.taskCompleted:
        return const CelebrationConfig(
          label: 'TÂCHE ACCOMPLIE',
          title: 'Bien joué !',
          subtitle: 'Une priorité de moins,\ntu avances à ton rythme.',
          points: '⭐  +10 pts',
          gradientColors: [AppColors.accent, AppColors.primaryLight],
          particleColors: [AppColors.accent, AppColors.primaryLight, AppColors.primaryPale],
          accentColor: AppColors.accent,
          icon: Icons.check_rounded,
          particleCount: 32,
          duration: Duration(milliseconds: 2500),
        );

      case CelebrationEvent.flashTaskDone:
        return const CelebrationConfig(
          label: 'FLASH ⚡',
          title: 'Micro-tâche validée !',
          subtitle: 'Petite action, grande énergie.',
          points: '⭐  +5 pts',
          gradientColors: [AppColors.chartAmber, AppColors.secondary],
          particleColors: [AppColors.chartAmber, AppColors.secondary, Colors.white],
          accentColor: AppColors.chartAmber,
          icon: Icons.bolt_rounded,
          particleCount: 28,
          duration: Duration(milliseconds: 2000),
        );

      case CelebrationEvent.flashBlocCompleted:
        return const CelebrationConfig(
          label: 'BLOC FLASH TERMINÉ',
          title: 'Session accomplie !',
          subtitle: 'Tu as tout géré ce bloc.\nRepose-toi bien.',
          points: '⭐  +15 pts',
          gradientColors: [AppColors.primary, AppColors.primaryPale],
          particleColors: [AppColors.primary, AppColors.primaryLight, AppColors.chartAmber, AppColors.primaryPale],
          accentColor: AppColors.primaryPale,
          icon: Icons.adjust_rounded,
          particleCount: 50,
          duration: Duration(milliseconds: 3000),
        );

      case CelebrationEvent.habitCompleted:
        return const CelebrationConfig(
          label: 'HABITUDE DU JOUR',
          title: 'Routine respectée !',
          subtitle: 'Chaque jour, tu construis\nquelque chose de durable.',
          points: '⭐  +5 pts',
          gradientColors: [AppColors.accent, AppColors.primary],
          particleColors: [AppColors.accent, AppColors.primaryPale],
          accentColor: AppColors.accent,
          icon: Icons.eco_rounded,
          particleCount: 30,
          duration: Duration(milliseconds: 2500),
        );

      case CelebrationEvent.objectiveCompleted:
        return CelebrationConfig(
          label: 'GRANDE VICTOIRE 🏆',
          title: 'Objectif atteint !',
          subtitle: 'Tu l\'as fait. Prends un moment\npour savourer ça.',
          points: '⭐  +50 pts',
          gradientColors: const [AppColors.primaryDark, AppColors.primaryPale, AppColors.chartAmber],
          particleColors: const [AppColors.primary, AppColors.primaryPale, AppColors.chartAmber, AppColors.secondary, AppColors.accent],
          accentColor: AppColors.primaryPale,
          icon: Icons.emoji_events_rounded,
          particleCount: 80,
          duration: const Duration(milliseconds: 4500),
        );

      case CelebrationEvent.checkinDone:
        return const CelebrationConfig(
          label: 'CHECK-IN DU JOUR',
          title: 'Check-in complété !',
          subtitle: 'Tu te connais un peu\nmieux chaque jour.',
          points: '⭐  +5 pts',
          gradientColors: [AppColors.primaryLight, AppColors.primaryPale],
          particleColors: [AppColors.primaryLight, AppColors.primaryPale, AppColors.primary],
          accentColor: AppColors.primaryLight,
          icon: Icons.wb_sunny_rounded,
          particleCount: 35,
          duration: Duration(milliseconds: 2500),
        );
    }
  }
}

// ── Particule de confetti ─────────────────────────────────────────────────────
class _Particle {
  _Particle(math.Random rng, List<Color> colors)
      : startX = rng.nextDouble(),
        vy = 0.18 + rng.nextDouble() * 0.30,
        vx = (rng.nextDouble() - 0.5) * 0.18,
        delay = rng.nextDouble() * 0.5,
        color = colors[rng.nextInt(colors.length)],
        size = 6.0 + rng.nextDouble() * 7.0,
        isRect = rng.nextDouble() > 0.4,
        rotSpeed = (rng.nextDouble() - 0.5) * 8.0;

  final double startX;
  final double vy;
  final double vx;
  final double delay;
  final Color color;
  final double size;
  final bool isRect;
  final double rotSpeed;
}

// ── CustomPainter confetti ────────────────────────────────────────────────────
class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.particles, this.progress);
  final List<_Particle> particles;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (final p in particles) {
      if (progress < p.delay) continue;
      final t = ((progress - p.delay) / (1.0 - p.delay.clamp(0.0, 0.98))).clamp(0.0, 1.0);
      if (t >= 1.0) continue;
      final opacity = t > 0.75 ? ((1.0 - (t - 0.75) / 0.25)).clamp(0.0, 1.0) : 1.0;
      paint.color = p.color.withValues(alpha: opacity * 0.88);
      final x = (p.startX + p.vx * t) * size.width;
      final y = t * size.height * 1.05;
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(p.rotSpeed * t);
      if (p.isRect) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.42),
            const Radius.circular(2),
          ),
          paint,
        );
      } else {
        canvas.drawCircle(Offset.zero, p.size / 2, paint);
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.progress != progress;
}

// ── Hexagone badge painter ────────────────────────────────────────────────────
class _HexPainter extends CustomPainter {
  _HexPainter(this.colors);
  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = math.min(cx, cy) * 0.90;

    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (i * 60 - 90) * math.pi / 180;
      final x = cx + r * math.cos(angle);
      final y = cy + r * math.sin(angle);
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    path.close();

    // Gradient fill
    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors.length >= 2 ? colors : [colors.first, colors.first],
        ).createShader(Offset.zero & size)
        ..style = PaintingStyle.fill,
    );

    // Bordure inner highlight
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(_HexPainter old) => false;
}

// ── Widget principal ──────────────────────────────────────────────────────────
class CelebrationOverlay extends StatefulWidget {
  const CelebrationOverlay({
    super.key,
    required this.event,
    required this.onDismiss,
  });

  final CelebrationEvent event;
  final VoidCallback onDismiss;

  @override
  State<CelebrationOverlay> createState() => _CelebrationOverlayState();
}

class _CelebrationOverlayState extends State<CelebrationOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _cardCtrl;
  late final AnimationController _confettiCtrl;
  late final AnimationController _glowCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _scaleAnim;
  late final CelebrationConfig _config;
  late final List<_Particle> _particles;
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    _config = CelebrationConfig.fromEvent(widget.event);

    // Pop-in de la card
    _cardCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    )..forward();

    _fadeAnim = CurvedAnimation(parent: _cardCtrl, curve: Curves.easeOut);
    _scaleAnim = Tween<double>(begin: 0.72, end: 1.0).animate(
      CurvedAnimation(parent: _cardCtrl, curve: Curves.elasticOut),
    );

    // Pluie de confettis pendant toute la durée
    _confettiCtrl = AnimationController(
      vsync: this,
      duration: _config.duration,
    )..forward();

    // Pulsation glow autour du badge
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    // Génération des particules
    final rng = math.Random();
    _particles = List.generate(
      _config.particleCount,
      (_) => _Particle(rng, _config.particleColors),
    );

    // Auto-dismiss
    _dismissTimer = Timer(
      _config.duration + const Duration(milliseconds: 600),
      widget.onDismiss,
    );
  }

  @override
  void dispose() {
    _cardCtrl.dispose();
    _confettiCtrl.dispose();
    _glowCtrl.dispose();
    _dismissTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onDismiss,
      child: Stack(
        children: [
          // Fond flouté
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(color: const Color(0xBA09071E)),
          ),

          // Confettis
          AnimatedBuilder(
            animation: _confettiCtrl,
            builder: (context, _) => CustomPaint(
              size: MediaQuery.of(context).size,
              painter: _ConfettiPainter(_particles, _confettiCtrl.value),
            ),
          ),

          // Card centrée
          Center(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: ScaleTransition(
                scale: _scaleAnim,
                child: _buildCard(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard() {
    return GestureDetector(
      // Absorbe les taps sur la card pour ne pas fermer accidentellement
      onTap: () {},
      child: SizedBox(
        width: 280,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Badge flottant
            _buildBadge(),

            // Body de la card (le badge déborde en haut via margin négative)
            Container(
              margin: const EdgeInsets.only(top: -44),
              decoration: BoxDecoration(
                color: const Color(0xF5161432),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.55),
                    blurRadius: 60,
                    offset: const Offset(0, 20),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 58, 24, 24),
                child: Column(
                  children: [
                    // Label
                    Text(
                      _config.label,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                        color: _config.accentColor,
                        fontFamily: 'Inter',
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Titre
                    Text(
                      _config.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFEDEDFF),
                        letterSpacing: -0.4,
                        fontFamily: 'Inter',
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Sous-titre
                    Text(
                      _config.subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0x80EDEDFF),
                        height: 1.55,
                        fontFamily: 'Inter',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),

                    // Pill de points
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: _config.accentColor.withValues(alpha: 0.15),
                        border: Border.all(
                          color: _config.accentColor.withValues(alpha: 0.3),
                        ),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Text(
                        _config.points,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _config.accentColor,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Bouton CTA avec gradient
                    GestureDetector(
                      onTap: widget.onDismiss,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _config.gradientColors.first,
                              _config.gradientColors.last,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(50),
                          boxShadow: [
                            BoxShadow(
                              color: _config.accentColor.withValues(alpha: 0.4),
                              blurRadius: 18,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            'Super !',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Barre de timer
                    const SizedBox(height: 16),
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 1.0, end: 0.0),
                      duration: _config.duration,
                      builder: (_, value, __) => ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: value,
                          backgroundColor: Colors.white.withValues(alpha: 0.06),
                          valueColor: AlwaysStoppedAnimation(
                            _config.accentColor.withValues(alpha: 0.5),
                          ),
                          minHeight: 2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge() {
    return AnimatedBuilder(
      animation: _glowCtrl,
      builder: (_, child) {
        final glowOpacity = 0.5 + 0.5 * _glowCtrl.value;
        final glowScale = 0.85 + 0.3 * _glowCtrl.value;
        return Stack(
          alignment: Alignment.center,
          children: [
            // Anneau de glow pulsant
            Transform.scale(
              scale: glowScale,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _config.accentColor.withValues(alpha: 0.38 * glowOpacity),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            child!,
          ],
        );
      },
      child: SizedBox(
        width: 100,
        height: 100,
        child: Stack(
          children: [
            // Hexagone avec gradient
            CustomPaint(
              size: const Size(100, 100),
              painter: _HexPainter(_config.gradientColors),
            ),
            // Icône centrée
            Center(
              child: Icon(
                _config.icon,
                color: Colors.white,
                size: 44,
                shadows: const [
                  Shadow(color: Color(0x4D000000), blurRadius: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
