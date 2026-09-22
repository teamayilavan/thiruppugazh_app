/// Aggregate for one calendar day of practice. `day` is the primary key --
/// a local-date ISO string (yyyy-MM-dd), never a UTC timestamp.
class PracticeDay {
  final String day;
  final int songsCompleted;
  final bool verseSeen;

  PracticeDay({
    required this.day,
    required this.songsCompleted,
    required this.verseSeen,
  });

  Map<String, dynamic> toMap() {
    return {
      'day': day,
      'songs_completed': songsCompleted,
      'verse_seen': verseSeen ? 1 : 0,
    };
  }

  factory PracticeDay.fromMap(Map<String, dynamic> map) {
    return PracticeDay(
      day: map['day'],
      songsCompleted: map['songs_completed'],
      verseSeen: map['verse_seen'] == 1,
    );
  }

  PracticeDay copyWith({String? day, int? songsCompleted, bool? verseSeen}) {
    return PracticeDay(
      day: day ?? this.day,
      songsCompleted: songsCompleted ?? this.songsCompleted,
      verseSeen: verseSeen ?? this.verseSeen,
    );
  }
}
