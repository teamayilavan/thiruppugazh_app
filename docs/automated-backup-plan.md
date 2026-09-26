# Automated Data Backup: Plan

**Status:** 🟡 Planned, not started — write-up for review before implementation.
**Date written:** 2026-09-26
**Branch:** `next`

---

## 1. What this covers

Two related pieces of work:

- **Part A** — automated, invisible backup of user data (favorites, categories, notes, highlights, settings) via Android's built-in Auto Backup to the user's own Google Drive, so people stop losing data on uninstall/reinstall/device loss without having to remember to tap "Export."
- **Part B** — hardening the *existing* manual Export/Import feature (`lib/services/backup_service.dart`), since Part A reuses its core logic and several real correctness gaps surfaced while reviewing it.

Neither part requires a server, an account system, or any new third-party service. Everything stays inside the app + the user's own Google account, consistent with how the rest of this app works.

---

## 2. What already exists (read before building)

`lib/services/backup_service.dart` already does the hard part: `exportData()` gathers favorites, custom categories (with their song lists), notes, and highlights into one JSON document and hands it to the OS share sheet; `importData()` reads a picked JSON file, validates its shape (`_validateBackupMap`), and merges/overwrites it into the local database.

Crucially, **the export is already small and already separated from the big bundled song database** — it's just user-generated data as JSON, typically a few KB. That's what makes Part A cheap: there's no need to back up the ~38MB `thiruppugazh.db` at all (it's read-only, ships with the app, and is already self-healing on corruption per the database fixes in `docs/crash-reporting-decision.md`).

`android/app/src/main/AndroidManifest.xml` currently has **no backup configuration at all** — meaning Android's Auto Backup is already *on* (it's on by default) but *unconfigured*, which today means it would try to back up the app's entire private storage, including that same 38MB read-only database, wasting the free backup quota on data that doesn't need protecting.

---

## 3. Part A — Automated backup via Android Auto Backup

### 3.1 How it works, in short

Android's Auto Backup (all API levels this app supports) periodically uploads specified app files to the signed-in user's Google Drive, in a special app-data area that doesn't count against the user's visible Drive storage and that they can't browse directly. On reinstall, or on a new device signed into the same Google account, Android restores those files **before the app's own code runs for the first time**. No server, no API integration, no user-visible login flow beyond the Google account already on their phone.

- Runs roughly once every 24 hours, only when the device is idle, charging, and on Wi-Fi (Android controls timing, not us).
- Free tier is generous for something this small (default quota 25MB/app; our target file is KB-sized).
- Works fully offline for the app itself — this is a background OS concern, not something the app depends on to function.

### 3.2 Design

**What gets backed up:** a single, fixed-name JSON file (not timestamped — one rolling file, so it never accumulates or wastes quota), written to the app's internal files directory (`getApplicationDocumentsDirectory()`, *not* the temp/cache directory — Android's Auto Backup explicitly never includes cache dirs), e.g.:

```
files/auto_backup/thiruppugazh_auto_backup.json
```

Plus: `shared_preferences` (small, and worth restoring too — theme, language, reminder time/enabled, lyrics font size). Everything else, especially `databases/thiruppugazh.db`, is explicitly excluded.

**When it writes:** two triggers, combined —
1. **Debounced on data change.** Favoriting a song, editing a category, saving a note, adding a highlight — each marks the backup "dirty" and schedules a rewrite ~5 seconds after the last change (so rapid successive edits don't each trigger a disk write).
2. **Opportunistic on app start.** If it's been more than a day since the last successful auto-backup write (covers the case where the app was killed before a debounced write fired).

**Where the logic lives:** refactor `BackupService.exportData()` so the "gather data → build the JSON map" step is its own pure method (`buildBackupJson()`), used by both the existing manual share-sheet export *and* the new silent auto-backup writer. One source of truth for the backup format — Part B's correctness fixes benefit both paths automatically.

**The restore side — this is the part that actually closes the loop.** Auto Backup restoring the file to disk is not enough by itself; the app has to notice it and import it. On startup, after the database is confirmed usable (see `docs/crash-reporting-decision.md` for why that check matters), check:

- Is this a *genuinely fresh* database (freshly created/copied this run, not just "app reopened")?
- Does `files/auto_backup/thiruppugazh_auto_backup.json` exist (i.e. Android restored one)?
- Has an auto-restore not already been attempted (`SharedPreferences` flag, checked once, so this never re-runs or re-imports on every ordinary launch)?

If all three: run the same import logic silently (no dialog, no user action), then set the flag so it never runs again. If the device restore included `shared_preferences`, settings come back for free with no extra code.

**Manifest changes needed:**
- `android:allowBackup="true"` — explicit (already the default, but should be intentional, not accidental).
- `android:fullBackupContent="@xml/backup_rules"` — legacy rules, API ≤ 30.
- `android:dataExtractionRules="@xml/data_extraction_rules"` — API 31+, covers both cloud backup and the newer device-to-device transfer feature.
- Both XML files: include only `files/auto_backup/` and `shared_prefs/`; exclude `databases/` explicitly.

(Two rule files are needed because this project deliberately keeps `minSdk` at Flutter's default for broad device support — see `docs/android-16-target-sdk-upgrade.md` — so both the old and new backup-rule formats have to be covered.)

**User-visible surface — deliberately minimal.** No new toggle, no new permission prompt. This is just correctly configuring an OS feature every Android app already has on by default; no new data leaves the device to any third party beyond the user's own Google account. The one addition: a quiet, read-only line in Settings near the existing Export/Import buttons — "Last automatic backup: `<time>`" — so people have *some* confirmation it's working, without needing to think about it.

### 3.3 What this does *not* solve

- Doesn't help iOS (not a concern — this app is Android-only per earlier direction).
- Depends on the device's Google account + Play Services backup transport actually working. Most phones, but some OEMs (MIUI included, per the Redmi 10 history in `docs/crash-reporting-decision.md`) have had backup-service quirks. Not a guarantee, just a strong default — same caveat noted for Crashlytics.
- Android controls the actual backup schedule; there's no way to force an instant backup on demand beyond calling `BackupManager.dataChanged()` to *request* an opportunistic pass, which the OS may still delay.

---

## 4. Part B — Hardening manual Export/Import

Found while reading `backup_service.dart` end to end, unrelated to Part A but worth fixing at the same time since Part A reuses this exact code path:

| Issue | Why it matters | Fix |
|---|---|---|
| **No transaction around import.** Each favorite/category/note/highlight is written in its own separate `await`. If the import fails or the app is killed partway through, the database is left half-imported with no rollback. | Silent partial-data corruption is exactly the kind of bug this whole effort (see `docs/crash-reporting-decision.md`) is trying to stop causing. | Wrap the whole mutation sequence in a single `db.transaction()`. |
| **`version` field is written but never checked.** A future format change (`version: 2`) would be silently mis-imported by an app that only understands `version: 1`, or vice versa. | Forward/backward compatibility currently doesn't exist despite the field being there. | `_validateBackupMap` should read `version` and branch/reject with a clear message for versions it doesn't understand. |
| **No preview/confirmation before a destructive import.** Notes and highlights are *overwritten* unconditionally; there's no "this backup has X favorites, Y categories, Z notes from `<date>` — continue?" step. | Picking the wrong file (or an old one) currently overwrites data with zero warning. | Parse and show a short summary before committing, with an explicit confirm step. |
| **No import result summary.** A song ID in the backup that doesn't exist in this install just silently no-ops. | User has no way to know if their restore was actually complete. | Track and report counts: "Imported 40 of 42 favorites; 2 songs not found." |
| **Raw exception text shown to the user** (`Export failed: ${e.toString()}`). | Unfriendly, sometimes exposes internal detail for no benefit. | Map known exception types (`FormatException`, file errors) to plain-language messages; keep the raw error only in `AppLogger`. |
| **Category matching for merge is exact-string-match only.** | Minor: a slightly-renamed category creates a duplicate instead of merging. Not a correctness bug, just a rough edge. | Note for awareness; not blocking, can defer. |

---

## 5. Suggested order of work

1. Part B first (transaction safety, version check, confirmation step, result summary) — it's the correctness foundation, and Part A depends on the same code being reusable/correct.
2. Refactor `buildBackupJson()` out as a shared pure function.
3. Silent auto-backup writer (debounced + opportunistic triggers) writing to `files/auto_backup/`.
4. Manifest + `backup_rules.xml` / `data_extraction_rules.xml`.
5. Startup auto-restore check (fresh-DB + file-exists + not-already-attempted).
6. "Last automatic backup" status line in Settings.
7. Manual, on-device verification: back up on one emulator instance, uninstall, reinstall, confirm data comes back with no user action (this needs an actual Google-account-signed-in device/emulator with Play Services — the standard AVD Play Store images support this; a plain Google APIs image without Play Store may not).

---

## 6. Open questions for the user

- Any objection to the minimal Settings addition ("Last automatic backup: ...")?
- Confirm: no opt-out toggle needed for Part A specifically (unlike the earlier crash-reporting discussion, this isn't sending data anywhere new — it's the user's own device data going to their own Google account via a standard OS feature already on by default). Flag if this reasoning feels wrong.
- Part B's confirmation-before-import step adds one extra tap to the existing manual flow — fine, or prefer to keep it a single tap and only add the post-import summary?
