import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';
import '../data/database/database_helper.dart';
import '../providers/auto_backup_status_provider.dart';
import '../utils/app_logger.dart';
import 'auto_backup_policy.dart';
import 'backup_service.dart';

const String _autoBackupFileName = 'thiruppugazh_auto_backup.json';

/// Wires [DatabaseHelper.onMutation] to a debounced write of the
/// auto-backup snapshot, and on startup either writes one opportunistically
/// (if the last one is stale) or silently restores from a previously
/// Android-restored file (if this is a genuinely fresh install). See
/// `docs/automated-backup-plan.md` for the full design.
///
/// [backupJsonBuilder] and [applyImport] are injected (defaulting to a real
/// [BackupService]'s methods) so this class is testable without a real
/// database; [backupDirectory] is injected (defaulting to
/// `getApplicationDocumentsDirectory()/auto_backup`) so it's testable
/// without `path_provider`.
class AutoBackupService {
  AutoBackupService({
    Future<Map<String, dynamic>> Function()? backupJsonBuilder,
    Future<dynamic> Function(Map<String, dynamic>)? applyImport,
    required AutoBackupStatusProvider statusProvider,
    Directory? backupDirectory,
    this.debounceDuration = const Duration(seconds: 5),
  }) : _backupJsonBuilder = backupJsonBuilder ?? BackupService().buildBackupJson,
       _applyImport = applyImport ?? BackupService().applyImport,
       _statusProvider = statusProvider,
       _injectedBackupDirectory = backupDirectory;

  final Future<Map<String, dynamic>> Function() _backupJsonBuilder;
  final Future<dynamic> Function(Map<String, dynamic>) _applyImport;
  final AutoBackupStatusProvider _statusProvider;
  final Directory? _injectedBackupDirectory;
  final Duration debounceDuration;

  Timer? _debounceTimer;

  Future<Directory> _resolveBackupDirectory() async {
    final injected = _injectedBackupDirectory;
    if (injected != null) return injected;
    final docsDir = await getApplicationDocumentsDirectory();
    return Directory(p.join(docsDir.path, 'auto_backup'));
  }

  Future<File> _backupFile() async {
    final dir = await _resolveBackupDirectory();
    return File(p.join(dir.path, _autoBackupFileName));
  }

  /// Called by [DatabaseHelper.onMutation] on every data change. Coalesces
  /// rapid successive changes into a single write [debounceDuration] after
  /// the last one.
  void onMutation() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(debounceDuration, () {
      unawaited(writeNow());
    });
  }

  /// Writes the current backup snapshot to disk immediately and records
  /// the time. Safe to call directly (used by the opportunistic startup
  /// check) or via the debounced [onMutation] path.
  Future<void> writeNow() async {
    try {
      final map = await _backupJsonBuilder();
      final file = await _backupFile();
      await file.parent.create(recursive: true);
      await file.writeAsString(jsonEncode(map));
      await _statusProvider.recordBackup(DateTime.now());
    } catch (e, stackTrace) {
      AppLogger.error('Auto-backup write failed', error: e, stackTrace: stackTrace);
    }
  }

  /// If a backup was restored by Android onto a genuinely fresh database,
  /// silently imports it exactly once. Must be called after the app's
  /// database has been confirmed usable this run (so [isFreshDatabase]
  /// reflects [DatabaseHelper.wasFreshlyCreated] correctly).
  Future<void> maybeRestore({required bool isFreshDatabase}) async {
    final prefs = await SharedPreferences.getInstance();
    final alreadyAttempted =
        prefs.getBool(AppConstants.autoRestoreAttemptedPrefsKey) ?? false;
    final file = await _backupFile();
    final fileExists = await file.exists();

    if (!shouldAttemptAutoRestore(
      isFreshDatabase: isFreshDatabase,
      backupFileExists: fileExists,
      alreadyAttempted: alreadyAttempted,
    )) {
      return;
    }

    try {
      final content = await file.readAsString();
      final map = jsonDecode(content) as Map<String, dynamic>;
      await _applyImport(map);
      AppLogger.info('Silently restored auto-backup on fresh install');
    } catch (e, stackTrace) {
      AppLogger.error('Auto-restore failed', error: e, stackTrace: stackTrace);
    } finally {
      // Set the flag even on failure -- this is a one-shot gate, not a
      // retry mechanism; a corrupt restored file shouldn't be retried
      // forever on every launch.
      await prefs.setBool(AppConstants.autoRestoreAttemptedPrefsKey, true);
    }
  }

  /// Wires the mutation hook and runs the opportunistic staleness check.
  /// Call once at app startup, after [maybeRestore].
  void startWatchingMutations() {
    DatabaseHelper.onMutation = onMutation;
  }

  Future<void> runOpportunisticCheck() async {
    if (isAutoBackupStale(_statusProvider.lastBackupAt, DateTime.now())) {
      await writeNow();
    }
  }

  void dispose() {
    _debounceTimer?.cancel();
    if (identical(DatabaseHelper.onMutation, onMutation)) {
      DatabaseHelper.onMutation = null;
    }
  }
}
