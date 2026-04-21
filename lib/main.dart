import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:volume_controller/volume_controller.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
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

  // ✅ Load .env
  await dotenv.load(fileName: '.env');

  // ✅ Init Supabase
  await Supabase.initialize(
    url:     dotenv.env['https://qhtqkpjgxjzqcpyknebv.supabase.co']!,
    anonKey: dotenv.env['eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFodHFrcGpneGp6cWNweWtuZWJ2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzYxNTM1ODYsImV4cCI6MjA5MTcyOTU4Nn0.udCTGKMbHFlJKMaqVklwlBp1x56udhY_164-3nPprvQ']!,
  );

  // ✅ Hide system volume popup
  VolumeController().showSystemUI = false;

  // ✅ Run app with MusicService provided
  runApp(
    ChangeNotifierProvider(
      create: (_) => MusicService(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'REdiify App',
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
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
          overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
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
      routes: {
        '/login':         (context) => const LoginScreen(),
        '/signup':        (context) => const SignUpScreen(),
        '/dashboard':     (context) => const DashboardScreen(),
        '/profile':       (context) => const ProfileScreen(),
        '/search':        (context) => const SearchScreen(),
        '/settings':      (context) => const SettingsScreen(),
        '/notifications': (context) => const NotificationsScreen(),
        '/nowplaying':    (context) => const NowPlayingScreen(),
      },
    );
  }
}