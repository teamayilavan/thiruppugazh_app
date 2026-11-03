import 'package:flutter/material.dart';

import '../../data/models/song_model.dart';
import '../../l10n/app_localizations.dart';
import '../widgets/adaptive_layout.dart';
import 'home_screen.dart';
import 'song_detail_screen.dart';

/// The Songs tab. On a narrow window it is just the song list and each song
/// opens as its own page. When there is room it becomes a list on the left
/// and the open song beside it, so reading never leaves the list.
class SongsTab extends StatefulWidget {
  const SongsTab({super.key});

  @override
  State<SongsTab> createState() => _SongsTabState();
}

class _SongsTabState extends State<SongsTab> {
  static const double _listPaneWidth = 400;

  Song? _selected;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // The rail has already taken its share, so compare against the
        // window class minus roughly its width.
        final split =
            Breakpoints.isLargeScreen(context) &&
            constraints.maxWidth >= Breakpoints.expanded - 80;
        if (!split) return const HomeScreen();

        final colors = Theme.of(context).colorScheme;
        return Row(
          children: [
            SizedBox(
              width: _listPaneWidth,
              child: SongPaneScope(
                selectedSongId: _selected?.id,
                onOpen: (song) => setState(() => _selected = song),
                child: const HomeScreen(),
              ),
            ),
            VerticalDivider(width: 1, color: colors.outlineVariant),
            Expanded(
              child: _selected == null
                  ? _EmptyReader(
                      message: AppLocalizations.of(context)!.selectSongToRead,
                    )
                  : SongDetailScreen(
                      key: ValueKey(_selected!.id),
                      song: _selected!,
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _EmptyReader extends StatelessWidget {
  const _EmptyReader({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.menu_book_outlined,
              size: 56,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
