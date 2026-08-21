import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

import '../models/verse.dart';
import '../models/book.dart';
import '../models/chapter.dart';
import '../services/bible_service.dart';
import '../providers/commentary_provider.dart';
import '../screens/book_picker.dart';
import '../screens/chapter_picker.dart';
import '../services/scripture_parser.dart';

class BibleScreen extends StatefulWidget {
  const BibleScreen({super.key});

  @override
  State<BibleScreen> createState() => _BibleScreenState();
}

class _BibleScreenState extends State<BibleScreen> {
  final _bibleService = BibleService();
  final _scrollController = ScrollController();
  String _bookName = 'Genesis';
  int _chapterNum = 1;
  List<Verse> _verses = [];
  bool _isLoading = true;

  // Highlight state
  int? _highlightedVerse;
  Timer? _highlightTimer;

  // Keys for each verse item
  final Map<int, GlobalKey> _verseKeys = {};

  /// Jump deferred until the Bible data finishes loading, if a commentary
  /// link was tapped before that happened.
  String? _pendingJumpRef;

  @override
  void initState() {
    super.initState();
    _loadBible();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _highlightTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final provider = context.watch<CommentaryProvider>();
    final pending = provider.pendingBibleRef;

    if (pending != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _jumpToReference(pending);
        provider.clearPendingBibleRef();
      });
    }
  }

  Future<void> _loadBible() async {
    try {
      await _bibleService.load();
      if (mounted) {
        _loadChapter();
        setState(() => _isLoading = false);
        final pendingJump = _pendingJumpRef;
        _pendingJumpRef = null;
        if (pendingJump != null) {
          _jumpToReference(pendingJump);
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _verses = [];
          _isLoading = false;
        });
      }
    }
  }

  void _loadChapter() {
    _clearHighlight();
    _verses = _bibleService.getVerses(_bookName, _chapterNum);
    _verseKeys.clear();
    for (final verse in _verses) {
      _verseKeys[verse.verse] = GlobalKey();
    }
    setState(() {});
  }

  void _clearHighlight() {
    _highlightTimer?.cancel();
    _highlightTimer = null;
    if (mounted) {
      setState(() => _highlightedVerse = null);
    }
  }

  void _highlightVerse(int verseNum) {
    _clearHighlight();
    
    if (mounted) {
      setState(() => _highlightedVerse = verseNum);
    }

    _highlightTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() => _highlightedVerse = null);
      }
    });
  }

  Future<void> _scrollToVerse(int verseNum) async {
    final key = _verseKeys[verseNum];
    if (key == null) return;

    final renderObject = key.currentContext?.findRenderObject() as RenderBox?;
    if (renderObject == null) return;

    final scrollPosition = _scrollController.position;

    // Find the enclosing viewport. (Context-based lookups like
    // Scrollable.of() don't work here: this state's context is above the
    // list, and Scrollable.of only searches ancestors.)
    final viewport = RenderAbstractViewport.maybeOf(renderObject) as RenderBox?;
    if (viewport == null) return;

    // Distance from the top of the viewport to the top of the verse row.
    final verseTop = renderObject.localToGlobal(Offset.zero).dy;
    final viewportTop = viewport.localToGlobal(Offset.zero).dy;
    final verseOffsetInViewport = verseTop - viewportTop;

    // Center the verse row vertically within the viewport.
    final targetOffset = scrollPosition.pixels +
        verseOffsetInViewport -
        (scrollPosition.viewportDimension / 2) +
        (renderObject.size.height / 2);

    await scrollPosition.animateTo(
      targetOffset.clamp(0.0, scrollPosition.maxScrollExtent),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _jumpToReference(String canonicalRef) async {
    if (!_bibleService.isLoaded) {
      // Bible data still loading; run the jump once it is ready.
      _pendingJumpRef = canonicalRef;
      return;
    }

    final parser = ScriptureParser();
    final ref = parser.parse(canonicalRef);
    if (ref == null) return;

    final book = _bibleService.findBook(ref.book);
    if (book == null) return;

    setState(() {
      _bookName = book.name;
      _chapterNum = ref.chapter;
    });
    _loadChapter();

    // Wait for verses to load, then scroll to and highlight
    await Future.delayed(const Duration(milliseconds: 100));

    if (!mounted) return;

    // Find the first verse in the reference (could be multiple)
    final firstVerse = ref.verses.isNotEmpty ? ref.verses.first : 1;

    await _scrollToVerse(firstVerse);
    _highlightVerse(firstVerse);
  }

  void _onVerseTap(String canonicalRef) {
    final provider = context.read<CommentaryProvider>();
    provider.showReference(canonicalRef);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opened $canonicalRef in Commentary'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _openBookPicker() async {
    final books = _bibleService.books;
    final result = await Navigator.push<Book>(
      context,
      MaterialPageRoute(
        builder: (context) => BookPicker(books: books),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _bookName = result.name;
        _chapterNum = 1;
      });
      _loadChapter();
    }
  }

  Future<void> _openChapterPicker() async {
    final chapters = _bibleService.getChapters(_bookName);
    if (chapters.isEmpty) return;

    final result = await Navigator.push<Chapter>(
      context,
      MaterialPageRoute(
        builder: (context) => ChapterPicker(
          chapters: chapters,
          currentChapter: _chapterNum,
          onSelect: (chapter) => Navigator.pop(context, chapter),
        ),
      ),
    );

    if (result != null && mounted) {
      setState(() => _chapterNum = result.chapter);
      _loadChapter();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CommentaryProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: InkWell(
          onTap: _openBookPicker,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _bookName,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const Icon(Icons.arrow_drop_down, size: 20),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            tooltip: 'Previous chapter',
            onPressed: _chapterNum > 1
                ? () {
                    setState(() => _chapterNum--);
                    _loadChapter();
                  }
                : null,
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            tooltip: 'Next chapter',
            onPressed: () {
              final max = _bibleService.getChapterCount(_bookName);
              if (_chapterNum < max) {
                setState(() => _chapterNum++);
                _loadChapter();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.menu_book),
            tooltip: 'Select chapter',
            onPressed: _openChapterPicker,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _verses.isEmpty
              ? const Center(child: Text('No verses available'))
              : ListView(
                  // Eager (non-lazy) list: chapters are short (max 176 verses),
                  // and building every row keeps each verse's GlobalKey attached
                  // so _scrollToVerse can always locate and center the target.
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                  children: List.generate(_verses.length, (index) {
                    final verse = _verses[index];
                    final canonicalRef = verse.toCanonical();
                    final hasCommentary =
                        provider.hasCommentaryFor(canonicalRef);
                    final isHighlighted = _highlightedVerse == verse.verse;

                    return AnimatedContainer(
                      key: _verseKeys[verse.verse],
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      decoration: BoxDecoration(
                        color: isHighlighted
                            ? colorScheme.primary.withValues(alpha: 0.15)
                            : null,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: InkWell(
                        onTap: () => _onVerseTap(canonicalRef),
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 4,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 36,
                                child: Text(
                                  '${verse.verse}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: isHighlighted
                                        ? colorScheme.primary
                                        : colorScheme.secondary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      verse.text,
                                      style: TextStyle(
                                        fontSize: 16.5,
                                        height: 1.55,
                                        color: colorScheme.onSurface,
                                      ),
                                    ),
                                    if (hasCommentary) ...[
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.auto_awesome,
                                            size: 13,
                                            color: colorScheme.primary,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Commentary available',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: colorScheme.primary,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
    );
  }
}
