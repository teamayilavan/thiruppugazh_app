// import 'package:flutter/foundation.dart';
import 'package:flutter/foundation.dart' hide Category;
import '../database/database_helper.dart';
import '../models/category_model.dart';
import '../models/song_model.dart';
import '../models/search_filter.dart';

/// A repository that acts as a mediator between UI and data source (DatabaseHelper).
/// It extends ChangeNotifier to notify of data changes.
class SongRepository extends ChangeNotifier {
  final dbHelper = DatabaseHelper();

  // --- Song and Meaning Methods ---

  /// Fetches all songs.
  Future<List<Song>> getAllSongs() async {
    final songs = await dbHelper.getAllSongs();
    return songs;
  }

  /// Fetches a single song by its ID.
  Future<Song?> getSongById(int id) async {
    return await dbHelper.getSongById(id);
  }

  /// Fetches songs with pagination.
  Future<List<Song>> getSongsPaginated({
    int page = 0,
    int pageSize = 20,
  }) async {
    return await dbHelper.getSongsPaginated(
      page: page,
      pageSize: pageSize,
    );
  }

  /// Gets total count of songs.
  Future<int> getSongsCount() async {
    return await dbHelper.getSongsCount();
  }

  /// Searches songs using FTS table.
  Future<List<Song>> searchSongs(String query) async {
    if (query.trim().isEmpty) return [];
    return await dbHelper.searchSongs(query);
  }

  /// Searches songs with custom filter.
  Future<List<Song>> searchSongsWithFilter(SearchFilter filter) async {
    if (filter.query.trim().isEmpty) return [];
    return await dbHelper.searchSongsWithFilter(filter);
  }

  // --- Category Management ---

  /// Fetches all categories with their respective song counts.
  Future<List<Category>> getAllCategories() async {
    final categories = await dbHelper.getCategoriesWithSongCounts();
    return categories;
  }

  /// Creates a new category and notifies listeners.
  Future<int> createCategory(String name) async {
    final result = await dbHelper.createCategory(name);
    notifyListeners(); // Notify UI that list of categories has changed.
    return result;
  }

  /// Deletes a category and notifies listeners.
  Future<void> deleteCategory(int categoryId) async {
    await dbHelper.deleteCategory(categoryId);
    notifyListeners();
  }

  // --- Song-Category Linking ---

  /// Adds a song to a specific category and notifies listeners.
  Future<void> addSongToCategory(int songId, int categoryId) async {
    await dbHelper.addSongToCategory(songId, categoryId);
    notifyListeners(); // Notify UI to update song counts, etc.
  }

  /// Removes a song from a specific category and notifies listeners.
  Future<void> removeSongFromCategory(int songId, int categoryId) async {
    await dbHelper.removeSongFromCategory(songId, categoryId);
    notifyListeners();
  }

  /// Gets all category IDs that a specific song belongs to.
  Future<List<int>> getCategoryIdsForSong(int songId) async {
    return await dbHelper.getCategoryIdsForSong(songId);
  }

  /// Fetches all songs belonging to a specific category ID.
  Future<List<Song>> getSongsByCategoryId(int categoryId) async {
    return await dbHelper.getSongsByCategoryId(categoryId);
  }

  // --- Favorites Management ---

  /// Fetches all favorite songs.
  Future<List<Song>> getFavoriteSongs() async {
    return await dbHelper.getFavoriteSongs();
  }

  /// Toggles a song's favorite status.
  Future<void> toggleFavorite(int songId, bool isFavorite) async {
    await dbHelper.toggleFavorite(songId, isFavorite);
    notifyListeners();
  }
  /// Triggers a UI update for listeners.
  void refresh() {
    notifyListeners();
  }


}
