import 'package:flutter/material.dart';
import '../models/book.dart';

class BookPicker extends StatelessWidget {
  final List<Book> books;
  final void Function(Book) onSelect;

  const BookPicker({super.key, required this.books, required this.onSelect});

  static const _spacing = 8.0;
  static const _padding = 16.0;

  ({int columns, double tile}) _findBestFit(
    double availWidth,
    double availHeight,
  ) {
    var bestCols = 3;
    var bestTile = 0.0;

    for (var cols = 1; cols <= books.length; cols++) {
      final rows = (books.length / cols).ceil();
      final tileW = (availWidth - (cols - 1) * _spacing) / cols;
      final tileH = (availHeight - (rows - 1) * _spacing) / rows;
      final tile = tileW < tileH ? tileW : tileH;
      if (tile > bestTile) {
        bestTile = tile;
        bestCols = cols;
      }
    }
    return (columns: bestCols, tile: bestTile);
  }

  String _normalizeBookName(String name) {
    return name
        .replaceAllMapped(RegExp(r'\bI\b'), (m) => '1')
        .replaceAllMapped(RegExp(r'\bII\b'), (m) => '2')
        .replaceAllMapped(RegExp(r'\bIII\b'), (m) => '3');
  }

  String _abbreviate(String name) {
    final normalized = _normalizeBookName(name.trim());
    const abbreviations = {
      'Genesis': 'Gen',
      'Exodus': 'Exod',
      'Leviticus': 'Lev',
      'Numbers': 'Num',
      'Deuteronomy': 'Deut',
      'Joshua': 'Josh',
      'Judges': 'Judg',
      'Ruth': 'Ruth',
      '1 Samuel': '1 Sam',
      '2 Samuel': '2 Sam',
      '1 Kings': '1 Kgs',
      '2 Kings': '2 Kgs',
      '1 Chronicles': '1 Chr',
      '2 Chronicles': '2 Chr',
      'Ezra': 'Ezra',
      'Nehemiah': 'Neh',
      'Esther': 'Esth',
      'Job': 'Job',
      'Psalms': 'Ps',
      'Proverbs': 'Prov',
      'Ecclesiastes': 'Eccl',
      'Song of Solomon': 'Song',
      'Isaiah': 'Isa',
      'Jeremiah': 'Jer',
      'Lamentations': 'Lam',
      'Ezekiel': 'Ezek',
      'Daniel': 'Dan',
      'Hosea': 'Hos',
      'Joel': 'Joel',
      'Amos': 'Amos',
      'Obadiah': 'Obad',
      'Jonah': 'Jonah',
      'Micah': 'Mic',
      'Nahum': 'Nah',
      'Habakkuk': 'Hab',
      'Zephaniah': 'Zeph',
      'Haggai': 'Hag',
      'Zechariah': 'Zech',
      'Malachi': 'Mal',
      'Matthew': 'Matt',
      'Mark': 'Mark',
      'Luke': 'Luke',
      'John': 'John',
      'Acts': 'Acts',
      'Romans': 'Rom',
      '1 Corinthians': '1 Cor',
      '2 Corinthians': '2 Cor',
      'Galatians': 'Gal',
      'Ephesians': 'Eph',
      'Philippians': 'Phil',
      'Colossians': 'Col',
      '1 Thessalonians': '1 Thess',
      '2 Thessalonians': '2 Thess',
      '1 Timothy': '1 Tim',
      '2 Timothy': '2 Tim',
      'Titus': 'Titus',
      'Philemon': 'Phlm',
      'Hebrews': 'Heb',
      'James': 'Jas',
      '1 Peter': '1 Pet',
      '2 Peter': '2 Pet',
      '1 John': '1 John',
      '2 John': '2 John',
      '3 John': '3 John',
      'Jude': 'Jude',
      'Rev': 'Rev',
      'Revelation of John': 'Rev',
    };
    return abbreviations[normalized] ?? name.substring(0, name.length.clamp(0, 4));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select a Book'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(_padding),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final availWidth = constraints.maxWidth;
            final availHeight = constraints.maxHeight;

            final best = _findBestFit(availWidth, availHeight);

            return CustomScrollView(
              slivers: [
                SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: best.columns,
                    childAspectRatio: 1.0,
                    mainAxisSpacing: _spacing,
                    crossAxisSpacing: _spacing,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final book = books[index];
                      final abbreviated = _abbreviate(book.name);
                      return _BookTile(
                        text: abbreviated,
                        onTap: () => onSelect(book),
                        semanticsLabel: book.name,
                      );
                    },
                    childCount: books.length,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _BookTile extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final String semanticsLabel;

  const _BookTile({
    required this.text,
    required this.onTap,
    required this.semanticsLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Semantics(
          label: semanticsLabel,
          child: Center(
            child: Text(
              text,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
