import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/highlight_model.dart';
import '../../data/models/note_model.dart';
import '../../data/models/song_model.dart';
import '../../data/repositories/song_repository.dart';
import 'song_detail_screen.dart';
import '../../l10n/app_localizations.dart';

class HighlightsNotesScreen extends StatelessWidget {
  const HighlightsNotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Basic l10n strings (fallback to English if not defined yet)
    // Assuming we might need to add these keys to l10n later.
    // For now using hardcoded strings or generic ones.
    
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.myLibrary),
          bottom: TabBar(
            tabs: [
              Tab(icon: const Icon(Icons.highlight), text: AppLocalizations.of(context)!.highlights),
              Tab(icon: const Icon(Icons.note), text: AppLocalizations.of(context)!.notes),
            ],
          ),
        ),
        body: const TabBarView(
          children: [

            HighlightsList(),
            NotesList(),
          ],
        ),
      ),
    );
  }
}

class HighlightsList extends StatefulWidget {
  const HighlightsList({super.key});

  @override
  State<HighlightsList> createState() => _HighlightsListState();
}

class _HighlightsListState extends State<HighlightsList> {
  late Future<List<Highlight>> _highlightsFuture;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() {
      _highlightsFuture =
          Provider.of<SongRepository>(context, listen: false).getAllHighlights();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SongRepository>(
      builder: (context, repo, child) {
        // Trigger refresh if repo changes (though FutureBuilder handles its own state, 
        // using Consumer ensures we rebuild if notifyListeners is called)
        return FutureBuilder<List<Highlight>>(
          future: repo.getAllHighlights(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text(AppLocalizations.of(context)!.noHighlightsFound));
            }

            final highlights = snapshot.data!;
            return ListView.separated(
              itemCount: highlights.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final highlight = highlights[index];
                return FutureBuilder<Song?>(
                  future: repo.getSongById(highlight.songId),
                  builder: (context, songSnapshot) {
                    if (!songSnapshot.hasData) return const SizedBox.shrink();
                    final song = songSnapshot.data!;
                    
                    return ListTile(
                      title: Text(
                        song.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          '"${highlight.textContent}"',
                          style: const TextStyle(fontStyle: FontStyle.italic),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SongDetailScreen(song: song),
                          ),
                        );
                      },
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () async {
                          await repo.removeHighlight(highlight.songId, highlight.verseIndex);
                          // Consumer will rebuild
                        },
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}

class NotesList extends StatelessWidget {
  const NotesList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SongRepository>(
      builder: (context, repo, child) {
        return FutureBuilder<List<Note>>(
          future: repo.getAllNotes(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text(AppLocalizations.of(context)!.noNotesFound));
            }

            final notes = snapshot.data!;
            return ListView.separated(
              itemCount: notes.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final note = notes[index];
                return FutureBuilder<Song?>(
                  future: repo.getSongById(note.songId),
                  builder: (context, songSnapshot) {
                    if (!songSnapshot.hasData) return const SizedBox.shrink();
                    final song = songSnapshot.data!;
                    
                    return ListTile(
                      title: Text(
                        song.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          note.content,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SongDetailScreen(song: song),
                          ),
                        );
                      },
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () async {
                          final l10n = AppLocalizations.of(context)!;
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(l10n.deleteNote),
                              content: Text(l10n.deleteNoteConfirmation),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(false),
                                  child: Text(l10n.cancel),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(true),
                                  child: Text(
                                    l10n.delete,
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            await repo.deleteNote(note.songId);
                          }
                        },
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
