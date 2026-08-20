# bible_app - AGENTS.md

## Quick Start
```bash
flutter pub get
flutter run
flutter analyze
flutter test
```

## Overview
Offline Bible reader (BSB translation) with Abbott commentary, built with
Flutter (Material 3). No network access: all data ships as JSON assets.
Three bottom-nav tabs — Bible, Commentary, Settings — kept alive in an
`IndexedStack`.

## Project Structure
- `lib/main.dart` — entry point; `MultiProvider` setup, `BibleApp` shell with
  `NavigationBar` + `IndexedStack` (Bible / Commentary / Settings). Watches
  `CommentaryProvider.requestedTabIndex` to switch tabs for cross-tab jumps.
  `main()` awaits `ThemeProvider.init()` before `runApp`.
- `lib/models/` — `Book`, `Chapter`, `Verse` (fromJson; `Verse.toCanonical()`
  returns `"Book C:V"`)
- `lib/services/`
  - `bible_service.dart` — loads/parses BSB.json into memory; `findBook()`
    normalizes case and Roman/Arabic numerals
  - `scripture_parser.dart` — parses refs like "1 Cor. 10:1", "John 1:31-34",
    "John 7:50, 51, 19"; large abbreviation map (Arabic + Roman input forms);
    `linkifyReferences()` wraps plain refs in `bible://` markdown links
  - `commentary_service.dart` — loads a commentary JSON (flat map or
    `{"commentary": ...}` wrapper) into a string cache keyed by canonical refs
  - `bible_jump_service.dart` — `BibleJumpRequest` value class; currently
    unused (jumps flow through `CommentaryProvider.pendingBibleRef`)
- `lib/providers/`
  - `commentary_provider.dart` — active source, reference selection, cross-tab
    jump requests (`pendingBibleRef` / `requestedTabIndex`)
  - `theme_provider.dart` — `ThemeMode` persisted in shared_preferences
    (key `theme_mode`)
- `lib/screens/` — `BibleScreen`, `BookPicker`, `ChapterPicker`,
  `CommentaryScreen`, `SettingsScreen`
- `lib/data/commentary_sources.dart` — `CommentarySource` list (currently:
  Abbott → `assets/commentary/abbott_bsb.json`)
- `assets/bible/BSB.json` — BSB Bible, `{"books": [...]}`, 66 books, ~194k lines
- `assets/commentary/abbott_bsb.json` — Abbott commentary keyed by canonical
  refs (e.g. `"Genesis 1:1"`)
- `assets/commentary/abbott.json` — legacy source file, present on disk but
  NOT declared in pubspec (not bundled)
- `test/` — `widget_test.dart` (app renders), `scripture_parser_test.dart`
  (parse + equality cases)
- `temp/Abbott/` — source material + `convert.dart` tooling; not part of the app

## Data Model
- `Book{name, chapters: List<Chapter>}`
- `Chapter{chapter, name, verses: List<Verse>}`
- `Verse{verse, chapter, name, text}` — `name` is the book name exactly as
  stored in BSB.json, which uses Roman numerals ("I Corinthians", "III John")
  and "Revelation of John"
- Canonical ref format: `Book Chapter:Verse` (e.g. `Genesis 1:1`)
- Genesis chapter 1 loads on first app launch

## Key Flows
- Tap a verse in the Bible tab → `CommentaryProvider.showReference(ref)` +
  SnackBar; the Commentary tab shows the entry for that ref (if any).
- Tap a commentary ref header, or an in-text `bible://` link →
  `requestBibleJump(ref)` sets `pendingBibleRef` + `requestedTabIndex = 0`;
  the shell switches to the Bible tab; `BibleScreen.didChangeDependencies`
  then jumps: parse → `findBook` → load chapter → scroll to verse (centered
  in viewport) → highlight for 5 s.
- Book/chapter pickers are pushed as routes and return the selection.
- Settings: theme dropdown (system/light/dark, persisted) and Quit.

## Services API
- `BibleService`: `load()`, `books`, `findBook(name)`,
  `normalizeBookName(name)`, `getChapter(book, n)`, `getVerses(book, n)`,
  `getChapterCount(book)`, `getChapters(book)`
- `ScriptureParser`: `parse(text)` → `ScriptureReference{book, chapter,
  verses} | null` (chapter-only refs have empty `verses`), `toCanonical()`,
  `linkifyReferences(text)`
- `CommentaryService`: `load()`, `isLoaded`, `cache` (`Map<String, String>`)
- `CommentaryProvider`: `loadSource()`, `setSource()`, `activeSourceName`,
  `availableSources`, `isLoaded`, `hasCommentaryFor(ref)`,
  `getCommentaryText(ref)`, `availableReferences` (sorted in biblical order),
  `showReference(ref)`, `requestBibleJump(ref)`, `clearPendingBibleRef()`,
  `clear()`, `pendingBibleRef`, `requestedTabIndex`

## Gotchas
- BSB book names use Roman numerals; `ScriptureParser` emits Arabic numerals
  for Arabic input ("1 Corinthians"). `BibleService.findBook` normalizes both
  sides (leading I/II/III → 1/2/3) and maps "Revelation" → "Revelation of
  John". Do not "fix" either side to match the other — the parser tests
  assert the Arabic-numeral output.
- Commentary keys and verse refs must stay in canonical `Book C:V` form or
  `hasCommentaryFor` / lookups silently miss.
- `bible_jump_service.dart` is dead code; prefer `CommentaryProvider`
  jump requests.
- Lint config: `flutter_lints` via `analysis_options.yaml`.
- `opencode.json` configures a local LLM (Qwen3.6-35B-A3B-Q8_0 via
  llama-server at `http://127.0.0.1:8080/v1`) — dev tooling only.
- No CI, no pre-commit hooks, no monorepo structure.
- State management: `provider` (ChangeNotifier) plus `setState` in screens.
- Dependencies: `provider`, `shared_preferences`, `flutter_markdown`, `xml`,
  `cupertino_icons`.

## Conventions
- Standard Flutter conventions, `flutter_lints` only.
- No custom fonts or platform-specific overrides.
