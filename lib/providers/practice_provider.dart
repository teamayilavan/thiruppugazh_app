import 'package:flutter/material.dart';
import '../data/database/database_helper.dart';

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

  PracticeProvider({DatabaseHelper? databaseHelper})
    : _db = databaseHelper ?? DatabaseHelper() {
    refresh();
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

  String _today() {
    final now = DateTime.now();
    final y = now.year.toString().padLeft(4, '0');
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
