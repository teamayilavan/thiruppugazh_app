/// How long since the last successful auto-backup write before the
/// opportunistic startup check forces a fresh one, covering the case where
/// the debounced write never got a chance to fire (app killed too soon).
const Duration autoBackupStaleAfter = Duration(hours: 24);

bool isAutoBackupStale(DateTime? lastWriteAt, DateTime now) {
  if (lastWriteAt == null) return true;
  return now.difference(lastWriteAt) > autoBackupStaleAfter;
}

/// Whether the silent startup auto-restore should run. All three
/// conditions must hold: the database was freshly (re)copied this run (not
/// just an ordinary reopen of existing data), Android actually restored a
/// backup file to disk, and this device hasn't already tried a restore
/// before (a permanent one-shot gate, so this never re-imports on a later
/// launch even if the database is somehow freshly copied again).
bool shouldAttemptAutoRestore({
  required bool isFreshDatabase,
  required bool backupFileExists,
  required bool alreadyAttempted,
}) {
  return isFreshDatabase && backupFileExists && !alreadyAttempted;
}
