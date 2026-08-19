import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/repositories/song_repository.dart';
import '../../providers/song_list_provider.dart';
import '../../providers/lyrics_language_provider.dart';
import 'song_detail_screen.dart';
import 'search_screen.dart';
import '../../l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isRandomLoading = false;

  @override
  void initState() {
    super.initState();
    // Trigger initial load if not already loaded or if empty
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<SongListProvider>(context, listen: false);
      if (!provider.isInitialized) {
        provider.loadInitialSongs();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _openRandomSong() async {
    if (_isRandomLoading) return;

    final repo = Provider.of<SongRepository>(context, listen: false);
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context)!;

    setState(() {
      _isRandomLoading = true;
    });

    try {
      final randomSong = await repo.getRandomSong();

      if (!mounted) return;
      setState(() {
        _isRandomLoading = false;
      });

      if (randomSong == null) {
        messenger.showSnackBar(SnackBar(content: Text(l10n.noSongsFound)));
        return;
      }

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => SongDetailScreen(song: randomSong),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isRandomLoading = false;
      });
      messenger.showSnackBar(
        SnackBar(content: Text('Error loading random song: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final listBackgroundColor = Theme.of(
      context,
    ).colorScheme.surfaceContainerHighest;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Consumer<SongListProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.songs.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!provider.isLoading && provider.songs.isEmpty) {
            return RefreshIndicator(
              onRefresh: provider.refreshSongs,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height,
                  child: Center(child: Text(l10n.noSongsFound)),
                ),
              ),
            );
          }

          final lyricsLang = Provider.of<LyricsLanguageProvider>(
            context,
          ).lyricsLanguage;

          return NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scrollInfo) {
              // We can also check here index-based if we want strict "30 items remaining" logic,
              // but pixel-based is smoother for infinite scroll.

              // However, to strictly follow "start fetching user reaches 30" (remaining),
              // we can try to rely on the scroll controller listener which is standard.
              // Let's stick to the scroll controller approach but attach it to the CustomScrollView.
              if (scrollInfo.metrics.pixels >=
                  scrollInfo.metrics.maxScrollExtent - 2500) {
                if (!provider.isLoading && provider.hasMore) {
                  provider.loadMoreSongs();
                }
              }
              return false;
            },
            child: RefreshIndicator(
              onRefresh: provider.refreshSongs,
              child: Scrollbar(
                controller: _scrollController,
                interactive: true,
                thickness: 10.0,
                radius: const Radius.circular(10.0),
                child: CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    SliverToBoxAdapter(
                      child: Semantics(
                        image: true,
                        label: l10n.thiruppugazhHeroImage,
                        child: Image.asset(
                          'assets/images/hero.png',
                          width: double.infinity,
                          height: 350,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Semantics(
                          header: true,
                          child: Text(
                            l10n.thiruppugazhTitle,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      sliver: SliverList.separated(
                        itemCount:
                            provider.songs.length + (provider.hasMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == provider.songs.length) {
                            return const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }

                          final song = provider.songs[index];
                          final useEnglish =
                              lyricsLang == LyricsLanguage.english &&
                              song.hasEnglishContent;
                          final displayTitle = useEnglish
                              ? (song.englishTitle ?? song.title)
                              : song.title;
                          final displayPlace = useEnglish
                              ? (song.englishVenue ?? song.place)
                              : song.place;

                          return Semantics(
                            button: true,
                            label: '${index + 1}. $displayTitle. $displayPlace',
                            hint: l10n.tapToViewSongDetails,
                            child: ListTile(
                              leading: Text(
                                '${index + 1}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              title: Text(displayTitle),
                              subtitle: Text(
                                displayPlace.isNotEmpty
                                    ? displayPlace
                                    : l10n.tuneNotAvailable,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              tileColor: listBackgroundColor,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        SongDetailScreen(song: song),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                        separatorBuilder: (BuildContext context, int index) {
                          return Container(
                            color: listBackgroundColor,
                            child: const Divider(
                              height: 1,
                              thickness: 1,
                              indent: 16,
                              endIndent: 16,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Semantics(
            button: true,
            label: l10n.randomSong,
            hint: _isRandomLoading ? l10n.loading : l10n.tapToViewRandomSong,
            child: FloatingActionButton.small(
              heroTag: 'fab_random_song',
              onPressed: _isRandomLoading ? null : _openRandomSong,
              child: _isRandomLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.shuffle),
            ),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'fab_search',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SearchScreen()),
              );
            },
            child: const Icon(Icons.search),
          ),
        ],
      ),
    );
  }
}
