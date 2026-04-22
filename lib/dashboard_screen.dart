// dashboard_screen.dart
// DashboardScreen is now a route alias → AppShell(initialIndex: 0).
// DashboardHomeTab is the actual content widget used by AppShell.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/music_service.dart';
import 'app_shell.dart';

// ── Colour palette (shared across dashboard widgets) ──────────
class RColors {
  static const bg            = Color(0xFF121212);
  static const surface       = Color(0xFF1A1A1A);
  static const elevated      = Color(0xFF242424);
  static const highlight     = Color(0xFF2A2A2A);
  static const red           = Color(0xFFE8173A);
  static const redDark       = Color(0xFFB01229);
  static const redGlow       = Color(0x33E8173A);
  static const green         = Color(0xFF1DB954);
  static const textPrimary   = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFB3B3B3);
  static const textMuted     = Color(0xFF535353);
  static const gradRed = LinearGradient(
    colors: [Color(0xFFE8173A), Color(0xFF7B0D1E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

// ── Route entry point ─────────────────────────────────────────
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) => const AppShell(initialIndex: 0);
}

// ── Home tab body (used by AppShell's IndexedStack) ───────────
class DashboardHomeTab extends StatelessWidget {
  const DashboardHomeTab({super.key});

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning ☀️';
    if (h < 17) return 'Good afternoon 🎵';
    return 'Good evening 🌙';
  }

  @override
  Widget build(BuildContext context) {
    final music = context.watch<MusicService>();
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 160),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGreetingSection(context),
          const SizedBox(height: 20),
          _buildLastSession(context, music),
          const SizedBox(height: 20),
          _buildFeaturedBanner(context, music),
          const SizedBox(height: 24),
          _sectionHeader('Your Songs — Tap to Play'),
          const SizedBox(height: 4),
          _buildSongList(context, music),
          const SizedBox(height: 24),
          _sectionHeader('Recently played'),
          const SizedBox(height: 12),
          _buildRecentRow(context),
          const SizedBox(height: 24),
          _sectionHeader('Made for you'),
          const SizedBox(height: 12),
          _buildMixRow(context),
          const SizedBox(height: 24),
          _sectionHeader('Trending now'),
          const SizedBox(height: 4),
          _buildTrendingList(context),
          const SizedBox(height: 24),
          _sectionHeader('New releases'),
          const SizedBox(height: 12),
          _buildNewReleasesRow(context),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(title,
            style: const TextStyle(
                color: RColors.textPrimary,
                fontSize: 18, fontWeight: FontWeight.w900)),
      );

  Widget _buildSongList(BuildContext context, MusicService music) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: music.songs.length,
      itemBuilder: (_, i) {
        final song = music.songs[i];
        final isCurrent = music.currentSong?.id == song.id;
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Container(
            width: 50, height: 50,
            decoration: BoxDecoration(
              color: isCurrent
                  ? song.themeColor
                  : song.themeColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isCurrent && music.isPlaying ? Icons.graphic_eq : Icons.music_note,
              color: Colors.white, size: 24,
            ),
          ),
          title: Text(song.title,
              style: TextStyle(
                color: isCurrent ? song.themeColor : Colors.white,
                fontWeight: FontWeight.w600, fontSize: 14,
              ),
              maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text('${song.artist} • ${song.genre}',
              style: const TextStyle(color: RColors.textSecondary, fontSize: 12)),
          trailing: isCurrent && music.isPlaying
              ? Icon(Icons.pause_circle, color: song.themeColor, size: 32)
              : const Icon(Icons.play_circle_outline, color: RColors.textMuted, size: 32),
          onTap: () async {
            await music.playSong(song);
            if (context.mounted) Navigator.pushNamed(context, '/nowplaying');
          },
        );
      },
    );
  }

  Widget _buildLastSession(BuildContext context, MusicService music) {
    final last = music.currentSong ?? music.songs.first;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: RColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: RColors.red.withOpacity(0.3)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.history, color: RColors.red, size: 18),
          const SizedBox(width: 6),
          const Text('Last Session',
              style: TextStyle(color: RColors.textPrimary, fontSize: 14,
                  fontWeight: FontWeight.w700)),
          const Spacer(),
          const Text('Tap Resume to continue',
              style: TextStyle(color: RColors.textMuted, fontSize: 11)),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: last.themeColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.music_note, color: last.themeColor, size: 22),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(last.title,
                  style: const TextStyle(color: RColors.textPrimary, fontSize: 13,
                      fontWeight: FontWeight.w600),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              Text('${last.artist} • ${last.genre}',
                  style: const TextStyle(color: RColors.textSecondary, fontSize: 11)),
            ]),
          ),
          GestureDetector(
            onTap: () async {
              await music.playSong(last);
              if (context.mounted) Navigator.pushNamed(context, '/nowplaying');
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                  color: RColors.red, borderRadius: BorderRadius.circular(20)),
              child: const Text('Resume',
                  style: TextStyle(color: Colors.white, fontSize: 12,
                      fontWeight: FontWeight.w700)),
            ),
          ),
        ]),
      ]),
    );
  }

  Widget _buildGreetingSection(BuildContext context) {
    final items = [
      ('Liked Songs', Icons.favorite,       const Color(0xFFE8173A)),
      ('Top Hits',    Icons.trending_up,    const Color(0xFF1565C0)),
      ('Workout',     Icons.fitness_center, const Color(0xFF6A1B9A)),
      ('Chill Mix',   Icons.waves,          const Color(0xFF00695C)),
      ('Hip Hop',     Icons.album,          const Color(0xFF4E342E)),
      ('Party',       Icons.celebration,    const Color(0xFF37474F)),
    ];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Text(_greeting,
            style: const TextStyle(color: RColors.textPrimary,
                fontSize: 22, fontWeight: FontWeight.w900)),
      ),
      GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, crossAxisSpacing: 8,
            mainAxisSpacing: 8, childAspectRatio: 4),
        itemCount: items.length,
        itemBuilder: (_, i) {
          final item = items[i];
          return GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/nowplaying'),
            child: Container(
              decoration: BoxDecoration(
                  color: RColors.elevated, borderRadius: BorderRadius.circular(4)),
              child: Row(children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: item.$3,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      bottomLeft: Radius.circular(4),
                    ),
                  ),
                  child: Icon(item.$2, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(item.$1,
                      style: const TextStyle(color: RColors.textPrimary,
                          fontWeight: FontWeight.w700, fontSize: 13),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
              ]),
            ),
          );
        },
      ),
    ]);
  }

  Widget _buildFeaturedBanner(BuildContext context, MusicService music) {
    return GestureDetector(
      onTap: () async {
        if (music.songs.isNotEmpty) await music.playSong(music.songs.first);
        if (context.mounted) Navigator.pushNamed(context, '/nowplaying');
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        height: 190,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            colors: [Color(0xFFE8173A), Color(0xFF7B0D1E), Color(0xFF1A1A1A)],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
        ),
        child: Stack(children: [
          Positioned(
            right: -10, top: -10,
            child: Icon(Icons.music_note, size: 160,
                color: Colors.white.withOpacity(0.05)),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                      color: RColors.red, borderRadius: BorderRadius.circular(4)),
                  child: const Text('FEATURED',
                      style: TextStyle(color: Colors.white, fontSize: 10,
                          fontWeight: FontWeight.w800, letterSpacing: 1.5)),
                ),
                const SizedBox(height: 8),
                Text(
                  music.songs.isNotEmpty ? music.songs.first.title : "Today's Top Hits",
                  style: const TextStyle(color: Colors.white, fontSize: 22,
                      fontWeight: FontWeight.w900),
                ),
                Text(
                  music.songs.isNotEmpty ? music.songs.first.artist : 'The hottest tracks right now',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 12),
                Row(children: [
                  Container(
                    width: 40, height: 40,
                    decoration: const BoxDecoration(
                        color: Colors.white, shape: BoxShape.circle),
                    child: const Icon(Icons.play_arrow, color: Colors.black, size: 24),
                  ),
                  const SizedBox(width: 14),
                  const Icon(Icons.shuffle, color: Colors.white70, size: 20),
                  const SizedBox(width: 14),
                  const Icon(Icons.favorite_border, color: Colors.white70, size: 20),
                ]),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildRecentRow(BuildContext context) {
    final items = [
      ('Daily Mix 1', Icons.queue_music,   const Color(0xFF1DB954)),
      ('Afrobeats',   Icons.music_note,    const Color(0xFFE8173A)),
      ('Rap Caviar',  Icons.album,         const Color(0xFF1565C0)),
      ('R&B Only',    Icons.headphones,    const Color(0xFF6A1B9A)),
      ('Rock Hits',   Icons.electric_bolt, const Color(0xFF37474F)),
    ];
    return SizedBox(
      height: 145,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: items.length,
        itemBuilder: (_, i) {
          final item = items[i];
          return GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/nowplaying'),
            child: Container(
              width: 108,
              margin: const EdgeInsets.only(right: 12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  height: 108, width: 108,
                  decoration: BoxDecoration(
                      color: item.$3, borderRadius: BorderRadius.circular(8)),
                  child: Icon(item.$2, color: Colors.white.withOpacity(0.8), size: 38),
                ),
                const SizedBox(height: 6),
                Text(item.$1,
                    style: const TextStyle(color: RColors.textPrimary,
                        fontSize: 12, fontWeight: FontWeight.w600),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
              ]),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMixRow(BuildContext context) {
    final mixes = [
      ('Daily Mix 1',     'Based on your taste', const Color(0xFF303F9F)),
      ('Discover Weekly', 'New music for you',   const Color(0xFF1B5E20)),
      ('Release Radar',   'Fresh releases',       const Color(0xFFB71C1C)),
      ('Time Capsule',    'Old favorites',        const Color(0xFF4A148C)),
    ];
    return SizedBox(
      height: 205,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: mixes.length,
        itemBuilder: (_, i) {
          final mix = mixes[i];
          return GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/nowplaying'),
            child: Container(
              width: 148,
              margin: const EdgeInsets.only(right: 14),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  height: 148, width: 148,
                  decoration: BoxDecoration(
                    color: mix.$3,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [BoxShadow(
                        color: mix.$3.withOpacity(0.4),
                        blurRadius: 12, offset: const Offset(0, 6))],
                  ),
                  child: Stack(children: [
                    Center(child: Icon(Icons.headphones,
                        color: Colors.white.withOpacity(0.3), size: 56)),
                    Positioned(bottom: 10, left: 10,
                        child: Text(mix.$1,
                            style: const TextStyle(color: Colors.white,
                                fontSize: 13, fontWeight: FontWeight.w800))),
                  ]),
                ),
                const SizedBox(height: 6),
                Text(mix.$2,
                    style: const TextStyle(color: RColors.textSecondary, fontSize: 12),
                    maxLines: 2, overflow: TextOverflow.ellipsis),
              ]),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTrendingList(BuildContext context) {
    final colors = [
      RColors.red, const Color(0xFF1DB954), const Color(0xFF1565C0),
      const Color(0xFF6A1B9A), const Color(0xFFE65100),
    ];
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 5,
      itemBuilder: (_, i) => ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        leading: Stack(alignment: Alignment.center, children: [
          Container(
            width: 46, height: 46,
            decoration: BoxDecoration(
              color: colors[i].withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(Icons.music_note, color: colors[i], size: 22),
          ),
          Positioned(bottom: 0, right: 0,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(color: RColors.bg, shape: BoxShape.circle),
                child: Text('${i + 1}',
                    style: TextStyle(color: colors[i], fontSize: 9,
                        fontWeight: FontWeight.w900)),
              )),
        ]),
        title: Text('Song Title ${i + 1}',
            style: const TextStyle(color: RColors.textPrimary,
                fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Text('Artist ${i + 1} • ${3 + i}:${(20 + i * 7).toString().padLeft(2, '0')}',
            style: const TextStyle(color: RColors.textSecondary, fontSize: 12)),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          if (i == 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                  color: RColors.redGlow, borderRadius: BorderRadius.circular(4)),
              child: const Text('🔥 HOT',
                  style: TextStyle(color: RColors.red, fontSize: 10,
                      fontWeight: FontWeight.w800)),
            ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: RColors.textMuted, size: 20),
            onPressed: () {},
          ),
        ]),
        onTap: () => Navigator.pushNamed(context, '/nowplaying'),
      ),
    );
  }

  Widget _buildNewReleasesRow(BuildContext context) {
    final releases = [
      ('Album Name',  'Artist 1', const Color(0xFFE8173A)),
      ('Single Drop', 'Artist 2', const Color(0xFF1DB954)),
      ('EP Title',    'Artist 3', const Color(0xFF1565C0)),
      ('Mixtape',     'Artist 4', const Color(0xFF6A1B9A)),
    ];
    return SizedBox(
      height: 170,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: releases.length,
        itemBuilder: (_, i) {
          final r = releases[i];
          return GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/nowplaying'),
            child: Container(
              width: 128,
              margin: const EdgeInsets.only(right: 14),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  height: 128, width: 128,
                  decoration: BoxDecoration(color: r.$3,
                      borderRadius: BorderRadius.circular(6)),
                  child: Center(child: Icon(Icons.album,
                      color: Colors.white.withOpacity(0.5), size: 48)),
                ),
                const SizedBox(height: 6),
                Text(r.$1,
                    style: const TextStyle(color: RColors.textPrimary,
                        fontSize: 13, fontWeight: FontWeight.w700),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(r.$2,
                    style: const TextStyle(color: RColors.textSecondary, fontSize: 11),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
              ]),
            ),
          );
        },
      ),
    );
  }
}