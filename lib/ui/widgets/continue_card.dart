import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/song_model.dart';
import '../../data/repositories/song_repository.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/lyrics_language_provider.dart';
import '../../providers/reading_state_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/verses.dart';
import '../screens/chanting_screen.dart';
import '../screens/song_detail_screen.dart';

/// "Continue where you left off": the song the user opened last, and -- if
/// they were chanting it -- the verse they were on. Hidden until they have
/// opened a song.
class ContinueCard extends StatefulWidget {
  const ContinueCard({super.key});

  @override
  State<ContinueCard> createState() => _ContinueCardState();
}

class _ContinueCardState extends State<ContinueCard> {
  int? _loadedId;
  Future<Song?>? _songFuture;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ReadingStateProvider>();
    final id = state.lastSongId;
    if (id == null) return const SizedBox.shrink();

    if (id != _loadedId) {
      _loadedId = id;
      _songFuture = Provider.of<SongRepository>(
        context,
        listen: false,
      ).getSongById(id);
    }

    return FutureBuilder<Song?>(
      future: _songFuture,
      builder: (context, snapshot) {
        final song = snapshot.data;
        if (song == null) return const SizedBox.shrink();
        return _buildCard(context, state, song);
      },
    );
  }

  Widget _buildCard(
    BuildContext context,
    ReadingStateProvider state,
    Song song,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).extension<AppColorExtension>()!;
    final onCard = Theme.of(context).colorScheme.onSurface;
    final useEnglish =
        context.watch<LyricsLanguageProvider>().lyricsLanguage ==
            LyricsLanguage.english &&
        song.hasEnglishContent;

    final title = useEnglish ? (song.englishTitle ?? song.title) : song.title;
    final lines = useEnglish ? song.englishLyricsList : song.lyricsList;
    final tuneLines = useEnglish ? song.englishTuneList : song.tuneList;
    final verseCount = splitIntoVerses(lines, tuneLines.length).length;

    // Only resume into chanting if a position is saved and still valid.
    final savedIndex = state.lastChantIndex;
    final resumeChanting =
        state.lastMode == ResumeMode.chant &&
        savedIndex != null &&
        verseCount > 0;
    final index = resumeChanting
        ? savedIndex.clamp(0, verseCount - 1)
        : 0;

    final subtitle = resumeChanting
        ? l10n.continueChantingAt(index + 1, verseCount)
        : l10n.continueLastOpened;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Semantics(
        button: true,
        label: '${l10n.continueWhereLeftOff}. $title. $subtitle',
        child: Card(
          color: colors.card,
          child: InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => resumeChanting
                      ? ChantingScreen(song: song, initialIndex: index)
                      : SongDetailScreen(song: song),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(
                    resumeChanting
                        ? Icons.self_improvement
                        : Icons.play_circle_outline,
                    color: onCard,
                    size: 26,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.continueWhereLeftOff,
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(color: onCard, letterSpacing: 0.5),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: onCard,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(color: onCard),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.chevron_right, color: onCard),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
