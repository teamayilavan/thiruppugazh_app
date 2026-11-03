import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

import 'categories_screen.dart';
import 'songs_tab.dart';
import '../widgets/adaptive_layout.dart';
import 'temples_screen.dart';
import 'settings_screen.dart';
import 'highlights_notes_screen.dart';
import 'package:app_links/app_links.dart';
import 'package:provider/provider.dart';
import '../../data/repositories/song_repository.dart';
import 'song_detail_screen.dart';
import 'pick_song_screen.dart';
import '../../services/share_intent_service.dart';
import '../../utils/link_utils.dart';
import '../../providers/lyrics_language_provider.dart';
import '../../constants/app_constants.dart';
import '../../l10n/app_localizations.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    SongsTab(),
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
    _initDeepLinks();
    _initShareIntake();
  }

  @override
  void dispose() {
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
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => SongDetailScreen(song: song),
            ),
          );
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final useRail = Breakpoints.useRail(context);

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

    final content = PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) return;
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
      },
      child: IndexedStack(index: _selectedIndex, children: _widgetOptions),
    );

    if (useRail) {
      return Scaffold(
        body: Row(
          children: [
            // Scrolls on short windows (a phone held sideways) so every
            // destination stays reachable.
            // Keeps the rail clear of a camera cutout in landscape.
            ColoredBox(
              color: Theme.of(context).navigationRailTheme.backgroundColor!,
              child: SafeArea(
                right: false,
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
            Expanded(child: content),
          ],
        ),
      );
    }

    return Scaffold(
      body: content,
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
}

class _Destination {
  const _Destination(this.icon, this.selectedIcon, this.label);

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}
