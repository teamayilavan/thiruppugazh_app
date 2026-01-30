import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/song_model.dart';
import '../models/category_model.dart';
import '../models/search_filter.dart';
import '../../utils/app_logger.dart';

/// A singleton class to manage the SQLite database connection and queries.
class DatabaseHelper {
  // Singleton pattern setup
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;
  static const String _dbName = "thiruppugazh.db";
  static const int _dbVersion = 3;
  static bool _fts5Available = false;

  /// Returns the singleton database instance, initializing it if necessary.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initializes the database with version checking to preserve user data.
  /// Only copies the database from assets if version changes or doesn't exist.
  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    String path = join(databasesPath, _dbName);
    AppLogger.info('Database path: $path');

    // 1. Check if database exists
    final exists = await databaseExists(path);
    AppLogger.info('Database exists: $exists');

    if (!exists) {
      // Database doesn't exist, copy from assets
      AppLogger.info('Database does not exist, copying from assets');
      await _copyDatabaseFromAssets(path);
    } else {
      // Database exists, check version
      final db = await openDatabase(path);
      final currentVersion = await db.getVersion();
      await db.close();
      AppLogger.info('Current database version: $currentVersion, expected version: $_dbVersion');

      if (currentVersion < _dbVersion) {
        // Version mismatch, perform migration
        AppLogger.info('Database version mismatch, migrating...');
        await _migrateDatabase(path, currentVersion);
      }
    }

    // 2. Open the database with version
    AppLogger.info('Opening database...');
    final db = await openDatabase(path, version: _dbVersion, onUpgrade: _onUpgrade);

    // Verify database has songs
    final songsCount = await db.rawQuery('SELECT COUNT(*) as count FROM songs');
    final totalSongs = Sqflite.firstIntValue(songsCount) ?? 0;
    AppLogger.info('Total songs in database after initialization: $totalSongs');

    return db;
  }

  /// Copies the database from assets to the device storage using streaming.
  /// This prevents out-of-memory errors on low-end devices.
  Future<void> _copyDatabaseFromAssets(String path) async {
    try {
      await Directory(dirname(path)).create(recursive: true);
      
      final assetPath = join('assets', _dbName);
      AppLogger.info('Starting database copy from assets');
      
      final Stopwatch stopwatch = Stopwatch()..start();
      
      final ByteData data = await rootBundle.load(assetPath);
      final Uint8List bytes = data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      );
      
      final fileSize = bytes.lengthInBytes;
      AppLogger.debug('Database size: ${(fileSize / 1024).toStringAsFixed(2)} KB');
      
      final file = File(path);
      
      final raf = await file.open(mode: FileMode.write);
      const chunkSize = 8192;
      int bytesWritten = 0;
      
      for (int i = 0; i < bytes.length; i += chunkSize) {
        final end = (i + chunkSize < bytes.length) ? i + chunkSize : bytes.length;
        final chunk = bytes.sublist(i, end);
        await raf.writeFrom(chunk);
        bytesWritten += chunk.length;
        
        if (bytesWritten % (1024 * 100) == 0) {
          final progress = (bytesWritten / fileSize * 100).toStringAsFixed(1);
          AppLogger.debug('Database copy progress: $progress%');
        }
      }
      
      await raf.close();
      
      stopwatch.stop();
      AppLogger.info('Database copied successfully in ${stopwatch.elapsedMilliseconds}ms');
    } catch (e) {
      AppLogger.error('Failed to copy database from assets: $e');
      throw Exception('Failed to copy database from assets: $e');
    }
  }

  /// Migrates the database when version changes.
  Future<void> _migrateDatabase(String path, int oldVersion) async {
    // Backup existing user data
    final db = await openDatabase(path);

    // Store user-created categories and their song associations
    final userCategories = await db.query(
      'categories',
      where: 'id > 1',
    );

    final songCategories = await db.query('song_categories');

    await db.close();

    // Copy new database from assets
    await _copyDatabaseFromAssets(path);

    // Restore user data
    final newDb = await openDatabase(path);

    // Restore categories
    for (final category in userCategories) {
      await newDb.insert('categories', category);
    }

    // Restore song-category associations
    for (final sc in songCategories) {
      await newDb.insert('song_categories', sc);
    }

    await newDb.close();
  }

  /// Handles database upgrades.
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle version 1 to 2 migration - Add is_favorite column
    if (oldVersion < 2) {
      await _migrateV1ToV2(db);
    }

    // Handle version 2 to 3 migration - Extend FTS with metadata
    if (oldVersion < 3) {
      await _migrateV2ToV3(db);
    }
  }

  /// Migrates from version 1 to 2: Add is_favorite column to songs table.
  Future<void> _migrateV1ToV2(Database db) async {
    try {
      // Add is_favorite column to songs table
      await db.execute('ALTER TABLE songs ADD COLUMN is_favorite INTEGER DEFAULT 0');

      // Migrate existing favorites from song_categories table
      // Get all songs that are in favorites category (category_id = 1)
      final favoriteSongs = await db.rawQuery('''
        SELECT DISTINCT song_id
        FROM song_categories
        WHERE category_id = 1
      ''');

      // Update is_favorite for these songs
      await db.transaction((txn) async {
        for (final song in favoriteSongs) {
          await txn.update(
            'songs',
            {'is_favorite': 1},
            where: 'id = ?',
            whereArgs: [song['song_id']],
          );
        }
      });

      AppLogger.info('Migrated ${favoriteSongs.length} favorite songs to is_favorite column');
    } catch (e) {
      AppLogger.error('Failed to migrate to v2: $e');
      // Continue even if migration fails, column may already exist
    }
  }

  /// Migrates from version 2 to 3: No-op as we're using LIKE queries instead of FTS.
  Future<void> _migrateV2ToV3(Database db) async {
    AppLogger.info('Migration to v3: No changes needed, using LIKE queries');
  }

  /// Creates FTS (Full-Text Search) table for fast search.
  Future<void> _createFTSTable(Database db) async {
    await db.execute('''
      CREATE VIRTUAL TABLE IF NOT EXISTS songs_fts
      USING fts5(
        title,
        lyrics,
        place,
        tune,
        kaumaram_id,
        pathavurai
      )
    ''');
  }

  /// Populates FTS table with existing songs data.
  Future<void> _populateFTSTable(Database db) async {
    final songs = await db.query('songs');
    await db.transaction((txn) async {
      for (final song in songs) {
        await txn.insert('songs_fts', {
          'rowid': song['id'],
          'title': song['title'],
          'lyrics': song['lyrics'],
          'place': song['place'],
          'tune': song['tune'],
          'kaumaram_id': song['kaumaram_id'].toString(),
          'pathavurai': song['pathavurai'] ?? '',
        });
      }
    });
  }

  // --- Query Methods (No changes needed here) ---

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
    
    // Special handling for Favorites category (id = 1)
    if (categoryId == 1) {
      final List<Map<String, dynamic>> maps = await db.query(
        'songs',
        where: 'is_favorite = ?',
        whereArgs: [1],
        orderBy: 'title',
      );
      return List.generate(maps.length, (i) => Song.fromMap(maps[i]));
    }
    
    // For other categories, use the junction table
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
