import 'package:flutter/material.dart';
import '../services/commentary_service.dart';
import '../data/commentary_sources.dart';

class CommentaryProvider extends ChangeNotifier {
  final List<CommentarySource> sources;
  late CommentaryService _service;
  CommentarySource _activeSource;

  String _selectedReference = '';
  String _commentaryText = '';
  bool _isLoading = false;
  bool _hasError = false;
  String? _errorMessage;

  // Navigation helpers
  String? _pendingBibleRef;
  int? _requestedTabIndex;

  // Canonical biblical order
  static const List<String> _biblicalOrder = [
    'Genesis', 'Exodus', 'Leviticus', 'Numbers', 'Deuteronomy',
    'Joshua', 'Judges', 'Ruth', '1 Samuel', '2 Samuel',
    '1 Kings', '2 Kings', '1 Chronicles', '2 Chronicles',
    'Ezra', 'Nehemiah', 'Esther', 'Job', 'Psalms', 'Proverbs',
    'Ecclesiastes', 'Song of Solomon', 'Isaiah', 'Jeremiah',
    'Lamentations', 'Ezekiel', 'Daniel', 'Hosea', 'Joel',
    'Amos', 'Obadiah', 'Jonah', 'Micah', 'Nahum', 'Habakkuk',
    'Zephaniah', 'Haggai', 'Zechariah', 'Malachi',
    'Matthew', 'Mark', 'Luke', 'John', 'Acts',
    'Romans', '1 Corinthians', '2 Corinthians', 'Galatians',
    'Ephesians', 'Philippians', 'Colossians',
    '1 Thessalonians', '2 Thessalonians',
    '1 Timothy', '2 Timothy', 'Titus', 'Philemon',
    'Hebrews', 'James', '1 Peter', '2 Peter',
    '1 John', '2 John', '3 John', 'Jude', 'Revelation',
  ];

  CommentaryProvider({List<CommentarySource>? sourceList})
      : sources = sourceList ?? commentarySources,
        _activeSource = (sourceList ?? commentarySources).first {
    _service = CommentaryService(source: _activeSource);
    loadSource();
  }

  // Getters
  String get activeSourceName => _activeSource.name;
  String get selectedReference => _selectedReference;
  String get commentaryText => _commentaryText;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String? get errorMessage => _errorMessage;
  List<CommentarySource> get availableSources => sources;
  bool get isLoaded => _service.isLoaded;

  String? get pendingBibleRef => _pendingBibleRef;
  int? get requestedTabIndex => _requestedTabIndex;

  Future<void> loadSource() async {
    _isLoading = true;
    _hasError = false;
    notifyListeners();

    try {
      await _service.load();
    } catch (e) {
      _hasError = true;
      _errorMessage = 'Failed to load ${_activeSource.name}';
    }

    _isLoading = false;
    notifyListeners();
  }

  void setSource(CommentarySource source) {
    if (_activeSource.id == source.id) return;
    _activeSource = source;
    _service = CommentaryService(source: source);
    _selectedReference = '';
    _commentaryText = '';
    loadSource();
  }

  bool hasCommentaryFor(String canonicalRef) {
    return _service.isLoaded && _service.getCommentary(canonicalRef) != null;
  }

  String? getCommentaryText(String canonicalRef) {
    return _service.getCommentary(canonicalRef);
  }

  /// Returns references sorted in proper biblical order
  List<String> get availableReferences {
    if (!_service.isLoaded) return [];

    final refs = _service.cache.keys.toList();

    refs.sort((a, b) {
      final parsedA = _parseRef(a);
      final parsedB = _parseRef(b);

      if (parsedA == null && parsedB == null) return a.compareTo(b);
      if (parsedA == null) return 1;
      if (parsedB == null) return -1;

      // Compare book order
      final bookIndexA = _biblicalOrder.indexOf(parsedA.book);
      final bookIndexB = _biblicalOrder.indexOf(parsedB.book);

      if (bookIndexA != bookIndexB) {
        // Unknown books go to the end
        if (bookIndexA == -1) return 1;
        if (bookIndexB == -1) return -1;
        return bookIndexA.compareTo(bookIndexB);
      }

      // Same book → compare chapter
      if (parsedA.chapter != parsedB.chapter) {
        return parsedA.chapter.compareTo(parsedB.chapter);
      }

      // Same chapter → compare first verse
      final verseA = parsedA.verses.isNotEmpty ? parsedA.verses.first : 0;
      final verseB = parsedB.verses.isNotEmpty ? parsedB.verses.first : 0;
      return verseA.compareTo(verseB);
    });

    return refs;
  }

  _ParsedRef? _parseRef(String ref) {
    // Simple parser for "Book Chapter:Verse" or "Book Chapter:Verse-Verse"
    final match = RegExp(
      r'^(.+?)\s+(\d+)(?::(\d+)(?:[-–](\d+))?)?$',
      caseSensitive: false,
    ).firstMatch(ref.trim());

    if (match == null) return null;

    final book = match.group(1)!.trim();
    final chapter = int.tryParse(match.group(2)!) ?? 1;
    final startVerse = int.tryParse(match.group(3) ?? '1') ?? 1;
    final endVerse = int.tryParse(match.group(4) ?? '') ?? startVerse;

    return _ParsedRef(
      book: book,
      chapter: chapter,
      verses: [startVerse, if (endVerse != startVerse) endVerse],
    );
  }

  Future<void> showReference(String canonicalRef) async {
    _selectedReference = canonicalRef;
    _isLoading = true;
    _hasError = false;
    notifyListeners();

    try {
      if (!_service.isLoaded) await loadSource();
      final text = _service.getCommentary(canonicalRef);
      _commentaryText = text ?? 'No commentary available for this reference.';
    } catch (e) {
      _hasError = true;
      _errorMessage = 'Error loading commentary';
      _commentaryText = '';
    }

    _isLoading = false;
    notifyListeners();
  }

  void requestBibleJump(String canonicalRef) {
    _pendingBibleRef = canonicalRef;
    _requestedTabIndex = 0; // Bible tab
    notifyListeners();
  }

  void clearPendingBibleRef() {
    _pendingBibleRef = null;
    _requestedTabIndex = null;
  }

  void clear() {
    _selectedReference = '';
    _commentaryText = '';
    _hasError = false;
    _errorMessage = null;
    notifyListeners();
  }
}

class _ParsedRef {
  final String book;
  final int chapter;
  final List<int> verses;

  _ParsedRef({
    required this.book,
    required this.chapter,
    required this.verses,
  });
}
