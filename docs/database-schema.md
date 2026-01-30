# Database Schema Documentation

## Overview

The Thiruppugazh app uses SQLite database stored as `assets/thiruppugazh.db`. The database is initialized by copying from assets to the device's documents directory on first launch.

## Database Architecture

### Initialization Process

1. **Database File**: `thiruppugazh.db` located in `assets/` folder
2. **Copy Strategy**: On app initialization, the database is copied to the device's documents directory
3. **Update Strategy**: Currently uses force replacement - deletes existing database and copies fresh one from assets
4. **Location**: `getApplicationDocumentsDirectory()/thiruppugazh.db`

### Database Helper Class

**File**: `lib/data/database/database_helper.dart`

- Implements Singleton pattern
- Manages database connection lifecycle
- Provides query methods for all data operations
- Uses `sqflite` package with FFI support for cross-platform compatibility

## Tables

### 1. songs Table

Stores all song information including lyrics, meanings, and metadata.

#### Columns

| Column Name | Type | Description | Example |
|-------------|------|-------------|---------|
| `id` | INTEGER | Primary key, auto-increment | 1, 2, 3... |
| `title` | TEXT | Song title (Tamil) | "முத்துத்தாண்டவர்" |
| `kaumaram_id` | TEXT | Kaumaram website reference ID | "1", "23", "145" |
| `lyrics` | TEXT | Complete song lyrics (Tamil) | Full song text |
| `place` | TEXT | Temple/Location name (thiruthalam) | "திருத்தணி" |
| `tune` | TEXT | Tune/Meter information (santham) | "தாளம் - ரூபகம்" |
| `lyrics_list` | TEXT | JSON array of lyrics paragraphs | `["paragraph1", "paragraph2"]` |
| `tune_list` | TEXT | JSON array of tune information | `["tune1", "tune2"]` |
| `words` | TEXT | JSON array of words for meanings | `["word1", "word2"]` |
| `meanings` | TEXT | JSON array of word meanings (porul) | `["meaning1", "meaning2"]` |
| `pathavurai` | TEXT | Song introduction/precis | Introductory text |
| `patham` | TEXT | JSON array of patham information | `["patham1", "patham2"]` |

#### Notes:
- `lyrics_list`, `tune_list`, `words`, `meanings`, and `patham` are stored as JSON strings
- These JSON arrays are decoded to Dart Lists using `jsonDecode()`
- `lyrics_list` contains paragraph-separated lyrics
- `words` and `meanings` arrays have corresponding indices for word-to-meaning mapping
- `tune_list` has same length as `lyrics_list` to map tune to each paragraph

#### Sample Data Structure
```json
{
  "id": 1,
  "title": "முத்துத்தாண்டவர் முருகா முதல்வா",
  "kaumaram_id": "1",
  "lyrics": "Complete song lyrics...",
  "place": "திருத்தணி",
  "tune": "தாளம் - ரூபகம்",
  "lyrics_list": "[\"paragraph1\", \"paragraph2\", \"paragraph3\"]",
  "tune_list": "[\"tune1\", \"tune2\", \"tune3\"]",
  "words": "[\"word1\", \"word2\", \"word3\"]",
  "meanings": "[\"meaning1\", \"meaning2\", \"meaning3\"]",
  "pathavurai": "Song introduction...",
  "patham": "[\"patham1\", \"patham2\"]"
}
```

### 2. categories Table

Stores user-defined and system categories for organizing songs.

#### Columns

| Column Name | Type | Description | Example |
|-------------|------|-------------|---------|
| `id` | INTEGER | Primary key, auto-increment | 1, 2, 3... |
| `name` | TEXT | Category name | "Favorites", "Morning Songs" |

#### Special Categories:
- **Category ID 1**: Reserved as "Favorites" - special handling in the app
- **Category IDs > 1**: User-created custom categories

#### Sample Data Structure
```json
{
  "id": 1,
  "name": "Favorites"
}
```

### 3. song_categories Table

Many-to-many relationship table linking songs to categories.

#### Columns

| Column Name | Type | Description | Example |
|-------------|------|-------------|---------|
| `song_id` | INTEGER | Foreign key referencing songs.id | 1, 2, 3... |
| `category_id` | INTEGER | Foreign key referencing categories.id | 1, 2, 3... |

#### Composite Key:
- Unique constraint on `(song_id, category_id)` to prevent duplicate associations
- Uses `ConflictAlgorithm.ignore` to handle duplicates

#### Sample Data Structure
```json
{
  "song_id": 1,
  "category_id": 1
}
```

## Relationships

### Entity Relationship Diagram

```
songs (1) ----< song_categories >---- (*) categories
    |                                         |
    |                                         |
    id (PK)                                  id (PK)
    title                                    name
    kaumaram_id
    lyrics
    place
    tune
    lyrics_list (JSON)
    tune_list (JSON)
    words (JSON)
    meanings (JSON)
    pathavurai
    patham (JSON)
```

### Relationship Rules:

1. **One-to-Many (Songs ↔ SongCategories)**: A song can be associated with multiple categories
2. **Many-to-Many (Songs ↔ Categories)**: Implemented through junction table
3. **Foreign Key Constraints**:
   - `song_categories.song_id` → `songs.id`
   - `song_categories.category_id` → `categories.id`

## Indexes

### Implicit Indexes
- Primary key indexes on `songs.id`, `categories.id`
- Unique index on `song_categories(song_id, category_id)`

### Search Optimization
- Full-Text Search (FTS) table for efficient song search
- Searches are performed using `LIKE` queries on `songs.title` and `songs.lyrics`

## Key Queries

### Get All Songs
```sql
SELECT * FROM songs ORDER BY title
```

### Search Songs
```sql
SELECT * FROM songs
WHERE title LIKE ? OR lyrics LIKE ?
```

### Get Categories with Song Counts
```sql
SELECT
  c.id,
  c.name,
  COUNT(sc.song_id) AS song_count
FROM categories c
LEFT JOIN song_categories sc ON c.id = sc.category_id
GROUP BY c.id, c.name
ORDER BY c.id
```

### Get Songs by Category
```sql
SELECT s.*
FROM songs s
INNER JOIN song_categories sc ON s.id = sc.song_id
WHERE sc.category_id = ?
ORDER BY s.title
```

### Get Category IDs for a Song
```sql
SELECT category_id
FROM song_categories
WHERE song_id = ?
```

### Add Song to Category
```sql
INSERT INTO song_categories (song_id, category_id)
VALUES (?, ?)
ON CONFLICT(song_id, category_id) DO NOTHING
```

### Remove Song from Category
```sql
DELETE FROM song_categories
WHERE song_id = ? AND category_id = ?
```

### Create Category
```sql
INSERT INTO categories (name)
VALUES (?)
ON CONFLICT DO NOTHING
```

### Delete Category
```sql
DELETE FROM categories
WHERE id = ?
```

## Data Models

### Song Model

**File**: `lib/data/models/song_model.dart`

```dart
class Song {
  final int id;
  final String title;
  final String kaumaramId;
  final String lyrics;
  final String place;
  final String tune;
  final List<String> lyricsList;
  final List<String> tuneList;
  final List<String> words;
  final List<String> meanings;
  final String pathavurai;
  final List<String> patham;
  List<int> categoryIds; // Mutable, managed at app level
}
```

**Key Points:**
- Immutable model (except `categoryIds`)
- Factory constructor `fromMap()` converts database rows to Song objects
- JSON fields are decoded from TEXT to Dart Lists
- `categoryIds` is populated separately by repository

### Category Model

**File**: `lib/data/models/category_model.dart`

```dart
class Category {
  final int? id;
  final String name;
  final int songCount; // Calculated, not stored in DB
}
```

**Key Points:**
- `id` is nullable for creation scenarios
- `songCount` is calculated at query time using COUNT aggregate
- Factory constructor `fromMap()` converts database rows to Category objects

## Database Operations

### Initialization Flow

1. Check if database exists in documents directory
2. If exists, delete existing database (force replacement strategy)
3. Create directory structure
4. Load database from assets
5. Write bytes to documents directory
6. Open database connection

### CRUD Operations

All CRUD operations are encapsulated in:
- `DatabaseHelper` class - Direct database operations
- `SongRepository` class - Business logic layer with state management

### Error Handling

- Try-catch blocks for database operations
- Logging of errors during initialization
- Graceful fallback for missing data
- Null safety with `??` operators for optional fields

## Performance Considerations

1. **Lazy Loading**: Songs loaded on-demand using FutureBuilder
2. **Connection Pooling**: Singleton pattern maintains single database connection
3. **Query Optimization**: Efficient JOINs and aggregates for category counts
4. **Debouncing**: Search operations debounced to prevent excessive queries
5. **JSON Decoding**: Performed only once during object creation

## Future Enhancements

Potential database improvements:
1. Add FTS5 virtual table for faster full-text search
2. Implement database versioning and migration system
3. Add indexes on frequently queried columns (`title`, `place`)
4. Implement incremental updates instead of full replacement
5. Add caching layer for frequently accessed songs
6. Consider offline sync capabilities
