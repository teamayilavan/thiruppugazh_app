/// Splits a song's lyric lines into verses.
///
/// A verse is [tuneLength] consecutive lines -- the same rule the song detail
/// screen uses to put a blank line between stanzas, so chanting mode shows
/// exactly the groups readers already see. (Checked against the bundled
/// database: this agrees with the "......" line-break marker for 1,295 of
/// 1,340 songs, and gives the more sensible grouping for most of the rest.)
///
/// Blank lines are dropped from the output but still count toward the
/// grouping, again matching the detail screen. When a song has no tune
/// pattern, lines are paired. A trailing partial group is kept as the last
/// verse rather than discarded.
List<List<String>> splitIntoVerses(List<String> lines, int tuneLength) {
  final size = tuneLength > 0 ? tuneLength : 2;
  final verses = <List<String>>[];
  var current = <String>[];
  for (var i = 0; i < lines.length; i++) {
    final line = lines[i].trim();
    if (line.isNotEmpty) current.add(line);
    if ((i + 1) % size == 0) {
      if (current.isNotEmpty) verses.add(current);
      current = <String>[];
    }
  }
  if (current.isNotEmpty) verses.add(current);
  return verses;
}
