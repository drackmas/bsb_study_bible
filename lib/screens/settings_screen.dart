import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ListTile(
              title: const Text('Theme'),
              subtitle: Text(_label(themeProvider.themeMode)),
              trailing: DropdownButton<ThemeMode>(
                value: themeProvider.themeMode,
                items: const [
                  DropdownMenuItem(value: ThemeMode.system, child: Text('Default')),
                  DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
                  DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
                ],
                onChanged: (mode) {
                  if (mode != null) {
                    themeProvider.setThemeMode(mode);
                  }
                },
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
              child: const Text('Quit'),
            ),
          ],
        ),
      ),
    );
  }

  String _label(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'Default';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
    }
  }
}
