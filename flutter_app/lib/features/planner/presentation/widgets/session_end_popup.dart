import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../data/session_context_model.dart';

enum SessionEndAction { completed, restart, later }

class SessionEndPopup extends StatefulWidget {
  final String timerType; // 'flow' | 'pomodoro'
  final int durationMinutes;
  final SessionContext? sessionContext;

  const SessionEndPopup({
    super.key,
    required this.timerType,
    required this.durationMinutes,
    this.sessionContext,
  });

  static Future<SessionEndAction?> show(
    BuildContext context, {
    required String timerType,
    required int durationMinutes,
    SessionContext? sessionContext,
  }) {
    return showModalBottomSheet<SessionEndAction>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (_) => SessionEndPopup(
        timerType: timerType,
        durationMinutes: durationMinutes,
        sessionContext: sessionContext,
      ),
    );
  }

  @override
  State<SessionEndPopup> createState() => _SessionEndPopupState();
}

class _SessionEndPopupState extends State<SessionEndPopup>
    with TickerProviderStateMixin {
  late final AnimationController _entryCtrl;
  late final AnimationController _particlesCtrl;
  late final AnimationController _emojiCtrl;
  late final Animation<double> _slideAnim;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _emojiAnim;

  @override
  void initState() {
    super.initState();

    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    _particlesCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _emojiCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _slideAnim = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutCubic);
    _fadeAnim  = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);
    _emojiAnim = CurvedAnimation(parent: _emojiCtrl, curve: Curves.elasticOut);

    _entryCtrl.forward();
    _particlesCtrl.forward();
    Future.delayed(const Duration(milliseconds: 200),
        () => _emojiCtrl.forward());
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _particlesCtrl.dispose();
    _emojiCtrl.dispose();
    super.dispose();
  }

  bool get _isFlow => widget.timerType == 'flow';

  List<Color> get _gradientColors => _isFlow
      ? [AppColors.primary, AppColors.primaryLight]
      : [AppColors.secondary, AppColors.chartAmber];

  Color get _accentColor => _isFlow ? AppColors.primary : AppColors.secondary;

  String get _emoji => _isFlow ? '⚡' : '🍅';

  String get _title =>
      '${widget.durationMinutes} minutes bouclées !';

  String get _encouragement {
    if (widget.sessionContext == null) {
      return 'Tu avances à ton rythme. C\'est ce qui compte.';
    }
    if (_isFlow) {
      return '${widget.durationMinutes} min de focus, c\'est une vraie performance. Bravo !';
    }
    return 'Belle concentration. Chaque session te rapproche de ton objectif.';
  }

  String get _completedLabel {
    switch (widget.sessionContext?.type) {
      case SessionContextType.flash:
        return 'Bloc Flash traité';
      case SessionContextType.other:
        return 'Session notée';
      default:
        return 'Tâche complétée';
    }
  }

  String get _breakLabel => _isFlow
      ? 'Pause 10 min, on repart'
      : 'Pause 5 min, on repart';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size   = MediaQuery.of(context).size;

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(_slideAnim),
      child: FadeTransition(
        opacity: _fadeAnim,
        child: Stack(
          children: [
            // Particules en arrière-plan
            AnimatedBuilder(
              animation: _particlesCtrl,
              builder: (_, __) => CustomPaint(
                size: Size(size.width, 220),
                painter: _EndParticlesPainter(
                  progress: _particlesCtrl.value,
                  colors: _gradientColors,
                ),
              ),
            ),

            // Card principale
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceElevatedDark : Colors.white,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: [
                  BoxShadow(
                    color: _accentColor.withValues(alpha: 0.18),
                    blurRadius: 40,
                    offset: const Offset(0, -8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Bande gradient
                  Container(
                    height: 5,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: _gradientColors),
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(28)),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(28, 28, 28, 32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Emoji animé
                        ScaleTransition(
                          scale: _emojiAnim,
                          child: Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  _accentColor.withValues(alpha: 0.20),
                                  _accentColor.withValues(alpha: 0.05),
                                ],
                              ),
                            ),
                            child: Center(
                              child: Text(
                                _emoji,
                                style: const TextStyle(fontSize: 36),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Titre durée
                        Text(
                          _title,
                          style: AppTextStyles.headingLarge(
                            color: isDark
                                ? AppColors.textDark
                                : AppColors.textLight,
                          ).copyWith(fontSize: 22),
                          textAlign: TextAlign.center,
                        ),

                        // Pill tâche
                        if (widget.sessionContext != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            'Tu viens d\'avancer sur',
                            style: AppTextStyles.bodySmall(
                                color: AppColors.grey400),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 7),
                            decoration: BoxDecoration(
                              color: _accentColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _accentColor.withValues(alpha: 0.30),
                              ),
                            ),
                            child: Text(
                              widget.sessionContext!.label,
                              style: AppTextStyles.labelMedium(
                                      color: _accentColor)
                                  .copyWith(fontWeight: FontWeight.w700),
                              maxLines: 2,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],

                        const SizedBox(height: 14),

                        // Message encouragement
                        Text(
                          _encouragement,
                          style: AppTextStyles.bodyMedium(
                                  color: AppColors.grey400)
                              .copyWith(height: 1.5),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 28),

                        // Bouton 1 — Tâche complétée
                        _PopupButton(
                          label: _completedLabel,
                          icon: Icons.check_circle_rounded,
                          gradientColors: _gradientColors,
                          style: _ButtonStyle.primary,
                          onTap: () => Navigator.pop(
                              context, SessionEndAction.completed),
                        ),
                        const SizedBox(height: 10),

                        // Bouton 2 — Pause + relancer
                        _PopupButton(
                          label: _breakLabel,
                          icon: Icons.coffee_rounded,
                          accentColor: AppColors.accent,
                          style: _ButtonStyle.secondary,
                          onTap: () => Navigator.pop(
                              context, SessionEndAction.restart),
                        ),
                        const SizedBox(height: 6),

                        // Bouton 3 — Plus tard
                        TextButton.icon(
                          onPressed: () => Navigator.pop(
                              context, SessionEndAction.later),
                          icon: Icon(
                            Icons.arrow_forward_rounded,
                            size: 16,
                            color: AppColors.grey400,
                          ),
                          label: Text(
                            'Continuer plus tard',
                            style: AppTextStyles.bodyMedium(
                                color: AppColors.grey400),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Styles de bouton ──────────────────────────────────────────
enum _ButtonStyle { primary, secondary }

class _PopupButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final _ButtonStyle style;
  final List<Color>? gradientColors;
  final Color? accentColor;
  final VoidCallback onTap;

  const _PopupButton({
    required this.label,
    required this.icon,
    required this.style,
    required this.onTap,
    this.gradientColors,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    if (style == _ButtonStyle.primary) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          height: 54,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors!,
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(27),
            boxShadow: [
              BoxShadow(
                color: gradientColors!.first.withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: AppTextStyles.headingSmall(color: Colors.white),
              ),
            ],
          ),
        ),
      );
    }

    // Secondary
    final color = accentColor ?? AppColors.accent;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: color.withValues(alpha: 0.30),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTextStyles.bodyMedium(color: color)
                  .copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Particules de célébration ─────────────────────────────────
class _EndParticlesPainter extends CustomPainter {
  final double progress;
  final List<Color> colors;

  static final _rng = math.Random(99);
  static final _particles = List.generate(20, (_) {
    return (
      angle: _rng.nextDouble() * math.pi + math.pi,
      speed: 0.4 + _rng.nextDouble() * 0.6,
      size:  2.0 + _rng.nextDouble() * 4.0,
      offset: _rng.nextDouble(),
    );
  });

  const _EndParticlesPainter({required this.progress, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in _particles) {
      final opacity = (1.0 - progress * 1.2).clamp(0.0, 1.0);
      if (opacity <= 0) continue;

      final dist = size.height * 0.6 * p.speed * progress;
      final x = size.width * p.offset;
      final y = -dist * 0.5;

      canvas.drawCircle(
        Offset(x, y),
        p.size * (1 - progress * 0.4),
        Paint()
          ..color = (progress < 0.5 ? colors.first : colors.last)
              .withValues(alpha: opacity * 0.7),
      );
    }
  }

  @override
  bool shouldRepaint(_EndParticlesPainter old) => old.progress != progress;
}
