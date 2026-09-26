/// Pure, dependency-free "song of the day" selection. No DB access, no RNG,
/// no clock reads -- deterministic for a given [DateTime]: every devotee
/// worldwide gets the same song on the same calendar date, and it doesn't
/// change again until the next local date.
library;

/// Splitmix64-style integer mixing. Deterministic and stable across Dart
/// versions and platforms, unlike `Object.hashCode`.
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

/// A deterministic index in `[0, corpusSize)` for [date] -- today's song of
/// the day. Same date, same index, every time, for every installation.
int dailySongIndexForDate(DateTime date, int corpusSize) {
  if (corpusSize <= 0) {
    throw ArgumentError.value(corpusSize, 'corpusSize', 'must be positive');
  }
  final hash = _splitMix64(_dateSeed(date));
  return _positiveMod(hash, corpusSize);
}
