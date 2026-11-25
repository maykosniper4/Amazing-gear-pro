import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class Sounds {
  static bool soundEnabled = true;

  // Jump pool: 4 lightweight players in lowLatency mode rotate seamlessly
  // to prevent channel buffer exhaustion and native thread contention on rapid taps
  static final List<AudioPlayer> _jumpPool = [
    AudioPlayer(),
    AudioPlayer(),
    AudioPlayer(),
    AudioPlayer(),
  ];
  static int _jumpIndex = 0;

  // Score pool: 2 players in lowLatency mode
  static final List<AudioPlayer> _scorePool = [
    AudioPlayer(),
    AudioPlayer(),
  ];
  static int _scoreIndex = 0;

  static final AudioPlayer _brickPlayer = AudioPlayer();
  static final AudioPlayer _btnPlayer = AudioPlayer();

  static bool _initialized = false;
  static Future<void>? _initializing;
  static final Set<AudioPlayer> _busyPlayers = {};

  static Future<void> init() => _initializing ??= _initialize();

  static Future<void> _initialize() async {
    try {
      await AudioPlayer.global.setAudioContext(
        AudioContext(
          android: const AudioContextAndroid(
            isSpeakerphoneOn: true,
            stayAwake: false,
            contentType: AndroidContentType.sonification,
            usageType: AndroidUsageType.game,
            audioFocus: AndroidAudioFocus.none,
          ),
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.playback,
            options: const {AVAudioSessionOptions.mixWithOthers},
          ),
        ),
      );

      for (final p in _jumpPool) {
        await p.setPlayerMode(PlayerMode.lowLatency);
        await p.setReleaseMode(ReleaseMode.stop);
        await p.setSource(AssetSource('audio/jump.ogg'));
      }

      for (final p in _scorePool) {
        await p.setPlayerMode(PlayerMode.lowLatency);
        await p.setReleaseMode(ReleaseMode.stop);
        await p.setSource(AssetSource('audio/score.ogg'));
      }

      await _brickPlayer.setPlayerMode(PlayerMode.lowLatency);
      await _brickPlayer.setReleaseMode(ReleaseMode.stop);
      await _brickPlayer.setSource(AssetSource('audio/brick.ogg'));

      await _btnPlayer.setPlayerMode(PlayerMode.lowLatency);
      await _btnPlayer.setReleaseMode(ReleaseMode.stop);
      await _btnPlayer.setSource(AssetSource('audio/button.ogg'));

      _initialized = true;
    } catch (e) {
      debugPrint('Audio initialization note: $e');
    }
  }

  static void playJump() {
    if (!soundEnabled || !_initialized) return;
    final p = _jumpPool[_jumpIndex];
    _jumpIndex = (_jumpIndex + 1) % _jumpPool.length;
    _play(p);
  }

  static void playScore() {
    if (!soundEnabled || !_initialized) return;
    final p = _scorePool[_scoreIndex];
    _scoreIndex = (_scoreIndex + 1) % _scorePool.length;
    _play(p);
  }

  static void playBrick() {
    if (!soundEnabled || !_initialized) return;
    _play(_brickPlayer);
  }

  static void playButton() {
    if (!soundEnabled || !_initialized) return;
    _play(_btnPlayer);
  }

  static Future<void> _play(AudioPlayer player) async {
    // Drop excess requests rather than queueing stale sounds during rapid taps.
    // Each player must finish stopping before it can resume.
    if (!soundEnabled || !_initialized || !_busyPlayers.add(player)) return;
    try {
      await player.stop();
      await player.resume();
    } catch (e) {
      debugPrint('Audio playback note: $e');
    } finally {
      _busyPlayers.remove(player);
    }
  }

  static void dispose() {
    for (final p in _jumpPool) {
      p.dispose();
    }
    for (final p in _scorePool) {
      p.dispose();
    }
    _brickPlayer.dispose();
    _btnPlayer.dispose();
  }
}
