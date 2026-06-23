import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/constants/app_constants.dart';
import '../../data/models/meditation.dart';
import '../../../../shared/widgets/kolyb_loader.dart';

class MeditationPlayerScreen extends StatefulWidget {
  final Meditation meditation;
  const MeditationPlayerScreen({super.key, required this.meditation});

  @override
  State<MeditationPlayerScreen> createState() => _MeditationPlayerScreenState();
}

class _MeditationPlayerScreenState extends State<MeditationPlayerScreen>
    with SingleTickerProviderStateMixin {
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;
  bool _isLoading = true;
  bool _hasError = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  StreamSubscription? _positionSub;
  StreamSubscription? _durationSub;
  StreamSubscription? _stateSub;

  @override
  void initState() {
    super.initState();

    // Animation de pulsation de l'emoji/image
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _pulseAnim = Tween(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    _initPlayer();
  }

  Future<void> _initPlayer() async {
    try {
      _positionSub = _player.positionStream.listen((pos) {
        if (mounted) setState(() => _position = pos);
      });
      _durationSub = _player.durationStream.listen((dur) {
        if (mounted && dur != null) setState(() => _duration = dur);
      });
      _stateSub = _player.playerStateStream.listen((state) {
        if (mounted) {
          setState(() {
            _isPlaying = state.playing;
            if (state.processingState == ProcessingState.completed) {
              _position = Duration.zero;
            }
          });
        }
      });

      await _player.setAsset(widget.meditation.audioAssetPath);
      if (mounted) setState(() => _isLoading = false);
    } catch (e) {
      debugPrint('🔴 AUDIO ERROR: $e | path: ${widget.meditation.audioAssetPath}');
      if (mounted) setState(() { _isLoading = false; _hasError = true; });
    }
  }

  Future<void> _togglePlay() async {
    if (_hasError) return;
    if (_isPlaying) {
      await _player.pause();
    } else {
      if (_position >= _duration && _duration > Duration.zero) {
        await _player.seek(Duration.zero);
      }
      await _player.play();
    }
  }

  Future<void> _seekTo(double value) async {
    if (_duration == Duration.zero) return;
    final target = Duration(
      milliseconds: (value * _duration.inMilliseconds).round(),
    );
    await _player.seek(target);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _positionSub?.cancel();
    _durationSub?.cancel();
    _stateSub?.cancel();
    _player.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.meditation.theme;
    final totalDuration = _duration > Duration.zero
        ? _duration
        : Duration(minutes: widget.meditation.durationMinutes);
    final progress = _duration > Duration.zero
        ? (_position.inMilliseconds / _duration.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Stack(
        children: [
          // ── Fond dégradé thème ────────────────────────────────
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.gradient[0].withValues(alpha: 0.9),
                    AppColors.backgroundDark,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.5],
                ),
              ),
            ),
          ),

          // ── Contenu ───────────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                // Bouton retour
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => context.pop(),
                        icon: const Icon(Icons.keyboard_arrow_down_rounded),
                        color: AppColors.textDark,
                        iconSize: 32,
                      ),
                      const Spacer(),
                      // Pill thème
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: theme.color.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(AppConstants.radiusPill),
                        ),
                        child: Text(
                          '${theme.emoji} ${theme.label}',
                          style: AppTextStyles.labelMedium(color: theme.color),
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // ── Illustration centrale (pulsée) ─────────────
                AnimatedBuilder(
                  animation: _pulseAnim,
                  builder: (_, __) => Transform.scale(
                    scale: _isPlaying ? _pulseAnim.value : 1.0,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            theme.color.withValues(alpha: 0.3),
                            theme.gradient[0].withValues(alpha: 0.8),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: theme.color.withValues(alpha: 0.4),
                            blurRadius: 60,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          theme.emoji,
                          style: const TextStyle(fontSize: 72),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppConstants.spacing32),

                // ── Titre & description ────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    children: [
                      Text(
                        widget.meditation.title,
                        style: AppTextStyles.headingLarge(
                          color: AppColors.textDark,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppConstants.spacing8),
                      Text(
                        widget.meditation.description,
                        style: AppTextStyles.bodyMedium(
                          color: AppColors.textDarkMuted,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // ── Barre de progression ───────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    children: [
                      // Message si audio manquant
                      if (_hasError)
                        Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.chartAmber.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline_rounded,
                                  color: AppColors.chartAmber, size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Ajoute le fichier audio dans assets/audio/meditations/',
                                  style: AppTextStyles.caption(
                                    color: AppColors.chartAmber,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Slider progression
                      SliderTheme(
                        data: SliderThemeData(
                          trackHeight: 3,
                          thumbShape:
                              const RoundSliderThumbShape(enabledThumbRadius: 6),
                          overlayShape:
                              const RoundSliderOverlayShape(overlayRadius: 16),
                          activeTrackColor: theme.color,
                          inactiveTrackColor: AppColors.textDarkMuted.withValues(alpha: 0.3),
                          thumbColor: AppColors.textDark,
                          overlayColor: theme.color.withValues(alpha: 0.2),
                        ),
                        child: Slider(
                          value: progress,
                          onChanged: _hasError ? null : _seekTo,
                        ),
                      ),

                      // Temps
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatDuration(_position),
                              style: AppTextStyles.caption(
                                color: AppColors.textDarkMuted,
                              ),
                            ),
                            Text(
                              _formatDuration(totalDuration),
                              style: AppTextStyles.caption(
                                color: AppColors.textDarkMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppConstants.spacing24),

                // ── Contrôles ──────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Recul 15s
                    IconButton(
                      onPressed: _hasError ? null : () async {
                        final target = _position - const Duration(seconds: 15);
                        await _player.seek(
                          target.isNegative ? Duration.zero : target,
                        );
                      },
                      icon: const Icon(Icons.replay_10_rounded),
                      color: AppColors.textDarkMuted,
                      iconSize: 32,
                    ),
                    const SizedBox(width: 16),

                    // Play / Pause
                    GestureDetector(
                      onTap: _isLoading ? null : _togglePlay,
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.color,
                          boxShadow: [
                            BoxShadow(
                              color: theme.color.withValues(alpha: 0.4),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: _isLoading
                            ? const Center(
                                child: KolybLoader(size: 6, color: Colors.white),
                              )
                            : Icon(
                                _isPlaying
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 36,
                              ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Avance 15s
                    IconButton(
                      onPressed: _hasError ? null : () async {
                        final target = _position + const Duration(seconds: 15);
                        await _player.seek(
                          target > _duration ? _duration : target,
                        );
                      },
                      icon: const Icon(Icons.forward_10_rounded),
                      color: AppColors.textDarkMuted,
                      iconSize: 32,
                    ),
                  ],
                ),

                const SizedBox(height: AppConstants.spacing16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
