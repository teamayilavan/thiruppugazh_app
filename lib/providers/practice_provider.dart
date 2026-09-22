import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../data/database/database_helper.dart';
import '../services/daily_selection_service.dart';

/// Cached practice-progress numbers for the home screen and daily card.
/// Loads once on construction and after every write; the home screen reads
/// [completedCount] / [totalDays] / [continuity] / [todayComplete] on every
/// build and must never trigger a `reading_log` scan per frame.
class PracticeProvider with ChangeNotifier {
  final DatabaseHelper _db;

  int _completedCount = 0;
  int _totalDays = 0;
  int _continuity = 0;
  bool _todayComplete = false;

  int get completedCount => _completedCount;
  int get totalDays => _totalDays;
  int get continuity => _continuity;
  bool get todayComplete => _todayComplete;

  /// Resolves once the constructor's initial [refresh] completes. Exists
  /// so callers (tests especially) can join that exact load instead of
  /// triggering a second, concurrent one -- awaiting a fresh [refresh]
  /// call right after construction doesn't cancel the constructor's own
  /// fire-and-forget one, which can then still be in flight later.
  late final Future<void> ready;

  PracticeProvider({DatabaseHelper? databaseHelper})
    : _db = databaseHelper ?? DatabaseHelper() {
    ready = refresh();
  }

  Future<void> refresh() async {
    _completedCount = await _db.getCompletedSongCount();
    _totalDays = await _db.getTotalPracticeDays();
    _continuity = await _db.getCurrentContinuity();
    _todayComplete = await _db.isDayComplete(_today());
    notifyListeners();
  }

  Future<void> recordCompletion(
    int songId,
    int dwellSeconds,
    bool completed,
  ) async {
    await _db.recordDwell(songId, _today(), dwellSeconds, completed);
    await refresh();
  }

  /// Today's hymn, pinned for the whole calendar day: picked once (lowest
  /// uncompleted song id, per [todaysHymnSongId]) and persisted, so
  /// finishing it mid-day does not advance the pick to the next song --
  /// it just shows completed until the day rolls over. Only a new local
  /// date triggers a fresh pick. Returns null when the corpus is empty.
  Future<int?> resolveTodaysHymnId() async {
    final allIds = await _db.getAllSongIds();
    if (allIds.isEmpty) return null;

    final prefs = await SharedPreferences.getInstance();
    final today = _today();
    if (prefs.getString(AppConstants.practiceTodaysHymnDatePrefsKey) == today) {
      final storedId = prefs.getInt(AppConstants.practiceTodaysHymnIdPrefsKey);
      if (storedId != null && allIds.contains(storedId)) {
        return storedId;
      }
    }

    final completedIds = await _db.getCompletedSongIds();
    final hymnId = todaysHymnSongId(
      allSongIds: allIds,
      completedSongIds: completedIds.toSet(),
      date: DateTime.now(),
    );
    await prefs.setString(AppConstants.practiceTodaysHymnDatePrefsKey, today);
    await prefs.setInt(AppConstants.practiceTodaysHymnIdPrefsKey, hymnId);
    return hymnId;
  }

  String _today() {
    final now = DateTime.now();
    final y = now.year.toString().padLeft(4, '0');
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
