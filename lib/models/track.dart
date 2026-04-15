import 'artist.dart';

class Track {
  final String id;
  final String songId;
  final String albumId;
  final String title;
  final Artist? artist;
  final int trackNumber;
  final int discNumber;
  final Duration duration;
  final String? audioUrl;
  final String? previewUrl;
  final bool isExplicit;
  final bool isPlayable;
  final int playCount;
  final Map<String, dynamic>? externalIds; // ISRC, etc.
  final DateTime? addedAt;

  const Track({
    required this.id,
    required this.songId,
    required this.albumId,
    required this.title,
    this.artist,
    this.trackNumber = 1,
    this.discNumber = 1,
    this.duration = Duration.zero,
    this.audioUrl,
    this.previewUrl,
    this.isExplicit = false,
    this.isPlayable = true,
    this.playCount = 0,
    this.externalIds,
    this.addedAt,
  });

  // ── From JSON ──────────────────────────────────────────────
  factory Track.fromJson(Map<String, dynamic> json) {
    final durationMs = json['duration_ms'] as int? ?? 0;

    return Track(
      id:           json['id'] as String,
      songId:       json['song_id'] as String,
      albumId:      json['album_id'] as String,
      title:        json['title'] as String,
      artist:       json['artists'] != null
                      ? Artist.fromJson(json['artists'])
                      : null,
      trackNumber:  json['track_number'] as int? ?? 1,
      discNumber:   json['disc_number'] as int? ?? 1,
      duration:     Duration(milliseconds: durationMs),
      audioUrl:     json['audio_url'] as String?,
      previewUrl:   json['preview_url'] as String?,
      isExplicit:   json['is_explicit'] as bool? ?? false,
      isPlayable:   json['is_playable'] as bool? ?? true,
      playCount:    json['play_count'] as int? ?? 0,
      externalIds:  json['external_ids'] as Map<String, dynamic>?,
      addedAt:      json['added_at'] != null
                      ? DateTime.tryParse(json['added_at'])
                      : null,
    );
  }

  // ── To JSON ────────────────────────────────────────────────
  Map<String, dynamic> toJson() => {
    'id':           id,
    'song_id':      songId,
    'album_id':     albumId,
    'title':        title,
    'track_number': trackNumber,
    'disc_number':  discNumber,
    'duration_ms':  duration.inMilliseconds,
    'audio_url':    audioUrl,
    'preview_url':  previewUrl,
    'is_explicit':  isExplicit,
    'is_playable':  isPlayable,
    'play_count':   playCount,
    'external_ids': externalIds,
    'added_at':     addedAt?.toIso8601String(),
  };

  // ── Copy With ──────────────────────────────────────────────
  Track copyWith({
    String? id,
    String? songId,
    String? albumId,
    String? title,
    Artist? artist,
    int? trackNumber,
    int? discNumber,
    Duration? duration,
    String? audioUrl,
    String? previewUrl,
    bool? isExplicit,
    bool? isPlayable,
    int? playCount,
    Map<String, dynamic>? externalIds,
    DateTime? addedAt,
  }) {
    return Track(
      id:           id           ?? this.id,
      songId:       songId       ?? this.songId,
      albumId:      albumId      ?? this.albumId,
      title:        title        ?? this.title,
      artist:       artist       ?? this.artist,
      trackNumber:  trackNumber  ?? this.trackNumber,
      discNumber:   discNumber   ?? this.discNumber,
      duration:     duration     ?? this.duration,
      audioUrl:     audioUrl     ?? this.audioUrl,
      previewUrl:   previewUrl   ?? this.previewUrl,
      isExplicit:   isExplicit   ?? this.isExplicit,
      isPlayable:   isPlayable   ?? this.isPlayable,
      playCount:    playCount    ?? this.playCount,
      externalIds:  externalIds  ?? this.externalIds,
      addedAt:      addedAt      ?? this.addedAt,
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
      return '${(playCount / 1000000).toStringAsFixed(1)}M plays';
    } else if (playCount >= 1000) {
      return '${(playCount / 1000).toStringAsFixed(1)}K plays';
    }
    return '$playCount plays';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Track && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'Track(id: $id, title: $title, trackNumber: $trackNumber)';
}