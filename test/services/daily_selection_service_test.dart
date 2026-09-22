import 'package:flutter_test/flutter_test.dart';
import 'package:thiruppugazh/services/daily_selection_service.dart';

void main() {
  group('verseSongIdForDate', () {
    test('is deterministic for the same date across repeated calls', () {
      final date = DateTime(2026, 9, 22);
      final first = verseSongIdForDate(date, 1334);
      final second = verseSongIdForDate(date, 1334);
      final third = verseSongIdForDate(DateTime(2026, 9, 22), 1334);
      expect(first, second);
      expect(first, third);
    });

    test('differs for adjacent dates', () {
      final today = verseSongIdForDate(DateTime(2026, 9, 22), 1334);
      final tomorrow = verseSongIdForDate(DateTime(2026, 9, 23), 1334);
      expect(today, isNot(tomorrow));
    });

    test('stays within [0, corpusSize)', () {
      for (var day = 1; day <= 28; day++) {
        final index = verseSongIdForDate(DateTime(2026, 2, day), 1334);
        expect(index, inInclusiveRange(0, 1333));
      }
    });

    test('throws for a non-positive corpus size', () {
      expect(
        () => verseSongIdForDate(DateTime(2026, 1, 1), 0),
        throwsArgumentError,
      );
    });
  });

  group('verseIndexForDate', () {
    test('is deterministic and bounded', () {
      final date = DateTime(2026, 9, 22);
      final first = verseIndexForDate(date, 8);
      final second = verseIndexForDate(DateTime(2026, 9, 22), 8);
      expect(first, second);
      expect(first, inInclusiveRange(0, 7));
    });

    test('does not always equal verseSongIdForDate for the same date', () {
      // Mixed with a distinct constant so the two selections don't
      // trivially correlate -- spot-check a handful of dates.
      var sawDifference = false;
      for (var day = 1; day <= 20; day++) {
        final date = DateTime(2026, 3, day);
        final songIndex = verseSongIdForDate(date, 1334);
        final verseIndex = verseIndexForDate(date, 1334);
        if (songIndex != verseIndex) {
          sawDifference = true;
          break;
        }
      }
      expect(sawDifference, isTrue);
    });
  });

  group('todaysHymnSongId', () {
    test('returns the lowest id not in completedSongIds', () {
      final result = todaysHymnSongId(
        allSongIds: [7, 3, 1, 9, 5],
        completedSongIds: {1, 3},
        date: DateTime(2026, 1, 1),
      );
      expect(result, 5);
    });

    test('falls back to a deterministic pick once everything is complete', () {
      final ids = [5, 3, 1, 2, 4];
      final result = todaysHymnSongId(
        allSongIds: ids,
        completedSongIds: ids.toSet(),
        date: DateTime(2026, 1, 1),
      );
      expect(ids, contains(result));

      final again = todaysHymnSongId(
        allSongIds: ids,
        completedSongIds: ids.toSet(),
        date: DateTime(2026, 1, 1),
      );
      expect(result, again);
    });

    test('throws for an empty corpus', () {
      expect(
        () => todaysHymnSongId(
          allSongIds: const [],
          completedSongIds: const {},
          date: DateTime(2026, 1, 1),
        ),
        throwsArgumentError,
      );
    });
  });
}
