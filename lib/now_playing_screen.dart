import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import 'services/music_service.dart';

class NowPlayingScreen extends StatefulWidget {
  final double volume;                         // ✅ from main.dart
  final ValueChanged<double> onVolumeChanged;  // ✅ from main.dart

  const NowPlayingScreen({
    super.key,
    required this.volume,
    required this.onVolumeChanged,
  });

  @override
  State<NowPlayingScreen> createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends State<NowPlayingScreen>
    with TickerProviderStateMixin {
  late AnimationController _discRotation;
  late AnimationController _bgPulse;

  @override
  void initState() {
    super.initState();
    _discRotation = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );
    _bgPulse = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
  }

  @override
  void didUpdateWidget(NowPlayingScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // ✅ Sync hardware volume button changes into MusicService
    if (oldWidget.volume != widget.volume) {
      context.read<MusicService>().syncVolume(widget.volume);
    }
  }

  @override
  void dispose() {
    _discRotation.dispose();
    _bgPulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final music = context.watch<MusicService>();

    // Control disc spin based on real playback
    if (music.isPlaying) {
      if (!_discRotation.isAnimating) _discRotation.repeat();
      if (!_bgPulse.isAnimating)      _bgPulse.repeat(reverse: true);
    } else {
      _discRotation.stop();
      _bgPulse.stop();
    }

    // If no song selected — show song picker
    if (music.currentSong == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF121212),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.keyboard_arrow_down,
                color: Colors.white, size: 30),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('Pick a Song',
              style: TextStyle(color: Colors.white)),
        ),
        body: ListView.builder(
          itemCount: music.songs.length,
          itemBuilder: (_, i) {
            final song = music.songs[i];
            return ListTile(
              leading: Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                    color: song.themeColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8)),
                child: Icon(Icons.music_note,
                    color: song.themeColor, size: 24),
              ),
              title: Text(song.title,
                  style: const TextStyle(color: Colors.white,
                      fontWeight: FontWeight.w600)),
              subtitle: Text('${song.artist} • ${song.genre}',
                  style: const TextStyle(color: Colors.white54)),
              onTap: () => music.playSong(song),
            );
          },
        ),
      );
    }

    final song       = music.currentSong!;
    final themeColor = song.themeColor;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(children: [

        // ── Animated background ────────────────────────────
        AnimatedBuilder(
          animation: _bgPulse,
          builder: (_, _) => Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  themeColor.withOpacity(0.9),
                  themeColor.withOpacity(0.4),
                  Colors.black,
                  Colors.black,
                ],
                stops: const [0.0, 0.3, 0.65, 1.0],
              ),
            ),
          ),
        ),

        SafeArea(child: Column(children: [

          // ── Top bar ─────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 8, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.keyboard_arrow_down,
                      color: Colors.white, size: 30),
                  onPressed: () => Navigator.pop(context),
                ),
                Column(children: [
                  const Text('NOW PLAYING', style: TextStyle(
                      color: Colors.white54, fontSize: 10,
                      letterSpacing: 2, fontWeight: FontWeight.w600)),
                  Text(song.genre, style: const TextStyle(
                      color: Colors.white70, fontSize: 12)),
                ]),
                IconButton(
                  icon: const Icon(Icons.queue_music,
                      color: Colors.white),
                  onPressed: () => _showQueue(context, music),
                ),
              ],
            ),
          ),

          Expanded(child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(children: [
              const SizedBox(height: 16),

              // ── Vinyl disc ──────────────────────────────
              AnimatedBuilder(
                animation: _discRotation,
                builder: (_, child) => Transform.rotate(
                  angle: _discRotation.value * 2 * math.pi,
                  child: child,
                ),
                child: Container(
                  width: 270, height: 270,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(
                        color: themeColor.withOpacity(0.6),
                        blurRadius: 50, spreadRadius: 10)],
                  ),
                  child: CustomPaint(
                    painter: _VinylPainter(color: themeColor),
                    child: Center(child: Container(
                      width: 80, height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black,
                        border: Border.all(
                            color: themeColor.withOpacity(0.6),
                            width: 2),
                      ),
                      child: Center(child: Container(
                        width: 12, height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: themeColor,
                          boxShadow: [BoxShadow(
                              color: themeColor.withOpacity(0.8),
                              blurRadius: 8, spreadRadius: 2)],
                        ),
                      )),
                    )),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // ── Song info ───────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(song.title, style: const TextStyle(
                          color: Colors.white, fontSize: 24,
                          fontWeight: FontWeight.w900),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text(song.artist, style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 15)),
                    ],
                  )),
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
                    onPressed: () => music.toggleLike(),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ── Progress bar ────────────────────────────
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor:   Colors.white,
                  inactiveTrackColor: Colors.white24,
                  thumbColor:         Colors.white,
                  overlayColor:       Colors.white24,
                  trackHeight:        3,
                  thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 6),
                  overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 14),
                ),
                child: Slider(
                  value: music.progress,
                  onChanged: (v) => music.seekTo(v),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(music.positionLabel,
                        style: const TextStyle(
                            color: Colors.white60, fontSize: 12)),
                    Text(music.durationLabel,
                        style: const TextStyle(
                            color: Colors.white60, fontSize: 12)),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── Controls ────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () => music.toggleShuffle(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: music.isShuffle ? BoxDecoration(
                          color: themeColor.withOpacity(0.15),
                          shape: BoxShape.circle) : null,
                      child: Icon(Icons.shuffle,
                          color: music.isShuffle
                              ? themeColor
                              : Colors.white54,
                          size: 26),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => music.playPrevious(),
                    child: const Icon(Icons.skip_previous,
                        color: Colors.white, size: 40),
                  ),
                  GestureDetector(
                    onTap: () => music.togglePlayPause(),
                    child: Container(
                      width: 72, height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [BoxShadow(
                            color: Colors.white.withOpacity(0.3),
                            blurRadius: 20, spreadRadius: 4)],
                      ),
                      child: music.isBuffering
                          ? const Padding(
                              padding: EdgeInsets.all(20),
                              child: CircularProgressIndicator(
                                  color: Color(0xFFE8173A),
                                  strokeWidth: 2.5))
                          : Icon(
                              music.isPlaying
                                  ? Icons.pause
                                  : Icons.play_arrow,
                              color: Colors.black, size: 40),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => music.playNext(),
                    child: const Icon(Icons.skip_next,
                        color: Colors.white, size: 40),
                  ),
                  GestureDetector(
                    onTap: () => music.toggleRepeat(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: music.isRepeat ? BoxDecoration(
                          color: themeColor.withOpacity(0.15),
                          shape: BoxShape.circle) : null,
                      child: Icon(
                          music.isRepeat
                              ? Icons.repeat_one
                              : Icons.repeat,
                          color: music.isRepeat
                              ? themeColor
                              : Colors.white54,
                          size: 26),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ── Volume ──────────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(children: [
                  const Icon(Icons.volume_mute,
                      color: Colors.white54, size: 18),
                  Expanded(child: Slider(
                    value: music.volume,
                    onChanged: (v) {
                      music.setVolume(v);           // ✅ update MusicService
                      widget.onVolumeChanged(v);    // ✅ update main.dart state
                    },
                  )),
                  const Icon(Icons.volume_up,
                      color: Colors.white54, size: 18),
                ]),
              ),

              const SizedBox(height: 24),

              // ── Song list (quick switch) ─────────────────
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('All Songs', style: TextStyle(
                    color: Colors.white70, fontSize: 13,
                    fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 8),
              ...music.songs.map((s) {
                final isCurrent = music.currentSong?.id == s.id;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? s.themeColor
                          : s.themeColor.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isCurrent && music.isPlaying
                          ? Icons.graphic_eq
                          : Icons.music_note,
                      color: Colors.white, size: 20,
                    ),
                  ),
                  title: Text(s.title, style: TextStyle(
                      color: isCurrent ? themeColor : Colors.white,
                      fontWeight: isCurrent
                          ? FontWeight.w800
                          : FontWeight.normal,
                      fontSize: 14)),
                  subtitle: Text(s.artist,
                      style: const TextStyle(
                          color: Colors.white54, fontSize: 12)),
                  onTap: () => music.playSong(s),
                );
              }),

              const SizedBox(height: 40),
            ]),
          )),
        ])),
      ]),
    );
  }

  // ── Queue Bottom Sheet ─────────────────────────────────────
  void _showQueue(BuildContext context, MusicService music) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(24))),
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        builder: (_, sc) => Column(children: [
          const SizedBox(height: 12),
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 16),
          const Text('Queue', style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Expanded(child: ListView.builder(
            controller: sc,
            itemCount: music.songs.length,
            itemBuilder: (_, i) {
              final s = music.songs[i];
              final isCurrent = music.currentSong?.id == s.id;
              return ListTile(
                leading: Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCurrent
                        ? s.themeColor
                        : Colors.white12,
                  ),
                  child: Icon(
                    isCurrent
                        ? Icons.graphic_eq
                        : Icons.music_note,
                    color: Colors.white, size: 20,
                  ),
                ),
                title: Text(s.title, style: TextStyle(
                    color: isCurrent ? s.themeColor : Colors.white,
                    fontWeight: isCurrent
                        ? FontWeight.w800
                        : FontWeight.normal)),
                subtitle: Text(s.artist,
                    style: const TextStyle(color: Colors.white54)),
                onTap: () {
                  music.playSong(s);
                  Navigator.pop(context);
                },
              );
            },
          )),
        ]),
      ),
    );
  }
}

// ── Vinyl painter ──────────────────────────────────────────────
class _VinylPainter extends CustomPainter {
  final Color color;
  _VinylPainter({required this.color});

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
            ..color = Colors.white
                .withOpacity(0.04 + (i % 3) * 0.01)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.2);
    }

    canvas.drawCircle(center, radius,
        Paint()
          ..shader = RadialGradient(
            colors: [
              Colors.white.withOpacity(0.12),
              Colors.transparent
            ],
            center: const Alignment(-0.3, -0.4),
          ).createShader(
              Rect.fromCircle(center: center, radius: radius)));

    canvas.drawCircle(center, radius * 0.42,
        Paint()
          ..shader = RadialGradient(
            colors: [
              color.withOpacity(0.8),
              color.withOpacity(0.2)
            ],
          ).createShader(Rect.fromCircle(
              center: center, radius: radius * 0.42)));

    canvas.drawCircle(center, radius * 0.42,
        Paint()
          ..color = color.withOpacity(0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5);
  }

  @override
  bool shouldRepaint(_VinylPainter old) => old.color != color;
}