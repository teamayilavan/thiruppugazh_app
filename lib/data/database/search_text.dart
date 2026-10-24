import '../../constants/app_constants.dart';

/// Text handling for the song search: Tamil spelling variants, the casual
/// "Tanglish" normalisation used for temple names, and query clean-up.
class SearchText {
  SearchText._();

  /// Generates variations for common Tamil spelling differences.
  /// Currently handles:
  /// - ன (U+0BA9) <-> ந (U+0BA8)
  /// Escapes `%`, `_` and the escape character itself so a typed query is
  /// matched literally by `LIKE ? ESCAPE '\'`.
  static String escapeLike(String s) => s
      .replaceAll(r'\', r'\\')
      .replaceAll('%', r'\%')
      .replaceAll('_', r'\_');

  static List<String> tamilVariations(String query) {
    final Set<String> variations = {query};

    // Handle ன (Nna - Alveolar) vs ந (Na - Dental) mismatch
    // These are often confused in spelling (e.g., Palani: பழனி vs பழநி)
    if (query.contains('ன')) {
      variations.add(query.replaceAll('ன', 'ந'));
    }
    if (query.contains('ந')) {
      variations.add(query.replaceAll('ந', 'ன'));
    }

    // We could add more here (ra/Ra, la/La/zha) if needed later.

    return variations.toList();
  }

  /// Ordered find/replace pairs collapsing the formal scholarly
  /// transliteration scheme used throughout `english_venue` (and
  /// elsewhere) toward a casual "Tanglish" spelling -- e.g.
  /// "thiruchchendhUr" -> "tiruchendur", matching how most people would
  /// actually type Thiruchendur. Order matters: digraph-doubling and
  /// single-letter-doubling collapse first, so a later single-letter rule
  /// (like th -> t) doesn't interfere with an earlier digraph rule (like
  /// thth -> th). Verified against every temple name currently in the
  /// bundled database (see PR description / commit message for the check
  /// script) -- every entry's own casually-simplified spelling matches
  /// itself after normalization.
  static const List<List<String>> _tanglishNormalizationRules = [
    ['chch', 'ch'],
    ['thth', 'th'],
    ['dhdh', 'dh'],
    ['shsh', 'sh'],
    ['aa', 'a'],
    ['ee', 'e'],
    ['kk', 'k'],
    ['ll', 'l'],
    ['mm', 'm'],
    ['nn', 'n'],
    ['pp', 'p'],
    ['tt', 't'],
    ['uu', 'u'],
    ['dh', 'd'],
    // zh (ழ) is very commonly typed as a plain "l" rather than "zh"/"z"
    // (e.g. Palani for பழநி, "pazhani"), so both collapse to the same
    // letter for matching purposes.
    ['zh', 'l'],
    ['th', 't'],
    ['ngk', 'nk'],
    ['ng', 'n'],
  ];

  /// Applies [_tanglishNormalizationRules] to a Dart string -- used to
  /// normalize the incoming search query. See [tanglishNormalizedSql]
  /// for the equivalent transformation applied to a database column.
  static String normalizeTanglish(String s) {
    var result = s.toLowerCase();
    for (final rule in _tanglishNormalizationRules) {
      result = result.replaceAll(rule[0], rule[1]);
    }
    return result;
  }

  /// Builds a SQL expression that applies [_tanglishNormalizationRules]
  /// to [column] via chained `REPLACE()` calls, so it can be compared
  /// against a query already normalized by [normalizeTanglish]. SQLite
  /// has no regex support, but every rule here is a plain substring
  /// replacement, so a REPLACE() chain is exact.
  static String tanglishNormalizedSql(String column) {
    var expr = 'LOWER($column)';
    for (final rule in _tanglishNormalizationRules) {
      expr = "REPLACE($expr, '${rule[0]}', '${rule[1]}')";
    }
    return expr;
  }

  /// Trims and length-limits the search query.
  /// SQL injection is prevented by parameterised queries (whereArgs),
  /// not by character removal.
  static String sanitizeQuery(String query) {
    final trimmed = query.trim();
    if (trimmed.length > AppConstants.maxSearchQueryLength) {
      return trimmed.substring(0, AppConstants.maxSearchQueryLength);
    }
    return trimmed;
  }
}
