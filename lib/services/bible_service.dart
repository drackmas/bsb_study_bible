import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/book.dart';
import '../models/chapter.dart';
import '../models/verse.dart';

class BibleService {
  List<Book> _books = [];
  bool _loaded = false;

  Future<void> load() async {
    if (_loaded) return;
    final raw = await rootBundle.loadString('assets/bible/BSB.json');
    final data = jsonDecode(raw) as Map<String, dynamic>;
    final booksJson = data['books'] as List<dynamic>;
    _books = booksJson
        .map((b) => Book.fromJson(b as Map<String, dynamic>))
        .toList();
    _loaded = true;
  }

  List<Book> get books => _books;

  /// Normalizes a book name for comparison: trims, lowercases, collapses
  /// whitespace, converts a leading Roman numeral (I/II/III) to Arabic,
  /// and maps the "Revelation" abbreviation to BSB's "Revelation of John".
  static String normalizeBookName(String name) {
    var result = name.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
    final roman = RegExp(r'^(i{1,3})\b').firstMatch(result);
    if (roman != null) {
      final arabic = switch (roman.group(1)!) {
        'i' => '1',
        'ii' => '2',
        _ => '3',
      };
      result = '$arabic${result.substring(roman.end)}';
    }
    if (result == 'revelation') {
      result = 'revelation of john';
    }
    return result;
  }

  /// Finds a book by name. Case-insensitive and tolerant of Roman/Arabic
  /// numeral differences (e.g. "1 Corinthians" matches BSB's "I Corinthians").
  Book? findBook(String name) {
    final query = normalizeBookName(name);
    try {
      return _books.firstWhere(
        (b) => normalizeBookName(b.name) == query,
      );
    } catch (_) {
      return null;
    }
  }

  Chapter? getChapter(String bookName, int chapterNum) {
    final book = findBook(bookName);
    if (book == null) return null;
    try {
      return book.chapters.firstWhere(
        (c) => c.chapter == chapterNum,
      );
    } catch (_) {
      return null;
    }
  }

  List<Verse> getVerses(String bookName, int chapterNum) {
    final chapter = getChapter(bookName, chapterNum);
    if (chapter == null) return [];
    return chapter.verses;
  }

  int getChapterCount(String bookName) {
    final book = findBook(bookName);
    if (book == null) return 0;
    return book.chapters.length;
  }

  List<Chapter> getChapters(String bookName) {
    final book = findBook(bookName);
    if (book == null) return [];
    return book.chapters;
  }
}
