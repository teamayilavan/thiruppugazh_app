# Changelog

Notable changes to this project. Format loosely follows [Keep a Changelog](https://keepachangelog.com/).

## [1.5.0+7] — Phase 1 of the gamification plan: "The Daily Loop"

Everything below landed after `1.4.0+6` (the mayuragiri word-separated lyrics release). Implements
Phase 1 of [`docs/gamification-implementation-plan.md`](docs/gamification-implementation-plan.md) —
see [`docs/gamification-strategy.md`](docs/gamification-strategy.md) for the *why*. The whole layer
is opt-in: off by default, and `PracticeSettingsProvider.enabled == false` restores the exact
pre-1.5.0 experience with no observer, no timer, no writes.

### Added
- **Daily practice toggle** in Settings — the master opt-out, first item in the list, off by default.
- **Sankalpam onboarding** — shown once on first run, before the normal app UI: a four-option intent
  picker (daily practice / meanings / temples / just looking), then immediately the corpus framed as
  heritage ("Arunagirinathar composed over 16,000 hymns, 1,334 survived") plus one verse and its
  meaning — value before any ask.
- **Daily practice card** on the home screen — local date, one deterministic daily verse
  ("இன்றைய அருள்"), today's hymn ("இன்றைய பாடல்" — the lowest uncompleted song, tap to open),
  a quiet completed-today state, and the `n / 1334` progress bar with total days kept. The same
  verse/date pick is deterministic across every device worldwide — no server, no RNG.
- **Reading dwell tracking** on the song detail screen — a song is marked read after 90 seconds of
  genuine foreground reading or scrolling to the end, never on tap; time does not accrue while the
  app is backgrounded.
- **Practice data in backup export/import** (`BackupService` version 1 → 2) — a reinstall no longer
  loses reading history. A v1 backup file still imports cleanly.
- New `reading_log`, `practice_days`, `milestones` tables (DB schema v5 — v4 was already claimed by
  the mayuragiri merge; see the revision note at the top of the implementation plan).

### Privacy
- Nothing new leaves the device. No network call transmits reading history, streaks, or the
  onboarding choice — same offline-only posture as the rest of the app.

## [1.4.0+6] — Mayuragiri word-separated lyrics

Everything below landed after `1.3.0+5`.

### Added
- **Word-separated (padham) lyrics** for all 1,334 songs, sourced from mayuragiri.info and scraped
  offline at build time (`scripts/mayuragiri_scraper.py`, patched into the DB by
  `scripts/build_db.py` via `assets/mayuragiri_data.json`). Shown on the song detail screen ahead of
  the meaning section, with a link back to the source page; credited on the Settings screen.
- New `mayuragiri_lyrics_separated` / `mayuragiri_english_lyrics_separated` columns on `songs`
  (DB schema v4).

## [1.3.0+5] — 2026-08-25

Everything below landed after `1.2.0+4` (the last version bump, part of the Android 16 target SDK compliance fix).

### Added
- **Random song button** on the Home screen — a small shuffle FAB, stacked above the search FAB, opens a uniformly random song queried across the entire database (not just whatever page is currently loaded).
- **Inline category creation** in the "Add to categories" dialog — type a new category name and add it right there instead of needing to leave the dialog and use the Categories screen first. Staged locally until Save, consistent with how existing category checkboxes already behave.
- **Fallback web app** (`web_app/`) — a static site generator producing one page per song plus an index, hosted at `https://thiruppugazh.ayilavan.org`, so a shared song link shows real content (and a "get the app" prompt) instead of a dead end for people without the app installed. See [`docs/web-app.md`](docs/web-app.md).
- **Lyrics font size adjustment** — A-/A+ buttons next to the "Lyrics" header on the song detail screen step through 5 sizes (14–26sp), persisted via a new `LyricsFontSizeProvider`.
- **GitHub repo link** on the Settings screen — a "View Source Code on GitHub" button opening the project's repo in the external browser.

### Fixed
- **Android deep links were never registered.** The Dart-side handler (`MainWrapper._handleDeepLink`, via `app_links`) fully parsed both `thiruppugazh://song/{id}` and `https://thiruppugazh.ayilavan.org/song/{id}`, and the share feature generated the latter — but `AndroidManifest.xml` had no `<intent-filter>` for either scheme on `MainActivity`, so tapping a shared link never actually launched the app on Android. iOS was already correctly configured via the Associated Domains entitlement.
- **The deep link domain didn't resolve at all.** `thiruppugazh.ayilavan.org` had no DNS record — separate from the manifest bug above, and now resolved by the new web app (once hosted; see `docs/web-app.md`). Not to be confused with `thiruppugazhapp.ayilavan.org`, the existing marketing/banner site, which is unrelated to this repo.
- **`assets/thiruppugazh.db` had a missing `proguard-rules.pro`** referenced by `android/app/build.gradle.kts` — AGP 8 silently tolerated the missing file; upgrading to AGP 9 (below) failed the build on it until the (empty, as originally intended) file was added.
- **`ndkVersion` mismatch** — pinned to `27.0.12077973` while every installed Flutter plugin requested `28.2.13676358`; AGP 8 didn't surface this as a problem, AGP 9 does.
- **Netlify build for the web app failed** — `runtime.txt` used a Heroku-style `python-3.12.0` prefix, but mise (Netlify's toolchain manager) reads the whole line as the version identifier, so it looked for a nonexistent `python-build` definition. Corrected to the bare version format.

### Changed
- **Upgraded AGP `8.13.0` → `9.3.0`**, Gradle `8.13` → `9.7.0`, Kotlin `2.1.0` → `2.2.20`, and enabled `android.r8.optimizedResourceShrinking` — addresses two Play Console performance recommendations (bitmap downsampling was traced to an obfuscated third-party dependency, not app code, and left as-is; resource shrinking and the AGP version were actionable). Deliberately kept the legacy Kotlin-plugin DSL (`android.builtInKotlin=false`) rather than fully migrating to AGP 9's built-in Kotlin support, since several plugins haven't migrated yet — see the addendum in [`docs/android-16-target-sdk-upgrade.md`](docs/android-16-target-sdk-upgrade.md).
- Added AGPL-3.0 license, a CI workflow (`flutter analyze` + `flutter test` on every push/PR to `main`), and a contributing guide.

### Known issues
- **Song 1328** (`ஏறுமயிலேறி`) has a source data anomaly — its `tune` field contains the full lyrics/meaning text, and its actual lyrics are empty. Present in `assets/thiruppugazh.db` itself, so it shows the same way in both the app and the new web app. Not yet fixed — see [`docs/database.md`](docs/database.md) → Known Data Issues.

## [1.2.0+4] — 2026-08-19 (approx.)
- Target Android 16 (API level 36) for Play Store compliance.

## [1.2.0] and earlier
Not retroactively documented here — see git history for changes prior to this changelog's introduction.
