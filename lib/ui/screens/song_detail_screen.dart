import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/models/song_model.dart';
import '../../data/models/highlight_model.dart';
import '../../data/models/note_model.dart';
import '../../data/repositories/song_repository.dart';
import '../widgets/add_to_category_dialog.dart';
import '../../constants/app_strings.dart';
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
  List<Highlight> _highlights = [];
  Note? _note;

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
        widget.song.categoryIds = categoryIds;
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
    final wasFavorite = _isFavorite || widget.song.categoryIds.contains(1);

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


  void _toggleHighlight(int verseIndex, String content) async {
    final repo = Provider.of<SongRepository>(context, listen: false);
    final existingIndex = _highlights.indexWhere((h) => h.verseIndex == verseIndex);

    if (existingIndex != -1) {
      // Remove
      await repo.removeHighlight(widget.song.id, verseIndex);
      setState(() {
        _highlights.removeAt(existingIndex);
      });
    } else {
      // Add
      final highlight = Highlight(
        songId: widget.song.id,
        verseIndex: verseIndex,
        textContent: content,
        createdAt: DateTime.now(),
      );
      await repo.addHighlight(highlight);
      setState(() {
        _highlights.add(highlight);
      });
    }
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
              if (mounted) {
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
    final deepLink = 'thiruppugazh://song/${song.id}';
    // Fallback Play Store URL (using standard ID format, replace if actual ID differs)
    final playStoreUrl = 'https://play.google.com/store/apps/details?id=com.example.thiruppugazh';

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
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
                  Text(l10n.lyrics, style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  const Divider(height: 16),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            sliver: SliverList.separated(
              itemCount: widget.song.lyricsList.length,
              itemBuilder: (context, index) {
                final paragraph = widget.song.lyricsList[index];
                if (paragraph.trim().isEmpty) return const SizedBox.shrink();
                
                return InkWell(
                  onLongPress: () => _toggleHighlight(index, paragraph),
                  child: Container(
                    decoration: BoxDecoration(
                      color: _highlights.any((h) => h.verseIndex == index)
                          ? Colors.yellow.withOpacity(0.3)
                          : null,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 2.0),
                    child: SelectableText(
                      paragraph,
                      style: const TextStyle(fontSize: 16, height: 1.2),
                      // Pass tap events through if not selecting text? 
                      // SelectableText captures gestures, so InkWell might conflict if precise.
                      // However, onLongPress on InkWell wraps the container. 
                      // SelectableText consumes long press for selection. 
                      // Alternatively, we use GestureDetector -> onDoubleTap to highlight since long press selects.
                      // Or creating a custom context menu for SelectableText is harder.
                      // Let's rely on Double Tap for highlighting to avoid conflict with text selection.
                    ),
                  ),
                );
                // Note: Double Tap is better than Long Press because SelectableText needs Long Press.
                // Switching InkWell onLongPress to onDoubleTap in next edit if needed, but trying LongPress on parent first.
              },
              separatorBuilder: (context, index) {
                // Calculate separator based on tuneList length to group lines into stanzas
                final tuneLength = widget.song.tuneList.length;
                
                // Avoid division by zero, default to simple list if no tune structure
                if (tuneLength == 0) return const SizedBox(height: 8);

                // Check if the current line (index+1) completes a stanza
                if ((index + 1) % tuneLength == 0) {
                  return const SizedBox(height: 32); // Paragraph break
                } else {
                  return const SizedBox(height: 4); // Line break (tightly spaced)
                }
              },
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
                  : Icon((_isFavorite || widget.song.categoryIds.contains(1)) ? Icons.favorite : Icons.favorite_border),
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
                    onUpdate: () {
                      setState(() {
                         _isFavorite = widget.song.categoryIds.contains(1);
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
          Text(l10n.temple, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          Text(
            widget.song.place,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 24),
          Text(l10n.tune, style: const TextStyle(fontSize: 16)),
          Text(widget.song.tune, style: const TextStyle(fontSize: 16)),
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
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                    style: const TextStyle(fontSize: 16, height: 1.5),
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
