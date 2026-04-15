import 'package:flutter/material.dart';

// --- Models ---
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

// --- Library Controller ---
class LibraryController extends ChangeNotifier {
  int _selectedTab = 0; // 0 = Playlists, 1 = Liked, 2 = Recent

  final List<LibraryPlaylist> _playlists = [
    LibraryPlaylist(id: '1', name: "Afrobeats Vibes",   trackCount: 12, createdBy: "Mido", isFavorite: true),
    LibraryPlaylist(id: '2', name: "Late Night R&B",    trackCount: 8,  createdBy: "Mido"),
    LibraryPlaylist(id: '3', name: "Hip Hop Classics",  trackCount: 15, createdBy: "Mido"),
    LibraryPlaylist(id: '4', name: "Reggae Chill",      trackCount: 10, createdBy: "Mido"),
    LibraryPlaylist(id: '5', name: "Top Hits 2024",     trackCount: 20, createdBy: "Mido", isFavorite: true),
  ];

  final List<LibrarySong> _likedSongs = [
    LibrarySong(id: '1', title: "Essence",        artist: "Wizkid",        genre: "Afrobeats", duration: "4:02", isLiked: true),
    LibrarySong(id: '2', title: "Ojuelegba",      artist: "Wizkid",        genre: "Afrobeats", duration: "3:44", isLiked: true),
    LibrarySong(id: '3', title: "God's Plan",     artist: "Drake",         genre: "Hip Hop",   duration: "3:18", isLiked: true),
    LibrarySong(id: '4', title: "Blinding Lights",artist: "The Weeknd",    genre: "R&B",       duration: "3:22", isLiked: true),
    LibrarySong(id: '5', title: "No Woman No Cry",artist: "Bob Marley",    genre: "Reggae",    duration: "3:55", isLiked: true),
  ];

  final List<LibrarySong> _recentSongs = [
    LibrarySong(id: '6', title: "HUMBLE.",        artist: "Kendrick Lamar",genre: "Hip Hop",   duration: "2:57"),
    LibrarySong(id: '7', title: "Burna Boy Mix",  artist: "Burna Boy",     genre: "Afrobeats", duration: "4:15"),
    LibrarySong(id: '8', title: "Call Out My Name",artist: "The Weeknd",   genre: "R&B",       duration: "3:49"),
    LibrarySong(id: '9', title: "One Love",       artist: "Bob Marley",    genre: "Reggae",    duration: "2:58"),
    LibrarySong(id: '10',title: "Nonstop",        artist: "Drake",         genre: "Hip Hop",   duration: "3:59"),
  ];

  // --- Getters ---
  int get selectedTab => _selectedTab;
  List<LibraryPlaylist> get playlists => _playlists;
  List<LibrarySong> get likedSongs => _likedSongs;
  List<LibrarySong> get recentSongs => _recentSongs;
  int get totalLiked => _likedSongs.length;
  int get totalPlaylists => _playlists.length;

  // --- Switch Tab ---
  void selectTab(int index) {
    _selectedTab = index;
    notifyListeners();
  }

  // --- Toggle Playlist Favorite ---
  void togglePlaylistFavorite(String id) {
    final playlist = _playlists.firstWhere((p) => p.id == id);
    playlist.isFavorite = !playlist.isFavorite;
    notifyListeners();
  }

  // --- Unlike Song ---
  void unlikeSong(String id) {
    final song = _likedSongs.firstWhere((s) => s.id == id);
    song.isLiked = false;
    _likedSongs.removeWhere((s) => s.id == id);
    notifyListeners();
  }

  // --- Add Playlist ---
  void addPlaylist(String name) {
    if (name.trim().isEmpty) return;
    _playlists.add(LibraryPlaylist(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name.trim(),
      trackCount: 0,
      createdBy: "Mido",
    ));
    notifyListeners();
  }

  // --- Delete Playlist ---
  void deletePlaylist(String id) {
    _playlists.removeWhere((p) => p.id == id);
    notifyListeners();
  }
}

// --- Library Screen ---
class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final LibraryController _controller = LibraryController();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            title: const Text(
              "Your Library",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.add, color: Colors.white),
                onPressed: _showAddPlaylistDialog,
              ),
            ],
          ),
          body: Column(
            children: [
              // --- Stats Row ---
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _StatBadge(
                      icon: Icons.queue_music,
                      label: "Playlists",
                      value: _controller.totalPlaylists.toString(),
                    ),
                    const VerticalDivider(color: Colors.grey),
                    _StatBadge(
                      icon: Icons.favorite,
                      label: "Liked",
                      value: _controller.totalLiked.toString(),
                    ),
                    const VerticalDivider(color: Colors.grey),
                    _StatBadge(
                      icon: Icons.history,
                      label: "Recent",
                      value: _controller.recentSongs.length.toString(),
                    ),
                  ],
                ),
              ),

              // --- Tab Selector ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _TabButton(
                      label: "Playlists",
                      selected: _controller.selectedTab == 0,
                      onTap: () => _controller.selectTab(0),
                    ),
                    const SizedBox(width: 8),
                    _TabButton(
                      label: "Liked",
                      selected: _controller.selectedTab == 1,
                      onTap: () => _controller.selectTab(1),
                    ),
                    const SizedBox(width: 8),
                    _TabButton(
                      label: "Recent",
                      selected: _controller.selectedTab == 2,
                      onTap: () => _controller.selectTab(2),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // --- Tab Content ---
              Expanded(
                child: _controller.selectedTab == 0
                    ? _buildPlaylists()
                    : _controller.selectedTab == 1
                        ? _buildLikedSongs()
                        : _buildRecentSongs(),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- Playlists Tab ---
  Widget _buildPlaylists() {
    if (_controller.playlists.isEmpty) {
      return _buildEmpty("No playlists yet", Icons.queue_music);
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _controller.playlists.length,
      itemBuilder: (context, index) {
        final playlist = _controller.playlists[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.red,
              child: const Icon(Icons.queue_music, color: Colors.white),
            ),
            title: Text(playlist.name,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w500)),
            subtitle: Text("${playlist.trackCount} tracks",
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    playlist.isFavorite
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color:
                        playlist.isFavorite ? Colors.red : Colors.grey,
                    size: 20,
                  ),
                  onPressed: () =>
                      _controller.togglePlaylistFavorite(playlist.id),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      color: Colors.grey, size: 20),
                  onPressed: () =>
                      _confirmDeletePlaylist(playlist.id, playlist.name),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- Liked Songs Tab ---
  Widget _buildLikedSongs() {
    if (_controller.likedSongs.isEmpty) {
      return _buildEmpty("No liked songs yet", Icons.favorite_border);
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _controller.likedSongs.length,
      itemBuilder: (context, index) {
        final song = _controller.likedSongs[index];
        return ListTile(
          leading: const CircleAvatar(
            backgroundColor: Colors.red,
            child: Icon(Icons.music_note, color: Colors.white),
          ),
          title: Text(song.title,
              style: const TextStyle(color: Colors.white)),
          subtitle: Text(song.artist,
              style: const TextStyle(color: Colors.grey)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(song.duration,
                  style: const TextStyle(
                      color: Colors.grey, fontSize: 12)),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _controller.unlikeSong(song.id),
                child: const Icon(Icons.favorite,
                    color: Colors.red, size: 20),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- Recent Songs Tab ---
  Widget _buildRecentSongs() {
    if (_controller.recentSongs.isEmpty) {
      return _buildEmpty("No recent songs", Icons.history);
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _controller.recentSongs.length,
      itemBuilder: (context, index) {
        final song = _controller.recentSongs[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.grey[800],
            child: const Icon(Icons.music_note, color: Colors.white),
          ),
          title: Text(song.title,
              style: const TextStyle(color: Colors.white)),
          subtitle: Text(song.artist,
              style: const TextStyle(color: Colors.grey)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(song.duration,
                  style: const TextStyle(
                      color: Colors.grey, fontSize: 12)),
              const SizedBox(width: 8),
              Chip(
                label: Text(song.genre,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 10)),
                backgroundColor: Colors.grey[800],
                padding: EdgeInsets.zero,
              ),
            ],
          ),
        );
      },
    );
  }

  // --- Add Playlist Dialog ---
  void _showAddPlaylistDialog() {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text("New Playlist",
            style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: nameController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: "Playlist name",
            hintStyle: TextStyle(color: Colors.grey),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel",
                style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              _controller.addPlaylist(nameController.text);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red),
            child: const Text("Create"),
          ),
        ],
      ),
    );
  }

  // --- Confirm Delete Dialog ---
  void _confirmDeletePlaylist(String id, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text("Delete Playlist",
            style: TextStyle(color: Colors.white)),
        content: Text('Are you sure you want to delete "$name"?',
            style: const TextStyle(color: Colors.grey)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel",
                style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              _controller.deletePlaylist(id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  // --- Empty State ---
  Widget _buildEmpty(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.grey, size: 60),
          const SizedBox(height: 12),
          Text(message,
              style: const TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }
}

// --- Reusable Widgets ---
class _StatBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _StatBadge(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.red, size: 22),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        Text(label,
            style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _TabButton(
      {required this.label,
      required this.selected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? Colors.red : Colors.grey[900],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label,
            style: TextStyle(
                color: selected ? Colors.white : Colors.grey,
                fontWeight: FontWeight.w500)),
      ),
    );
  }
}