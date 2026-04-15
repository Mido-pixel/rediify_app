import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashController extends ChangeNotifier {
  final _supabase = Supabase.instance.client;

  // ── State ──────────────────────────────────────────────────
  bool isLoading = true;
  String statusMessage = 'Loading...';
  double progress = 0.0;

  // ── Init & Route ───────────────────────────────────────────
  Future<void> initialize(BuildContext context) async {
    try {
      await _step('Initializing app...', 0.2, milliseconds: 400);
      await _step('Checking connection...', 0.5, milliseconds: 500);
      await _checkSupabaseConnection();
      await _step('Restoring session...', 0.8, milliseconds: 400);
      await _step('Almost ready...', 1.0, milliseconds: 300);

      final session = _supabase.auth.currentSession;

      if (session != null && !_isSessionExpired(session)) {
        await _refreshSessionIfNeeded(session);
        _navigate(context, '/dashboard');
      } else {
        _navigate(context, '/login');
      }
    } catch (e) {
      statusMessage = 'Something went wrong. Retrying...';
      notifyListeners();
      await Future.delayed(const Duration(seconds: 2));
      _navigate(context, '/login');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ── Step Helper ────────────────────────────────────────────
  Future<void> _step(String message, double value, {int milliseconds = 500}) async {
    statusMessage = message;
    progress = value;
    notifyListeners();
    await Future.delayed(Duration(milliseconds: milliseconds));
  }

  // ── Connection Check ───────────────────────────────────────
  Future<void> _checkSupabaseConnection() async {
    try {
      await _supabase.from('profiles').select('id').limit(1);
    } catch (_) {
      // Supabase may be unreachable — continue anyway
      debugPrint('Supabase unreachable, continuing offline...');
    }
  }

  // ── Session Helpers ────────────────────────────────────────
  bool _isSessionExpired(Session session) {
    final expiry = DateTime.fromMillisecondsSinceEpoch(
        session.expiresAt! * 1000);
    return DateTime.now().isAfter(expiry);
  }

  Future<void> _refreshSessionIfNeeded(Session session) async {
    try {
      final expiry = DateTime.fromMillisecondsSinceEpoch(
          session.expiresAt! * 1000);
      final timeLeft = expiry.difference(DateTime.now());

      // Refresh if less than 5 minutes left
      if (timeLeft.inMinutes < 5) {
        await _supabase.auth.refreshSession();
      }
    } catch (e) {
      debugPrint('Session refresh failed: $e');
    }
  }

  // ── Navigate ───────────────────────────────────────────────
  void _navigate(BuildContext context, String route) {
    if (!context.mounted) return;
    Navigator.pushReplacementNamed(context, route);
  }
}