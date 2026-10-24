# Database Documentation

The application uses SQLite via the `sqflite` package. The database file `thiruppugazh.db` is pre-populated and bundled as an asset, then copied to the device on first launch.

**Current version:** 6 (adds the user-owned `links` table; v5 was data-only: fixed mis-parsed songs 1328 and 1338, restored songs 1–6)

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
| `mayuragiri_lyrics_separated` | TEXT | Tamil lyrics with padham (word) separation, sourced from mayuragiri.com |
| `mayuragiri_english_lyrics_separated` | TEXT | English/romanized equivalent |

Both nullable, populated via `assets/mayuragiri_data.json` (a patch keyed by song ID, applied in the v4 migration) rather than the main `songs/*.json` rebuild — the section stays hidden for any song where scraping didn't succeed.

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

### `links`

Web links a user attached to a song (a video, a discourse, a shared post). Many per song. Stores only the URL and an optional label — nothing is fetched, so it works fully offline; tapping a link opens it externally. Only `http`/`https` URLs are stored.

| Column | Type | Notes |
|---|---|---|
| `id` | INTEGER PK AutoIncrement | |
| `song_id` | INTEGER FK → `songs.id` | Cascade delete |
| `url` | TEXT | Absolute http(s) URL |
| `title` | TEXT | Optional user label; the UI falls back to the domain |
| `created_at` | TEXT | ISO 8601 timestamp |

---

## Indexes

| Index | Table | Column | Purpose |
|---|---|---|---|
| `idx_songs_is_favorite` | `songs` | `is_favorite` | Fast favorites query |
| `idx_song_categories_category_id` | `song_categories` | `category_id` | Fast category song list |
| `idx_highlights_song_id` | `highlights` | `song_id` | Fast highlight lookup per song |
| `idx_notes_song_id` | `notes` | `song_id` | Fast note lookup per song |
| `idx_links_song_id` | `links` | `song_id` | Fast link lookup per song |

---

## Migration History

| Version | Change |
|---|---|
| 1 | Initial schema |
| 2 | Added indexes (`idx_songs_is_favorite`, `idx_song_categories_category_id`, `idx_highlights_song_id`, `idx_notes_song_id`) |
| 3 | Added 7 English columns to `songs`; added `english_name` to `temples`; populated via `assets/english_data.json` migration asset |
| 4 | Added `mayuragiri_lyrics_separated`/`mayuragiri_english_lyrics_separated` to `songs`; populated via `assets/mayuragiri_data.json` migration asset |
| 5 | Data-only fix: `UPDATE`s songs 1328 and 1338 from `assets/song_fixes_v5.json` (`migrateToV5`). Touches only `lyrics`, `tune`, `tune_list`, `lyrics_list`, `pathavurai`, `search_content`, `mayuragiri_lyrics_separated` — never `is_favorite`, and never delete/replace (notes, highlights and category links cascade-delete with the song row). Also re-inserts songs 1–6 (`assets/song_restore_v5.json`, `INSERT OR IGNORE`, never overwriting an existing row, `is_favorite` always 0) and refreshes their temples' `song_count`. Fresh installs get the same rows from the rebuilt bundled DB. |
| 6 | Added the `links` table and `idx_links_song_id` (`migrateToV6`). Purely additive, idempotent, and non-fatal; existing data is untouched. Fresh installs create it in `onCreate`. |

---

## Known Data Issues

- **Fixed in v5 (2026-09-30):** songs **1328** (`ஏறுமயிலேறி`) and **1338** (`சிவணிதா வியமனது`) had their lyrics stored in the `tune` column. 1338's `tune` also held the word-separated (சொற்பிரிவு) block, now recovered into `mayuragiri_lyrics_separated`. 1328's `tune`/`tune_list` held 8 lyric lines plus prose meaning; the lyrics moved to `lyrics`/`lyrics_list` and the meaning to `pathavurai`. 1328's `tune` is now empty (the true tāḷa isn't in the source data) and it still has no `words`/`meanings` or English data; four trailing lines of its prose (`6. என்னை உன்னோடு…`) belonged to a different verse and were dropped.
- **Songs 1–6 restored in v5 (2026-09-30):** `கைத்தல நிறைகனி`, `பக்கரை விசித்ரமணி`, `உம்பர் தரு`, `நினது திருவடி`, `விடமடைசு வேலை` (place `விநாயகர்`) and `முத்தைத்தரு` (`திருவருணை`) were in the 1.1.0 database but silently missing from every bundled DB since 1.2.0, because the rebuild from `songs/*.json` started at `0007.json`. Recreated from the 1.1.0 DB as `songs/0001–0006.json` (stray whitespace trimmed). They have no English data (the app falls back to Tamil) and no Mayuragiri word-separated lyrics yet. Upgraders from 1.1.0 kept their original rows; their song 1 has place `" விநாயகர்"` (leading space), so the temple list shows two `விநாயகர்` entries for them — a 1.1.0-era quirk.
- **Still open:** no word-by-word meanings for 1328–1333, 1338–1340; no English data for 1–6, 67, 340, 444, 1327–1334; 1326 has no tune (intentional, not a tāḷa song); 1305 has 14 lyric lines / 6 tune lines (possibly two merged songs).

---

## `DatabaseHelper` API

**Transactions:** `runInTransaction<T>(Future<T> Function(Transaction txn) action)` runs a block atomically. The favorites/notes/highlights/categories mutation methods below all accept an optional trailing `{DatabaseExecutor? executor}` — pass the `Transaction` from `runInTransaction` to make a write participate in it instead of running against the default connection. Used by backup import (`BackupService.applyImport`, see [`automated-backup-plan.md`](automated-backup-plan.md)) so a failed or interrupted import can't leave the database half-written.

**Mutation hook:** `DatabaseHelper.onMutation` is a static `void Function()?` callback fired after every favorite/category/note/highlight write (regardless of whether it ran inside a transaction). `AutoBackupService` sets this at app startup to debounce a fresh backup snapshot write on any change.

### Songs
- `getAllSongs()` — all songs sorted by Tamil title
- `getSongById(int id)` — single song by ID
- `getRandomSong()` — one uniformly random song, queried DB-wide (`ORDER BY RANDOM() LIMIT 1`), not just from whatever page is loaded — backs the Home screen's random-song shuffle FAB
- `getSongByIndex(int index)` — single song by row position
- `getSongsPaginated({int page, int pageSize})` — paginated list
- `getAllSongIds({DatabaseExecutor? executor})` — every song ID as a `Set<int>`, used by backup import to skip entries referencing a song no longer in this install instead of tripping a foreign-key constraint
- `searchSongsWithFilter(SearchFilter filter)` — LIKE-based search across title, lyrics, words, place, tune, kaumaram\_id, pathavurai; handles Tamil ன/ந variation and casual "Tanglish" spelling (place/temple search only) for English/romanized fields; v3 also searches English columns in parallel

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

### Links
- `addLink(SongLink link)` — insert
- `addLinkIfAbsent(SongLink link)` — insert unless the song already has that URL; returns whether a row was added (used by backup import and the share flow)
- `deleteLink(int id)`
- `getLinksForSong(int songId)` — oldest first
- `getAllLinks()`
- `getLinksWithSongs()` — links joined with song titles

### Temples
- `getAllTemples()` — all temples sorted by Tamil name; returns `english_name` column in v3
- `getSongsByTemple(String templeName)` — songs by Tamil `place` value
