# Changelog

Notable changes to this project. Format loosely follows [Keep a Changelog](https://keepachangelog.com/).

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
