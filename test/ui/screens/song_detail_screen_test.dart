import 'package:flutter_test/flutter_test.dart';
import 'package:thiruppugazh/data/models/song_model.dart';
import 'package:thiruppugazh/ui/screens/song_detail_screen.dart';

Song _song({
  List<String> tamil = const [],
  List<String> english = const [],
}) {
  return Song(
    id: 1,
    kaumaramId: '1',
    title: 'T',
    place: 'P',
    tune: '',
    lyrics: '',
    lyricsList: const [],
    tuneList: const [],
    words: const [],
    meanings: const [],
    pathavurai: '',
    patham: const [],
    mayuragiriLyricsSeparatedList: tamil,
    mayuragiriEnglishLyricsSeparatedList: english,
  );
}

void main() {
  group('selectMayuragiriLyrics', () {
    test('returns Tamil list when useEnglish is false', () {
      final song = _song(tamil: ['ta one', 'ta two'], english: ['en one']);
      expect(selectMayuragiriLyrics(song, false), ['ta one', 'ta two']);
    });

    test('returns English list when useEnglish is true', () {
      final song = _song(tamil: ['ta one'], english: ['en one', 'en two']);
      expect(selectMayuragiriLyrics(song, true), ['en one', 'en two']);
    });

    test('returns empty list when the selected language has no data', () {
      final song = _song(tamil: const [], english: const []);
      expect(selectMayuragiriLyrics(song, false), isEmpty);
      expect(selectMayuragiriLyrics(song, true), isEmpty);
    });
  });
}
