/// Pure, dependency-free daily-selection logic (T1.5). No DB access, no
/// RNG, no clock reads -- every function here is fully unit-testable and
/// deterministic for a given [DateTime]: every devotee worldwide gets the
/// same verse and the same fallback hymn on the same calendar date.
///
/// [verseSongIdForDate] and [verseIndexForDate] return zero-based indices
/// bounded by the caller-supplied count, not raw database ids (song ids in
/// `songs.id` are not guaranteed contiguous, and this file must not touch
/// the DB to look them up). Callers map the index onto an actual id via a
/// sorted-by-id list of all song ids, e.g. `sortedSongIds[index]`.
library;

/// Splitmix64-style integer mixing. Deterministic and stable across Dart
/// versions and platforms, unlike `Object.hashCode`. Relies on 64-bit
/// wrapping integer arithmetic (the Dart VM/AOT target this app ships on).
int _splitMix64(int seed) {
  int z = seed + 0x9E3779B97F4A7C15;
  z = (z ^ (z >>> 30)) * 0xBF58476D1CE4E5B9;
  z = (z ^ (z >>> 27)) * 0x94D049BB133111EB;
  return z ^ (z >>> 31);
}

/// Non-negative `value % modulus`, safe even when `value` is negative --
/// deliberately not `.abs() % modulus`, since `.abs()` on the most negative
/// 64-bit int overflows back to itself in two's-complement arithmetic.
int _positiveMod(int value, int modulus) {
  final result = value % modulus;
  return result < 0 ? result + modulus : result;
}

/// A stable per-date seed. Deliberately not `date.hashCode` (unstable
/// across Dart versions/platforms) and never reads the clock.
int _dateSeed(DateTime date) => date.year * 10000 + date.month * 100 + date.day;

/// A deterministic index in `[0, corpusSize)` for [date], usable as a
/// fallback song selection once every song has been read. Same date, same
/// index, every time.
int verseSongIdForDate(DateTime date, int corpusSize) {
  if (corpusSize <= 0) {
    throw ArgumentError.value(corpusSize, 'corpusSize', 'must be positive');
  }
  final hash = _splitMix64(_dateSeed(date));
  return _positiveMod(hash, corpusSize);
}

/// A deterministic index in `[0, verseCount)` for [date] -- which line of
/// today's chosen song to show as "today's grace" (இன்றைய அருள்). Mixed
/// with a distinct constant so it doesn't correlate with
/// [verseSongIdForDate] for the same date.
int verseIndexForDate(DateTime date, int verseCount) {
  if (verseCount <= 0) {
    throw ArgumentError.value(verseCount, 'verseCount', 'must be positive');
  }
  final hash = _splitMix64(_dateSeed(date) ^ 0x5DEECE66D);
  return _positiveMod(hash, verseCount);
}

/// Selects today's hymn: the lowest-id song not yet completed, or -- once
/// the whole corpus has been read -- a deterministic date-seeded pick, so
/// the endgame degrades gracefully instead of finding nothing to show.
///
/// Pure: callers fetch [allSongIds] and [completedSongIds] from the DB
/// themselves and pass them in. In v1.5 there is no parayanam table yet
/// (T3.2), so "next uncompleted" always means lowest id across the whole
/// corpus; once a parayanam is active this selection moves to its cursor.
int todaysHymnSongId({
  required List<int> allSongIds,
  required Set<int> completedSongIds,
  required DateTime date,
}) {
  if (allSongIds.isEmpty) {
    throw ArgumentError.value(allSongIds, 'allSongIds', 'must not be empty');
  }
  final sorted = [...allSongIds]..sort();
  for (final id in sorted) {
    if (!completedSongIds.contains(id)) return id;
  }
  final index = verseSongIdForDate(date, sorted.length);
  return sorted[index];
}
