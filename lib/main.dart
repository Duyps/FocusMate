import 'package:flashcard/page/home_screen.dart';
import 'package:flashcard/page/login_screen.dart';
import 'package:flashcard/page/settings_provider.dart';
import 'package:flashcard/page/settings_screen.dart';
import 'package:flashcard/page/stats_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
//import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    ChangeNotifierProvider(
      create: (_) => SettingsProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: settings.darkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        // 👉 Đổi màu chủ đạo ở đây (VD: xanh dương)
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue, // 🔄 Đổi thành màu bạn thích
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF9F9F9),
      ),
      darkTheme: ThemeData.dark(useMaterial3: true),

      home: const HomeScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/stats': (context) => const StatsScreen(),
      },
    );
  }
}
