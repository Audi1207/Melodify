import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/player_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/main_screen.dart';

void main() {
  runApp(const MelodifyApp());
}

class MelodifyApp extends StatelessWidget {
  const MelodifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      // Daftarkan semua provider yang akan digunakan di seluruh app
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PlayerProvider()),
      ],
      child: MaterialApp(
        title: 'Melodify',
        debugShowCheckedModeBanner: false,
        // Tema dark seperti Spotify
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF121212),
          primaryColor: const Color(0xFF1DB954), // Hijau Melodify
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF1DB954),
            secondary: Color(0xFF1DB954),
            surface: Color(0xFF282828),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF121212),
            elevation: 0,
          ),
          textTheme: const TextTheme(
            bodyMedium: TextStyle(color: Colors.white),
            bodyLarge: TextStyle(color: Colors.white),
          ),
        ),
        home: const AppWrapper(),
      ),
    );
  }
}

// AppWrapper memeriksa apakah user sudah login
class AppWrapper extends StatefulWidget {
  const AppWrapper({super.key});

  @override
  State<AppWrapper> createState() => _AppWrapperState();
}

class _AppWrapperState extends State<AppWrapper> {
  @override
  void initState() {
    super.initState();
    // Load data user dari storage lokal saat app dibuka
    context.read<AuthProvider>().loadUser();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    // Jika user sudah login → pergi ke halaman utama
    // Jika belum → pergi ke halaman login
    if (authProvider.isLoggedIn) {
      return const MainScreen();
    } else {
      return const LoginScreen();
    }
  }
}
