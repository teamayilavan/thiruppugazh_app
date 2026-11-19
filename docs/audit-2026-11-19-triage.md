# Audit triage and fix plan (2026-11-19)

Read this first when continuing the audit work. It records what was checked against the code, what is real, and the ordered plan. Source documents (outside the repo, in `D:\`): `thiruppugazh_codebase_audit.md` (an external read-only audit of `next` @ `47c7f2c`, v1.7.0+9, DB v6) and `thiruppugazh_learning_and_memorization_plan.md` (see the last section).

**Method and limits.** Claims were spot-checked by reading code and measuring the bundled DB and asset sizes. Nothing was reproduced on a device. `flutter analyze` and `flutter test` were not run for the original audit. Performance, CI, Netlify and most line numbers were not checked.

**Rule of thumb:** the audit is good at *finding* issues but states several causes as certain when they are only plausible. Verify with a test before fixing.

## At a glance (state at the end of 2026-11-19)

**Fixed on `next`** (commits `493ec07`, `c573367`, `c5ae090`, `e95ec66`, `5ed696d`; analyze clean, 361 tests; checked on the emulator where noted in the log):
- Tamil-only category names were rejected (M1); the favorite heart emptied after saving categories (M2b); raw error text in category SnackBars (S2).
- After a database recovery an older auto-backup overwrote rescued notes and highlights (M7, a real data-loss bug); rescuing a pre-links database stranded a 37 MB file; backup input checks (S1a).
- Today's song widget read the database on the main thread (P8); `text/plain; charset=...` shares were dropped (M9).
- Light-theme muted text contrast and the crossed light/dark references; leftover English strings and hard-coded colours (M11, partly); dead `lib/generated/` (M5); URL userinfo and length (S1b).
- Link-save errors, deep-link `mounted` checks (M4, verified parts); failed import triggering a backup (M3); overlapping auto-backup writes (M8); typing limits (S3).

**Disproved or dropped:** M2 as described, P2 (keyboard wipes dialog; tested), P4 (controller leaks; not worth the risk).

**Open, needs an owner decision or its own project:** S4 deep-link filters, M6 tracked binaries, P5 indexes (with the next DB bump), P1 drop bundled migration JSONs (full upgrade matrix first), performance items (unmeasured), M10 reminder service, CI/Netlify hardening, remaining M4 sub-items, M9 warm-start race (unverified).

**Before the next release:** build and smoke-test the signed release APK where `upload-keystore.jks` lives (it is not on the machine used for this work); R8 and release lint already pass. Bump the version only when preparing the release (CLAUDE.md).

## 1. Verdict per item

Status: DONE = fixed and tested; TODO = planned; TEST FIRST = write a test to prove it before deciding; DEFER = real but not worth doing now; DROP = disproved.

| ID | Item | Real? | Impact | Batch | Status |
|---|---|---|---|---|---|
| M1 | Category-name validator uses `\w` without `unicode: true`, so Tamil-only names are rejected (3 copies: `add_to_category_dialog.dart`, `categories_screen.dart` x2) | Yes, confirmed | High (Tamil-first app) | 1 | see section 3 |
| M2 | "Unfavoriting leaves the heart filled" | **Cause wrong.** Favorites live in `songs.is_favorite`; category 1 is virtual and never written to `song_categories`, so `_categoryIds.contains(1)` is normally false | None as described | - | DROP |
| M2b | Related real bug: after the category dialog saves, `song_detail_screen.dart` sets `_isFavorite = updatedIds.contains(1)`, which clears the heart for a favorited song (DB still says favorite) until the screen is reopened | Yes (by reading the code) | Low to medium | 1 | see section 3 |
| S2 | Raw `$e` shown in 3 category SnackBars | Yes | Low | 1 | see section 3 |
| P4 | 3 `TextEditingController`s never disposed (`categories_screen.dart` create and rename, `song_detail_screen.dart` note dialog) | Yes | Very low | 1 | see section 3 |
| P2 | `AddToCategoryDialog` keyboard frames wipe selections | **Doubtful.** `MediaQuery.of` is inside the inner `StatefulBuilder`, so only that subtree rebuilds; the outer `FutureBuilder` locals are not reset by the keyboard. A rebuild of the dialog widget by its parent would re-run the query | Unproven | 1 | TEST FIRST |
| M7 | After DB recovery, `main.dart` calls `maybeRestore(databaseWasRecovered: true)` right after `_rescueUserData`, so an older auto-backup can overwrite just-rescued notes and highlights (`saveNote`, `removeHighlight` + `addHighlight`) | Code path real; trigger rare (corrupt DB + rescue + stale backup) | Data safety | 2 | TEST FIRST |
| S1a | `validateBackupMap` does not cap total `category.songs` entries; `maybeRestore` reads the file without `maxBackupFileBytes`; `pickAndPreviewBackup` casts without an `is Map` check | Yes | Low | 2 | TODO |
| P8 | `TodaysSongWidget.kt` opens the 37 MB DB synchronously in `onUpdate`/`onReceive` (no `goAsync`) | Yes | Low to medium (ANR risk on slow storage) | 3 | TODO |
| M9 | `MainActivity.kt:70` requires `intent.type == "text/plain"` exactly, so `text/plain; charset=utf-8` shares are dropped. Warm-start handler race is plausible, not verified | Yes (MIME part) | Low to medium | 3 | TODO |
| M11 | Hardcoded strings (`'Tune not available'`, `'Create new category'`, `'Privacy Policy'`, etc.), `Colors.red/grey/yellow`, `textMuted == dtextMuted == #A9A9A9` (~1.7:1 on the light background) and light/dark crossed; `MayuragiriLyricsSection` does not use `splitIntoVerses` | Yes | CLAUDE.md violations; Tamil users see English | 4 | TODO |
| M5 | `lib/generated/` is dead (no references) | Yes | Housekeeping | 4 | TODO |
| M6 | Large binaries tracked: `scriptures/*.pdf`, `assets/images/hero.png` (5.14 MiB), `scripts/output/mayuragiri_lyrics_separated.json` | Yes | Repo size | 4 | TODO (owner: confirm PDFs may be untracked) |
| S1b | `LinkUtils.isValidUrl` accepts userinfo (`https://a.com@evil.example`) | Technically | Very low (the confirm dialog names `uri.host`, the real host) | 4 | optional |
| S4 | Intent filters lack `android:host="song"` / `pathPrefix="/song/"`; `launchUrl` without try/catch in `song_web_links.dart` and `settings_screen.dart` | Yes | Low | later | DEFER |
| M3 | `applyImport` fires the mutation hook in `finally` even if the import failed | Yes | Low (one extra backup write) | later | DEFER |
| M8 | `AutoBackupService.writeNow()` shares one `.tmp` path | Plausible | Low (logged, retried) | later | DEFER |
| M4 | Async UI flows: `setState` before a `mounted` check, missing try/catch (`add_link_sheet`, `pick_song_screen`, `main_wrapper`, `search_screen`) | Plausible, not verified one by one | Low | later | DEFER |
| P1 | 9.87 MiB of duplicate migration JSON in the APK (sizes verified: 6.43 + 3.32 + 0.11 + 0.01 MiB) | Real opportunity | APK size | later | DEFER (riskiest; rewrites upgrade paths; needs the full v1 to v6 matrix) |
| P5 | Missing indexes on `songs(place)`, `songs(title)`, `songs(kaumaram_id)`, `links(song_id,url)` | Likely | Speed | later | DEFER (bundle with the next additive DB bump) |
| P3, P6, P7, P9-P13 | Search/detail rebuilds, `SELECT *` + jsonDecode per row, double DB open, redundant derived text in the DB, isolates, web og:image | Not measured | Speed/size | later | DEFER (nothing is broken today) |
| Other | CI gaps, S5 security headers on the fallback site, S6 proguard, unused `web/` scaffold, test-coverage gaps, low-severity list | Not verified | - | later | DEFER |

Verified true and not bugs (no action): `dbVersion = 6`, version `1.7.0+9`, asset sizes, `hero.png` size, `INTERNET` absent in release, parameterised SQL.

## 2. Batches

1. **Tamil and category fixes** (next release): M1, M2b, S2, P4, and a test for P2. No schema, backup or dependency impact.
2. **Data-safety check**: write the M7 test first (recovered DB + stale backup); fix only if it shows loss. Add the S1a hardening.
3. **Android pass**: P8 and M9. Needs a debug APK checked on the emulator.
4. **Housekeeping**: M11, M5, M6, S1b.
5. **Later, after a soak**: everything marked DEFER. Indexes go with the next additive DB bump (possibly together with the learning feature's v7).

Ordering rule: tests first; one small commit per logical fix; `CHANGELOG.md` `[Unreleased]` updated; `flutter analyze` clean and `flutter test` green before saying done; UI/native changes also built and checked on the emulator (see CLAUDE.md).

## 3. Progress log

Update this section as work lands.

- 2026-11-19: triage written.
- 2026-11-19: **Batch 1 done on `next`, uncommitted** (analyze clean, 352 tests pass; not checked on the emulator): M1 (new `lib/utils/category_name.dart` + `test/utils/category_name_test.dart`, used in the 3 places), M2b (`song_detail_screen.dart` no longer sets `_isFavorite` from the dialog result), S2 (3 SnackBars show localized text, errors logged; new `errorUpdatingCategory` in both arbs). `CHANGELOG.md` updated.
  - **Not done in Batch 1:** P4 (controller leaks): disposing right after `showDialog` completes would dispose while the dialog's exit animation still uses the controller, so it needs the small-StatefulWidget refactor; left for later. P2: still needs a widget test. M2b has no widget test yet (the song page is heavy to pump); verify on the emulator.
  - Committed as `493ec07`.
- 2026-11-19: **Batch 2 done on `next`, uncommitted.**
  - **M7 confirmed as a real bug** by `test/data/recovery_then_restore_test.dart` (it failed before the fix: an older auto-backup overwrote the rescued newer note and highlight). Fix: `DatabaseHelper.userDataRescued` (true after a complete rescue); `main.dart` passes `isFreshDatabase`/`databaseWasRecovered` as false in that case, so the snapshot is not restored. If the rescue was partial or failed, behaviour is as before (restore may fill the gaps).
  - Second M7 problem: rescuing a set-aside DB without a `links` table counted as a failure and stranded the old file. `_rescueUserData` now lists the old file's tables and skips missing ones. Test: `test/data/recovery_pre_links_test.dart` (written after the fix; not run red).
  - S1a: `maxBackupCategorySongs` (100,000) total cap in `validateBackupMap`; `maybeRestore` checks `maxBackupFileBytes` and that the JSON is an object; `pickAndPreviewBackup` checks the same. Tests added.
  - Not changed: M3, M8 (deferred).
  - Committed as `c573367`.
- 2026-11-19: **Round 2 of deferred items done** (analyze clean, 361 tests pass):
  - M3 fixed (`applyImport` fires the hook only after a successful commit; test added). M8 fixed (`writeNow` serializes writes with an in-flight future and a write-again flag; test with overlapping calls added).
  - M4 (the verified parts): `add_link_sheet` and `pick_song_screen` catch save errors, log them and show new `linkSaveFailed`; `main_wrapper` `_handleDeepLink` checks `mounted` and catches errors. Other M4 sub-items (categories-screen `setState` ordering, search-screen request guard and stale filter query, song-detail dialog `mounted` check) were not touched.
  - P2 **disproved**: `test/ui/widgets/add_to_category_dialog_test.dart` shows keyboard-inset frames do not reset ticks or re-query (this test also covers Tamil names in the dialog). Dropped.
  - P4 **won't fix**: disposing right after `showDialog` returns would dispose while the exit animation still uses the controller; the proper fix is three small StatefulWidget refactors for a few bytes saved per open. Not worth the risk.
  - S3: typing limits added (note 20,000, link 2,048, label 200; UI only, imports unlimited so no user data is ever refused).
  - Emulator: share to "Pick a song", search, choose a song: "Link added to ..." and the app returned to the launcher (debug APK). Not re-checked on the device: link-save failure message, note limit.
  - Still deferred, each needing a decision or its own project: S4 (intent filters), M6 (tracked binaries), M9 warm-start handler race (unverified), P1 (drop the migration JSONs), P5 (indexes, next DB bump), P3/P6/P7/P9-P13 (performance, unmeasured), M10 (reminder service), CI/Netlify items.
- 2026-11-19: **Batches 3 and 4 done** (commit `c5ae090`; analyze clean, 357 tests pass).
  - Batch 3: P8 (`TodaysSongWidget.onUpdate` uses `goAsync()` + a worker thread), M9 MIME (`startsWith("text/plain")`; the warm-start handler race was not changed or verified).
  - Batch 4: M11 partly (l10n for `Tune not available`, create-category label/tooltip, category semantics; `Colors.red`/yellow replaced by `AppColors.destructive`/`verseHighlight`; `textMuted` darkened to `#476450` and the light/dark references uncrossed), M5 (`lib/generated/` removed), S1b (`isValidUrl` rejects userinfo and URLs over 2,048 chars; test added).
  - **Deliberately not done:** hard-coded Tamil/English names in the language picker (native-script language names are the usual convention) and the bilingual privacy-policy screen (intentionally shows both languages); `Colors.black` lyric text and the white spinner (visual risk, no bug); `MayuragiriLyricsSection` still groups with a modulo, the same rule as the song page (switching to `splitIntoVerses` is a separate change); M6 (tracked PDFs, scraper JSON) left alone because `hero.png` is copied by `web_app/generate_site.py` for the site and the PDFs are the owner's deliverables (owner decision needed); S4 intent filters (deep links already shipped; narrowing could break installed links).
  - **Emulator (Medium_Phone_API_36, debug APK):** the app starts and shows Home and the song list in the new theme; sharing `text/plain;charset=utf-8` opened "Pick a song for this link" with the URL and title (M9 verified, warm start); favoriting a song then saving categories keeps the heart filled (M2b verified); "Add to Categories" lists an existing Tamil-named category. **Not verified on the device:** typing a Tamil category name (adb cannot type Tamil; unit tests only), the Today's song widget (cannot add it to a launcher from the command line), the cold-start share path, dark theme, the M7 recovery flow (unit-tested only).
  - **Release:** `flutter build apk --release` cannot run on this machine: `android/key.properties` points to a keystore file (`upload-keystore.jks` in the D: root) that does not exist here. R8 shrinking (`:app:minifyReleaseWithR8`) and `:app:lintVitalRelease` for the release variant both succeed. The signed release APK still has to be built and smoke-tested where the keystore is, before tagging.

## 4. The learning and memorization plan (`thiruppugazh_learning_and_memorization_plan.md`)

An expansion of `docs/memorization-practice-plan.md`. Checked: 1,340 songs; 9 songs have no `words`/`meanings`; 17 have no `english_title`; the existing plan's Leitner boxes (1/3/7/14/30 days) and "Again resets to box 1" are as described; `ChantingScreen` has manual and auto advance and none of the proposed loop/peek/word-split features; no `RECORD_AUDIO` permission today; the proposed `learning_songs` and `verse_progress` tables are additive and fit the CLAUDE.md migration and backup rules.

Not verified: how many songs have usable `mayuragiri_lyrics_separated` (the JSON has 1,334 entries; the doc says 1,300); the example starter-song numbers; whether `tune_list` parses into short/long beats.

Open design points for the owner: the new plan changes "Again" to step down 2 boxes instead of resetting to box 1; the per-verse meaning sheet needs `words`/`meanings` aligned to verses (prove with the Phase 0 data audit); Phase 1 (Chanting Studio, preferences only, no DB change) is the suggested start; Phase 4 would need an opt-in `RECORD_AUDIO` permission (owner decision). Nothing from this plan is started.
