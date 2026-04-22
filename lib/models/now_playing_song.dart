class NowPlayingSong {
  final String id;
  final String title;
  final String artist;
  final String album;
  final String genre;
  final String duration;
  final int durationSeconds;
  final String fileUrl;

  NowPlayingSong({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.genre,
    required this.duration,
    required this.durationSeconds,
    required this.fileUrl,
  });
}
