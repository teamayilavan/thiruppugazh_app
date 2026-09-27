import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../data/database/database_helper.dart';
import '../providers/auto_backup_status_provider.dart';
import '../utils/app_logger.dart';
import 'auto_backup_policy.dart';
import 'backup_service.dart';

const String _autoBackupSubdirectory = 'auto_backup';
const String _autoBackupFileName = 'thiruppugazh_auto_backup.json';
const String _autoRestoreAttemptedMarkerFileName =
    'auto_restore_attempted.marker';

/// Wires [DatabaseHelper.onMutation] to a debounced write of the
/// auto-backup snapshot, and on startup either writes one opportunistically
/// (if the last one is stale) or silently restores from a previously
/// Android-restored file (if this is a genuinely fresh install). See
/// `docs/automated-backup-plan.md` for the full design.
///
/// On-disk layout (base = `getApplicationSupportDirectory()`, which on
/// Android is `context.getFilesDir()`, i.e. `files/`):
///
/// * `<base>/auto_backup/thiruppugazh_auto_backup.json` -- the snapshot.
///   This is the ONLY path the Android backup rules include from the
///   `file` domain (`<include domain="file" path="auto_backup/" />`).
/// * `<base>/auto_restore_attempted.marker` -- the local-only one-shot
///   restore gate. Deliberately a sibling of `auto_backup/`, not inside it,
///   so it is never backed up. (It must not live in SharedPreferences:
///   all of `shared_prefs/` is backed up, so a "restore already attempted"
///   flag there would ride along to the next device and permanently
///   disable restore.)
///
/// [backupJsonBuilder] and [applyImport] are injected (defaulting to a real
/// [BackupService]'s methods) so this class is testable without a real
/// database; [backupDirectory] (defaulting to `<base>/auto_backup`) and
/// [attemptedMarkerDirectory] (defaulting to `<base>`) are injected so it's
/// testable without `path_provider`.
class AutoBackupService {
  AutoBackupService({
    Future<Map<String, dynamic>> Function()? backupJsonBuilder,
    Future<dynamic> Function(Map<String, dynamic>)? applyImport,
    required AutoBackupStatusProvider statusProvider,
    Directory? backupDirectory,
    Directory? attemptedMarkerDirectory,
    this.debounceDuration = const Duration(seconds: 5),
  }) : _backupJsonBuilder = backupJsonBuilder ?? BackupService().buildBackupJson,
       _applyImport = applyImport ?? BackupService().applyImport,
       _statusProvider = statusProvider,
       _injectedBackupDirectory = backupDirectory,
       _injectedAttemptedMarkerDirectory = attemptedMarkerDirectory;

  final Future<Map<String, dynamic>> Function() _backupJsonBuilder;
  final Future<dynamic> Function(Map<String, dynamic>) _applyImport;
  final AutoBackupStatusProvider _statusProvider;
  final Directory? _injectedBackupDirectory;
  final Directory? _injectedAttemptedMarkerDirectory;
  final Duration debounceDuration;

  Timer? _debounceTimer;

  /// The base directory both the backup subdirectory and the restore
  /// marker live under.
  ///
  /// Uses `getApplicationSupportDirectory()`, NOT
  /// `getApplicationDocumentsDirectory()`: on Android, path_provider maps
  /// the "documents" directory to `context.getDir("flutter")` (i.e.
  /// `app_flutter/`), whereas the "support" directory is
  /// `context.getFilesDir()` (i.e. `files/`) -- and `files/` is what the
  /// Android backup rules' `domain="file"` refers to. Using the documents
  /// directory would silently write the snapshot somewhere Android Auto
  /// Backup never looks.
  Future<Directory> _resolveBaseDirectory() async {
    return getApplicationSupportDirectory();
  }

  Future<Directory> _resolveBackupDirectory() async {
    final injected = _injectedBackupDirectory;
    if (injected != null) return injected;
    final baseDir = await _resolveBaseDirectory();
    return Directory(p.join(baseDir.path, _autoBackupSubdirectory));
  }

  Future<File> _backupFile() async {
    final dir = await _resolveBackupDirectory();
    return File(p.join(dir.path, _autoBackupFileName));
  }

  /// The one-shot restore marker. Lives directly in the base directory, as
  /// a sibling of `auto_backup/` (never inside it), so the Android backup
  /// rules never select it -- it's purely local state.
  Future<File> _attemptedMarkerFile() async {
    final dir = _injectedAttemptedMarkerDirectory ?? await _resolveBaseDirectory();
    return File(p.join(dir.path, _autoRestoreAttemptedMarkerFileName));
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
    final marker = await _attemptedMarkerFile();
    final alreadyAttempted = await marker.exists();
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
      // Same version gate as the manual import path; an unsupported or
      // missing version throws FormatException and is logged below.
      validateBackupVersion(map);
      await _applyImport(map);
      AppLogger.info('Silently restored auto-backup on fresh install');
    } catch (e, stackTrace) {
      AppLogger.error('Auto-restore failed', error: e, stackTrace: stackTrace);
    } finally {
      // Create the marker even on failure -- this is a one-shot gate, not a
      // retry mechanism; a corrupt restored file shouldn't be retried
      // forever on every launch.
      try {
        await marker.parent.create(recursive: true);
        await marker.writeAsString('');
      } catch (e, stackTrace) {
        AppLogger.error(
          'Failed to write auto-restore marker',
          error: e,
          stackTrace: stackTrace,
        );
      }
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
