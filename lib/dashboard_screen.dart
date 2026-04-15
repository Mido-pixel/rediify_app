import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

// ── Colors ───────────────────────────────────────────────────
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

// ── Dashboard ────────────────────────────────────────────────
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const _HomeTab(),
    const _LibraryTab(),
    const _StatsTab(),
    const _PremiumTab(),
  ];

  void _onTabTapped(int index) {
    if (index == 4) {
      Navigator.pushNamed(context, '/settings');
      return;
    }
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RColors.bg,
      extendBody: true,

      // ── TOP APP BAR ────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: RColors.bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 12,

        // Left: Logo + App name
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RColors.gradRed,
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/REdiify.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(
                      Icons.music_note, color: Colors.white, size: 18),
                ),
              ),
            ),
            const SizedBox(width: 8),
            RichText(
              text: const TextSpan(
                children: [
                  TextSpan(text: 'RE', style: TextStyle(color: RColors.red,   fontSize: 18, fontWeight: FontWeight.w900)),
                  TextSpan(text: 'diify', style: TextStyle(color: RColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w900)),
                ],
              ),
            ),
          ],
        ),

        // Right: Top nav icons
        actions: [
          // Home
          _topNavBtn(Icons.home, 'Home', () => setState(() => _currentIndex = 0), active: _currentIndex == 0),
          // My Music
          _topNavBtn(Icons.library_music, 'Music', () => setState(() => _currentIndex = 1), active: _currentIndex == 1),
          // Playlists
          _topNavBtn(Icons.queue_music, 'Playlists', () => setState(() => _currentIndex = 1), active: false),
          // Settings
          _topNavBtn(Icons.settings, 'Settings', () => Navigator.pushNamed(context, '/settings'), active: false),
          // Rate
          _topNavBtn(Icons.star_rate, 'Rate', _showRateDialog, active: false),
          // Profile avatar
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/profile'),
            child: Container(
              margin: const EdgeInsets.only(right: 12, left: 2),
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: RColors.elevated,
                border: Border.all(color: RColors.red, width: 1.5),
              ),
              child: const Icon(Icons.person, color: RColors.textSecondary, size: 18),
            ),
          ),
        ],
      ),

      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),

      bottomSheet: const _MiniPlayer(),

      // ── BOTTOM NAV ─────────────────────────────────────────
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: RColors.surface,
          border: const Border(top: BorderSide(color: Color(0xFF282828), width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor:   RColors.red,
          unselectedItemColor: RColors.textMuted,
          selectedLabelStyle:   const TextStyle(fontWeight: FontWeight.w700, fontSize: 10),
          unselectedLabelStyle: const TextStyle(fontSize: 10),
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined),           activeIcon: Icon(Icons.home),           label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.library_music_outlined),  activeIcon: Icon(Icons.library_music),  label: 'Library'),
            BottomNavigationBarItem(icon: Icon(Icons.bar_chart_outlined),      activeIcon: Icon(Icons.bar_chart),      label: 'Stats'),
            BottomNavigationBarItem(icon: Icon(Icons.workspace_premium_outlined), activeIcon: Icon(Icons.workspace_premium), label: 'Premium'),
            BottomNavigationBarItem(icon: Icon(Icons.settings_outlined),       activeIcon: Icon(Icons.settings),       label: 'Settings'),
          ],
        ),
      ),
    );
  }

  // Top nav icon button with tooltip
  Widget _topNavBtn(IconData icon, String tooltip, VoidCallback onTap, {bool active = false}) {
    return Tooltip(
      message: tooltip,
      child: IconButton(
        icon: Icon(icon,
            color: active ? RColors.red : RColors.textSecondary,
            size: 22),
        onPressed: onTap,
      ),
    );
  }

  // Rate App Dialog
  void _showRateDialog() {
    int _stars = 0;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          backgroundColor: RColors.elevated,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Rate REdiify', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Enjoying the app? Let us know!',
                  style: TextStyle(color: RColors.textSecondary, fontSize: 13)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) => GestureDetector(
                  onTap: () => setS(() => _stars = i + 1),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      i < _stars ? Icons.star : Icons.star_border,
                      color: i < _stars ? Colors.amber : RColors.textMuted,
                      size: 36,
                    ),
                  ),
                )),
              ),
              const SizedBox(height: 12),
              Text(
                _stars == 0 ? 'Tap a star' :
                _stars == 1 ? 'Poor 😞' :
                _stars == 2 ? 'Fair 😐' :
                _stars == 3 ? 'Good 🙂' :
                _stars == 4 ? 'Great 😊' : 'Excellent! 🤩',
                style: TextStyle(
                  color: _stars > 3 ? RColors.green : RColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Later', style: TextStyle(color: RColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: _stars == 0 ? null : () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Thanks for $_stars stars! 🎉'),
                  backgroundColor: RColors.green,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: RColors.red,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text('Submit', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
// 🏠 HOME TAB
// ════════════════════════════════════════════════════════════
class _HomeTab extends StatelessWidget {
  const _HomeTab();

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning ☀️';
    if (h < 17) return 'Good afternoon 🎵';
    return 'Good evening 🌙';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 160),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGreetingSection(context),
          const SizedBox(height: 20),

          // ── Last Session ────────────────────────────────
          _buildLastSession(context),
          const SizedBox(height: 20),

          _buildFeaturedBanner(context),
          const SizedBox(height: 24),

          _buildSectionHeader('Recently played'),
          const SizedBox(height: 12),
          _buildRecentRow(context),
          const SizedBox(height: 24),

          _buildSectionHeader('Made for you'),
          const SizedBox(height: 12),
          _buildMixRow(context),
          const SizedBox(height: 24),

          _buildSectionHeader('Trending now'),
          const SizedBox(height: 4),
          _buildTrendingList(context),
          const SizedBox(height: 24),

          _buildSectionHeader('New releases'),
          const SizedBox(height: 12),
          _buildNewReleasesRow(context),
        ],
      ),
    );
  }

  // ── Last Session ──────────────────────────────────────────
  Widget _buildLastSession(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: RColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: RColors.red.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.history, color: RColors.red, size: 18),
              const SizedBox(width: 6),
              const Text('Last Session',
                  style: TextStyle(color: RColors.textPrimary,
                      fontSize: 14, fontWeight: FontWeight.w700)),
              const Spacer(),
              Text('2h 34m listened',
                  style: TextStyle(color: RColors.textMuted, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              // Last played song
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: RColors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.music_note, color: RColors.red, size: 22),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Blinding Lights',
                        style: TextStyle(color: RColors.textPrimary,
                            fontSize: 13, fontWeight: FontWeight.w600),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text('The Weeknd • Stopped at 2:14',
                        style: TextStyle(color: RColors.textSecondary, fontSize: 11)),
                  ],
                ),
              ),
              // Resume button
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/nowplaying'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: RColors.red,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('Resume',
                      style: TextStyle(color: Colors.white,
                          fontSize: 12, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGreetingSection(BuildContext context) {
    final items = [
      ('Liked Songs', Icons.favorite,       RColors.red),
      ('Top Hits',    Icons.trending_up,    Color(0xFF1565C0)),
      ('Workout',     Icons.fitness_center, Color(0xFF6A1B9A)),
      ('Chill Mix',   Icons.waves,          Color(0xFF00695C)),
      ('Hip Hop',     Icons.album,          Color(0xFF4E342E)),
      ('Party',       Icons.celebration,    Color(0xFF37474F)),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
            mainAxisSpacing: 8, childAspectRatio: 4,
          ),
          itemCount: items.length,
          itemBuilder: (_, i) {
            final item = items[i];
            return GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/nowplaying'),
              child: Container(
                decoration: BoxDecoration(
                  color: RColors.elevated,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
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
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFeaturedBanner(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/nowplaying'),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        height: 190,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            colors: [Color(0xFFE8173A), Color(0xFF7B0D1E), Color(0xFF1A1A1A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            Positioned(right: -10, top: -10,
              child: Icon(Icons.music_note, size: 160,
                  color: Colors.white.withOpacity(0.05))),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: RColors.red,
                        borderRadius: BorderRadius.circular(4)),
                    child: const Text('FEATURED',
                        style: TextStyle(color: Colors.white, fontSize: 10,
                            fontWeight: FontWeight.w800, letterSpacing: 1.5)),
                  ),
                  const SizedBox(height: 8),
                  const Text("Today's Top Hits",
                      style: TextStyle(color: Colors.white, fontSize: 22,
                          fontWeight: FontWeight.w900)),
                  const Text('The hottest tracks right now',
                      style: TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        width: 40, height: 40,
                        decoration: const BoxDecoration(
                            color: Colors.white, shape: BoxShape.circle),
                        child: const Icon(Icons.play_arrow, color: Colors.black, size: 24),
                      ),
                      const SizedBox(width: 14),
                      const Icon(Icons.shuffle,      color: Colors.white70, size: 20),
                      const SizedBox(width: 14),
                      const Icon(Icons.favorite_border, color: Colors.white70, size: 20),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(title,
          style: const TextStyle(color: RColors.textPrimary,
              fontSize: 18, fontWeight: FontWeight.w900)),
    );
  }

  Widget _buildRecentRow(BuildContext context) {
    final items = [
      ('Daily Mix 1', Icons.queue_music,   Color(0xFF1DB954)),
      ('Afrobeats',   Icons.music_note,    Color(0xFFE8173A)),
      ('Rap Caviar',  Icons.album,         Color(0xFF1565C0)),
      ('R&B Only',    Icons.headphones,    Color(0xFF6A1B9A)),
      ('Rock Hits',   Icons.electric_bolt, Color(0xFF37474F)),
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
              width: 108, margin: const EdgeInsets.only(right: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMixRow(BuildContext context) {
    final mixes = [
      ('Daily Mix 1',      'Based on your taste', Color(0xFF303F9F)),
      ('Discover Weekly',  'New music for you',   Color(0xFF1B5E20)),
      ('Release Radar',    'Fresh releases',       Color(0xFFB71C1C)),
      ('Time Capsule',     'Old favorites',        Color(0xFF4A148C)),
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
              width: 148, margin: const EdgeInsets.only(right: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 148, width: 148,
                    decoration: BoxDecoration(
                      color: mix.$3,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [BoxShadow(
                          color: (mix.$3).withOpacity(0.4),
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
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTrendingList(BuildContext context) {
    final colors = [RColors.red, Color(0xFF1DB954), Color(0xFF1565C0),
                    Color(0xFF6A1B9A), Color(0xFFE65100)];
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 5,
      itemBuilder: (_, i) => ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        leading: Stack(
          alignment: Alignment.center,
          children: [
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
          ],
        ),
        title: Text('Song Title ${i + 1}',
            style: const TextStyle(color: RColors.textPrimary,
                fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Text('Artist ${i + 1} • ${3+i}:${(20+i*7).toString().padLeft(2,'0')}',
            style: const TextStyle(color: RColors.textSecondary, fontSize: 12)),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          if (i == 0) Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
                color: RColors.redGlow, borderRadius: BorderRadius.circular(4)),
            child: const Text('🔥 HOT',
                style: TextStyle(color: RColors.red, fontSize: 10, fontWeight: FontWeight.w800)),
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
      ('Album Name',  'Artist 1', Color(0xFFE8173A)),
      ('Single Drop', 'Artist 2', Color(0xFF1DB954)),
      ('EP Title',    'Artist 3', Color(0xFF1565C0)),
      ('Mixtape',     'Artist 4', Color(0xFF6A1B9A)),
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
              width: 128, margin: const EdgeInsets.only(right: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 128, width: 128,
                    decoration: BoxDecoration(
                        color: r.$3, borderRadius: BorderRadius.circular(6)),
                    child: Center(child: Icon(Icons.album,
                        color: Colors.white.withOpacity(0.5), size: 48)),
                  ),
                  const SizedBox(height: 6),
                  Text(r.$1, style: const TextStyle(color: RColors.textPrimary,
                      fontSize: 13, fontWeight: FontWeight.w700),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(r.$2, style: const TextStyle(
                      color: RColors.textSecondary, fontSize: 11),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
// 📚 LIBRARY TAB
// ════════════════════════════════════════════════════════════
class _LibraryTab extends StatefulWidget {
  const _LibraryTab();
  @override State<_LibraryTab> createState() => _LibraryTabState();
}

class _LibraryTabState extends State<_LibraryTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _tabs = ['Playlists', 'Albums', 'Artists', 'Downloads'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() { _tabController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: RColors.bg,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            indicator: BoxDecoration(
                color: RColors.red, borderRadius: BorderRadius.circular(20)),
            labelColor: Colors.white,
            unselectedLabelColor: RColors.textSecondary,
            labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            dividerColor: Colors.transparent,
            tabs: _tabs.map((t) => Tab(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                child: Text(t),
              ),
            )).toList(),
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [_buildPlaylists(), _buildAlbums(), _buildArtists(), _buildDownloads()],
          ),
        ),
      ],
    );
  }

  Widget _buildPlaylists() {
    final playlists = [
      ('Workout Bangers', '18 songs', Color(0xFF1565C0)),
      ('Chill Vibes',     '34 songs', Color(0xFF1B5E20)),
      ('Party Mix',       '27 songs', Color(0xFF6A1B9A)),
      ('Afrobeats 🔥',    '55 songs', Color(0xFFE65100)),
      ('Late Night Drive','12 songs', Color(0xFF37474F)),
    ];
    return Stack(children: [
      ListView(
        padding: const EdgeInsets.only(bottom: 160),
        children: [
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/nowplaying'),
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFFE8173A), Color(0xFF4A0010)],
                    begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(children: [
                Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.favorite, color: Colors.white, size: 30),
                ),
                const SizedBox(width: 14),
                const Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Liked Songs', style: TextStyle(color: Colors.white,
                        fontSize: 16, fontWeight: FontWeight.w800)),
                    Text('142 songs', style: TextStyle(color: Colors.white70, fontSize: 13)),
                  ],
                )),
                Container(
                  width: 40, height: 40,
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: const Icon(Icons.play_arrow, color: Colors.black, size: 24),
                ),
              ]),
            ),
          ),
          ...playlists.map((p) => ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                  color: p.$3, borderRadius: BorderRadius.circular(4)),
              child: const Icon(Icons.library_music, color: Colors.white, size: 26),
            ),
            title: Text(p.$1, style: const TextStyle(
                color: RColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
            subtitle: Text(p.$2, style: const TextStyle(
                color: RColors.textSecondary, fontSize: 12)),
            trailing: const Icon(Icons.more_vert, color: RColors.textMuted, size: 20),
            onTap: () => Navigator.pushNamed(context, '/nowplaying'),
          )),
        ],
      ),
      Positioned(
        bottom: 100, right: 16,
        child: FloatingActionButton(
          onPressed: () => _showCreateDialog(context),
          backgroundColor: RColors.red,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    ]);
  }

  Widget _buildAlbums() {
    final albums = [
      ('After Hours',      'The Weeknd', Color(0xFFB71C1C)),
      ('Renaissance',      'Beyoncé',    Color(0xFF4A148C)),
      ('Certified Lover',  'Drake',      Color(0xFF212121)),
      ('SOS',              'SZA',        Color(0xFF1A237E)),
      ('Un Verano Sin Ti', 'Bad Bunny',  Color(0xFF1B5E20)),
      ('Mr. Morale',       'Kendrick',   Color(0xFF4E342E)),
    ];
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 160),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, crossAxisSpacing: 14,
          mainAxisSpacing: 20, childAspectRatio: 0.78),
      itemCount: albums.length,
      itemBuilder: (_, i) {
        final a = albums[i];
        return GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/nowplaying'),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              height: 155,
              decoration: BoxDecoration(
                color: a.$3, borderRadius: BorderRadius.circular(6),
                boxShadow: [BoxShadow(color: (a.$3).withOpacity(0.4),
                    blurRadius: 14, offset: const Offset(0, 6))],
              ),
              child: Center(child: Icon(Icons.album,
                  color: Colors.white.withOpacity(0.4), size: 60)),
            ),
            const SizedBox(height: 8),
            Text(a.$1, style: const TextStyle(color: RColors.textPrimary,
                fontSize: 13, fontWeight: FontWeight.w700),
                maxLines: 1, overflow: TextOverflow.ellipsis),
            Text(a.$2, style: const TextStyle(
                color: RColors.textSecondary, fontSize: 12),
                maxLines: 1, overflow: TextOverflow.ellipsis),
          ]),
        );
      },
    );
  }

  Widget _buildArtists() {
    final artists = [
      ('The Weeknd', Color(0xFFB71C1C)), ('Drake',     Color(0xFF212121)),
      ('Beyoncé',    Color(0xFF4A148C)), ('SZA',        Color(0xFF1A237E)),
      ('Bad Bunny',  Color(0xFF1B5E20)), ('Kendrick',   Color(0xFF4E342E)),
      ('Taylor S.',  Color(0xFF880E4F)), ('Burna Boy',  Color(0xFFE65100)),
      ('Rema',       Color(0xFF006064)),
    ];
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 160),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, crossAxisSpacing: 12, mainAxisSpacing: 20),
      itemCount: artists.length,
      itemBuilder: (_, i) {
        final a = artists[i];
        return Column(children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle, color: a.$2,
              boxShadow: [BoxShadow(color: (a.$2).withOpacity(0.5),
                  blurRadius: 12, offset: const Offset(0, 4))],
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 36),
          ),
          const SizedBox(height: 8),
          Text(a.$1, style: const TextStyle(color: RColors.textPrimary,
              fontSize: 12, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center, maxLines: 1,
              overflow: TextOverflow.ellipsis),
          const Text('Artist', style: TextStyle(color: RColors.textMuted, fontSize: 11)),
        ]);
      },
    );
  }

  Widget _buildDownloads() {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 160),
      itemCount: 6,
      itemBuilder: (_, i) => ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 52, height: 52,
          decoration: BoxDecoration(
              color: RColors.elevated, borderRadius: BorderRadius.circular(6)),
          child: const Icon(Icons.download_done, color: RColors.green, size: 24),
        ),
        title: Text('Downloaded Song ${i + 1}',
            style: const TextStyle(color: RColors.textPrimary,
                fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Text('Artist ${i+1}  •  3:${(30+i*5).toString().padLeft(2,'0')}',
            style: const TextStyle(color: RColors.textSecondary, fontSize: 12)),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: RColors.textMuted, size: 20),
          onPressed: () {},
        ),
        onTap: () => Navigator.pushNamed(context, '/nowplaying'),
      ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: RColors.elevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Create playlist',
            style: TextStyle(color: RColors.textPrimary, fontWeight: FontWeight.w800)),
        content: TextField(
          controller: ctrl, autofocus: true,
          style: const TextStyle(color: RColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'My playlist #1',
            hintStyle: const TextStyle(color: RColors.textMuted),
            filled: true, fillColor: RColors.highlight,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: RColors.textSecondary))),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(backgroundColor: RColors.red,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
            child: const Text('Create', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
// 📊 STATS TAB
// ════════════════════════════════════════════════════════════
class _StatsTab extends StatelessWidget {
  const _StatsTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 160),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Your Stats', style: TextStyle(
              color: RColors.textPrimary, fontSize: 22, fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          const Text('This month', style: TextStyle(color: RColors.textSecondary, fontSize: 13)),
          const SizedBox(height: 20),

          // ── Big stat cards ────────────────────────────────
          Row(children: [
            Expanded(child: _statCard('Minutes Listened', '2,847', Icons.timer, RColors.red)),
            const SizedBox(width: 12),
            Expanded(child: _statCard('Songs Played', '184', Icons.music_note, Color(0xFF1DB954))),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _statCard('Artists Discovered', '23', Icons.person_search, Color(0xFF1565C0))),
            const SizedBox(width: 12),
            Expanded(child: _statCard('Playlists Created', '5', Icons.playlist_add, Color(0xFF6A1B9A))),
          ]),

          const SizedBox(height: 28),

          // ── Top genres ───────────────────────────────────
          const Text('Top Genres', style: TextStyle(
              color: RColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 14),
          _genreBar('Afrobeats', 0.72, RColors.red),
          _genreBar('Hip Hop',   0.58, Color(0xFF1DB954)),
          _genreBar('R&B',       0.44, Color(0xFF1565C0)),
          _genreBar('Reggae',    0.28, Color(0xFF6A1B9A)),
          _genreBar('Pop',       0.20, Color(0xFFE65100)),

          const SizedBox(height: 28),

          // ── Top artists ──────────────────────────────────
          const Text('Top Artists This Month', style: TextStyle(
              color: RColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 14),
          ...[
            ('Wizkid',        '48 plays', Color(0xFFE65100)),
            ('The Weeknd',    '36 plays', Color(0xFFB71C1C)),
            ('Drake',         '29 plays', Color(0xFF212121)),
            ('Kendrick Lamar','22 plays', Color(0xFF4E342E)),
            ('Burna Boy',     '18 plays', Color(0xFF1B5E20)),
          ].asMap().entries.map((e) => _topArtistTile(e.key + 1, e.value.$1, e.value.$2, e.value.$3)),

          const SizedBox(height: 28),

          // ── Listening streak ─────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xFFE8173A), Color(0xFF7B0D1E)]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(children: [
              const Icon(Icons.local_fire_department, color: Colors.white, size: 40),
              const SizedBox(width: 14),
              const Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('7 Day Streak! 🔥', style: TextStyle(
                      color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                  Text('You\'ve listened every day this week!',
                      style: TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              )),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: RColors.surface, borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 10),
        Text(value, style: TextStyle(color: color, fontSize: 28,
            fontWeight: FontWeight.w900)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: RColors.textSecondary, fontSize: 12)),
      ]),
    );
  }

  Widget _genreBar(String genre, double value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(genre, style: const TextStyle(color: RColors.textPrimary,
              fontSize: 13, fontWeight: FontWeight.w600)),
          Text('${(value * 100).toInt()}%',
              style: const TextStyle(color: RColors.textSecondary, fontSize: 12)),
        ]),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value,
            backgroundColor: RColors.elevated,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
      ]),
    );
  }

  Widget _topArtistTile(int rank, String name, String plays, Color color) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
      leading: Row(mainAxisSize: MainAxisSize.min, children: [
        SizedBox(width: 24,
          child: Text('$rank', style: TextStyle(color: rank == 1 ? Colors.amber :
              RColors.textMuted, fontSize: 14, fontWeight: FontWeight.w700))),
        const SizedBox(width: 8),
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          child: const Icon(Icons.person, color: Colors.white, size: 22),
        ),
      ]),
      title: Text(name, style: const TextStyle(color: RColors.textPrimary,
          fontWeight: FontWeight.w600, fontSize: 14)),
      subtitle: Text(plays, style: const TextStyle(
          color: RColors.textSecondary, fontSize: 12)),
      trailing: rank == 1
          ? const Icon(Icons.emoji_events, color: Colors.amber, size: 22)
          : null,
    );
  }
}

// ════════════════════════════════════════════════════════════
// 👑 PREMIUM TAB
// ════════════════════════════════════════════════════════════
class _PremiumTab extends StatefulWidget {
  const _PremiumTab();
  @override State<_PremiumTab> createState() => _PremiumTabState();
}

class _PremiumTabState extends State<_PremiumTab> {
  int _selectedPlan = 1; // 0=Free, 1=Premium, 2=Family

  final _plans = [
    {
      'name': 'Free',
      'price': 'KSh 0/mo',
      'color': Color(0xFF535353),
      'features': ['Ads between songs', 'Shuffle only', 'Low quality audio',
                   'No offline downloads', 'Basic stats'],
    },
    {
      'name': 'Premium',
      'price': 'KSh 399/mo',
      'color': RColors.red,
      'features': ['No ads', 'Play any song', 'High quality audio',
                   'Offline downloads', 'Full stats & insights',
                   'YouTube search', 'Lyrics view'],
    },
    {
      'name': 'Family',
      'price': 'KSh 599/mo',
      'color': Color(0xFF1565C0),
      'features': ['Everything in Premium', 'Up to 6 accounts',
                   'Family Mix playlist', 'Parental controls',
                   'Individual recommendations'],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 160),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xFFE8173A), Color(0xFF7B0D1E)]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Icon(Icons.workspace_premium, color: Colors.white, size: 36),
              const SizedBox(height: 10),
              const Text('Go Premium', style: TextStyle(
                  color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900)),
              const Text('Unlock the full REdiify experience',
                  style: TextStyle(color: Colors.white70, fontSize: 14)),
            ]),
          ),

          const SizedBox(height: 24),
          const Text('Choose your plan', style: TextStyle(
              color: RColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 14),

          // Plan cards
          ..._plans.asMap().entries.map((e) {
            final i    = e.key;
            final plan = e.value;
            final isSelected = _selectedPlan == i;
            final color = plan['color'] as Color;
            final features = plan['features'] as List<String>;

            return GestureDetector(
              onTap: () => setState(() => _selectedPlan = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected ? color.withOpacity(0.1) : RColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? color : RColors.elevated,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Text(plan['name'] as String, style: TextStyle(
                        color: isSelected ? color : RColors.textPrimary,
                        fontSize: 18, fontWeight: FontWeight.w800)),
                    const Spacer(),
                    Text(plan['price'] as String, style: TextStyle(
                        color: isSelected ? color : RColors.textSecondary,
                        fontSize: 15, fontWeight: FontWeight.w700)),
                    const SizedBox(width: 8),
                    if (isSelected)
                      Icon(Icons.check_circle, color: color, size: 22)
                    else
                      Icon(Icons.radio_button_unchecked, color: RColors.textMuted, size: 22),
                  ]),
                  const SizedBox(height: 12),
                  ...features.map((f) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(children: [
                      Icon(Icons.check, color: isSelected ? color : RColors.textMuted, size: 16),
                      const SizedBox(width: 8),
                      Text(f, style: TextStyle(
                          color: isSelected ? RColors.textPrimary : RColors.textSecondary,
                          fontSize: 13)),
                    ]),
                  )),
                ]),
              ),
            );
          }),

          const SizedBox(height: 20),

          // Subscribe button
          SizedBox(
            width: double.infinity, height: 52,
            child: ElevatedButton(
              onPressed: _selectedPlan == 0 ? null : () => _showSubscribeDialog(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: (_plans[_selectedPlan]['color'] as Color),
                disabledBackgroundColor: RColors.textMuted,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: Text(
                _selectedPlan == 0
                    ? 'Currently on Free'
                    : 'Subscribe to ${_plans[_selectedPlan]['name']}',
                style: const TextStyle(color: Colors.white,
                    fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ),

          const SizedBox(height: 12),
          const Center(
            child: Text('Cancel anytime. No commitments.',
                style: TextStyle(color: RColors.textMuted, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  void _showSubscribeDialog(BuildContext context) {
    final plan = _plans[_selectedPlan];
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: RColors.elevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Subscribe to ${plan['name']}',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('You will be charged ${plan['price']} starting today.',
              style: const TextStyle(color: RColors.textSecondary)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: RColors.highlight, borderRadius: BorderRadius.circular(10)),
            child: const Row(children: [
              Icon(Icons.lock, color: RColors.green, size: 18),
              SizedBox(width: 8),
              Expanded(child: Text('Secure payment • Cancel anytime',
                  style: TextStyle(color: RColors.textSecondary, fontSize: 12))),
            ]),
          ),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: RColors.textSecondary))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Welcome to ${plan['name']}! 🎉'),
                backgroundColor: RColors.green,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: plan['color'] as Color,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text('Confirm', style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
// 🎵 MINI PLAYER
// ════════════════════════════════════════════════════════════
class _MiniPlayer extends StatefulWidget {
  const _MiniPlayer();
  @override State<_MiniPlayer> createState() => _MiniPlayerState();
}

class _MiniPlayerState extends State<_MiniPlayer> {
  bool _isPlaying = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/nowplaying'),
      child: Container(
        height: 64,
        margin: const EdgeInsets.fromLTRB(8, 0, 8, 4),
        decoration: BoxDecoration(
          color: const Color(0xFF282828),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5),
              blurRadius: 16, offset: const Offset(0, -4))],
        ),
        child: Column(children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            child: LinearProgressIndicator(
              value: 0.35,
              backgroundColor: RColors.textMuted,
              valueColor: const AlwaysStoppedAnimation<Color>(RColors.red),
              minHeight: 2,
            ),
          ),
          Expanded(child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                    color: RColors.red.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4)),
                child: const Icon(Icons.music_note, color: RColors.red, size: 22),
              ),
              const SizedBox(width: 10),
              const Expanded(child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Now Playing', style: TextStyle(color: RColors.textPrimary,
                      fontSize: 13, fontWeight: FontWeight.w700),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text('Artist Name', style: TextStyle(
                      color: RColors.textSecondary, fontSize: 12),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              )),
              IconButton(
                icon: const Icon(Icons.favorite_border,
                    color: RColors.textSecondary, size: 22),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow,
                    color: RColors.textPrimary, size: 30),
                onPressed: () => setState(() => _isPlaying = !_isPlaying),
              ),
              IconButton(
                icon: const Icon(Icons.skip_next, color: RColors.textPrimary, size: 26),
                onPressed: () {},
              ),
            ]),
          )),
        ]),
      ),
    );
  }
}