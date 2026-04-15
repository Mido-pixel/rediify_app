import 'package:flutter/material.dart';
import '../data/sample_queue.dart' as sample_queue_data;
import '../controllers/audio_player_controller.dart';

class SamplePlaylistScreen extends StatefulWidget {
  const SamplePlaylistScreen({super.key});

  @override
  State<SamplePlaylistScreen> createState() => _SamplePlaylistScreenState();
}

class _SamplePlaylistScreenState extends State<SamplePlaylistScreen> {
  final AudioPlayerController controller = AudioPlayerController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sample Playlist")),
      body: ListView.builder(
        itemCount: sample_queue_data.sampleQueue.length,
        itemBuilder: (context, index) {
          var sampleQueue = sample_queue_data.sampleQueue;
          final song = sampleQueue[index];
          return ListTile(
            title: Text(song.title),
            subtitle: Text("${song.artist} • ${song.genre}"),
            trailing: IconButton(
              icon: const Icon(Icons.play_arrow),
              onPressed: () => controller.playSong(song),
            ),
          );
        },
      ),
    );
  }
}
