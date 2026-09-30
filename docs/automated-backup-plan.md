# Automated Data Backup: Plan

**Status:** ✅ Shipped (2026-09-27) — implemented via `superpowers:subagent-driven-development` across 9 tasks, then a whole-branch review, one fix wave, and manual on-device verification. Landed on `next` as commits `f0722be`..`521a61f`; the notification icon fix landed separately as `de03d82`.
**Date written:** 2026-09-26

---

## 0. Post-implementation notes

Two Critical defects were found and fixed during the final whole-branch review, before this ever shipped — both traced to this plan's own assumptions, not implementation slips:

1. **Wrong backup directory.** `getApplicationDocumentsDirectory()` (what §3.2 below specifies) resolves to `app_flutter/` on Android, not `files/` — but the Android backup rules only cover `files/`. Fixed by switching to `getApplicationSupportDirectory()`, which actually maps to `files/`. Verified against `path_provider_android`'s own plugin source before fixing, not just inferred.
2. **The one-shot restore flag was itself getting backed up.** It lived in `SharedPreferences`, which the backup rules fully include (so settings/theme/language restore too) — meaning after one successful restore, the flag rode along in every later backup and silently disabled restore forever on a user's *second* reinstall. Fixed by moving the flag to a plain marker file that sits outside the `auto_backup/` directory the rules whitelist.

Both were verified fixed on a real emulator using Android's local backup transport (a faithful proxy for the real cloud transport — same OS file-selection and restore-before-first-launch code paths, different upload destination): favorited a song, ran a real backup pass, confirmed only the small JSON + shared-prefs got backed up (not the 38MB database), uninstalled/reinstalled, and watched Android's own `BackupManagerService` restore the file *before first launch* — the app then silently imported it with zero dialogs, visible in the UI.

**Not verified:** the actual Google Drive network leg with a real signed-in account and the real cloud transport — the test emulator image doesn't include Play Store. This is a Play Services implementation detail outside the app's own code, and the on-device test above exercises everything this app's code controls.

The rest of this document is the original design write-up, kept as-is for the reasoning behind each decision — it does not reflect the two fixes above inline.

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

## 6. Open questions for the user — resolved (2026-09-27)

- Settings addition: **approved**, shipped as-is.
- Opt-out toggle for Part A: **confirmed not needed**, none added.
- Part B confirmation step: **approved**, shipped as a real dialog showing the file's actual contents (counts, export date), not just a generic message.
