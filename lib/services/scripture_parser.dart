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

    if (verses.length == 1) {
      return '$book $chapter:${verses.first}';
    }

    return '$book $chapter:${verses.first}-${verses.last}';
  }

  @override
  String toString() => toCanonical();
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

    '2 sam': '2 Samuel',
    '2 sa': '2 Samuel',
    '2sm': '2 Samuel',
    '2 samuel': '2 Samuel',

    '1 kgs': '1 Kings',
    '1 ki': '1 Kings',
    '1kg': '1 Kings',
    '1 kings': '1 Kings',

    '2 kgs': '2 Kings',
    '2 ki': '2 Kings',
    '2kg': '2 Kings',
    '2 kings': '2 Kings',

    '1 chr': '1 Chronicles',
    '1 ch': '1 Chronicles',
    '1 chronicles': '1 Chronicles',

    '2 chr': '2 Chronicles',
    '2 ch': '2 Chronicles',
    '2 chronicles': '2 Chronicles',

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

    '2 cor': '2 Corinthians',
    '2 co': '2 Corinthians',
    '2cor': '2 Corinthians',
    '2 corinthians': '2 Corinthians',

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

    '2 thess': '2 Thessalonians',
    '2 th': '2 Thessalonians',
    '2thess': '2 Thessalonians',
    '2 thessalonians': '2 Thessalonians',

    '1 tim': '1 Timothy',
    '1 ti': '1 Timothy',
    '1tim': '1 Timothy',
    '1 timothy': '1 Timothy',

    '2 tim': '2 Timothy',
    '2 ti': '2 Timothy',
    '2tim': '2 Timothy',
    '2 timothy': '2 Timothy',

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

    '2 pet': '2 Peter',
    '2 pe': '2 Peter',
    '2pt': '2 Peter',
    '2 peter': '2 Peter',

    '1 john': '1 John',
    '1 jn': '1 John',
    '1jo': '1 John',

    '2 john': '2 John',
    '2 jn': '2 John',
    '2jo': '2 John',

    '3 john': '3 John',
    '3 jn': '3 John',
    '3jo': '3 John',

    'jude': 'Jude',
    'jud': 'Jude',

    'rev': 'Revelation',
    're': 'Revelation',
    'rv': 'Revelation',
    'revelation': 'Revelation',
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
      r'^(\d?\s*[A-Za-z]+(?:\s+[A-Za-z]+)?)\.?\s+'
      r'(\d+)'
      r'(?::(\d+)(?:[-–](\d+))?)?$',
      caseSensitive: false,
    );

    final match = pattern.firstMatch(cleaned);

    if (match == null) {
      return null;
    }

    final bookCandidate = match
        .group(1)!
        .trim()
        .toLowerCase()
        .replaceAll('.', '')
        .replaceAll(RegExp(r'\s+'), ' ');

    final chapter = int.tryParse(match.group(2)!);

    if (chapter == null) {
      return null;
    }

    final startVerse = int.tryParse(match.group(3) ?? '');

    final endVerse = int.tryParse(match.group(4) ?? '');

    final bookName = _bookAbbreviations[bookCandidate];

    if (bookName == null) {
      return null;
    }

    // No verse means chapter-only reference.
    if (startVerse == null) {
      return ScriptureReference(
        book: bookName,
        chapter: chapter,
        verses: const [],
      );
    }

    final actualEndVerse = endVerse ?? startVerse;

    // Reject malformed ranges such as 5:10-2.
    if (actualEndVerse < startVerse) {
      return null;
    }

    final verses = <int>[];

    for (var verse = startVerse; verse <= actualEndVerse; verse++) {
      verses.add(verse);
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
      r'(?:[:]\d+(?:[-–]\d+)?)?)'
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
}
