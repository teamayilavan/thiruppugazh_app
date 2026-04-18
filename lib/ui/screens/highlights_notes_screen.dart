import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/repositories/song_repository.dart';
import 'song_detail_screen.dart';
import '../../l10n/app_localizations.dart';

class HighlightsNotesScreen extends StatelessWidget {
  const HighlightsNotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = Provider.of<SongRepository>(context, listen: false)
        .getHighlightsWithSongs();
  }

  void _refresh() {
    if (!mounted) return;
    setState(_load);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text(l10n.anErrorOccurred));
        }
        final rows = snapshot.data ?? [];
        if (rows.isEmpty) {
          return Center(child: Text(l10n.noHighlightsFound));
        }

        // Group rows by song_id
        final Map<int, List<Map<String, dynamic>>> grouped = {};
        for (final row in rows) {
          final songId = row['song_id'] as int;
          grouped.putIfAbsent(songId, () => []).add(row);
        }
        final songIds = grouped.keys.toList();

        return ListView.separated(
          itemCount: songIds.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, index) {
            final songId = songIds[index];
            final songRows = grouped[songId]!;
            final songTitle = songRows.first['song_title'] as String;
            final count = songRows.length;

            return ListTile(
              title: Text(
                songTitle,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  '$count ${count == 1 ? l10n.highlight : l10n.highlights}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
              onTap: () async {
                final repo =
                    Provider.of<SongRepository>(context, listen: false);
                final song = await repo.getSongById(songId);
                if (song != null && context.mounted) {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SongDetailScreen(song: song),
                    ),
                  );
                  _refresh();
                }
              },
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            );
          },
        );
      },
    );
  }
}

class NotesList extends StatefulWidget {
  const NotesList({super.key});

  @override
  State<NotesList> createState() => _NotesListState();
}

class _NotesListState extends State<NotesList> {
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = Provider.of<SongRepository>(context, listen: false)
        .getNotesWithSongs();
  }

  void _refresh() {
    if (!mounted) return;
    setState(_load);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text(l10n.anErrorOccurred));
        }
        final rows = snapshot.data ?? [];
        if (rows.isEmpty) {
          return Center(child: Text(l10n.noNotesFound));
        }

        return ListView.separated(
          itemCount: rows.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, index) {
            final row = rows[index];
            final songId = row['song_id'] as int;
            final songTitle = row['song_title'] as String;
            final content = row['content'] as String;

            return ListTile(
              title: Text(
                songTitle,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              onTap: () async {
                final repo =
                    Provider.of<SongRepository>(context, listen: false);
                final song = await repo.getSongById(songId);
                if (song != null && context.mounted) {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SongDetailScreen(song: song),
                    ),
                  );
                  _refresh();
                }
              },
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () async {
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
                  if (confirm == true && context.mounted) {
                    final repo =
                        Provider.of<SongRepository>(context, listen: false);
                    await repo.deleteNote(songId);
                    _refresh();
                  }
                },
              ),
            );
          },
        );
      },
    );
  }
}
