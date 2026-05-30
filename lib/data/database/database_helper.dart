import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/song_model.dart';
import '../models/category_model.dart';
import '../models/search_filter.dart';
import '../models/highlight_model.dart';
import '../models/note_model.dart';
import '../../utils/app_logger.dart';
import '../../constants/app_constants.dart';

/// A singleton class to manage the SQLite database connection and queries.
class DatabaseHelper {
  // Singleton pattern setup
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Future<Database>? _databaseFuture;
  static const String _dbName = "thiruppugazh.db";
  static const int _dbVersion = AppConstants.dbVersion;

  /// Returns the singleton database instance, initializing it if necessary.
  /// Caches the Future itself so concurrent callers all await the same init.
  Future<Database> get database => _databaseFuture ??= _initDatabase();

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    // Check if the database exists
    final exists = await databaseExists(path);

    if (!exists) {
      // If not, copy from assets
      AppLogger.info("Creating new copy from asset");
      try {
        await Directory(dirname(path)).create(recursive: true);
        
        // Copy from asset
        ByteData data = await rootBundle.load('assets/thiruppugazh.db');
        List<int> bytes =
            data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
            
        await File(path).writeAsBytes(bytes, flush: true);
        AppLogger.info("Database copied from assets");

      } catch (e, stackTrace) {
        AppLogger.error("Fatal: failed to copy bundled database", error: e, stackTrace: stackTrace);
        rethrow;
      }
    } else {
      AppLogger.info("Opening existing database");
    }

    return await openDatabase(
      path,
      version: _dbVersion,
      onConfigure: (db) async {
         // Enable foreign keys
         await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        // Since we copied the asset, 'songs' table should exist.
        // We need to ensure other tables exist and populate temples.
        await _initializeSchema(db);
        await _addIndexes(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _addIndexes(db);
        }
        if (oldVersion < 3) {
          await _migrateToV3(db);
        }
      },
      onOpen: (db) async {
         // Ensure schema is up to date even on open if needed
         // (Optional, but safe for dev environments where asset might be replaced)
         // For now, we rely on onCreate/onUpgrade
      }
    );
  }

  Future<void> _initializeSchema(Database db) async {
    AppLogger.info("Initializing database schema");

    // 1. Ensure 'songs' table exists (it should from asset)
    // If not, we have a problem, but let's define it just in case of empty db creation
    await db.execute('''
      CREATE TABLE IF NOT EXISTS songs(
        id                    INTEGER PRIMARY KEY,
        title                 TEXT NOT NULL,
        lyrics                TEXT,
        tune                  TEXT,
        place                 TEXT,
        kaumaram_id           TEXT,
        tune_list             TEXT,
        lyrics_list           TEXT,
        words                 TEXT,
        meanings              TEXT,
        pathavurai            TEXT,
        patham                TEXT,
        search_content        TEXT,
        is_favorite           INTEGER DEFAULT 0,
        english_title         TEXT,
        english_venue         TEXT,
        english_tune_list     TEXT,
        english_lyrics_list   TEXT,
        english_words         TEXT,
        english_meanings_list TEXT,
        english_pathavurai    TEXT
      )
    ''');

    // 2. Create Categories table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS categories(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE
      )
    ''');

    // Insert default 'Favorites' category if it doesn't exist
    await db.execute('''
      INSERT OR IGNORE INTO categories (id, name) VALUES (1, 'Favorites')
    ''');

    // 3. Create Song Categories mapping table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS song_categories(
        song_id INTEGER,
        category_id INTEGER,
        PRIMARY KEY (song_id, category_id),
        FOREIGN KEY(song_id) REFERENCES songs(id) ON DELETE CASCADE,
        FOREIGN KEY(category_id) REFERENCES categories(id) ON DELETE CASCADE
      )
    ''');

    // 4. Create Temples table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS temples(
        id           INTEGER PRIMARY KEY AUTOINCREMENT,
        name         TEXT NOT NULL UNIQUE,
        song_count   INTEGER DEFAULT 0,
        english_name TEXT
      )
    ''');

    // 5. Create Highlights table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS highlights(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        song_id INTEGER NOT NULL,
        verse_index INTEGER NOT NULL,
        text_content TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY(song_id) REFERENCES songs(id) ON DELETE CASCADE
      )
    ''');

    // 6. Create Notes table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS notes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        song_id INTEGER NOT NULL,
        content TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY(song_id) REFERENCES songs(id) ON DELETE CASCADE
      )
    ''');

    // 7. Populate Temples Table
    // We only want to populate if it's empty to avoid re-calculating on every open/upgrade unnecessarily,
    // unless we want to ensure sync.
    // Let's check count first.
    final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM temples'));

    if (count == 0) {
      AppLogger.info('Populating temples table');
      final List<Map<String, dynamic>> places = await db.rawQuery('''
        SELECT place, COUNT(*) as count
        FROM songs
        WHERE place IS NOT NULL AND place != ''
        GROUP BY place
      ''');

      final batch = db.batch();
      for (final place in places) {
        batch.insert('temples', {
          'name': place['place'],
          'song_count': place['count']
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }
      await batch.commit(noResult: true);
    }

    // 8. Ensure is_favorite column exists in songs (if asset didn't have it)
    try {
      await db.rawQuery('SELECT is_favorite FROM songs LIMIT 1');
    } catch (_) {
      // Column doesn't exist, add it
      AppLogger.info('Adding is_favorite column to songs');
       await db.execute('ALTER TABLE songs ADD COLUMN is_favorite INTEGER DEFAULT 0');
    }
  }

  Future<void> _addIndexes(Database db) async {
    // Index for fast favorite lookups (WHERE is_favorite = 1)
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_songs_is_favorite
      ON songs(is_favorite)
    ''');

    // Index for fast category-based song lookups
    // (composite PK covers song_id first; this covers category_id queries)
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_song_categories_category_id
      ON song_categories(category_id)
    ''');

    // Index for fast highlight lookups by song
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_highlights_song_id
      ON highlights(song_id)
    ''');

    // Index for fast note lookups by song
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_notes_song_id
      ON notes(song_id)
    ''');
  }

  Future<void> _migrateToV3(Database db) async {
    AppLogger.info('Running v3 migration: adding English content columns');

    // Step 1: Add English columns to songs (all nullable)
    for (final col in [
      'english_title',
      'english_venue',
      'english_tune_list',
      'english_lyrics_list',
      'english_words',
      'english_meanings_list',
      'english_pathavurai',
    ]) {
      await db.execute('ALTER TABLE songs ADD COLUMN $col TEXT');
    }

    // Step 2: Add english_name to temples
    await db.execute('ALTER TABLE temples ADD COLUMN english_name TEXT');

    // Step 3: Populate songs English columns from bundled JSON asset
    try {
      final jsonString = await rootBundle.loadString(AppConstants.englishDataAsset);
      final Map<String, dynamic> patch = jsonDecode(jsonString);

      final batch = db.batch();
      for (final entry in patch.entries) {
        final id = int.tryParse(entry.key);
        if (id == null) continue;
        final fields = entry.value as Map<String, dynamic>;
        batch.update(
          'songs',
          {
            'english_title':         fields['english_title'],
            'english_venue':         fields['english_venue'],
            'english_tune_list':     fields['english_tune_list'],
            'english_lyrics_list':   fields['english_lyrics_list'],
            'english_words':         fields['english_words'],
            'english_meanings_list': fields['english_meanings_list'],
            'english_pathavurai':    fields['english_pathavurai'],
          },
          where: 'id = ?',
          whereArgs: [id],
        );
      }
      await batch.commit(noResult: true);
      AppLogger.info('v3 migration: populated English data for ${patch.length} songs');
    } catch (e, st) {
      AppLogger.error('v3 migration: failed to populate English data', error: e, stackTrace: st);
      // Non-fatal: English columns remain NULL, app falls back to Tamil
    }

    // Step 4: Populate temples.english_name from songs (runs after Step 3)
    await db.execute('''
      UPDATE temples
      SET english_name = (
        SELECT english_venue FROM songs
        WHERE songs.place = temples.name
          AND songs.english_venue IS NOT NULL
        LIMIT 1
      )
    ''');

    AppLogger.info('v3 migration complete');
  }

  // --- Highlights Methods ---
  
  Future<int> addHighlight(Highlight highlight) async {
    final db = await database;
    return await db.insert('highlights', highlight.toMap());
  }
  
  Future<void> removeHighlight(int songId, int verseIndex) async {
    final db = await database;
    await db.delete(
      'highlights', 
      where: 'song_id = ? AND verse_index = ?',
      whereArgs: [songId, verseIndex]
    );
  }
  
  Future<List<Highlight>> getHighlightsForSong(int songId) async {
    final db = await database;
    final maps = await db.query(
      'highlights',
      where: 'song_id = ?',
      whereArgs: [songId],
    );
    return List.generate(maps.length, (i) => Highlight.fromMap(maps[i]));
  }
  
  Future<List<Highlight>> getAllHighlights() async {
    final db = await database;
    final maps = await db.query('highlights', orderBy: 'created_at DESC');
    return List.generate(maps.length, (i) => Highlight.fromMap(maps[i]));
  }

  /// Returns all highlights joined with their song titles in one query.
  /// Each map contains all highlight columns plus `song_title`.
  Future<List<Map<String, dynamic>>> getHighlightsWithSongs() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT h.id, h.song_id, h.verse_index, h.text_content, h.created_at,
             s.title AS song_title
      FROM highlights h
      INNER JOIN songs s ON h.song_id = s.id
      ORDER BY h.created_at DESC
    ''');
  }

  // --- Notes Methods ---

  Future<int> saveNote(Note note) async {
    final db = await database;
    final existing = await db.query('notes', where: 'song_id = ?', whereArgs: [note.songId]);
    
    if (existing.isNotEmpty) {
      return await db.update(
        'notes', 
        {
          'content': note.content,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'song_id = ?',
        whereArgs: [note.songId]
      );
    } else {
      return await db.insert('notes', note.toMap());
    }
  }
  
  Future<Note?> getNoteForSong(int songId) async {
    final db = await database;
    final maps = await db.query(
      'notes',
      where: 'song_id = ?',
      whereArgs: [songId],
    );
    if (maps.isEmpty) return null;
    return Note.fromMap(maps.first);
  }
  
  Future<List<Note>> getAllNotes() async {
    final db = await database;
    final maps = await db.query('notes', orderBy: 'updated_at DESC');
    return List.generate(maps.length, (i) => Note.fromMap(maps[i]));
  }

  /// Returns all notes joined with their song titles in one query.
  /// Each map contains all note columns plus `song_title`.
  Future<List<Map<String, dynamic>>> getNotesWithSongs() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT n.id, n.song_id, n.content, n.created_at, n.updated_at,
             s.title AS song_title
      FROM notes n
      INNER JOIN songs s ON n.song_id = s.id
      ORDER BY n.updated_at DESC
    ''');
  }

  Future<void> deleteNote(int songId) async {
     final db = await database;
     await db.delete('notes', where: 'song_id = ?', whereArgs: [songId]);
  }

  // --- Query Methods ---

  Future<List<Song>> getAllSongs() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'songs',
      orderBy: 'title',
    );
    return List.generate(maps.length, (i) => Song.fromMap(maps[i]));
  }

  Future<Song?> getSongById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'songs',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Song.fromMap(maps.first);
  }

  Future<List<Song>> getSongsPaginated({
    int page = 0,
    int pageSize = 20,
  }) async {
    try {
      final db = await database;
      final offset = page * pageSize;
      final List<Map<String, dynamic>> maps = await db.query(
        'songs',
        orderBy: 'title',
        limit: pageSize,
        offset: offset,
      );
      AppLogger.info('Retrieved ${maps.length} songs (page $page, pageSize $pageSize)');
      return List.generate(maps.length, (i) => Song.fromMap(maps[i]));
    } catch (e, stackTrace) {
      AppLogger.error('Error fetching paginated songs: $e', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<int> getSongsCount() async {
    try {
      final db = await database;
      final result = await db.rawQuery('SELECT COUNT(*) as count FROM songs');
      final count = Sqflite.firstIntValue(result) ?? 0;
      AppLogger.info('Total songs in database: $count');
      return count;
    } catch (e, stackTrace) {
      AppLogger.error('Error getting songs count: $e', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<List<Song>> searchSongs(String query) async {
    final filter = SearchFilter(query: query);
    return searchSongsWithFilter(filter);
  }

  Future<List<Song>> searchSongsWithFilter(SearchFilter filter) async {
    final db = await database;

    if (filter.query.isEmpty) {
      return [];
    }

    // Validate and sanitize search query
    final sanitizedQuery = _sanitizeSearchQuery(filter.query);

    if (sanitizedQuery.isEmpty) {
      return [];
    }

    // Build dynamic WHERE clause based on filter flags
    final List<String> conditions = [];
    final List<dynamic> args = [];
    final exactQuery = sanitizedQuery;

    // Generate variations for Tamil spelling tolerance (e.g. ன vs ந)
    final variations = _getTamilVariations(sanitizedQuery);

    void addLikeConditions(String tamilField, [String? englishField]) {
      if (variations.isEmpty) return;
      final fieldConditions = <String>[];
      for (var _ in variations) {
        fieldConditions.add('$tamilField LIKE ?');
      }
      args.addAll(variations.map((v) => '%$v%'));

      if (englishField != null) {
        fieldConditions.add('$englishField LIKE ?');
        args.add('%$sanitizedQuery%');
      }
      conditions.add('(${fieldConditions.join(' OR ')})');
    }

    if (filter.searchTitle) {
      addLikeConditions('title', 'english_title');
    }

    // For lyrics, we also check 'words' as it often contains the segmented words useful for search
    if (filter.searchLyrics) {
      addLikeConditions('lyrics', 'english_lyrics_list');
      addLikeConditions('words', 'english_words');
    }

    if (filter.searchPlace) {
      addLikeConditions('place', 'english_venue');
    }

    if (filter.searchTune) {
      addLikeConditions('tune'); // no English tune search
    }

    if (filter.searchKaumaramId) {
      // Exact match for Kaumaram ID as requested
      conditions.add('kaumaram_id = ?');
      args.add(exactQuery);
    }

    if (filter.searchPathavurai) {
      addLikeConditions('pathavurai', 'english_pathavurai');
    }

    // If no specific filter is selected, fallback... (handled by returning empty above if conditions empty)
    
    if (conditions.isEmpty) {
      return []; 
    }

    final whereClause = conditions.join(' OR ');

    // AppLogger.info('Searching with Clause: $whereClause'); 
    // AppLogger.info('Args: $args');

    final List<Map<String, dynamic>> results = await db.rawQuery('''
      SELECT * FROM songs
      WHERE $whereClause
      ORDER BY title
      LIMIT 50
    ''', args);

    return results.map((songMap) => Song.fromMap(songMap)).toList();
  }

  /// Generates variations for common Tamil spelling differences.
  /// Currently handles:
  /// - ன (U+0BA9) <-> ந (U+0BA8)
  List<String> _getTamilVariations(String query) {
    final Set<String> variations = {query};
    
    // Handle ன (Nna - Alveolar) vs ந (Na - Dental) mismatch
    // These are often confused in spelling (e.g., Palani: பழனி vs பழநி)
    if (query.contains('ன')) {
      variations.add(query.replaceAll('ன', 'ந'));
    }
    if (query.contains('ந')) {
      variations.add(query.replaceAll('ந', 'ன'));
    }
    
    // We could add more here (ra/Ra, la/La/zha) if needed later.
    
    return variations.toList();
  }

  /// Trims and length-limits the search query.
  /// SQL injection is prevented by parameterised queries (whereArgs),
  /// not by character removal.
  String _sanitizeSearchQuery(String query) {
    final trimmed = query.trim();
    if (trimmed.length > AppConstants.maxSearchQueryLength) {
      return trimmed.substring(0, AppConstants.maxSearchQueryLength);
    }
    return trimmed;
  }

  Future<List<Category>> getCategoriesWithSongCounts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT c.id, c.name, 
        CASE 
          WHEN c.id = 1 THEN (SELECT COUNT(*) FROM songs WHERE is_favorite = 1)
          ELSE COUNT(sc.song_id)
        END AS song_count
      FROM categories c
      LEFT JOIN song_categories sc ON c.id = sc.category_id
      GROUP BY c.id, c.name ORDER BY c.id
    ''');
    return List.generate(maps.length, (i) => Category.fromMap(maps[i]));
  }

  Future<int> createCategory(String name) async {
    final db = await database;
    return await db.insert('categories', {
      'name': name,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<int> updateCategory(int id, String name) async {
    final db = await database;
    return await db.update(
      'categories',
      {'name': name},
      where: 'id = ?',
      whereArgs: [id],
      conflictAlgorithm: ConflictAlgorithm.fail,
    );
  }

  Future<void> deleteCategory(int id) async {
    final db = await database;
    await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> addSongToCategory(int songId, int categoryId) async {
    final db = await database;
    await db.insert('song_categories', {
      'song_id': songId,
      'category_id': categoryId,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<void> removeSongFromCategory(int songId, int categoryId) async {
    final db = await database;
    await db.delete(
      'song_categories',
      where: 'song_id = ? AND category_id = ?',
      whereArgs: [songId, categoryId],
    );
  }

  Future<List<int>> getCategoryIdsForSong(int songId) async {
    final db = await database;
    final maps = await db.query(
      'song_categories',
      columns: ['category_id'],
      where: 'song_id = ?',
      whereArgs: [songId],
    );
    return maps.map((map) => map['category_id'] as int).toList();
  }

  Future<List<Map<String, dynamic>>> getAllSongCategories() async {
    final db = await database;
    return await db.query('song_categories');
  }

  Future<Category?> getCategoryByName(String name) async {
    final db = await database;
    final maps = await db.query(
      'categories',
      where: 'name = ?',
      whereArgs: [name],
    );
    if (maps.isEmpty) return null;
    return Category.fromMap(maps.first);
  }

  Future<List<Song>> getSongsByCategoryId(int categoryId) async {
    final db = await database;
    
    if (categoryId == 1) {
      final List<Map<String, dynamic>> maps = await db.query(
        'songs',
        where: 'is_favorite = ?',
        whereArgs: [1],
        orderBy: 'title',
      );
      return List.generate(maps.length, (i) => Song.fromMap(maps[i]));
    }
    
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT s.* FROM songs s
      INNER JOIN song_categories sc ON s.id = sc.song_id
      WHERE sc.category_id = ? ORDER BY s.title
    ''',
      [categoryId],
    );
    return List.generate(maps.length, (i) => Song.fromMap(maps[i]));
  }

  Future<List<Song>> getFavoriteSongs() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'songs',
      where: 'is_favorite = ?',
      whereArgs: [1],
      orderBy: 'title',
    );
    return List.generate(maps.length, (i) => Song.fromMap(maps[i]));
  }

  // --- Temples Methods ---

  Future<List<Map<String, dynamic>>> getAllTemples() async {
    final db = await database;
    return await db.query('temples', orderBy: 'name');
  }

  Future<List<Song>> getSongsByTemple(String templeName) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'songs',
      where: 'place = ?',
      whereArgs: [templeName],
      orderBy: 'title',
    );
    return List.generate(maps.length, (i) => Song.fromMap(maps[i]));
  }

  Future<void> toggleFavorite(int songId, bool isFavorite) async {
    final db = await database;
    await db.update(
      'songs',
      {'is_favorite': isFavorite ? 1 : 0},
      where: 'id = ?',
      whereArgs: [songId],
    );
  }
}
