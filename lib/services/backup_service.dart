import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../data/database/database_helper.dart';
import '../data/models/category_model.dart';
import '../data/models/highlight_model.dart';
import '../data/models/note_model.dart';
import '../utils/app_logger.dart';

class BackupService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  /// Exports user data (Favorites, Categories, Notes, Highlights) to a JSON file
  /// and prompts the user to share/save it.
  Future<void> exportData(BuildContext context) async {
    try {
      // 1. Fetch all data
      final favoriteSongs = await _dbHelper.getFavoriteSongs();
      final categories = await _dbHelper.getCategoriesWithSongCounts();
      final songCategories = await _dbHelper.getAllSongCategories();
      final notes = await _dbHelper.getAllNotes();
      final highlights = await _dbHelper.getAllHighlights();

      // 2. Structure data
      // Filter out 'Favorites' category (ID 1) from explicit export if handled via isFavorite flag,
      // generally ID 1 is reserved.
      final customCategories = categories.where((c) => c.id != 1).toList();
      
      final Map<String, dynamic> exportMap = {
        'version': 1,
        'exported_at': DateTime.now().toIso8601String(),
        'app_name': 'Thiruppugazh',
        'favorites': favoriteSongs.map((s) => s.id).toList(),
        'categories': customCategories.map((c) {
          final songIds = songCategories
              .where((sc) => sc['category_id'] == c.id)
              .map((sc) => sc['song_id'])
              .toList();
          return {
            'name': c.name,
            'songs': songIds,
          };
        }).toList(),
        'notes': notes.map((n) => n.toMap()).toList(),
        'highlights': highlights.map((h) => h.toMap()).toList(),
      };

      // 3. Create JSON file
      final jsonString = jsonEncode(exportMap);
      final directory = await getTemporaryDirectory();
      final dateStr = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
      final fileName = 'thiruppugazh_backup_$dateStr.json';
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(jsonString);

      // 4. Share file
      // ignore: deprecated_member_use
      final result = await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Thiruppugazh Backup',
        text: 'Backup of Thiruppugazh app data created on $dateStr',
      );

      if (result.status == ShareResultStatus.success) {
        if (context.mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Export successful')),
          );
        }
      }
      
    } catch (e, stackTrace) {
      AppLogger.error('Export failed', error: e, stackTrace: stackTrace);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: ${e.toString()}')),
        );
      }
    }
  }

  /// Imports data from a JSON file selected by the user.
  /// Merges Categories/Favorites, Overwrites Notes/Highlights.
  Future<void> importData(BuildContext context) async {
    try {
      // 1. Pick file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.single.path == null) {
        // User canceled
        return;
      }

      final file = File(result.files.single.path!);
      final content = await file.readAsString();
      final Map<String, dynamic> importMap = jsonDecode(content);

      _validateBackupMap(importMap);

      // Show progress
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (c) => const Center(child: CircularProgressIndicator()),
        );
      }

      // 2. Process Data
      
      // Favorites
      final List<dynamic> favIds = importMap['favorites'] ?? [];
      for (final id in favIds) {
        if (id is int) {
          // Check if song exists first? Database toggleFavorite updates based on ID. 
          // If ID doesn't exist, update returns 0 rows. Safe.
          await _dbHelper.toggleFavorite(id, true);
        }
      }

      // Categories
      final List<dynamic> cats = importMap['categories'] ?? [];
      for (final catMap in cats) {
        final String name = catMap['name'];
        final List<dynamic> songs = catMap['songs'] ?? [];

        // Find or Create Category
        Category? existingCat = await _dbHelper.getCategoryByName(name);
        int catId;
        if (existingCat != null && existingCat.id != null) {
          catId = existingCat.id!;
        } else {
          catId = await _dbHelper.createCategory(name);
        }

        // Add songs to category
        for (final songId in songs) {
          if (songId is int) {
             await _dbHelper.addSongToCategory(songId, catId);
          }
        }
      }

      // Notes (Overwrite)
      final List<dynamic> notesList = importMap['notes'] ?? [];
      for (final noteMap in notesList) {
        final note = Note.fromMap(noteMap);
        // saveNote handles update if exists
        await _dbHelper.saveNote(note);
      }

      // Highlights (Overwrite/Merge)
      final List<dynamic> highlightsList = importMap['highlights'] ?? [];
      for (final hlMap in highlightsList) {
        final hl = Highlight.fromMap(hlMap);
        // Remove existing for this verse to "overwrite"
        await _dbHelper.removeHighlight(hl.songId, hl.verseIndex);
        await _dbHelper.addHighlight(hl);
      }

      // Close progress dialog
      if (context.mounted) {
        Navigator.of(context).pop(); // Close dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Import completed successfully')),
        );
      }

    } catch (e, stackTrace) {
      if (context.mounted) {
        // Close progress dialog if open (can be tricky to know state, but usually fine here)
        // A better way is using a stateful widget or provider, but for this simple action:
        Navigator.of(context).maybePop();

        AppLogger.error('Import failed', error: e, stackTrace: stackTrace);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Import failed: ${e.toString()}')),
        );
      }
    }
  }

  void _validateBackupMap(Map<String, dynamic> map) {
    if (!map.containsKey('favorites') || !map.containsKey('categories')) {
      throw const FormatException('Missing required keys: favorites, categories');
    }

    final favorites = map['favorites'];
    if (favorites is! List) {
      throw const FormatException('favorites must be a list');
    }
    if (favorites.any((e) => e is! int)) {
      throw const FormatException('favorites must contain only integers');
    }
    if (favorites.length > 10000) {
      throw const FormatException('favorites list is unexpectedly large');
    }

    final categories = map['categories'];
    if (categories is! List) {
      throw const FormatException('categories must be a list');
    }
    for (final cat in categories) {
      if (cat is! Map) throw const FormatException('each category must be an object');
      if (cat['name'] is! String) throw const FormatException('category name must be a string');
      final songs = cat['songs'];
      if (songs != null) {
        if (songs is! List) throw const FormatException('category songs must be a list');
        if (songs.any((e) => e is! int)) {
          throw const FormatException('category songs must contain only integers');
        }
      }
    }

    final notes = map['notes'];
    if (notes != null && notes is! List) {
      throw const FormatException('notes must be a list');
    }

    final highlights = map['highlights'];
    if (highlights != null && highlights is! List) {
      throw const FormatException('highlights must be a list');
    }
  }
}
