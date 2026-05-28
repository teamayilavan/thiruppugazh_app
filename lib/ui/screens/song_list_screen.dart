// lib/ui/screens/song_list_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/category_model.dart';
import '../../data/models/song_model.dart';
import '../../data/repositories/song_repository.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/lyrics_language_provider.dart';
import '../widgets/error_display_widget.dart';
import 'song_detail_screen.dart';

class SongListScreen extends StatefulWidget {
  final Category category;

  const SongListScreen({super.key, required this.category});

  @override
  State<SongListScreen> createState() => _SongListScreenState();
}

class _SongListScreenState extends State<SongListScreen> {
  late Future<List<Song>> _songsFuture;

  @override
  void initState() {
    super.initState();
    // Fetch songs for the specific category when the screen loads
    _songsFuture = Provider.of<SongRepository>(context, listen: false)
        .getSongsByCategoryId(widget.category.id!);
  }

  @override
  Widget build(BuildContext context) {
    final lyricsLang = Provider.of<LyricsLanguageProvider>(context).lyricsLanguage;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.name),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _songsFuture = Provider.of<SongRepository>(context, listen: false)
                .getSongsByCategoryId(widget.category.id!);
          });
          await _songsFuture;
        },
        child: FutureBuilder<List<Song>>(
          future: _songsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return ErrorDisplayWidget(
                errorMessage: AppLocalizations.of(context)!.failedToLoadSongs,
                onRetry: () {
                  setState(() {
                    _songsFuture =
                        Provider.of<SongRepository>(context, listen: false)
                            .getSongsByCategoryId(widget.category.id!);
                  });
                },
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
               return Stack(
                children: [
                  ListView(), // Enable pull to refresh on empty
                  Center(
                    child: Text(
                      'No songs found in "${widget.category.name}".',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ],
              );
            }
  
            final songs = snapshot.data!;
            return Scrollbar(
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: songs.length,
                itemBuilder: (context, index) {
                  final song = songs[index];
                  final useEnglish = lyricsLang == LyricsLanguage.english && song.hasEnglishContent;
                  final displayTitle = useEnglish ? (song.englishTitle ?? song.title) : song.title;
                  final displayPlace = useEnglish ? (song.englishVenue ?? song.place) : song.place;
                  return ListTile(
                    title: Padding(
                      // Add padding to the bottom of the title
                      padding: const EdgeInsets.only(bottom: 2.0),
                      child: Text('${index + 1}. $displayTitle'),
                    ),
                    //gap between title and subtitle
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 6.0,
                      horizontal: 12.0,
                    ),
                    subtitle: Text(
                      displayPlace.isNotEmpty ? displayPlace : 'Tune not available',
                      //change text size
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => SongDetailScreen(song: song),
                        ),
                      );
                    },
                  );
                },
                // This builds the divider between each ListTile
                separatorBuilder: (BuildContext context, int index) {
                  return Divider(
                    height: 1, // The height of the divider space
                    thickness: 1, // The thickness of the line
                    indent: 12, // The empty space on the left of the divider
                    endIndent: 12, // The empty space on the right of the divider
                    color: Theme.of(context).dividerColor, 
                  );
                },
              ),
            );
  
          },
        ),
      ),
    );

  }
}