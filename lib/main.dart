import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:volume_controller/volume_controller.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
// Screens
import 'login_screen.dart';
import 'signup_screen.dart';
import 'dashboard_screen.dart';
import 'profile_screen.dart';
import 'search_screen.dart';
import 'setting_screen.dart';
import 'now_playing_screen.dart';
import 'notification_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  await Supabase.initialize(
    url:     dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  VolumeController().showSystemUI = false;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {        // ✅ StatelessWidget — no volume state needed
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'REdiify App',

      // ── App Theme ─────────────────────────────────────────────
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
            fontWeight: FontWeight.w600,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor:      Color(0xFF1A1A1A),
          selectedItemColor:    Color(0xFFE8173A),
          unselectedItemColor:  Color(0xFF535353),
          selectedLabelStyle:   TextStyle(
              fontWeight: FontWeight.w700, fontSize: 11),
          unselectedLabelStyle: TextStyle(fontSize: 11),
          type: BottomNavigationBarType.fixed,
        ),
      ),

      initialRoute: '/login',

      // ── Routes ────────────────────────────────────────────────
      routes: {
        '/login':         (context) => const LoginScreen(),
        '/signup':        (context) => const SignUpScreen(),
        '/dashboard':     (context) => const DashboardScreen(),
        '/profile':       (context) => const ProfileScreen(),
        '/search':        (context) => const SearchScreen(),
        '/settings':      (context) => const SettingsScreen(),
        '/notifications': (context) => const NotificationsScreen(),
        '/nowplaying':    (context) => const NowPlayingScreen(), // ✅ no params
      },
    );
  }
}