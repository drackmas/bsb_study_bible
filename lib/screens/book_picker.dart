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
      'Joshua': 'Josh',
      'Judges': 'Judg',
      'Ruth': 'Ruth',
      '1 Samuel': '1 Sam',
      '2 Samuel': '2 Sam',
      '1 Kings': '1 Kgs',
      '2 Kings': '2 Kgs',
      '1 Chronicles': '1 Chron',
      '2 Chronicles': '2 Chron',
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
      'Philemon': 'Philem',
      'Hebrews': 'Heb',
      'James': 'Jas',
      '1 Peter': '1 Pet',
      '2 Peter': '2 Pet',
      '1 John': '1 John',
      '2 John': '2 John',
      '3 John': '3 John',
      'Jude': 'Jude',
      'Revelation': 'Rev',
    };
    return abbreviations[name] ?? name.substring(0, name.length.clamp(0, 4));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      height: 400,
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
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
