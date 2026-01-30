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
        'lyrics': '',
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
  });
}
