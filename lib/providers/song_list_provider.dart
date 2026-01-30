import 'package:flutter/foundation.dart';
import '../data/models/song_model.dart';
import '../data/repositories/song_repository.dart';
import '../constants/app_constants.dart';
import '../utils/app_logger.dart';

class SongListProvider extends ChangeNotifier {
  final SongRepository _repository;
  
  List<Song> _songs = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = AppConstants.defaultPage;
  bool _isInitialized = false;

  List<Song> get songs => _songs;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  bool get isInitialized => _isInitialized;

  SongListProvider(this._repository);

  Future<void> loadInitialSongs() async {
    if (_isLoading) return;
    
    _isLoading = true;
    _currentPage = AppConstants.defaultPage;
    _hasMore = true;
    _songs = [];
    notifyListeners();

    try {
      AppLogger.info('Loading initial songs...');
      final newSongs = await _repository.getSongsPaginated(
        page: _currentPage,
        pageSize: AppConstants.pageSize,
      );
      
      final totalCount = await _repository.getSongsCount();
      AppLogger.info('Loaded ${newSongs.length} songs, total count: $totalCount');

      _songs = newSongs;
      _hasMore = _songs.length < totalCount;
      _isInitialized = true;
    } catch (e, stackTrace) {
      AppLogger.error('Error loading initial songs: $e', error: e, stackTrace: stackTrace);
      // We might want to expose an error state here
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreSongs() async {
    if (_isLoading || !_hasMore) return;

    _isLoading = true;
    notifyListeners();

    try {
      _currentPage++;
      final newSongs = await _repository.getSongsPaginated(
        page: _currentPage,
        pageSize: AppConstants.pageSize,
      );

      _songs.addAll(newSongs);
      // If we got fewer songs than requested, we've likely hit the end
      if (newSongs.length < AppConstants.pageSize) {
        _hasMore = false;
      }
    } catch (e, stackTrace) {
      AppLogger.error('Error loading more songs: $e', error: e, stackTrace: stackTrace);
      _currentPage--; // Revert page increment on failure
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshSongs() async {
    await loadInitialSongs();
  }
}
