import 'package:flutter_test/flutter_test.dart';
import 'package:bible_app/services/scripture_parser.dart';

void main() {
  group('ScriptureParser', () {
    ScriptureParser parser = ScriptureParser();

    setUp(() {
      parser = ScriptureParser();
    });

    test('parses simple reference Matthew 1:1', () {
      final ref = parser.parse('Matthew 1:1');
      expect(ref, isNotNull);
      expect(ref!.book, 'Matthew');
      expect(ref.chapter, 1);
      expect(ref.verses, [1]);
      expect(ref.toCanonical(), 'Matthew 1:1');
    });

    test('parses range reference John 1:31-34', () {
      final ref = parser.parse('John 1:31-34');
      expect(ref, isNotNull);
      expect(ref!.book, 'John');
      expect(ref.chapter, 1);
      expect(ref.verses, [31, 32, 33, 34]);
    });

    test('parses 1 Cor. 10:1', () {
      final ref = parser.parse('1 Cor. 10:1');
      expect(ref, isNotNull);
      expect(ref!.book, '1 Corinthians');
      expect(ref.chapter, 10);
      expect(ref.verses, [1]);
    });

    test('parses 2 Tim. 4:11', () {
      final ref = parser.parse('2 Tim. 4:11');
      expect(ref, isNotNull);
      expect(ref!.book, '2 Timothy');
      expect(ref.chapter, 4);
      expect(ref.verses, [11]);
    });

    test('parses 1 Kings 10:1', () {
      final ref = parser.parse('1 Kings 10:1');
      expect(ref, isNotNull);
      expect(ref!.book, '1 Kings');
      expect(ref.chapter, 10);
      expect(ref.verses, [1]);
    });

    test('parses John 7:50, 51, 19', () {
      final ref = parser.parse('John 7:50, 51, 19');
      expect(ref, isNotNull);
      expect(ref!.book, 'John');
      expect(ref.chapter, 7);
      expect(ref.verses, [50, 51, 19]);
    });

    test('parses Acts 5:27-41, 6', () {
      final ref = parser.parse('Acts 5:27-41, 6');
      expect(ref, isNotNull);
      expect(ref!.book, 'Acts');
      expect(ref.chapter, 5);
      expect(ref.verses, [27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 6]);
    });

    test('returns null for invalid reference', () {
      final ref = parser.parse('invalid reference');
      expect(ref, isNull);
    });

    test('returns null for empty string', () {
      final ref = parser.parse('');
      expect(ref, isNull);
    });

    test('canonicalReferences contains Genesis 1:1', () {
      expect(parser.canonicalReferences, contains('Genesis 1:1'));
    });

    test('parses Genesis abbreviated as Gen', () {
      final ref = parser.parse('Gen 1:1');
      expect(ref, isNotNull);
      expect(ref!.book, 'Genesis');
      expect(ref.chapter, 1);
      expect(ref.verses, [1]);
    });

    test('parses Psalms abbreviated as Ps', () {
      final ref = parser.parse('Ps 23:1');
      expect(ref, isNotNull);
      expect(ref!.book, 'Psalms');
      expect(ref.chapter, 23);
      expect(ref.verses, [1]);
    });

    test('parses Song of Solomon', () {
      final ref = parser.parse('Song of Solomon 1:1');
      expect(ref, isNotNull);
      expect(ref!.book, 'Song of Solomon');
      expect(ref.chapter, 1);
      expect(ref.verses, [1]);
    });

    test('parses 1 Peter', () {
      final ref = parser.parse('1 Peter 1:1');
      expect(ref, isNotNull);
      expect(ref!.book, '1 Peter');
      expect(ref.chapter, 1);
      expect(ref.verses, [1]);
    });

    test('parses Rom. 9:1', () {
      final ref = parser.parse('Rom. 9:1');
      expect(ref, isNotNull);
      expect(ref!.book, 'Romans');
      expect(ref.chapter, 9);
      expect(ref.verses, [1]);
    });

    test('toCanonical returns correct format', () {
      final ref = parser.parse('John 3:16');
      expect(ref!.toCanonical(), 'John 3:16');
    });

    test('toCanonical with range', () {
      final ref = parser.parse('John 3:16-18');
      expect(ref!.toCanonical(), 'John 3:16,17,18');
    });

    test('equality works correctly', () {
      final ref1 = parser.parse('John 3:16')!;
      final ref2 = parser.parse('John 3:16')!;
      expect(ref1, ref2);
      expect(ref1.hashCode, ref2.hashCode);
    });

    test('equality returns false for different references', () {
      final ref1 = parser.parse('John 3:16')!;
      final ref2 = parser.parse('John 3:17')!;
      expect(ref1, isNot(ref2));
    });
  });
}
