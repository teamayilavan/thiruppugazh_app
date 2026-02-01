import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/song_model.dart';
import '../../data/models/search_filter.dart';
import '../../data/repositories/song_repository.dart';
import 'song_detail_screen.dart';
import '../../../constants/app_strings.dart';
import '../../../constants/app_constants.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  List<Song> _results = [];
  bool _isLoading = false;
  Timer? _debounce;
  SearchFilter _filter = const SearchFilter();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: AppConstants.searchDebounceMs), () {
      if (mounted) {
        _performSearch(query);
      }
    });
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      if (mounted) setState(() => _results = []);
      return;
    }

    if (mounted) setState(() => _isLoading = true);

    final repo = Provider.of<SongRepository>(context, listen: false);
    final updatedFilter = _filter.copyWith(query: query.trim());
    final results = await repo.searchSongsWithFilter(updatedFilter);

    if (mounted) {
      setState(() {
        _results = results;
        _isLoading = false;
        _filter = updatedFilter;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _searchFocusNode.unfocus();
      },
      child: Scaffold(
        appBar: AppBar(title: const Text(AppStrings.globalSearch)),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                onChanged: _onSearchChanged,
                autofocus: false,
                decoration: InputDecoration(
                  hintText: AppStrings.searchByTitleOrLyrics,
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _performSearch('');
                          },
                        )
                      : null,
                ),
              ),
            ),

            SearchFilterOptions(
              filter: _filter,
              onFilterChanged: (newFilter) {
                _filter = newFilter;
                _performSearch(_filter.query);
              },
            ),

            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _results.isEmpty
                  ? Center(
                      child: Text(
                        _searchController.text.trim().isEmpty
                            ? AppStrings.startTypingToSearch
                            : AppStrings.noResultsFound,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    )
                  : Scrollbar(
                      controller: _scrollController,
                      thumbVisibility: true,
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: _results.length,
                        itemBuilder: (context, index) {
                          final song = _results[index];
                          return ListTile(
                            leading: Text(
                              (index + 1).toString(),
                              style: const TextStyle(fontSize: 16),
                            ),
                            title: Text(song.title),
                            subtitle: Text(
                              song.place,
                              style: const TextStyle(fontSize: 12),
                            ),
                            onTap: () {
                              _searchFocusNode.unfocus();
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      SongDetailScreen(song: song),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class SearchFilterOptions extends StatelessWidget {
  final SearchFilter filter;
  final ValueChanged<SearchFilter> onFilterChanged;

  const SearchFilterOptions({
    super.key,
    required this.filter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: Wrap(
        spacing: 8.0,
        runSpacing: 8.0,
        children: [
          FilterChip(
            label: const Text('Title'),
            selected: filter.searchTitle,
            onSelected: (_) {
              onFilterChanged(filter.copyWith(searchTitle: !filter.searchTitle));
            },
          ),
          FilterChip(
            label: const Text('Lyrics'),
            selected: filter.searchLyrics,
            onSelected: (_) {
              onFilterChanged(filter.copyWith(searchLyrics: !filter.searchLyrics));
            },
          ),
          FilterChip(
            label: const Text('Temple'),
            selected: filter.searchPlace,
            onSelected: (_) {
              onFilterChanged(filter.copyWith(searchPlace: !filter.searchPlace));
            },
          ),
          FilterChip(
            label: const Text('Kaumaram ID'),
            selected: filter.searchKaumaramId,
            onSelected: (_) {
              onFilterChanged(
                filter.copyWith(searchKaumaramId: !filter.searchKaumaramId),
              );
            },
          ),
        ],
      ),
    );
  }
}
