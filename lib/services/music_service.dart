import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

// ── Song Model ────────────────────────────────────────────────
class Song {
  final String id;
  final String title;
  final String artist;
  final String fileUrl;
  final String genre;
  final Color themeColor;
  bool isLiked;

  Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.fileUrl,
    required this.genre,
    required this.themeColor,
    this.isLiked = false,
  });
}

// ── Music Service ─────────────────────────────────────────────
class MusicService extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();

  final List<Song> songs = [
    Song(
      id: '1',
      title: 'Essence',
      artist: 'Chad Crouch',
      fileUrl: 'https://qhtqkpjgxjzqcpyknebv.supabase.co/storage/v1/object/public/songs/my%20songs/Chad%20Crouch%20-%20Essence.mp3',
      genre: 'Afrobeats',
      themeColor: const Color(0xFFE65100),
      isLiked: true,
    ),
    Song(
      id: '2',
      title: 'Falling For You',
      artist: 'Happy Refugees',
      fileUrl: 'https://qhtqkpjgxjzqcpyknebv.supabase.co/storage/v1/object/public/songs/my%20songs/Happy%20Refugees%20-%20Falling%20For%20You.mp3',
      genre: 'R&B',
      themeColor: const Color(0xFF1565C0),
    ),
    Song(
      id: '3',
      title: 'The Weekend',
      artist: 'Krestovsky',
      fileUrl: 'https://qhtqkpjgxjzqcpyknebv.supabase.co/storage/v1/object/public/songs/my%20songs/Krestovsky%20-%20The%20Weekend.mp3',
      genre: 'Pop',
      themeColor: const Color(0xFFB71C1C),
    ),
    Song(
      id: '4',
      title: 'Beautiful and Young',
      artist: 'Break The Bans',
      fileUrl: 'https://qhtqkpjgxjzqcpyknebv.supabase.co/storage/v1/object/public/songs/my%20songs/Break%20The%20Bans%20-%20Beautiful%20and%20young.mp3',
      genre: 'Pop',
      themeColor: const Color(0xFF2E7D32),
    ),
    Song(
      id: '5',
      title: 'Fight Song',
      artist: 'Cletus Got Shot',
      fileUrl: 'https://qhtqkpjgxjzqcpyknebv.supabase.co/storage/v1/object/public/songs/my%20songs/Cletus%20Got%20Shot%20-%20Fight%20Song.mp3',
      genre: 'Hip Hop',
      themeColor: const Color(0xFF4A148C),
    ),
    Song(
      id: '6',
      title: 'Humble',
      artist: 'Tep',
      fileUrl: 'https://qhtqkpjgxjzqcpyknebv.supabase.co/storage/v1/object/public/songs/my%20songs/Tep%20-%20humble.mp3',
      genre: 'Hip Hop',
      themeColor: const Color(0xFF00695C),
    ),
  ];

  // ── State ──────────────────────────────────────────────────
  Song?    currentSong;
  int      currentIndex = 0;
  bool     isPlaying    = false;
  bool     isBuffering  = false;
  bool     isShuffle    = false;
  bool     isRepeat     = false;
  Duration position     = Duration.zero;
  Duration duration     = Duration.zero;
  double   volume       = 0.8;
  String?  errorMessage;

  MusicService() {
    _initListeners();
  }

  // ── Listeners ──────────────────────────────────────────────
  void _initListeners() {
    _player.playingStream.listen((playing) {
      isPlaying = playing;
      notifyListeners();
    });
    _player.positionStream.listen((pos) {
      position = pos;
      notifyListeners();
    });
    _player.durationStream.listen((dur) {
      if (dur != null) duration = dur;
      notifyListeners();
    });
    _player.processingStateStream.listen((state) {
      isBuffering = state == ProcessingState.buffering ||
                    state == ProcessingState.loading;
      if (state == ProcessingState.completed) {
        if (isRepeat) {
          _player.seek(Duration.zero);
          _player.play();
        } else {
          playNext();
        }
      }
      notifyListeners();
    });
  }

  // ── Play Song ──────────────────────────────────────────────
  Future<void> playSong(Song song) async {
    try {
      currentSong  = song;
      currentIndex = songs.indexOf(song);
      isBuffering  = true;
      errorMessage = null;
      notifyListeners();

      await _player.stop();
      await _player.setUrl(song.fileUrl);
      await _player.play();
    } catch (e) {
      errorMessage = 'Playback failed: $e';
      isBuffering  = false;
      notifyListeners();
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

  Future<void> playNext() async {
    if (songs.isEmpty) return;
    if (isShuffle) {
      final list = List.generate(songs.length, (i) => i)..shuffle();
      await playSong(songs[list.first]);
    } else {
      await playSong(songs[(currentIndex + 1) % songs.length]);
    }
  }

  Future<void> playPrevious() async {
    if (songs.isEmpty) return;
    if (position.inSeconds > 3) {
      await _player.seek(Duration.zero);
      return;
    }
    await playSong(songs[(currentIndex - 1 + songs.length) % songs.length]);
  }

  Future<void> seekTo(double value) async {
    final ms = (value * duration.inMilliseconds).toInt();
    await _player.seek(Duration(milliseconds: ms));
  }

  Future<void> setVolume(double value) async {
    volume = value.clamp(0.0, 1.0);
    await _player.setVolume(volume);
    notifyListeners();
  }

  void syncVolume(double value) {
    volume = value.clamp(0.0, 1.0);
    _player.setVolume(volume);
    notifyListeners();
  }

  void toggleShuffle() { isShuffle = !isShuffle; notifyListeners(); }
  void toggleRepeat()  { isRepeat  = !isRepeat;  notifyListeners(); }

  void toggleLike() {
    if (currentSong != null) {
      currentSong!.isLiked = !currentSong!.isLiked;
      notifyListeners();
    }
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

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}