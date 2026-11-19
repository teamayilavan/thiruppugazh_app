# Audit triage and fix plan (2026-11-19)

Read this first when continuing the audit work. It records what was checked against the code, what is real, and the ordered plan. Source documents (outside the repo, in `D:\`): `thiruppugazh_codebase_audit.md` (an external read-only audit of `next` @ `47c7f2c`, v1.7.0+9, DB v6) and `thiruppugazh_learning_and_memorization_plan.md` (see the last section).

**Method and limits.** Claims were spot-checked by reading code and measuring the bundled DB and asset sizes. Nothing was reproduced on a device. `flutter analyze` and `flutter test` were not run for the original audit. Performance, CI, Netlify and most line numbers were not checked.

**Rule of thumb:** the audit is good at *finding* issues but states several causes as certain when they are only plausible. Verify with a test before fixing.

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
  - Next: Batch 3 (Android: P8 widget off the main thread, M9 MIME), needs the emulator.

## 4. The learning and memorization plan (`thiruppugazh_learning_and_memorization_plan.md`)

An expansion of `docs/memorization-practice-plan.md`. Checked: 1,340 songs; 9 songs have no `words`/`meanings`; 17 have no `english_title`; the existing plan's Leitner boxes (1/3/7/14/30 days) and "Again resets to box 1" are as described; `ChantingScreen` has manual and auto advance and none of the proposed loop/peek/word-split features; no `RECORD_AUDIO` permission today; the proposed `learning_songs` and `verse_progress` tables are additive and fit the CLAUDE.md migration and backup rules.

Not verified: how many songs have usable `mayuragiri_lyrics_separated` (the JSON has 1,334 entries; the doc says 1,300); the example starter-song numbers; whether `tune_list` parses into short/long beats.

Open design points for the owner: the new plan changes "Again" to step down 2 boxes instead of resetting to box 1; the per-verse meaning sheet needs `words`/`meanings` aligned to verses (prove with the Phase 0 data audit); Phase 1 (Chanting Studio, preferences only, no DB change) is the suggested start; Phase 4 would need an opt-in `RECORD_AUDIO` permission (owner decision). Nothing from this plan is started.
