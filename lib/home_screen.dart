import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/music_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void _onDrawerItemTapped(String route) {
    Navigator.pop(context);
    if (ModalRoute.of(context)?.settings.name != route) {
      Navigator.pushReplacementNamed(context, route);
    }
  }

  // ── Section wallpaper data ────────────────────────────────
  static const _sections = [
    {
      'title': '🔥 Top Hits',
      'subtitle': 'Biggest songs right now',
      'bg': 'https://upload.wikimedia.org/wikipedia/commons/thumb/e/ef/Billie_Eilish_%22Hit_Me_Hard_and_Soft%22_promotional_photo.png/440px-Billie_Eilish_%22Hit_Me_Hard_and_Soft%22_promotional_photo.png',
      'color': '0xFFE65100',
      'artists': [
        {'name': 'Billie Eilish', 'song': 'Birds of a Feather', 'img': 'https://upload.wikimedia.org/wikipedia/commons/thumb/e/ef/Billie_Eilish_%22Hit_Me_Hard_and_Soft%22_promotional_photo.png/440px-Billie_Eilish_%22Hit_Me_Hard_and_Soft%22_promotional_photo.png'},
        {'name': 'The Weeknd',    'song': 'Blinding Lights',    'img': 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a1/The_Weeknd_-_Openair_Frauenfeld_2023.jpg/440px-The_Weeknd_-_Openair_Frauenfeld_2023.jpg'},
        {'name': 'Drake',         'song': "God's Plan",         'img': 'https://upload.wikimedia.org/wikipedia/commons/thumb/2/28/Drake_July_2016.jpg/440px-Drake_July_2016.jpg'},
        {'name': 'Taylor Swift',  'song': 'Anti-Hero',          'img': 'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b5/191125_Taylor_Swift_at_the_2019_American_Music_Awards_%28cropped%29.png/440px-191125_Taylor_Swift_at_the_2019_American_Music_Awards_%28cropped%29.png'},
        {'name': 'Michael Jackson','song': 'Thriller',          'img': 'https://upload.wikimedia.org/wikipedia/commons/thumb/4/40/Michael_Jackson_in_1988.jpg/440px-Michael_Jackson_in_1988.jpg'},
      ],
    },
    {
      'title': '💪 Workout',
      'subtitle': 'Power through your session',
      'bg': 'https://upload.wikimedia.org/wikipedia/commons/thumb/3/3a/Eminem_-_Concert_for_Valor_in_Washington%2C_D.C._Nov._11%2C_2014_%2815536869370%29_%28cropped%29.jpg/440px-Eminem_-_Concert_for_Valor_in_Washington%2C_D.C._Nov._11%2C_2014_%2815536869370%29_%28cropped%29.jpg',
      'color': '0xFF1B5E20',
      'artists': [
        {'name': 'Eminem',         'song': 'Lose Yourself', 'img': 'https://upload.wikimedia.org/wikipedia/commons/thumb/3/3a/Eminem_-_Concert_for_Valor_in_Washington%2C_D.C._Nov._11%2C_2014_%2815536869370%29_%28cropped%29.jpg/440px-Eminem_-_Concert_for_Valor_in_Washington%2C_D.C._Nov._11%2C_2014_%2815536869370%29_%28cropped%29.jpg'},
        {'name': 'Kanye West',     'song': 'Stronger',      'img': 'https://upload.wikimedia.org/wikipedia/commons/thumb/1/11/Kanye_West_at_the_2009_Tribeca_Film_Festival.jpg/440px-Kanye_West_at_the_2009_Tribeca_Film_Festival.jpg'},
        {'name': 'Kendrick Lamar', 'song': 'HUMBLE.',        'img': 'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b5/Kendrick_Lamar_-_Openair_Frauenfeld_2023_-_Frauenfeld_-_2023-07-06_%281_of_1%29_%28cropped%29.jpg/440px-Kendrick_Lamar_-_Openair_Frauenfeld_2023_-_Frauenfeld_-_2023-07-06_%281_of_1%29_%28cropped%29.jpg'},
        {'name': 'Jay-Z',          'song': '99 Problems',   'img': 'https://upload.wikimedia.org/wikipedia/commons/thumb/f/f3/Jay-Z_-_Coachella_2010.jpg/440px-Jay-Z_-_Coachella_2010.jpg'},
      ],
    },
    {
      'title': '😌 Chill Music',
      'subtitle': 'Relax and unwind',
      'bg': 'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b4/Lana_Del_Rey_Lollapalooza_Chile_2018_%28cropped%29.jpg/440px-Lana_Del_Rey_Lollapalooza_Chile_2018_%28cropped%29.jpg',
      'color': '0xFF0D47A1',
      'artists': [
        {'name': 'Frank Ocean',  'song': 'Nights',              'img': 'https://upload.wikimedia.org/wikipedia/commons/thumb/7/73/Frank_Ocean_2012.jpg/440px-Frank_Ocean_2012.jpg'},
        {'name': 'SZA',          'song': 'Kill Bill',           'img': 'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2d/SZA_2018.jpg/440px-SZA_2018.jpg'},
        {'name': 'Lana Del Rey', 'song': 'Summertime Sadness',  'img': 'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b4/Lana_Del_Rey_Lollapalooza_Chile_2018_%28cropped%29.jpg/440px-Lana_Del_Rey_Lollapalooza_Chile_2018_%28cropped%29.jpg'},
        {'name': 'The Weeknd',   'song': 'Call Out My Name',    'img': 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a1/The_Weeknd_-_Openair_Frauenfeld_2023.jpg/440px-The_Weeknd_-_Openair_Frauenfeld_2023.jpg'},
      ],
    },
    {
      'title': '🎤 Hip Hop',
      'subtitle': 'The streets are talking',
      'bg': 'https://upload.wikimedia.org/wikipedia/commons/thumb/2/28/Drake_July_2016.jpg/440px-Drake_July_2016.jpg',
      'color': '0xFF4A148C',
      'artists': [
        {'name': 'Drake',       'song': 'Hotline Bling', 'img': 'https://upload.wikimedia.org/wikipedia/commons/thumb/2/28/Drake_July_2016.jpg/440px-Drake_July_2016.jpg'},
        {'name': 'Cardi B',     'song': 'WAP',           'img': 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a2/Cardi_B_2018.jpg/440px-Cardi_B_2018.jpg'},
        {'name': 'Travis Scott','song': 'SICKO MODE',    'img': 'https://upload.wikimedia.org/wikipedia/commons/thumb/7/7b/Travis_Scott_2018.jpg/440px-Travis_Scott_2018.jpg'},
        {'name': 'Nicki Minaj', 'song': 'Super Bass',    'img': 'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b3/Nicki_Minaj_2014.jpg/440px-Nicki_Minaj_2014.jpg'},
      ],
    },
    {
      'title': '🎉 Party',
      'subtitle': 'Turn it up loud',
      'bg': 'https://upload.wikimedia.org/wikipedia/commons/thumb/1/17/Beyonce_-_Black_Is_King_Still_%28cropped%29.png/440px-Beyonce_-_Black_Is_King_Still_%28cropped%29.png',
      'color': '0xFFB71C1C',
      'artists': [
        {'name': 'Dua Lipa',   'song': 'Levitating',    'img': 'https://upload.wikimedia.org/wikipedia/commons/thumb/f/f5/Dua_Lipa_2018_3.jpg/440px-Dua_Lipa_2018_3.jpg'},
        {'name': 'Bruno Mars', 'song': 'Uptown Funk',   'img': 'https://upload.wikimedia.org/wikipedia/commons/thumb/3/32/Bruno_Mars_2013.jpg/440px-Bruno_Mars_2013.jpg'},
        {'name': 'Beyoncé',    'song': 'Crazy in Love', 'img': 'https://upload.wikimedia.org/wikipedia/commons/thumb/1/17/Beyonce_-_Black_Is_King_Still_%28cropped%29.png/440px-Beyonce_-_Black_Is_King_Still_%28cropped%29.png'},
        {'name': 'Rihanna',    'song': 'We Found Love', 'img': 'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c2/Rihanna_-_Live_at_Barclay_Center_cropped.jpg/440px-Rihanna_-_Live_at_Barclay_Center_cropped.jpg'},
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    final music = context.watch<MusicService>();
    final liked = music.songs.where((s) => s.isLiked).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // ── Logo in AppBar ──────────────────────────────────
        title: Row(children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFFE8173A), Color(0xFF7B0020)],
              ),
              boxShadow: [BoxShadow(
                color: const Color(0xFFE8173A).withOpacity(0.4),
                blurRadius: 8, spreadRadius: 1,
              )],
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
          RichText(text: const TextSpan(children: [
            TextSpan(text: 'RE', style: TextStyle(
                color: Color(0xFFE8173A), fontSize: 20,
                fontWeight: FontWeight.w900, letterSpacing: 1)),
            TextSpan(text: 'diify', style: TextStyle(
                color: Colors.white, fontSize: 20,
                fontWeight: FontWeight.w900, letterSpacing: 1)),
          ])),
        ]),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () => Navigator.pushNamed(context, '/search'),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () => Navigator.pushNamed(context, '/notifications'),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
          ),
        ],
      ),

      drawer: Drawer(
        backgroundColor: const Color(0xFF1A1A1A),
        child: ListView(padding: EdgeInsets.zero, children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF0A0A0A)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 60, height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE8173A), Color(0xFF7B0020)],
                    ),
                    boxShadow: [BoxShadow(
                      color: const Color(0xFFE8173A).withOpacity(0.5),
                      blurRadius: 16, spreadRadius: 2,
                    )],
                  ),
                  child: ClipOval(
                    child: Image.asset('assets/images/REdiify.png',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.music_note, color: Colors.white, size: 30)),
                  ),
                ),
                const SizedBox(height: 10),
                RichText(text: const TextSpan(children: [
                  TextSpan(text: 'RE', style: TextStyle(
                      color: Color(0xFFE8173A), fontSize: 22,
                      fontWeight: FontWeight.w900)),
                  TextSpan(text: 'diify', style: TextStyle(
                      color: Colors.white, fontSize: 22,
                      fontWeight: FontWeight.w900)),
                ])),
              ],
            ),
          ),
          _drawerTile(Icons.dashboard,     'Dashboard', '/dashboard'),
          _drawerTile(Icons.library_music, 'Library',   '/library'),
          _drawerTile(Icons.queue_music,   'Playlists', '/playlists'),
          _drawerTile(Icons.person,        'Profile',   '/profile'),
          _drawerTile(Icons.settings,      'Settings',  '/settings'),
        ]),
      ),

      body: ListView(
        padding: const EdgeInsets.only(bottom: 120),
        children: [

          // ── Hero banner ──────────────────────────────────
          Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            height: 160,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                colors: [Color(0xFFE8173A), Color(0xFF7B0020)],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
            ),
            child: Stack(children: [
              // faint headphone watermark
              Positioned(right: -10, bottom: -10,
                child: Icon(Icons.headphones,
                    color: Colors.white.withOpacity(0.08), size: 160)),
              Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Good Evening 👋',
                        style: TextStyle(color: Colors.white70, fontSize: 13)),
                    const SizedBox(height: 6),
                    const Text('What are you\nlistening to?',
                        style: TextStyle(color: Colors.white,
                            fontSize: 24, fontWeight: FontWeight.w900,
                            height: 1.2)),
                    const SizedBox(height: 14),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/nowplaying'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Text('Play Now',
                            style: TextStyle(
                                color: Color(0xFFE8173A),
                                fontWeight: FontWeight.w800,
                                fontSize: 13)),
                      ),
                    ),
                  ],
                ),
              ),
            ]),
          ),

          // ── Liked Songs ──────────────────────────────────
          if (liked.isNotEmpty) ...[
            _sectionHeader('❤️ Liked Songs', null),
            SizedBox(
              height: 155,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: liked.length,
                itemBuilder: (_, i) {
                  final s = liked[i];
                  return GestureDetector(
                    onTap: () {
                      music.playSong(s);
                      Navigator.pushNamed(context, '/nowplaying');
                    },
                    child: Container(
                      width: 120,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: LinearGradient(
                          colors: [s.themeColor, s.themeColor.withOpacity(0.4)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Stack(children: [
                        Positioned.fill(child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Container(color: Colors.black45),
                        )),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.music_note, color: Colors.white70, size: 28),
                              const SizedBox(height: 8),
                              Text(s.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700)),
                              Text(s.artist,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      color: Colors.white60, fontSize: 10)),
                            ],
                          ),
                        ),
                      ]),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 28),
          ],

          // ── Wallpaper sections ────────────────────────────
          ..._sections.map((section) => _buildSection(section)),
        ],
      ),
    );
  }

  // ── Big wallpaper section card + artist row ───────────────
  Widget _buildSection(Map<String, dynamic> section) {
    final color = Color(int.parse(section['color'] as String));
    final artists = section['artists'] as List;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Big wallpaper banner ─────────────────────────
        Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
          height: 160,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: color.withOpacity(0.3),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Stack(children: [
              // Background image (first artist photo as wallpaper)
              Positioned.fill(
                child: Image.network(
                  section['bg'] as String,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(color: color),
                  loadingBuilder: (_, child, p) =>
                      p == null ? child : Container(color: color),
                ),
              ),
              // Dark gradient overlay so text is readable
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.65),
                        Colors.transparent,
                        Colors.black.withOpacity(0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),
              // Text overlay
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(section['title'] as String,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            shadows: [Shadow(
                                color: Colors.black87, blurRadius: 8)])),
                    const SizedBox(height: 4),
                    Text(section['subtitle'] as String,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 13,
                            shadows: [Shadow(
                                color: Colors.black87, blurRadius: 6)])),
                  ],
                ),
              ),
            ]),
          ),
        ),

        // ── Artist cards row ─────────────────────────────
        SizedBox(
          height: 165,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: artists.length,
            itemBuilder: (_, i) {
              final a = artists[i] as Map;
              return Container(
                width: 120,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: Colors.white10,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Stack(children: [
                    // Artist photo as wallpaper
                    Positioned.fill(
                      child: Image.network(
                        a['img'] as String,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: color.withOpacity(0.3),
                          child: const Icon(Icons.person,
                              color: Colors.white38, size: 40),
                        ),
                        loadingBuilder: (_, child, p) => p == null
                            ? child
                            : Container(
                                color: Colors.white10,
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Color(0xFFE8173A),
                                  ),
                                ),
                              ),
                      ),
                    ),
                    // Bottom gradient overlay
                    Positioned.fill(
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.transparent, Colors.black87],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: [0.4, 1.0],
                          ),
                        ),
                      ),
                    ),
                    // Artist name & song at bottom
                    Positioned(
                      left: 8, right: 8, bottom: 8,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(a['name'] as String,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800)),
                          Text(a['song'] as String,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: Colors.white60, fontSize: 10)),
                        ],
                      ),
                    ),
                  ]),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 28),
      ],
    );
  }

  Widget _sectionHeader(String title, String? route) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
          if (route != null)
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, route),
              child: const Text('See all', style: TextStyle(
                  color: Color(0xFFE8173A), fontSize: 13,
                  fontWeight: FontWeight.w600)),
            ),
        ],
      ),
    );
  }

  ListTile _drawerTile(IconData icon, String label, String route) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(label, style: const TextStyle(color: Colors.white)),
      onTap: () => _onDrawerItemTapped(route),
    );
  }
}