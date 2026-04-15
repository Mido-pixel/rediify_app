import 'artist.dart';

class Song {
  final String id;
  final String title;
  final String artist;
  final String? artistId;
  final String? albumId;
  final String? albumName;
  final String? coverUrl;
  final String? audioUrl;
  final Duration duration;
  final int playCount;
  final bool isFeatured;
  final bool isExplicit;
  final bool isLiked;
  final bool isDownloaded;
  final String? genre;
  final String? lyrics;
  final DateTime? releaseDate;
  final DateTime? addedAt;
  final Artist? artistDetails;
  final Map<String, dynamic>? meta;

  const Song({
    required this.id,
    required this.title,
    required this.artist,
    this.artistId,
    this.albumId,
    this.albumName,
    this.coverUrl,
    this.audioUrl,
    this.duration = Duration.zero,
    this.playCount = 0,
    this.isFeatured = false,
    this.isExplicit = false,
    this.isLiked = false,
    this.isDownloaded = false,
    this.genre,
    this.lyrics,
    this.releaseDate,
    this.addedAt,
    this.artistDetails,
    this.meta,
  });

  // ── From JSON ──────────────────────────────────────────────
  factory Song.fromJson(Map<String, dynamic> json) {
    // Duration can come as seconds (int) or milliseconds
    Duration parseDuration() {
      if (json['duration_ms'] != null) {
        return Duration(milliseconds: json['duration_ms'] as int);
      } else if (json['duration'] != null) {
        return Duration(seconds: json['duration'] as int);
      }
      return Duration.zero;
    }

    return Song(
      id:            json['id'] as String,
      title:         json['title'] as String,
      artist:        json['artist'] as String,
      artistId:      json['artist_id'] as String?,
      albumId:       json['album_id'] as String?,
      albumName:     json['album_name'] as String?,
      coverUrl:      json['cover_url'] as String?,
      audioUrl:      json['audio_url'] as String?,
      duration:      parseDuration(),
      playCount:     json['play_count'] as int? ?? 0,
      isFeatured:    json['is_featured'] as bool? ?? false,
      isExplicit:    json['is_explicit'] as bool? ?? false,
      isLiked:       json['is_liked'] as bool? ?? false,
      isDownloaded:  json['is_downloaded'] as bool? ?? false,
      genre:         json['genre'] as String?,
      lyrics:        json['lyrics'] as String?,
      releaseDate:   json['release_date'] != null
                       ? DateTime.tryParse(json['release_date'])
                       : null,
      addedAt:       json['added_at'] != null
                       ? DateTime.tryParse(json['added_at'])
                       : null,
      artistDetails: json['artists'] != null
                       ? Artist.fromJson(json['artists'])
                       : null,
      meta:          json['meta'] as Map<String, dynamic>?,
    );
  }

  // ── To JSON ────────────────────────────────────────────────
  Map<String, dynamic> toJson() => {
    'id':           id,
    'title':        title,
    'artist':       artist,
    'artist_id':    artistId,
    'album_id':     albumId,
    'album_name':   albumName,
    'cover_url':    coverUrl,
    'audio_url':    audioUrl,
    'duration':     duration.inSeconds,
    'play_count':   playCount,
    'is_featured':  isFeatured,
    'is_explicit':  isExplicit,
    'is_liked':     isLiked,
    'is_downloaded':isDownloaded,
    'genre':        genre,
    'lyrics':       lyrics,
    'release_date': releaseDate?.toIso8601String(),
    'added_at':     addedAt?.toIso8601String(),
    'meta':         meta,
  };

  // ── Copy With ──────────────────────────────────────────────
  Song copyWith({
    String? id,
    String? title,
    String? artist,
    String? artistId,
    String? albumId,
    String? albumName,
    String? coverUrl,
    String? audioUrl,
    Duration? duration,
    int? playCount,
    bool? isFeatured,
    bool? isExplicit,
    bool? isLiked,
    bool? isDownloaded,
    String? genre,
    String? lyrics,
    DateTime? releaseDate,
    DateTime? addedAt,
    Artist? artistDetails,
    Map<String, dynamic>? meta,
  }) {
    return Song(
      id:            id            ?? this.id,
      title:         title         ?? this.title,
      artist:        artist        ?? this.artist,
      artistId:      artistId      ?? this.artistId,
      albumId:       albumId       ?? this.albumId,
      albumName:     albumName     ?? this.albumName,
      coverUrl:      coverUrl      ?? this.coverUrl,
      audioUrl:      audioUrl      ?? this.audioUrl,
      duration:      duration      ?? this.duration,
      playCount:     playCount     ?? this.playCount,
      isFeatured:    isFeatured    ?? this.isFeatured,
      isExplicit:    isExplicit    ?? this.isExplicit,
      isLiked:       isLiked       ?? this.isLiked,
      isDownloaded:  isDownloaded  ?? this.isDownloaded,
      genre:         genre         ?? this.genre,
      lyrics:        lyrics        ?? this.lyrics,
      releaseDate:   releaseDate   ?? this.releaseDate,
      addedAt:       addedAt       ?? this.addedAt,
      artistDetails: artistDetails ?? this.artistDetails,
      meta:          meta          ?? this.meta,
    );
  }

  // ── Helpers ────────────────────────────────────────────────
  String get formattedDuration {
    final m = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String get formattedPlayCount {
    if (playCount >= 1000000) {
      return '${(playCount / 1000000).toStringAsFixed(1)}M';
    } else if (playCount >= 1000) {
      return '${(playCount / 1000).toStringAsFixed(1)}K';
    }
    return playCount.toString();
  }

  String get releaseYear =>
      releaseDate != null ? releaseDate!.year.toString() : '';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Song && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Song(id: $id, title: $title, artist: $artist)';
}