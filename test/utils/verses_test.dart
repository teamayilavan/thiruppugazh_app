import 'package:flutter_test/flutter_test.dart';
import 'package:thiruppugazh/utils/verses.dart';

void main() {
  group('splitIntoVerses', () {
    test('groups lines by the tune pattern length', () {
      final lines = ['a', 'b', 'c', 'd', 'e', 'f'];
      expect(splitIntoVerses(lines, 3), [
        ['a', 'b', 'c'],
        ['d', 'e', 'f'],
      ]);
      expect(splitIntoVerses(lines, 2), [
        ['a', 'b'],
        ['c', 'd'],
        ['e', 'f'],
      ]);
    });

    test('keeps a trailing partial group as the last verse', () {
      expect(splitIntoVerses(['a', 'b', 'c', 'd', 'e'], 2), [
        ['a', 'b'],
        ['c', 'd'],
        ['e'],
      ]);
    });

    test('pairs lines when there is no tune pattern', () {
      expect(splitIntoVerses(['a', 'b', 'c', 'd'], 0), [
        ['a', 'b'],
        ['c', 'd'],
      ]);
    });

    test('drops blank lines but they still count toward the grouping', () {
      // Same rule the detail screen uses for its stanza breaks.
      expect(splitIntoVerses(['a', '  ', 'c', 'd'], 2), [
        ['a'],
        ['c', 'd'],
      ]);
    });

    test('never emits an empty verse', () {
      expect(splitIntoVerses(['', '', 'x', 'y'], 2), [
        ['x', 'y'],
      ]);
      expect(splitIntoVerses(const [], 3), isEmpty);
    });

    test('a single-line tune pattern makes every line its own verse', () {
      expect(splitIntoVerses(['a', 'b'], 1), [
        ['a'],
        ['b'],
      ]);
    });
  });
}
