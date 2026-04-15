import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SettingsController extends ChangeNotifier {
  final _supabase = Supabase.instance.client;

  // ── State ──────────────────────────────────────────────────
  bool isLoading = false;
  bool isSaving = false;
  String? errorMessage;
  String? successMessage;

  // Preferences
  bool notificationsEnabled = true;
  bool darkMode = true;
  bool autoPlay = true;
  bool highQualityStreaming = false;
  bool downloadOnWifi = true;
  bool showExplicitContent = false;

  String selectedQuality = 'High';
  String selectedLanguage = 'English';

  Map<String, dynamic>? userProfile;

  final List<String> qualities = ['Low', 'Medium', 'High', 'Ultra'];
  final List<String> languages = ['English', 'Swahili', 'French', 'Spanish'];

  // ── Init ───────────────────────────────────────────────────
  Future<void> init() async {
    await Future.wait([
      fetchUserProfile(),
      loadPreferences(),
    ]);
  }

  // ── Load Profile ───────────────────────────────────────────
  Future<void> fetchUserProfile() async {
    try {
      isLoading = true;
      notifyListeners();

      final user = _supabase.auth.currentUser;
      if (user == null) return;

      final response = await _supabase
          .from('profiles')
          .select('id, username, avatar_url, email')
          .eq('id', user.id)
          .single();

      userProfile = response;
    } catch (e) {
      errorMessage = 'Failed to load profile: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ── Load Preferences from Supabase ─────────────────────────
  Future<void> loadPreferences() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      final response = await _supabase
          .from('user_preferences')
          .select()
          .eq('user_id', user.id)
          .maybeSingle();

      if (response != null) {
        notificationsEnabled  = response['notifications_enabled'] ?? true;
        darkMode              = response['dark_mode'] ?? true;
        autoPlay              = response['auto_play'] ?? true;
        highQualityStreaming   = response['high_quality_streaming'] ?? false;
        downloadOnWifi        = response['download_on_wifi'] ?? true;
        showExplicitContent   = response['show_explicit_content'] ?? false;
        selectedQuality       = response['streaming_quality'] ?? 'High';
        selectedLanguage      = response['language'] ?? 'English';
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Failed to load preferences: $e');
    }
  }

  // ── Save Preferences ───────────────────────────────────────
  Future<void> savePreferences() async {
    try {
      isSaving = true;
      notifyListeners();

      final user = _supabase.auth.currentUser;
      if (user == null) return;

      await _supabase.from('user_preferences').upsert({
        'user_id': user.id,
        'notifications_enabled': notificationsEnabled,
        'dark_mode': darkMode,
        'auto_play': autoPlay,
        'high_quality_streaming': highQualityStreaming,
        'download_on_wifi': downloadOnWifi,
        'show_explicit_content': showExplicitContent,
        'streaming_quality': selectedQuality,
        'language': selectedLanguage,
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'user_id');

      successMessage = 'Settings saved!';
      notifyListeners();
      await Future.delayed(const Duration(seconds: 2));
      successMessage = null;
      notifyListeners();
    } catch (e) {
      errorMessage = 'Failed to save settings: $e';
      notifyListeners();
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  // ── Toggle Helpers ─────────────────────────────────────────
  void toggleNotifications(bool v)     { notificationsEnabled = v;  _autosave(); }
  void toggleDarkMode(bool v)          { darkMode = v;               _autosave(); }
  void toggleAutoPlay(bool v)          { autoPlay = v;               _autosave(); }
  void toggleHighQuality(bool v)       { highQualityStreaming = v;   _autosave(); }
  void toggleDownloadOnWifi(bool v)    { downloadOnWifi = v;         _autosave(); }
  void toggleExplicitContent(bool v)   { showExplicitContent = v;   _autosave(); }
  void setQuality(String v)            { selectedQuality = v;        _autosave(); }
  void setLanguage(String v)           { selectedLanguage = v;       _autosave(); }

  void _autosave() {
    notifyListeners();
    savePreferences();
  }

  // ── Change Password ────────────────────────────────────────
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      isSaving = true;
      notifyListeners();

      await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      successMessage = 'Password updated successfully!';
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      errorMessage = e.message;
      notifyListeners();
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  // ── Sign Out ───────────────────────────────────────────────
  Future<void> signOut(BuildContext context) async {
    try {
      await _supabase.auth.signOut();
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    } catch (e) {
      errorMessage = 'Sign out failed: $e';
      notifyListeners();
    }
  }

  // ── Delete Account ─────────────────────────────────────────
  Future<bool> deleteAccount(BuildContext context) async {
    try {
      isLoading = true;
      notifyListeners();

      final user = _supabase.auth.currentUser;
      if (user == null) return false;

      // Delete profile & preferences (cascade deletes handle the rest)
      await _supabase.from('profiles').delete().eq('id', user.id);
      await _supabase.auth.signOut();

      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      return true;
    } catch (e) {
      errorMessage = 'Failed to delete account: $e';
      notifyListeners();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }
}