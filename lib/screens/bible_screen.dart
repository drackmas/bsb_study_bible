import 'package:flutter/material.dart';
import '../models/verse.dart';
import '../services/bible_service.dart';
import 'book_picker.dart';
import 'chapter_picker.dart';

class BibleScreen extends StatefulWidget {
  const BibleScreen({super.key});

  @override
  State<BibleScreen> createState() => _BibleScreenState();
}

class _BibleScreenState extends State<BibleScreen> {
  final _bibleService = BibleService();
  late String _bookName = 'Genesis';
  late int _chapterNum = 1;
  late List<Verse> _verses;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBible();
  }

  Future<void> _loadBible() async {
    try {
      await _bibleService.load();
      if (mounted) {
        _loadChapter();
        setState(() {
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        _verses = [];
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _loadChapter() {
    _verses = _bibleService.getVerses(_bookName, _chapterNum);
    setState(() {});
  }

  void _changeChapter(int delta) {
    final total = _bibleService.getChapterCount(_bookName);
    final next = _chapterNum + delta;
    if (next >= 1 && next <= total) {
      setState(() {
        _chapterNum = next;
      });
      _loadChapter();
    }
  }

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

  void _showChapterPicker() {
    final book = _bibleService.findBook(_bookName);
    final chapters = book?.chapters ?? [];
    showModalBottomSheet(
      context: context,
      builder: (context) => ChapterPicker(
        chapters: chapters,
        currentChapter: _chapterNum,
        onSelect: (chapter) {
          setState(() {
            _chapterNum = chapter.chapter;
          });
          _loadChapter();
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildTopBar(),
                Expanded(
                  child: _verses.isEmpty
                      ? const Center(child: Text('No verses loaded'))
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _verses.length,
                          itemBuilder: (context, index) {
                            final verse = _verses[index];
                            return _buildVerse(verse, index);
                          },
                        ),
                ),
                _buildBottomBar(),
              ],
            ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: _showBookPicker,
              child: Text(
                _bookName,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildVerse(Verse verse, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            fontSize: 16,
            height: 1.6,
            color: Color(0xFF212121),
          ),
          children: [
            TextSpan(
              text: '${verse.verse} ',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF1565C0),
              ),
            ),
            TextSpan(text: verse.text),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: _chapterNum > 1 ? () => _changeChapter(-1) : null,
          ),
          GestureDetector(
            onTap: _showChapterPicker,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$_chapterNum',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: _chapterNum < _bibleService.getChapterCount(_bookName)
                ? () => _changeChapter(1)
                : null,
          ),
        ],
      ),
    );
  }
}
