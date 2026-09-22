import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_constants.dart';
import '../../data/models/song_model.dart';
import '../../data/repositories/song_repository.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/lyrics_font_size_provider.dart';
import '../../providers/lyrics_language_provider.dart';
import '../../providers/practice_provider.dart';
import '../../providers/practice_settings_provider.dart';
import '../../services/daily_selection_service.dart';
import '../../theme/app_theme.dart';
import '../screens/song_detail_screen.dart';

/// The v1.5 "Daily Loop" card: local date (+ a festival line once T2.8
/// lands), one verse of "today's grace" (இன்றைய அருள்), today's hymn
/// (இன்றைய பாடல்) with a quiet completion state, and the n/corpus
/// progress bar. Inserted as the first sliver of the home screen's
/// CustomScrollView (T1.7).
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
  Song? _verseSong;
  bool _loading = true;
  bool _requestedLoad = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_requestedLoad) return;
    _requestedLoad = true;
    if (context.read<PracticeSettingsProvider>().enabled) {
      _loadDailySelection();
    } else {
      _loading = false;
    }
  }

  Future<void> _loadDailySelection() async {
    final repo = Provider.of<SongRepository>(context, listen: false);
    final today = DateTime.now();

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
        date: today,
      );

      final sortedIds = [...allIds]..sort();
      final verseSongIndex = verseSongIdForDate(today, sortedIds.length);
      final verseSongId = sortedIds[verseSongIndex];

      final hymn = await repo.getSongById(hymnId);
      final verseSong = verseSongId == hymnId
          ? hymn
          : await repo.getSongById(verseSongId);

      if (!mounted) return;
      setState(() {
        _hymn = hymn;
        _verseSong = verseSong;
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

    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).extension<AppColorExtension>()!;
    final practice = context.watch<PracticeProvider>();
    final lyricsLanguage = context
        .watch<LyricsLanguageProvider>()
        .lyricsLanguage;
    final lyricsFontSize = context.watch<LyricsFontSizeProvider>().fontSize;

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      color: colors.container,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _loading
            ? const Padding(
                padding: EdgeInsets.symmetric(vertical: 24.0),
                child: Center(child: CircularProgressIndicator()),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDateLine(context, colors),
                  if (_verseSong != null) ...[
                    const SizedBox(height: 16),
                    _buildVerseSection(
                      context,
                      l10n,
                      colors,
                      lyricsLanguage,
                      lyricsFontSize,
                    ),
                  ],
                  if (_hymn != null) ...[
                    const SizedBox(height: 16),
                    _buildHymnSection(
                      context,
                      l10n,
                      colors,
                      practice,
                      lyricsLanguage,
                    ),
                  ],
                  const SizedBox(height: 16),
                  _buildProgressSection(context, l10n, colors, practice),
                ],
              ),
      ),
    );
  }

  Widget _buildDateLine(BuildContext context, AppColorExtension colors) {
    // Festival line is a stub in v1.5 -- always none until T2.8 wires the
    // bundled offline lunisolar lookup table. No date is ever shown
    // wrong: showing nothing is always the safe fallback.
    final dateText = MaterialLocalizations.of(
      context,
    ).formatFullDate(DateTime.now());
    return Text(
      dateText,
      style: Theme.of(
        context,
      ).textTheme.labelLarge?.copyWith(color: colors.textMuted),
    );
  }

  Widget _buildVerseSection(
    BuildContext context,
    AppLocalizations l10n,
    AppColorExtension colors,
    LyricsLanguage lyricsLanguage,
    double lyricsFontSize,
  ) {
    final song = _verseSong!;
    final useEnglish =
        lyricsLanguage == LyricsLanguage.english && song.hasEnglishContent;
    final words = useEnglish ? song.englishWords : song.words;
    final meanings = useEnglish ? song.englishMeaningsList : song.meanings;
    final verseCount = words.length < meanings.length
        ? words.length
        : meanings.length;
    if (verseCount == 0) return const SizedBox.shrink();

    final index = verseIndexForDate(DateTime.now(), verseCount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.todaysGrace,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: colors.textHigh,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          words[index],
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontSize: lyricsFontSize,
            height: 1.5,
            color: colors.textHigh,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          meanings[index],
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: colors.textMuted),
        ),
      ],
    );
  }

  Widget _buildHymnSection(
    BuildContext context,
    AppLocalizations l10n,
    AppColorExtension colors,
    PracticeProvider practice,
    LyricsLanguage lyricsLanguage,
  ) {
    final song = _hymn!;
    final useEnglish =
        lyricsLanguage == LyricsLanguage.english && song.hasEnglishContent;
    final title = useEnglish ? (song.englishTitle ?? song.title) : song.title;
    final place = useEnglish ? (song.englishVenue ?? song.place) : song.place;

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => SongDetailScreen(song: song)));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.todaysHymn,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: colors.textHigh,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: colors.textHigh),
                  ),
                  if (place.isNotEmpty)
                    Text(
                      place,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: colors.textMuted),
                    ),
                ],
              ),
            ),
            if (practice.todayComplete)
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.completedToday,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: colors.textMuted),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSection(
    BuildContext context,
    AppLocalizations l10n,
    AppColorExtension colors,
    PracticeProvider practice,
  ) {
    const total = AppConstants.corpusSize;
    final progress = total == 0 ? 0.0 : practice.completedCount / total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            minHeight: 8,
            backgroundColor: colors.card,
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.practiceProgressLabel(practice.completedCount, total),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colors.textHigh,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              l10n.totalDaysKeptLabel(practice.totalDays),
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: colors.textMuted),
            ),
          ],
        ),
      ],
    );
  }
}
