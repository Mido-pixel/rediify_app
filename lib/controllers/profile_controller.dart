import 'package:flutter/material.dart';

// --- Profile Model ---
class UserProfile {
  final String username;
  final String email;
  final String bio;
  final List<String> favoriteGenres;
  final int liked;
  final int playlists;
  final int following;

  const UserProfile({
    required this.username,
    required this.email,
    required this.bio,
    required this.favoriteGenres,
    this.liked = 0,
    this.playlists = 0,
    this.following = 0,
  });

  // Creates updated copy with new values
  UserProfile copyWith({
    String? username,
    String? email,
    String? bio,
    List<String>? favoriteGenres,
    int? liked,
    int? playlists,
    int? following,
  }) {
    return UserProfile(
      username: username ?? this.username,
      email: email ?? this.email,
      bio: bio ?? this.bio,
      favoriteGenres: favoriteGenres ?? this.favoriteGenres,
      liked: liked ?? this.liked,
      playlists: playlists ?? this.playlists,
      following: following ?? this.following,
    );
  }

  static void fromJson(json) {}
}

// --- Profile Controller ---
class ProfileController extends ChangeNotifier {
  // --- Initial Profile Data ---
  UserProfile _profile = const UserProfile(
    username: "Mido",
    email: "user@rediify.com",
    bio: "I love music 🎵",
    favoriteGenres: ["Hip Hop", "R&B", "Afrobeats", "Reggae"],
    liked: 24,
    playlists: 5,
    following: 12,
  );

  final bool _isLoading = false;
  String? _errorMessage;

  // --- Getters ---
  UserProfile get profile => _profile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get username => _profile.username;
  String get email => _profile.email;
  String get bio => _profile.bio;
  List<String> get favoriteGenres => _profile.favoriteGenres;
  int get liked => _profile.liked;
  int get playlists => _profile.playlists;
  int get following => _profile.following;

  // --- Update Username & Bio ---
  void updateProfile({required String username, required String bio}) {
    if (username.trim().isEmpty) {
      _errorMessage = "Username cannot be empty";
      notifyListeners();
      return;
    }

    _profile = _profile.copyWith(
      username: username.trim(),
      bio: bio.trim(),
    );
    _errorMessage = null;
    notifyListeners();
  }

  // --- Update Email ---
  void updateEmail(String email) {
    if (!email.contains('@')) {
      _errorMessage = "Invalid email address";
      notifyListeners();
      return;
    }

    _profile = _profile.copyWith(email: email.trim());
    _errorMessage = null;
    notifyListeners();
  }

  // --- Add Favorite Genre ---
  void addGenre(String genre) {
    if (genre.trim().isEmpty) return;
    if (_profile.favoriteGenres.contains(genre)) {
      _errorMessage = "Genre already added";
      notifyListeners();
      return;
    }

    final updated = List<String>.from(_profile.favoriteGenres)
      ..add(genre.trim());
    _profile = _profile.copyWith(favoriteGenres: updated);
    _errorMessage = null;
    notifyListeners();
  }

  // --- Remove Favorite Genre ---
  void removeGenre(String genre) {
    final updated = List<String>.from(_profile.favoriteGenres)
      ..remove(genre);
    _profile = _profile.copyWith(favoriteGenres: updated);
    notifyListeners();
  }

  // --- Increment Stats ---
  void incrementLiked() {
    _profile = _profile.copyWith(liked: _profile.liked + 1);
    notifyListeners();
  }

  void incrementPlaylists() {
    _profile = _profile.copyWith(playlists: _profile.playlists + 1);
    notifyListeners();
  }

  void incrementFollowing() {
    _profile = _profile.copyWith(following: _profile.following + 1);
    notifyListeners();
  }

  // --- Decrement Stats ---
  void decrementFollowing() {
    if (_profile.following > 0) {
      _profile = _profile.copyWith(following: _profile.following - 1);
      notifyListeners();
    }
  }

  // --- Clear Error ---
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // --- Reset Profile ---
  void resetProfile() {
    _profile = const UserProfile(
      username: "Mido",
      email: "user@rediify.com",
      bio: "I love music 🎵",
      favoriteGenres: ["Hip Hop", "R&B", "Afrobeats", "Reggae"],
      liked: 24,
      playlists: 5,
      following: 12,
    );
    _errorMessage = null;
    notifyListeners();
  }
}