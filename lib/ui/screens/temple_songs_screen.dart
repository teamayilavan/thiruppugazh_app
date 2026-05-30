import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/database/database_helper.dart';
import '../../data/models/song_model.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/lyrics_language_provider.dart';
import 'song_detail_screen.dart';

class TempleSongsScreen extends StatefulWidget {
  final String templeName;          // Tamil name — used for DB query
  final String? templeDisplayName;  // Display name (English or Tamil)

  const TempleSongsScreen({
    super.key,
    required this.templeName,
    this.templeDisplayName,
  });

  @override
  State<TempleSongsScreen> createState() => _TempleSongsScreenState();
}

class _TempleSongsScreenState extends State<TempleSongsScreen> {
  late Future<List<Song>> _songsFuture;

  @override
  void initState() {
    super.initState();
    _songsFuture = DatabaseHelper().getSongsByTemple(widget.templeName);
  }

  @override
  Widget build(BuildContext context) {
    final lyricsLang = Provider.of<LyricsLanguageProvider>(context).lyricsLanguage;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.templeDisplayName ?? widget.templeName),
      ),
      body: FutureBuilder<List<Song>>(
        future: _songsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('${AppLocalizations.of(context)!.anErrorOccurred}: ${snapshot.error}'));
          }

          final songs = snapshot.data ?? [];

          if (songs.isEmpty) {
            return Center(child: Text(AppLocalizations.of(context)!.noSongsFoundForTemple));
          }

          return ListView.separated(
            itemCount: songs.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final song = songs[index];
              final useEnglish = lyricsLang == LyricsLanguage.english && song.hasEnglishContent;
              final displayTitle = useEnglish ? (song.englishTitle ?? song.title) : song.title;
              final displayPlace = useEnglish ? (song.englishVenue ?? song.place) : song.place;
              return ListTile(
                leading: Text('${index + 1}'),
                title: Text(displayTitle),
                subtitle: displayPlace.isNotEmpty
                    ? Text(displayPlace, style: Theme.of(context).textTheme.bodySmall)
                    : null,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SongDetailScreen(song: song),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
