import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../services/focus_audio_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Bloc toggle audio style Apple pour Pomodoro et Flow.
/// Affiché juste avant les contrôles du timer.
/// Gère l'activation/désactivation de la musique focus via [FocusAudioService].
class FocusAudioToggle extends StatefulWidget {
  const FocusAudioToggle({
    super.key,
    this.accentColor,
    this.onChanged,
    this.trackLabel,
  });

  /// Couleur d'accent du timer en cours (corail pour Pomodoro work, violet pour Flow)
  final Color? accentColor;

  /// Callback appelé quand l'utilisateur change l'état du toggle
  final void Function(bool enabled)? onChanged;

  /// Libellé de la piste (ex. "Beta 20 Hz · 25 min" ou "Gamma 40 Hz · 90 min")
  final String? trackLabel;

  @override
  State<FocusAudioToggle> createState() => _FocusAudioToggleState();
}

class _FocusAudioToggleState extends State<FocusAudioToggle> {
  bool _enabled = true;

  @override
  void initState() {
    super.initState();
    _enabled = FocusAudioService.instance.isEnabled;
  }

  Future<void> _toggle(bool value) async {
    setState(() => _enabled = value);
    await FocusAudioService.instance.setEnabled(value);
    widget.onChanged?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.accentColor ?? AppColors.primary;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: _enabled
                ? accent.withValues(alpha: 0.10)
                : Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _enabled
                  ? accent.withValues(alpha: 0.28)
                  : Colors.white.withValues(alpha: 0.10),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Icône
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _enabled
                      ? accent.withValues(alpha: 0.18)
                      : Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _enabled
                      ? Icons.headphones_rounded
                      : Icons.headphones_outlined,
                  color: _enabled
                      ? accent
                      : Colors.white.withValues(alpha: 0.30),
                  size: 18,
                ),
              ),

              const SizedBox(width: 12),

              // Texte
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Musique focus',
                      style: AppTextStyles.labelMedium(
                        color: _enabled
                            ? Colors.white.withValues(alpha: 0.90)
                            : Colors.white.withValues(alpha: 0.40),
                      ).copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _enabled
                          ? (widget.trackLabel ?? 'Lo-fi · Ambiant')
                          : 'Désactivée',
                      style: AppTextStyles.caption(
                        color: _enabled
                            ? accent.withValues(alpha: 0.70)
                            : Colors.white.withValues(alpha: 0.22),
                      ),
                    ),
                  ],
                ),
              ),

              // Toggle Apple (CupertinoSwitch)
              CupertinoSwitch(
                value: _enabled,
                onChanged: _toggle,
                activeTrackColor: accent,
                inactiveTrackColor: Colors.white.withValues(alpha: 0.12),
                thumbColor: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
