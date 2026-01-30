import 'dart:convert';

/// Represents a single song with all its details.
/// This model is immutable.
class Song {
  final int id;
  final String title;
  final String kaumaramId;
  final String lyrics;
  final String place;
  final String tune;
  final List<String> lyricsList;
  final List<String> tuneList;
  final List<String> words;
  final List<String> meanings;
  final String pathavurai;
  final List<String> patham;
  final bool isFavorite;

  /// A mutable list of category IDs this song belongs to.
  /// This is managed at the app level, not directly from the 'songs' table.
  List<int> categoryIds;

  Song({
    required this.id,
    required this.title,
    required this.kaumaramId,
    required this.lyrics,
    required this.place,
    required this.tune,
    required this.lyricsList,
    required this.tuneList,
    required this.words,
    required this.meanings,
    required this.pathavurai,
    required this.patham,
    this.isFavorite = false,
    this.categoryIds = const [] // Default to an empty list
  });

  /// Factory constructor to create a Song instance from a database map.
  factory Song.fromMap(Map<String, dynamic> map) {
    return Song(
      id: map['id'],
      title: map['title'] ?? ''.toString(),
      kaumaramId: map['kaumaram_id'].toString(),
      lyrics: map['lyrics'] ?? ''.toString(),
      place: map['place'] ?? ''.toString(),
      tune: map['tune'] ?? ''.toString(),
      tuneList: List<String>.from(jsonDecode(map['tune_list'] ?? '[]')),
      // Decode the JSON strings from the database into Dart Lists.
      // Provide a fallback of '[]' for safety.
      lyricsList: List<String>.from(jsonDecode(map['lyrics_list'] ?? '[]')),
      words: List<String>.from(jsonDecode(map['words'] ?? '[]')),
      meanings: List<String>.from(jsonDecode(map['meanings'] ?? '[]')),
      pathavurai: map['pathavurai'] ?? '',
      patham: List<String>.from(jsonDecode(map['patham'] ?? '[]')),
      isFavorite: (map['is_favorite'] ?? 0) == 1,

      // categoryIds are populated separately by the repository.
      categoryIds: [],
    );
  }
}
