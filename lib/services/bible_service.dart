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

  Book? findBook(String name) {
    try {
      return _books.firstWhere(
        (b) => b.name.toLowerCase() == name.toLowerCase(),
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
