class Highlight {
  final int? id;
  final int songId;
  final int verseIndex; // Index of the lyric paragraph/verse
  final String textContent; // Snapshot of the text highlighted
  final DateTime createdAt;

  Highlight({
    this.id,
    required this.songId,
    required this.verseIndex,
    required this.textContent,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'song_id': songId,
      'verse_index': verseIndex,
      'text_content': textContent,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Highlight.fromMap(Map<String, dynamic> map) {
    return Highlight(
      id: map['id'],
      songId: map['song_id'],
      verseIndex: map['verse_index'],
      textContent: map['text_content'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
