import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/sample_queue.dart' as sample_queue_data;
import '../services/music_service.dart';

class SamplePlaylistScreen extends StatelessWidget {
  const SamplePlaylistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final music = context.read<MusicService>();

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Sample Playlist'),
        backgroundColor: Colors.transparent,
      ),
      body: ListView.builder(
        itemCount: sample_queue_data.sampleQueue.length,
        itemBuilder: (context, index) {
          final song = sample_queue_data.sampleQueue[index];
          return ListTile(
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: song.themeColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.music_note,
                  color: song.themeColor, size: 22),
            ),
            title: Text(song.title,
                style: const TextStyle(color: Colors.white,
                    fontWeight: FontWeight.w600)),
            subtitle: Text('${song.artist} • ${song.genre}',
                style: const TextStyle(color: Colors.white54)),
            trailing: IconButton(
              icon: const Icon(Icons.play_arrow, color: Colors.white),
              onPressed: () => music.playSong(song), // ✅ uses MusicService
            ),
          );
        },
      ),
    );
  }
}