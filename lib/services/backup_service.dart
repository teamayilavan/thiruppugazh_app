import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sqflite/sqflite.dart' show DatabaseExecutor;
import '../data/database/database_helper.dart';
import '../data/models/category_model.dart';
import '../data/models/highlight_model.dart';
import '../data/models/link_model.dart';
import '../data/models/note_model.dart';
import '../l10n/app_localizations.dart';
import '../constants/app_constants.dart';
import '../utils/app_logger.dart';
import '../utils/link_utils.dart';

/// The only backup format version this app understands. A backup written
/// by a future app version with a higher `version` would otherwise be
/// silently mis-imported (or vice versa for an older one); this makes
/// that loud instead.
const int supportedBackupVersion = 1;

/// Validates the `version` field of a parsed backup map and returns it.
/// Throws [FormatException] if it's missing or not [supportedBackupVersion].
int validateBackupVersion(Map<String, dynamic> map) {
  final version = map['version'];
  if (version is! int) {
    throw const FormatException('Backup is missing a version number');
  }
  if (version != supportedBackupVersion) {
    throw FormatException(
      'Unsupported backup version $version -- this app version only '
      'understands version $supportedBackupVersion backups',
    );
  }
  return version;
}

/// Returns the subset of [requested] that's present in [existingIds],
/// preserving order. Used to skip backup entries that reference a song no
/// longer in this install instead of letting a foreign-key violation abort
/// the whole import.
List<int> filterExistingIds(List<int> requested, Set<int> existingIds) {
  return requested.where(existingIds.contains).toList();
}

/// Returns a copy of a backed-up note/highlight row with its `id` removed,
/// so the importing database assigns a fresh autoincrement id instead of
/// reusing the source device's -- which could collide with an existing
/// local row and (inside the import transaction) roll back the whole
/// import. Everything else, including `song_id`, is preserved.
Map<String, dynamic> withoutRowId(Map<dynamic, dynamic> row) {
  return {
    for (final entry in row.entries)
      if (entry.key != 'id') entry.key as String: entry.value,
  };
}

/// Runs [parse], returning null if the row is malformed (wrong types, missing
/// fields, an unparseable date). Lets one bad row be skipped and counted
/// instead of aborting the whole import.
T? _tryParse<T>(T Function() parse) {
  try {
    return parse();
  } catch (_) {
    return null;
  }
}

/// Summary of what a call to [BackupService.applyImport] actually did,
/// so the caller can tell the user "imported 40 of 42 favorites" instead
/// of a bare "done".
class ImportResult {
  const ImportResult({
    required this.favoritesImported,
    required this.favoritesSkipped,
    required this.categoriesImported,
    required this.categorySongsImported,
    required this.categorySongsSkipped,
    required this.notesImported,
    required this.notesSkipped,
    required this.highlightsImported,
    required this.highlightsSkipped,
    this.linksImported = 0,
    this.linksSkipped = 0,
  });

  final int favoritesImported;
  final int favoritesSkipped;
  final int categoriesImported;
  final int categorySongsImported;
  final int categorySongsSkipped;
  final int notesImported;
  final int notesSkipped;
  final int highlightsImported;
  final int highlightsSkipped;
  final int linksImported;
  final int linksSkipped;

  int get totalSkipped =>
      favoritesSkipped +
      categorySongsSkipped +
      notesSkipped +
      highlightsSkipped +
      linksSkipped;
  int get totalImported =>
      favoritesImported +
      categorySongsImported +
      notesImported +
      highlightsImported +
      linksImported;
}

/// What's inside a backup file, computed after parsing but before writing
/// anything -- shown to the user in the pre-import confirmation dialog so
/// picking the wrong (or an old) file is visible before it overwrites data.
class BackupPreview {
  const BackupPreview({
    required this.favorites,
    required this.categories,
    required this.notes,
    required this.highlights,
    required this.exportedAt,
    required this.rawMap,
    this.links = 0,
  });

  final int favorites;
  final int categories;
  final int notes;
  final int highlights;
  final int links;
  final DateTime? exportedAt;
  final Map<String, dynamic> rawMap;
}

class BackupService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  /// Gathers favorites, categories, notes, highlights, and links into the backup
  /// JSON shape. Pure data-gathering, no file I/O or UI -- shared by the
  /// manual share-sheet export and the silent auto-backup writer, so both
  /// paths produce byte-identical output for the same data.
  Future<Map<String, dynamic>> buildBackupJson() async {
    final favoriteIds = await _dbHelper.getFavoriteSongIds();
    final categories = await _dbHelper.getCategoriesWithSongCounts();
    final songCategories = await _dbHelper.getAllSongCategories();
    final notes = await _dbHelper.getAllNotes();
    final highlights = await _dbHelper.getAllHighlights();
    final links = await _dbHelper.getAllLinks();

    final customCategories = categories.where((c) => c.id != 1).toList();

    return {
      'version': 1,
      'exported_at': DateTime.now().toIso8601String(),
      'app_name': 'Thiruppugazh',
      'favorites': favoriteIds,
      'categories': customCategories.map((c) {
        final songIds = songCategories
            .where((sc) => sc['category_id'] == c.id)
            .map((sc) => sc['song_id'])
            .toList();
        return {'name': c.name, 'songs': songIds};
      }).toList(),
      'notes': notes.map((n) => n.toMap()).toList(),
      'highlights': highlights.map((h) => h.toMap()).toList(),
      'links': links.map((l) => l.toMap()).toList(),
    };
  }

  /// Exports user data (Favorites, Categories, Notes, Highlights, Links) to a JSON file
  /// and prompts the user to share/save it.
  Future<void> exportData(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await deleteStaleExports();
      final exportMap = await buildBackupJson();
      final jsonString = jsonEncode(exportMap);
      final directory = await getTemporaryDirectory();
      final dateStr = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
      final fileName = '$_exportFilePrefix$dateStr.json';
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(jsonString);

      final result = await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          subject: l10n.backupShareSubject,
          text: l10n.backupShareText(dateStr),
        ),
      );

      if (result.status == ShareResultStatus.success) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.exportSuccess)));
        }
      }
    } catch (e, stackTrace) {
      AppLogger.error('Export failed', error: e, stackTrace: stackTrace);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.exportFailedGeneric)));
      }
    }
  }

  static const String _exportFilePrefix = 'thiruppugazh_backup_';

  /// Deletes backup export files left in the cache directory by earlier
  /// exports. They hold all notes and links in plain text. They can't be
  /// removed right after sharing, because the receiving app may still be
  /// reading the file, so anything older than [minAge] is swept instead --
  /// at startup and before each new export.
  Future<void> deleteStaleExports({
    Directory? directory,
    Duration minAge = const Duration(hours: 1),
  }) async {
    try {
      final dir = directory ?? await getTemporaryDirectory();
      final cutoff = DateTime.now().subtract(minAge);
      await for (final entity in dir.list(followLinks: false)) {
        if (entity is! File) continue;
        final name = entity.uri.pathSegments.last;
        if (!name.startsWith(_exportFilePrefix) || !name.endsWith('.json')) {
          continue;
        }
        if ((await entity.lastModified()).isBefore(cutoff)) {
          await entity.delete();
        }
      }
    } catch (e, stackTrace) {
      AppLogger.error(
        'Cleaning up old export files failed',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Picks a backup file, parses and validates it, and returns a preview
  /// of its contents -- or null if the user canceled or the file was
  /// invalid (in which case an error is already shown via [context]).
  Future<BackupPreview?> pickAndPreviewBackup(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final PlatformFile? picked = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      if (picked == null || picked.path == null) {
        return null;
      }

      final file = File(picked.path!);
      if (await file.length() > maxBackupFileBytes) {
        throw const FormatException('Backup file is unexpectedly large');
      }
      final content = await file.readAsString();
      final Map<String, dynamic> importMap = jsonDecode(content);
      validateBackupMap(importMap);

      final favIds = (importMap['favorites'] as List).whereType<int>();
      final cats = (importMap['categories'] as List);
      final notes = (importMap['notes'] as List?) ?? const [];
      final highlights = (importMap['highlights'] as List?) ?? const [];
      final links = (importMap['links'] as List?) ?? const [];
      final exportedAtRaw = importMap['exported_at'];

      return BackupPreview(
        favorites: favIds.length,
        categories: cats.length,
        notes: notes.length,
        highlights: highlights.length,
        links: links.length,
        exportedAt: exportedAtRaw is String
            ? DateTime.tryParse(exportedAtRaw)
            : null,
        rawMap: importMap,
      );
    } on FormatException catch (e, stackTrace) {
      AppLogger.error('Import file invalid', error: e, stackTrace: stackTrace);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.importFileInvalid)));
      }
      return null;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Import file read failed',
        error: e,
        stackTrace: stackTrace,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.importFileReadError)));
      }
      return null;
    }
  }

  /// Picks a backup file, shows the user what's in it, and -- only if they
  /// confirm -- applies it inside a transaction and reports what happened.
  Future<void> importData(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final preview = await pickAndPreviewBackup(context);
    if (preview == null) return;

    if (!context.mounted) return;
    final confirmed = await _showImportConfirmation(context, l10n, preview);
    if (confirmed != true) return;

    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (c) => const Center(child: CircularProgressIndicator()),
      );
    }

    try {
      final result = await applyImport(preview.rawMap);
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result.totalSkipped == 0
                  ? l10n.importResultSuccess
                  : l10n.importResultWithSkips(result.totalSkipped),
            ),
          ),
        );
      }
    } catch (e, stackTrace) {
      AppLogger.error('Import failed', error: e, stackTrace: stackTrace);
      if (context.mounted) {
        Navigator.of(context).maybePop();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.importFailedGeneric)));
      }
    }
  }

  Future<bool?> _showImportConfirmation(
    BuildContext context,
    AppLocalizations l10n,
    BackupPreview preview,
  ) {
    final dateStr = preview.exportedAt != null
        ? DateFormat.yMMMd().format(preview.exportedAt!)
        : l10n.importUnknownDate;
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.importConfirmationTitle),
        content: Text(
          l10n.importConfirmationDetailedMessage(
            preview.favorites,
            preview.categories,
            preview.notes,
            preview.highlights,
            preview.links,
            dateStr,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.yes),
          ),
        ],
      ),
    );
  }

  /// Applies a parsed, already-validated backup [map] to the database
  /// inside a single transaction: either it all lands, or none of it does.
  /// Entries referencing a song ID no longer in this install are skipped
  /// (and counted) rather than left to trip the songs foreign-key
  /// constraint and abort the whole import. No [BuildContext] -- this is
  /// also called by the silent auto-restore path at startup.
  Future<ImportResult> applyImport(Map<String, dynamic> map) async {
    // Every row written fires the mutation hook; pause it for the import
    // and fire it once afterwards so the auto-backup is rewritten once.
    final hook = DatabaseHelper.onMutation;
    DatabaseHelper.onMutation = null;
    try {
      return await _applyImportInTransaction(map);
    } finally {
      DatabaseHelper.onMutation = hook;
      hook?.call();
    }
  }

  Future<ImportResult> _applyImportInTransaction(
    Map<String, dynamic> map,
  ) async {
    return _dbHelper.runInTransaction((txn) async {
      final validSongIds = await _dbHelper.getAllSongIds(executor: txn);

      final List<dynamic> favIdsRaw = map['favorites'] ?? [];
      final favIds = favIdsRaw.whereType<int>().toList();
      final favIdsToApply = filterExistingIds(favIds, validSongIds);
      for (final id in favIdsToApply) {
        await _dbHelper.toggleFavorite(id, true, executor: txn);
      }

      int categoriesImported = 0;
      int categorySongsImported = 0;
      int categorySongsSkipped = 0;
      final List<dynamic> cats = map['categories'] ?? [];
      for (final catMap in cats) {
        final String name = (catMap['name'] as String).trim();
        final List<dynamic> songsRaw = catMap['songs'] ?? [];
        final songs = songsRaw.whereType<int>().toList();

        // Same length rule as creating a category in the app; a hand-edited
        // backup can't smuggle in an empty or enormous name.
        if (name.length < AppConstants.categoryMinNameLength ||
            name.length > AppConstants.categoryMaxNameLength) {
          categorySongsSkipped += songs.length;
          continue;
        }

        Category? existingCat = await _dbHelper.getCategoryByName(
          name,
          executor: txn,
        );
        int catId;
        if (existingCat != null && existingCat.id != null) {
          catId = existingCat.id!;
        } else {
          catId = await _dbHelper.createCategory(name, executor: txn);
        }
        categoriesImported++;

        final songsToApply = filterExistingIds(songs, validSongIds);
        categorySongsSkipped += songs.length - songsToApply.length;
        for (final songId in songsToApply) {
          await _dbHelper.addSongToCategory(songId, catId, executor: txn);
          categorySongsImported++;
        }
      }

      int notesImported = 0;
      int notesSkipped = 0;
      final List<dynamic> notesList = map['notes'] ?? [];
      for (final noteMap in notesList) {
        // Drop the backup's id; saveNote merges by song_id, and a fresh
        // insert gets a locally assigned id.
        final Note? note = _tryParse(() => Note.fromMap(withoutRowId(noteMap as Map)));
        if (note != null && validSongIds.contains(note.songId)) {
          await _dbHelper.saveNote(note, executor: txn);
          notesImported++;
        } else {
          notesSkipped++;
        }
      }

      int highlightsImported = 0;
      int highlightsSkipped = 0;
      final List<dynamic> highlightsList = map['highlights'] ?? [];
      for (final hlMap in highlightsList) {
        final Highlight? hl = _tryParse(() => Highlight.fromMap(withoutRowId(hlMap as Map)));
        if (hl != null && validSongIds.contains(hl.songId)) {
          await _dbHelper.removeHighlight(
            hl.songId,
            hl.verseIndex,
            executor: txn,
          );
          await _dbHelper.addHighlight(hl, executor: txn);
          highlightsImported++;
        } else {
          highlightsSkipped++;
        }
      }

      final linksResult = await importLinks(
        map['links'] ?? [],
        validSongIds,
        executor: txn,
      );

      return ImportResult(
        favoritesImported: favIdsToApply.length,
        favoritesSkipped: favIds.length - favIdsToApply.length,
        categoriesImported: categoriesImported,
        categorySongsImported: categorySongsImported,
        categorySongsSkipped: categorySongsSkipped,
        notesImported: notesImported,
        notesSkipped: notesSkipped,
        highlightsImported: highlightsImported,
        highlightsSkipped: highlightsSkipped,
        linksImported: linksResult.imported,
        linksSkipped: linksResult.skipped,
      );
    });
  }

  /// Merges the backup's `links` into the database. Malformed rows, rows for
  /// songs this install doesn't have, and rows whose URL isn't http(s) are
  /// skipped (and counted) rather than aborting the import -- the URL is
  /// re-validated because a hand-edited backup must not be able to smuggle in
  /// another scheme. A link the song already has counts as imported, not
  /// skipped, so re-importing a backup never duplicates links.
  @visibleForTesting
  Future<({int imported, int skipped})> importLinks(
    List<dynamic> linksList,
    Set<int> validSongIds, {
    required DatabaseExecutor executor,
  }) async {
    var imported = 0;
    var skipped = 0;
    for (final linkMap in linksList) {
      final SongLink? link = _tryParse(() => SongLink.fromMap(withoutRowId(linkMap as Map)));
      if (link == null ||
          !validSongIds.contains(link.songId) ||
          !LinkUtils.isValidUrl(link.url)) {
        skipped++;
        continue;
      }
      await _dbHelper.addLinkIfAbsent(link, executor: executor);
      imported++;
    }
    return (imported: imported, skipped: skipped);
  }
}

/// Largest backup file the app will read. A real backup is a few KB to a few
/// hundred KB; this only stops a wrong or hostile file from exhausting memory.
const int maxBackupFileBytes = 5 * 1024 * 1024;

/// Largest number of entries accepted in any one list of a backup.
const int maxBackupListLength = 10000;

/// Validates the structure of a parsed backup map. Throws [FormatException]
/// if it can't be imported safely. Shared by the manual import and the
/// silent auto-restore, so both apply the same checks.
void validateBackupMap(Map<String, dynamic> map) {
  validateBackupVersion(map);

  if (!map.containsKey('favorites') || !map.containsKey('categories')) {
    throw const FormatException(
      'Missing required keys: favorites, categories',
    );
  }

  final favorites = map['favorites'];
  if (favorites is! List) {
    throw const FormatException('favorites must be a list');
  }
  if (favorites.any((e) => e is! int)) {
    throw const FormatException('favorites must contain only integers');
  }
  if (favorites.length > maxBackupListLength) {
    throw const FormatException('favorites list is unexpectedly large');
  }

  final categories = map['categories'];
  if (categories is! List) {
    throw const FormatException('categories must be a list');
  }
  if (categories.length > maxBackupListLength) {
    throw const FormatException('categories list is unexpectedly large');
  }
  for (final cat in categories) {
    if (cat is! Map) {
      throw const FormatException('each category must be an object');
    }
    if (cat['name'] is! String) {
      throw const FormatException('category name must be a string');
    }
    final songs = cat['songs'];
    if (songs != null) {
      if (songs is! List) {
        throw const FormatException('category songs must be a list');
      }
      if (songs.any((e) => e is! int)) {
        throw const FormatException(
          'category songs must contain only integers',
        );
      }
    }
  }

  final notes = map['notes'];
  if (notes != null && notes is! List) {
    throw const FormatException('notes must be a list');
  }
  if (notes is List && notes.length > maxBackupListLength) {
    throw const FormatException('notes list is unexpectedly large');
  }

  final highlights = map['highlights'];
  if (highlights != null && highlights is! List) {
    throw const FormatException('highlights must be a list');
  }
  if (highlights is List && highlights.length > maxBackupListLength) {
    throw const FormatException('highlights list is unexpectedly large');
  }

  final links = map['links'];
  if (links != null && links is! List) {
    throw const FormatException('links must be a list');
  }
  if (links is List && links.length > maxBackupListLength) {
    throw const FormatException('links list is unexpectedly large');
  }
}
