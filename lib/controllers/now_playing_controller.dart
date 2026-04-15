import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NowPlayingController extends ChangeNotifier {
  final _supabase = Supabase.instance.client;

  // ── State ──────────────────────────────────────────────────
  bool isLoading = false;
  bool isPlaying = false;
  bool isShuffled = false;
  bool isFavorite = false;
  String? errorMessage;

  Map<String, dynamic>? currentSong;
  List<Map<String, dynamic>> queue = [];
  List<Map<String, dynamic>> relatedSongs = [];
  List<Map<String, dynamic>> comments = [];

  int currentIndex = 0;
  Duration currentPosition = Duration.zero;
  Duration totalDuration = Duration.zero;
  double volume = 1.0;

  RepeatMode repeatMode = RepeatMode.none;

  // ── Load Song ──────────────────────────────────────────────
  Future<void> loadSong(Map<String, dynamic> song, {List<Map<String, dynamic>>? songQueue}) async {
    try {
      isLoading = true;
      currentSong = song;
      currentPosition = Duration.zero;
      notifyListeners();

      if (songQueue != null) {
        queue = songQueue;
        currentIndex = queue.indexWhere((s) => s['id'] == song['id']);
      }

      await Future.wait([
        _checkIsFavorite(song['id']),
        fetchRelatedSongs(song['id'], song['artist']),
        fetchComments(song['id']),
        _logPlay(song['id']),
      ]);

      isPlaying = true;
    } catch (e) {
      errorMessage = 'Failed to load song: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ── Playback Controls ──────────────────────────────────────
  void togglePlayPause() {
    isPlaying = !isPlaying;
    notifyListeners();
  }

  void playNext() {
    if (queue.isEmpty) return;

    if (isShuffled) {
      currentIndex = (currentIndex + 1 + (queue.length - 1)) % queue.length;
    } else {
      if (repeatMode == RepeatMode.one) {
        // replay same
      } else {
        currentIndex = (currentIndex + 1) % queue.length;
      }
    }

    currentSong = queue[currentIndex];
    currentPosition = Duration.zero;
    isPlaying = true;
    notifyListeners();
    _logPlay(currentSong!['id']);
  }

  void playPrevious() {
    if (queue.isEmpty) return;

    // If more than 3s in, restart; else go previous
    if (currentPosition.inSeconds > 3) {
      currentPosition = Duration.zero;
    } else {
      currentIndex = (currentIndex - 1 + queue.length) % queue.length;
      currentSong = queue[currentIndex];
      currentPosition = Duration.zero;
    }
    isPlaying = true;
    notifyListeners();
  }

  void toggleShuffle() {
    isShuffled = !isShuffled;
    if (isShuffled) queue.shuffle();
    notifyListeners();
  }

  void cycleRepeatMode() {
    switch (repeatMode) {
      case RepeatMode.none: repeatMode = RepeatMode.all;  break;
      case RepeatMode.all:  repeatMode = RepeatMode.one;  break;
      case RepeatMode.one:  repeatMode = RepeatMode.none; break;
    }
    notifyListeners();
  }

  void seekTo(Duration position) {
    currentPosition = position;
    notifyListeners();
  }

  void setVolume(double value) {
    volume = value.clamp(0.0, 1.0);
    notifyListeners();
  }

  void updatePosition(Duration position) {
    currentPosition = position;
    notifyListeners();
  }

  void setDuration(Duration duration) {
    totalDuration = duration;
    notifyListeners();
  }

  // ── Progress ───────────────────────────────────────────────
  double get progress {
    if (totalDuration.inMilliseconds == 0) return 0.0;
    return currentPosition.inMilliseconds / totalDuration.inMilliseconds;
  }

  String get currentPositionLabel => _formatDuration(currentPosition);
  String get totalDurationLabel   => _formatDuration(totalDuration);

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  // ── Favorite ───────────────────────────────────────────────
  Future<void> _checkIsFavorite(String songId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      final result = await _supabase
          .from('liked_songs')
          .select('id')
          .eq('user_id', user.id)
          .eq('song_id', songId)
          .maybeSingle();

      isFavorite = result != null;
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to check favorite: $e');
    }
  }

  Future<void> toggleFavorite() async {
    if (currentSong == null) return;
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;
      final songId = currentSong!['id'];

      if (isFavorite) {
        await _supabase
            .from('liked_songs')
            .delete()
            .eq('user_id', user.id)
            .eq('song_id', songId);
      } else {
        await _supabase.from('liked_songs').insert({
          'user_id': user.id,
          'song_id': songId,
          'liked_at': DateTime.now().toIso8601String(),
        });
      }
      isFavorite = !isFavorite;
      notifyListeners();
    } catch (e) {
      errorMessage = 'Failed to toggle favorite: $e';
      notifyListeners();
    }
  }

  // ── Related Songs ──────────────────────────────────────────
  Future<void> fetchRelatedSongs(String songId, String artist) async {
    try {
      final response = await _supabase
          .from('songs')
          .select('id, title, artist, cover_url, audio_url, duration')
          .eq('artist', artist)
          .neq('id', songId)
          .limit(10);

      relatedSongs = List<Map<String, dynamic>>.from(response);
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load related songs: $e');
    }
  }

  // ── Comments ───────────────────────────────────────────────
  Future<void> fetchComments(String songId) async {
    try {
      final response = await _supabase
          .from('comments')
          .select('id, body, created_at, profiles(username, avatar_url)')
          .eq('song_id', songId)
          .order('created_at', ascending: false)
          .limit(20);

      comments = List<Map<String, dynamic>>.from(response);
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load comments: $e');
    }
  }

  Future<void> addComment(String songId, String body) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      await _supabase.from('comments').insert({
        'user_id': user.id,
        'song_id': songId,
        'body': body,
        'created_at': DateTime.now().toIso8601String(),
      });

      await fetchComments(songId);
    } catch (e) {
      errorMessage = 'Failed to add comment: $e';
      notifyListeners();
    }
  }

  // ── Log Play ───────────────────────────────────────────────
  Future<void> _logPlay(String songId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      await _supabase.from('play_history').insert({
        'user_id': user.id,
        'song_id': songId,
        'played_at': DateTime.now().toIso8601String(),
      });

      await _supabase.rpc('increment_play_count', params: {'song_id': songId});
    } catch (e) {
      debugPrint('Failed to log play: $e');
    }
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }
}

enum RepeatMode { none, all, one }