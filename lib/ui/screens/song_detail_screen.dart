import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/models/song_model.dart';
import '../../data/models/highlight_model.dart';
import '../../data/models/note_model.dart';
import '../../data/models/link_model.dart';
import '../../data/repositories/song_repository.dart';
import '../widgets/add_to_category_dialog.dart';
import '../widgets/add_link_sheet.dart';
import '../widgets/link_actions.dart';
import '../widgets/song_sections.dart';
import '../widgets/song_web_links.dart';

import '../../constants/app_constants.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/app_logger.dart';
import '../../providers/lyrics_language_provider.dart';
import '../../providers/lyrics_font_size_provider.dart';
import '../../providers/reading_state_provider.dart';
import 'chanting_screen.dart';

List<String> selectMayuragiriLyrics(Song song, bool useEnglish) {
  return useEnglish
      ? song.mayuragiriEnglishLyricsSeparatedList
      : song.mayuragiriLyricsSeparatedList;
}

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
  List<SongLink> _links = [];
  final List<VerseRange> _verseRanges = [];
  LyricsLanguage _lyricsLanguage = LyricsLanguage.tamil;

  bool get _useEnglish =>
      _lyricsLanguage == LyricsLanguage.english &&
      widget.song.hasEnglishContent;

  String get _displayTitle => _useEnglish
      ? (widget.song.englishTitle ?? widget.song.title)
      : widget.song.title;

  String get _displayPlace => _useEnglish
      ? (widget.song.englishVenue ?? widget.song.place)
      : widget.song.place;

  String get _displayTune =>
      _useEnglish ? widget.song.englishTune : widget.song.tune;

  List<String> get _displayTuneList =>
      _useEnglish ? widget.song.englishTuneList : widget.song.tuneList;

  List<String> get _displayLyricsList =>
      _useEnglish ? widget.song.englishLyricsList : widget.song.lyricsList;

  List<String> get _displayWords =>
      _useEnglish ? widget.song.englishWords : widget.song.words;

  List<String> get _displayMeanings =>
      _useEnglish ? widget.song.englishMeaningsList : widget.song.meanings;

  List<String> get _displayMayuragiriLyricsSeparated =>
      selectMayuragiriLyrics(widget.song, _useEnglish);

  @override
  void initState() {
    super.initState();
    final repo = Provider.of<SongRepository>(context, listen: false);
    _loadCategoryInfo(repo);
    // Remember this song so Home can offer "Continue".
    context.read<ReadingStateProvider>().recordOpened(widget.song.id);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _lyricsLanguage = Provider.of<LyricsLanguageProvider>(
      context,
    ).lyricsLanguage;
  }

  Future<void> _loadCategoryInfo(SongRepository repo) async {
    final categoryIds = await repo.getCategoryIdsForSong(widget.song.id);
    final highlights = await repo.getHighlightsForSong(widget.song.id);
    final note = await repo.getNoteForSong(widget.song.id);
    final links = await repo.getLinksForSong(widget.song.id);

    if (mounted) {
      setState(() {
        _categoryIds = categoryIds;
        _isFavorite = widget.song.isFavorite;
        _highlights = highlights;
        _note = note;
        _links = links;
      });
    }
  }

  Future<void> _reloadLinks() async {
    final repo = Provider.of<SongRepository>(context, listen: false);
    final links = await repo.getLinksForSong(widget.song.id);
    if (mounted) setState(() => _links = links);
  }

  Future<void> _addLink() async {
    final added = await showAddLinkSheet(context, songId: widget.song.id);
    if (added) await _reloadLinks();
  }

  Future<void> _deleteLink(SongLink link) async {
    if (link.id == null || !await confirmDeleteLink(context)) return;
    if (!mounted) return;
    await Provider.of<SongRepository>(context, listen: false)
        .deleteLink(link.id!);
    await _reloadLinks();
  }

  Widget _buildLinksSection(AppLocalizations l10n) {
    if (_links.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.links, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          for (final link in _links)
            Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const Icon(Icons.link),
                title: Text(
                  link.displayTitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  link.url,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () => openSavedLink(context, link.url),
                trailing: IconButton(
                  tooltip: l10n.deleteLink,
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _deleteLink(link),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _toggleFavorite() async {
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

      final l10n = AppLocalizations.of(context)!;
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            wasFavorite
                ? l10n.songRemovedFromFavorites(widget.song.title)
                : l10n.songAddedToFavorites(widget.song.title),
          ),
        ),
      );
    } catch (e, st) {
      AppLogger.error('Updating favorite failed', error: e, stackTrace: st);
      if (!mounted) return;
      setState(() {
        _isFavoriteLoading = false;
      });
      messenger.showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.errorUpdatingFavorite),
        ),
      );
    }
  }

  Future<void> _toggleHighlights(List<int> indices) async {
    final repo = Provider.of<SongRepository>(context, listen: false);

    // Check if all selected verses are already highlighted
    final allHighlighted = indices.every(
      (i) => _highlights.any((h) => h.verseIndex == i),
    );

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
          final content = _displayLyricsList[index];
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
    final tuneLength = _displayTuneList.length;
    final lyricsFontSize = context.watch<LyricsFontSizeProvider>().fontSize;

    for (int i = 0; i < _displayLyricsList.length; i++) {
      final paragraph = _displayLyricsList[i];
      if (paragraph.trim().isEmpty) continue;

      // Determine style
      final isHighlighted = _highlights.any((h) => h.verseIndex == i);
      // Using a light yellow background for highlighted text
      final bgColor = isHighlighted
          ? Colors.yellow.withValues(alpha: 0.3)
          : null;

      final style = Theme.of(context).textTheme.bodyLarge?.copyWith(
        fontSize: lyricsFontSize,
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
    final TextEditingController noteController = TextEditingController(
      text: _note?.content ?? '',
    );

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
    final l10n = AppLocalizations.of(context)!;
    final textToShare =
        '''${l10n.title}:
$_displayTitle

${l10n.temple}:
$_displayPlace

${l10n.tune}:
$_displayTune

${l10n.lyrics}:
${_displayLyricsList.join('\n')}''';

    SharePlus.instance.share(
      ShareParams(title: '${l10n.lyrics}: $_displayTitle', text: textToShare),
    );
  }

  void _shareSongLink() {
    final song = widget.song;
    final l10n = AppLocalizations.of(context)!;

    // Custom scheme URI that MainWrapper detects
    // Updated to use https domain for App Links / Universal Links
    final deepLink = 'https://${AppConstants.deepLinkDomain}/song/${song.id}';
    // Fallback Play Store URL (using standard ID format, replace if actual ID differs)
    const playStoreUrl =
        'https://play.google.com/store/apps/details?id=org.ayilavan.thiruppugazh';

    final textToShare =
        '${l10n.checkOutSong(song.title)}\n\n'
        '${l10n.tapToOpenInApp}\n$deepLink\n\n'
        '${l10n.getTheAppHere}\n$playStoreUrl';

    SharePlus.instance.share(
      ShareParams(title: l10n.checkOutSong(song.title), text: textToShare),
    );
  }

  /// One row of two equal-height action tiles. Every tile in the detail
  /// screen's button block goes through here so they line up and balance.
  Widget _actionRow(ButtonStyle style, _ActionSpec left, _ActionSpec right) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(child: _actionTile(style, left)),
          const SizedBox(width: 12),
          Expanded(child: _actionTile(style, right)),
        ],
      ),
    );
  }

  Widget _actionTile(ButtonStyle style, _ActionSpec spec) {
    return SizedBox(
      height: 84,
      child: FilledButton.tonal(
        style: style.copyWith(
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
        onPressed: spec.onPressed,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(spec.icon, size: 24),
            const SizedBox(height: 6),
            Text(
              spec.label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(height: 1.2),
            ),
          ],
        ),
      ),
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
                  _displayTitle,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (_lyricsLanguage == LyricsLanguage.english &&
                    !widget.song.hasEnglishContent)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Chip(
                      label: Text(
                        AppLocalizations.of(context)!.englishLyricsUnavailable,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                    ),
                  ),
                const SizedBox(height: 32),
                SongInfoCard(place: _displayPlace, tune: _displayTune),
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
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.lyrics,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.play_circle_outline),
                        tooltip: l10n.chantingMode,
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  ChantingScreen(song: widget.song),
                            ),
                          );
                        },
                      ),
                      Consumer<LyricsFontSizeProvider>(
                        builder: (context, fontSizeProvider, _) => Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.text_decrease),
                              tooltip: l10n.decreaseLyricsFontSize,
                              onPressed: fontSizeProvider.canDecrease
                                  ? fontSizeProvider.decrease
                                  : null,
                            ),
                            IconButton(
                              icon: const Icon(Icons.text_increase),
                              tooltip: l10n.increaseLyricsFontSize,
                              onPressed: fontSizeProvider.canIncrease
                                  ? fontSizeProvider.increase
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
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
                TextSpan(children: _buildLyricsTextSpans(context)),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: context.watch<LyricsFontSizeProvider>().fontSize,
                  height: 1.5,
                  color: Colors.black,
                ),
                contextMenuBuilder: (context, editableTextState) {
                  return AdaptiveTextSelectionToolbar.buttonItems(
                    anchors: editableTextState.contextMenuAnchors,
                    buttonItems: [
                      ...editableTextState.contextMenuButtonItems.where(
                        (item) => item.type == ContextMenuButtonType.copy,
                      ),
                      ContextMenuButtonItem(
                        onPressed: () {
                          final selection =
                              editableTextState.textEditingValue.selection;
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
            child: MayuragiriLyricsSection(
              lines: _displayMayuragiriLyricsSeparated,
              tuneLength: _displayTuneList.length,
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32.0),
              child: SongMeaningsCard(
                title: l10n.meaning,
                words: _displayWords,
                meanings: _displayMeanings,
              ),
            ),
          ),

          SliverToBoxAdapter(child: _buildLinksSection(l10n)),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _actionRow(
                    buttonStyle,
                    _ActionSpec(
                      icon: _note != null ? Icons.note : Icons.note_add_outlined,
                      label: l10n.songNote,
                      onPressed: _showNoteDialog,
                    ),
                    _ActionSpec(
                      icon: Icons.add_link,
                      label: l10n.addLink,
                      onPressed: _addLink,
                    ),
                  ),
                  _actionRow(
                    buttonStyle,
                    _ActionSpec(
                      icon: Icons.share_outlined,
                      label: l10n.shareText,
                      onPressed: _shareSongText,
                    ),
                    _ActionSpec(
                      icon: Icons.install_mobile,
                      label: l10n.shareLink,
                      onPressed: _shareSongLink,
                    ),
                  ),
                  _actionRow(
                    buttonStyle,
                    _ActionSpec(
                      icon: Icons.language,
                      label: l10n.openKaumaramPage,
                      onPressed: () => openOnKaumaram(context, widget.song),
                    ),
                    _ActionSpec(
                      icon: Icons.language,
                      label: l10n.openMayuragiriPage,
                      onPressed: () => openOnMayuragiri(context, widget.song),
                    ),
                  ),
                  _actionRow(
                    buttonStyle,
                    _ActionSpec(
                      icon: Icons.smart_display,
                      label: l10n.searchOnYouTube,
                      onPressed: () => searchOnYouTube(context, widget.song),
                    ),
                    _ActionSpec(
                      icon: Icons.search,
                      label: l10n.searchInGoogle,
                      onPressed: () => searchOnGoogle(context, widget.song),
                    ),
                  ),
                  // Clear the floating buttons so the last row stays tappable.
                  const SizedBox(height: 150),
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
                  : Icon(
                      (_isFavorite || _categoryIds.contains(1))
                          ? Icons.favorite
                          : Icons.favorite_border,
                    ),
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
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
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
}

class VerseRange {
  final int start;
  final int end;
  final int index;

  VerseRange({required this.start, required this.end, required this.index});
}

class _ActionSpec {
  const _ActionSpec({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
}
