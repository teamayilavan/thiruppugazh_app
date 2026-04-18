# Database Documentation

The application uses SQLite via the `sqflite` package. The database file `thiruppugazh.db` is pre-populated and copied from assets on first launch.

## Schema

### Tables

#### `songs`
Stores the main content of Thiruppugazh songs.
- `id` (INTEGER, PK): Unique identifier.
- `title` (TEXT): Title of the song.
- `lyrics` (TEXT): Full lyrics.
- `tune` (TEXT): Pann/Tune information.
- `place` (TEXT): Associated temple/place.
- `kaumaram_id` (TEXT): ID referencing Kaumaram.com.
- `words` (TEXT): Segmented words for search.
- `meanings` (TEXT): Explanatory meanings.
- `search_content` (TEXT): Optimized search text.
- `is_favorite` (INTEGER): 0 or 1 (Boolean).

#### `categories`
User-defined or system categories for organizing songs.
- `id` (INTEGER, PK, AutoIncrement)
- `name` (TEXT, Unique)

#### `song_categories`
Junction table for Many-to-Many relationship between Songs and Categories.
- `song_id` (INTEGER, FK -> songs.id)
- `category_id` (INTEGER, FK -> categories.id)

#### `temples`
Stores unique temples derived from songs.
- `id` (INTEGER, PK, AutoIncrement)
- `name` (TEXT, Unique)
- `song_count` (INTEGER)

#### `highlights`
User highlights within song verses.
- `id` (INTEGER, PK, AutoIncrement)
- `song_id` (INTEGER, FK -> songs.id)
- `verse_index` (INTEGER): Index of the verse highlighted.
- `text_content` (TEXT): The content highlighted.
- `created_at` (TEXT): ISO8601 Timestamp.

#### `notes`
User notes attached to songs.
- `id` (INTEGER, PK, AutoIncrement)
- `song_id` (INTEGER, FK -> songs.id)
- `content` (TEXT): The user's note.
- `created_at` (TEXT)
- `updated_at` (TEXT)

## Exposed Functions (DatabaseHelper)

### Songs
- `getAllSongs()`: Retrieve all songs sorted by title.
- `getSongById(int id)`: Retrieve a single song.
- `getSongsPaginated({int page, int pageSize})`: Retrieve songs in chunks.
- `searchSongsWithFilter(SearchFilter filter)`: Advanced search with filters (Title, Lyrics, Temple, Tune, Kaumaram ID). Handles Tamil character variations (e.g., ன/ந).

### Categories
- `getCategoriesWithSongCounts()`: List categories with count of songs.
- `createCategory(String name)`: Create a new category.
- `updateCategory(int id, String name)`: Rename a category.
- `deleteCategory(int id)`: Delete a category.
- `addSongToCategory(int songId, int categoryId)`: Add song to category.
- `getSongsByCategoryId(int categoryId)`: Retrieve songs in a category.

### Library (Favorites, Highlights, Notes)
- `toggleFavorite(int songId, bool isFavorite)`: Mark/unmark a song as favorite.
- `getFavoriteSongs()`: Retrieve all favorite songs.
- `addHighlight(Highlight highlight)`: Save a highlight.
- `getHighlightsForSong(int songId)`: Retrieve highlights for a specific song.
- `saveNote(Note note)`: Create or update a note for a song.
- `getNoteForSong(int songId)`: Retrieve the note for a specific song.

### Temples
- `getAllTemples()`: List all temples.
- `getSongsByTemple(String templeName)`: Retrieve songs associated with a temple.
