# Production Observability: the "empty database on fresh install" incident, and whether to add crash/error reporting

**Status:** 🟡 Decision pending — the underlying bug is already fixed and shipped (see Section 2). This doc is about whether to add production error visibility so incidents like this are caught automatically next time, instead of relying on a user reporting it manually.
**Date written:** 2026-09-26
**Branch:** `next`

---

## 1. The incident

A user (on a Redmi 10 / MIUI device) reported: after the app had been updated several times, doing an uninstall + reinstall (including clearing app data, multiple times) resulted in every screen being empty — no songs, no temples, no data at all. This was a real, reproducible class of bug, not a one-off device fluke.

## 2. Root cause and fixes (already shipped on `next`)

Investigation traced this to `lib/data/database/database_helper.dart`'s first-run database bootstrap (copies a bundled `assets/thiruppugazh.db` into the app's private storage on first launch). Three related, independently-verified failure modes were found and fixed:

| Commit | What it fixes | How it was verified |
|---|---|---|
| `d113bf0` | A partial/corrupted copy of the bundled asset (e.g. device low on storage, process killed mid-write) was trusted without checking — silently left every screen empty, no error anywhere. Also: `_migrateToV3`/`_migrateToV4`'s `ALTER TABLE ADD COLUMN` calls were unguarded — a "duplicate column name" exception outside any try/catch would poison the app's single cached database connection, same silent-empty-everywhere symptom. | Live device test: forced an already-fully-migrated database's version marker back to an old value and relaunched; confirmed via logcat both migrations ran to completion with zero errors and all 1334 songs intact (would have thrown immediately without the fix). |
| `f92eab3` | `databaseExists()` only checks that *a file* is present at the DB path, not that it's usable. A corrupted/empty file left over from any past failure would be opened as-is forever, on every future launch, with no way to recover short of the app noticing itself. | Live device test: corrupted the on-device database file directly, relaunched, confirmed via logcat the app detected it ("Existing database failed usability check"), re-copied from the bundled asset, and fully recovered — song list restored, no user action needed. |
| `229d938` | (Unrelated bug found in the same investigation window, different root cause — casual "Tanglish" search spelling not matching the formal transliteration stored for temple names. Included here only for the date/commit trail, see its own commit message for detail.) | — |

**None of these fixes require a schema change or migration** — they're all query-time/copy-time defensive checks. Existing installs are unaffected either way.

**Residual gap, not fixed (flagged, not yet built):** if the *existing* file on disk is a valid-but-different-schema SQLite file rather than garbage (a much rarer case), the new usability check (`SELECT COUNT(*) FROM songs`) might still pass while other things are subtly wrong. Not observed, not chased further — would need real evidence to justify.

## 3. The actual problem this doc is about

None of the above fixes solve the *meta* problem: **we only found out about this because a user happened to mention it.** If it happens again — this exact bug, a regression, or something new — the default outcome is still "nobody at Ayilavan knows until someone complains."

### What Play Console already gives us for free

Play Console → **Quality → Android vitals → Crashes & ANRs** — automatic, zero setup, works for any Play Store app. Shows stack traces, affected device/OS breakdowns, trends.

**The catch: this incident was not a crash.** The app never threw an uncaught exception or hung the UI thread — it just silently rendered empty state. Play Console's built-in reporting would have shown *nothing* for this specific incident. It only helps for actual crashes/ANRs, which is a narrower category than "the app is broken."

## 4. Proposed fix: Firebase Crashlytics, with non-fatal error routing

**Crashlytics** (free, standard for Flutter) would close this gap, but only if set up correctly — a naive "just add Crashlytics" wouldn't have caught this bug either, since it too only reports crashes by default.

Two parts needed together:

1. **Crashlytics for real crashes** — automatic once integrated.
2. **Route `lib/utils/app_logger.dart`'s `AppLogger.error()` calls to Crashlytics as non-fatal events.** This is the part that actually matters for this incident — `AppLogger.error()` is already called at every one of the failure points fixed in Section 2 (e.g. "Existing database failed usability check"). Today those calls only `print()` in debug mode and do nothing in release (see the comment already in that file: *"In release mode, send logs to crash reporting/analytics service e.g., Firebase Crashlytics, Sentry, etc."* — never implemented). Wiring this up means the exact log lines that let us diagnose this bug in a controlled test would show up in a dashboard from a real user's phone, the moment it happens, with no user action required.

### Does this require an internet connection?

No. The app keeps working 100% offline; nothing about existing functionality changes. Crashlytics queues reports locally and uploads them whenever the app next has connectivity (typically next launch while online). It's not a requirement for the app to function, just for *us* to find out about problems.

### Play Store / privacy implications

- **Play Console "Data safety" form must be updated** to declare collection of crash logs / diagnostics and a device/app-instance identifier (Firebase Installation ID). This is a mandatory form update on the Play Console listing, not a code change — but it is required before shipping this.
- **In-app runtime consent prompt: probably not needed**, *if* we add Crashlytics only (no Google Analytics for Firebase bundled alongside it). Analytics is what typically triggers Google's EU User Consent Policy requirement for an explicit consent flow; plain crash/diagnostics reporting generally does not. Recommendation: don't enable Analytics, just Crashlytics.
- **Privacy Policy screen** (already exists in-app, `lib/ui/screens/privacy_policy_screen.dart`) needs a short addition disclosing crash/diagnostic reporting.

### Should it be opt-in (off by default) or on by default?

**On by default — not opt-in.** This was explicitly discussed and corrected mid-conversation: an opt-in toggle in Settings is useless for exactly this incident, because the user who hits a broken fresh install never gets to a working Settings screen to opt in. Every other opt-in feature in this app (the daily reminder notification) is opt-in because it's a *user-facing behavior with an intrusion tradeoff* (notifications). Crash/diagnostic reporting is invisible infrastructure with a different risk profile — the standard, Play-policy-compliant pattern for it is default-on with disclosure via the Data Safety label and Privacy Policy, not a runtime prompt.

**Still worth adding:** a "disable crash reporting" toggle in Settings for privacy-conscious users who want to turn it *off* (opt-out, not opt-in) — this doesn't undermine catching first-launch failures, since it defaults on.

## 5. Recommendation (for when this gets picked back up)

1. Add `firebase_crashlytics` (+ `firebase_core`), Crashlytics only — no Analytics.
2. Route `AppLogger.error()` → `FirebaseCrashlytics.instance.recordError(..., fatal: false)` in release builds.
3. Default enabled; add an opt-*out* toggle in Settings (mirrors existing Settings patterns).
4. Update the in-app Privacy Policy screen with a short disclosure.
5. Update Play Console's Data Safety form before the next release that includes this.
6. Requires a Firebase project to be created (user's own Google/Firebase account — not something that can be done from this session).

## 6. Open questions for the user to decide before proceeding

- Confirm: Firebase project setup, on your end, before any code changes here.
- Confirm: comfortable with default-on (vs. sticking with opt-in and accepting the coverage gap for first-launch failures)?
- Any preference on wording for the Privacy Policy disclosure, or should a draft be proposed once we pick this back up?
