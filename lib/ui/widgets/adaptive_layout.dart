import 'package:flutter/material.dart';

import '../../data/models/song_model.dart';
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

  static bool useRail(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= medium;
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
  final void Function(Song song) onOpen;

  static SongPaneScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SongPaneScope>();

  @override
  bool updateShouldNotify(SongPaneScope old) =>
      selectedSongId != old.selectedSongId;
}

/// Opens [song] in the reading pane when there is one, otherwise as a full
/// screen on top of the current page.
void openSong(BuildContext context, Song song) {
  final scope = SongPaneScope.maybeOf(context);
  if (scope != null) {
    scope.onOpen(song);
    return;
  }
  Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (_) => SongDetailScreen(song: song)));
}
