# Fix Bible Book Abbreviations — Plan

## Analysis
BSB.json stores book names with **Roman numerals** but the abbreviations map uses **digits**. Lookup fails, falls back to `substring(0, 4)` which produces bad output:
- `"I Samuel"` → `"I Sam"` (should be `"1 Sam"`)
- `"I John"` → `"I Jo"` (should be `"1 John"`)
- `"III John"` → `"III "` (should be `"3 John"`)
- `"Revelation of John"` → `"Reve"` (should be `"Rev"`)

16 book names use Roman numerals in BSB.json: `I Samuel`, `II Samuel`, `I Kings`, `II Kings`, `I Chronicles`, `II Chronicles`, `I Corinthians`, `II Corinthians`, `I Thessalonians`, `II Thessalonians`, `I Timothy`, `II Timothy`, `I Peter`, `II Peter`, `I John`, `II John`, `III John`, `Revelation of John`.

## Changes Required

### File: `lib/screens/book_picker.dart`

1. **Add Roman numeral normalizer** — new private helper that converts Roman numerals to digits:
   ```dart
   String _normalizeBookName(String name) {
     return name
       .replaceAllMapped(RegExp(r'\bI\b'), (m) => '1')
       .replaceAllMapped(RegExp(r'\bII\b'), (m) => '2')
       .replaceAllMapped(RegExp(r'\bIII\b'), (m) => '3');
   }
   ```
   Then call `_normalizeBookName(trimmed)` before lookup in `abbreviations`.

2. **Add `Revelation of John` entry** to the abbreviations map:
   ```dart
   'Revelation of John': 'Rev',
   ```

3. **Fix layout measurement** — remove `statusBarHeight` and `appBarHeight` from the height calculation. The `LayoutBuilder` is inside `Scaffold.body` so the app bar is already accounted for. Wrap `CustomScrollView` in `Padding` instead:
   ```dart
   final availHeight = constraints.maxHeight;
   // remove: statusBarHeight - appBarHeight - _padding * 2
   ```
   And wrap the CustomScrollView in a Padding widget with `_padding`.

## Verification
- `dart analyze` — clean
- `flutter test` — passes
- Manual check: "III John" → "3 John", "I Samuel" → "1 Sam", "Revelation of John" → "Rev"
