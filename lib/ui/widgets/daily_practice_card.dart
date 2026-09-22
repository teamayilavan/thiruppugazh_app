import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/song_model.dart';
import '../../data/repositories/song_repository.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/lyrics_language_provider.dart';
import '../../providers/practice_provider.dart';
import '../../providers/practice_settings_provider.dart';
import '../../services/daily_selection_service.dart';
import '../../theme/app_theme.dart';
import '../screens/song_detail_screen.dart';

/// Today's hymn (இன்றைய பாடல்) as a clean, tappable card: the lowest
/// uncompleted song id, with a quiet completed-today state. Deliberately
/// minimal -- no date, no daily verse -- see [PracticeStatsSection] for
/// the days-practiced/songs-read numbers, now a separate block below it.
///
/// Returns [SizedBox.shrink] whenever the practice layer is off --
/// standing rule 7, checked on every build so toggling Settings takes
/// effect immediately.
class DailyPracticeCard extends StatefulWidget {
  const DailyPracticeCard({super.key});

  @override
  State<DailyPracticeCard> createState() => _DailyPracticeCardState();
}

class _DailyPracticeCardState extends State<DailyPracticeCard> {
  Song? _hymn;
  bool _loading = true;
  bool _requestedLoad = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_requestedLoad) return;
    _requestedLoad = true;
    if (context.read<PracticeSettingsProvider>().enabled) {
      _loadTodaysHymn();
    } else {
      _loading = false;
    }
  }

  Future<void> _loadTodaysHymn() async {
    final repo = Provider.of<SongRepository>(context, listen: false);

    try {
      final allIds = await repo.getAllSongIds();
      if (allIds.isEmpty) {
        if (mounted) setState(() => _loading = false);
        return;
      }
      final completedIds = await repo.getCompletedSongIds();

      final hymnId = todaysHymnSongId(
        allSongIds: allIds,
        completedSongIds: completedIds.toSet(),
        date: DateTime.now(),
      );
      final hymn = await repo.getSongById(hymnId);

      if (!mounted) return;
      setState(() {
        _hymn = hymn;
        _loading = false;
      });
    } catch (_) {
      // Non-fatal: the card just stays empty for this visit rather than
      // crashing the home screen over a missed daily pick.
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final enabled = context.watch<PracticeSettingsProvider>().enabled;
    if (!enabled) return const SizedBox.shrink();

    if (_loading) {
      return const Padding(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final hymn = _hymn;
    if (hymn == null) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).extension<AppColorExtension>()!;
    final practice = context.watch<PracticeProvider>();
    final lyricsLanguage = context
        .watch<LyricsLanguageProvider>()
        .lyricsLanguage;

    final useEnglish =
        lyricsLanguage == LyricsLanguage.english && hymn.hasEnglishContent;
    final title = useEnglish ? (hymn.englishTitle ?? hymn.title) : hymn.title;
    final place = useEnglish ? (hymn.englishVenue ?? hymn.place) : hymn.place;

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      color: colors.container,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => SongDetailScreen(song: hymn)),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.todaysHymn,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: colors.textMuted,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: colors.textHigh,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (place.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        place,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colors.textMuted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                practice.todayComplete
                    ? Icons.check_circle_outline
                    : Icons.chevron_right,
                color: practice.todayComplete
                    ? Theme.of(context).colorScheme.primary
                    : colors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
