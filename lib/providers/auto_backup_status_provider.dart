import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';

/// Exposes when the silent auto-backup last wrote successfully, for the
/// read-only "Last automatic backup: ..." line in Settings. Loaded from
/// and persisted to [SharedPreferences]; [AutoBackupService] calls
/// [recordBackup] after each successful write so the Settings line updates
/// live without the screen needing to be rebuilt from scratch.
class AutoBackupStatusProvider extends ChangeNotifier {
  AutoBackupStatusProvider() {
    ready = _load();
  }

  /// Completes once the persisted last-backup time has been loaded, so
  /// callers that read [lastBackupAt] at startup (the opportunistic
  /// staleness check) don't race the initial load.
  late final Future<void> ready;

  DateTime? _lastBackupAt;
  DateTime? get lastBackupAt => _lastBackupAt;

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final iso = prefs.getString(AppConstants.autoBackupLastWriteAtPrefsKey);
    if (iso != null) {
      _lastBackupAt = DateTime.tryParse(iso);
    }
    notifyListeners();
  }

  Future<void> recordBackup(DateTime time) async {
    _lastBackupAt = time;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      AppConstants.autoBackupLastWriteAtPrefsKey,
      time.toIso8601String(),
    );
    notifyListeners();
  }
}
