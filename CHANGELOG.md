# Changelog

Notable changes to this project. Format loosely follows [Keep a Changelog](https://keepachangelog.com/).

## [Unreleased]

### Added
- **Links.** Attach web links (a kirtan video, a discourse, a post) to any song. A **Add Link** button sits beside Note on the song detail screen; a song's links are listed inline just above the buttons, and tapping one opens it in the browser or the app that handles it. A new **Links** tab in My Library lists them all, grouped by song. Links store only the URL and an optional label, so everything works offline, and only `http`/`https` URLs are accepted.
- **Share into the app.** Share a link from YouTube, Instagram, a browser or any app and choose Thiruppugazh: the app asks which song it belongs to (with search) and saves it. Works whether the app is closed or already open. After you pick the song, a short toast confirms it ("Link added to <song>") and you are taken straight back to the app you shared from, so sharing never pulls you out of what you were doing. Implemented as a small native Android share target in `MainActivity` — no new plugin.
- Links are part of Export/Import and Auto Backup. Older backups without links still import, re-importing never duplicates a link, and a backup entry with a non-http(s) URL is skipped.
- DB v6: new `links` table (additive; see [`docs/database.md`](docs/database.md)).
- **Self-repairing links table:** the database now re-creates the `links` table on every open if it is ever missing, so a failed update step can never leave backups or song pages broken.
- **Chanting mode** (the figure-meditating icon beside "Lyrics" on a song). A distraction-free view: one verse at a time in large text, the tune pattern as a cue (can be hidden), the screen kept awake, and the existing font-size and lyrics-language settings. Move by hand (swipe or the next/previous buttons) or switch to **Auto**, which advances at a pace you choose (10 to 60 seconds per verse) with play/pause and a "song complete" end state. Verses are grouped by the tune pattern length, exactly as on the song page.
- **Continue where you left off** card on Home: the last song you opened and, if you were chanting it, the verse you were on. Stored on the device in preferences only (no database change).
- **Favorites shortcut**: a heart button on Home opens your Favorites list directly.
- Maintenance: removed an unused, discontinued build dependency (`intl_utils`), and moved the Settings radio-button dialogs to Flutter's current `RadioGroup` API (no visible change).
- **Opening a saved link asks first**, naming the site ("You are about to visit youtu.be. Continue?"), the same prompt the app already shows for its other external links.
- **Tamil for backup and import.** The Export/Import screens, confirmations and messages, and the last-automatic-backup line, were English-only; they are now in Tamil too. Other leftover English messages (song page, Home, Settings) moved to the language files.
- The **GitHub link in Settings** now asks first, naming the site, like every other external link.
- Safer, lighter backups: the automatic backup snapshot is written to a temporary file and then swapped in, so an interruption can't corrupt it; building a backup reads only favorite ids instead of every favorite's full text; and old export files are cleared from the cache folder (at startup and before each export). Home no longer decodes the full 2048 px hero image, and error messages no longer show technical details.
- **Privacy policy rewritten** (Tamil and English) to match what the app actually does: data kept on the device, Android Auto Backup and Export/Import, the notification permission, sharing into and out of the app, and the websites it can open after you confirm.
- **The daily reminder follows your time zone.** It used to repeat at a fixed UTC time, so outside India it could drift an hour when daylight saving started or ended. It now keeps the same local time (new small dependency `flutter_timezone`, offline, no new permission).
- **Library lists stay up to date.** Highlights, Notes and Links refresh when data changes elsewhere, and after a backup is restored at startup (they used to keep what they loaded first).
- **Search matches `%` and `_` literally** instead of treating them as wildcards.
- **Smaller and lighter:** the Home picture is now a 200 KB WebP instead of a 5.4 MB PNG (the app is about 5 MB smaller, and Home no longer decodes a 2048 px bitmap).
- **Readability:** text on outlined and text buttons (Export Data, View source, dialog buttons), the privacy-policy headings and the word-meaning phrases use the darker theme text colours instead of the faint accent green, in light and dark themes.
- The exit dialog now closes the app the normal way instead of killing the process. Text shared into the app is limited to 8 KB.
- **Android only, and about 4.4 MB smaller.** Removed the unused Windows, Linux and macOS project folders and the desktop start-up code, and the end-of-life `sqlite3_flutter_libs` package (it only added an unused copy of SQLite for three CPU types to the app). `sqflite_common_ffi` is now a dev-only dependency: it exists to run the database tests on the development computer (`flutter test` has no Android SQLite). The release APK went from 66.1 MB to 61.7 MB. The `ios/` folder is kept.
- Dependencies: updated `share_plus` 13, `file_picker` 13, `app_links` 7 and `flutter_lints` 6 (with the matching code changes); removed the unused `dynamic_color` and `cupertino_icons`; dropped the unneeded Jetifier build setting. The app's own backup export now uses the current share API.
- Maintenance (no visible change): the song page's web-lookup buttons and its info, meanings and word-separated-lyrics sections moved into their own files; temple lists go through the repository; unused constants and the unused `app_strings.dart` removed; importing a backup rewrites the automatic backup once instead of once per row; the logger does no work in release builds.
- CI now also runs on `next`, and the analyzer check is strict.
- **Safer database recovery.** If the song database file is ever found unusable, the app now sets it aside and copies your notes, highlights, categories, links and favorites into the fresh database, instead of discarding the file. The automatic backup can also restore again after such a recovery.
- **Sturdier import.** A backup with a damaged note, highlight or category no longer fails the whole import: that row is skipped and counted. Oversized backup files and absurdly long lists are refused, category names follow the same length rule as in the app, and the automatic restore uses the same checks as the manual import.
- **Fixes opening a very old (1.0.0) database.** An install that updated straight from 1.0.0 to this version would have failed to open its song database ("no such column: is_favorite") and shown every screen empty. The upgrade now completes the old schema first. Upgrade tests now cover v1 through v5.
- The Home "random song" button picks without sorting the whole song table.
- Maintenance (no visible change): the database file is split into `database_helper.dart`, `database_schema.dart` (tables and migrations) and `search_text.dart` (search text rules); the four "open on the web" buttons on a song share one checked code path; the temple song list goes through the repository; the unused `error_handler.dart` is removed; the deep-link listener is cancelled when the screen closes.
- Upgrade tests now run against the real bundled databases from earlier versions (v2 to v5), checking that notes, highlights, categories and favorites survive. Patch/minor updates to nine packages (share_plus, shared_preferences, path_provider, url_launcher, flutter_local_notifications, timezone, provider and related).
- **Chanting mode pace** now offers 5, 10, 15, 20, 25 and 30 seconds, and 1 minute. The chanting icon is a simple play button, and the Home heart is an outline.
- **Song page buttons** are now an even two-column grid of equal-height tiles (icon above a two-line label) instead of a mix of rows that wrapped and crowded; extra space at the bottom keeps the floating buttons from covering the last row.
- **Theme fix:** the app's green is now defined for the secondary colours too, so segmented buttons, chips (including the search filters) and tonal buttons are green instead of Material's default teal, in light and dark.
- The "no songs in this list" message is now translated.
- **Smarter search.** Results are now ranked: a song number finds that song first, then title matches, then opening-line matches, then the rest of the text. Spelling is forgiving in both scripts: casual English spellings and missing spaces now match (e.g. `muthaitharu`, `thirupugazh`, `dh`/`th`, `zh`/`l`, doubled letters), and Tamil letters that are easy to confuse (ன/ண/ந, ர/ற, ல/ள/ழ) match each other. Typing several words matches them in any order. On the bundled songs, typing a title or opening words with casual spelling or no spaces went from finding the song about 10% of the time to about 100%.

## [1.5.0+7] — 2026-09-30

Everything below landed after `1.4.0+6`.

### Added
- **Automated backup via Android Auto Backup**, on top of the existing manual Export/Import: favorites, categories, notes, highlights, and settings are now silently snapshotted on-device (debounced ~5s after any change, plus a catch-up write if the last one is over a day old) and handed to Android's own Auto Backup system — the user's own Google account, no server, no new permission prompt. On a reinstall or new device signed into the same account, it's restored automatically, once, before the app even finishes its first launch. A quiet "Last automatic backup: …" line was added to Settings for visibility. See [`docs/automated-backup-plan.md`](docs/automated-backup-plan.md).
- **Hardened the existing manual Export/Import** alongside the above, since both now share the same code path: import is transactional (an interrupted or invalid import no longer leaves the database half-written), a backup file with an unsupported format version is rejected with a clear message instead of silently mis-imported, a favorite/category/note/highlight referencing a song no longer present is skipped and counted instead of aborting the whole import, and the import confirmation dialog now shows the real contents of the picked file (counts, export date) instead of a generic message.
- **Daily reminder notification** — opt-in "Daily Reminder" toggle in Settings schedules a single recurring local notification at a devotee-chosen time (default 8:00 AM). Fully offline (`flutter_local_notifications`); denying the OS permission leaves the toggle off with an explanation.
- **Today's Song card** on the Home screen — a deterministic, date-seeded pick shown below the title; the same song for everyone for the whole calendar day.
- **Arupadai Veedu grid** at the top of the Temples screen — a fixed 2×3 grid of the six Arupadai Veedu abodes, with song counts, as quick shortcuts into each abode's song list.
- **Add-to-category dialog is now a modal bottom sheet** instead of a cramped centered `AlertDialog`, with a proper scrollable list and a pinned Cancel/Save footer — noticeably better once the keyboard opens for the inline new-category field.
- **A real vel icon for the daily reminder notification**, replacing a placeholder cropped from the launcher emblem that read as a raindrop rather than a vel. Ships as two tiers: a bold simplified version for the small mdpi/hdpi/xhdpi status-bar sizes (the full detail turns to illegible gray mush that small) and the full detailed artwork for xxhdpi/xxxhdpi.

### Fixed
- **Songs 1328 and 1338 showed their lyrics under "சந்தம்" (tune)** (DB v5). Upgraded installs are corrected in place by a data-only migration (`assets/song_fixes_v5.json`) that never touches favorites, notes, highlights or categories; fresh installs get the corrected rows from the rebuilt bundled database.
- **Songs 1–6 (including கைத்தல நிறைகனி and முத்தைத்தரு) were missing for everyone who installed since 1.2.0.** They were dropped when the bundled database was rebuilt from a source folder that started at song 7. Restored for fresh installs and, via the same v5 migration, for existing installs (never overwriting a song a user already has).
- **A corrupted or partially-copied bundled database silently showed every screen empty, with no error and no recovery**, on fresh installs and reinstalls alike (root-caused from a real user report on a Redmi 10/MIUI device). Three related issues, each independently verified live on-device: the first-run asset copy wasn't checked for actual usability before being trusted; an *existing* file at the DB path was assumed valid without the same check, so a bad file left over from any past failure was never self-corrected; and the v3/v4 migrations' `ALTER TABLE ADD COLUMN` calls were unguarded, so a "duplicate column name" exception from an unexpected DB state would poison the app's single cached database connection outside any try/catch. See [`docs/crash-reporting-decision.md`](docs/crash-reporting-decision.md) for the full incident writeup (also covers a still-open recommendation to add Crashlytics so incidents like this surface automatically next time, not decided yet).
- **Casual "Tanglish" spelling didn't match temple search** — e.g. searching "thiruchendur" (Temple filter) returned nothing, because the stored transliteration is the formal scholarly form ("thiruchchendhUr"). Added an additive, query-time-only normalization (both the query and the stored name run through the same substring rules) — no schema change.
- Filled checkbox (matching existing-category rows) instead of a close/✕ button for a pending new category in the add-to-category sheet.
- Reminder time row's left alignment under the toggle above it (was a guessed fixed padding that didn't quite line up).
- Daily reminder toggle's label simplified — dropped the offline-explanation subtitle, since the local/offline nature doesn't need spelling out on the toggle itself.

### Known issues
- See [`docs/database.md`](docs/database.md) → Known Data Issues for remaining incomplete records (missing word meanings / English data on a few newer songs).

## [1.4.0+6] — 2026-09-02 (shipped to Play Store)

Everything below landed after `1.3.0+5`.

### Added
- **Word-separated (padham) lyrics section** on the song detail screen, sourced from mayuragiri.com and shown after the lyrics and before the meaning, grouped into the same stanzas as the main lyrics; hidden for songs where no data was scraped. DB v4 adds the `mayuragiri_*` columns; a Mayuragiri credit block was added to Settings.

### Fixed
- Digital Asset Links now include the Play app-signing certificate, so App Link verification for `thiruppugazh.ayilavan.org` passes on Play-signed installs.

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
