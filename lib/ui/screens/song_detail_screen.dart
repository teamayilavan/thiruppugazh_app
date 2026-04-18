import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/models/song_model.dart';
import '../../data/models/highlight_model.dart';
import '../../data/models/note_model.dart';
import '../../data/repositories/song_repository.dart';
import '../widgets/add_to_category_dialog.dart';

import '../../constants/app_constants.dart';
import '../../l10n/app_localizations.dart';

class SongDetailScreen extends StatefulWidget {
  final Song song;
  const SongDetailScreen({super.key, required this.song});

  @override
  State<SongDetailScreen> createState() => _SongDetailScreenState();
}

class _SongDetailScreenState extends State<SongDetailScreen> {
  bool _isFavorite = false;
  bool _isFavoriteLoading = false;
  List<int> _categoryIds = [];
  List<Highlight> _highlights = [];
  Note? _note;
  final List<VerseRange> _verseRanges = [];


  @override
  void initState() {
    super.initState();
    final repo = Provider.of<SongRepository>(context, listen: false);
    _loadCategoryInfo(repo);
  }

  void _loadCategoryInfo(SongRepository repo) async {
    final categoryIds = await repo.getCategoryIdsForSong(widget.song.id);
    final highlights = await repo.getHighlightsForSong(widget.song.id);
    final note = await repo.getNoteForSong(widget.song.id);

    if (mounted) {
      setState(() {
        _categoryIds = categoryIds;
        _isFavorite = widget.song.isFavorite;
        _highlights = highlights;
        _note = note;
      });
    }
  }

  void _toggleFavorite() async {
    if (_isFavoriteLoading) return;

    final repo = Provider.of<SongRepository>(context, listen: false);
    final messenger = ScaffoldMessenger.of(context);
    final wasFavorite = _isFavorite || _categoryIds.contains(1);

    setState(() {
      _isFavoriteLoading = true;
    });

    try {
      await repo.toggleFavorite(widget.song.id, !wasFavorite);

      if (!mounted) return;

      setState(() {
        _isFavorite = !wasFavorite;
        _isFavoriteLoading = false;
      });

      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Song ${widget.song.title} ${wasFavorite ? 'removed from Favorites' : 'added to Favorites'}',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isFavoriteLoading = false;
      });
      messenger.showSnackBar(
        SnackBar(
          content: Text('Error updating favorite: $e'),
        ),
      );
    }
    }


  void _toggleHighlights(List<int> indices) async {
    final repo = Provider.of<SongRepository>(context, listen: false);
    
    // Check if all selected verses are already highlighted
    final allHighlighted = indices.every((i) => _highlights.any((h) => h.verseIndex == i));
    
    if (allHighlighted) {
      // Remove highlights
      for (final index in indices) {
        await repo.removeHighlight(widget.song.id, index);
      }
      if (mounted) {
        setState(() {
          _highlights.removeWhere((h) => indices.contains(h.verseIndex));
        });
      }
    } else {
      // Add highlights
      final newHighlights = <Highlight>[];
      for (final index in indices) {
        if (!_highlights.any((h) => h.verseIndex == index)) {
          final content = widget.song.lyricsList[index];
          final highlight = Highlight(
            songId: widget.song.id,
            verseIndex: index,
            textContent: content,
            createdAt: DateTime.now(),
          );
          await repo.addHighlight(highlight);
          newHighlights.add(highlight);
        }
      }
      if (mounted) {
        setState(() {
          _highlights.addAll(newHighlights);
        });
      }
    }
  }

  List<InlineSpan> _buildLyricsTextSpans(BuildContext context) {
    _verseRanges.clear();
    final spans = <InlineSpan>[];
    int currentIndex = 0;
    final tuneLength = widget.song.tuneList.length;

    for (int i = 0; i < widget.song.lyricsList.length; i++) {
        final paragraph = widget.song.lyricsList[i];
        if (paragraph.trim().isEmpty) continue;

        // Determine style
        final isHighlighted = _highlights.any((h) => h.verseIndex == i);
        // Using a light yellow background for highlighted text
        final bgColor = isHighlighted ? Colors.yellow.withValues(alpha: 0.3) : null;
        
        final style = Theme.of(context).textTheme.bodyLarge?.copyWith(
            height: 1.5,
            backgroundColor: bgColor,
            color: Theme.of(context).colorScheme.onSurface,
        );

        final span = TextSpan(text: paragraph, style: style);
        spans.add(span);
        
        final start = currentIndex;
        final end = currentIndex + paragraph.length;
        _verseRanges.add(VerseRange(start: start, end: end, index: i));
        currentIndex += paragraph.length;

        // Add separator
        if (tuneLength > 0 && (i + 1) % tuneLength == 0) {
             const sep = '\n\n';
             spans.add(const TextSpan(text: sep));
             currentIndex += sep.length;
        } else {
             const sep = '\n';
             spans.add(const TextSpan(text: sep));
             currentIndex += sep.length;
        }
    }
    return spans;
  }

  void _showNoteDialog() {
    final TextEditingController noteController = 
        TextEditingController(text: _note?.content ?? '');
        
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
          title: Text(AppLocalizations.of(context)!.songNote),
          content: SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            width: double.maxFinite,
            child: TextField(
              controller: noteController,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.enterThoughts,
                border: const OutlineInputBorder(),
              ),
            ),
          ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          FilledButton(
            onPressed: () async {
              final content = noteController.text.trim();
              final repo = Provider.of<SongRepository>(context, listen: false);
              
              if (content.isEmpty) {
                if (_note != null) {
                  await repo.deleteNote(widget.song.id);
                }
              } else {
                final note = Note(
                  songId: widget.song.id,
                  content: content,
                  createdAt: _note?.createdAt ?? DateTime.now(),
                  updatedAt: DateTime.now(),
                );
                await repo.saveNote(note);
              }
              
              // Reload note
              final updatedNote = await repo.getNoteForSong(widget.song.id);
              if (context.mounted) {
                setState(() {
                  _note = updatedNote;
                });
                Navigator.pop(context);
              }
            },
            child: Text(AppLocalizations.of(context)!.save),
          ),
        ],
      ),
    );
  }



  void _shareSongText() {
    final song = widget.song;

    final l10n = AppLocalizations.of(context)!;
    final textToShare =
        '''
      ${l10n.title}: 
      ${song.title} 
 
      ${l10n.temple}:
      ${song.place}
 
      ${l10n.tune}: 
      ${song.tune}
 
      ${l10n.lyrics}:
      ${song.lyrics}
      ''';

    SharePlus.instance.share(
      ShareParams(title: '${l10n.lyrics}: ${song.title}', text: textToShare),
    );
  }

  void _shareSongLink() {
    final song = widget.song;
    final l10n = AppLocalizations.of(context)!;
    
    // Custom scheme URI that MainWrapper detects
    // Updated to use https domain for App Links / Universal Links
    final deepLink = 'https://${AppConstants.deepLinkDomain}/song/${song.id}';
    // Fallback Play Store URL (using standard ID format, replace if actual ID differs)
    final playStoreUrl = 'https://play.google.com/store/apps/details?id=org.ayilavan.thiruppugazh';

    final textToShare = 
        '${l10n.checkOutSong(song.title)}\n\n'
        '${l10n.tapToOpenInApp}\n$deepLink\n\n'
        '${l10n.getTheAppHere}\n$playStoreUrl';

    SharePlus.instance.share(
      ShareParams(title: l10n.checkOutSong(song.title), text: textToShare),
    );
  }

  void _launchYouTubeSearch() async {
    final messenger = ScaffoldMessenger.of(context);

    final songTitle = Uri.encodeComponent(widget.song.title);
    final url = Uri.parse(
      'https://www.youtube.com/results?search_query=திருப்புகழ்%20$songTitle',
    );

    if (!_isValidUrl(url, ['youtube.com', 'www.youtube.com'])) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Invalid URL')),
      );
      return;
    }

    final confirmed = await _showUrlConfirmationDialog(context, 'YouTube');
    if (confirmed == true) {
      if (!await launchUrl(url)) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('Could not launch YouTube for ${widget.song.title}'),
          ),
        );
      }
    }
  }

  void _launchGoogleSearch() async {
    final messenger = ScaffoldMessenger.of(context);

    final songTitle = Uri.encodeComponent(widget.song.title);
    final url = Uri.parse(
      'https://www.google.com/search?q=திருப்புகழ்%20$songTitle',
    );

    if (!_isValidUrl(url, ['google.com', 'www.google.com'])) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Invalid URL')),
      );
      return;
    }

    final confirmed = await _showUrlConfirmationDialog(context, 'Google');
    if (confirmed == true) {
      if (!await launchUrl(url)) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('Could not launch Google for ${widget.song.title}'),
          ),
        );
      }
    }
  }

  void _launchCustomUrl() async {
    final messenger = ScaffoldMessenger.of(context);

    final kaumaramId = widget.song.kaumaramId.padLeft(4, '0');
    final url = Uri.parse(
      'https://kaumaram.com/thiru/nnt${kaumaramId}_u.html',
    );

    if (!_isValidUrl(url, ['kaumaram.com', 'www.kaumaram.com'])) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Invalid URL')),
      );
      return;
    }

    final confirmed = await _showUrlConfirmationDialog(context, 'Kaumaram');
    if (confirmed == true) {
      if (!await launchUrl(url)) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Could not launch the custom URL')),
        );
      }
    }
  }

  /// Validates URL against whitelist of trusted domains.
  bool _isValidUrl(Uri url, List<String> allowedDomains) {
    if (url.scheme != 'https') {
      return false;
    }
    
    if (!allowedDomains.contains(url.host)) {
      return false;
    }
    
    return true;
  }

  /// Shows a confirmation dialog before launching external URLs.
  Future<bool?> _showUrlConfirmationDialog(BuildContext context, String domain) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.openExternalLink),
          content: Text(AppLocalizations.of(context)!.openExternalLinkConfirmation(domain)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(AppLocalizations.of(context)!.open),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final buttonStyle = FilledButton.styleFrom(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
    );
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 32),
                Text(
                  widget.song.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                _buildInfoCard(context),
                const SizedBox(height: 32),
              ],
            ),
          ),
          
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.lyrics, style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 8),
                  const Divider(height: 16),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SelectableText.rich(
                TextSpan(
                  children: _buildLyricsTextSpans(context),
                ),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5, color: Colors.black),
                contextMenuBuilder: (context, editableTextState) {
                  return AdaptiveTextSelectionToolbar.buttonItems(
                    anchors: editableTextState.contextMenuAnchors,
                    buttonItems: [
                      ...editableTextState.contextMenuButtonItems
                          .where((item) => item.type == ContextMenuButtonType.copy),
                      ContextMenuButtonItem(
                        onPressed: () {
                          final selection = editableTextState.textEditingValue.selection;
                          if (!selection.isValid) {
                             editableTextState.hideToolbar();
                             return;
                          }
                          
                          // Find affected verses
                          final start = selection.start;
                          final end = selection.end;
                          final affectedIndices = <int>[];
                          
                          for (final range in _verseRanges) {
                            // Check for intersection
                            if (range.start < end && range.end > start) {
                              affectedIndices.add(range.index);
                            }
                          }

                          editableTextState.hideToolbar();
                          if (affectedIndices.isNotEmpty) {
                            _toggleHighlights(affectedIndices);
                          }
                        },
                        label: AppLocalizations.of(context)!.highlight,
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32.0),
               child: _buildMeaningsCard(
                l10n.meaning,
                widget.song.words,
                widget.song.meanings,
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FilledButton.tonalIcon(
                    style: buttonStyle,
                    icon: Icon(_note != null ? Icons.note : Icons.note_add_outlined),
                    label: Text(l10n.songNote),
                    onPressed: _showNoteDialog,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.tonalIcon(
                          style: buttonStyle,
                          icon: const Icon(Icons.share_outlined),
                          label: Text(l10n.shareText),
                          onPressed: _shareSongText,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: FilledButton.tonalIcon(
                          style: buttonStyle,
                          icon: const Icon(Icons.install_mobile),
                          label: Text(l10n.shareLink),
                          onPressed: _shareSongLink,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  FilledButton.tonalIcon(
                    style: buttonStyle,
                    icon: const Icon(Icons.language),
                    label: Text(l10n.openKaumaramPage),
                    onPressed: _launchCustomUrl,
                  ),
                  const SizedBox(height: 12),
                  FilledButton.tonalIcon(
                    style: buttonStyle,
                    icon: const Icon(Icons.smart_display),
                    label: Text(l10n.searchOnYouTube),
                    onPressed: _launchYouTubeSearch,
                  ),
                  const SizedBox(height: 12),
                  FilledButton.tonalIcon(
                    style: buttonStyle,
                    icon: const Icon(Icons.search),
                    label: Text(l10n.searchInGoogle),
                    onPressed: _launchGoogleSearch,
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Semantics(
            button: true,
            label: _isFavorite ? l10n.removeFromFavorites : l10n.addToFavorites,
            hint: _isFavoriteLoading ? l10n.loading : l10n.tapToToggleFavorite,
            child: FloatingActionButton(
              heroTag: 'fab_favorite',
              onPressed: _isFavoriteLoading ? null : _toggleFavorite,
              child: _isFavoriteLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Icon((_isFavorite || _categoryIds.contains(1)) ? Icons.favorite : Icons.favorite_border),
            ),
          ),
          const SizedBox(height: 16),
          Semantics(
            button: true,
            label: l10n.addToCategories,
            hint: l10n.tapToAddCategories,
            child: FloatingActionButton(
              heroTag: 'fab_add_category',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AddToCategoryDialog(
                    song: widget.song,
                    currentCategoryIds: _categoryIds,
                    onCategoryIdsChanged: (updatedIds) {
                      setState(() {
                        _categoryIds = updatedIds;
                        _isFavorite = updatedIds.contains(1);
                      });
                    },
                  ),
                );
              },
              child: const Icon(Icons.playlist_add),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.temple, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 8),
          Text(
            widget.song.place,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 24),
          Text(l10n.tune, style: Theme.of(context).textTheme.bodyLarge),
          Text(widget.song.tune, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }

  Widget _buildMeaningsCard(
    String title,
    List<String> words,
    List<String> meanings,
  ) {
    // Assert that both lists have the same length.
    // This helps catch errors during development.
    assert(
      words.length == meanings.length,
      'The words and meanings lists must have the same length.',
    );

    if (words.isEmpty || meanings.isEmpty) return const SizedBox.shrink();

    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Divider(height: 16),
          const SizedBox(height: 16),
          ...List.generate(meanings.length, (index) {
            final word = index < words.length ? words[index] : '';
            final meaning = meanings[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (word.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: SelectableText(
                        word,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  SelectableText(
                    meaning,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class VerseRange {
  final int start;
  final int end;
  final int index;

  VerseRange({required this.start, required this.end, required this.index});
}
