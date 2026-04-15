import 'package:flutter/material.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String username = "Mido";
  String email = "user@rediify.com";
  String bio = "I love music 🎵";
  List<String> favoriteGenres = ["Hip Hop", "R&B", "Afrobeats", "Reggee"];

  void _editProfile() {
    final nameController = TextEditingController(text: username);
    final bioController = TextEditingController(text: bio);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 16, right: 16, top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Edit Profile",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Username"),
            ),
            TextField(
              controller: bioController,
              decoration: const InputDecoration(labelText: "Bio"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  username = nameController.text;
                  bio = bioController.text;
                });
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 7, 3, 2),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text("Save Changes"),
            ),
          ],
        ),
      ),
    );
  }

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false, // clears navigation stack
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Colors.black,
        foregroundColor: const Color.fromARGB(255, 26, 209, 255),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _editProfile,
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // --- Avatar ---
            const CircleAvatar(
              radius: 55,
              backgroundColor: Color.fromARGB(255, 19, 164, 221),
              child: Icon(Icons.person, size: 55, color: Colors.white),
            ),
            const SizedBox(height: 12),

            // --- Name & Bio ---
            Text(username,
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            const SizedBox(height: 4),
            Text(email,
                style: const TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 8),
            Text(bio,
                style: const TextStyle(color: Color.fromARGB(179, 168, 16, 156), fontSize: 14),
                textAlign: TextAlign.center),

            const SizedBox(height: 24),
            const Divider(color: Colors.grey),

            // --- Stats Row ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                _StatItem(label: "Liked", value: "24"),
                _StatItem(label: "Playlists", value: "5"),
                _StatItem(label: "Following", value: "12"),
              ],
            ),

            const Divider(color: Colors.grey),
            const SizedBox(height: 16),

            // --- Favorite Genres ---
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Favorite Genres",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: favoriteGenres
                  .map((genre) => Chip(
                        label: Text(genre),
                        backgroundColor: const Color.fromARGB(255, 4, 163, 255),
                        labelStyle: const TextStyle(color: Colors.white),
                      ))
                  .toList(),
            ),

            const SizedBox(height: 24),

            // --- Logout Button ---
            ElevatedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout),
              label: const Text("Logout"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 247, 14, 150),
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Reusable stat widget
class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}