# Database Documentation

The application uses SQLite via the `sqflite` package. The database file `thiruppugazh.db` is pre-populated and bundled as an asset, then copied to the device on first launch.

**Current version:** 5 (practice tracking — `reading_log`, `practice_days`, `milestones`)

---

## Schema

### `songs`

Stores the main content of all Thiruppugazh songs.

**Tamil content (v1/v2):**

| Column | Type | Notes |
|---|---|---|
| `id` | INTEGER PK | Unique identifier |
| `title` | TEXT | Tamil title |
| `lyrics` | TEXT | Full Tamil lyrics (joined string) |
| `tune` | TEXT | Tāḷa pattern (joined string) |
| `place` | TEXT | Associated temple name (Tamil) |
| `kaumaram_id` | TEXT | Reference ID on Kaumaram.com |
| `tune_list` | TEXT | JSON array of tāḷa lines |
| `lyrics_list` | TEXT | JSON array of lyric lines |
| `words` | TEXT | JSON array of word-group strings (from `word_meanings[].words`) |
| `meanings` | TEXT | JSON array of meaning strings (from `word_meanings[].meaning`) |
| `pathavurai` | TEXT | All meanings joined as a single paragraph (search use only) |
| `patham` | TEXT | Segmented word breakdown (search use only) |
| `search_content` | TEXT | Denormalized search text |
| `is_favorite` | INTEGER | 0 or 1 |

**English content (v3):**

| Column | Type | Notes |
|---|---|---|
| `english_title` | TEXT | Romanized title |
| `english_venue` | TEXT | Romanized temple name |
| `english_tune_list` | TEXT | JSON array — Tamil tune syllables transliterated |
| `english_lyrics_list` | TEXT | JSON array — romanized lyric lines (empty separators stripped) |
| `english_words` | TEXT | JSON array — `english_meanings[i].word` for each i |
| `english_meanings_list` | TEXT | JSON array — `english_meanings[i].meaning` for each i |
| `english_pathavurai` | TEXT | All English meanings joined (search use only) |

All v3 English columns are nullable. Songs without English data (7 songs as of v3) have NULL in these columns; the app falls back to Tamil for those.

**Mayuragiri word-separated lyrics (v4):**

| Column | Type | Notes |
|---|---|---|
| `mayuragiri_lyrics_separated` | TEXT | JSON array — padham-separated Tamil lyrics, scraped from mayuragiri.info |
| `mayuragiri_english_lyrics_separated` | TEXT | JSON array — the English-transliterated equivalent |

Populated via `assets/mayuragiri_data.json` (built by `scripts/build_db.py` from `scripts/mayuragiri_scraper.py`'s output). Both columns are nullable — `Song.hasMayuragiriContent` is false and the section stays hidden when a song has neither.

---

### `categories`

User-defined and system categories for organising songs.

| Column | Type | Notes |
|---|---|---|
| `id` | INTEGER PK AutoIncrement | |
| `name` | TEXT UNIQUE | `id = 1` is reserved for "Favorites" |

---

### `song_categories`

Junction table — many-to-many between songs and categories.

| Column | Type | Notes |
|---|---|---|
| `song_id` | INTEGER FK → `songs.id` | Cascade delete |
| `category_id` | INTEGER FK → `categories.id` | Cascade delete |

---

### `temples`

Distinct temple names derived from `songs.place`, with song counts.

| Column | Type | Notes |
|---|---|---|
| `id` | INTEGER PK AutoIncrement | |
| `name` | TEXT UNIQUE | Tamil temple name — used as the query key for `getSongsByTemple()` |
| `song_count` | INTEGER | Count of songs for that temple |
| `english_name` | TEXT | Romanized temple name (added in v3, nullable) |

`english_name` is populated in the v3 migration via:
```sql
UPDATE temples
SET english_name = (
  SELECT english_venue FROM songs
  WHERE songs.place = temples.name
    AND songs.english_venue IS NOT NULL
  LIMIT 1
);
```

---

### `highlights`

User-created highlights within song verses.

| Column | Type | Notes |
|---|---|---|
| `id` | INTEGER PK AutoIncrement | |
| `song_id` | INTEGER FK → `songs.id` | Cascade delete |
| `verse_index` | INTEGER | Index into `lyrics_list` |
| `text_content` | TEXT | The highlighted text |
| `created_at` | TEXT | ISO 8601 timestamp |

---

### `notes`

User notes attached to songs (one note per song).

| Column | Type | Notes |
|---|---|---|
| `id` | INTEGER PK AutoIncrement | |
| `song_id` | INTEGER FK → `songs.id` | Cascade delete |
| `content` | TEXT | Note body |
| `created_at` | TEXT | ISO 8601 timestamp |
| `updated_at` | TEXT | ISO 8601 timestamp |

---

### `reading_log` (v5)

One row per song per day a devotee opened it. Populated by `DatabaseHelper.recordDwell`, called from `SongDetailScreen`'s dwell tracking — see `docs/gamification-implementation-plan.md` T1.6.

| Column | Type | Notes |
|---|---|---|
| `id` | INTEGER PK AutoIncrement | |
| `song_id` | INTEGER FK → `songs.id` | Cascade delete |
| `read_on` | TEXT | Local-date ISO string (`yyyy-MM-dd`) — never a UTC timestamp; a practice day is a human day in the devotee's own timezone |
| `dwell_seconds` | INTEGER | Foreground reading time that day for this song; upserted to the **maximum** seen, never downgraded |
| `completed` | INTEGER | 0 or 1 — set once foreground dwell reaches `AppConstants.dwellSecondsToComplete` (90s) or the lyrics are scrolled to the end; never downgraded from 1 to 0 |

`UNIQUE(song_id, read_on)` — `recordDwell` upserts on this constraint inside a transaction.

---

### `practice_days` (v5)

Denormalised from `reading_log` so the home screen's daily card never scans it — one row per day with any reading activity (a "kept day", per strategy §6.8 — showing up counts, not only finishing).

| Column | Type | Notes |
|---|---|---|
| `day` | TEXT PK | Local-date ISO string (`yyyy-MM-dd`) |
| `songs_completed` | INTEGER | `COUNT(*)` of that day's `reading_log` rows with `completed = 1`, recomputed on every `recordDwell` call |
| `verse_seen` | INTEGER | Reserved — not yet written by any v5 code path |

**Total days kept** — `SELECT COUNT(*) FROM practice_days` (never resets). **Current continuity** — `DatabaseHelper.getCurrentContinuity()` walks this table backwards from today (from yesterday if today has no row yet, so an in-progress day doesn't zero an unbroken streak).

---

### `milestones` (v5)

Reserved for Phase 2 (T2.6) — not yet written by any v5 code path.

| Column | Type | Notes |
|---|---|---|
| `key` | TEXT PK | e.g. `songs_108`, `arupadai_pazhani` |
| `achieved_on` | TEXT | ISO 8601 timestamp |

---

## Indexes

| Index | Table | Column | Purpose |
|---|---|---|---|
| `idx_songs_is_favorite` | `songs` | `is_favorite` | Fast favorites query |
| `idx_song_categories_category_id` | `song_categories` | `category_id` | Fast category song list |
| `idx_highlights_song_id` | `highlights` | `song_id` | Fast highlight lookup per song |
| `idx_notes_song_id` | `notes` | `song_id` | Fast note lookup per song |
| `idx_reading_log_read_on` | `reading_log` | `read_on` | Fast lookup of a given day's rows |
| `idx_reading_log_song_id` | `reading_log` | `song_id` | Fast lookup of a given song's history |

---

## Migration History

| Version | Change |
|---|---|
| 1 | Initial schema |
| 2 | Added indexes (`idx_songs_is_favorite`, `idx_song_categories_category_id`, `idx_highlights_song_id`, `idx_notes_song_id`) |
| 3 | Added 7 English columns to `songs`; added `english_name` to `temples`; populated via `assets/english_data.json` migration asset |
| 4 | Added `mayuragiri_lyrics_separated` and `mayuragiri_english_lyrics_separated` to `songs`; populated via `assets/mayuragiri_data.json` migration asset |
| 5 | Added `reading_log`, `practice_days`, `milestones` for the gamification/practice-tracking layer (`docs/gamification-implementation-plan.md` Phase 1) — new tables only, no changes to existing ones |

---

## Known Data Issues

- **Song 1328** (`ஏறுமயிலேறி`, திருவருணை): the `tune`/`tune_list` columns contain what looks like the song's full lyrics and meaning text, while `lyrics_list`/`lyrics`/`pathavurai` are empty. This affects both the app's `SongDetailScreen` (renders the misplaced text under "சந்தம்") and the fallback web app (`web_app/`), since both read the same columns. Root cause is in the source data (`songs/*.json`, rebuilt via `scripts/build_db.py`), not a rendering bug — found while building the web app's static pages (2026-08-19), not yet fixed.

---

## `DatabaseHelper` API

### Songs
- `getAllSongs()` — all songs sorted by Tamil title
- `getSongById(int id)` — single song by ID
- `getSongsPaginated({int page, int pageSize})` — paginated list
- `searchSongsWithFilter(SearchFilter filter)` — LIKE-based search across title, lyrics, words, place, tune, kaumaram\_id, pathavurai; handles Tamil ன/ந variation; v3 also searches English columns in parallel

### Categories
- `getCategoriesWithSongCounts()` — categories with song counts
- `createCategory(String name)` — new category
- `updateCategory(int id, String name)` — rename
- `deleteCategory(int id)` — delete (cascades to `song_categories`)
- `addSongToCategory(int songId, int categoryId)`
- `removeSongFromCategory(int songId, int categoryId)`
- `getSongsByCategoryId(int categoryId)`
- `getCategoryIdsForSong(int songId)`

### Favorites
- `toggleFavorite(int songId, bool isFavorite)`
- `getFavoriteSongs()`

### Highlights
- `addHighlight(Highlight highlight)`
- `removeHighlight(int songId, int verseIndex)`
- `getHighlightsForSong(int songId)`
- `getAllHighlights()`
- `getHighlightsWithSongs()` — highlights joined with song titles

### Notes
- `saveNote(Note note)` — insert or update
- `getNoteForSong(int songId)`
- `getAllNotes()`
- `getNotesWithSongs()` — notes joined with song titles
- `deleteNote(int songId)`

### Temples
- `getAllTemples()` — all temples sorted by Tamil name; returns `english_name` column in v3
- `getSongsByTemple(String templeName)` — songs by Tamil `place` value

### Practice tracking (v5)
- `recordDwell(int songId, String day, int dwellSeconds, bool completed)` — upserts on `UNIQUE(song_id, read_on)`, keeps the max dwell, never downgrades `completed`; recomputes `practice_days.songs_completed` for `day` in the same transaction
- `getCompletedSongCount()` — `COUNT(DISTINCT song_id)` with `completed = 1`
- `isSongCompleted(int songId)`
- `getTotalPracticeDays()` — `COUNT(*) FROM practice_days`
- `getCurrentContinuity()` — walks `practice_days` backwards from today
- `getPracticeDaysInRange(String from, String to)`
- `getCompletedCountByTemple()` — completed counts grouped by `songs.place`
- `getCompletedSongIds()`
- `getAllSongIds()` — lightweight, ids only, for the daily selection service's index mapping
- `isDayComplete(String day)` — whether `day`'s row shows at least one completed song
- `getAllReadingLog()`, `getAllPracticeDays()`, `getAllMilestones()` — raw rows for `BackupService` export
- `upsertReadingLogRow(Map)`, `upsertPracticeDayRow(Map)`, `upsertMilestoneRow(Map)` — raw-row upserts for `BackupService` import
