import 'song.dart';

// ── UserProfile Model ──────────────────────────────────────────
class UserProfile {
  final String id;
  final String username;
  final String? displayName;
  final String? avatarUrl;
  final String? bio;

  const UserProfile({
    required this.id,
    required this.username,
    this.displayName,
    this.avatarUrl,
    this.bio,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id:          json['id'] as String,
      username:    json['username'] as String,
      displayName: json['display_name'] as String?,
      avatarUrl:   json['avatar_url'] as String?,
      bio:         json['bio'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id':           id,
    'username':     username,
    'display_name': displayName,
    'avatar_url':   avatarUrl,
    'bio':          bio,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is UserProfile && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'UserProfile(id: $id, username: $username)';
}

// ── Playlist Model ─────────────────────────────────────────────
class Playlist {
  final String id;
  final String userId;
  final String name;
  final String? description;
  final String? coverUrl;
  final bool isPublic;
  final int songCount;
  final Duration totalDuration;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<Song>? songs;
  final UserProfile? owner;

  const Playlist({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    this.coverUrl,
    this.isPublic = false,
    this.songCount = 0,
    this.totalDuration = Duration.zero,
    required this.createdAt,
    this.updatedAt,
    this.songs,
    this.owner,
  });

  // ── From JSON ──────────────────────────────────────────────
  factory Playlist.fromJson(Map<String, dynamic> json) {
    List<Song>? songs;
    if (json['songs'] != null) {
      songs = (json['songs'] as List)
          .map((s) => Song.fromJson(s is Map ? s['songs'] ?? s : s))
          .toList();
    }

    final durationSec = json['total_duration_seconds'] as int? ?? 0;

    final owner = json['profiles'] != null
        ? UserProfile.fromJson(json['profiles'] as Map<String, dynamic>)
        : null;

    return Playlist(
      id:            json['id'] as String,
      userId:        json['user_id'] as String,
      name:          json['name'] as String,
      description:   json['description'] as String?,
      coverUrl:      json['cover_url'] as String?,
      isPublic:      json['is_public'] as bool? ?? false,
      songCount:     json['song_count'] as int? ?? 0,
      totalDuration: Duration(seconds: durationSec),
      createdAt:     DateTime.parse(json['created_at'] as String),
      updatedAt:     json['updated_at'] != null
                       ? DateTime.tryParse(json['updated_at'])
                       : null,
      songs: songs,
      owner: owner,
    );
  }

  // ── To JSON ────────────────────────────────────────────────
  Map<String, dynamic> toJson() => {
    'id':                      id,
    'user_id':                 userId,
    'name':                    name,
    'description':             description,
    'cover_url':               coverUrl,
    'is_public':               isPublic,
    'song_count':              songCount,
    'total_duration_seconds':  totalDuration.inSeconds,
    'created_at':              createdAt.toIso8601String(),
    'updated_at':              updatedAt?.toIso8601String(),
  };

  // ── Copy With ──────────────────────────────────────────────
  Playlist copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    String? coverUrl,
    bool? isPublic,
    int? songCount,
    Duration? totalDuration,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Song>? songs,
    UserProfile? owner,
  }) {
    return Playlist(
      id:            id            ?? this.id,
      userId:        userId        ?? this.userId,
      name:          name          ?? this.name,
      description:   description   ?? this.description,
      coverUrl:      coverUrl      ?? this.coverUrl,
      isPublic:      isPublic      ?? this.isPublic,
      songCount:     songCount     ?? this.songCount,
      totalDuration: totalDuration ?? this.totalDuration,
      createdAt:     createdAt     ?? this.createdAt,
      updatedAt:     updatedAt     ?? this.updatedAt,
      songs:         songs         ?? this.songs,
      owner:         owner         ?? this.owner,
    );
  }

  // ── Helpers ────────────────────────────────────────────────
  String get formattedDuration {
    final h = totalDuration.inHours;
    final m = totalDuration.inMinutes.remainder(60);
    if (h > 0) return '${h}h ${m}m';
    return '$m min';
  }

  String get formattedSongCount =>
      '$songCount ${songCount == 1 ? 'song' : 'songs'}';

  bool get isEmpty => songCount == 0;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Playlist && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Playlist(id: $id, name: $name, songCount: $songCount)';
}