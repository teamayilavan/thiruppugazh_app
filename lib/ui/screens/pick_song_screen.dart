import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_constants.dart';
import '../../data/models/link_model.dart';
import '../../data/models/search_filter.dart';
import '../../data/models/song_model.dart';
import '../../data/repositories/song_repository.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/lyrics_language_provider.dart';

/// What the picker hands back once a link has been saved.
class PickSongResult {
  const PickSongResult({required this.song, required this.added});

  final Song song;

  /// False if the song already had this link (nothing new was saved).
  final bool added;
}

/// Lets the user choose which song a shared [url] belongs to. Saves the link
/// on selection and pops with a [PickSongResult]; pops with null if the user
/// backs out.
class PickSongScreen extends StatefulWidget {
  const PickSongScreen({super.key, required this.url, this.title});

  final String url;
  final String? title;

  @override
  State<PickSongScreen> createState() => _PickSongScreenState();
}

class _PickSongScreenState extends State<PickSongScreen> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;
  List<Song> _results = [];
  bool _isLoading = false;
  bool _saving = false;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: AppConstants.searchDebounceMs),
      () => _search(query),
    );
    setState(() {});
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      if (mounted) setState(() => _results = []);
      return;
    }
    if (mounted) setState(() => _isLoading = true);
    final repo = Provider.of<SongRepository>(context, listen: false);
    final results = await repo.searchSongsWithFilter(
      SearchFilter(query: query.trim()),
    );
    if (mounted) {
      setState(() {
        _results = results;
        _isLoading = false;
      });
    }
  }

  Future<void> _choose(Song song) async {
    if (_saving) return;
    setState(() => _saving = true);
    final navigator = Navigator.of(context);
    final repo = Provider.of<SongRepository>(context, listen: false);

    final added = await repo.addLinkIfAbsent(
      SongLink(
        songId: song.id,
        url: widget.url,
        title: widget.title,
        createdAt: DateTime.now(),
      ),
    );
    navigator.pop(PickSongResult(song: song, added: added));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final lyricsLang = Provider.of<LyricsLanguageProvider>(
      context,
    ).lyricsLanguage;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.pickSongForLink)),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: ListTile(
              leading: const Icon(Icons.link),
              title: Text(
                widget.title ?? Uri.tryParse(widget.url)?.host ?? widget.url,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                widget.url,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _controller,
              onChanged: _onChanged,
              autofocus: true,
              decoration: InputDecoration(
                hintText: l10n.searchSongsHint,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                suffixIcon: _controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _controller.clear();
                          _onChanged('');
                        },
                      )
                    : null,
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _results.isEmpty
                ? Center(
                    child: Text(
                      _controller.text.trim().isEmpty
                          ? l10n.startTypingToSearch
                          : l10n.noResultsFound,
                      style: theme.textTheme.bodyLarge,
                    ),
                  )
                : ListView.builder(
                    itemCount: _results.length,
                    itemBuilder: (context, index) {
                      final song = _results[index];
                      final useEnglish =
                          lyricsLang == LyricsLanguage.english &&
                          song.hasEnglishContent;
                      final title = useEnglish
                          ? (song.englishTitle ?? song.title)
                          : song.title;
                      final place = useEnglish
                          ? (song.englishVenue ?? song.place)
                          : song.place;
                      return ListTile(
                        title: Text(title),
                        subtitle: Text(
                          place,
                          style: theme.textTheme.bodySmall,
                        ),
                        onTap: _saving ? null : () => _choose(song),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
