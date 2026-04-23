// library_screen.dart
// When used inside AppShell it renders as a plain body widget.
// When navigated to directly (/library route) it wraps itself in AppShell.

import 'package:flutter/material.dart';
import 'app_shell.dart';

// ── Route entry point ─────────────────────────────────────────
class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // If pushed as a route, show inside the shell at Library tab (index 2)
    return const AppShell(initialIndex: 2);
  }
}

// ── Models ────────────────────────────────────────────────────
class LibraryPlaylist {
  final String id;
  final String name;
  final int trackCount;
  final String createdBy;
  bool isFavorite;

  LibraryPlaylist({
    required this.id,
    required this.name,
    required this.trackCount,
    required this.createdBy,
    this.isFavorite = false,
  });
}

class LibrarySong {
  final String id;
  final String title;
  final String artist;
  final String genre;
  final String duration;
  bool isLiked;

  LibrarySong({
    required this.id,
    required this.title,
    required this.artist,
    required this.genre,
    required this.duration,
    this.isLiked = false,
  });
}

// ── Controller ────────────────────────────────────────────────
class LibraryController extends ChangeNotifier {
  int _selectedTab = 0;

  final List<LibraryPlaylist> _playlists = [
    LibraryPlaylist(id: '1', name: 'Afrobeats Vibes',  trackCount: 12, createdBy: 'Mido', isFavorite: true),
    LibraryPlaylist(id: '2', name: 'Late Night R&B',   trackCount: 8,  createdBy: 'Mido'),
    LibraryPlaylist(id: '3', name: 'Hip Hop Classics', trackCount: 15, createdBy: 'Mido'),
    LibraryPlaylist(id: '4', name: 'Reggae Chill',     trackCount: 10, createdBy: 'Mido'),
    LibraryPlaylist(id: '5', name: 'Top Hits 2024',    trackCount: 20, createdBy: 'Mido', isFavorite: true),
  ];

  final List<LibrarySong> _likedSongs = [
    LibrarySong(id: '1', title: 'Essence',         artist: 'Wizkid',     genre: 'Afrobeats', duration: '4:02', isLiked: true),
    LibrarySong(id: '2', title: 'Ojuelegba',       artist: 'Wizkid',     genre: 'Afrobeats', duration: '3:44', isLiked: true),
    LibrarySong(id: '3', title: "God's Plan",      artist: 'Drake',      genre: 'Hip Hop',   duration: '3:18', isLiked: true),
    LibrarySong(id: '4', title: 'Blinding Lights', artist: 'The Weeknd', genre: 'R&B',       duration: '3:22', isLiked: true),
    LibrarySong(id: '5', title: 'No Woman No Cry', artist: 'Bob Marley', genre: 'Reggae',    duration: '3:55', isLiked: true),
  ];

  final List<LibrarySong> _recentSongs = [
    LibrarySong(id: '6',  title: 'HUMBLE.',          artist: 'Kendrick Lamar', genre: 'Hip Hop',   duration: '2:57'),
    LibrarySong(id: '7',  title: 'Burna Boy Mix',    artist: 'Burna Boy',      genre: 'Afrobeats', duration: '4:15'),
    LibrarySong(id: '8',  title: 'Call Out My Name', artist: 'The Weeknd',     genre: 'R&B',       duration: '3:49'),
    LibrarySong(id: '9',  title: 'One Love',         artist: 'Bob Marley',     genre: 'Reggae',    duration: '2:58'),
    LibrarySong(id: '10', title: 'Nonstop',          artist: 'Drake',          genre: 'Hip Hop',   duration: '3:59'),
  ];

  int get selectedTab    => _selectedTab;
  List<LibraryPlaylist> get playlists    => _playlists;
  List<LibrarySong>     get likedSongs   => _likedSongs;
  List<LibrarySong>     get recentSongs  => _recentSongs;
  int get totalLiked     => _likedSongs.length;
  int get totalPlaylists => _playlists.length;

  void selectTab(int i) { _selectedTab = i; notifyListeners(); }

  void togglePlaylistFavorite(String id) {
    _playlists.firstWhere((p) => p.id == id).isFavorite ^= true;
    notifyListeners();
  }

  void unlikeSong(String id) {
    _likedSongs.removeWhere((s) => s.id == id);
    notifyListeners();
  }

  void addPlaylist(String name) {
    if (name.trim().isEmpty) return;
    _playlists.add(LibraryPlaylist(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name.trim(), trackCount: 0, createdBy: 'Mido',
    ));
    notifyListeners();
  }

  void deletePlaylist(String id) {
    _playlists.removeWhere((p) => p.id == id);
    notifyListeners();
  }
}

// ── Library body widget (used inside AppShell's IndexedStack) ─
class LibraryBody extends StatefulWidget {
  const LibraryBody({super.key});

  @override
  State<LibraryBody> createState() => _LibraryBodyState();
}

class _LibraryBodyState extends State<LibraryBody> {
  final LibraryController _ctrl = LibraryController();

  static const _red = Color(0xFFE8173A);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) => Column(
        children: [
          // Stats row
          Container(
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _StatBadge(icon: Icons.queue_music, label: 'Playlists', value: '${_ctrl.totalPlaylists}'),
                const VerticalDivider(color: Colors.grey),
                _StatBadge(icon: Icons.favorite,    label: 'Liked',     value: '${_ctrl.totalLiked}'),
                const VerticalDivider(color: Colors.grey),
                _StatBadge(icon: Icons.history,     label: 'Recent',    value: '${_ctrl.recentSongs.length}'),
              ],
            ),
          ),

          // Tab selector + add button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                _TabBtn(label: 'Playlists', selected: _ctrl.selectedTab == 0, onTap: () => _ctrl.selectTab(0)),
                const SizedBox(width: 8),
                _TabBtn(label: 'Liked',     selected: _ctrl.selectedTab == 1, onTap: () => _ctrl.selectTab(1)),
                const SizedBox(width: 8),
                _TabBtn(label: 'Recent',    selected: _ctrl.selectedTab == 2, onTap: () => _ctrl.selectTab(2)),
                const Spacer(),
                // Add playlist button
                GestureDetector(
                  onTap: _showAddDialog,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: _red, borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Tab content
          Expanded(
            child: _ctrl.selectedTab == 0
                ? _buildPlaylists()
                : _ctrl.selectedTab == 1
                    ? _buildLikedSongs()
                    : _buildRecentSongs(),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaylists() {
    if (_ctrl.playlists.isEmpty) return _empty('No playlists yet', Icons.queue_music);
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 160),
      itemCount: _ctrl.playlists.length,
      itemBuilder: (context, i) {
        final p = _ctrl.playlists[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: _red,
              child: Icon(Icons.queue_music, color: Colors.white),
            ),
            title: Text(p.name,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
            subtitle: Text('${p.trackCount} tracks',
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
              IconButton(
                icon: Icon(
                  p.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: p.isFavorite ? _red : Colors.grey, size: 20,
                ),
                onPressed: () => _ctrl.togglePlaylistFavorite(p.id),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.grey, size: 20),
                onPressed: () => _confirmDelete(p.id, p.name),
              ),
            ]),
          ),
        );
      },
    );
  }

  Widget _buildLikedSongs() {
    if (_ctrl.likedSongs.isEmpty) return _empty('No liked songs yet', Icons.favorite_border);
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 160),
      itemCount: _ctrl.likedSongs.length,
      itemBuilder: (_, i) {
        final s = _ctrl.likedSongs[i];
        return ListTile(
          leading: const CircleAvatar(
              backgroundColor: _red, child: Icon(Icons.music_note, color: Colors.white)),
          title: Text(s.title, style: const TextStyle(color: Colors.white)),
          subtitle: Text(s.artist, style: const TextStyle(color: Colors.grey)),
          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(s.duration, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _ctrl.unlikeSong(s.id),
              child: const Icon(Icons.favorite, color: _red, size: 20),
            ),
          ]),
        );
      },
    );
  }

  Widget _buildRecentSongs() {
    if (_ctrl.recentSongs.isEmpty) return _empty('No recent songs', Icons.history);
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 160),
      itemCount: _ctrl.recentSongs.length,
      itemBuilder: (_, i) {
        final s = _ctrl.recentSongs[i];
        return ListTile(
          leading: CircleAvatar(
              backgroundColor: Colors.grey[800],
              child: const Icon(Icons.music_note, color: Colors.white)),
          title: Text(s.title, style: const TextStyle(color: Colors.white)),
          subtitle: Text(s.artist, style: const TextStyle(color: Colors.grey)),
          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(s.duration, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(width: 8),
            Chip(
              label: Text(s.genre,
                  style: const TextStyle(color: Colors.white, fontSize: 10)),
              backgroundColor: Colors.grey[800],
              padding: EdgeInsets.zero,
            ),
          ]),
        );
      },
    );
  }

  void _showAddDialog() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('New Playlist', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: ctrl,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Playlist name',
            hintStyle: TextStyle(color: Colors.grey),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () {
              _ctrl.addPlaylist(ctrl.text);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: _red),
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(String id, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Delete Playlist', style: TextStyle(color: Colors.white)),
        content: Text('Delete "$name"?', style: const TextStyle(color: Colors.grey)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () { _ctrl.deletePlaylist(id); Navigator.pop(ctx); },
            style: ElevatedButton.styleFrom(backgroundColor: _red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _empty(String msg, IconData icon) {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, color: Colors.grey, size: 60),
        const SizedBox(height: 12),
        Text(msg, style: const TextStyle(color: Colors.grey, fontSize: 16)),
      ]),
    );
  }
}

// ── Reusable widgets ──────────────────────────────────────────
class _StatBadge extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _StatBadge({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Column(children: [
        Icon(icon, color: const Color(0xFFE8173A), size: 22),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(
            color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ]);
}

class _TabBtn extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _TabBtn({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFE8173A) : Colors.grey[900],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(label,
              style: TextStyle(
                  color: selected ? Colors.white : Colors.grey,
                  fontWeight: FontWeight.w500)),
        ),
      );
}