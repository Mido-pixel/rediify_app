// app_shell.dart
// ─────────────────────────────────────────────────────────────
// Shared scaffold that wraps every main screen with a consistent
// Spotify-inspired bottom navigation bar + mini-player.
//
// Usage:
//   Navigator.pushReplacementNamed(context, '/dashboard');
// or embed directly:
//   AppShell(initialIndex: 2)  // opens Library tab
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/music_service.dart';

// Tab screens — import your real screen widgets here
import 'dashboard_screen.dart'  show DashboardHomeTab;
import 'library_screen.dart'    show LibraryScreen;
import 'search_screen.dart'     show SearchScreen;
import 'premium_tab.dart'       show PremiumTab;
import 'profile_screen.dart'    show ProfileScreen;

// ── Brand colours (matches dashboard_screen.dart RColors) ────
class _C {
  static const bg       = Color(0xFF121212);
  static const surface  = Color(0xFF1A1A1A);
  static const red      = Color(0xFFE8173A);
  static const muted    = Color(0xFF535353);
  static const text     = Color(0xFFFFFFFF);
  static const sub      = Color(0xFFB3B3B3);
}

// ── AppShell ─────────────────────────────────────────────────
class AppShell extends StatefulWidget {
  final int initialIndex;
  const AppShell({super.key, this.initialIndex = 0});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late int _index;

  // Tabs: Home | Search | Library | Premium | Profile
  static const _tabs = [
    _TabMeta(icon: Icons.home_outlined,              activeIcon: Icons.home,             label: 'Home'),
    _TabMeta(icon: Icons.search_outlined,            activeIcon: Icons.search,           label: 'Search'),
    _TabMeta(icon: Icons.library_music_outlined,     activeIcon: Icons.library_music,    label: 'Library'),
    _TabMeta(icon: Icons.workspace_premium_outlined, activeIcon: Icons.workspace_premium,label: 'Premium'),
    _TabMeta(icon: Icons.person_outline,             activeIcon: Icons.person,           label: 'Profile'),
  ];

  // Keep screen widgets alive using IndexedStack
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
    _screens = const [
      DashboardHomeTab(),   // 0 — Home
      SearchScreen(),       // 1 — Search
      LibraryScreen(),      // 2 — Library
      PremiumTab(),         // 3 — Premium
      ProfileScreen(),      // 4 — Profile
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      // ── App bar ─────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: _C.bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 14,
        title: _REdiifyLogo(),
        actions: [
          // Notifications
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: _C.text, size: 24),
            tooltip: 'Notifications',
            onPressed: () => Navigator.pushNamed(context, '/notifications'),
          ),
          // Settings
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: _C.sub, size: 22),
            tooltip: 'Settings',
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
          const SizedBox(width: 4),
        ],
      ),

      // ── Screen body ──────────────────────────────────────
      body: IndexedStack(
        index: _index,
        children: _screens,
      ),

      // ── Mini player sits above bottom nav ────────────────
      bottomSheet: const _MiniPlayer(),

      // ── Bottom navigation bar ─────────────────────────────
      bottomNavigationBar: _BottomNav(
        currentIndex: _index,
        tabs: _tabs,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}

// ── REdiify Logo widget ───────────────────────────────────────
class _REdiifyLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // App icon — dark circle with R + red dot
        Container(
          width: 34, height: 34,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF1A1A1A),
            border: Border.all(color: _C.red.withOpacity(0.6), width: 1.5),
            boxShadow: [
              BoxShadow(color: _C.red.withOpacity(0.25), blurRadius: 8),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Soundwave arcs behind the R
              CustomPaint(painter: _SoundArcPainter(), size: const Size(28, 28)),
              // Bold R letterform
              const Text(
                'R',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
              // Red accent dot bottom-right
              Positioned(
                right: 4, bottom: 4,
                child: Container(
                  width: 6, height: 6,
                  decoration: const BoxDecoration(
                    color: _C.red, shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        RichText(
          text: const TextSpan(children: [
            TextSpan(
              text: 'RE',
              style: TextStyle(color: _C.red, fontSize: 19, fontWeight: FontWeight.w900),
            ),
            TextSpan(
              text: 'diify',
              style: TextStyle(color: _C.text, fontSize: 19, fontWeight: FontWeight.w900),
            ),
          ]),
        ),
      ],
    );
  }
}

// ── Sound arc painter for app icon ───────────────────────────
class _SoundArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _C.red.withOpacity(0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final cx = size.width / 2;
    final cy = size.height / 2;

    // Three arcs emanating from centre-left
    for (final r in [6.0, 9.0, 12.0]) {
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx - 2, cy), radius: r),
        -0.8, 1.6,
        false,
        paint..color = _C.red.withOpacity(0.5 - r * 0.02),
      );
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── Bottom nav bar ────────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final List<_TabMeta> tabs;
  final ValueChanged<int> onTap;

  const _BottomNav({
    required this.currentIndex,
    required this.tabs,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // Extra height so mini-player doesn't overlap labels
      padding: const EdgeInsets.only(bottom: 8),
      decoration: const BoxDecoration(
        color: _C.surface,
        border: Border(top: BorderSide(color: Color(0xFF282828), width: 1)),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor:    _C.red,
        unselectedItemColor:  _C.muted,
        selectedLabelStyle:   const TextStyle(fontWeight: FontWeight.w700, fontSize: 10),
        unselectedLabelStyle: const TextStyle(fontSize: 10),
        type: BottomNavigationBarType.fixed,
        items: tabs.map((t) {
          final isSelected = tabs.indexOf(t) == currentIndex;
          // Premium tab gets a special crown badge
          if (t.label == 'Premium') {
            return BottomNavigationBarItem(
              label: t.label,
              icon: _PremiumNavIcon(active: isSelected, active_: false),
              activeIcon: _PremiumNavIcon(active: true, active_: true),
            );
          }
          return BottomNavigationBarItem(
            label: t.label,
            icon: Icon(t.icon),
            activeIcon: Icon(t.activeIcon),
          );
        }).toList(),
      ),
    );
  }
}

// ── Premium nav icon with crown badge ────────────────────────
class _PremiumNavIcon extends StatelessWidget {
  final bool active;
  final bool active_;
  const _PremiumNavIcon({required this.active, required this.active_});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(
          active ? Icons.workspace_premium : Icons.workspace_premium_outlined,
          color: active ? _C.red : _C.muted,
        ),
        if (active)
          Positioned(
            top: -4, right: -4,
            child: Container(
              width: 8, height: 8,
              decoration: const BoxDecoration(
                color: Color(0xFFFFD700), // gold
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }
}

class _TabMeta {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _TabMeta({required this.icon, required this.activeIcon, required this.label});
}

// ── Mini player (wired to MusicService) ──────────────────────
class _MiniPlayer extends StatelessWidget {
  const _MiniPlayer();

  @override
  Widget build(BuildContext context) {
    final music = context.watch<MusicService>();
    final song  = music.currentSong;
    if (song == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/nowplaying'),
      child: Container(
        height: 64,
        margin: const EdgeInsets.fromLTRB(8, 0, 8, 4),
        decoration: BoxDecoration(
          color: const Color(0xFF282828),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 16,
                offset: const Offset(0, -4)),
          ],
        ),
        child: Column(children: [
          // Progress bar
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            child: LinearProgressIndicator(
              value: music.progress,
              backgroundColor: _C.muted,
              valueColor: const AlwaysStoppedAnimation<Color>(_C.red),
              minHeight: 2,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(children: [
                // Album art placeholder
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: song.themeColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(Icons.music_note, color: song.themeColor, size: 22),
                ),
                const SizedBox(width: 10),
                // Title + artist
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(song.title,
                          style: const TextStyle(
                              color: _C.text, fontSize: 13, fontWeight: FontWeight.w700),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text(song.artist,
                          style: const TextStyle(color: _C.sub, fontSize: 12),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                // Controls
                IconButton(
                  icon: const Icon(
                    Icons.favorite_border,
                    color: _C.sub, size: 22,
                  ),
                  onPressed: () => music.toggleLike(),
                ),
                IconButton(
                  icon: Icon(
                    music.isPlaying ? Icons.pause : Icons.play_arrow,
                    color: _C.text, size: 30,
                  ),
                  onPressed: () => music.togglePlayPause(),
                ),
                IconButton(
                  icon: const Icon(Icons.skip_next, color: _C.text, size: 26),
                  onPressed: () => music.playNext(),
                ),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}