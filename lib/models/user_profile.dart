class UserProfile {
  final String id;
  final String username;
  final String email;
  final String? avatarUrl;
  final String? bio;
  final String? country;
  final String? dateOfBirth;
  final int followersCount;
  final int followingCount;
  final int playlistCount;
  final int likedSongsCount;
  final bool isVerified;
  final bool isPremium;
  final String subscriptionTier; // free | premium | family
  final DateTime createdAt;
  final DateTime? lastSeenAt;
  final Map<String, dynamic>? preferences;
  final List<String>? favoriteGenres;

  const UserProfile({
    required this.id,
    required this.username,
    required this.email,
    this.avatarUrl,
    this.bio,
    this.country,
    this.dateOfBirth,
    this.followersCount = 0,
    this.followingCount = 0,
    this.playlistCount = 0,
    this.likedSongsCount = 0,
    this.isVerified = false,
    this.isPremium = false,
    this.subscriptionTier = 'free',
    required this.createdAt,
    this.lastSeenAt,
    this.preferences,
    this.favoriteGenres,
  });

  // ── From JSON ──────────────────────────────────────────────
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id:               json['id'] as String,
      username:         json['username'] as String,
      email:            json['email'] as String,
      avatarUrl:        json['avatar_url'] as String?,
      bio:              json['bio'] as String?,
      country:          json['country'] as String?,
      dateOfBirth:      json['date_of_birth'] as String?,
      followersCount:   json['followers_count'] as int? ?? 0,
      followingCount:   json['following_count'] as int? ?? 0,
      playlistCount:    json['playlist_count'] as int? ?? 0,
      likedSongsCount:  json['liked_songs_count'] as int? ?? 0,
      isVerified:       json['is_verified'] as bool? ?? false,
      isPremium:        json['is_premium'] as bool? ?? false,
      subscriptionTier: json['subscription_tier'] as String? ?? 'free',
      createdAt:        DateTime.parse(json['created_at'] as String),
      lastSeenAt:       json['last_seen_at'] != null
                          ? DateTime.tryParse(json['last_seen_at'])
                          : null,
      preferences:      json['preferences'] as Map<String, dynamic>?,
      favoriteGenres:   json['favorite_genres'] != null
                          ? List<String>.from(json['favorite_genres'])
                          : null,
    );
  }

  // ── To JSON ────────────────────────────────────────────────
  Map<String, dynamic> toJson() => {
    'id':                 id,
    'username':           username,
    'email':              email,
    'avatar_url':         avatarUrl,
    'bio':                bio,
    'country':            country,
    'date_of_birth':      dateOfBirth,
    'followers_count':    followersCount,
    'following_count':    followingCount,
    'playlist_count':     playlistCount,
    'liked_songs_count':  likedSongsCount,
    'is_verified':        isVerified,
    'is_premium':         isPremium,
    'subscription_tier':  subscriptionTier,
    'created_at':         createdAt.toIso8601String(),
    'last_seen_at':       lastSeenAt?.toIso8601String(),
    'preferences':        preferences,
    'favorite_genres':    favoriteGenres,
  };

  // ── Copy With ──────────────────────────────────────────────
  UserProfile copyWith({
    String? id,
    String? username,
    String? email,
    String? avatarUrl,
    String? bio,
    String? country,
    String? dateOfBirth,
    int? followersCount,
    int? followingCount,
    int? playlistCount,
    int? likedSongsCount,
    bool? isVerified,
    bool? isPremium,
    String? subscriptionTier,
    DateTime? createdAt,
    DateTime? lastSeenAt,
    Map<String, dynamic>? preferences,
    List<String>? favoriteGenres,
  }) {
    return UserProfile(
      id:               id               ?? this.id,
      username:         username         ?? this.username,
      email:            email            ?? this.email,
      avatarUrl:        avatarUrl        ?? this.avatarUrl,
      bio:              bio              ?? this.bio,
      country:          country          ?? this.country,
      dateOfBirth:      dateOfBirth      ?? this.dateOfBirth,
      followersCount:   followersCount   ?? this.followersCount,
      followingCount:   followingCount   ?? this.followingCount,
      playlistCount:    playlistCount    ?? this.playlistCount,
      likedSongsCount:  likedSongsCount  ?? this.likedSongsCount,
      isVerified:       isVerified       ?? this.isVerified,
      isPremium:        isPremium        ?? this.isPremium,
      subscriptionTier: subscriptionTier ?? this.subscriptionTier,
      createdAt:        createdAt        ?? this.createdAt,
      lastSeenAt:       lastSeenAt       ?? this.lastSeenAt,
      preferences:      preferences      ?? this.preferences,
      favoriteGenres:   favoriteGenres   ?? this.favoriteGenres,
    );
  }

  // ── Helpers ────────────────────────────────────────────────
  String get displayName => username;

  String get initials {
    final parts = username.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return username.substring(0, username.length >= 2 ? 2 : 1).toUpperCase();
  }

  String get formattedFollowers {
    if (followersCount >= 1000000) {
      return '${(followersCount / 1000000).toStringAsFixed(1)}M followers';
    } else if (followersCount >= 1000) {
      return '${(followersCount / 1000).toStringAsFixed(1)}K followers';
    }
    return '$followersCount followers';
  }

  String get subscriptionLabel {
    switch (subscriptionTier) {
      case 'premium': return 'Premium';
      case 'family':  return 'Family';
      default:        return 'Free';
    }
  }

  bool get hasBio => bio != null && bio!.trim().isNotEmpty;

  bool get hasAvatar => avatarUrl != null && avatarUrl!.isNotEmpty;

  int? get age {
    if (dateOfBirth == null) return null;
    final dob = DateTime.tryParse(dateOfBirth!);
    if (dob == null) return null;
    final now = DateTime.now();
    int age = now.year - dob.year;
    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return age;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is UserProfile && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'UserProfile(id: $id, username: $username, tier: $subscriptionTier)';
}