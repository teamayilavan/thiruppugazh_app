/// Represents search filter options for songs.
class SearchFilter {
  final String query;
  final bool searchTitle;
  final bool searchLyrics;
  final bool searchPlace;
  final bool searchTune;
  final bool searchKaumaramId;
  final bool searchPathavurai;

  const SearchFilter({
    this.query = '',
    this.searchTitle = true,
    this.searchLyrics = true,
    this.searchPlace = true,
    this.searchTune = true,
    this.searchKaumaramId = false,
    this.searchPathavurai = false,
  });

  /// Gets active fields for FTS search.
  String getSearchFields() {
    final fields = <String>[];
    
    if (searchTitle) fields.add('title');
    if (searchLyrics) fields.add('lyrics');
    if (searchPlace) fields.add('place');
    if (searchTune) fields.add('tune');
    if (searchKaumaramId) fields.add('kaumaram_id');
    if (searchPathavurai) fields.add('pathavurai');
    
    return fields.join(', ');
  }

  /// Creates a copy with updated values.
  SearchFilter copyWith({
    String? query,
    bool? searchTitle,
    bool? searchLyrics,
    bool? searchPlace,
    bool? searchTune,
    bool? searchKaumaramId,
    bool? searchPathavurai,
  }) {
    return SearchFilter(
      query: query ?? this.query,
      searchTitle: searchTitle ?? this.searchTitle,
      searchLyrics: searchLyrics ?? this.searchLyrics,
      searchPlace: searchPlace ?? this.searchPlace,
      searchTune: searchTune ?? this.searchTune,
      searchKaumaramId: searchKaumaramId ?? this.searchKaumaramId,
      searchPathavurai: searchPathavurai ?? this.searchPathavurai,
    );
  }
}
