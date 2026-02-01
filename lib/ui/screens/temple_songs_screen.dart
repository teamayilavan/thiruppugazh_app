import 'package:flutter/material.dart';
import '../../data/database/database_helper.dart';
import '../../data/models/song_model.dart';
import '../../l10n/app_localizations.dart';
import 'song_detail_screen.dart';

class TempleSongsScreen extends StatefulWidget {
  final String templeName;

  const TempleSongsScreen({super.key, required this.templeName});

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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.templeName),
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
              return ListTile(
                leading: Text('${index + 1}'),
                title: Text(song.title),
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
