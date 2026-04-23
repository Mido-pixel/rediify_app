// app_shell.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/music_service.dart';

import 'dashboard_screen.dart'  show DashboardHomeTab;
import 'library_screen.dart'    show LibraryBody;      // ✅ LibraryBody, NOT LibraryScreen
import 'search_screen.dart'     show SearchScreen;
import 'premium_tab.dart'       show PremiumTab;
import 'profile_screen.dart'    show ProfileScreen;

class _C {
  static const bg      = Color(0xFF121212);
  static const surface = Color(0xFF1A1A1A);
  static const red     = Color(0xFFE8173A);
  static const muted   = Color(0xFF535353);
  static const text    = Color(0xFFFFFFFF);
  static const sub     = Color(0xFFB3B3B3);
}

class AppShell extends StatefulWidget {
  final int initialIndex;
  const AppShell({super.key, this.initialIndex = 0});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late int _index;

  static const _tabs = [
    _TabMeta(icon: Icons.home_outlined,              activeIcon: Icons.home,              label: 'Home'),
    _TabMeta(icon: Icons.search_outlined,            activeIcon: Icons.search,            label: 'Search'),
    _TabMeta(icon: Icons.library_music_outlined,     activeIcon: Icons.library_music,     label: 'Library'),
    _TabMeta(icon: Icons.workspace_premium_outlined, activeIcon: Icons.workspace_premium, label: 'Premium'),
    _TabMeta(icon: Icons.person_outline,             activeIcon: Icons.person,            label: 'Profile'),
  ];

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
    _screens = const [
      DashboardHomeTab(),   // 0 — Home
      SearchScreen(),       // 1 — Search
      LibraryBody(),        // 2 — Library ✅ no more infinite loop
      PremiumTab(),         // 3 — Premium
      ProfileScreen(),      // 4 — Profile
    ];
  }

  void _goNext() {
    if (_index < _tabs.length - 1) setState(() => _index++);
  }

  void _goPrev() {
    if (_index > 0) setState(() => _index--);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      appBar: AppBar(
        backgroundColor: _C.bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 14,
        title: _REdiifyLogo(),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: _C.text, size: 24),
            tooltip: 'Notifications',
            onPressed: () => Navigator.pushNamed(context, '/notifications'),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: _C.sub, size: 22),
            tooltip: 'Settings',
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: IndexedStack(index: _index, children: _screens),
      bottomSheet: const _MiniPlayer(),
      bottomNavigationBar: _BottomNav(
        currentIndex: _index,
        tabs: _tabs,
        onTap: (i) => setState(() => _index = i),
        onPrev: _index > 0 ? _goPrev : null,
        onNext: _index < _tabs.length - 1 ? _goNext : null,
      ),
    );
  }
}

// ── REdiify Logo ──────────────────────────────────────────────
class _REdiifyLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 34, height: 34,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF1A1A1A),
            border: Border.all(color: _C.red.withOpacity(0.6), width: 1.5),
            boxShadow: [BoxShadow(color: _C.red.withOpacity(0.25), blurRadius: 8)],
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/images/REdiify.png',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(painter: _SoundArcPainter(), size: const Size(28, 28)),
                  const Text('R', style: TextStyle(
                      color: Colors.white, fontSize: 15, fontWeight: FontWeight.w900)),
                  Positioned(
                    right: 4, bottom: 4,
                    child: Container(width: 6, height: 6,
                        decoration: const BoxDecoration(
                            color: _C.red, shape: BoxShape.circle)),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        RichText(text: const TextSpan(children: [
          TextSpan(text: 'RE',    style: TextStyle(color: _C.red,  fontSize: 19, fontWeight: FontWeight.w900)),
          TextSpan(text: 'diify', style: TextStyle(color: _C.text, fontSize: 19, fontWeight: FontWeight.w900)),
        ])),
      ],
    );
  }
}

class _SoundArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    final cx = size.width / 2;
    final cy = size.height / 2;
    for (final r in [6.0, 9.0, 12.0]) {
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx - 2, cy), radius: r),
        -0.8, 1.6, false,
        paint..color = _C.red.withOpacity(0.5 - r * 0.02),
      );
    }
  }
  @override
  bool shouldRepaint(_) => false;
}

// ── Bottom nav with ‹ › arrows ────────────────────────────────
class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final List<_TabMeta> tabs;
  final ValueChanged<int> onTap;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;

  const _BottomNav({
    required this.currentIndex,
    required this.tabs,
    required this.onTap,
    this.onPrev,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: _C.surface,
        border: Border(top: BorderSide(color: Color(0xFF282828), width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(children: [
            // ◀ Prev arrow
            _NavArrow(icon: Icons.chevron_left, enabled: onPrev != null, onTap: onPrev),

            // Tab items
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: tabs.asMap().entries.map((e) {
                  final i      = e.key;
                  final tab    = e.value;
                  final active = i == currentIndex;
                  return GestureDetector(
                    onTap: () => onTap(i),
                    behavior: HitTestBehavior.opaque,
                    child: SizedBox(
                      width: 52,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          tab.label == 'Premium'
                              ? _PremiumNavIcon(active: active)
                              : Icon(
                                  active ? tab.activeIcon : tab.icon,
                                  color: active ? _C.red : _C.muted,
                                  size: 24,
                                ),
                          const SizedBox(height: 3),
                          Text(tab.label, style: TextStyle(
                              color: active ? _C.red : _C.muted,
                              fontSize: 10,
                              fontWeight: active
                                  ? FontWeight.w700 : FontWeight.normal)),
                          const SizedBox(height: 3),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: active ? 18 : 0,
                            height: 2,
                            decoration: BoxDecoration(
                              color: _C.red,
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            // ▶ Next arrow
            _NavArrow(icon: Icons.chevron_right, enabled: onNext != null, onTap: onNext),
          ]),
        ),
      ),
    );
  }
}

class _NavArrow extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback? onTap;
  const _NavArrow({required this.icon, required this.enabled, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 36,
        alignment: Alignment.center,
        child: Icon(icon,
            color: enabled ? _C.text : _C.muted.withOpacity(0.3),
            size: 26),
      ),
    );
  }
}

class _PremiumNavIcon extends StatelessWidget {
  final bool active;
  const _PremiumNavIcon({required this.active});

  @override
  Widget build(BuildContext context) {
    return Stack(clipBehavior: Clip.none, children: [
      Icon(active ? Icons.workspace_premium : Icons.workspace_premium_outlined,
          color: active ? _C.red : _C.muted, size: 24),
      if (active)
        Positioned(top: -4, right: -4,
          child: Container(width: 8, height: 8,
              decoration: const BoxDecoration(
                  color: Color(0xFFFFD700), shape: BoxShape.circle))),
    ]);
  }
}

class _TabMeta {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _TabMeta({required this.icon, required this.activeIcon, required this.label});
}

// ── Mini player ───────────────────────────────────────────────
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
          boxShadow: [BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 16, offset: const Offset(0, -4))],
        ),
        child: Column(children: [
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
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: song.themeColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(Icons.music_note, color: song.themeColor, size: 22),
                ),
                const SizedBox(width: 10),
                Expanded(child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(song.title,
                        style: const TextStyle(color: _C.text,
                            fontSize: 13, fontWeight: FontWeight.w700),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text(song.artist,
                        style: const TextStyle(color: _C.sub, fontSize: 12),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                )),
                IconButton(
                  icon: Icon(
                    song.isLiked ? Icons.favorite : Icons.favorite_border,
                    color: song.isLiked ? _C.red : _C.sub, size: 22,
                  ),
                  onPressed: () => music.toggleLike(),
                ),
                IconButton(
                  icon: Icon(music.isPlaying ? Icons.pause : Icons.play_arrow,
                      color: _C.text, size: 30),
                  onPressed: () => music.togglePlayPause(),
                ),
                IconButton(
                  icon: const Icon(Icons.skip_next, color: _C.text, size: 26),
                  onPressed: () => music.playNext(),
                ),
                const Icon(Icons.keyboard_arrow_up, color: _C.muted, size: 18),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}