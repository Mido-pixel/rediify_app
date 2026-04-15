import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/playlist.dart';

class PlaylistService {
  final String baseUrl = "http://localhost/redlify_api";

  Future<Playlist> fetchPlaylist(int id) async {
    final response = await http.get(Uri.parse("$baseUrl/get_playlist.php?id=$id"));

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);

      final Map<String, dynamic> playlistJson = {
        "id": jsonData.first["playlist_id"].toString(),
        "user_id": "1", // placeholder until you add user info
        "name": jsonData.first["playlist_title"],
        "song_count": jsonData.length,
        "total_duration_seconds": jsonData.fold<int>(
          0,
          (sum, song) => sum + (song["duration"] as int? ?? 0),
        ),
        "created_at": DateTime.now().toIso8601String(),
        "songs": jsonData,
      };

      return Playlist.fromJson(playlistJson);
    } else {
      throw Exception("Failed to load playlist");
    }
  }
}
