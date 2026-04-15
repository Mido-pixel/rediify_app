import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationController extends ChangeNotifier {
  final _supabase = Supabase.instance.client;

  // ── State ──────────────────────────────────────────────────
  bool isLoading = false;
  String? errorMessage;

  List<Map<String, dynamic>> notifications = [];
  List<Map<String, dynamic>> unreadNotifications = [];

  String activeFilter = 'All'; // All, Unread, Music, Social
  final List<String> filters = ['All', 'Unread', 'Music', 'Social'];

  int get unreadCount => unreadNotifications.length;

  // ── Init ───────────────────────────────────────────────────
  Future<void> init() async {
    await fetchNotifications();
    _listenRealtime();
  }

  // ── Fetch ──────────────────────────────────────────────────
  Future<void> fetchNotifications() async {
    try {
      isLoading = true;
      notifyListeners();

      final user = _supabase.auth.currentUser;
      if (user == null) return;

      final response = await _supabase
          .from('notifications')
          .select('id, type, title, body, image_url, is_read, created_at, meta')
          .eq('user_id', user.id)
          .order('created_at', ascending: false)
          .limit(50);

      notifications = List<Map<String, dynamic>>.from(response);
      unreadNotifications = notifications
          .where((n) => n['is_read'] == false)
          .toList();
    } catch (e) {
      errorMessage = 'Failed to load notifications: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ── Realtime Listener ──────────────────────────────────────
  void _listenRealtime() {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    _supabase
        .channel('user_notifications')
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
            final newNotif = payload.newRecord;
            notifications.insert(0, newNotif);
            if (newNotif['is_read'] == false) {
              unreadNotifications.insert(0, newNotif);
            }
            notifyListeners();
          },
        )
        .subscribe();
  }

  // ── Mark Single as Read ────────────────────────────────────
  Future<void> markAsRead(String notificationId) async {
    try {
      await _supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('id', notificationId);

      final index = notifications.indexWhere((n) => n['id'] == notificationId);
      if (index != -1) {
        notifications[index]['is_read'] = true;
        unreadNotifications.removeWhere((n) => n['id'] == notificationId);
        notifyListeners();
      }
    } catch (e) {
      errorMessage = 'Failed to mark as read: $e';
      notifyListeners();
    }
  }

  // ── Mark All as Read ───────────────────────────────────────
  Future<void> markAllAsRead() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      await _supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', user.id)
          .eq('is_read', false);

      for (var n in notifications) {
        n['is_read'] = true;
      }
      unreadNotifications.clear();
      notifyListeners();
    } catch (e) {
      errorMessage = 'Failed to mark all as read: $e';
      notifyListeners();
    }
  }

  // ── Delete Notification ────────────────────────────────────
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _supabase
          .from('notifications')
          .delete()
          .eq('id', notificationId);

      notifications.removeWhere((n) => n['id'] == notificationId);
      unreadNotifications.removeWhere((n) => n['id'] == notificationId);
      notifyListeners();
    } catch (e) {
      errorMessage = 'Failed to delete notification: $e';
      notifyListeners();
    }
  }

  // ── Clear All ──────────────────────────────────────────────
  Future<void> clearAll() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      await _supabase
          .from('notifications')
          .delete()
          .eq('user_id', user.id);

      notifications.clear();
      unreadNotifications.clear();
      notifyListeners();
    } catch (e) {
      errorMessage = 'Failed to clear notifications: $e';
      notifyListeners();
    }
  }

  // ── Filter ─────────────────────────────────────────────────
  void setFilter(String filter) {
    activeFilter = filter;
    notifyListeners();
  }

  List<Map<String, dynamic>> get filteredNotifications {
    switch (activeFilter) {
      case 'Unread': return unreadNotifications;
      case 'Music':
        return notifications.where((n) => n['type'] == 'music').toList();
      case 'Social':
        return notifications.where((n) => n['type'] == 'social').toList();
      default: return notifications;
    }
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }
}