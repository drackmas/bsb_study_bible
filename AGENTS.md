# bible_app - AGENTS.md

## Quick Start
```bash
flutter pub get
flutter run
flutter analyze
flutter test
```

## Project Structure
- `lib/main.dart` — app entry point
- `lib/models/` — data models (Book, Chapter, Verse)
- `lib/services/` — BibleService for loading data
- `lib/screens/` — BibleScreen, BookPicker, ChapterPicker, SettingsScreen
- `assets/bible/BSB.json` — Bible data (194,080 lines, 66 books)

## Data Model
- `Book{name, chapters: List<Chapter>}`
- `Chapter{chapter, name, verses: List<Verse>}`
- `Verse{verse, chapter, name, text}`
- BSB.json structure: `{"books": [...]}`
- Genesis 1:1 appears on first app launch

## BibleService API
- `load()` — loads BSB.json from assets
- `books` — getter for all books
- `findBook(String)` — find book by name (case-insensitive)
- `getVerses(bookName, chapterNum)` — get verses for a chapter
- `getChapterCount(bookName)` — total chapters in a book
- `getChapter(bookName, chapterNum)` — get a specific chapter

## Navigation Routes
- `/` — BibleScreen (home)
- `/settings` — SettingsScreen

## Gotchas
- `pubspec.yaml` has `assets/bible/BSB.json` declared
- Lint config: `flutter_lints/flutter.yaml`
- `opencode.json` configures Qwen3.6-35B-A3B-Q8_0 via llama-server at `http://127.0.0.1:8080/v1`
- No CI, no pre-commit hooks, no monorepo structure
- State management: default `setState` pattern
- No state management package used

## Conventions
- Standard Flutter conventions
- `flutter_lints` only
- No custom fonts or platform-specific overrides
