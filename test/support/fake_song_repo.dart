import 'package:thiruppugazh/data/models/category_model.dart';
import 'package:thiruppugazh/data/models/highlight_model.dart';
import 'package:thiruppugazh/data/models/link_model.dart';
import 'package:thiruppugazh/data/models/note_model.dart';
import 'package:thiruppugazh/data/models/search_filter.dart';
import 'package:thiruppugazh/data/models/song_model.dart';
import 'package:thiruppugazh/data/repositories/song_repository.dart';

Song testSong(
  int id,
  String title, {
  List<String> words = const [],
  List<String> meanings = const [],
}) => Song(
  id: id,
  kaumaramId: '$id',
  title: title,
  place: 'Place $id',
  tune: '',
  lyrics: '',
  lyricsList: const ['line one', 'line two'],
  tuneList: const [],
  words: words,
  meanings: meanings,
  pathavurai: '',
  patham: const [],
);

/// Five songs with a gap in the numbering (no 4), so "next" must not assume
/// contiguous ids.
final List<Song> testSongs = [
  testSong(1, 'Alpha Song'),
  testSong(2, 'Bravo Song'),
  testSong(3, 'Charlie Song'),
  testSong(5, 'Echo Song'),
  testSong(6, 'Foxtrot Song'),
];

/// Serves the shell's tabs from memory, so the tests don't need a database.
class FakeSongRepo extends SongRepository {
  @override
  Future<List<Song>> getSongsPaginated({
    int page = 0,
    int pageSize = 20,
  }) async => page == 0 ? testSongs : [];

  @override
  Future<int> getSongsCount() async => testSongs.length;

  @override
  Future<Song?> getSongByIndex(int index) async => testSongs[index];

  @override
  Future<Song?> getRandomSong() async => testSongs.first;

  @override
  Future<Song?> getSongById(int id) async {
    for (final s in testSongs) {
      if (s.id == id) return s;
    }
    return null;
  }

  @override
  Future<Song?> getAdjacentSong(int id, {required bool next}) async {
    final ordered = next ? testSongs : testSongs.reversed;
    for (final s in ordered) {
      if (next ? s.id > id : s.id < id) return s;
    }
    return null;
  }

  @override
  Future<List<Song>> searchSongsWithFilter(SearchFilter filter) async {
    final q = filter.query.trim().toLowerCase();
    if (q.isEmpty) return [];
    return testSongs.where((s) => s.title.toLowerCase().contains(q)).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> getAllTemples() async => [];

  @override
  Future<List<Category>> getAllCategories() async => [];

  @override
  Future<List<int>> getCategoryIdsForSong(int songId) async => [];

  @override
  Future<List<Highlight>> getHighlightsForSong(int songId) async => [];

  @override
  Future<Note?> getNoteForSong(int songId) async => null;

  @override
  Future<List<SongLink>> getLinksForSong(int songId) async => [];

  @override
  Future<List<Map<String, dynamic>>> getHighlightsWithSongs() async => [];

  @override
  Future<List<Map<String, dynamic>>> getNotesWithSongs() async => [];

  @override
  Future<List<Map<String, dynamic>>> getLinksWithSongs() async => [];
}

/// [FakeSongRepo] with some highlights, notes and links in the Library.
class PopulatedFakeSongRepo extends FakeSongRepo {
  @override
  Future<List<Map<String, dynamic>>> getHighlightsWithSongs() async => [
    for (final s in testSongs.take(3))
      {
        'id': s.id,
        'song_id': s.id,
        'verse_index': 0,
        'text_content': 'a highlighted line',
        'created_at': '2026-01-01',
        'song_title': s.title,
      },
  ];

  @override
  Future<List<Map<String, dynamic>>> getNotesWithSongs() async => [
    for (final s in testSongs.take(3))
      {
        'id': s.id,
        'song_id': s.id,
        'content': 'My note on ${s.title}',
        'created_at': '2026-01-01',
        'updated_at': '2026-01-01',
        'song_title': s.title,
      },
  ];

  @override
  Future<List<Map<String, dynamic>>> getLinksWithSongs() async => [
    for (final s in testSongs.take(3))
      {
        'id': s.id,
        'song_id': s.id,
        'url': 'https://youtu.be/${s.id}',
        'title': 'A recital of ${s.title}',
        'created_at': '2026-01-01',
        'song_title': s.title,
      },
  ];
}
