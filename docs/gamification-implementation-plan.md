# Gamification — Phased Development Plan (Agent Instructions)

**Companion to:** [`gamification-strategy.md`](gamification-strategy.md) — *what* and *why*.
This document is *how*, written to be executed by a coding agent.
**Baseline:** v1.4.0+6, DB schema **v4** (mayuragiri word-separated lyrics merged to `main`
2026-09-22), `main` clean.

> **Revision note (2026-09-22):** this plan was originally written against a v1.3.0+5 / schema-v3
> baseline. The mayuragiri word-separated lyrics feature shipped to the Play Store and merged to
> `main` in the meantime, claiming **schema v4** for itself (`_migrateToV4` already exists in
> `database_helper.dart`). Every DB version number below has been shifted up by one to account for
> this: the practice tables in Phase 1 now land as **v5** (not v4), and Phase 3's ordered
> recitation sets now land as **v6** (not v5). If a future merge claims another version number out
> from under this plan, repeat this shift before starting the affected task.

---

## How to use this document

Work **one task at a time, in order**. Each task is a self-contained unit with an ID, a file
list, a spec, and acceptance criteria. Do not start a task whose dependencies are unmet.

For every task:

1. Read the task's **Files** list and the existing code in them before writing anything.
2. Implement the **Spec**.
3. Run the **Verify** block. It must pass before the task is considered done.
4. Commit with the given message. One task = one commit.

**Do not batch tasks into one commit.** Do not skip ahead to a later phase because a task
looks small. If a task's spec conflicts with what you find in the code, stop and report the
conflict rather than improvising.

### Standing verification (after every task)

```bash
flutter analyze --no-fatal-infos    # must be clean
flutter test                        # must pass
dart format --set-exit-if-changed lib test   # must be clean
```

Any task touching `lib/l10n/*.arb` additionally requires:

```bash
flutter gen-l10n
```

### Conventions to follow (derived from the existing codebase — do not invent new ones)

| Concern | Convention | Reference |
|---|---|---|
| Constants | Everything goes in `AppConstants`; no magic numbers in widgets | `lib/constants/app_constants.dart` |
| Colors | `AppColors` + `AppColorExtension`; never a raw `Color(0xFF…)` in a widget | `lib/theme/app_theme.dart`, `docs/color-guide.md` |
| Providers | `ChangeNotifier`, load from `SharedPreferences` in the constructor, `notifyListeners()` after load | `lib/providers/lyrics_font_size_provider.dart` |
| Provider registration | `MultiProvider` list in `main.dart` | `lib/main.dart` |
| DB access | `DatabaseHelper` singleton, methods return models or `Map<String, dynamic>` | `lib/data/database/database_helper.dart` |
| Models | `toMap()` / `fromMap()` pair | `lib/data/models/note_model.dart` |
| Logging | `AppLogger.info/error` — never `print` | `lib/utils/app_logger.dart` |
| Strings | **Both** `app_en.arb` and `app_ta.arb`, then regenerate | `lib/l10n/` |
| Commits | `feat:` / `fix:` / `chore:` / `docs:` / `style:` | `git log` |

> ⚠️ **l10n is a known repeat failure in this repo.** Commit `269489d` exists solely to fix ARB
> keys that were added to one file and not the other. **Every new string goes into both
> `app_en.arb` and `app_ta.arb` in the same commit**, with a real Tamil translation — never an
> English placeholder in the Tamil file.

---

## Standing rules — never violate these

These come from §5 and §11 of the strategy. They are not negotiable and they are not subject to
your judgement mid-task. If a task seems to require breaking one, stop and report.

1. **Never gate a hymn.** No content is ever locked behind progress, payment or a streak.
2. **Never shame a missed day.** No red, no "lost", no flame, no guilt copy.
3. **No leaderboards of devotion.** No ranking of people.
4. **No invented currency.** Hymns read is the only number. No XP, no points, no levels.
5. **Completion is earned by real reading** (dwell rule, T1.6). Never credit on tap.
6. **Nothing leaves the device.** No network call that transmits user state. Ever.
7. **The whole layer is optional** — `PracticeSettingsProvider.enabled == false` must restore
   the exact v1.3.0 experience.
8. **No red** in any progress or streak UI (`color-guide.md` rule 4).
9. **No hardcoded abode/milestone colors** — `dynamic_color` is active; derive from `ColorScheme`.
10. **No new animation or game-UI dependency.** Material 3 primitives only.

---

## ⚠️ The migration trap — read before Phase 1

The bundled asset `assets/thiruppugazh.db` has **`PRAGMA user_version = 0`** (verified).
`scripts/build_db.py` never sets it. Therefore:

| Install type | user_version at open | Callback that fires |
|---|---|---|
| **Fresh install** (asset just copied) | `0` | **`onCreate`** → `_initializeSchema` + `_addIndexes` |
| **Existing pre-mayuragiri install** (v3) | `3` | **`onUpgrade(3, 5)`** → runs `_migrateToV4` then `_migrateToV5` |
| **Existing post-mayuragiri install** (v4, already live on Play Store) | `4` | **`onUpgrade(4, 5)`** → runs `_migrateToV5` only |

**Consequence: every new table must be created in ALL THREE paths.** Adding it only to
`_migrateToV5` means fresh installs get no practice tables and the app crashes on first read.
Adding it only to `_initializeSchema` means existing users get nothing on upgrade. And because
real users are already on v4 in production, `onUpgrade` must handle starting from v4 as a normal
case, not just v3.

Use `CREATE TABLE IF NOT EXISTS` throughout, have `_migrateToV5(db)` call the same private
helper that `_initializeSchema` calls, and test all three paths explicitly (T1.10), including the
v4→v5 case that didn't exist when this plan was first written.

---

# Phase 0 — Foundations

**Goal:** the opt-out switch and its plumbing exist *before* any feature that must obey it.
**Exit criteria:** a Settings toggle exists, persists, defaults to off, and controls nothing yet.

### T0.1 — Constants

**Files:** `lib/constants/app_constants.dart`

**Spec:** Add to `AppConstants`:

```dart
// ==================== Database Constants ====================
static const int dbVersion = 5;            // was 4 (mayuragiri merge claimed 4)

// ==================== Preferences Keys ====================
static const String practiceEnabledPrefsKey = 'practice_enabled';
static const String practiceSankalpamPrefsKey = 'practice_sankalpam';
static const String practiceFirstRunPrefsKey = 'practice_first_run_date';
static const String practiceReminderTimePrefsKey = 'practice_reminder_time';
static const String practiceNotifyAskedPrefsKey = 'practice_notify_asked';

// ==================== Practice Constants ====================
static const int dwellSecondsToComplete = 90;
static const int corpusSize = 1334;        // total songs; assert in tests
static const int mandalamDays = 48;
static const List<int> milestoneCounts = [6, 21, 48, 108, 216, 540, 1008, 1334];
```

**Do not** bump `dbVersion` to 5 until T1.1 lands the migration — bumping it alone will open a
v5 database with no v5 tables. **Set `dbVersion = 5` in T1.1, not here.** Add every other
constant now.

**Verify:** standing block.
**Commit:** `chore: add practice constants for gamification layer`

---

### T0.2 — `PracticeSettingsProvider`

**Files:** `lib/providers/practice_settings_provider.dart` (new), `lib/main.dart`

**Spec:** Mirror `LyricsFontSizeProvider` exactly in shape.

```dart
enum Sankalpam { dailyPractice, meanings, temples, justLooking }

class PracticeSettingsProvider with ChangeNotifier {
  bool _enabled = false;                    // default OFF — rule 7
  Sankalpam? _sankalpam;                    // null = onboarding not completed
  DateTime? _firstRun;

  bool get enabled => _enabled;
  bool get onboardingComplete => _sankalpam != null;
  Sankalpam? get sankalpam => _sankalpam;
  /// Days since first run — gates the notification ask (T2.2).
  int get daysSinceFirstRun => ...;

  Future<void> setEnabled(bool v);
  Future<void> setSankalpam(Sankalpam s);   // justLooking ⇒ setEnabled(false)
  Future<void> markFirstRunIfUnset();
}
```

Register in `main.dart`'s `MultiProvider` **above** `SongListProvider`.

**Acceptance:**
- Default is `false` on a fresh profile.
- Choosing `justLooking` forces `enabled == false`.
- State survives an app restart.

**Verify:** standing block.
**Commit:** `feat: add PracticeSettingsProvider with master opt-out`

---

### T0.3 — Settings toggle

**Files:** `lib/ui/screens/settings_screen.dart`, `lib/l10n/app_en.arb`, `lib/l10n/app_ta.arb`

**Spec:** Add a `SwitchListTile` as the **first** item in the settings list, above App Language.

- Title: `l10n.dailyPractice` — EN "Daily practice", TA "தினசரி பயிற்சி"
- Subtitle: `l10n.dailyPracticeSubtitle` — EN "Daily verse, reading progress and collections.
  Turn off for a plain library.", TA "இன்றைய பாடல், படித்தவை மற்றும் தொகுப்புகள். எளிய
  நூலகத்திற்கு அணைக்கவும்."
- Bound to `PracticeSettingsProvider.enabled`.

**Acceptance:** toggling persists across restart; no other behaviour changes yet.

**Verify:** standing block + `flutter gen-l10n`.
**Commit:** `feat: add daily practice toggle to settings`

---

# Phase 1 — v1.5 "The Daily Loop"

**Goal:** the minimum that changes what kind of app this is.
**Exit criteria:** a user can open the app, read today's hymn, and see an honest count rise —
with notifications nowhere in the build, and the whole thing switch-off-able.

### T1.1 — DB v5 migration

**Files:** `lib/data/database/database_helper.dart`, `lib/constants/app_constants.dart`

**Spec:**

1. Set `AppConstants.dbVersion = 5`.
2. Add a private `_createPracticeTables(Database db)` containing the DDL below.
3. Call it from **both** `_initializeSchema(db)` (onCreate) **and** a new `_migrateToV5(db)`.
4. Add to `onUpgrade`, **leaving the existing `oldVersion < 4` block untouched**:
   `if (oldVersion < 5) { await _migrateToV5(db); }`

```sql
CREATE TABLE IF NOT EXISTS reading_log (
  id            INTEGER PRIMARY KEY AUTOINCREMENT,
  song_id       INTEGER NOT NULL REFERENCES songs(id) ON DELETE CASCADE,
  read_on       TEXT    NOT NULL,
  dwell_seconds INTEGER NOT NULL DEFAULT 0,
  completed     INTEGER NOT NULL DEFAULT 0,
  UNIQUE(song_id, read_on)
);
CREATE INDEX IF NOT EXISTS idx_reading_log_read_on ON reading_log(read_on);
CREATE INDEX IF NOT EXISTS idx_reading_log_song_id ON reading_log(song_id);

CREATE TABLE IF NOT EXISTS practice_days (
  day             TEXT PRIMARY KEY,
  songs_completed INTEGER NOT NULL DEFAULT 0,
  verse_seen      INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS milestones (
  key         TEXT PRIMARY KEY,
  achieved_on TEXT NOT NULL
);
```

`read_on` and `day` are **local-date** ISO strings (`yyyy-MM-dd`), never UTC timestamps — a
practice day is a human day in the user's own timezone.

**Acceptance:** all three install paths (fresh/v0, v3, v4) produce all three tables (proved in
T1.10).

**Verify:** standing block.
**Commit:** `feat: add v5 schema for practice tracking`

---

### T1.2 — Models

**Files:** `lib/data/models/reading_log_model.dart`, `lib/data/models/practice_day_model.dart` (both new)

**Spec:** Follow `note_model.dart` exactly — immutable fields, `toMap()`, `fromMap()`,
`copyWith()` where useful. `ReadingLogEntry { id, songId, readOn, dwellSeconds, completed }`,
`PracticeDay { day, songsCompleted, verseSeen }`.

**Verify:** standing block.
**Commit:** `feat: add reading log and practice day models`

---

### T1.3 — `DatabaseHelper` practice API

**Files:** `lib/data/database/database_helper.dart`

**Spec:** Add, in the existing style:

```dart
Future<void> recordDwell(int songId, String day, int dwellSeconds, bool completed);
Future<int>  getCompletedSongCount();                 // COUNT(DISTINCT song_id) WHERE completed=1
Future<bool> isSongCompleted(int songId);
Future<int>  getTotalPracticeDays();                  // COUNT(*) FROM practice_days
Future<int>  getCurrentContinuity();                  // walk back from today
Future<List<String>> getPracticeDaysInRange(String from, String to);
Future<Map<String, int>> getCompletedCountByTemple(); // place -> completed count
Future<List<int>> getCompletedSongIds();
```

`recordDwell` must **upsert** on `UNIQUE(song_id, read_on)`, keep the **maximum** dwell seen
that day, never downgrade `completed` from 1 to 0, and update `practice_days.songs_completed`
in the **same transaction**.

**Verify:** standing block.
**Commit:** `feat: add practice tracking queries to DatabaseHelper`

---

### T1.4 — `PracticeProvider`

**Files:** `lib/providers/practice_provider.dart` (new), `lib/main.dart`

**Spec:** `ChangeNotifier` holding `completedCount`, `totalDays`, `continuity`,
`todayComplete`. Loads on construction; exposes `Future<void> refresh()` and
`Future<void> recordCompletion(int songId, int dwellSeconds, bool completed)`.

Cache aggressively — the home screen reads these on every build and must never scan
`reading_log`. Register in `main.dart` after `PracticeSettingsProvider`.

**Verify:** standing block.
**Commit:** `feat: add PracticeProvider`

---

### T1.5 — Daily selection (deterministic)

**Files:** `lib/services/daily_selection_service.dart` (new)

**Spec:** Pure, dependency-free, **fully unit-testable** logic.

```dart
/// Deterministic for a given local date — every user worldwide gets the same
/// verse on the same date. No RNG, no persistence, no clock reads inside.
int verseSongIdForDate(DateTime date, int corpusSize);
int verseIndexForDate(DateTime date, int verseCount);
```

Seed from `date.year * 10000 + date.month * 100 + date.day` through a fixed integer hash
(e.g. splitmix64-style mixing). **Do not** use `Random()` without a seed, `DateTime.now()`
inside the function, or `hashCode` (unstable across Dart versions and platforms).

Today's *hymn* (distinct from today's *verse*) = the next uncompleted song in the active
parayanam; in v1.5 with no parayanam table yet, use the lowest song id not in
`getCompletedSongIds()`, falling back to the date-seeded pick once all are read.

**Acceptance:** the same date returns the same ids across runs, platforms and app restarts.

**Verify:** standing block.
**Commit:** `feat: add deterministic daily verse selection`

---

### T1.6 — Dwell tracking ⚠️ integrity-critical

**Files:** `lib/ui/screens/song_detail_screen.dart`

**Spec:** In `_SongDetailScreenState`:

1. `with WidgetsBindingObserver`; register in `initState`, remove in `dispose`.
2. A wall-clock accumulator — record `DateTime` on resume, add the delta on pause. **Do not**
   use `Timer.periodic` to increment a counter; it keeps ticking in ways that overcount.
3. **Pause on `AppLifecycleState.paused`, `inactive` and `hidden`.** A song must not accrue
   time while the phone is locked in a pocket. This is the single most important line in the
   task — it is what makes the count worth having.
4. Mark complete when **either** accumulated foreground seconds ≥
   `AppConstants.dwellSecondsToComplete` **or** the lyrics scroll controller reaches
   `maxScrollExtent` (within a small epsilon).
5. Flush to `PracticeProvider.recordCompletion` on completion **and** in `dispose`.
6. **Entirely inert** when `PracticeSettingsProvider.enabled == false` — no observer, no timer,
   no writes.

**Acceptance:** backgrounding the app for 5 minutes on an open song adds ~0 seconds.

**Verify:** standing block.
**Commit:** `feat: track reading dwell time on song detail screen`

---

### T1.7 — `DailyPracticeCard`

**Files:** `lib/ui/widgets/daily_practice_card.dart` (new), `lib/ui/screens/home_screen.dart`

**Spec:** A `Card` inserted as the **first sliver** of the existing `CustomScrollView` in
`home_screen.dart` (~line 134), above the song list.

Contents, top to bottom:

1. Local date, and a festival line when one applies (a static stub in v1.5 — real calendar in T2.8).
2. **இன்றைய அருள்** — one verse from the daily selection + its meaning.
3. **இன்றைய பாடல்** — title and temple of today's hymn, tapping opens `SongDetailScreen`.
4. A quiet completion state once done: a check and `l10n.completedToday` ("இன்று நிறைவு").
5. `n / 1334` progress with a `LinearProgressIndicator` and total days kept.

**Design constraints (rules 8–10):** background `container`, track `card`, fill `accent`,
numerals `textHigh`, labels `textMuted`. No red anywhere. No confetti, no scale/bounce
animation. Verse text **must** honour `LyricsFontSizeProvider` and `LyricsLanguageProvider`;
card chrome follows `LanguageProvider`.

Returns `SizedBox.shrink()` when the practice layer is disabled.

**Verify:** standing block + `flutter gen-l10n`.
**Commit:** `feat: add daily practice card to home screen`

---

### T1.8 — Extend backup ⚠️ data-loss-critical

**Files:** `lib/services/backup_service.dart`, `lib/data/database/database_helper.dart`

**Spec:** Bump the export map's `'version'` from `1` to `2` and add `reading_log`,
`practice_days` and `milestones` alongside the existing keys.

**Import must stay backward compatible:** a `version: 1` file has no practice keys and must
still import cleanly. Extend `_validateBackup` for the new keys **only when present**, with the
same defensive shape as the existing checks (type checks, sane length caps).

> Losing years of practice to a reinstall is the one place in this design where loss would be
> real. This task ships in the same release as T1.1 — not later.

**Acceptance:** export → wipe → import restores the exact count, total days and continuity;
and a v1 backup file still imports.

**Verify:** standing block.
**Commit:** `feat: include practice data in backup export and import`

---

### T1.9 — Onboarding sankalpam

**Files:** `lib/ui/screens/onboarding_screen.dart` (new), `lib/ui/screens/main_wrapper.dart`,
both ARB files

**Spec:** Shown once, when `PracticeSettingsProvider.onboardingComplete == false`.

- One screen, four options (§4 Phase 2 of the strategy), no carousel, no multi-step flow.
- Frame the corpus as heritage, never as a backlog — use the "16,000 composed, 1,334 survived"
  line, not "1,334 to go".
- Immediately after choosing, show one verse and its meaning. Value before any ask.
- Call `markFirstRunIfUnset()`.
- **Do not** request notification permission here. That is T2.2, on day 3.

**Verify:** standing block + `flutter gen-l10n`.
**Commit:** `feat: add sankalpam onboarding screen`

---

### T1.10 — Tests

**Files:** `test/services/daily_selection_service_test.dart`,
`test/providers/practice_settings_provider_test.dart`,
`test/data/database_migration_test.dart` (all new)

**Spec:** Use `sqfliteFfiInit()` + `databaseFactoryFfi` in `setUpAll` (already a dependency;
see `main.dart` for the desktop pattern).

Required cases:

1. **Migration, fresh install** — open a v0 (`user_version = 0`, pre-mayuragiri-shaped) DB at
   version 5; assert `reading_log`, `practice_days`, `milestones` all exist.
2. **Migration, upgrade from v3** — open with `user_version = 3` at version 5 (exercises
   `_migrateToV4` then `_migrateToV5` in sequence); assert the same, **and** that existing
   `notes` / `highlights` / `categories` rows survive.
3. **Migration, upgrade from v4** — open with `user_version = 4` (the shape real Play Store
   users are on today, mayuragiri columns already present) at version 5; assert the same tables
   exist and no mayuragiri data is lost.
4. **Determinism** — `verseSongIdForDate` returns identical output for the same date across
   repeated calls, and different output for adjacent dates.
5. **Opt-out default** — `PracticeSettingsProvider.enabled` is `false` on a fresh profile;
   `justLooking` forces it false.
6. **Upsert** — `recordDwell` twice in a day yields one row with the max dwell, and never
   downgrades `completed`.
7. **Corpus assertion** — `AppConstants.corpusSize == 1334` matches `SELECT COUNT(*) FROM songs`.

**Verify:** standing block.
**Commit:** `test: cover v5 migration, daily selection, and practice opt-out`

---

### T1.11 — Docs & release

**Files:** `docs/database.md`, `docs/architecture.md`, `CHANGELOG.md`, `pubspec.yaml`

**Spec:** Document the v5 tables in `database.md` (schema table + migration-history row + the
new `DatabaseHelper` API), the daily card and onboarding in `architecture.md`, a `1.5.0` entry
in `CHANGELOG.md`, and bump `version: 1.5.0+7`.

> **Note:** the original plan targeted `1.4.0+6` for this release, but `main` is already at
> `1.4.0+6` (the mayuragiri release). Bump to `1.5.0+7` instead, and shift every later phase's
> version target up by one release to match (Phase 2 → `1.6.0+8`, Phase 3 → `1.7.0+9`, Phase 4 →
> `2.0.0+10`) unless another release lands first and this note needs updating again.

**Commit:** `docs: document v5 practice schema and daily loop` *(version bump separately:
`chore: bump version to 1.5.0+7 for release`)*

---

> ### 🚦 Phase 1 gate — do not start Phase 2 until this passes
>
> Ship v1.5 and **watch D30 retention before building notifications.** The strategy is explicit:
> if the loop only works when we ping people, it does not work. If D30 has not moved at all
> after a full month, re-read §2 and §3 with the team before continuing — the problem is the
> loop, and notifications will not fix it.

---

# Phase 2 — v1.6 "Vow & Abode"

**Goal:** the collection and the vow.
**Exit criteria:** Arupadai Veedu fills in, temples show progress, milestones land, and an
opt-in daily verse notification exists.

### T2.1 — Notification dependencies

**Files:** `pubspec.yaml`, `android/app/src/main/AndroidManifest.xml`

**Spec:** Add `flutter_local_notifications` and `timezone`. Declare `POST_NOTIFICATIONS`.
Confirm the Android 16 / API 36 target from `docs/android-16-target-sdk-upgrade.md` still
builds. **No iOS entitlement changes** beyond what the plugin requires.

**Verify:** standing block + `flutter build apk --debug`.
**Commit:** `chore: add local notification dependencies`

---

### T2.2 — `NotificationService` + the day-3 ask

**Files:** `lib/services/notification_service.dart` (new),
`lib/ui/widgets/notification_intro_sheet.dart` (new), `lib/ui/screens/settings_screen.dart`

**Spec:**

- Schedule **exactly one** daily notification at the user's chosen time. Content is the
  **verse itself**, generated on-device from the bundled DB.
- Gate the system prompt behind our own explanatory sheet, shown only when
  `daysSinceFirstRun >= 3` and `practiceNotifyAsked == false`. The sheet states plainly that the
  notification is generated on the device and that nothing is sent or received.
- Set `practiceNotifyAsked` whatever the answer. **Never ask twice.**
- Denial is fully supported — the app must work identically without it.
- A time picker in Settings, shown only when the practice layer is enabled.

**Forbidden copy:** "Murugan is waiting", "Don't lose your streak", "You haven't read today",
or any guilt framing. Reviewer: reject the task if such a string appears.

**Verify:** standing block + `flutter gen-l10n`.
**Commit:** `feat: add opt-in daily verse notification`

---

### T2.3 — Arupadai Veedu data layer

**Files:** `lib/constants/arupadai.dart` (new), `lib/data/database/database_helper.dart`

**Spec:** The six abodes keyed by the **Tamil `temples.name`** value (the query key used by
`getSongsByTemple`), with verified song counts:

| Tamil `place` | Romanized | Songs |
|---|---|---|
| திருப்பரங்குன்றம் | thirupparangkundRam | 14 |
| திருச்செந்தூர் | thiruchchendhUr | 84 |
| பழநி | pazhani | 98 |
| சுவாமிமலை | SwAmimalai | 40 |
| திருத்தணிகை | thiruththaNigai | 64 |
| பழமுதிர்ச்சோலை | pazhamudhirchOlai | 16 |

Total 316. Add `Future<Map<String, int>> getArupadaiProgress()` returning completed counts
per abode. **Assert these six names resolve against `temples` in a test** — a typo here
silently yields a permanently 0/N panel.

**Verify:** standing block.
**Commit:** `feat: add Arupadai Veedu constants and progress query`

---

### T2.4 — Arupadai Veedu screen

**Files:** `lib/ui/screens/arupadai_screen.dart` (new), `lib/ui/screens/highlights_notes_screen.dart`

**Spec:** Six panels, each with the abode name (both scripts per language setting), a progress
ring, and `n / total`. Tapping opens the existing `TempleSongsScreen` for that temple.
Reached from the **Library** tab — do **not** add a sixth bottom tab.

**Design (rule 9):** differentiate the six by **iconography and typography only**. Surfaces
derive from the active `ColorScheme`; un-visited panels use `card` at reduced opacity. No six
hardcoded hues — `dynamic_color` will destroy them.

**Verify:** standing block + `flutter gen-l10n`.
**Commit:** `feat: add Arupadai Veedu collection screen`

---

### T2.5 — Per-temple progress

**Files:** `lib/ui/screens/temples_screen.dart`

**Spec:** Extend the existing subtitle (currently `song_count`) to `read / song_count` plus a
slim `LinearProgressIndicator`. One batched `getCompletedCountByTemple()` call for the whole
list — **not** one query per row. Falls back to the current plain count when the layer is off.

**Verify:** standing block + `flutter gen-l10n`.
**Commit:** `feat: show reading progress per temple`

---

### T2.6 — Milestones engine

**Files:** `lib/services/milestone_service.dart` (new), `lib/providers/practice_provider.dart`,
`lib/ui/widgets/milestone_sheet.dart` (new)

**Spec:** After each completion, check `AppConstants.milestoneCounts` and the six abodes; insert
into `milestones` and surface a **modal sheet, once**, keyed on the stored row so it never
repeats. Copy carries the Tamil meaning of the number (108, மண்டலம், etc.) — not "Level up".

**Verify:** standing block + `flutter gen-l10n`.
**Commit:** `feat: add milestone detection and acknowledgment`

---

### T2.7 — Mandalam ceremony (day 48)

**Files:** `lib/ui/screens/mandalam_complete_screen.dart` (new), `lib/services/milestone_service.dart`

**Spec:** A full-screen moment at 48 practice days — the key retention checkpoint. A permanent
record in `milestones`, and an **optional** share that produces a completion card. Restrained,
in-palette, no confetti. Sharing is opt-in and shares the achievement of a *practice*, never a
score to compare (rule 3).

**Verify:** standing block + `flutter gen-l10n`.
**Commit:** `feat: add mandalam completion ceremony`

---

### T2.8 — Festival calendar

**Files:** `lib/services/festival_service.dart` (new), `lib/ui/widgets/daily_practice_card.dart`

**Spec:** Replace T1.7's stub. Compute, offline: Skanda Sashti, Thai Poosam, Vaikasi Visakam,
Karthigai Deepam, the monthly Karthigai nakshatram, and Tuesdays.

**This is the task most likely to be got wrong.** Tamil festival dates are lunisolar and
**cannot** be derived from Gregorian arithmetic. Do **not** attempt to compute nakshatram from a
formula. Ship a **bundled lookup table** covering at least 2026–2036, generated offline and
committed as an asset, with a dated source noted in the file. If the table runs out, the card
shows no festival line — it never shows a wrong date. Wrong festival dates in a devotional app
are worse than no festival dates.

**Verify:** standing block + a test asserting a known date (Thai Poosam 2027) resolves correctly.
**Commit:** `feat: add offline festival calendar`

---

### T2.9 — Tests, docs, release

**Spec:** Tests for the six abode keys resolving, milestone idempotency (never fires twice),
notification scheduling logic (pure parts only), and the festival table. Update `database.md`,
`architecture.md`, `CHANGELOG.md`; bump to `1.6.0+8`.

**Confirm at release:** local notifications do not change the Play **Data Safety** declaration
— still *no data collected, no data shared*.

**Commit:** `test: cover abodes, milestones and festival calendar` + `docs:` + `chore:`

---

# Phase 3 — v1.7 "Your Thirumurai"

**Goal:** the app starts answering back with the user's own material.

### T3.1 — Ordered recitation sets

**Files:** `lib/data/database/database_helper.dart`, `lib/constants/app_constants.dart`

**Spec:** DB **v6**. `ALTER TABLE song_categories ADD COLUMN position INTEGER;`
`ALTER TABLE categories ADD COLUMN is_sequence INTEGER NOT NULL DEFAULT 0;`
Same both-paths rule as T1.1. `ALTER TABLE` is not idempotent — guard with a `PRAGMA
table_info` check before altering, or the upgrade throws on a partially-migrated DB.

**Commit:** `feat: add v6 schema for ordered recitation sets`

---

### T3.2 — Parayanam table, provider, resume

**Files:** `lib/data/database/database_helper.dart`, `lib/providers/parayanam_provider.dart` (new),
`lib/ui/screens/categories_screen.dart`

**Spec:** Create the `parayanam` table (strategy §7 DDL) in v6. A category can be marked a
sequence and set active; "today's hymn" in the daily card then follows `cursor` instead of the
T1.5 fallback. `cycle` increments on completion rather than resetting (the endgame contract).

**Commit:** `feat: add parayanam sets with resume`

---

### T3.3 — Library reflections

**Files:** `lib/ui/screens/highlights_notes_screen.dart`, `lib/services/reflection_service.dart` (new)

**Spec:** Surface aggregates over the user's **own** highlights — recurring words, most-revisited
songs, most-highlighted temple. Pure local text analysis over the `highlights` table. Needs
≥ 10 highlights before showing anything; below that, show nothing rather than something thin.

Once this ships, switch the daily verse source to the user's own highlights when they have
≥ 10 (strategy §6.3) — the single strongest zero-cost retention mechanic available.

**Commit:** `feat: surface reflections from your own highlights`

---

### T3.4 — Personal thirumurai export

**Files:** `lib/services/thirumurai_export_service.dart` (new), `lib/ui/screens/settings_screen.dart`

**Spec:** Render highlights + notes + categories + progress as one formatted Markdown document,
shared via the existing `share_plus` path. Distinct from `BackupService` — this is the
human-readable artifact, not the machine-restorable one. Do not merge the two.

**Commit:** `feat: export personal thirumurai as a shareable document`

---

### T3.5 — Report a correction

**Files:** `lib/ui/screens/song_detail_screen.dart`, `lib/services/correction_service.dart` (new)

**Spec:** Long-press a verse → "report a correction" → `url_launcher` opens a **prefilled GitHub
issue URL** (song id, kaumaram id, verse index, the current text). No API call, no token, no
background submission — the user sees and sends it themselves, in their own browser.

Seed the tracker with the known `docs/database.md` issue: **song 1328** has lyrics in its `tune`
column.

**Commit:** `feat: let devotees report text corrections`

---

### T3.6 — Tests, docs, release

Bump to `1.7.0+9`. Update all three docs.

---

# Phase 4 — v2.0 "Together"

**Goal:** shared practice without a server, and an endgame.

### T4.1 — Group code format

**Files:** `docs/group-parayanam-format.md` (new), `lib/services/group_code_service.dart` (new)

**Spec:** Specify the format **before** implementing it: versioned, compact, URL-safe, with a
checksum. Carries member label, assigned song-id range, completed count, and an ISO date — and
**nothing identifying**. Document it publicly; the repo is AGPL and the format must be forkable.

**Size discipline:** it gets pasted into WhatsApp. Target well under 300 characters. Encode the
completed set as ranges, not an id list.

**Commit:** `docs: specify group parayanam code format` + `feat: add group code encode/decode`

---

### T4.2 — Group progress UI

**Files:** `lib/ui/screens/group_parayanam_screen.dart` (new)

**Spec:** Paste-to-import, a combined progress wheel, per-member contribution. Rule 3 still
applies in full: show **contribution to a shared goal**, never a ranking, never a sort by who
read most. Treat every imported code as untrusted input — validate, bound and reject
malformed data exactly as `BackupService._validateBackup` does.

**Commit:** `feat: add group parayanam progress`

---

### T4.3 — Verse card image share

**Files:** `lib/ui/widgets/verse_card.dart` (new), `lib/ui/screens/song_detail_screen.dart`

**Spec:** Render a verse to an image via `RepaintBoundary` + `toImage` (**no new dependency**),
shared through `share_plus`. Carries the verse, the temple, and the app link — **never a
count, never a streak, never a score** (strategy §6.5).

**Commit:** `feat: share verses as image cards`

---

### T4.4 — Mentorship import

**Files:** `lib/services/mandalam_share_service.dart` (new)

**Spec:** Export/import a curated ordered song sequence as a file or link, reusing the T3.2
parayanam model and the T4.1 validation discipline.

**Commit:** `feat: share and import curated mandalam sequences`

---

### T4.5 — Endgame

**Files:** `lib/providers/parayanam_provider.dart`, `lib/ui/widgets/daily_practice_card.dart`

**Spec:** On completing all 1,334, offer a second parayanam — `cycle` increments, the count
continues ("2nd parayanam · 40 / 1334"), nothing resets to zero. Add a depth mode that
re-weights the daily card toward meanings and the `patham` breakdown.

**Commit:** `feat: add second parayanam and depth mode`

---

### T4.6 — Tests, docs, release

Bump to `2.0.0+10`. Full docs pass across `architecture.md`, `database.md`, `README.md`.

---

## Definition of done (every task)

- [ ] `flutter analyze --no-fatal-infos` clean
- [ ] `flutter test` passing
- [ ] `dart format --set-exit-if-changed lib test` clean
- [ ] New strings in **both** ARB files, with real Tamil, `flutter gen-l10n` run
- [ ] New colors via `AppColors` / `AppColorExtension`, light **and** dark values
- [ ] Feature inert when `PracticeSettingsProvider.enabled == false`
- [ ] No red in progress/streak UI
- [ ] No network transmission of user state
- [ ] `docs/` updated when schema, navigation or setup changed
- [ ] One task, one commit, conventional prefix

## Escalate instead of improvising

Stop and report to the user if:

- A task requires breaking a standing rule.
- The migration behaves differently from the `user_version` table above.
- `AppConstants.corpusSize` disagrees with `SELECT COUNT(*) FROM songs`.
- A festival date cannot be sourced reliably (ship no date rather than a wrong one).
- Any task tempts you toward a server, an account, or an analytics SDK.
