import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/song_model.dart';
import '../../data/repositories/song_repository.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/lyrics_language_provider.dart';
import '../../services/daily_song_service.dart';
import '../../theme/app_theme.dart';
import '../screens/song_detail_screen.dart';

/// Today's song (இன்றைய பாடல்), picked deterministically from today's date
/// via [dailySongIndexForDate] -- every installation shows the same song on
/// the same calendar date, and it stays put until the next local date.
/// Always visible; unlike the practice-layer's own daily pick, this one
/// ignores reading/completion state entirely.
class TodaysSongCard extends StatefulWidget {
  const TodaysSongCard({super.key});

  @override
  State<TodaysSongCard> createState() => _TodaysSongCardState();
}

class _TodaysSongCardState extends State<TodaysSongCard> {
  Song? _song;
  bool _loading = true;
  bool _requestedLoad = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_requestedLoad) return;
    _requestedLoad = true;
    _loadTodaysSong();
  }

  Future<void> _loadTodaysSong() async {
    final repo = Provider.of<SongRepository>(context, listen: false);

    try {
      final count = await repo.getSongsCount();
      if (count <= 0) {
        if (mounted) setState(() => _loading = false);
        return;
      }
      final index = dailySongIndexForDate(DateTime.now(), count);
      final song = await repo.getSongByIndex(index);

      if (!mounted) return;
      setState(() {
        _song = song;
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
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final song = _song;
    if (song == null) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).extension<AppColorExtension>()!;
    final lyricsLanguage = context
        .watch<LyricsLanguageProvider>()
        .lyricsLanguage;

    final useEnglish =
        lyricsLanguage == LyricsLanguage.english && song.hasEnglishContent;
    final title = useEnglish ? (song.englishTitle ?? song.title) : song.title;
    final place = useEnglish ? (song.englishVenue ?? song.place) : song.place;

    // The card's fill (colors.card) is a mid-tone green in both themes, so
    // the app's general-purpose textHigh/textMuted colors (tuned for the
    // plain surface background) don't have enough contrast against it.
    // onSurface is the same high-contrast color the app already uses for
    // ordinary readable text, and it reads clearly on colors.card in both
    // light and dark mode.
    final onCard = Theme.of(context).colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Semantics(
        button: true,
        label: '${l10n.todaysSong}. $title. $place',
        hint: l10n.tapToViewTodaysSong,
        child: Card(
          color: colors.card,
          child: InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => SongDetailScreen(song: song),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 16.0,
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today_outlined, color: onCard, size: 26),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.todaysSong,
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
                        if (place.isNotEmpty)
                          Text(
                            place,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: onCard),
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
