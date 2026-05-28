import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:thiruppugazh/data/models/song_model.dart';

void main() {
  group('Song Model Tests', () {
    test('Song should create from map correctly', () {
      // Arrange
      final map = {
        'id': 1,
        'kaumaram_id': 123,
        'title': 'Test Song',
        'place': 'Test Temple',
        'tune': 'Test Tune',
        'lyrics': 'Line 1\nLine 2\nLine 3',
        'pathavurai': 'Test Author',
        'lyrics_list': jsonEncode(['Line 1', 'Line 2', 'Line 3']),
        'tune_list': jsonEncode(['Tune']),
        'words': jsonEncode(['word1', 'word2', 'word3']),
        'meanings': jsonEncode(['meaning1', 'meaning2', 'meaning3']),
        'patham': jsonEncode(['Path 1', 'Path 2']),
      };

      // Act
      final song = Song.fromMap(map);

      // Assert
      expect(song.id, 1);
      expect(song.kaumaramId, '123');
      expect(song.title, 'Test Song');
      expect(song.place, 'Test Temple');
      expect(song.tune, 'Test Tune');
      expect(song.lyrics, 'Line 1\nLine 2\nLine 3');
      expect(song.pathavurai, 'Test Author');
      expect(song.lyricsList, ['Line 1', 'Line 2', 'Line 3']);
      expect(song.tuneList, ['Tune']);
      expect(song.words, ['word1', 'word2', 'word3']);
      expect(song.meanings, ['meaning1', 'meaning2', 'meaning3']);
      expect(song.patham, ['Path 1', 'Path 2']);
    });

    test('Song should initialize with empty categoryIds', () {
      // Arrange & Act
      final song = Song(
        id: 1,
        kaumaramId: '123',
        title: 'Test',
        place: 'Temple',
        tune: 'Tune',
        lyrics: 'Lyrics',
        lyricsList: [],
        tuneList: [],
        words: [],
        meanings: [],
        pathavurai: 'Author',
        patham: [],
      );

      // Assert
      expect(song.categoryIds, isEmpty);
    });

    test('Song can be constructed with non-empty categoryIds', () {
      final song = Song(
        id: 1,
        kaumaramId: '1',
        title: 'T',
        place: 'P',
        tune: 'Tu',
        lyrics: '',
        lyricsList: [],
        tuneList: [],
        words: [],
        meanings: [],
        pathavurai: '',
        patham: [],
        categoryIds: [2, 3],
      );

      expect(song.categoryIds, [2, 3]);
    });

    group('English content', () {
      test('hasEnglishContent is true when englishLyricsList is non-empty', () {
        final song = Song(
          id: 1, kaumaramId: '1', title: 'T', place: 'P',
          tune: '', lyrics: '', lyricsList: [], tuneList: [],
          words: [], meanings: [], pathavurai: '', patham: [],
          englishLyricsList: ['line one', 'line two'],
        );
        expect(song.hasEnglishContent, isTrue);
      });

      test('hasEnglishContent is false when englishLyricsList is empty', () {
        final song = Song(
          id: 1, kaumaramId: '1', title: 'T', place: 'P',
          tune: '', lyrics: '', lyricsList: [], tuneList: [],
          words: [], meanings: [], pathavurai: '', patham: [],
        );
        expect(song.hasEnglishContent, isFalse);
      });

      test('englishLyrics joins englishLyricsList with newlines', () {
        final song = Song(
          id: 1, kaumaramId: '1', title: 'T', place: 'P',
          tune: '', lyrics: '', lyricsList: [], tuneList: [],
          words: [], meanings: [], pathavurai: '', patham: [],
          englishLyricsList: ['line one', 'line two'],
        );
        expect(song.englishLyrics, 'line one\nline two');
      });

      test('Song.fromMap reads English columns with null safety', () {
        final map = {
          'id': 7,
          'kaumaram_id': 7,
          'title': 'Tamil Title',
          'place': 'Tamil Place',
          'tune': '',
          'lyrics': '',
          'tune_list': '[]',
          'lyrics_list': '[]',
          'words': '[]',
          'meanings': '[]',
          'pathavurai': '',
          'patham': '[]',
          'english_title': 'English Title',
          'english_venue': 'English Venue',
          'english_tune_list': '["thana","thana"]',
          'english_lyrics_list': '["line one","line two"]',
          'english_words': '["word one"]',
          'english_meanings_list': '["meaning one"]',
          'english_pathavurai': 'meaning one',
        };
        final song = Song.fromMap(map);
        expect(song.englishTitle, 'English Title');
        expect(song.englishVenue, 'English Venue');
        expect(song.englishTuneList, ['thana', 'thana']);
        expect(song.englishLyricsList, ['line one', 'line two']);
        expect(song.hasEnglishContent, isTrue);
      });

      test('Song.fromMap handles missing English columns gracefully', () {
        final map = {
          'id': 67,
          'kaumaram_id': 67,
          'title': 'Tamil Title',
          'place': 'Tamil Place',
          'tune': '',
          'lyrics': '',
          'tune_list': '[]',
          'lyrics_list': '[]',
          'words': '[]',
          'meanings': '[]',
          'pathavurai': '',
          'patham': '[]',
          // No English fields
        };
        final song = Song.fromMap(map);
        expect(song.englishTitle, isNull);
        expect(song.englishLyricsList, isEmpty);
        expect(song.hasEnglishContent, isFalse);
      });
    });
  });
}
