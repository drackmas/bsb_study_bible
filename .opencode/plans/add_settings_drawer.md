# Add Hamburger Menu Settings Item — Plan

## Analysis
The `BibleScreen` in `lib/screens/bible_screen.dart` uses a `Scaffold` (line 102) with only a `body`. There is no `drawer` property set. The app has a `/settings` route defined in `main.dart` that navigates to `SettingsScreen`.

## Change

### File: `lib/screens/bible_screen.dart`

Add a `drawer` property to the existing `Scaffold` widget (line 102).

```dart
Scaffold(
  drawer: Drawer(
    child: Column(
      children: [
        DrawerHeader(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
          ),
          child: Text(
            'Bible App',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              fontSize: 24,
            ),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.settings),
          title: const Text('Settings'),
          onTap: () {
            Navigator.pop(context);
            Navigator.of(context).pushNamed('/settings');
          },
        ),
      ],
    ),
  ),
  body: ...
),
```

No other files are modified. The existing styling, spacing, theme, and typography are preserved — the drawer uses theme colors from `Theme.of(context)`.

## Verification
- `dart analyze` — clean
- `flutter test` — passes
- Hamburger menu appears on left swipe / tap area
- Settings row shows `Icons.settings` on leading side with "Settings" label
- Tapping Settings navigates to `/settings`
- No "Dev" item present
