import 'dart:convert';
import 'dart:io';

const bookMap = {
  'Matt': 'MAT',
  'Mark': 'MRK',
  'Luke': 'LUK',
  'John': 'JHN',
  'Acts': 'ACT',
  'Rom': 'ROM',
  '1Cor': '1CO',
  '2Cor': '2CO',
  'Gal': 'GAL',
  'Eph': 'EPH',
  'Phil': 'PHP',
  'Col': 'COL',
  '1Thess': '1TH',
  '2Thess': '2TH',
  '1Tim': '1TI',
  '2Tim': '2TI',
  'Titus': 'TIT',
  'Phlm': 'PHM',
  'Heb': 'HEB',
  'Jas': 'JAS',
  '1Pet': '1PE',
  '2Pet': '2PE',
  '1John': '1JN',
  '2John': '2JN',
  '3John': '3JN',
  'Jude': 'JUD',
  'Rev': 'REV',
};

String? bsbId(String osisRef) {
  final parts = osisRef.split('.');

  if (parts.length != 3) {
    return null;
  }

  final book = bookMap[parts[0]];

  if (book == null) {
    return null;
  }

  return '$book.${parts[1]}.${parts[2]}';
}

/// Converts the SWORD/OSIS markup inside a commentary entry
/// into readable text.
String cleanText(String text) {
  // References:
  //
  // <reference osisRef="Matt.9.9">Matthew 9:9</reference>
  //
  text = text.replaceAllMapped(
    RegExp(r'<reference\b[^>]*>(.*?)</reference>', dotAll: true),
    (match) => match.group(1) ?? '',
  );

  // Italic text -> Markdown italic.
  text = text.replaceAllMapped(
    RegExp(r'<hi\b[^>]*type="italic"[^>]*>(.*?)</hi>', dotAll: true),
    (match) => '*${match.group(1) ?? ''}*',
  );

  // Small caps -> just preserve the text.
  text = text.replaceAllMapped(
    RegExp(r'<hi\b[^>]*type="small-caps"[^>]*>(.*?)</hi>', dotAll: true),
    (match) => match.group(1) ?? '',
  );

  // Any remaining <hi> tags.
  text = text.replaceAllMapped(
    RegExp(r'<hi\b[^>]*>(.*?)</hi>', dotAll: true),
    (match) => match.group(1) ?? '',
  );

  // Paragraph divs.
  text = text.replaceAll(
    RegExp(r'<div\b[^>]*type="paragraph"[^>]*>', dotAll: true),
    '',
  );

  text = text.replaceAll(
    RegExp(r'<div\b[^>]*eID="[^"]*"[^>]*/>', dotAll: true),
    '',
  );

  // Remove any remaining div tags.
  text = text.replaceAll(
    RegExp(r'</?div\b[^>]*>', dotAll: true),
    '',
  );

  // Remove any remaining XML/HTML tags.
  text = text.replaceAll(
    RegExp(r'<[^>]+>', dotAll: true),
    '',
  );

  // Decode the most common XML entities.
  text = text
      .replaceAll('&amp;', '&')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&quot;', '"')
      .replaceAll('&apos;', "'");

  // Normalize whitespace.
  text = text
      .replaceAll(RegExp(r'[ \t]+'), ' ')
      .replaceAll(RegExp(r' *\n *'), '\n')
      .replaceAll(RegExp(r'\n{3,}'), '\n\n')
      .trim();

  return text;
}

Future<void> main() async {
  stdout.writeln('========================================');
  stdout.writeln('Abbott SWORD -> JSON converter');
  stdout.writeln('========================================');
  stdout.writeln();

  // ------------------------------------------------------------
  // Run native SWORD exporter.
  // ------------------------------------------------------------

  stdout.writeln('Running mod2vpl...');

  final result = await Process.run(
    'mod2vpl',
    ['Abbott'],
    environment: {
      ...Platform.environment,
      'SWORD_PATH': Directory.current.path,
    },
  );

  if (result.exitCode != 0) {
    stderr.writeln();
    stderr.writeln('ERROR: mod2vpl failed.');
    stderr.writeln(result.stderr);
    exit(result.exitCode);
  }

  final xmlText = result.stdout as String;

  stdout.writeln(
    'SWORD output: ${xmlText.length} characters',
  );

  // ------------------------------------------------------------
  // Extract commentary blocks.
  //
  // SWORD produces entries like:
  //
  // <div annotateRef="Matt.1.1"
  //      annotateType="commentary"
  //      sID="gen5"
  //      type="section"/>
  //
  // <div sID="gen6" type="paragraph"/>
  // TEXT
  // <div eID="gen6" type="paragraph"/>
  //
  // <div annotateRef="Matt.1.1"
  //      annotateType="commentary"
  //      eID="gen5"
  //      type="section"/>
  //
  // So we grab everything between the opening and closing
  // commentary markers.
  // ------------------------------------------------------------

  final commentary = <String, String>{};

  final startRegex = RegExp(
    r'<div\s+annotateRef="([^"]+)"\s+annotateType="commentary"[^>]*>',
    dotAll: true,
  );

  final matches = startRegex.allMatches(xmlText).toList();

  stdout.writeln(
    'Commentary blocks discovered: ${matches.length}',
  );

  var skipped = 0;

  for (var i = 0; i < matches.length; i++) {
    final match = matches[i];

    final osisRef = match.group(1);

    if (osisRef == null) {
      skipped++;
      continue;
    }

    final id = bsbId(osisRef);

    if (id == null) {
      stderr.writeln(
        'Skipping unsupported reference: $osisRef',
      );
      skipped++;
      continue;
    }

    // Content starts immediately after the opening marker.
    final contentStart = match.end;

    // Find the next commentary marker.
    final nextMatch = i + 1 < matches.length
        ? matches[i + 1]
        : null;

    final contentEnd = nextMatch?.start ?? xmlText.length;

    if (contentEnd <= contentStart) {
      skipped++;
      continue;
    }

    var content = xmlText.substring(
      contentStart,
      contentEnd,
    );

    // The next commentary marker is normally the closing marker
    // for this entry. Strip the closing marker if it belongs to
    // this exact reference.
    final closingPattern = RegExp(
      r'<div\s+annotateRef="' +
          RegExp.escape(osisRef) +
          r'"[^>]*eID="[^"]*"[^>]*/>',
      dotAll: true,
    );

    content = content.replaceFirst(
      closingPattern,
      '',
    );

    final text = cleanText(content);

    if (text.isEmpty) {
      continue;
    }

    commentary[id] = text;

    // Progress every 100 entries.
    if (commentary.length % 100 == 0) {
      stdout.writeln(
        '  Converted ${commentary.length} entries...',
      );
    }
  }

  // ------------------------------------------------------------
  // Create output.
  // ------------------------------------------------------------

  final output = {
    'version': 1,
    'source': 'Abbott Illustrated New Testament',
    'module': 'Abbott',
    'format': 'sword-zcom',
    'commentary': commentary,
  };

  final file = File('abbott.json');

  const encoder = JsonEncoder.withIndent('  ');

  await file.writeAsString(
    encoder.convert(output),
  );

  // ------------------------------------------------------------
  // Finished.
  // ------------------------------------------------------------

  stdout.writeln();
  stdout.writeln('========================================');
  stdout.writeln('DONE');
  stdout.writeln('========================================');
  stdout.writeln(
    'Commentary blocks: ${matches.length}',
  );
  stdout.writeln(
    'Converted entries: ${commentary.length}',
  );
  stdout.writeln(
    'Skipped: $skipped',
  );
  stdout.writeln(
    'Output: ${file.absolute.path}',
  );
  stdout.writeln('========================================');
}
