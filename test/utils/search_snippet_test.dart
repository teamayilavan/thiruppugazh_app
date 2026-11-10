import 'package:flutter_test/flutter_test.dart';
import 'package:thiruppugazh/data/models/song_model.dart';
import 'package:thiruppugazh/utils/search_snippet.dart';

Song _song({
  String title = 'Arukku Mangaiyar',
  String? englishTitle,
  String number = '12',
  List<String> tamil = const [],
  List<String> english = const [],
}) => Song(
  id: 1,
  kaumaramId: number,
  title: title,
  englishTitle: englishTitle,
  place: 'P',
  tune: '',
  lyrics: '',
  lyricsList: tamil,
  englishLyricsList: english,
  tuneList: const [],
  words: const [],
  meanings: const [],
  pathavurai: '',
  patham: const [],
);

void main() {
  group('findMatchingLine', () {
    test('shows the line that contains the words, split around them', () {
      final s = findMatchingLine(
        _song(tamil: ['first line', 'the peacock dances', 'last line']),
        'peacock',
        preferEnglish: false,
      )!;
      expect(s.before, 'the ');
      expect(s.match, 'peacock');
      expect(s.after, ' dances');
      expect(s.text, 'the peacock dances');
    });

    test('is case-insensitive but keeps the line as written', () {
      final s = findMatchingLine(
        _song(tamil: ['The Peacock Dances']),
        'peacock',
        preferEnglish: false,
      )!;
      expect(s.match, 'Peacock');
    });

    test('works for Tamil script', () {
      final s = findMatchingLine(
        _song(tamil: ['முத்தைத் தருபத்தி திருநகை']),
        'தருபத்தி',
        preferEnglish: false,
      )!;
      expect(s.match, 'தருபத்தி');
    });

    test('looks in the language being read first, then the other', () {
      final song = _song(
        tamil: ['vel vel muruga'],
        english: ['vel vel in english'],
      );
      expect(
        findMatchingLine(song, 'vel', preferEnglish: true)!.text,
        'vel vel in english',
      );
      expect(
        findMatchingLine(song, 'vel', preferEnglish: false)!.text,
        'vel vel muruga',
      );
      // Only the Tamil lines have this word, so English-first still finds it.
      expect(
        findMatchingLine(
          _song(tamil: ['only here'], english: ['nothing']),
          'only',
          preferEnglish: true,
        )!.text,
        'only here',
      );
    });

    test(
      'says nothing when the title or number already explains the match',
      () {
        final song = _song(tamil: ['arukku in a line too']);
        expect(findMatchingLine(song, 'arukku', preferEnglish: false), isNull);
        expect(findMatchingLine(song, '12', preferEnglish: false), isNull);
        expect(
          findMatchingLine(
            _song(englishTitle: 'Muththai Tharu', tamil: ['muththai again']),
            'muththai',
            preferEnglish: false,
          ),
          isNull,
        );
      },
    );

    test('says nothing for a very short query or no matching line', () {
      final song = _song(tamil: ['some line']);
      expect(findMatchingLine(song, 's', preferEnglish: false), isNull);
      expect(findMatchingLine(song, '  ', preferEnglish: false), isNull);
      expect(findMatchingLine(song, 'zzz', preferEnglish: false), isNull);
    });

    test('cuts a long lead-in so the match stays in view', () {
      final line = '${'a' * 60} MATCH tail';
      final s = findMatchingLine(
        _song(tamil: [line]),
        'match',
        preferEnglish: false,
      )!;
      expect(s.before.startsWith('…'), isTrue);
      expect(s.before.length, lessThan(40));
      expect(s.match, 'MATCH');
    });
  });
}
