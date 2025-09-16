import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';

// IMPORTANT: Replace this with your actual Supabase URL and anon key
// You can find these values in your Supabase project dashboard under Settings > API
final supabaseUrl = 'https://htqshywwbcmvuhwcaoaz.supabase.co';
final supabaseKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imh0cXNoeXd3YmNtdnVod2Nhb2F6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTgwMjQ1NTMsImV4cCI6MjA3MzYwMDU1M30.84_Hs9D5I7flJHT_hOWIknKwIdT93PP7mmLLaaI8-xk';
// For production, use this instead and pass values via --dart-define:
// final supabaseUrl = const String.fromEnvironment('SUPABASE_URL');
// final supabaseKey = const String.fromEnvironment('SUPABASE_KEY');

// Create a global Supabase client instance for easy access
late final SupabaseClient supabase;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseKey,
    debug: true, // Set to false in production
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
      home: const LoginScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
