import 'package:flutter/material.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String username = "Mido";
  String email    = "user@rediify.com";
  String bio      = "I love music 🎵";
  List<String> favoriteGenres = ["Hip Hop", "R&B", "Afrobeats", "Reggae"];

  static const _red     = Color(0xFFE8173A);
  static const _surface = Color(0xFF1A1A1A);
  static const _bg      = Color(0xFF0A0A0A);

  void _editProfile() {
    final nameCtrl = TextEditingController(text: username);
    final bioCtrl  = TextEditingController(text: bio);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 20, right: 20, top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2)),
            )),
            const SizedBox(height: 16),
            const Text("Edit Profile",
                style: TextStyle(color: Colors.white,
                    fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            _inputField(nameCtrl, 'Username', Icons.person_outline),
            const SizedBox(height: 12),
            _inputField(bioCtrl, 'Bio', Icons.edit_outlined),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    username = nameCtrl.text;
                    bio = bioCtrl.text;
                  });
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _red,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text("Save Changes",
                    style: TextStyle(color: Colors.white,
                        fontWeight: FontWeight.w700, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputField(TextEditingController ctrl, String hint, IconData icon) {
    return TextField(
      controller: ctrl,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38),
        prefixIcon: Icon(icon, color: _red),
        filled: true,
        fillColor: const Color(0xFF121212),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _red, width: 1.5),
        ),
      ),
    );
  }

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // ── Logo ─────────────────────────────────────────
        title: Row(children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                  colors: [Color(0xFFE8173A), Color(0xFF7B0020)]),
              boxShadow: [BoxShadow(
                  color: _red.withOpacity(0.4), blurRadius: 8)],
            ),
            child: ClipOval(
              child: Image.asset('assets/images/REdiify.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.music_note, color: Colors.white, size: 18)),
            ),
          ),
          const SizedBox(width: 8),
          RichText(text: const TextSpan(children: [
            TextSpan(text: 'RE', style: TextStyle(
                color: _red, fontSize: 20, fontWeight: FontWeight.w900)),
            TextSpan(text: 'diify', style: TextStyle(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
          ])),
        ]),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.white),
            onPressed: _editProfile,
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        child: Column(
          children: [

            // ── Avatar + name ───────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _red.withOpacity(0.2)),
              ),
              child: Column(children: [
                // Avatar with red ring
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                        colors: [Color(0xFFE8173A), Color(0xFF7B0020)]),
                  ),
                  child: const CircleAvatar(
                    radius: 50,
                    backgroundColor: Color(0xFF121212),
                    child: Icon(Icons.person, size: 52, color: Colors.white70),
                  ),
                ),
                const SizedBox(height: 14),
                Text(username,
                    style: const TextStyle(color: Colors.white,
                        fontSize: 22, fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text(email,
                    style: const TextStyle(color: Colors.white54, fontSize: 13)),
                const SizedBox(height: 8),
                Text(bio,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                    textAlign: TextAlign.center),
              ]),
            ),

            const SizedBox(height: 16),

            // ── Stats row ────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _stat('24',  'Liked'),
                  _divider(),
                  _stat('5',   'Playlists'),
                  _divider(),
                  _stat('12',  'Following'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Favorite genres ──────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Favorite Genres',
                      style: TextStyle(color: Colors.white,
                          fontSize: 15, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: favoriteGenres.map((g) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: _red.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _red.withOpacity(0.4)),
                      ),
                      child: Text(g, style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                    )).toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Menu items ───────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(children: [
                _menuTile(Icons.history,          'Listening History', () {}),
                _menuDivider(),
                _menuTile(Icons.download_outlined,'Downloads',         () {}),
                _menuDivider(),
                _menuTile(Icons.settings_outlined,'Settings',
                    () => Navigator.pushNamed(context, '/settings')),
                _menuDivider(),
                _menuTile(Icons.help_outline,     'Help & Support',    () {}),
              ]),
            ),

            const SizedBox(height: 16),

            // ── Logout ───────────────────────────────────
            SizedBox(
              width: double.infinity, height: 52,
              child: ElevatedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text('Log Out',
                    style: TextStyle(color: Colors.white,
                        fontSize: 15, fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _red,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 4,
                  shadowColor: _red.withOpacity(0.4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat(String val, String label) => Column(children: [
    Text(val, style: const TextStyle(color: Colors.white,
        fontSize: 22, fontWeight: FontWeight.w900)),
    const SizedBox(height: 4),
    Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
  ]);

  Widget _divider() => Container(
      width: 1, height: 36, color: Colors.white12);

  Widget _menuDivider() => const Divider(
      height: 1, color: Colors.white10, indent: 56);

  Widget _menuTile(IconData icon, String label, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: _red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: _red, size: 20),
      ),
      title: Text(label,
          style: const TextStyle(color: Colors.white,
              fontSize: 14, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right,
          color: Colors.white38, size: 20),
      onTap: onTap,
    );
  }
}