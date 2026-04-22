import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final int _selectedIndex = 0;

  void _onDrawerItemTapped(String route) {
    Navigator.pop(context); // close drawer
    if (ModalRoute.of(context)?.settings.name != route) {
      Navigator.pushReplacementNamed(context, route);
    }
  }

  void _onSearchPressed() {
    Navigator.pushNamed(context, '/search');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Home", style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            tooltip: 'Search',
            onPressed: _onSearchPressed, // ✅ functional search icon
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Logout',
            onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
          ),
        ],
      ),

      drawer: Drawer(
        backgroundColor: const Color(0xFF1A1A1A),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Color(0xFFE8173A),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white.withOpacity(0.2),
                    radius: 28,
                    child: const Icon(Icons.music_note, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "REdiify",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),

            ListTile(
              leading: const Icon(Icons.home, color: Colors.white),
              title: const Text('Dashboard', style: TextStyle(color: Colors.white)),
              onTap: () => _onDrawerItemTapped('/dashboard'),
            ),
            ListTile(
              leading: const Icon(Icons.library_music, color: Colors.white),
              title: const Text('Library', style: TextStyle(color: Colors.white)),
              onTap: () => _onDrawerItemTapped('/library'),
            ),
            ListTile(
              leading: const Icon(Icons.queue_music, color: Colors.white),
              title: const Text('Playlists', style: TextStyle(color: Colors.white)),
              onTap: () => _onDrawerItemTapped('/playlists'),
            ),
            ListTile(
              leading: const Icon(Icons.person, color: Colors.white),
              title: const Text('Profile', style: TextStyle(color: Colors.white)),
              onTap: () => _onDrawerItemTapped('/profile'),
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.white),
              title: const Text('Settings', style: TextStyle(color: Colors.white)),
              onTap: () => _onDrawerItemTapped('/settings'),
            ),
          ],
        ),
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/REdiify.png', height: 120),
            const SizedBox(height: 20),
            const Text(
              "Welcome to REdiify!",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE8173A)),
              onPressed: () => Navigator.pushReplacementNamed(context, '/signup'),
              child: const Text("Sign Up"),
            ),
          ],
        ),
      ),
    );
  }
}
