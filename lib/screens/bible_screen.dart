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
            if (context.mounted) {
              _showChapterPicker(bookName: book.name);
            }
          },
        ),
      ),
    );
  }

  void _showChapterPicker({String? bookName}) {
    final resolvedBook = _bibleService.findBook(bookName ?? _bookName);
    final chapters = resolvedBook?.chapters ?? [];
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

  String _bookAbbreviation(String name) {
    final normalized = name.trim().toLowerCase();
    return _abbreviations[normalized] ??
        name.substring(0, name.length.clamp(0, 4));
  }

  void _showSettingsMenu(BuildContext context, RenderBox button) {
    if (!context.mounted) return;
    final position = button.localToGlobal(Offset.zero);

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy + button.size.height,
        position.dx,
        MediaQuery.of(context).size.height - position.dy - button.size.height,
      ),
      items: [
        const PopupMenuItem<String>(
          value: 'settings',
          child: Row(
            children: [
              Icon(Icons.settings, size: 20),
              SizedBox(width: 12),
              Text('Settings'),
            ],
          ),
        ),
      ],
    ).then((value) {
      if (!context.mounted) return;
      if (value == 'settings') {
        Navigator.of(context).pushNamed('/settings');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$_bookName Chapter $_chapterNum'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _verses.length,
                    itemBuilder: (context, index) {
                      final verse = _verses[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: RichText(
                          text: TextSpan(
                            text: '${verse.verse} ',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1565C0),
                            ),
                            children: [
                              TextSpan(text: verse.text),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                _buildBottomNav(),
              ],
            ),
    );
  }

  Widget _buildBottomNav() {
    final abbr = _bookAbbreviation(_bookName);
    final prevDisabled = _chapterNum <= 1;
    final nextDisabled =
        _chapterNum >= _bibleService.getChapterCount(_bookName);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Left: Book abbreviation
            Expanded(
              child: _NavButton(
                text: abbr,
                onTap: _showBookPicker,
                alignment: Alignment.centerLeft,
              ),
            ),
            const SizedBox(width: 8),
            // Center: Prev, Chapter, Next
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _NavIconButton(
                  icon: Icons.chevron_left,
                  onPressed: prevDisabled ? null : () => _changeChapter(-1),
                ),
                const SizedBox(width: 8),
                _NavButton(text: '$_chapterNum', onTap: _showChapterPicker),
                const SizedBox(width: 8),
                _NavIconButton(
                  icon: Icons.chevron_right,
                  onPressed: nextDisabled ? null : () => _changeChapter(1),
                ),
              ],
            ),
            const SizedBox(width: 8),
            // Right: Menu button
            Expanded(
              child: _MenuIconButton(
                icon: Icons.menu,
                alignment: Alignment.centerRight,
                onMenuTap: _showSettingsMenu,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final AlignmentGeometry alignment;

  const _NavButton({
    required this.text,
    this.onTap,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: alignment,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
      ),
    );
  }
}

class _NavIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _NavIconButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon),
      onPressed: onPressed,
    );
  }
}

class _MenuIconButton extends StatefulWidget {
  final IconData icon;
  final void Function(BuildContext, RenderBox) onMenuTap;
  final AlignmentGeometry alignment;

  const _MenuIconButton({
    required this.icon,
    required this.onMenuTap,
    this.alignment = Alignment.center,
  });

  @override
  State<_MenuIconButton> createState() => _MenuIconButtonState();
}

class _MenuIconButtonState extends State<_MenuIconButton> {
  final GlobalKey _buttonKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: widget.alignment,
      child: IconButton(
        key: _buttonKey,
        icon: Icon(widget.icon),
        onPressed: () {
          final renderBox =
              _buttonKey.currentContext?.findRenderObject() as RenderBox?;
          if (renderBox != null) {
            widget.onMenuTap(context, renderBox);
          }
        },
      ),
    );
  }
}

const _abbreviations = {
  'genesis': 'Gen',
  'exodus': 'Exod',
  'leviticus': 'Lev',
  'numbers': 'Num',
  'deuteronomy': 'Deut',
  'joshua': 'Josh',
  'judges': 'Judg',
  'ruth': 'Ruth',
  '1 samuel': '1 Sam',
  '2 samuel': '2 Sam',
  '1 kings': '1 Kgs',
  '2 kings': '2 Kgs',
  '1 chronicles': '1 Chr',
  '2 chronicles': '2 Chr',
  'ezra': 'Ezra',
  'nehemiah': 'Neh',
  'esther': 'Esth',
  'job': 'Job',
  'psalms': 'Ps',
  'proverbs': 'Prov',
  'ecclesiastes': 'Eccl',
  'song of solomon': 'Song',
  'isaiah': 'Isa',
  'jeremiah': 'Jer',
  'lamentations': 'Lam',
  'ezekiel': 'Ezek',
  'daniel': 'Dan',
  'hosea': 'Hos',
  'joel': 'Joel',
  'amos': 'Amos',
  'obadiah': 'Obad',
  'jonah': 'Jonah',
  'micah': 'Mic',
  'nahum': 'Nah',
  'habakkuk': 'Hab',
  'zephaniah': 'Zeph',
  'haggai': 'Hag',
  'zechariah': 'Zech',
  'malachi': 'Mal',
  'matthew': 'Matt',
  'mark': 'Mark',
  'luke': 'Luke',
  'john': 'John',
  'acts': 'Acts',
  'romans': 'Rom',
  '1 corinthians': '1 Cor',
  '2 corinthians': '2 Cor',
  'galatians': 'Gal',
  'ephesians': 'Eph',
  'philippians': 'Phil',
  'colossians': 'Col',
  '1 thessalonians': '1 Thess',
  '2 thessalonians': '2 Thess',
  '1 timothy': '1 Tim',
  '2 timothy': '2 Tim',
  'titus': 'Titus',
  'philemon': 'Phlm',
  'hebrews': 'Heb',
  'james': 'Jas',
  '1 peter': '1 Pet',
  '2 peter': '2 Pet',
  '1 john': '1 John',
  '2 john': '2 John',
  '3 john': '3 John',
  'jude': 'Jude',
  'revelation': 'Rev',
};
