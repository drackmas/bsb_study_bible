import 'package:flutter/material.dart';
import 'screens/bible_screen.dart';
import 'screens/settings_screen.dart';

void main() {
  runApp(const BibleApp());
}

class BibleApp extends StatelessWidget {
  const BibleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bible App',
      theme: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const BibleScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}
