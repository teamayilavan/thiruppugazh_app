import 'package:flutter/material.dart';
import 'dart:io';

import 'categories_screen.dart';
import 'home_screen.dart';
import 'temples_screen.dart';
import 'settings_screen.dart';
import 'highlights_notes_screen.dart';
import 'package:app_links/app_links.dart';
import 'package:provider/provider.dart';
import '../../data/repositories/song_repository.dart';
import 'song_detail_screen.dart';
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
    HomeScreen(),
    TemplesScreen(),
    CategoriesScreen(),
    HighlightsNotesScreen(),
    SettingsScreen(),
  ];

  // ... (omitted AppLinks code) ...

  late AppLinks _appLinks;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  Future<void> _initDeepLinks() async {
    _appLinks = AppLinks();

    // Check initial link if app was launched via deep link
    final initialLink = await _appLinks.getInitialLink();
    if (initialLink != null) {
      _handleDeepLink(initialLink);
    }

    // Listen for deep links while app is running
    _appLinks.uriLinkStream.listen((uri) {
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
    } else if ((uri.scheme == 'https' || uri.scheme == 'http') &&
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
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PopScope(
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
                        onPressed: () => exit(0),
                        child: Text(
                          l10n.yes,
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
              child: IndexedStack(
                index: _selectedIndex,
                children: _widgetOptions,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: _onDestinationSelected,
        selectedIndex: _selectedIndex,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: <Widget>[
          NavigationDestination(
            icon: const Icon(Icons.music_note_outlined),
            selectedIcon: const Icon(Icons.music_note),
            label: l10n.songs,
          ),
          NavigationDestination(
            icon: const Icon(Icons.temple_hindu_outlined),
            selectedIcon: const Icon(Icons.temple_hindu),
            label: l10n.temples,
          ),
          NavigationDestination(
            icon: const Icon(Icons.category_outlined),
            selectedIcon: const Icon(Icons.category),
            label: l10n.categories,
          ),
          NavigationDestination(
            icon: const Icon(Icons.library_books_outlined),
            selectedIcon: const Icon(Icons.library_books),
            label: l10n.myLibrary,
          ),
          NavigationDestination(
            icon: const Icon(Icons.more_horiz_outlined),
            selectedIcon: const Icon(Icons.more_horiz),
            label: l10n.more,
          ),
        ],
      ),
    );
  }
}
