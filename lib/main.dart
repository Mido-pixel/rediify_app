import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'services/music_service.dart';
import 'package:volume_controller/volume_controller.dart'
    if (dart.library.html) 'volume_stub.dart';

import 'login_screen.dart';
import 'signup_screen.dart';
import 'home_screen.dart';
import 'library_screen.dart';
import 'playlist_screen.dart';
import 'profile_screen.dart';
import 'search_screen.dart';
import 'setting_screen.dart';
import 'now_playing_screen.dart';
import 'notification_screen.dart';
import 'dashboard_screen.dart';

// ── Conditional import: web gets a no-op stub, mobile gets real plugin ──────
import 'package:volume_controller/volume_controller.dart'
    if (dart.library.html) 'volume_stub.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://qhtqkpjgxjzqcpyknebv.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFodHFrcGpneGp6cWNweWtuZWJ2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzYxNTM1ODYsImV4cCI6MjA5MTcyOTU4Nn0.udCTGKMbHFlJKMaqVklwlBp1x56udhY_164-3nPprvQ',
  );

  if (!kIsWeb) {
    try {
      VolumeController().showSystemUI = false;
    } catch (_) {}
  }

  runApp(
    ChangeNotifierProvider(
      create: (_) => MusicService(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  double _volume = 0.5;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      try {
        VolumeController().listener((v) {
          if (mounted) setState(() => _volume = v);
        });
        VolumeController().getVolume().then((v) {
          if (mounted) setState(() => _volume = v);
        });
      } catch (_) {
        // MissingPluginException on simulator/web — ignored safely
      }
    }
  }

  @override
  void dispose() {
    if (!kIsWeb) {
      try {
        VolumeController().removeListener();
      } catch (_) {}
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'REdiify',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFE8173A),
          secondary: Color(0xFF1DB954),
        ),
      ),
      initialRoute: '/login',
      routes: {
        '/login':         (ctx) => const LoginScreen(),
        '/signup':        (ctx) => const SignUpScreen(),
        '/home':          (ctx) => const HomeScreen(),
        '/dashboard':     (ctx) => const DashboardScreen(),
        '/library':       (ctx) => const LibraryScreen(),
        '/playlists':     (ctx) => const PlaylistsScreen(),
        '/profile':       (ctx) => const ProfileScreen(),
        '/search':        (ctx) => const SearchScreen(),
        '/settings':      (ctx) => const SettingsScreen(),
        '/notifications': (ctx) => const NotificationsScreen(),
        '/nowplaying': (ctx) => NowPlayingScreen(
              volume: _volume,
              onVolumeChanged: (v) {
                setState(() => _volume = v);
                if (!kIsWeb) {
                  try {
                    VolumeController().setVolume(v);
                  } catch (_) {}
                }
              },
            ),
      },
    );
  }
}