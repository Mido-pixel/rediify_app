import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:volume_controller/volume_controller.dart';
import 'services/music_service.dart';
// Screens
import 'login_screen.dart';
import 'signup_screen.dart';
import 'dashboard_screen.dart';
import 'profile_screen.dart';
import 'search_screen.dart';
import 'setting_screen.dart';
import 'now_playing_screen.dart';
import 'notification_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();


  await Supabase.initialize(
    url:     'https://qhtqkpjgxjzqcpyknebv.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFodHFrcGpneGp6cWNweWtuZWJ2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzYxNTM1ODYsImV4cCI6MjA5MTcyOTU4Nn0.udCTGKMbHFlJKMaqVklwlBp1x56udhY_164-3nPprvQ',
  );

  VolumeController().showSystemUI = false;         // ✅ hide system volume popup

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
    // ✅ Listen for hardware volume button changes
    VolumeController().listener((volume) {
      if (mounted) setState(() => _volume = volume);
    });
    // ✅ Get current device volume on startup
    VolumeController().getVolume().then((volume) {
      if (mounted) setState(() => _volume = volume);
    });
  }

  @override
  void dispose() {
    VolumeController().removeListener();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'REdiify App',

      // ── App Theme ───────────────────────────────────────────
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        colorScheme: const ColorScheme.dark(
          primary:   Color(0xFFE8173A),
          secondary: Color(0xFF1DB954),
        ),
        sliderTheme: SliderThemeData(
          activeTrackColor:   const Color(0xFFE8173A),
          inactiveTrackColor: Colors.white24,
          thumbColor:         Colors.white,
          overlayColor:       Colors.white12,
          trackHeight:        3,
          thumbShape: const RoundSliderThumbShape(
              enabledThumbRadius: 6),
          overlayShape: const RoundSliderOverlayShape(
              overlayRadius: 14),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor:      Color(0xFF1A1A1A),
          selectedItemColor:    Color(0xFFE8173A),
          unselectedItemColor:  Color(0xFF535353),
          selectedLabelStyle:
              TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
          unselectedLabelStyle: TextStyle(fontSize: 11),
          type: BottomNavigationBarType.fixed,
        ),
      ),

      initialRoute: '/login',

      // ── Routes ──────────────────────────────────────────────
      routes: {
        '/login':         (context) => const LoginScreen(),
        '/signup':        (context) => const SignUpScreen(),
        '/dashboard':     (context) => const DashboardScreen(),
        '/profile':       (context) => const ProfileScreen(),
        '/search':        (context) => const SearchScreen(),
        '/settings':      (context) => const SettingsScreen(),
        '/notifications': (context) => const NotificationsScreen(),
        '/nowplaying':    (context) => NowPlayingScreen(   // ✅ passes volume
              volume: _volume,
              onVolumeChanged: (v) {
                setState(() => _volume = v);
                VolumeController().setVolume(v);
              },
            ),
      },
    );
  }
}