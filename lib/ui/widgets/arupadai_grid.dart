import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/arupadai_veedu.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/lyrics_language_provider.dart';
import '../../theme/app_theme.dart';
import '../screens/temple_songs_screen.dart';

/// Fixed 2x3 grid of the six Arupadai Veedu abodes, shown above the full
/// temple list on [TemplesScreen]. Embedded (not its own scroll view), so
/// it sizes itself to its content and scrolls along with the page.
class ArupadaiGrid extends StatelessWidget {
  const ArupadaiGrid({super.key, required this.temples});

  /// The full temple rows already fetched by [TemplesScreen]
  /// (`DatabaseHelper.getAllTemples()`), keyed here by name to find each
  /// abode's `english_name`/song count without a second query.
  final List<Map<String, dynamic>> temples;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final templesByName = {
      for (final temple in temples) temple['name'] as String: temple,
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.arupadaiVeedu,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            l10n.arupadaiVeeduSubtitle,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.6,
            ),
            itemCount: ArupadaiVeedu.abodes.length,
            itemBuilder: (context, index) {
              final abode = ArupadaiVeedu.abodes[index];
              final temple = templesByName[abode.tamilName];
              return _ArupadaiTile(abode: abode, temple: temple);
            },
          ),
        ],
      ),
    );
  }
}

class _ArupadaiTile extends StatelessWidget {
  const _ArupadaiTile({required this.abode, required this.temple});

  final ArupadaiAbode abode;

  /// The matching row from `temples`, or null if this abode's name isn't
  /// in the bundled data -- the tile still shows (with the Tamil name),
  /// it just won't open a song list with any songs in it.
  final Map<String, dynamic>? temple;

  @override
  Widget build(BuildContext context) {
    final lyricsLang = Provider.of<LyricsLanguageProvider>(
      context,
    ).lyricsLanguage;
    final englishName = temple?['english_name'] as String?;
    final displayName = (lyricsLang == LyricsLanguage.english && englishName != null)
        ? englishName
        : abode.tamilName;
    final colors = Theme.of(context).extension<AppColorExtension>()!;
    final onCard = Theme.of(context).colorScheme.onSurface;

    return Card(
      color: colors.card,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: temple == null
            ? null
            : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TempleSongsScreen(
                      templeName: abode.tamilName,
                      templeDisplayName: displayName,
                    ),
                  ),
                );
              },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(abode.icon, color: onCard, size: 24),
              const SizedBox(height: 6),
              Text(
                displayName,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: onCard,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
