import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled  = true;
  bool _darkMode              = true;
  bool _autoPlay              = true;
  bool _highQualityStreaming  = false;
  bool _downloadOnWifi        = true;
  bool _showExplicitContent   = false;

  String _selectedQuality  = 'High';
  String _selectedLanguage = 'English';

  static const _red     = Color(0xFFE8173A);
  static const _bg      = Color(0xFF0A0A0A);
  static const _surface = Color(0xFF1A1A1A);

  final List<String> _qualities = ['Low', 'Medium', 'High', 'Ultra'];
  final List<String> _languages = ['English', 'Swahili', 'French', 'Spanish'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        // ── ← Back arrow ────────────────────────────────
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Settings',
            style: TextStyle(color: Colors.white,
                fontSize: 20, fontWeight: FontWeight.w800)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          _buildProfileCard(),
          const SizedBox(height: 24),

          _sectionHeader('PLAYBACK'),
          _buildCard([
            _toggleTile(Icons.play_circle_outline, _red, 'Autoplay',
                'Continue playing similar songs', _autoPlay,
                (v) => setState(() => _autoPlay = v)),
            _divider(),
            _dropdownTile(Icons.graphic_eq, _red, 'Streaming Quality',
                _selectedQuality, _qualities,
                (v) => setState(() => _selectedQuality = v!)),
          ]),
          const SizedBox(height: 16),

          _sectionHeader('DOWNLOADS'),
          _buildCard([
            _toggleTile(Icons.wifi, const Color(0xFF1DB954),
                'Download on Wi-Fi Only', 'Avoid using mobile data',
                _downloadOnWifi, (v) => setState(() => _downloadOnWifi = v)),
            _divider(),
            _toggleTile(Icons.high_quality_outlined, const Color(0xFF1DB954),
                'High Quality Downloads', 'Uses more storage space',
                _highQualityStreaming,
                (v) => setState(() => _highQualityStreaming = v)),
          ]),
          const SizedBox(height: 16),

          _sectionHeader('NOTIFICATIONS'),
          _buildCard([
            _toggleTile(Icons.notifications_outlined, _red,
                'Push Notifications', 'New releases & activity',
                _notificationsEnabled,
                (v) => setState(() => _notificationsEnabled = v)),
          ]),
          const SizedBox(height: 16),

          _sectionHeader('APPEARANCE'),
          _buildCard([
            _toggleTile(Icons.dark_mode_outlined, const Color(0xFFFFB347),
                'Dark Mode', 'Use dark theme',
                _darkMode, (v) => setState(() => _darkMode = v)),
            _divider(),
            _dropdownTile(Icons.language, const Color(0xFFFFB347),
                'Language', _selectedLanguage, _languages,
                (v) => setState(() => _selectedLanguage = v!)),
          ]),
          const SizedBox(height: 16),

          _sectionHeader('CONTENT'),
          _buildCard([
            _toggleTile(Icons.explicit_outlined, _red,
                'Explicit Content', 'Show explicit tracks',
                _showExplicitContent,
                (v) => setState(() => _showExplicitContent = v)),
          ]),
          const SizedBox(height: 16),

          _sectionHeader('ACCOUNT'),
          _buildCard([
            _navTile(Icons.lock_outline,      _red,  'Change Password', () {}),
            _divider(),
            _navTile(Icons.privacy_tip_outlined, _red, 'Privacy Policy', () {}),
            _divider(),
            _navTile(Icons.info_outline,      _red,  'About REdiify',   () {}),
          ]),
          const SizedBox(height: 16),

          _logoutButton(),
          const SizedBox(height: 24),
          const Center(child: Text('REdiify v1.0.0',
              style: TextStyle(color: Color(0xFF444455), fontSize: 12))),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ── Profile card ─────────────────────────────────────────
  Widget _buildProfileCard() {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/profile'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _red.withOpacity(0.3)),
        ),
        child: Row(children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                  colors: [Color(0xFFE8173A), Color(0xFF7B0020)]),
            ),
            child: ClipOval(
              child: Image.asset('assets/images/REdiify.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.person, color: Colors.white, size: 28)),
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Your Name', style: TextStyle(color: Colors.white,
                  fontSize: 16, fontWeight: FontWeight.w700)),
              SizedBox(height: 3),
              Text('youremail@rediify.com',
                  style: TextStyle(color: Colors.white54, fontSize: 12)),
            ],
          )),
          // › forward arrow
          const Icon(Icons.chevron_right, color: Colors.white38, size: 22),
        ]),
      ),
    );
  }

  Widget _sectionHeader(String title) => Padding(
    padding: const EdgeInsets.only(left: 4, bottom: 8),
    child: Text(title, style: const TextStyle(
        color: Color(0xFFE8173A), fontSize: 11,
        fontWeight: FontWeight.w700, letterSpacing: 1.5)),
  );

  Widget _buildCard(List<Widget> children) => Container(
    decoration: BoxDecoration(
        color: _surface, borderRadius: BorderRadius.circular(16)),
    child: Column(children: children),
  );

  Widget _toggleTile(IconData icon, Color color, String title,
      String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(
              color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
          Text(subtitle, style: const TextStyle(
              color: Colors.white38, fontSize: 12)),
        ])),
        CupertinoSwitch(value: value, onChanged: onChanged,
            activeTrackColor: _red),
      ]),
    );
  }

  Widget _dropdownTile(IconData icon, Color color, String title,
      String value, List<String> items, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(child: Text(title, style: const TextStyle(
            color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500))),
        DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            dropdownColor: const Color(0xFF1A1A1A),
            style: TextStyle(color: color, fontSize: 14),
            icon: Icon(Icons.keyboard_arrow_down, color: color, size: 18),
            items: items.map((e) =>
                DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: onChanged,
          ),
        ),
      ]),
    );
  }

  // ── Nav tile with › arrow ────────────────────────────────
  Widget _navTile(IconData icon, Color color, String title, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title, style: const TextStyle(
          color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
      // ── › forward arrow ──────────────────────────────
      trailing: const Icon(Icons.chevron_right,
          color: Colors.white38, size: 20),
    );
  }

  Widget _divider() => const Divider(
      color: Color(0xFF282828), height: 1, indent: 56, endIndent: 16);

  Widget _logoutButton() {
    return GestureDetector(
      onTap: _showLogoutDialog,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: _red.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _red.withOpacity(0.4)),
        ),
        child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.logout, color: Color(0xFFE8173A), size: 20),
          SizedBox(width: 10),
          Text('Log Out', style: TextStyle(
              color: Color(0xFFE8173A), fontSize: 16,
              fontWeight: FontWeight.w700)),
        ]),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Log Out',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        content: const Text('Are you sure you want to log out?',
            style: TextStyle(color: Colors.white54)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel',
                  style: TextStyle(color: Colors.white54))),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushNamedAndRemoveUntil(
                  context, '/login', (route) => false);
            },
            child: const Text('Log Out',
                style: TextStyle(color: Color(0xFFE8173A),
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}