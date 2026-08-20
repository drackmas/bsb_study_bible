import 'package:flutter_test/flutter_test.dart';
import 'package:bible_app/services/bible_service.dart';

void main() {
  group('BibleService.normalizeBookName', () {
    test('maps leading Roman numerals to Arabic', () {
      expect(BibleService.normalizeBookName('I Corinthians'), '1 corinthians');
      expect(BibleService.normalizeBookName('II Peter'), '2 peter');
      expect(BibleService.normalizeBookName('III John'), '3 john');
    });

    test('leaves Arabic-numeral names untouched', () {
      expect(BibleService.normalizeBookName('1 Corinthians'), '1 corinthians');
      expect(BibleService.normalizeBookName('2 Timothy'), '2 timothy');
    });

    test('is case-insensitive', () {
      expect(
        BibleService.normalizeBookName('i corinthians'),
        BibleService.normalizeBookName('I Corinthians'),
      );
    });

    test('does not mangle book names starting with "i" letters', () {
      expect(BibleService.normalizeBookName('Isaiah'), 'isaiah');
      expect(BibleService.normalizeBookName('Isa'), 'isa');
    });

    test('maps "Revelation" alias to "Revelation of John"', () {
      expect(BibleService.normalizeBookName('Revelation'), 'revelation of john');
      expect(
        BibleService.normalizeBookName('Revelation of John'),
        'revelation of john',
      );
    });

    test('normalizes both numeral styles to the same key', () {
      expect(
        BibleService.normalizeBookName('1 Corinthians'),
        BibleService.normalizeBookName('I Corinthians'),
      );
    });
  });
}
