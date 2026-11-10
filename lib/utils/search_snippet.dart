import '../data/models/song_model.dart';

/// The lyric line that made a song match a search, split around the matched
/// words so the screen can emphasise them. [match] is empty when the line is
/// shown without emphasis.
class SearchSnippet {
  const SearchSnippet({
    required this.before,
    required this.match,
    required this.after,
  });

  final String before;
  final String match;
  final String after;

  String get text => '$before$match$after';
}

/// Longest stretch kept before the match; longer lines are cut with an
/// ellipsis so the matched words stay in view.
const int _lead = 24;

/// Finds the first lyric line of [song] that contains [query], looking in the
/// language being read first. Returns null when there is nothing worth
/// showing: the query is too short, the song matched by its title or number
/// (which the row already shows), or no line contains it as typed. Searches by
/// transliteration can still match a song without a line containing the exact
/// letters; those rows simply have no snippet.
SearchSnippet? findMatchingLine(
  Song song,
  String query, {
  required bool preferEnglish,
}) {
  final q = query.trim().toLowerCase();
  if (q.length < 2) return null;

  if (song.title.toLowerCase().contains(q) ||
      (song.englishTitle ?? '').toLowerCase().contains(q) ||
      song.kaumaramId.trim().toLowerCase() == q) {
    return null;
  }

  final first = preferEnglish ? song.englishLyricsList : song.lyricsList;
  final second = preferEnglish ? song.lyricsList : song.englishLyricsList;
  for (final lines in [first, second]) {
    for (final raw in lines) {
      final line = raw.trim();
      final at = line.toLowerCase().indexOf(q);
      if (at < 0) continue;
      // Lower-casing can change a string's length in rare scripts; then the
      // offsets don't map back, so show the line plainly.
      if (line.toLowerCase().length != line.length) {
        return SearchSnippet(before: '', match: '', after: line);
      }
      final start = at > _lead ? at - _lead : 0;
      return SearchSnippet(
        before: (start > 0 ? '…' : '') + line.substring(start, at),
        match: line.substring(at, at + q.length),
        after: line.substring(at + q.length),
      );
    }
  }
  return null;
}
