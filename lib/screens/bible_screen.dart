import 'package:flutter/material.dart';
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
  String _bookName = 'Genesis';
  int _chapterNum = 1;
  List<Verse> _verses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBible();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // React to jump requests coming from Commentary
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
    _verses = _bibleService.getVerses(_bookName, _chapterNum);
    setState(() {});
  }

  void _jumpToReference(String canonicalRef) {
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
    final colorScheme = Theme.of(context).colorScheme;
    final provider = context.watch<CommentaryProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: _openBookPicker,
              child: Text(
                _bookName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: _openChapterPicker,
              child: Text(
                '$_chapterNum',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(width: 2),
            Icon(
              Icons.arrow_drop_down,
              size: 22,
              color: colorScheme.onSurface,
            ),
          ],
        ),
        centerTitle: true,
        elevation: 0,
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
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _verses.isEmpty
              ? const Center(child: Text('No verses available'))
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                  itemCount: _verses.length,
                  itemBuilder: (context, index) {
                    final verse = _verses[index];
                    final canonicalRef = verse.toCanonical();
                    final hasCommentary =
                        provider.hasCommentaryFor(canonicalRef);

                    return InkWell(
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
                                  color: colorScheme.secondary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                    );
                  },
                ),
    );
  }
}
