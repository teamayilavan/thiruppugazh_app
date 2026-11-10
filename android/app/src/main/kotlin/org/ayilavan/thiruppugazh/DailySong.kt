package org.ayilavan.thiruppugazh

/**
 * The "song of the day" rule, ported from `lib/services/daily_song_service.dart`
 * so the home-screen widget picks the same song as the app's Home card without
 * starting Flutter.
 *
 * Keep this identical to the Dart version. `test/services/daily_song_vectors_test.dart`
 * pins the Dart side to fixed values; the same values must come out of here.
 * Both use 64-bit wrap-around arithmetic.
 */
object DailySong {
    private fun splitMix64(seed: Long): Long {
        var z = seed + 0x9E3779B97F4A7C15UL.toLong()
        z = (z xor (z ushr 30)) * 0xBF58476D1CE4E5B9UL.toLong()
        z = (z xor (z ushr 27)) * 0x94D049BB133111EBUL.toLong()
        return z xor (z ushr 31)
    }

    /** A stable index in [0, count) for the given calendar date. */
    fun indexFor(year: Int, month: Int, day: Int, count: Int): Int {
        require(count > 0) { "count must be positive" }
        val seed = (year * 10000 + month * 100 + day).toLong()
        val remainder = splitMix64(seed) % count
        // Kotlin's % keeps the sign of the dividend; the Dart rule is the
        // non-negative remainder.
        return (if (remainder < 0) remainder + count else remainder).toInt()
    }
}
