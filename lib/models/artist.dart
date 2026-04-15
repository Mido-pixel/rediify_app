class Artist {
  final String id;
  final String name;
  final String? imageUrl;
  final String? genre;
  final String? bio;
  final int followersCount;
  final int songsCount;
  final bool isVerified;
  final DateTime? createdAt;
  final List<String>? socialLinks;

  const Artist({
    required this.id,
    required this.name,
    this.imageUrl,
    this.genre,
    this.bio,
    this.followersCount = 0,
    this.songsCount = 0,
    this.isVerified = false,
    this.createdAt,
    this.socialLinks,
  });

  // ── From JSON ──────────────────────────────────────────────
  factory Artist.fromJson(Map<String, dynamic> json) {
    return Artist(
      id:             json['id'] as String,
      name:           json['name'] as String,
      imageUrl:       json['image_url'] as String?,
      genre:          json['genre'] as String?,
      bio:            json['bio'] as String?,
      followersCount: json['followers_count'] as int? ?? 0,
      songsCount:     json['songs_count'] as int? ?? 0,
      isVerified:     json['is_verified'] as bool? ?? false,
      createdAt:      json['created_at'] != null
                        ? DateTime.tryParse(json['created_at'])
                        : null,
      socialLinks:    json['social_links'] != null
                        ? List<String>.from(json['social_links'])
                        : null,
    );
  }

  // ── To JSON ────────────────────────────────────────────────
  Map<String, dynamic> toJson() => {
    'id':              id,
    'name':            name,
    'image_url':       imageUrl,
    'genre':           genre,
    'bio':             bio,
    'followers_count': followersCount,
    'songs_count':     songsCount,
    'is_verified':     isVerified,
    'created_at':      createdAt?.toIso8601String(),
    'social_links':    socialLinks,
  };

  // ── Copy With ──────────────────────────────────────────────
  Artist copyWith({
    String? id,
    String? name,
    String? imageUrl,
    String? genre,
    String? bio,
    int? followersCount,
    int? songsCount,
    bool? isVerified,
    DateTime? createdAt,
    List<String>? socialLinks,
  }) {
    return Artist(
      id:             id             ?? this.id,
      name:           name           ?? this.name,
      imageUrl:       imageUrl       ?? this.imageUrl,
      genre:          genre          ?? this.genre,
      bio:            bio            ?? this.bio,
      followersCount: followersCount ?? this.followersCount,
      songsCount:     songsCount     ?? this.songsCount,
      isVerified:     isVerified     ?? this.isVerified,
      createdAt:      createdAt      ?? this.createdAt,
      socialLinks:    socialLinks    ?? this.socialLinks,
    );
  }

  // ── Helpers ────────────────────────────────────────────────
  String get formattedFollowers {
    if (followersCount >= 1000000) {
      return '${(followersCount / 1000000).toStringAsFixed(1)}M';
    } else if (followersCount >= 1000) {
      return '${(followersCount / 1000).toStringAsFixed(1)}K';
    }
    return followersCount.toString();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Artist && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Artist(id: $id, name: $name, genre: $genre)';
}