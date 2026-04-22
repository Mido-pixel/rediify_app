import 'package:just_audio/just_audio.dart';
import '../services/music_service.dart'; // ✅ uses Song from music_service

class AudioPlayerController {
  final AudioPlayer _player = AudioPlayer();

  // ── State ──────────────────────────────────────────────────
  bool     isPlaying   = false;
  bool     isBuffering = false;
  Duration position    = Duration.zero;
  Duration duration    = Duration.zero;
  String?  errorMessage;

  // ── Callbacks ──────────────────────────────────────────────
  void Function(Duration)? onPositionChanged;
  void Function(Duration)? onDurationChanged;
  void Function(bool)?     onPlayingChanged;
  void Function()?         onSongCompleted;

  AudioPlayerController() {
    _initListeners();
  }

  // ── Listeners ──────────────────────────────────────────────
  void _initListeners() {
    _player.playingStream.listen((playing) {
      isPlaying = playing;
      onPlayingChanged?.call(playing);
    });

    _player.positionStream.listen((pos) {
      position = pos;
      onPositionChanged?.call(pos);
    });

    _player.durationStream.listen((dur) {
      if (dur != null) {
        duration = dur;
        onDurationChanged?.call(dur);
      }
    });

    _player.processingStateStream.listen((state) {
      isBuffering = state == ProcessingState.buffering ||
                    state == ProcessingState.loading;
      if (state == ProcessingState.completed) {
        onSongCompleted?.call();
      }
    });
  }

  // ── Play Song ──────────────────────────────────────────────
  Future<void> playSong(Song song) async {
    try {
      errorMessage = null;
      isBuffering  = true;

      await _player.stop();
      await _player.setUrl(song.fileUrl); // ✅ uses Supabase URL
      await _player.play();
    } catch (e) {
      errorMessage = 'Playback failed: $e';
      isBuffering  = false;
      print('AudioPlayerController error: $e');
    }
  }

  // ── Play from URL directly ─────────────────────────────────
  Future<void> playUrl(String url) async {
    try {
      errorMessage = null;
      await _player.stop();
      await _player.setUrl(url);          // ✅ direct URL support
      await _player.play();
    } catch (e) {
      errorMessage = 'Playback failed: $e';
      print('AudioPlayerController error: $e');
    }
  }

  // ── Controls ───────────────────────────────────────────────
  Future<void> togglePlayPause() async {
    if (_player.playing) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  Future<void> seekTo(Duration position) async {
    await _player.seek(position);
  }

  Future<void> setVolume(double volume) async {
    await _player.setVolume(volume.clamp(0.0, 1.0));
  }

  Future<void> stop() async {
    await _player.stop();
  }

  Future<void> pause() async {
    await _player.pause();
  }

  Future<void> resume() async {
    await _player.play();
  }

  // ── Progress helpers ───────────────────────────────────────
  double get progress {
    if (duration.inMilliseconds == 0) return 0.0;
    return (position.inMilliseconds / duration.inMilliseconds)
        .clamp(0.0, 1.0);
  }

  String get positionLabel => _fmt(position);
  String get durationLabel  => _fmt(duration);

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  // ── Dispose ────────────────────────────────────────────────
  void dispose() {
    _player.dispose();
  }
}