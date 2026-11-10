import 'package:flutter_test/flutter_test.dart';
import 'package:thiruppugazh/services/daily_song_service.dart';

/// Pins the song-of-the-day rule to fixed values.
///
/// The Android home-screen widget (`android/.../DailySong.kt`) re-implements
/// this rule natively so it can pick the same song without starting Flutter.
/// If this test has to change, change `DailySong.kt` to match, or the widget
/// and the Home card will show different songs.
void main() {
  // (year, month, day, number of songs) -> expected index
  const vectors = <(int, int, int, int, int)>[
    (2026, 1, 1, 1340, 1030),
    (2026, 1, 1, 7, 4),
    (2026, 2, 28, 1340, 784),
    (2026, 11, 10, 1340, 530),
    (2026, 11, 10, 7, 3),
    (2026, 12, 31, 1340, 826),
    (2027, 3, 14, 1340, 472),
    (2030, 7, 4, 1340, 747),
    (2026, 11, 10, 1, 0),
  ];

  for (final (y, m, d, n, expected) in vectors) {
    test('$y-$m-$d with $n songs picks index $expected', () {
      expect(dailySongIndexForDate(DateTime(y, m, d), n), expected);
    });
  }

  test('the time of day does not change the pick', () {
    expect(
      dailySongIndexForDate(DateTime(2026, 11, 10, 0, 0, 1), 1340),
      dailySongIndexForDate(DateTime(2026, 11, 10, 23, 59, 59), 1340),
    );
  });
}
