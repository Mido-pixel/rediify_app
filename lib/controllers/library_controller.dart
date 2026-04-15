import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LibraryController extends ChangeNotifier {
  final _supabase = Supabase.instance.client;

  // ── State ──────────────────────────────────────────────────
  bool isLoading = false;
  bool isCreatingPlaylist = false;
  String? errorMessage;

  List<Map<String, dynamic>> playlists = [];
  List<Map<String, dynamic>> likedSongs = [];
  List<Map<String, dynamic>> downloadedSongs = [];
  List<Map<String, dynamic>> followedArtists = [];
  List<Map<String, dynamic>> savedAlbums = [];

  // Active playlist being viewed
  Map<String, dynamic>? activePlaylist;
  List<Map<String, dynamic>> activePlaylistSongs = [];

  // ── Init ───────────────────────────────────────────────────
  Future<void> init() async {
    await Future.wait([
      fetchPlaylists(),
      fetchLikedSongs(),
      fetchDownloadedSongs(),
      fetchFollowedArtists(),
      fetchSavedAlbums(),
    ]);
  }

  // ── Playlists ──────────────────────────────────────────────
  Future<void> fetchPlaylists() async {
    try {
      isLoading = true;
      notifyListeners();

      final user = _supabase.auth.currentUser;
      if (user == null) return;

      final response = await _supabase
          .from('playlists')
          .select('id, name, cover_url, description, is_public, created_at, song_count')
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      playlists = List<Map<String, dynamic>>.from(response);
    } catch (e) {
      errorMessage = 'Failed to load playlists: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ── Create Playlist ────────────────────────────────────────
  Future<bool> createPlaylist({
    required String name,
    String? description,
    bool isPublic = false,
  }) async {
    try {
      isCreatingPlaylist = true;
      notifyListeners();

      final user = _supabase.auth.currentUser;
      if (user == null) return false;

      await _supabase.from('playlists').insert({
        'user_id': user.id,
        'name': name,
        'description': description,
        'is_public': isPublic,
        'song_count': 0,
        'created_at': DateTime.now().toIso8601String(),
      });

      await fetchPlaylists();
      return true;
    } catch (e) {
      errorMessage = 'Failed to create playlist: $e';
      notifyListeners();
      return false;
    } finally {
      isCreatingPlaylist = false;
      notifyListeners();
    }
  }

  // ── Delete Playlist ────────────────────────────────────────
  Future<bool> deletePlaylist(String playlistId) async {
    try {
      await _supabase
          .from('playlists')
          .delete()
          .eq('id', playlistId);

      playlists.removeWhere((p) => p['id'] == playlistId);
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = 'Failed to delete playlist: $e';
      notifyListeners();
      return false;
    }
  }

  // ── Rename Playlist ────────────────────────────────────────
  Future<bool> renamePlaylist(String playlistId, String newName) async {
    try {
      await _supabase
          .from('playlists')
          .update({'name': newName})
          .eq('id', playlistId);

      final index = playlists.indexWhere((p) => p['id'] == playlistId);
      if (index != -1) {
        playlists[index]['name'] = newName;
        notifyListeners();
      }
      return true;
    } catch (e) {
      errorMessage = 'Failed to rename playlist: $e';
      notifyListeners();
      return false;
    }
  }

  // ── Load Playlist Songs ────────────────────────────────────
  Future<void> loadPlaylistSongs(String playlistId) async {
    try {
      isLoading = true;
      notifyListeners();

      final response = await _supabase
          .from('playlist_songs')
          .select('position, songs(id, title, artist, cover_url, audio_url, duration)')
          .eq('playlist_id', playlistId)
          .order('position', ascending: true);

      activePlaylistSongs = List<Map<String, dynamic>>.from(response);
    } catch (e) {
      errorMessage = 'Failed to load playlist songs: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ── Add Song to Playlist ───────────────────────────────────
  Future<bool> addSongToPlaylist(String playlistId, String songId) async {
    try {
      // Get current max position
      final existing = await _supabase
          .from('playlist_songs')
          .select('position')
          .eq('playlist_id', playlistId)
          .order('position', ascending: false)
          .limit(1)
          .maybeSingle();

      final nextPosition = existing != null ? (existing['position'] as int) + 1 : 0;

      await _supabase.from('playlist_songs').insert({
        'playlist_id': playlistId,
        'song_id': songId,
        'position': nextPosition,
        'added_at': DateTime.now().toIso8601String(),
      });

      // Update song count
      await _supabase.rpc('increment_playlist_song_count',
          params: {'playlist_id': playlistId});

      await fetchPlaylists();
      return true;
    } catch (e) {
      errorMessage = 'Failed to add song: $e';
      notifyListeners();
      return false;
    }
  }

  // ── Remove Song from Playlist ──────────────────────────────
  Future<bool> removeSongFromPlaylist(String playlistId, String songId) async {
    try {
      await _supabase
          .from('playlist_songs')
          .delete()
          .eq('playlist_id', playlistId)
          .eq('song_id', songId);

      activePlaylistSongs.removeWhere(
          (s) => s['songs']['id'] == songId);

      await _supabase.rpc('decrement_playlist_song_count',
          params: {'playlist_id': playlistId});

      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = 'Failed to remove song: $e';
      notifyListeners();
      return false;
    }
  }

  // ── Liked Songs ────────────────────────────────────────────
  Future<void> fetchLikedSongs() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      final response = await _supabase
          .from('liked_songs')
          .select('liked_at, songs(id, title, artist, cover_url, audio_url, duration)')
          .eq('user_id', user.id)
          .order('liked_at', ascending: false);

      likedSongs = List<Map<String, dynamic>>.from(response);
      notifyListeners();
    } catch (e) {
      errorMessage = 'Failed to load liked songs: $e';
      notifyListeners();
    }
  }

  // ── Check if Song is Liked ─────────────────────────────────
  bool isSongLiked(String songId) {
    return likedSongs.any((s) => s['songs']['id'] == songId);
  }

  // ── Downloaded Songs ───────────────────────────────────────
  Future<void> fetchDownloadedSongs() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      final response = await _supabase
          .from('downloads')
          .select('downloaded_at, local_path, songs(id, title, artist, cover_url, duration)')
          .eq('user_id', user.id)
          .order('downloaded_at', ascending: false);

      downloadedSongs = List<Map<String, dynamic>>.from(response);
      notifyListeners();
    } catch (e) {
      errorMessage = 'Failed to load downloads: $e';
      notifyListeners();
    }
  }

  // ── Followed Artists ───────────────────────────────────────
  Future<void> fetchFollowedArtists() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      final response = await _supabase
          .from('follows')
          .select('followed_at, artists(id, name, image_url, genre, followers_count)')
          .eq('user_id', user.id)
          .order('followed_at', ascending: false);

      followedArtists = List<Map<String, dynamic>>.from(response);
      notifyListeners();
    } catch (e) {
      errorMessage = 'Failed to load followed artists: $e';
      notifyListeners();
    }
  }

  // ── Saved Albums ───────────────────────────────────────────
  Future<void> fetchSavedAlbums() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      final response = await _supabase
          .from('saved_albums')
          .select('saved_at, albums(id, title, artist, cover_url, release_date, track_count)')
          .eq('user_id', user.id)
          .order('saved_at', ascending: false);

      savedAlbums = List<Map<String, dynamic>>.from(response);
      notifyListeners();
    } catch (e) {
      errorMessage = 'Failed to load saved albums: $e';
      notifyListeners();
    }
  }

  // ── Toggle Follow Artist ───────────────────────────────────
  Future<void> toggleFollowArtist(String artistId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      final existing = await _supabase
          .from('follows')
          .select('id')
          .eq('user_id', user.id)
          .eq('artist_id', artistId)
          .maybeSingle();

      if (existing != null) {
        await _supabase
            .from('follows')
            .delete()
            .eq('user_id', user.id)
            .eq('artist_id', artistId);
        followedArtists.removeWhere((a) => a['artists']['id'] == artistId);
      } else {
        await _supabase.from('follows').insert({
          'user_id': user.id,
          'artist_id': artistId,
          'followed_at': DateTime.now().toIso8601String(),
        });
        await fetchFollowedArtists();
      }
      notifyListeners();
    } catch (e) {
      errorMessage = 'Failed to toggle follow: $e';
      notifyListeners();
    }
  }

  // ── Toggle Save Album ──────────────────────────────────────
  Future<void> toggleSaveAlbum(String albumId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      final existing = await _supabase
          .from('saved_albums')
          .select('id')
          .eq('user_id', user.id)
          .eq('album_id', albumId)
          .maybeSingle();

      if (existing != null) {
        await _supabase
            .from('saved_albums')
            .delete()
            .eq('user_id', user.id)
            .eq('album_id', albumId);
        savedAlbums.removeWhere((a) => a['albums']['id'] == albumId);
      } else {
        await _supabase.from('saved_albums').insert({
          'user_id': user.id,
          'album_id': albumId,
          'saved_at': DateTime.now().toIso8601String(),
        });
        await fetchSavedAlbums();
      }
      notifyListeners();
    } catch (e) {
      errorMessage = 'Failed to toggle save album: $e';
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