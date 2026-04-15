import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardController extends ChangeNotifier {
  final _supabase = Supabase.instance.client;

  // ── State ──────────────────────────────────────────────────
  int currentIndex = 0;
  bool hasUnreadNotifications = false;
  int unreadCount = 0;
  String? errorMessage;
  Map<String, dynamic>? currentUser;

  final List<String> tabRoutes = [
    '/home',
    '/search',
    '/library',
    '/profile',
  ];

  // ── Init ───────────────────────────────────────────────────
  Future<void> init() async {
    await Future.wait([
      fetchCurrentUser(),
      checkUnreadNotifications(),
    ]);
    _listenToNotifications();
  }

  // ── Current User ───────────────────────────────────────────
  Future<void> fetchCurrentUser() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      final response = await _supabase
          .from('profiles')
          .select('id, username, avatar_url, email')
          .eq('id', user.id)
          .single();

      currentUser = response;
      notifyListeners();
    } catch (e) {
      errorMessage = 'Failed to load user: $e';
      notifyListeners();
    }
  }

  // ── Tab Navigation ─────────────────────────────────────────
  void setIndex(int index) {
    if (currentIndex == index) return;
    currentIndex = index;
    notifyListeners();
  }

  // ── Notifications Badge ────────────────────────────────────
  Future<void> checkUnreadNotifications() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      final response = await _supabase
          .from('notifications')
          .select('id')
          .eq('user_id', user.id)
          .eq('is_read', false);

      unreadCount = response.length;
      hasUnreadNotifications = unreadCount > 0;
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to check notifications: $e');
    }
  }

  // ── Realtime Notification Listener ─────────────────────────
  void _listenToNotifications() {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    _supabase
        .channel('notifications')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: user.id,
          ),
          callback: (payload) {
            unreadCount++;
            hasUnreadNotifications = true;
            notifyListeners();
          },
        )
        .subscribe();
  }

  void markNotificationsRead() {
    unreadCount = 0;
    hasUnreadNotifications = false;
    notifyListeners();
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

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }
}