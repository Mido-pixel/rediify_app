import 'package:just_audio/just_audio.dart';
import '../models/now_playing_song.dart';

class AudioPlayerController {
  final AudioPlayer _player = AudioPlayer();

  Future<void> playSong(NowPlayingSong song) async {
    try {
      // ✅ Use setAsset for local files
      await _player.setAsset('assets/audio/selected_song.mp3');
      await _player.play();
    } catch (e) {
      print("Error playing song: $e");
    }
  }

  void stop() {
    _player.stop();
  }

  void pause() {
    _player.pause();
  }

  void dispose() {
    _player.dispose();
  }
}
