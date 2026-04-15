import 'package:flutter/material.dart';
import 'package:volume_controller/volume_controller.dart';
import 'dart:math' as math;

// ─────────────────────────────────────────
// MODEL
// ─────────────────────────────────────────
class NowPlayingSong {
  final String id;
  final String title;
  final String artist;
  final String album;
  final String genre;
  final String duration;
  final int durationSeconds;
  final Color themeColor;
  bool isLiked;

  NowPlayingSong({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.genre,
    required this.duration,
    required this.durationSeconds,
    required this.themeColor,
    this.isLiked = false,
  });
}

// ─────────────────────────────────────────
// CONTROLLER
// ─────────────────────────────────────────
class NowPlayingController extends ChangeNotifier {
  final List<NowPlayingSong> _queue = [
    NowPlayingSong(id: '1', title: "God's Plan",      artist: "Drake",          album: "Scorpion",      genre: "Hip Hop",   duration: "3:18", durationSeconds: 198, themeColor: const Color(0xFF1565C0)),
    NowPlayingSong(id: '2', title: "Essence",         artist: "Wizkid",         album: "Made In Lagos", genre: "Afrobeats", duration: "4:02", durationSeconds: 242, themeColor: const Color(0xFFE65100), isLiked: true),
    NowPlayingSong(id: '3', title: "Blinding Lights", artist: "The Weeknd",     album: "After Hours",   genre: "R&B",       duration: "3:22", durationSeconds: 202, themeColor: const Color(0xFFB71C1C)),
    NowPlayingSong(id: '4', title: "No Woman No Cry", artist: "Bob Marley",     album: "Natty Dread",   genre: "Reggae",    duration: "3:55", durationSeconds: 235, themeColor: const Color(0xFF2E7D32)),
    NowPlayingSong(id: '5', title: "HUMBLE.",         artist: "Kendrick Lamar", album: "DAMN.",         genre: "Hip Hop",   duration: "2:57", durationSeconds: 177, themeColor: const Color(0xFF4A148C)),
    NowPlayingSong(id: '6', title: "Ojuelegba",       artist: "Wizkid",         album: "Ayo",           genre: "Afrobeats", duration: "3:44", durationSeconds: 224, themeColor: const Color(0xFF00695C), isLiked: true),
  ];

  int _currentIndex = 0;
  bool _isPlaying   = false;
  bool _isShuffle   = false;
  bool _isRepeat    = false;
  double _progress  = 0.0;
  double _volume    = 0.8;

  NowPlayingSong get currentSong => _queue[_currentIndex];
  bool   get isPlaying           => _isPlaying;
  bool   get isShuffle           => _isShuffle;
  bool   get isRepeat            => _isRepeat;
  double get progress            => _progress;
  double get volume              => _volume;
  List<NowPlayingSong> get queue => _queue;
  int    get currentIndex        => _currentIndex;

  String get currentTimeLabel {
    final elapsed = (_progress * currentSong.durationSeconds).toInt();
    final m = elapsed ~/ 60;
    final s = elapsed % 60;
    return "$m:${s.toString().padLeft(2, '0')}";
  }

  void togglePlayPause() { _isPlaying = !_isPlaying; notifyListeners(); }
  void toggleShuffle()   { _isShuffle = !_isShuffle; notifyListeners(); }
  void toggleRepeat()    { _isRepeat  = !_isRepeat;  notifyListeners(); }
  void seekTo(double v)  { _progress  = v;            notifyListeners(); }
  void setVolume(double v) { _volume  = v;            notifyListeners(); }
  void toggleLike() { currentSong.isLiked = !currentSong.isLiked; notifyListeners(); }

  void nextSong() {
    _currentIndex = _isShuffle
        ? math.Random().nextInt(_queue.length)
        : (_currentIndex + 1) % _queue.length;
    _progress  = 0.0;
    _isPlaying = true;
    notifyListeners();
  }

  void previousSong() {
    if (_progress > 0.2) {
      _progress = 0.0;
    } else {
      _currentIndex = (_currentIndex - 1 + _queue.length) % _queue.length;
      _progress = 0.0;
    }
    _isPlaying = true;
    notifyListeners();
  }

  void playFromQueue(int index) {
    _currentIndex = index;
    _progress     = 0.0;
    _isPlaying    = true;
    notifyListeners();
  }
}

// ─────────────────────────────────────────
// NOW PLAYING SCREEN  ✅ no required params
// ─────────────────────────────────────────
class NowPlayingScreen extends StatefulWidget {
  const NowPlayingScreen({super.key}); // ✅ FIXED — no volume, no callback

  @override
  State<NowPlayingScreen> createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends State<NowPlayingScreen>
    with TickerProviderStateMixin {
  final NowPlayingController _ctrl = NowPlayingController();
  late AnimationController _discRotation;
  late AnimationController _bgPulse;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();

    _discRotation = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _bgPulse = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _bgPulse, curve: Curves.easeInOut),
    );

    // ✅ Sync volume from device on open
    VolumeController().getVolume().then((v) {
      _ctrl.setVolume(v);
    });

    // ✅ Listen for hardware volume button changes
    VolumeController().listener((v) {
      _ctrl.setVolume(v);
    });
  }

  @override
  void dispose() {
    _discRotation.dispose();
    _bgPulse.dispose();
    VolumeController().removeListener();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final song = _ctrl.currentSong;

        if (_ctrl.isPlaying) {
          _discRotation.repeat();
          _bgPulse.repeat(reverse: true);
        } else {
          _discRotation.stop();
          _bgPulse.stop();
        }

        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              // ── ANIMATED BACKGROUND ────────────────────────
              _buildBackground(song),

              // ── CONTENT ────────────────────────────────────
              SafeArea(
                child: Column(
                  children: [
                    _buildTopBar(context),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        child: Column(
                          children: [
                            const SizedBox(height: 16),
                            _buildVinylDisc(song),
                            const SizedBox(height: 32),
                            _buildSongInfo(song),
                            const SizedBox(height: 24),
                            _buildProgressBar(song),
                            const SizedBox(height: 16),
                            _buildControls(song),
                            const SizedBox(height: 20),
                            _buildVolumeBar(),
                            const SizedBox(height: 20),
                            _buildExtraActions(),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── BACKGROUND ──────────────────────────────────────────────
  Widget _buildBackground(NowPlayingSong song) {
    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (_, _) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              song.themeColor.withOpacity(0.9),
              song.themeColor.withOpacity(0.4),
              Colors.black,
              Colors.black,
            ],
            stops: const [0.0, 0.3, 0.65, 1.0],
          ),
        ),
      ),
    );
  }

  // ── TOP BAR ─────────────────────────────────────────────────
  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_down,
                color: Colors.white, size: 30),
            onPressed: () => Navigator.pop(context),
          ),
          Column(
            children: [
              const Text('NOW PLAYING',
                  style: TextStyle(
                      color: Colors.white54,
                      fontSize: 10,
                      letterSpacing: 2,
                      fontWeight: FontWeight.w600)),
              Text(_ctrl.currentSong.genre,
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 12)),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.queue_music, color: Colors.white),
            onPressed: _showQueueSheet,
          ),
        ],
      ),
    );
  }

  // ── VINYL DISC ───────────────────────────────────────────────
  Widget _buildVinylDisc(NowPlayingSong song) {
    return AnimatedBuilder(
      animation: _discRotation,
      builder: (_, child) => Transform.rotate(
        angle: _discRotation.value * 2 * math.pi,
        child: child,
      ),
      child: Container(
        width: 270,
        height: 270,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: song.themeColor.withOpacity(0.6),
              blurRadius: 50,
              spreadRadius: 10,
            ),
          ],
        ),
        child: CustomPaint(
          painter: _VinylDiscPainter(themeColor: song.themeColor),
          child: Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black,
                border: Border.all(
                    color: song.themeColor.withOpacity(0.6), width: 2),
              ),
              child: Center(
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: song.themeColor,
                    boxShadow: [
                      BoxShadow(
                        color: song.themeColor.withOpacity(0.8),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── SONG INFO ────────────────────────────────────────────────
  Widget _buildSongInfo(NowPlayingSong song) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(song.title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w900),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Text(song.artist,
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 15)),
              Text(song.album,
                  style: const TextStyle(
                      color: Colors.white54, fontSize: 12)),
            ],
          ),
        ),
        Column(
          children: [
            IconButton(
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Icon(
                  song.isLiked
                      ? Icons.favorite
                      : Icons.favorite_border,
                  key: ValueKey(song.isLiked),
                  color: song.isLiked
                      ? const Color(0xFFE8173A)
                      : Colors.white54,
                  size: 28,
                ),
              ),
              onPressed: _ctrl.toggleLike,
            ),
            IconButton(
              icon: const Icon(Icons.share_outlined,
                  color: Colors.white54, size: 22),
              onPressed: () {},
            ),
          ],
        ),
      ],
    );
  }

  // ── PROGRESS BAR ─────────────────────────────────────────────
  Widget _buildProgressBar(NowPlayingSong song) {
    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor:   Colors.white,
            inactiveTrackColor: Colors.white24,
            thumbColor:         Colors.white,
            overlayColor:       Colors.white24,
            trackHeight:        3,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
          ),
          child: Slider(
            value: _ctrl.progress,
            onChanged: _ctrl.seekTo,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_ctrl.currentTimeLabel,
                  style: const TextStyle(
                      color: Colors.white60, fontSize: 12)),
              Text(song.duration,
                  style: const TextStyle(
                      color: Colors.white60, fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }

  // ── CONTROLS ─────────────────────────────────────────────────
  Widget _buildControls(NowPlayingSong song) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _ctrlIcon(Icons.shuffle,     _ctrl.isShuffle, _ctrl.toggleShuffle, song.themeColor),
        GestureDetector(
          onTap: _ctrl.previousSong,
          child: const Icon(Icons.skip_previous, color: Colors.white, size: 40),
        ),
        GestureDetector(
          onTap: _ctrl.togglePlayPause,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 72, height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    color: Colors.white.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 4)
              ],
            ),
            child: Icon(
              _ctrl.isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.black, size: 40,
            ),
          ),
        ),
        GestureDetector(
          onTap: _ctrl.nextSong,
          child: const Icon(Icons.skip_next, color: Colors.white, size: 40),
        ),
        _ctrlIcon(
          _ctrl.isRepeat ? Icons.repeat_one : Icons.repeat,
          _ctrl.isRepeat, _ctrl.toggleRepeat, song.themeColor,
        ),
      ],
    );
  }

  Widget _ctrlIcon(IconData icon, bool active, VoidCallback onTap, Color activeColor) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: active
            ? BoxDecoration(
                color: activeColor.withOpacity(0.15),
                shape: BoxShape.circle)
            : null,
        child: Icon(icon,
            color: active ? activeColor : Colors.white54, size: 26),
      ),
    );
  }

  // ── VOLUME BAR ───────────────────────────────────────────────
  Widget _buildVolumeBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.volume_mute, color: Colors.white54, size: 18),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor:   Colors.white,
                inactiveTrackColor: Colors.white24,
                thumbColor:         Colors.white,
                overlayColor:       Colors.white12,
                trackHeight:        3,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
              ),
              child: Slider(
                value: _ctrl.volume,
                onChanged: (v) {
                  _ctrl.setVolume(v);           // ✅ update UI
                  VolumeController().setVolume(v); // ✅ update device volume
                },
              ),
            ),
          ),
          const Icon(Icons.volume_up, color: Colors.white54, size: 18),
        ],
      ),
    );
  }

  // ── EXTRA ACTIONS ────────────────────────────────────────────
  Widget _buildExtraActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _extraBtn(Icons.playlist_add,      'Add to\nPlaylist', () {}),
        _extraBtn(Icons.download_outlined, 'Download',         () {}),
        _extraBtn(Icons.lyrics_outlined,   'Lyrics',           () {}),
        _extraBtn(Icons.more_horiz,        'More',             () {}),
      ],
    );
  }

  Widget _extraBtn(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white70, size: 22),
          ),
          const SizedBox(height: 6),
          Text(label,
              style: const TextStyle(
                  color: Colors.white54, fontSize: 10, height: 1.2),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  // ── QUEUE SHEET ──────────────────────────────────────────────
  void _showQueueSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        builder: (_, sc) => AnimatedBuilder(
          animation: _ctrl,
          builder: (_, _) => Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 16),
              const Text('Up Next',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  controller: sc,
                  itemCount: _ctrl.queue.length,
                  itemBuilder: (_, i) {
                    final s = _ctrl.queue[i];
                    final isCurrent = i == _ctrl.currentIndex;
                    return ListTile(
                      leading: Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isCurrent ? s.themeColor : Colors.white12,
                        ),
                        child: Icon(
                          isCurrent ? Icons.graphic_eq : Icons.music_note,
                          color: Colors.white, size: 20,
                        ),
                      ),
                      title: Text(s.title,
                          style: TextStyle(
                            color: isCurrent ? s.themeColor : Colors.white,
                            fontWeight: isCurrent
                                ? FontWeight.w800
                                : FontWeight.normal,
                          )),
                      subtitle: Text(s.artist,
                          style: const TextStyle(color: Colors.white54)),
                      trailing: Text(s.duration,
                          style: const TextStyle(
                              color: Colors.white38, fontSize: 12)),
                      onTap: () {
                        _ctrl.playFromQueue(i);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// VINYL DISC PAINTER
// ─────────────────────────────────────────
class _VinylDiscPainter extends CustomPainter {
  final Color themeColor;
  _VinylDiscPainter({required this.themeColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    canvas.drawCircle(center, radius,
        Paint()..color = const Color(0xFF111111));

    for (int i = 1; i <= 12; i++) {
      final r = radius * (0.35 + i * 0.052);
      if (r >= radius) break;
      canvas.drawCircle(center, r,
          Paint()
            ..color = Colors.white.withOpacity(0.04 + (i % 3) * 0.01)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.2);
    }

    canvas.drawCircle(center, radius,
        Paint()
          ..shader = RadialGradient(
            colors: [Colors.white.withOpacity(0.12), Colors.transparent],
            center: const Alignment(-0.3, -0.4),
          ).createShader(Rect.fromCircle(center: center, radius: radius))
          ..style = PaintingStyle.fill);

    canvas.drawCircle(center, radius * 0.42,
        Paint()
          ..shader = RadialGradient(
            colors: [
              themeColor.withOpacity(0.8),
              themeColor.withOpacity(0.2),
            ],
          ).createShader(
              Rect.fromCircle(center: center, radius: radius * 0.42))
          ..style = PaintingStyle.fill);

    canvas.drawCircle(center, radius * 0.42,
        Paint()
          ..color = themeColor.withOpacity(0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5);
  }

  @override
  bool shouldRepaint(_VinylDiscPainter old) =>
      old.themeColor != themeColor;
}