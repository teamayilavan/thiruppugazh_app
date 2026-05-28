# Database Documentation

The application uses SQLite via the `sqflite` package. The database file `thiruppugazh.db` is pre-populated and bundled as an asset, then copied to the device on first launch.

**Current version:** 2  
**Planned version:** 3 (bilingual content feature — see `docs/superpowers/specs/2026-05-28-bilingual-content-design.md`)

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

**English content (added in v3):**

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

## Indexes

| Index | Table | Column | Purpose |
|---|---|---|---|
| `idx_songs_is_favorite` | `songs` | `is_favorite` | Fast favorites query |
| `idx_song_categories_category_id` | `song_categories` | `category_id` | Fast category song list |
| `idx_highlights_song_id` | `highlights` | `song_id` | Fast highlight lookup per song |
| `idx_notes_song_id` | `notes` | `song_id` | Fast note lookup per song |

---

## Migration History

| Version | Change |
|---|---|
| 1 | Initial schema |
| 2 | Added indexes (`idx_songs_is_favorite`, `idx_song_categories_category_id`, `idx_highlights_song_id`, `idx_notes_song_id`) |
| 3 (planned) | Added 7 English columns to `songs`; added `english_name` to `temples`; populated via `assets/english_data.json` migration asset |

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
