/// True when [name] contains at least one letter, mark, digit or underscore
/// in any script, so a name made only of punctuation is rejected but Tamil
/// names are not.
///
/// Dart's `\w` matches ASCII only, even with `unicode: true`, which made the
/// old check reject every purely Tamil category name; hence the explicit
/// Unicode property classes.
bool hasValidCategoryNameChars(String name) =>
    RegExp(r'[\p{L}\p{M}\p{N}_]', unicode: true).hasMatch(name);
