import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeController extends ChangeNotifier {
  final _supabase = Supabase.instance.client;

  // ── State ──────────────────────────────────────────────────
  bool isLoading = false;
  String? errorMessage;

  List<Map<String, dynamic>> featuredSongs = [];
  List<Map<String, dynamic>> recentlyPlayed = [];
  List<Map<String, dynamic>> trendingSongs = [];
  List<Map<String, dynamic>> recommendedArtists = [];
  List<Map<String, dynamic>> newReleases = [];

  Map<String, dynamic>? currentUser;
  String greeting = '';

  // ── Init ───────────────────────────────────────────────────
  Future<void> init() async {
    _setGreeting();
    await Future.wait([
      fetchCurrentUser(),
      fetchFeaturedSongs(),
      fetchRecentlyPlayed(),
      fetchTrendingSongs(),
      fetchRecommendedArtists(),
      fetchNewReleases(),
    ]);
  }

  // ── Greeting ───────────────────────────────────────────────
  void _setGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      greeting = 'Good Morning';
    } else if (hour < 17) {
      greeting = 'Good Afternoon';
    } else {
      greeting = 'Good Evening';
    }
    notifyListeners();
  }

  // ── Current User ───────────────────────────────────────────
  Future<void> fetchCurrentUser() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      final response = await _supabase
          .from('profiles')
          .select('id, username, avatar_url, email')
          .eq('id', user.id)
          .single();

      currentUser = response;
      notifyListeners();
    } catch (e) {
      errorMessage = 'Failed to load user: $e';
      notifyListeners();
    }
  }

  // ── Featured Songs ─────────────────────────────────────────
  Future<void> fetchFeaturedSongs() async {
    try {
      isLoading = true;
      notifyListeners();

      final response = await _supabase
          .from('songs')
          .select('id, title, artist, cover_url, audio_url, duration, play_count')
          .eq('is_featured', true)
          .order('play_count', ascending: false)
          .limit(10);

      featuredSongs = List<Map<String, dynamic>>.from(response);
    } catch (e) {
      errorMessage = 'Failed to load featured songs: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ── Recently Played ────────────────────────────────────────
  Future<void> fetchRecentlyPlayed() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      final response = await _supabase
          .from('play_history')
          .select('id, played_at, songs(id, title, artist, cover_url, audio_url, duration)')
          .eq('user_id', user.id)
          .order('played_at', ascending: false)
          .limit(10);

      recentlyPlayed = List<Map<String, dynamic>>.from(response);
      notifyListeners();
    } catch (e) {
      errorMessage = 'Failed to load recently played: $e';
      notifyListeners();
    }
  }

  // ── Trending Songs ─────────────────────────────────────────
  Future<void> fetchTrendingSongs() async {
    try {
      final response = await _supabase
          .from('songs')
          .select('id, title, artist, cover_url, audio_url, duration, play_count')
          .order('play_count', ascending: false)
          .limit(15);

      trendingSongs = List<Map<String, dynamic>>.from(response);
      notifyListeners();
    } catch (e) {
      errorMessage = 'Failed to load trending: $e';
      notifyListeners();
    }
  }

  // ── Recommended Artists ────────────────────────────────────
  Future<void> fetchRecommendedArtists() async {
    try {
      final response = await _supabase
          .from('artists')
          .select('id, name, image_url, genre, followers_count')
          .order('followers_count', ascending: false)
          .limit(10);

      recommendedArtists = List<Map<String, dynamic>>.from(response);
      notifyListeners();
    } catch (e) {
      errorMessage = 'Failed to load artists: $e';
      notifyListeners();
    }
  }

  // ── New Releases ───────────────────────────────────────────
  Future<void> fetchNewReleases() async {
    try {
      final response = await _supabase
          .from('songs')
          .select('id, title, artist, cover_url, audio_url, duration, release_date')
          .order('release_date', ascending: false)
          .limit(10);

      newReleases = List<Map<String, dynamic>>.from(response);
      notifyListeners();
    } catch (e) {
      errorMessage = 'Failed to load new releases: $e';
      notifyListeners();
    }
  }

  // ── Log Play ───────────────────────────────────────────────
  Future<void> logSongPlay(String songId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      await _supabase.from('play_history').insert({
        'user_id': user.id,
        'song_id': songId,
        'played_at': DateTime.now().toIso8601String(),
      });

      // Increment play count
      await _supabase.rpc('increment_play_count', params: {'song_id': songId});

      // Refresh recently played
      await fetchRecentlyPlayed();
    } catch (e) {
      errorMessage = 'Failed to log play: $e';
      notifyListeners();
    }
  }

  // ── Like / Unlike Song ─────────────────────────────────────
  Future<void> toggleLike(String songId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      final existing = await _supabase
          .from('liked_songs')
          .select('id')
          .eq('user_id', user.id)
          .eq('song_id', songId)
          .maybeSingle();

      if (existing != null) {
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
      notifyListeners();
    } catch (e) {
      errorMessage = 'Failed to toggle like: $e';
      notifyListeners();
    }
  }

  // ── Refresh All ────────────────────────────────────────────
  Future<void> refresh() async {
    errorMessage = null;
    await init();
  }

  // ── Clear Error ────────────────────────────────────────────
  void clearError() {
    errorMessage = null;
    notifyListeners();
  }
}