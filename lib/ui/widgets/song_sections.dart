import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/lyrics_font_size_provider.dart';
import '../../theme/app_theme.dart';

/// Temple and tune block under the song title.
class SongInfoCard extends StatelessWidget {
  const SongInfoCard({super.key, required this.place, required this.tune});

  final String place;
  final String tune;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.temple, style: textTheme.bodyLarge),
          const SizedBox(height: 8),
          Text(
            place,
            style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 24),
          Text(l10n.tune, style: textTheme.bodyLarge),
          Text(tune, style: textTheme.bodyLarge),
        ],
      ),
    );
  }
}

/// Word-by-word meanings: each phrase in [words] with its [meanings] entry.
class SongMeaningsCard extends StatelessWidget {
  const SongMeaningsCard({
    super.key,
    required this.title,
    required this.words,
    required this.meanings,
  });

  final String title;
  final List<String> words;
  final List<String> meanings;

  @override
  Widget build(BuildContext context) {
    // Catches mismatched data during development.
    assert(
      words.length == meanings.length,
      'The words and meanings lists must have the same length.',
    );

    if (words.isEmpty || meanings.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final wordColor =
        theme.extension<AppColorExtension>()?.textHigh ??
        theme.colorScheme.onSurface;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Divider(height: 16),
          const SizedBox(height: 16),
          ...List.generate(meanings.length, (index) {
            final word = index < words.length ? words[index] : '';
            return Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (word.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: SelectableText(
                        word,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: wordColor,
                        ),
                      ),
                    ),
                  SelectableText(
                    meanings[index],
                    style: textTheme.bodyLarge?.copyWith(height: 1.5),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

/// The word-separated ("Mayuragiri") lyrics, grouped into verses by the
/// tune pattern length like the main lyrics.
class MayuragiriLyricsSection extends StatelessWidget {
  const MayuragiriLyricsSection({
    super.key,
    required this.lines,
    required this.tuneLength,
  });

  final List<String> lines;
  final int tuneLength;

  @override
  Widget build(BuildContext context) {
    if (lines.isEmpty) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.wordSeparatedLyrics,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Divider(height: 16),
          const SizedBox(height: 16),
          SelectableText.rich(TextSpan(children: _spans(context))),
        ],
      ),
    );
  }

  List<InlineSpan> _spans(BuildContext context) {
    final spans = <InlineSpan>[];
    final lyricsFontSize = context.watch<LyricsFontSizeProvider>().fontSize;
    final style = Theme.of(context).textTheme.bodyLarge?.copyWith(
      fontSize: lyricsFontSize,
      height: 1.5,
      color: Theme.of(context).colorScheme.onSurface,
    );

    for (int i = 0; i < lines.length; i++) {
      final paragraph = lines[i];
      if (paragraph.trim().isEmpty) continue;

      spans.add(TextSpan(text: paragraph, style: style));

      final sep = (tuneLength > 0 && (i + 1) % tuneLength == 0) ? '\n\n' : '\n';
      spans.add(TextSpan(text: sep));
    }
    return spans;
  }
}
