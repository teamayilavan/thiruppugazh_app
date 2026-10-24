import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../utils/app_logger.dart';

/// How the learner was last engaging with a song.
enum ResumeMode { read, chant }

/// Remembers the songs the user opened most recently and, for chanting mode,
/// which couplet they were on, so the Home screen can offer "Continue".
///
/// Stored as one small JSON blob in SharedPreferences -- no database change.
/// Only song ids and an index are kept (no lyrics), so a value restored from
/// another device's Auto Backup is harmless: song ids are stable across
/// installs.
class ReadingStateProvider with ChangeNotifier {
  static const int maxRecent = 10;

  List<int> _recent = [];
  ResumeMode _mode = ResumeMode.read;
  final Map<int, int> _chantPositions = {};

  /// Completes when the saved state has been read (or found unusable).
  late final Future<void> ready;

  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  /// Notifies listeners, but never in the middle of a frame. A song page
  /// records itself as opened from initState, i.e. while Flutter is
  /// building; a notification sent then is dropped for the widgets above it
  /// (in debug builds), leaving the Home "Continue" card stale. Waiting for
  /// the end of the frame makes it reach everyone.
  void _notify() {
    if (_disposed) return;
    final binding = SchedulerBinding.instance;
    if (binding.schedulerPhase == SchedulerPhase.persistentCallbacks) {
      binding.addPostFrameCallback((_) {
        if (!_disposed) notifyListeners();
      });
    } else {
      notifyListeners();
    }
  }

  ReadingStateProvider() {
    ready = _load();
  }

  /// Most recently opened first.
  List<int> get recentSongIds => List.unmodifiable(_recent);

  int? get lastSongId => _recent.isEmpty ? null : _recent.first;

  /// How the last song was being used. Chanting only counts if a position
  /// is actually saved for it.
  ResumeMode get lastMode =>
      _mode == ResumeMode.chant && lastChantIndex != null
      ? ResumeMode.chant
      : ResumeMode.read;

  /// The couplet the user was on in chanting mode for the last song.
  int? get lastChantIndex {
    final id = lastSongId;
    return id == null ? null : _chantPositions[id];
  }

  int? chantIndexFor(int songId) => _chantPositions[songId];

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(AppConstants.readingStatePrefsKey);
      if (raw == null) return;
      final map = jsonDecode(raw) as Map<String, dynamic>;

      _recent = [
        for (final id in (map['recent'] as List? ?? const []))
          if (id is int) id,
      ].take(maxRecent).toList();
      _mode = map['mode'] == 'chant' ? ResumeMode.chant : ResumeMode.read;
      final positions = map['chant'] as Map<String, dynamic>? ?? const {};
      for (final entry in positions.entries) {
        final id = int.tryParse(entry.key);
        final index = entry.value;
        if (id != null && index is int && index >= 0 && _recent.contains(id)) {
          _chantPositions[id] = index;
        }
      }
      _notify();
    } catch (e, st) {
      // A corrupt blob must never break the app; start clean.
      AppLogger.error('Reading state unreadable; resetting', error: e, stackTrace: st);
      _recent = [];
      _chantPositions.clear();
      _mode = ResumeMode.read;
    }
  }

  /// Call when a song's page is opened.
  Future<void> recordOpened(int songId) async {
    _touch(songId);
    _mode = ResumeMode.read;
    await _save();
  }

  /// Call as the user moves through couplets in chanting mode.
  Future<void> recordChantPosition(int songId, int coupletIndex) async {
    _touch(songId);
    _mode = ResumeMode.chant;
    _chantPositions[songId] = coupletIndex < 0 ? 0 : coupletIndex;
    await _save();
  }

  /// Forgets the saved chanting position, e.g. after finishing a song.
  Future<void> clearChantPosition(int songId) async {
    if (_chantPositions.remove(songId) == null) return;
    await _save();
  }

  void _touch(int songId) {
    _recent.remove(songId);
    _recent.insert(0, songId);
    if (_recent.length > maxRecent) {
      _recent = _recent.sublist(0, maxRecent);
    }
    // Positions are only worth keeping for songs still in the recent list.
    _chantPositions.removeWhere((id, _) => !_recent.contains(id));
  }

  Future<void> _save() async {
    _notify();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        AppConstants.readingStatePrefsKey,
        jsonEncode({
          'recent': _recent,
          'mode': _mode == ResumeMode.chant ? 'chant' : 'read',
          'chant': {
            for (final e in _chantPositions.entries) '${e.key}': e.value,
          },
        }),
      );
    } catch (e, st) {
      AppLogger.error('Saving reading state failed', error: e, stackTrace: st);
    }
  }
}
