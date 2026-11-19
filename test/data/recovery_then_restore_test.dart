import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:thiruppugazh/data/database/database_helper.dart';
import 'package:thiruppugazh/providers/auto_backup_status_provider.dart';
import 'package:thiruppugazh/services/auto_backup_service.dart';

/// After an unusable database is replaced, its user data is rescued into the
/// new one. The auto-backup snapshot may be older than that data, so the
/// startup restore must not overwrite what the rescue just recovered.
void main() {
  test('startup restore after a clean rescue does not overwrite newer data', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    final dir = Directory.systemTemp.createTempSync('recover_restore');
    await databaseFactoryFfi.setDatabasesPath(dir.path);

    // Unusable database (no songs) holding the user's NEWER note.
    final seed = await databaseFactoryFfi.openDatabase('${dir.path}/thiruppugazh.db');
    await seed.execute('CREATE TABLE songs(id INTEGER PRIMARY KEY, title TEXT NOT NULL, is_favorite INTEGER DEFAULT 0)');
    await seed.execute('CREATE TABLE categories(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL UNIQUE)');
    await seed.execute('CREATE TABLE song_categories(song_id INTEGER, category_id INTEGER, PRIMARY KEY(song_id, category_id))');
    await seed.execute('CREATE TABLE notes(id INTEGER PRIMARY KEY AUTOINCREMENT, song_id INTEGER NOT NULL, content TEXT NOT NULL, created_at TEXT NOT NULL, updated_at TEXT NOT NULL)');
    await seed.execute('CREATE TABLE highlights(id INTEGER PRIMARY KEY AUTOINCREMENT, song_id INTEGER NOT NULL, verse_index INTEGER NOT NULL, text_content TEXT, created_at TEXT NOT NULL)');
    await seed.execute('CREATE TABLE links(id INTEGER PRIMARY KEY AUTOINCREMENT, song_id INTEGER NOT NULL, url TEXT NOT NULL, title TEXT, created_at TEXT NOT NULL)');
    await seed.insert('categories', {'id': 1, 'name': 'Favorites'});
    await seed.insert('notes', {'song_id': 7, 'content': 'new text', 'created_at': '2026-11-01T00:00:00.000', 'updated_at': '2026-11-18T00:00:00.000'});
    await seed.insert('highlights', {'song_id': 7, 'verse_index': 1, 'text_content': 'new highlight', 'created_at': '2026-11-18T00:00:00.000'});
    await seed.execute('PRAGMA user_version = 6');
    await seed.close();

    // An OLDER auto-backup snapshot of the same song.
    final backupDir = Directory(p.join(dir.path, 'auto_backup'))..createSync();
    File(p.join(backupDir.path, 'thiruppugazh_auto_backup.json')).writeAsStringSync(jsonEncode({
      'version': 1,
      'favorites': [],
      'categories': [],
      'notes': [
        {'song_id': 7, 'content': 'old text', 'created_at': '2026-10-01T00:00:00.000', 'updated_at': '2026-10-02T00:00:00.000'},
      ],
      'highlights': [
        {'song_id': 7, 'verse_index': 1, 'text_content': 'old highlight', 'created_at': '2026-10-02T00:00:00.000'},
      ],
      'links': [],
    }));

    final helper = DatabaseHelper();
    final db = await helper.database;
    expect(helper.wasRecovered, true);
    expect((await helper.getNoteForSong(7))!.content, 'new text');

    // The same call main.dart makes at startup.
    final service = AutoBackupService(
      statusProvider: AutoBackupStatusProvider(),
      backupDirectory: backupDir,
      attemptedMarkerDirectory: dir,
    );
    await service.maybeRestore(
      isFreshDatabase: helper.wasFreshlyCreated && !helper.userDataRescued,
      databaseWasRecovered: helper.wasRecovered && !helper.userDataRescued,
    );

    expect((await helper.getNoteForSong(7))!.content, 'new text');
    expect((await helper.getHighlightsForSong(7)).single.textContent, 'new highlight');

    await db.close();
    dir.deleteSync(recursive: true);
  });
}
