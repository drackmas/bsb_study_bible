# Bible App Book Picker Full-Page Menu

## Problem
The book picker screen currently displays as a modal bottom sheet with a fixed height of 400 pixels, requiring scrolling to see all 66 Bible books.

## Solution

### 1. Rewrite `lib/screens/book_picker.dart`
- Change from a Container with fixed height to a full-page Scaffold
- Wrap the GridView in an Expanded widget to fill available space
- Add a proper AppBar with title

```dart
import 'package:flutter/material.dart';
import '../models/book.dart';

class BookPicker extends StatelessWidget {
  final List<Book> books;
  final void Function(Book) onSelect;

  const BookPicker({super.key, required this.books, required this.onSelect});

  String _abbreviate(String name) {
    const abbreviations = {
      'Genesis': 'Gen',
      'Exodus': 'Ex',
      'Leviticus': 'Lev',
      'Numbers': 'Num',
      'Deuteronomy': 'Deut',
      // ... (keep existing abbreviations)
      'Revelation': 'Rev',
    };
    return abbreviations[name] ?? name.substring(0, name.length.clamp(0, 4));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select a Book'),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: books.length,
        itemBuilder: (context, index) {
          final book = books[index];
          final abbreviated = _abbreviate(book.name);
          return Material(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => onSelect(book),
              child: Center(
                child: Text(
                  abbreviated,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
```

### 2. Rewrite `lib/screens/bible_screen.dart`
The current file is corrupted with merged methods. Rewrite with:
- Proper `_buildTopBar()` method
- Proper `_buildBottomBar()` method  
- Proper `_buildVerse()` method
- Change `_showBookPicker()` to push MaterialPageRoute instead of showModalBottomSheet

```dart
void _showBookPicker() {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => BookPicker(
        books: _bibleService.books,
        onSelect: (book) {
          setState(() {
            _bookName = book.name;
            _chapterNum = 1;
          });
          _loadChapter();
          Navigator.pop(context);
        },
      ),
    ),
  );
}
```

### 3. Test Changes
- Run `flutter analyze` to verify no lint errors
- Run `flutter test` to ensure tests pass
- Verify the book picker shows all 66 books on a full screen

## Files to Modify
1. `lib/screens/book_picker.dart` - Convert to full-page Scaffold
2. `lib/screens/bible_screen.dart` - Fix corrupted methods, change navigation to MaterialPageRoute

## Grid Layout Consideration
With 66 books and a 3-column grid, there will be 22 rows. This fits comfortably on most mobile screens without scrolling. A 2-column grid would give 33 rows which might require scrolling on smaller screens. 3 columns is the optimal balance.
