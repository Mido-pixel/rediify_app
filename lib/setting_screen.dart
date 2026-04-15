import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Toggle states
  bool _notificationsEnabled = true;
  bool _darkMode = true;
  bool _autoPlay = true;
  bool _highQualityStreaming = false;
  bool _downloadOnWifi = true;
  bool _showExplicitContent = false;

  String _selectedQuality = 'High';
  String _selectedLanguage = 'English';

  final List<String> _qualities = ['Low', 'Medium', 'High', 'Ultra'];
  final List<String> _languages = ['English', 'Swahili', 'French', 'Spanish'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          // ── Profile Card ──────────────────────────────────
          _buildProfileCard(),
          const SizedBox(height: 24),

          // ── Playback ──────────────────────────────────────
          _buildSectionHeader('Playback'),
          _buildSettingsCard([
            _buildToggleTile(
              icon: Icons.play_circle_outline,
              iconColor: const Color(0xFF6C63FF),
              title: 'Autoplay',
              subtitle: 'Continue playing similar songs',
              value: _autoPlay,
              onChanged: (v) => setState(() => _autoPlay = v),
            ),
            _buildDivider(),
            _buildDropdownTile(
              icon: Icons.graphic_eq,
              iconColor: const Color(0xFF6C63FF),
              title: 'Streaming Quality',
              value: _selectedQuality,
              items: _qualities,
              onChanged: (v) => setState(() => _selectedQuality = v!),
            ),
          ]),
          const SizedBox(height: 16),

          // ── Downloads ─────────────────────────────────────
          _buildSectionHeader('Downloads'),
          _buildSettingsCard([
            _buildToggleTile(
              icon: Icons.wifi,
              iconColor: const Color(0xFF00D4AA),
              title: 'Download on Wi-Fi Only',
              subtitle: 'Avoid using mobile data',
              value: _downloadOnWifi,
              onChanged: (v) => setState(() => _downloadOnWifi = v),
            ),
            _buildDivider(),
            _buildToggleTile(
              icon: Icons.high_quality_outlined,
              iconColor: const Color(0xFF00D4AA),
              title: 'High Quality Downloads',
              subtitle: 'Uses more storage space',
              value: _highQualityStreaming,
              onChanged: (v) => setState(() => _highQualityStreaming = v),
            ),
          ]),
          const SizedBox(height: 16),

          // ── Notifications ─────────────────────────────────
          _buildSectionHeader('Notifications'),
          _buildSettingsCard([
            _buildToggleTile(
              icon: Icons.notifications_outlined,
              iconColor: const Color(0xFFFF6B6B),
              title: 'Push Notifications',
              subtitle: 'New releases & activity',
              value: _notificationsEnabled,
              onChanged: (v) => setState(() => _notificationsEnabled = v),
            ),
          ]),
          const SizedBox(height: 16),

          // ── Appearance ────────────────────────────────────
          _buildSectionHeader('Appearance'),
          _buildSettingsCard([
            _buildToggleTile(
              icon: Icons.dark_mode_outlined,
              iconColor: const Color(0xFFFFB347),
              title: 'Dark Mode',
              subtitle: 'Use dark theme',
              value: _darkMode,
              onChanged: (v) => setState(() => _darkMode = v),
            ),
            _buildDivider(),
            _buildDropdownTile(
              icon: Icons.language,
              iconColor: const Color(0xFFFFB347),
              title: 'Language',
              value: _selectedLanguage,
              items: _languages,
              onChanged: (v) => setState(() => _selectedLanguage = v!),
            ),
          ]),
          const SizedBox(height: 16),

          // ── Content ───────────────────────────────────────
          _buildSectionHeader('Content'),
          _buildSettingsCard([
            _buildToggleTile(
              icon: Icons.explicit_outlined,
              iconColor: const Color(0xFFFF6B6B),
              title: 'Explicit Content',
              subtitle: 'Show explicit tracks',
              value: _showExplicitContent,
              onChanged: (v) => setState(() => _showExplicitContent = v),
            ),
          ]),
          const SizedBox(height: 16),

          // ── Account Actions ───────────────────────────────
          _buildSectionHeader('Account'),
          _buildSettingsCard([
            _buildNavTile(
              icon: Icons.lock_outline,
              iconColor: const Color(0xFF6C63FF),
              title: 'Change Password',
              onTap: () {},
            ),
            _buildDivider(),
            _buildNavTile(
              icon: Icons.privacy_tip_outlined,
              iconColor: const Color(0xFF6C63FF),
              title: 'Privacy Policy',
              onTap: () {},
            ),
            _buildDivider(),
            _buildNavTile(
              icon: Icons.info_outline,
              iconColor: const Color(0xFF6C63FF),
              title: 'About REdiify',
              onTap: () {},
            ),
          ]),
          const SizedBox(height: 16),

          // ── Logout ────────────────────────────────────────
          _buildLogoutButton(),
          const SizedBox(height: 32),

          // Version tag
          const Center(
            child: Text(
              'REdiify v1.0.0',
              style: TextStyle(color: Color(0xFF444455), fontSize: 12),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ── Profile Card ──────────────────────────────────────────
  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E1B3A), Color(0xFF16213E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF6C63FF).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF6C63FF), Color(0xFF00D4AA)],
              ),
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Name',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'youremail@example.com',
                  style: TextStyle(color: Color(0xFF888899), fontSize: 13),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/profile'),
            icon: const Icon(Icons.edit_outlined, color: Color(0xFF6C63FF)),
          ),
        ],
      ),
    );
  }

  // ── Section Header ────────────────────────────────────────
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: Color(0xFF6C63FF),
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  // ── Settings Card Container ───────────────────────────────
  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF12121A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF222233)),
      ),
      child: Column(children: children),
    );
  }

  // ── Toggle Tile ───────────────────────────────────────────
  Widget _buildToggleTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w500)),
                if (subtitle != null)
                  Text(subtitle,
                      style: const TextStyle(
                          color: Color(0xFF666677), fontSize: 12)),
              ],
            ),
          ),
          CupertinoSwitch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: const Color(0xFF6C63FF),
          ),
        ],
      ),
    );
  }

  // ── Dropdown Tile ─────────────────────────────────────────
  Widget _buildDropdownTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(title,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500)),
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              dropdownColor: const Color(0xFF1A1A2E),
              style: const TextStyle(color: Color(0xFF6C63FF), fontSize: 14),
              icon: const Icon(Icons.keyboard_arrow_down,
                  color: Color(0xFF6C63FF), size: 18),
              items: items
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  // ── Nav Tile (arrow) ──────────────────────────────────────
  Widget _buildNavTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(title,
          style: const TextStyle(
              color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.arrow_forward_ios,
          color: Color(0xFF444455), size: 14),
    );
  }

  // ── Divider ───────────────────────────────────────────────
  Widget _buildDivider() {
    return const Divider(
        color: Color(0xFF1E1E2E), height: 1, indent: 56, endIndent: 16);
  }

  // ── Logout Button ─────────────────────────────────────────
  Widget _buildLogoutButton() {
    return GestureDetector(
      onTap: () => _showLogoutDialog(),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A0A0A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFF6B6B).withOpacity(0.4)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, color: Color(0xFFFF6B6B), size: 20),
            SizedBox(width: 10),
            Text('Log Out',
                style: TextStyle(
                    color: Color(0xFFFF6B6B),
                    fontSize: 16,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  // ── Logout Dialog ─────────────────────────────────────────
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF12121A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Log Out',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        content: const Text('Are you sure you want to log out?',
            style: TextStyle(color: Color(0xFF888899))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: Color(0xFF6C63FF))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushNamedAndRemoveUntil(
                  context, '/login', (route) => false);
            },
            child: const Text('Log Out',
                style: TextStyle(color: Color(0xFFFF6B6B))),
          ),
        ],
      ),
    );
  }
}