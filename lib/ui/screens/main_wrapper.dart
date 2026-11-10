import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

import 'categories_screen.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import '../widgets/adaptive_layout.dart';
import 'temples_screen.dart';
import 'settings_screen.dart';
import 'highlights_notes_screen.dart';
import 'package:app_links/app_links.dart';
import 'package:provider/provider.dart';
import '../../data/models/song_model.dart';
import '../../data/repositories/song_repository.dart';
import 'song_detail_screen.dart';
import 'pick_song_screen.dart';
import '../../services/share_intent_service.dart';
import '../../utils/link_utils.dart';
import '../../providers/lyrics_language_provider.dart';
import '../../constants/app_constants.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/reading_state_provider.dart';
import '../../utils/app_logger.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  static const double _listPaneWidth = 400;
  static const int _settingsIndex = 4;

  int _selectedIndex = 0;

  /// The song open in the reading pane (tablets only).
  Song? _selected;

  /// The songs before and after [_selected] in song-number order, for the
  /// reader's previous/next buttons and the arrow keys. Null at either end,
  /// and until they have loaded.
  Song? _prevSong;
  Song? _nextSong;

  /// True once the user has opened a song in the pane themselves, as opposed
  /// to the pane showing the song remembered from last time. Only then is a
  /// rotation to portrait expected to keep that song on screen.
  bool _readerOpen = false;

  bool _paneActive = false;

  /// Whether the last layout had room for the list and the reader side by
  /// side, so a change (rotation, resizing) can be noticed.
  bool _wasSplit = false;

  // On large screens each tab keeps its own navigator, so pages opened from a
  // tab (a temple's songs, search) stay inside it and the rail and reading
  // pane remain on screen.
  final List<GlobalKey<NavigatorState>> _navKeys = List.generate(
    5,
    (_) => GlobalKey<NavigatorState>(),
  );
  final GlobalKey _tabsKey = GlobalKey();

  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    TemplesScreen(),
    CategoriesScreen(),
    HighlightsNotesScreen(),
    SettingsScreen(),
  ];

  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;
  StreamSubscription<String>? _shareSubscription;

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_handleKey);
    _initDeepLinks();
    _initShareIntake();
    _restoreLastSong();
  }

  /// Puts the song read last time into the reading pane, so a tablet doesn't
  /// start on an empty pane. It only fills the pane; nothing is opened or
  /// recorded, and a song the user picks first is never replaced.
  Future<void> _restoreLastSong() async {
    final reading = context.read<ReadingStateProvider>();
    final repo = context.read<SongRepository>();
    await reading.ready;
    final id = reading.lastSongId;
    if (id == null || !mounted || _selected != null) return;
    try {
      final song = await repo.getSongById(id);
      if (song == null || !mounted || _selected != null) return;
      setState(() => _selected = song);
      _loadNeighbours(song);
    } catch (e, st) {
      AppLogger.error(
        'Restoring the last song failed',
        error: e,
        stackTrace: st,
      );
    }
  }

  /// Shows [song] in the reading pane.
  void _select(Song song) {
    setState(() {
      _selected = song;
      _readerOpen = true;
      _prevSong = null;
      _nextSong = null;
    });
    _loadNeighbours(song);
  }

  Future<void> _loadNeighbours(Song song) async {
    final repo = context.read<SongRepository>();
    try {
      final prev = await repo.getAdjacentSong(song.id, next: false);
      final next = await repo.getAdjacentSong(song.id, next: true);
      // The user may have moved on while this was loading.
      if (!mounted || _selected?.id != song.id) return;
      setState(() {
        _prevSong = prev;
        _nextSong = next;
      });
    } catch (e, st) {
      AppLogger.error(
        'Loading neighbouring songs failed',
        error: e,
        stackTrace: st,
      );
    }
  }

  /// A tablet changed between "list and reader side by side" and a single
  /// column (rotation, a resized window). A full-screen song page left in a
  /// tab would be squeezed into the list column, so it moves into the pane;
  /// and a song open in the pane becomes a full page, so it isn't lost.
  void _onSplitChanged(bool split) {
    if (!mounted) return;
    if (split) {
      Song? found;
      for (final key in _navKeys) {
        key.currentState?.popUntil((route) {
          final args = route.settings.arguments;
          if (route.settings.name == songRouteName && args is Song) {
            found = args;
            return false;
          }
          return true;
        });
      }
      if (found != null) _select(found!);
    } else if (_readerOpen &&
        _selected != null &&
        _selectedIndex != _settingsIndex) {
      final nav = _tabNavigator;
      if (nav == null) return;
      nav.push(songRoute(_selected!));
      setState(() => _readerOpen = false);
    }
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleKey);
    _shareSubscription?.cancel();
    _linkSubscription?.cancel();
    super.dispose();
  }

  /// Handles web links shared into the app from other apps: both the share
  /// that launched us and any that arrive while we're running.
  Future<void> _initShareIntake() async {
    _shareSubscription = ShareIntentService.sharedText.listen(
      _handleSharedText,
    );
    final initial = await ShareIntentService.getInitialSharedText();
    if (initial != null) await _handleSharedText(initial);
  }

  Future<void> _handleSharedText(String text) async {
    if (!mounted) return;
    final url = LinkUtils.extractUrl(text);
    if (url == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.sharedLinkNotFound),
        ),
      );
      return;
    }
    final result = await Navigator.of(context).push<PickSongResult>(
      MaterialPageRoute(
        builder: (context) =>
            PickSongScreen(url: url, title: LinkUtils.suggestTitle(text, url)),
      ),
    );
    if (result == null || !mounted) return;

    // Confirm and put the user back where they were -- they came from another
    // app and still have something to do there, so don't pull them into ours.
    final l10n = AppLocalizations.of(context)!;
    final song = result.song;
    final useEnglish =
        context.read<LyricsLanguageProvider>().lyricsLanguage ==
            LyricsLanguage.english &&
        song.hasEnglishContent;
    final songTitle = useEnglish
        ? (song.englishTitle ?? song.title)
        : song.title;
    final message = result.added
        ? l10n.linkAddedToSong(songTitle)
        : l10n.linkAlreadyAdded;
    final handledNatively = await ShareIntentService.finishShare(message);
    if (!handledNatively && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _initDeepLinks() async {
    _appLinks = AppLinks();

    // Check initial link if app was launched via deep link
    final initialLink = await _appLinks.getInitialLink();
    if (initialLink != null) {
      _handleDeepLink(initialLink);
    }

    // Listen for deep links while app is running
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      _handleDeepLink(uri);
    });
  }

  Future<void> _handleDeepLink(Uri uri) async {
    // Expected formats:
    // 1. Custom Scheme: thiruppugazh://song/{id} (Legacy/Internal)
    // 2. App Link: https://thiruppugazh.ayilavan.org/song/{id}

    bool isSongLink = false;
    String? songIdString;

    if (uri.scheme == 'thiruppugazh' && uri.host == 'song') {
      // Legacy format
      if (uri.pathSegments.isNotEmpty) songIdString = uri.pathSegments.first;
      isSongLink = true;
    } else if (uri.scheme == 'https' &&
        uri.host == AppConstants.deepLinkDomain &&
        uri.pathSegments.isNotEmpty &&
        uri.pathSegments[0] == 'song') {
      // HTTPS format: /song/{id}
      if (uri.pathSegments.length > 1) songIdString = uri.pathSegments[1];
      isSongLink = true;
    }

    if (isSongLink && songIdString != null) {
      final songId = int.tryParse(songIdString);

      if (songId != null) {
        final repo = Provider.of<SongRepository>(context, listen: false);
        final song = await repo.getSongById(songId);

        if (song != null && mounted) {
          if (_paneActive) {
            _select(song);
          } else {
            Navigator.of(context).push(songRoute(song));
          }
        }
      }
    }
  }

  void _onDestinationSelected(int index) {
    if (_selectedIndex != index) {
      FocusManager.instance.primaryFocus?.unfocus();
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  /// The navigator of the visible tab, on large screens where tabs have one.
  NavigatorState? get _tabNavigator => Breakpoints.isLargeScreen(context)
      ? _navKeys[_selectedIndex].currentState
      : null;

  /// Goes back one page inside the visible tab. False when already at its
  /// first page.
  bool _popTabPage() {
    final nav = _tabNavigator;
    if (nav == null || !nav.canPop()) return false;
    nav.pop();
    return true;
  }

  /// Keyboard shortcuts for tablets used with a keyboard: Ctrl+F opens search
  /// and Esc goes back a page. Ignored while a dialog or full-screen page is
  /// on top, which handle their own keys.
  bool _handleKey(KeyEvent event) {
    if (event is! KeyDownEvent || ModalRoute.of(context)?.isCurrent != true) {
      return false;
    }
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.keyF &&
        HardwareKeyboard.instance.isControlPressed) {
      _openSearch();
      return true;
    }
    if (key == LogicalKeyboardKey.escape) return _popTabPage();
    if (key == LogicalKeyboardKey.arrowLeft ||
        key == LogicalKeyboardKey.arrowRight) {
      // Previous / next song in the reader, unless the arrows are moving a
      // text cursor.
      if (!_paneActive || _selected == null || _isEditingText()) return false;
      final target = key == LogicalKeyboardKey.arrowLeft
          ? _prevSong
          : _nextSong;
      if (target == null) return false;
      _select(target);
      return true;
    }
    return false;
  }

  /// True while the keyboard focus is in a text field the user can type in
  /// (the search box). Selectable lyrics are read-only and don't count.
  bool _isEditingText() {
    final context = FocusManager.instance.primaryFocus?.context;
    if (context == null) return false;
    final editable = context.findAncestorStateOfType<EditableTextState>();
    return editable != null && !editable.widget.readOnly;
  }

  void _openSearch() {
    final route = MaterialPageRoute<void>(
      builder: (context) => const SearchScreen(),
    );
    (_tabNavigator ?? Navigator.of(context)).push(route);
  }

  void _confirmExit(AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.exitAppTitle),
        content: Text(l10n.exitAppMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.no),
          ),
          TextButton(
            onPressed: () => SystemNavigator.pop(),
            child: Text(
              l10n.yes,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final useRail = Breakpoints.useRail(context);
    final large = Breakpoints.isLargeScreen(context);

    final destinations = <_Destination>[
      _Destination(Icons.music_note_outlined, Icons.music_note, l10n.songs),
      _Destination(
        Icons.temple_hindu_outlined,
        Icons.temple_hindu,
        l10n.temples,
      ),
      _Destination(Icons.category_outlined, Icons.category, l10n.categories),
      _Destination(
        Icons.library_books_outlined,
        Icons.library_books,
        l10n.myLibrary,
      ),
      _Destination(Icons.more_horiz_outlined, Icons.more_horiz, l10n.more),
    ];

    final tabs = KeyedSubtree(
      key: _tabsKey,
      child: IndexedStack(
        index: _selectedIndex,
        children: [
          for (var i = 0; i < _widgetOptions.length; i++)
            large
                ? _TabNavigator(navKey: _navKeys[i], child: _widgetOptions[i])
                : _widgetOptions[i],
        ],
      ),
    );

    final tabsWithBack = PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) return;
        if (_popTabPage()) return;
        _confirmExit(l10n);
      },
      child: tabs,
    );

    final Widget content;
    if (useRail) {
      content = Scaffold(
        body: Row(
          children: [
            // The rail's colour reaches under a camera cutout or gesture bar.
            ColoredBox(
              color: Theme.of(context).navigationRailTheme.backgroundColor!,
              child: SafeArea(
                right: false,
                // Scrolls on short windows (a phone held sideways) so every
                // destination stays reachable.
                child: LayoutBuilder(
                  builder: (context, constraints) => SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
                        child: NavigationRail(
                          selectedIndex: _selectedIndex,
                          onDestinationSelected: _onDestinationSelected,
                          labelType: NavigationRailLabelType.all,
                          destinations: [
                            for (final d in destinations)
                              NavigationRailDestination(
                                icon: Icon(d.icon),
                                selectedIcon: Icon(d.selectedIcon),
                                label: Text(d.label),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // The rail has taken its share, so compare against the
                  // window class minus roughly its width.
                  final split =
                      large &&
                      constraints.maxWidth >= Breakpoints.expanded - 80;
                  final showReader = split && _selectedIndex != _settingsIndex;
                  _paneActive = showReader;
                  if (split != _wasSplit) {
                    _wasSplit = split;
                    WidgetsBinding.instance.addPostFrameCallback(
                      (_) => _onSplitChanged(split),
                    );
                  }
                  final selected = _selected;
                  return Row(
                    children: [
                      SizedBox(
                        width: showReader
                            ? _listPaneWidth
                            : constraints.maxWidth,
                        child: SongPaneScope(
                          selectedSongId: showReader ? selected?.id : null,
                          onOpen: showReader ? _select : null,
                          child: tabsWithBack,
                        ),
                      ),
                      if (showReader)
                        VerticalDivider(
                          width: 1,
                          color: Theme.of(context).colorScheme.outlineVariant,
                        ),
                      if (showReader)
                        Expanded(
                          child: selected == null
                              ? _EmptyReader(message: l10n.selectSongToRead)
                              : Column(
                                  children: [
                                    _ReaderBar(
                                      previous: _prevSong,
                                      next: _nextSong,
                                      onSelect: _select,
                                    ),
                                    Expanded(
                                      child: SongDetailScreen(
                                        key: ValueKey(selected.id),
                                        song: selected,
                                        recordOpened: _readerOpen,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      );
    } else {
      content = Scaffold(
        body: tabsWithBack,
        bottomNavigationBar: NavigationBar(
          onDestinationSelected: _onDestinationSelected,
          selectedIndex: _selectedIndex,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: [
            for (final d in destinations)
              NavigationDestination(
                icon: Icon(d.icon),
                selectedIcon: Icon(d.selectedIcon),
                label: d.label,
              ),
          ],
        ),
      );
    }

    return content;
  }
}

/// A tab's own navigator. The PopScope in [_MainWrapperState] handles the
/// system back button.
class _TabNavigator extends StatelessWidget {
  const _TabNavigator({required this.navKey, required this.child});

  final GlobalKey<NavigatorState> navKey;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navKey,
      onGenerateRoute: (_) => MaterialPageRoute<void>(builder: (_) => child),
    );
  }
}

/// Previous / next song, above the reading pane. Songs follow each other in
/// song-number order, whichever list the song was opened from.
class _ReaderBar extends StatelessWidget {
  const _ReaderBar({
    required this.previous,
    required this.next,
    required this.onSelect,
  });

  final Song? previous;
  final Song? next;
  final ValueChanged<Song> onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final prev = previous;
    final nxt = next;
    return SafeArea(
      bottom: false,
      left: false,
      child: SizedBox(
        height: 48,
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              tooltip: l10n.previousSong,
              onPressed: prev == null ? null : () => onSelect(prev),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              tooltip: l10n.nextSong,
              onPressed: nxt == null ? null : () => onSelect(nxt),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyReader extends StatelessWidget {
  const _EmptyReader({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.menu_book_outlined,
              size: 56,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Destination {
  const _Destination(this.icon, this.selectedIcon, this.label);

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}
