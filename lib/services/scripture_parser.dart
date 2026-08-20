import 'dart:convert';
import 'package:flutter/services.dart';

class ScriptureReference {
  final String book;
  final int chapter;
  final List<int> verses;

  const ScriptureReference({
    required this.book,
    required this.chapter,
    required this.verses,
  });

  String toCanonical() {
    if (verses.isEmpty) {
      return '$book $chapter';
    }

    return '$book $chapter:${verses.join(',')}';
  }

  @override
  String toString() => toCanonical();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ScriptureReference &&
        other.book == book &&
        other.chapter == chapter &&
        listEquals(other.verses, verses);
  }

  @override
  int get hashCode {
    final versesHash = verses.fold<int>(0, (prev, elem) => prev ^ elem.hashCode);
    return Object.hash(book, chapter, versesHash);
  }
}

bool listEquals(List<int> a, List<int> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

class ScriptureParser {
  static const Map<String, String> _bookAbbreviations = {
    // ============================================================
    // OLD TESTAMENT
    // ============================================================

    'gen': 'Genesis',
    'ge': 'Genesis',
    'gn': 'Genesis',

    'ex': 'Exodus',
    'exod': 'Exodus',
    'exo': 'Exodus',

    'lev': 'Leviticus',
    'le': 'Leviticus',
    'lv': 'Leviticus',

    'num': 'Numbers',
    'nu': 'Numbers',
    'nm': 'Numbers',

    'deut': 'Deuteronomy',
    'de': 'Deuteronomy',
    'dt': 'Deuteronomy',

    'josh': 'Joshua',
    'jos': 'Joshua',
    'jsh': 'Joshua',

    'judg': 'Judges',
    'jdg': 'Judges',
    'jg': 'Judges',

    'ruth': 'Ruth',
    'ru': 'Ruth',

    '1 sam': '1 Samuel',
    '1 sa': '1 Samuel',
    '1sm': '1 Samuel',
    '1 samuel': '1 Samuel',
    'i sam': 'I Samuel',
    'i sa': 'I Samuel',
    'i samuel': 'I Samuel',

    '2 sam': '2 Samuel',
    '2 sa': '2 Samuel',
    '2sm': '2 Samuel',
    '2 samuel': '2 Samuel',
    'ii sam': 'II Samuel',
    'ii sa': 'II Samuel',
    'ii samuel': 'II Samuel',

    '1 kgs': '1 Kings',
    '1 ki': '1 Kings',
    '1kg': '1 Kings',
    '1 kings': '1 Kings',
    'i kgs': 'I Kings',
    'i ki': 'I Kings',
    'i kings': 'I Kings',

    '2 kgs': '2 Kings',
    '2 ki': '2 Kings',
    '2kg': '2 Kings',
    '2 kings': '2 Kings',
    'ii kgs': 'II Kings',
    'ii ki': 'II Kings',
    'ii kings': 'II Kings',

    '1 chr': '1 Chronicles',
    '1 ch': '1 Chronicles',
    '1 chronicles': '1 Chronicles',
    'i chr': 'I Chronicles',
    'i ch': 'I Chronicles',
    'i chronicles': 'I Chronicles',

    '2 chr': '2 Chronicles',
    '2 ch': '2 Chronicles',
    '2 chronicles': '2 Chronicles',
    'ii chr': 'II Chronicles',
    'ii ch': 'II Chronicles',
    'ii chronicles': 'II Chronicles',

    'ezra': 'Ezra',
    'ezr': 'Ezra',

    'neh': 'Nehemiah',
    'ne': 'Nehemiah',

    'est': 'Esther',
    'esth': 'Esther',
    'es': 'Esther',

    'job': 'Job',

    'ps': 'Psalms',
    'psa': 'Psalms',
    'psalm': 'Psalms',
    'psalms': 'Psalms',
    'pss': 'Psalms',

    'prov': 'Proverbs',
    'pr': 'Proverbs',
    'prv': 'Proverbs',

    'eccl': 'Ecclesiastes',
    'eccles': 'Ecclesiastes',
    'ecc': 'Ecclesiastes',

    'song': 'Song of Solomon',
    'sos': 'Song of Solomon',
    'so': 'Song of Solomon',
    'song of solomon': 'Song of Solomon',

    'isa': 'Isaiah',
    'is': 'Isaiah',
    'isaiah': 'Isaiah',

    'jer': 'Jeremiah',
    'je': 'Jeremiah',
    'jeremy': 'Jeremiah',
    'jeremiah': 'Jeremiah',

    'lam': 'Lamentations',
    'la': 'Lamentations',

    'ezek': 'Ezekiel',
    'eze': 'Ezekiel',
    'ezk': 'Ezekiel',

    'dan': 'Daniel',
    'da': 'Daniel',
    'dn': 'Daniel',

    'hos': 'Hosea',
    'ho': 'Hosea',

    'joel': 'Joel',
    'jl': 'Joel',

    'amos': 'Amos',
    'am': 'Amos',

    'obad': 'Obadiah',
    'ob': 'Obadiah',

    'jonah': 'Jonah',
    'jon': 'Jonah',

    'mic': 'Micah',
    'mi': 'Micah',
    'micah': 'Micah',

    'nah': 'Nahum',
    'na': 'Nahum',

    'hab': 'Habakkuk',
    'hb': 'Habakkuk',

    'zeph': 'Zephaniah',
    'zep': 'Zephaniah',

    'hag': 'Haggai',
    'hg': 'Haggai',

    'zech': 'Zechariah',
    'zec': 'Zechariah',
    'zc': 'Zechariah',

    'mal': 'Malachi',
    'ml': 'Malachi',

    // ============================================================
    // NEW TESTAMENT
    // ============================================================

    'matt': 'Matthew',
    'mat': 'Matthew',
    'mt': 'Matthew',
    'matthew': 'Matthew',

    'mark': 'Mark',
    'mk': 'Mark',
    'mr': 'Mark',

    'luke': 'Luke',
    'lk': 'Luke',
    'lu': 'Luke',

    'john': 'John',
    'jn': 'John',
    'joh': 'John',

    'acts': 'Acts',
    'ac': 'Acts',

    'rom': 'Romans',
    'ro': 'Romans',
    'rm': 'Romans',

    '1 cor': '1 Corinthians',
    '1 co': '1 Corinthians',
    '1cor': '1 Corinthians',
    '1 corinthians': '1 Corinthians',
    'i cor': 'I Corinthians',
    'i corinthians': 'I Corinthians',

    '2 cor': '2 Corinthians',
    '2 co': '2 Corinthians',
    '2cor': '2 Corinthians',
    '2 corinthians': '2 Corinthians',
    'ii cor': 'II Corinthians',
    'ii corinthians': 'II Corinthians',

    'gal': 'Galatians',
    'ga': 'Galatians',

    'eph': 'Ephesians',
    'ep': 'Ephesians',

    'phil': 'Philippians',
    'php': 'Philippians',
    'ph': 'Philippians',

    'col': 'Colossians',
    'co': 'Colossians',

    '1 thess': '1 Thessalonians',
    '1 th': '1 Thessalonians',
    '1thess': '1 Thessalonians',
    '1 thessalonians': '1 Thessalonians',
    'i thess': 'I Thessalonians',
    'i th': 'I Thessalonians',
    'ithess': 'I Thessalonians',
    'i thessalonians': 'I Thessalonians',

    '2 thess': '2 Thessalonians',
    '2 th': '2 Thessalonians',
    '2thess': '2 Thessalonians',
    '2 thessalonians': '2 Thessalonians',
    'ii thess': 'II Thessalonians',
    'ii th': 'II Thessalonians',
    'iithess': 'II Thessalonians',
    'ii thessalonians': 'II Thessalonians',

    '1 tim': '1 Timothy',
    '1 ti': '1 Timothy',
    '1tim': '1 Timothy',
    '1 timothy': '1 Timothy',
    'i tim': 'I Timothy',
    'i ti': 'I Timothy',
    'itim': 'I Timothy',
    'i timothy': 'I Timothy',

    '2 tim': '2 Timothy',
    '2 ti': '2 Timothy',
    '2tim': '2 Timothy',
    '2 timothy': '2 Timothy',
    'ii tim': 'II Timothy',
    'ii ti': 'II Timothy',
    'iitim': 'II Timothy',
    'ii timothy': 'II Timothy',

    'titus': 'Titus',
    'tit': 'Titus',

    'phlm': 'Philemon',
    'phm': 'Philemon',
    'philemon': 'Philemon',

    'heb': 'Hebrews',
    'he': 'Hebrews',
    'hebrews': 'Hebrews',

    'james': 'James',
    'jas': 'James',
    'jm': 'James',

    '1 pet': '1 Peter',
    '1 pe': '1 Peter',
    '1pt': '1 Peter',
    '1 peter': '1 Peter',
    'i pet': 'I Peter',
    'i pe': 'I Peter',
    'ipt': 'I Peter',
    'i peter': 'I Peter',

    '2 pet': '2 Peter',
    '2 pe': '2 Peter',
    '2pt': '2 Peter',
    '2 peter': '2 Peter',
    'ii pet': 'II Peter',
    'ii pe': 'II Peter',
    'iipet': 'II Peter',
    'ii peter': 'II Peter',

    '1 john': '1 John',
    '1 jn': '1 John',
    '1jo': '1 John',
    'i john': 'I John',
    'i jn': 'I John',
    'ijo': 'I John',

    '2 john': '2 John',
    '2 jn': '2 John',
    '2jo': '2 John',
    'ii john': 'II John',
    'ii jn': 'II John',
    'iijo': 'II John',

    '3 john': '3 John',
    '3 jn': '3 John',
    '3jo': '3 John',
    'iii john': 'III John',
    'iii jn': 'III John',
    'iiijo': 'III John',

    'jude': 'Jude',
    'jud': 'Jude',

    'rev': 'Revelation',
    're': 'Revelation',
    'rv': 'Revelation',
    'revelation': 'Revelation',
    'revelation of john': 'Revelation of John',
  };

  // ==============================================================
  // PARSE A SCRIPTURE REFERENCE
  // ==============================================================

  ScriptureReference? parse(String refString) {
    var cleaned = refString.trim();

    // Remove the custom URI scheme if one is passed in.
    if (cleaned.toLowerCase().startsWith('bible://')) {
      cleaned = cleaned.substring('bible://'.length);

      try {
        cleaned = Uri.decodeComponent(cleaned);
      } catch (_) {
        // Leave it alone if decoding fails.
      }
    }

    // Remove surrounding punctuation.
    cleaned = cleaned
        .replaceAll(RegExp(r'^[\s\(\[\{]+'), '')
        .replaceAll(RegExp(r'[\s\)\]\}\.,;!?]+$'), '')
        .trim();

    // Normalize whitespace.
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ');

    final pattern = RegExp(
      r'(\d?\s*[A-Z][a-z]*(?:\s+[a-z]+){0,2})\.?\s+'
      r'(\d+)'
      r'(?::([\d\s,:\-–]+))?\s*'
      r'(?=[\s.,;:!?()\[\]{}]|$)',
      caseSensitive: false,
    );

    final match = pattern.firstMatch(cleaned);

    if (match == null) {
      return null;
    }

    final rawBook = match.group(1)!;
    final chapter = int.tryParse(match.group(2)!);

    if (chapter == null) {
      return null;
    }

    // Try to find a valid book name by stripping leading words
    String? bookName;
    String bookCandidate = rawBook.trim().toLowerCase().replaceAll('.', '').replaceAll(RegExp(r'\s+'), ' ');

    while (bookName == null) {
      if (bookCandidate.isEmpty) break;
      bookName = _bookAbbreviations[bookCandidate];
      final parts = bookCandidate.split(RegExp(r'\s+'));
      if (parts.length > 1) {
        bookCandidate = parts.skip(1).join(' ');
      } else {
        break;
      }
    }

    if (bookName == null) {
      return null;
    }

    // No verse means chapter-only reference.
    if (match.group(3) == null) {
      return ScriptureReference(
        book: bookName,
        chapter: chapter,
        verses: const [],
      );
    }

    final rawVerses = match.group(3)!;

    // Check for chapter:verse pairs (e.g., "41, 4:25") which indicate
    // references to different chapters. For simplicity, we only handle
    // single-chapter references.
    if (rawVerses.contains(':')) {
      return ScriptureReference(
        book: bookName,
        chapter: chapter,
        verses: [],
      );
    }

    final verses = <int>[];

    // Split by comma to handle multiple verse references
    for (final part in rawVerses.split(',')) {
      final trimmed = part.trim();
      if (trimmed.contains('-') || trimmed.contains('–')) {
        final rangeParts = trimmed.split(RegExp(r'[-–]'));
        final start = int.tryParse(rangeParts[0].trim());
        final end = int.tryParse(rangeParts.length > 1 ? rangeParts[1].trim() : rangeParts[0].trim());
        if (start != null && end != null) {
          if (end < start) {
            return null;
          }
          for (var v = start; v <= end; v++) {
            verses.add(v);
          }
        }
      } else {
        final verse = int.tryParse(trimmed);
        if (verse != null) {
          verses.add(verse);
        }
      }
    }

    if (verses.isEmpty) {
      return null;
    }

    return ScriptureReference(
      book: bookName,
      chapter: chapter,
      verses: verses,
    );
  }

  // ==============================================================
  // LINKIFY SCRIPTURE REFERENCES
  // ==============================================================

  String linkifyReferences(String text) {
    if (text.isEmpty) {
      return text;
    }

    // ------------------------------------------------------------
    // Protect existing Markdown links.
    // ------------------------------------------------------------

    final protectedLinks = <String>[];

    final markdownLinkPattern = RegExp(
      r'\[[^\]]+\]\([^)]+\)',
      multiLine: true,
    );

    var result = text.replaceAllMapped(
      markdownLinkPattern,
      (match) {
        final index = protectedLinks.length;

        protectedLinks.add(match.group(0)!);

        return '\u0000LINK$index\u0000';
      },
    );

    // ------------------------------------------------------------
    // Scripture reference pattern.
    //
    // Examples:
    //
    // Micah 5:2
    // Micah 5:2.
    // (Micah 5:2.)
    // Isa. 7:14
    // (Isa. 7:14.)
    // Matt. 1:21
    // John 3:16-18
    // 1 Cor. 13:4
    // 2 Tim. 3:16
    //
    // Importantly, punctuation surrounding the reference is NOT
    // included in the Markdown link.
    // ------------------------------------------------------------

    final scripturePattern = RegExp(
      r'(?<![A-Za-z0-9_])'
      r'((?:\d\s*)?[A-Za-z]+(?:\s+[A-Za-z]+)?\.?\s+\d+'
      r'(?:[:](?:\d+(?:[-–]\d+)?(?:(?:\s*,\s*)+(?!\d+\s*:)\d+(?:[-–]\d+)?)*)?)?'
      r')'
      r'(?=$|[\s.,;:!?()\[\]{}])',
      caseSensitive: false,
    );

    result = result.replaceAllMapped(
      scripturePattern,
      (match) {
        final core = match.group(1)!.trim();

        final parsed = parse(core);

        if (parsed == null) {
          return match.group(0)!;
        }

        final canonical = parsed.toCanonical();

        // Use a custom scheme so Markdown never mistakes the
        // reference for a normal web URL.
        final href = 'bible://${Uri.encodeComponent(canonical)}';

        return '[$core]($href)';
      },
    );

    // ------------------------------------------------------------
    // Restore existing Markdown links.
    // ------------------------------------------------------------

    result = result.replaceAllMapped(
      RegExp(r'\u0000LINK(\d+)\u0000'),
      (match) {
        final index = int.parse(match.group(1)!);

        if (index < 0 || index >= protectedLinks.length) {
          return match.group(0)!;
        }

        return protectedLinks[index];
      },
    );

    return result;
  }

  // ==============================================================
  // EXTRACT / NORMALIZE A MARKDOWN LINK TARGET
  // ==============================================================

  String? canonicalFromHref(String href) {
    var value = href.trim();

    if (value.isEmpty) {
      return null;
    }

    if (value.toLowerCase().startsWith('bible://')) {
      value = value.substring('bible://'.length);

      try {
        value = Uri.decodeComponent(value);
      } catch (_) {
        return null;
      }
    }

    final parsed = parse(value);

    return parsed?.toCanonical();
  }

  // ==============================================================
  // BIBLE DATA LOADING & CANONICAL REFERENCES
  // ==============================================================

  final List<String> canonicalReferences = <String>[];
  bool _loaded = false;

  Future<void> load() async {
    if (_loaded) return;
    final raw = await rootBundle.loadString('assets/bible/BSB.json');
    final data = jsonDecode(raw) as Map<String, dynamic>;
    final booksJson = data['books'] as List<dynamic>;
    
    for (final bookJson in booksJson) {
      final book = bookJson as Map<String, dynamic>;
      final bookName = book['name'] as String;
      final chapters = book['chapters'] as List<dynamic>;
      
      for (final chapterJson in chapters) {
        final chapter = chapterJson as Map<String, dynamic>;
        final chapterNum = chapter['chapter'] as int;
        final verses = chapter['verses'] as List<dynamic>;
        
        for (final verseJson in verses) {
          final verse = verseJson as Map<String, dynamic>;
          final verseNum = verse['verse'] as int;
          canonicalReferences.add('$bookName $chapterNum:$verseNum');
        }
      }
    }
    _loaded = true;
  }
}
