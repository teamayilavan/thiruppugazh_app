# English Lyrics & Meanings Integration — Change Guide

## Overview

The app already has a Tamil/English language toggle (for UI strings) and a `LanguageProvider`. Adding English lyrics and meanings requires changes across four layers: **database schema**, **data model**, **repository/query**, and **UI display**. No architectural changes are needed — this extends existing patterns cleanly.

---

## Layer 1 — Database (`assets/thiruppugazh.db` + `database_helper.dart`)

### 1a. Add columns to the `songs` table

Four new columns are needed, mirroring the existing Tamil columns:

| New Column       | Type | Mirrors      | Purpose                                 |
|------------------|------|--------------|-----------------------------------------|
| `lyrics_en`      | TEXT |`lyrics`      | Full English lyrics as a single string  |
| `lyrics_list_en` | TEXT |`lyrics_list` | JSON array of English verses            |
| `words_en`       | TEXT |`words`       | JSON array of English/transliterated words |
| `meanings_en`    | TEXT |`meanings`    | JSON array of English word meanings     |

### 1b. Populate the new columns

The pre-bundled `assets/thiruppugazh.db` must be updated with the English content **before** the app ships. Use any SQLite editor (DB Browser for SQLite, etc.) to run `UPDATE songs SET lyrics_en = ..., lyrics_list_en = ..., words_en = ..., meanings_en = ... WHERE id = ...` for each song.

### 1c. Bump the database version and write a migration

In `database_helper.dart`, bump `_databaseVersion` (currently `1` or `2`) by 1. Then in the `onUpgrade` callback, run `ALTER TABLE songs ADD COLUMN ...` for each of the four new columns, with a `DEFAULT ''` so existing installs don't break.

The migration is a simple `ALTER TABLE` — no data copy needed, because users will pull content from the updated bundled DB on a fresh install, and existing installs only gain the columns (empty until their DB is replaced via an app update).

---

## Layer 2 — Data Model (`lib/data/models/song_model.dart`)

### 2a. Add four new fields to the `Song` class

```
final String lyricsEn;
final List<String> lyricsListEn;
final List<String> wordsEn;
final List<String> meaningsEn;
```

### 2b. Update `Song.fromMap()`

Decode the four new columns exactly like the Tamil ones — `jsonDecode` for the list fields, plain string for `lyricsEn`.

### 2c. Update `Song.copyWith()` (if it exists)

Add the four new fields so the method stays complete.

---

## Layer 3 — Database Queries (`lib/data/database/database_helper.dart`)

### 3a. `CREATE TABLE` statement

Add the four columns to the `songs` table definition so new installs have them from the start.

### 3b. `getAllSongs()` / `getSongById()` / `searchSongsWithFilter()`

No query changes are needed if you use `SELECT *`. If explicit column lists are used anywhere, add the four new columns to those lists.

### 3c. Search behaviour

The existing `searchSongsWithFilter()` searches `lyrics` and `words` (Tamil). You may optionally extend the `WHERE` clause to also search `lyrics_en` and `words_en`, so English queries find results too. This is optional for the first version.

---

## Layer 4 — UI (`lib/ui/screens/song_detail_screen.dart`)

This is the only screen that renders lyrics and meanings. Two methods need a language-aware switch:

### 4a. `_buildLyricsTextSpans()`

Currently iterates `song.lyricsList`. After the change, it should iterate:
- `song.lyricsListEn` when `LanguageProvider.currentLanguage == AppLanguage.english`
- `song.lyricsList` otherwise (Tamil, the existing default)

The rest of the method (highlight logic, `_verseRanges`, `SelectableText.rich`) stays unchanged.

### 4b. `_buildMeaningsCard()`

Currently zips `song.words` and `song.meanings`. After the change, it should zip:
- `song.wordsEn` and `song.meaningsEn` when language is English
- `song.words` and `song.meanings` otherwise

The card layout, styling, and assert stay unchanged.

### 4c. Fallback handling

If a song's English content is empty (not yet translated), fall back to Tamil silently rather than showing a blank card. A simple `isNotEmpty` check on `song.lyricsListEn` before the language switch handles this.

---

## Layer 5 — Settings Screen (`lib/ui/screens/settings_screen.dart`)

### Current behaviour

The language toggle already exists. It switches the **UI language** (Tamil/English labels, buttons, headings). With the changes above, it will **also** switch the lyrics and meanings content automatically, because `song_detail_screen.dart` reads from `LanguageProvider`.

### No new UI needed

The existing "Language" setting in `settings_screen.dart` (lines 121–154) covers the requirement. Users already know how to switch language. No additional toggle or preference is required.

---

## Summary of Files to Change

| File | What Changes |
|------|-------------|
| `assets/thiruppugazh.db` | Add 4 columns; populate English content for all songs |
| `lib/data/database/database_helper.dart` | Add columns to `CREATE TABLE`; bump version; write `onUpgrade` migration |
| `lib/data/models/song_model.dart` | Add 4 new fields; update `fromMap()`; update `copyWith()` if present |
| `lib/ui/screens/song_detail_screen.dart` | Switch lyrics/meanings source based on `LanguageProvider` in two methods |

No changes are needed to `language_provider.dart`, `settings_screen.dart`, `song_repository.dart`, or any other file.

---

## Data Format Reference

The English data must match the existing Tamil JSON structure exactly:

- `lyrics_en` — plain string, full lyrics joined (can be the same as `lyrics_list_en` joined with newlines)
- `lyrics_list_en` — JSON array of strings, one element per verse/paragraph, e.g. `["Verse 1 line1\nline2", "Verse 2 line1\nline2"]`
- `words_en` — JSON array of strings, one per word/phrase, e.g. `["thiruppugazh", "murugan"]`
- `meanings_en` — JSON array of strings, same length as `words_en`, one meaning per entry

The `words_en` and `meanings_en` arrays **must be the same length** — the display code asserts this (existing assert in `_buildMeaningsCard()`).

---

## Rollout Considerations

1. **Database replacement on update**: When a user updates the app with the new `thiruppugazh.db`, the bundled DB has English content, but the user's existing on-device DB does not. The migration (`onUpgrade`) adds the empty columns. The English content won't appear for existing users unless you also implement a "reset database" or "sync content" mechanism. For a content-only app like this, the simplest approach is to increment the database version high enough to trigger a full DB replacement (copy asset DB over the existing one) rather than a column-level migration.

2. **Partial content**: If only some songs have English translations ready, the fallback in point 4c above ensures those songs gracefully display Tamil until English is available.

3. **Search**: Tamil spelling-variation logic (`_getTamilVariations()`) in `database_helper.dart` applies only to Tamil. English search needs no equivalent — standard SQLite `LIKE` is sufficient for English.
