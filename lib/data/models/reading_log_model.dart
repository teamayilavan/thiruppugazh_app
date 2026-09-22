/// One day's reading record for one song. Upserted by `recordDwell` on
/// `UNIQUE(song_id, read_on)` -- see DatabaseHelper.recordDwell (T1.3).
class ReadingLogEntry {
  final int? id;
  final int songId;
  final String readOn; // local-date ISO string, yyyy-MM-dd -- never UTC
  final int dwellSeconds;
  final bool completed;

  ReadingLogEntry({
    this.id,
    required this.songId,
    required this.readOn,
    required this.dwellSeconds,
    required this.completed,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'song_id': songId,
      'read_on': readOn,
      'dwell_seconds': dwellSeconds,
      'completed': completed ? 1 : 0,
    };
  }

  factory ReadingLogEntry.fromMap(Map<String, dynamic> map) {
    return ReadingLogEntry(
      id: map['id'],
      songId: map['song_id'],
      readOn: map['read_on'],
      dwellSeconds: map['dwell_seconds'],
      completed: map['completed'] == 1,
    );
  }

  ReadingLogEntry copyWith({
    int? id,
    int? songId,
    String? readOn,
    int? dwellSeconds,
    bool? completed,
  }) {
    return ReadingLogEntry(
      id: id ?? this.id,
      songId: songId ?? this.songId,
      readOn: readOn ?? this.readOn,
      dwellSeconds: dwellSeconds ?? this.dwellSeconds,
      completed: completed ?? this.completed,
    );
  }
}
