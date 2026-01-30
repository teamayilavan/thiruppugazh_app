import 'package:flutter/material.dart';
import 'dart:io';

import 'categories_screen.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'settings_screen.dart';
import 'package:app_links/app_links.dart';
import 'package:provider/provider.dart';
import '../../data/repositories/song_repository.dart';
import 'song_detail_screen.dart';
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
    CategoriesScreen(),
    SearchScreen(),
    SettingsScreen(),
    SettingsScreen(),
  ];

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

  void _handleDeepLink(Uri uri) async {
    // Expected format: thiruppugazh://song/{id}
    if (uri.host == 'song' && uri.pathSegments.isNotEmpty) {
      final songIdString = uri.pathSegments.first;
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
              onPopInvoked: (bool didPop) {
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
                  index: _selectedIndex, children: _widgetOptions),
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
            icon: const Icon(Icons.category_outlined),
            selectedIcon: const Icon(Icons.category),
            label: l10n.categories,
          ),
          NavigationDestination(
            icon: const Icon(Icons.search_outlined),
            selectedIcon: const Icon(Icons.search),
            label: l10n.search,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: l10n.settings,
          ),
        ],
      ),
    );
  }
}
