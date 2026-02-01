// import 'dart:io';
// import 'dart:typed_data';
// import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/song_model.dart';
import '../models/category_model.dart';
import '../models/search_filter.dart';
import '../models/highlight_model.dart';
import '../models/note_model.dart';
import '../../utils/app_logger.dart';

/// A singleton class to manage the SQLite database connection and queries.
class DatabaseHelper {
  // Singleton pattern setup
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;
  static const String _dbName = "thiruppugazh.db";
  static const int _dbVersion = 5;


  /// Returns the singleton database instance, initializing it if necessary.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }


  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, version) async {
        await _createDb(db);
        if (version >= 4) {
           await _migrateV3ToV4(db);
        }
        if (version >= 5) {
           await _migrateV4ToV5(db);
        }
      },
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _createDb(Database db) async {
    await db.execute('''
      CREATE TABLE songs(
        id INTEGER PRIMARY KEY,
        title TEXT NOT NULL,
        lyrics TEXT,
        tune TEXT,
        place TEXT,
        kaumaram_id TEXT,
        words TEXT,
        meanings TEXT,
        search_content TEXT,
        is_favorite INTEGER DEFAULT 0
      )
    ''');
    
    await db.execute('''
      CREATE TABLE categories(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE
      )
    ''');

    await db.execute('''
      CREATE TABLE song_categories(
        song_id INTEGER,
        category_id INTEGER,
        PRIMARY KEY (song_id, category_id),
        FOREIGN KEY(song_id) REFERENCES songs(id) ON DELETE CASCADE,
        FOREIGN KEY(category_id) REFERENCES categories(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE temples(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        song_count INTEGER DEFAULT 0
      )
    ''');

    await db.insert('categories', {'id': 1, 'name': 'Favorites'});
  }

  Future<void> _migrateV1ToV2(Database db) async {
      try {
        await db.execute('ALTER TABLE songs ADD COLUMN is_favorite INTEGER DEFAULT 0');
      } catch (_) {}
  }
  
  Future<void> _migrateV2ToV3(Database db) async {
      // Placeholder
  }

  /// Migrates from version 3 to 4: Add highlights and notes tables.
  Future<void> _migrateV3ToV4(Database db) async {
    AppLogger.info('Migrating to v4: Creating highlights and notes tables');
    
    // Create Highlights table
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
    
    // Create Notes table
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
  }

  // ... (previous migrations)

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle version 1 to 2 migration - Add is_favorite column
    if (oldVersion < 2) {
      await _migrateV1ToV2(db);
    }

    // Handle version 2 to 3 migration - Extend FTS with metadata
    if (oldVersion < 3) {
      await _migrateV2ToV3(db);
    }
    
    // Handle version 3 to 4 migration - Add highlights and notes tables
    if (oldVersion < 4) {
      await _migrateV3ToV4(db);
    }

    // Handle version 4 to 5 migration - Add temples table and populate
    if (oldVersion < 5) {
      await _migrateV4ToV5(db);
    }
  }

  // ... (existing migrations)

  /// Migrates from version 4 to 5: Add temples table and populate it.
  Future<void> _migrateV4ToV5(Database db) async {
    AppLogger.info('Migrating to v5: Creating and populating temples table');
    
    // Create Temples table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS temples(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        song_count INTEGER DEFAULT 0
      )
    ''');

    // Populate Temples table from existing songs
    // Extract unique places and their counts
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
    AppLogger.info('Populated temples table with ${places.length} entries');
  }

  // ... (Highlights and Notes methods)

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

    // Use LIKE queries for Tamil language support
    final searchPattern = '%$sanitizedQuery%';
    final List<Map<String, dynamic>> results = await db.rawQuery('''
      SELECT * FROM songs
      WHERE title LIKE ? OR lyrics LIKE ?
      ORDER BY title
      LIMIT 50
    ''', [searchPattern, searchPattern]);

    return results.map((songMap) => Song.fromMap(songMap)).toList();
  }

  /// Sanitizes search query to prevent SQL injection and malicious input.
  String _sanitizeSearchQuery(String query) {
    // Trim whitespace
    String sanitized = query.trim();
    
    // Limit length to 100 characters
    if (sanitized.length > 100) {
      sanitized = sanitized.substring(0, 100);
    }
    
    // Remove potentially dangerous SQL patterns using plain string replacement
    sanitized = sanitized.replaceAll("'", '');
    sanitized = sanitized.replaceAll('"', '');
    sanitized = sanitized.replaceAll(';', '');
    sanitized = sanitized.replaceAll('--', '');
    sanitized = sanitized.replaceAll('/*', '');
    sanitized = sanitized.replaceAll('*/', '');
    
    return sanitized;
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
