import 'package:just_audio/just_audio.dart';
import 'package:logger/logger.dart';

/// Ambiances sonores disponibles pour Pomodoro et Flow
enum FocusAudio {
  silence,
  rain,
  waves,
  lofi,
  nature,
  whiteNoise,
}

extension FocusAudioExt on FocusAudio {
  String get label {
    switch (this) {
      case FocusAudio.silence:    return 'Silence';
      case FocusAudio.rain:       return 'Pluie';
      case FocusAudio.waves:      return 'Vagues';
      case FocusAudio.lofi:       return 'Lo-fi';
      case FocusAudio.nature:     return 'Nature';
      case FocusAudio.whiteNoise: return 'Bruit blanc';
    }
  }

  String get emoji {
    switch (this) {
      case FocusAudio.silence:    return '🔕';
      case FocusAudio.rain:       return '🌧';
      case FocusAudio.waves:      return '🌊';
      case FocusAudio.lofi:       return '🎵';
      case FocusAudio.nature:     return '🌿';
      case FocusAudio.whiteNoise: return '☁️';
    }
  }

  /// Chemin du fichier audio dans assets/audio/
  /// → Placer les fichiers MP3 correspondants dans flutter_app/assets/audio/
  String? get assetPath {
    switch (this) {
      case FocusAudio.silence:    return null;
      case FocusAudio.rain:       return 'assets/audio/rain.mp3';
      case FocusAudio.waves:      return 'assets/audio/waves.mp3';
      case FocusAudio.lofi:       return 'assets/audio/lofi.mp3';
      case FocusAudio.nature:     return 'assets/audio/nature.mp3';
      case FocusAudio.whiteNoise: return 'assets/audio/white_noise.mp3';
    }
  }
}

/// Service singleton qui gère la lecture audio pour Pomodoro et Flow.
/// Lecture en boucle infinie, pause/reprise synchronisée avec le timer.
class FocusAudioService {
  FocusAudioService._();
  static final FocusAudioService instance = FocusAudioService._();

  final _player = AudioPlayer();
  final _log    = Logger();

  FocusAudio _current = FocusAudio.silence;
  bool _isPlaying     = false;
  bool _enabled       = true;

  FocusAudio get current  => _current;
  bool get isPlaying      => _isPlaying;
  bool get isEnabled      => _enabled;

  Future<void> setEnabled(bool value) async {
    _enabled = value;
    if (!value) {
      await _player.pause();
    } else if (_isPlaying) {
      await _startPlayback();
    }
  }

  /// Change l'ambiance. Si le timer est actif, bascule immédiatement.
  Future<void> select(FocusAudio audio) async {
    if (_current == audio) return;
    _current = audio;

    if (_isPlaying) {
      await _player.stop();
      await _startPlayback();
    }
  }

  /// Démarre la lecture (appelé quand le timer démarre).
  Future<void> play() async {
    if (_current == FocusAudio.silence || !_enabled) return;
    _isPlaying = true;
    await _startPlayback();
  }

  /// Met en pause (appelé quand le timer est pausé).
  Future<void> pause() async {
    _isPlaying = false;
    await _player.pause();
  }

  /// Reprend après une pause.
  Future<void> resume() async {
    if (_current == FocusAudio.silence) return;
    _isPlaying = true;
    if (_player.playerState.processingState == ProcessingState.ready) {
      await _player.play();
    } else {
      await _startPlayback();
    }
  }

  /// Arrête complètement (fin de session ou reset).
  Future<void> stop() async {
    _isPlaying = false;
    await _player.stop();
  }

  Future<void> _startPlayback() async {
    final path = _current.assetPath;
    if (path == null) return;

    try {
      await _player.setAsset(path);
      await _player.setLoopMode(LoopMode.one);
      await _player.setVolume(0.5);
      await _player.play();
    } catch (e) {
      // Fichier absent — l'UI continue de fonctionner silencieusement
      _log.w('FocusAudioService: fichier introuvable → $path');
    }
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}
