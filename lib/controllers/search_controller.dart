import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SearchController extends ChangeNotifier {
  final _supabase = Supabase.instance.client;

  // ── State ──────────────────────────────────────────────────
  bool isLoading = false;
  bool isSearching = false;
  String? errorMessage;
  String searchQuery = '';

  List<Map<String, dynamic>> searchResults = [];
  List<Map<String, dynamic>> songResults = [];
  List<Map<String, dynamic>> artistResults = [];
  List<Map<String, dynamic>> albumResults = [];
  List<Map<String, dynamic>> playlistResults = [];
  List<Map<String, dynamic>> trendingSearches = [];
  List<Map<String, dynamic>> browseCategories = [];
  List<String> recentSearches = [];

  String activeFilter = 'All'; // All, Songs, Artists, Albums, Playlists
  final List<String> filters = ['All', 'Songs', 'Artists', 'Albums', 'Playlists'];

  // ── Init ───────────────────────────────────────────────────
  Future<void> init() async {
    await Future.wait([
      fetchTrendingSearches(),
      fetchBrowseCategories(),
      loadRecentSearches(),
    ]);
  }

  // ── Search ─────────────────────────────────────────────────
  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      clearResults();
      return;
    }

    try {
      isSearching = true;
      searchQuery = query;
      notifyListeners();

      final q = query.trim().toLowerCase();

      await Future.wait([
        _searchSongs(q),
        _searchArtists(q),
        _searchAlbums(q),
        _searchPlaylists(q),
      ]);

      // Merge all into one list for 'All' tab
      searchResults = [
        ...songResults.map((s) => {...s, 'type': 'song'}),
        ...artistResults.map((a) => {...a, 'type': 'artist'}),
        ...albumResults.map((a) => {...a, 'type': 'album'}),
        ...playlistResults.map((p) => {...p, 'type': 'playlist'}),
      ];

      _saveRecentSearch(query);
    } catch (e) {
      errorMessage = 'Search failed: $e';
    } finally {
      isSearching = false;
      notifyListeners();
    }
  }

  Future<void> _searchSongs(String q) async {
    final response = await _supabase
        .from('songs')
        .select('id, title, artist, cover_url, audio_url, duration, play_count')
        .or('title.ilike.%$q%,artist.ilike.%$q%')
        .limit(20);
    songResults = List<Map<String, dynamic>>.from(response);
  }

  Future<void> _searchArtists(String q) async {
    final response = await _supabase
        .from('artists')
        .select('id, name, image_url, genre, followers_count')
        .ilike('name', '%$q%')
        .limit(10);
    artistResults = List<Map<String, dynamic>>.from(response);
  }

  Future<void> _searchAlbums(String q) async {
    final response = await _supabase
        .from('albums')
        .select('id, title, artist, cover_url, release_date, track_count')
        .or('title.ilike.%$q%,artist.ilike.%$q%')
        .limit(10);
    albumResults = List<Map<String, dynamic>>.from(response);
  }

  Future<void> _searchPlaylists(String q) async {
    final response = await _supabase
        .from('playlists')
        .select('id, name, cover_url, song_count, user_id')
        .eq('is_public', true)
        .ilike('name', '%$q%')
        .limit(10);
    playlistResults = List<Map<String, dynamic>>.from(response);
  }

  // ── Trending Searches ──────────────────────────────────────
  Future<void> fetchTrendingSearches() async {
    try {
      final response = await _supabase
          .from('songs')
          .select('id, title, artist, cover_url, play_count')
          .order('play_count', ascending: false)
          .limit(8);
      trendingSearches = List<Map<String, dynamic>>.from(response);
      notifyListeners();
    } catch (e) {
      errorMessage = 'Failed to load trending: $e';
      notifyListeners();
    }
  }

  // ── Browse Categories ──────────────────────────────────────
  Future<void> fetchBrowseCategories() async {
    try {
      final response = await _supabase
          .from('categories')
          .select('id, name, cover_url, color')
          .order('name', ascending: true);
      browseCategories = List<Map<String, dynamic>>.from(response);
      notifyListeners();
    } catch (e) {
      errorMessage = 'Failed to load categories: $e';
      notifyListeners();
    }
  }

  // ── Recent Searches ────────────────────────────────────────
  Future<void> loadRecentSearches() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      final response = await _supabase
          .from('recent_searches')
          .select('query')
          .eq('user_id', user.id)
          .order('searched_at', ascending: false)
          .limit(10);

      recentSearches = List<String>.from(
          response.map((r) => r['query'] as String));
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load recent searches: $e');
    }
  }

  void _saveRecentSearch(String query) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      await _supabase.from('recent_searches').upsert({
        'user_id': user.id,
        'query': query,
        'searched_at': DateTime.now().toIso8601String(),
      }, onConflict: 'user_id, query');

      if (!recentSearches.contains(query)) {
        recentSearches.insert(0, query);
        if (recentSearches.length > 10) recentSearches.removeLast();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Failed to save search: $e');
    }
  }

  Future<void> clearRecentSearches() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      await _supabase
          .from('recent_searches')
          .delete()
          .eq('user_id', user.id);

      recentSearches.clear();
      notifyListeners();
    } catch (e) {
      errorMessage = 'Failed to clear searches: $e';
      notifyListeners();
    }
  }

  // ── Filter ─────────────────────────────────────────────────
  void setFilter(String filter) {
    activeFilter = filter;
    notifyListeners();
  }

  List<Map<String, dynamic>> get filteredResults {
    switch (activeFilter) {
      case 'Songs':     return songResults;
      case 'Artists':   return artistResults;
      case 'Albums':    return albumResults;
      case 'Playlists': return playlistResults;
      default:          return searchResults;
    }
  }

  // ── Helpers ────────────────────────────────────────────────
  void clearResults() {
    searchQuery = '';
    searchResults = [];
    songResults = [];
    artistResults = [];
    albumResults = [];
    playlistResults = [];
    notifyListeners();
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }
}