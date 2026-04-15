import 'package:flutter/material.dart';

// --- Data Models ---
class Track {
  final String title;
  final String artist;
  final String genre;
  final bool isFavorite;

  const Track({
    required this.title,
    required this.artist,
    required this.genre,
    this.isFavorite = false,
  });
}

class Artist {
  final String name;
  final String genre;

  const Artist({required this.name, required this.genre});
}

class Playlist {
  final String name;
  final int trackCount;

  const Playlist({required this.name, required this.trackCount});
}

// --- Hardcoded Data ---
const List<Track> allTracks = [
  Track(title: "God's Plan", artist: "Drake", genre: "Hip Hop"),
  Track(title: "Essence", artist: "Wizkid", genre: "Afrobeats", isFavorite: true),
  Track(title: "Blinding Lights", artist: "The Weeknd", genre: "R&B"),
  Track(title: "No Woman No Cry", artist: "Bob Marley", genre: "Reggae"),
  Track(title: "Ojuelegba", artist: "Wizkid", genre: "Afrobeats", isFavorite: true),
  Track(title: "Nonstop", artist: "Drake", genre: "Hip Hop"),
  Track(title: "Call Out My Name", artist: "The Weeknd", genre: "R&B"),
  Track(title: "One Love", artist: "Bob Marley", genre: "Reggae"),
];

const List<Artist> allArtists = [
  Artist(name: "Drake", genre: "Hip Hop"),
  Artist(name: "Wizkid", genre: "Afrobeats"),
  Artist(name: "The Weeknd", genre: "R&B"),
  Artist(name: "Bob Marley", genre: "Reggae"),
  Artist(name: "Burna Boy", genre: "Afrobeats"),
  Artist(name: "Kendrick Lamar", genre: "Hip Hop"),
];

const List<Playlist> allPlaylists = [
  Playlist(name: "Afrobeats Vibes", trackCount: 12),
  Playlist(name: "Late Night R&B", trackCount: 8),
  Playlist(name: "Hip Hop Classics", trackCount: 15),
  Playlist(name: "Reggae Chill", trackCount: 10),
  Playlist(name: "Top Hits 2024", trackCount: 20),
];

// --- Search Screen ---
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  late TabController _tabController;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  List<Track> get filteredTracks => allTracks
      .where((t) =>
          t.title.toLowerCase().contains(_query) ||
          t.artist.toLowerCase().contains(_query))
      .toList();

  List<Track> get filteredFavorites => allTracks
      .where((t) =>
          t.isFavorite &&
          (t.title.toLowerCase().contains(_query) ||
              t.artist.toLowerCase().contains(_query)))
      .toList();

  List<Artist> get filteredArtists => allArtists
      .where((a) => a.name.toLowerCase().contains(_query))
      .toList();

  List<Playlist> get filteredPlaylists => allPlaylists
      .where((p) => p.name.toLowerCase().contains(_query))
      .toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text("Search"),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.red,
          labelColor: Colors.red,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: "Songs"),
            Tab(text: "Artists"),
            Tab(text: "Playlists"),
            Tab(text: "Favorites"),
          ],
        ),
      ),
      body: Column(
        children: [
          // --- Search Bar ---
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              onChanged: (val) =>
                  setState(() => _query = val.toLowerCase().trim()),
              decoration: InputDecoration(
                hintText: "Search songs, artists, playlists...",
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey[900],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // --- Tab Views ---
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTrackList(filteredTracks),
                _buildArtistList(filteredArtists),
                _buildPlaylistList(filteredPlaylists),
                _buildTrackList(filteredFavorites, isFavoritesTab: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Songs & Favorites List ---
  Widget _buildTrackList(List<Track> tracks, {bool isFavoritesTab = false}) {
    if (tracks.isEmpty) {
      return _buildEmpty(
          isFavoritesTab ? "No favorites found" : "No songs found");
    }
    return ListView.builder(
      itemCount: tracks.length,
      itemBuilder: (context, index) {
        final track = tracks[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.red,
            child: const Icon(Icons.music_note, color: Colors.white),
          ),
          title: Text(track.title,
              style: const TextStyle(color: Colors.white)),
          subtitle: Text(track.artist,
              style: const TextStyle(color: Colors.grey)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Chip(
                label: Text(track.genre,
                    style: const TextStyle(color: Colors.white, fontSize: 11)),
                backgroundColor: Colors.grey[800],
                padding: EdgeInsets.zero,
              ),
              if (track.isFavorite)
                const Icon(Icons.favorite, color: Colors.red, size: 18),
            ],
          ),
        );
      },
    );
  }

  // --- Artists List ---
  Widget _buildArtistList(List<Artist> artists) {
    if (artists.isEmpty) return _buildEmpty("No artists found");
    return ListView.builder(
      itemCount: artists.length,
      itemBuilder: (context, index) {
        final artist = artists[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.red,
            child: Text(
              artist.name[0],
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          title: Text(artist.name,
              style: const TextStyle(color: Colors.white)),
          subtitle:
              Text(artist.genre, style: const TextStyle(color: Colors.grey)),
          trailing:
              const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
        );
      },
    );
  }

  // --- Playlists List ---
  Widget _buildPlaylistList(List<Playlist> playlists) {
    if (playlists.isEmpty) return _buildEmpty("No playlists found");
    return ListView.builder(
      itemCount: playlists.length,
      itemBuilder: (context, index) {
        final playlist = playlists[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.red,
            child: const Icon(Icons.queue_music, color: Colors.white),
          ),
          title: Text(playlist.name,
              style: const TextStyle(color: Colors.white)),
          subtitle: Text("${playlist.trackCount} tracks",
              style: const TextStyle(color: Colors.grey)),
          trailing:
              const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
        );
      },
    );
  }

  // --- Empty State ---
  Widget _buildEmpty(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, color: Colors.grey, size: 60),
          const SizedBox(height: 12),
          Text(message, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}