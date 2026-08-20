import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
import 'screens/bible_screen.dart';
import 'screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final themeProvider = ThemeProvider();
  await themeProvider.init();
  runApp(
    ChangeNotifierProvider(
      create: (_) => themeProvider,
      child: const BibleApp(),
    ),
  );
}

class BibleApp extends StatelessWidget {
  const BibleApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bible App',
      themeMode: themeProvider.themeMode,
      theme: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      darkTheme: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.dark,
        ),
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
