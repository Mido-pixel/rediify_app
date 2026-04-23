import 'package:flutter/material.dart';

enum NotificationType { newSong, newArtist, playlist, system, like }

class AppNotification {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime time;
  bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.time,
    this.isRead = false,
  });
}

class NotificationsController extends ChangeNotifier {
  final List<AppNotification> _notifications = [
    AppNotification(id: '1', title: "New Release 🎵",
        message: "Wizkid just dropped a new song — 'Kese'. Listen now!",
        type: NotificationType.newSong,
        time: DateTime.now().subtract(const Duration(minutes: 5))),
    AppNotification(id: '2', title: "Artist You Follow",
        message: "Drake released a new album 'For All The Dogs'.",
        type: NotificationType.newArtist,
        time: DateTime.now().subtract(const Duration(hours: 1))),
    AppNotification(id: '3', title: "Playlist Updated",
        message: "Your 'Afrobeats Vibes' playlist has 3 new songs.",
        type: NotificationType.playlist,
        time: DateTime.now().subtract(const Duration(hours: 3))),
    AppNotification(id: '4', title: "Someone Liked Your Playlist ❤️",
        message: "Your playlist 'Late Night R&B' got a new like.",
        type: NotificationType.like,
        time: DateTime.now().subtract(const Duration(hours: 5)),
        isRead: true),
    AppNotification(id: '5', title: "Welcome to REdiify! 🎉",
        message: "Your account is set up. Start exploring music now.",
        type: NotificationType.system,
        time: DateTime.now().subtract(const Duration(days: 1)),
        isRead: true),
    AppNotification(id: '6', title: "New Song Recommendation",
        message: "Based on your listening — try 'Burna Boy Mix'.",
        type: NotificationType.newSong,
        time: DateTime.now().subtract(const Duration(days: 1)),
        isRead: true),
    AppNotification(id: '7', title: "System Update",
        message: "REdiify has been updated to v1.1.0. See what's new.",
        type: NotificationType.system,
        time: DateTime.now().subtract(const Duration(days: 2)),
        isRead: true),
  ];

  List<AppNotification> get all          => _notifications;
  List<AppNotification> get unread       => _notifications.where((n) => !n.isRead).toList();
  List<AppNotification> get read         => _notifications.where((n) => n.isRead).toList();
  int  get unreadCount => unread.length;
  bool get hasUnread   => unread.isNotEmpty;

  void markAsRead(String id) {
    _notifications.firstWhere((n) => n.id == id).isRead = true;
    notifyListeners();
  }
  void markAllAsRead()         { for (final n in _notifications) n.isRead = true; notifyListeners(); }
  void deleteNotification(String id) { _notifications.removeWhere((n) => n.id == id); notifyListeners(); }
  void clearAll()              { _notifications.clear(); notifyListeners(); }

  String timeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) return "${diff.inMinutes}m ago";
    if (diff.inHours < 24)   return "${diff.inHours}h ago";
    return "${diff.inDays}d ago";
  }

  IconData iconFor(NotificationType type) {
    switch (type) {
      case NotificationType.newSong:   return Icons.music_note;
      case NotificationType.newArtist: return Icons.person;
      case NotificationType.playlist:  return Icons.queue_music;
      case NotificationType.like:      return Icons.favorite;
      case NotificationType.system:    return Icons.info;
    }
  }

  Color colorFor(NotificationType type) {
    switch (type) {
      case NotificationType.newSong:   return const Color(0xFFE8173A);
      case NotificationType.newArtist: return Colors.orange;
      case NotificationType.playlist:  return Colors.blue;
      case NotificationType.like:      return Colors.pink;
      case NotificationType.system:    return Colors.grey;
    }
  }
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  final NotificationsController _controller = NotificationsController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => Scaffold(
        backgroundColor: const Color(0xFF0A0A0A),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0A0A0A),
          elevation: 0,
          // ── ← Back arrow ──────────────────────────────
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new,
                color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: Row(children: [
            const Text("Notifications",
                style: TextStyle(color: Colors.white,
                    fontWeight: FontWeight.w800, fontSize: 18)),
            if (_controller.hasUnread) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                    color: const Color(0xFFE8173A),
                    borderRadius: BorderRadius.circular(12)),
                child: Text("${_controller.unreadCount}",
                    style: const TextStyle(color: Colors.white, fontSize: 12)),
              ),
            ],
          ]),
          actions: [
            if (_controller.hasUnread)
              TextButton(
                onPressed: _controller.markAllAsRead,
                child: const Text("Mark all read",
                    style: TextStyle(color: Color(0xFFE8173A))),
              ),
            IconButton(
              icon: const Icon(Icons.delete_sweep, color: Colors.grey),
              onPressed: _confirmClearAll,
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: const Color(0xFFE8173A),
            labelColor: const Color(0xFFE8173A),
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Text("Unread"),
                if (_controller.hasUnread) ...[
                  const SizedBox(width: 6),
                  Container(width: 8, height: 8,
                      decoration: const BoxDecoration(
                          color: Color(0xFFE8173A), shape: BoxShape.circle)),
                ],
              ])),
              const Tab(text: "All"),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildList(_controller.unread, emptyMessage: "You're all caught up! 🎉"),
            _buildList(_controller.all,    emptyMessage: "No notifications yet"),
          ],
        ),
      ),
    );
  }

  Widget _buildList(List<AppNotification> notifications, {required String emptyMessage}) {
    if (notifications.isEmpty) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.notifications_off, color: Colors.grey, size: 60),
        const SizedBox(height: 12),
        Text(emptyMessage, style: const TextStyle(color: Colors.grey, fontSize: 16)),
      ]));
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: notifications.length,
      itemBuilder: (_, i) => _NotificationTile(
          notification: notifications[i], controller: _controller),
    );
  }

  void _confirmClearAll() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Clear All", style: TextStyle(color: Colors.white)),
        content: const Text("Delete all notifications?",
            style: TextStyle(color: Colors.grey)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel", style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () { _controller.clearAll(); Navigator.pop(ctx); },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE8173A)),
            child: const Text("Clear All"),
          ),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final AppNotification notification;
  final NotificationsController controller;
  const _NotificationTile({required this.notification, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: const Color(0xFFE8173A),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => controller.deleteNotification(notification.id),
      child: GestureDetector(
        onTap: () => controller.markAsRead(notification.id),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: notification.isRead
                ? const Color(0xFF1A1A1A)
                : const Color(0xFFE8173A).withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: notification.isRead
                ? null
                : Border.all(color: const Color(0xFFE8173A).withOpacity(0.3)),
          ),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: controller.colorFor(notification.type).withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(controller.iconFor(notification.type),
                  color: controller.colorFor(notification.type), size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Expanded(child: Text(notification.title,
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: notification.isRead
                              ? FontWeight.normal : FontWeight.bold,
                          fontSize: 14),
                      maxLines: 1, overflow: TextOverflow.ellipsis)),
                  Text(controller.timeAgo(notification.time),
                      style: const TextStyle(color: Colors.grey, fontSize: 11)),
                ]),
                const SizedBox(height: 4),
                Text(notification.message,
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                    maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
            )),
            // ── › forward arrow ──────────────────────────
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: Colors.white24, size: 20),
            if (!notification.isRead)
              Container(
                margin: const EdgeInsets.only(left: 4, top: 4),
                width: 8, height: 8,
                decoration: const BoxDecoration(
                    color: Color(0xFFE8173A), shape: BoxShape.circle),
              ),
          ]),
        ),
      ),
    );
  }
}