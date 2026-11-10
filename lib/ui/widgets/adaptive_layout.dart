import 'package:flutter/material.dart';

import '../../data/models/song_model.dart';
import '../../theme/app_theme.dart';
import '../screens/song_detail_screen.dart';

/// Window-width breakpoints (Material 3 window size classes).
class Breakpoints {
  /// From here the bottom bar gives way to a navigation rail.
  static const double medium = 600;

  /// From here the Songs tab shows the list and the open song side by side.
  static const double expanded = 840;

  /// Widest a reading column (lists, settings, lyrics) grows before the
  /// extra width becomes margin.
  static const double contentMaxWidth = 720;

  /// True on tablets and other windows that are at least [medium] in both
  /// directions. A phone held sideways is wide but short, so it is not.
  static bool isLargeScreen(BuildContext context) =>
      MediaQuery.sizeOf(context).shortestSide >= medium;

  /// Navigation goes to the side whenever there is width for it. That
  /// includes a phone held sideways, where the bottom bar would eat a fifth
  /// of the height.
  static bool useRail(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= medium;

  /// A window shorter than this (a phone held sideways) shrinks the Home
  /// hero image so the songs stay in view.
  static const double shortHeight = 500;
}

/// Centers [child] and stops it growing wider than [maxWidth], so lists and
/// forms stay readable on tablets instead of stretching edge to edge.
class ContentWidth extends StatelessWidget {
  const ContentWidth({
    super.key,
    required this.child,
    this.maxWidth = Breakpoints.contentMaxWidth,
  });

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}

/// Side margin that centers a column of at most [maxWidth] inside [width].
/// For slivers, which cannot sit inside a [ConstrainedBox].
double gutterFor(
  double width, {
  double maxWidth = Breakpoints.contentMaxWidth,
}) {
  final extra = (width - maxWidth) / 2;
  return extra > 0 ? extra : 0;
}

/// Tells the Songs tab's list where to show a tapped song. Present only when
/// the tab is wide enough for a reading pane.
class SongPaneScope extends InheritedWidget {
  const SongPaneScope({
    super.key,
    required this.selectedSongId,
    required this.onOpen,
    required super.child,
  });

  final int? selectedSongId;

  /// Null when there is no room for a pane right now; songs then open as
  /// full pages.
  final void Function(Song song)? onOpen;

  static SongPaneScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SongPaneScope>();

  @override
  bool updateShouldNotify(SongPaneScope old) =>
      selectedSongId != old.selectedSongId ||
      (onOpen == null) != (old.onOpen == null);
}

/// Background for the list row of the song open in the reading pane, or null
/// for every other row (and when there is no pane).
Color? paneSelectionColor(BuildContext context, int songId) {
  final scope = SongPaneScope.maybeOf(context);
  if (scope?.selectedSongId != songId) return null;
  return Theme.of(context).extension<AppColorExtension>()!.card;
}

/// Name of the full-screen song page's route. The shell looks for it when a
/// tablet turns from portrait to landscape, to move that song into the reading
/// pane instead of squeezing a full page into the list column.
const String songRouteName = 'song-detail';

/// The full-screen page for [song]. Its route carries the song, so the shell
/// can recover it.
Route<void> songRoute(Song song) => MaterialPageRoute<void>(
  settings: RouteSettings(name: songRouteName, arguments: song),
  builder: (_) => SongDetailScreen(song: song),
);

/// Opens [song] in the reading pane when there is one, otherwise as a full
/// screen on top of the current page.
void openSong(BuildContext context, Song song) {
  final onOpen = SongPaneScope.maybeOf(context)?.onOpen;
  if (onOpen != null) {
    onOpen(song);
    return;
  }
  Navigator.of(context).push(songRoute(song));
}
