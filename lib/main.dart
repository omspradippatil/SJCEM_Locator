import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';

// IMPORTANT: Replace with your actual Supabase URL and anon key
final supabaseUrl = 'https://htqshywwbcmvuhwcaoaz.supabase.co';
final supabaseKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imh0cXNoeXd3YmNtdnVod2Nhb2F6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTgwMjQ1NTMsImV4cCI6MjA3MzYwMDU1M30.84_Hs9D5I7flJHT_hOWIknKwIdT93PP7mmLLaaI8-xk';

late final SupabaseClient supabase;

// Global user session
class UserSession {
  static String? currentUserId;
  static String? currentUserRole; // 'Student', 'Faculty', 'HOD'
  static String? currentUserName;
  static String? currentDepartment;
  static bool isLoggedIn = false;

  static void setSession({
    required String userId,
    required String role,
    required String name,
    required String department,
  }) {
    currentUserId = userId;
    currentUserRole = role;
    currentUserName = name;
    currentDepartment = department;
    isLoggedIn = true;
  }

  static void clearSession() {
    currentUserId = null;
    currentUserRole = null;
    currentUserName = null;
    currentDepartment = null;
    isLoggedIn = false;
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseKey,
    debug: true,
  );

  supabase = Supabase.instance.client;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SJCEM Navigator',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
      ),
      // Start with HomeScreen (Navigator accessible without login)
      home: const HomeScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
