import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/song_model.dart';
import '../../providers/song_list_provider.dart';
import 'song_detail_screen.dart';
import 'search_screen.dart';
import 'search_screen.dart';
import '../../l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

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

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    
    // Prefetch when user is 70% down the list or ~20 items away from end is a bit tricky with pixel height.
    // Simpler approach: If we are close to bottom (e.g. 2000 pixels or 2 screens worth)
    // The user requested "fetch next page when 30 items remain".
    // Since item height is variable, we can roughly estimate or just use a pixel threshold that equates to ~30 items.
    // Assuming approx 70px per item => 30 items = 2100px.
    
    const prefetchThreshold = 2500.0; 

    if (maxScroll - currentScroll <= prefetchThreshold) {
      Provider.of<SongListProvider>(context, listen: false).loadMoreSongs();
    }
  }

  @override
  Widget build(BuildContext context) {
    final listBackgroundColor = Theme.of(context).colorScheme.surfaceContainerHighest;
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

          return NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scrollInfo) {
              // We can also check here index-based if we want strict "30 items remaining" logic,
              // but pixel-based is smoother for infinite scroll.
              
              // However, to strictly follow "start fetching user reaches 30" (remaining),
              // we can try to rely on the scroll controller listener which is standard.
              // Let's stick to the scroll controller approach but attach it to the CustomScrollView.
               if (scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 2500) {
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
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(fontWeight: FontWeight.bold)
                                .copyWith(fontSize: 24),
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
                        itemCount: provider.songs.length + (provider.hasMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == provider.songs.length) {
                            return const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          final song = provider.songs[index];
                          
                          // Optional: Strict Index-based prefetching (as a backup to scroll listener)
                          // If we are at the 30th to last item, trigger load
                          if (provider.hasMore && !provider.isLoading && 
                              index >= provider.songs.length - 30) {
                             // Defer trying to load in build phase, do it post frame
                             WidgetsBinding.instance.addPostFrameCallback((_) {
                               provider.loadMoreSongs();
                             });
                          }

                          return Semantics(
                            button: true,
                            label: '${index + 1}. ${song.title}. ${song.place}',
                            hint: l10n.tapToViewSongDetails,
                            child: ListTile(
                              leading: Text(
                                '${index + 1}',
                                style: const TextStyle(fontSize: 14),
                              ),
                              title: Text(song.title),
                              subtitle: Text(
                                song.place.isNotEmpty
                                    ? song.place
                                    : l10n.tuneNotAvailable,
                                style: const TextStyle(fontSize: 12),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
               builder: (context) => const SearchScreen(),
            ),
          );
        },
        child: const Icon(Icons.search),
      ),
    );
  }
}
