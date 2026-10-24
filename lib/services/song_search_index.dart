/// An in-memory index of every song's title and opening lines, used to rank
/// search results so the song a person means comes first -- by number, by
/// title, or by the first words they remember -- however they spell it.
///
/// The full-text database search still handles everything deeper (rest of
/// the lyrics, meanings, temples, tunes); this only decides the top of the
/// list. It is small (title plus two lines per song) and built once.
class SongSearchEntry {
  const SongSearchEntry({
    required this.id,
    required this.kaumaramId,
    required this.titleLower,
    required this.englishTitleLower,
    required this.titleTamil,
    required this.titleLatin,
    required this.headTamil,
    required this.headLatin,
  });

  final int id;
  final String kaumaramId;

  /// Lower-cased, unfolded titles, for an exact-prefix match.
  final String titleLower;
  final String englishTitleLower;

  /// Folded forms (spacing and punctuation removed, easily-confused letters
  /// merged) of the title and of the first two lyric lines.
  final String titleTamil;
  final String titleLatin;
  final String headTamil;
  final String headLatin;
}

class SongSearchIndex {
  SongSearchIndex(this.entries);

  final List<SongSearchEntry> entries;

  /// Builds the index from rows with the columns `id`, `kaumaram_id`,
  /// `title`, `english_title`, `lyrics_list_head` and
  /// `english_lyrics_list_head` (the last two are the first few hundred
  /// characters of the JSON lyric lists).
  factory SongSearchIndex.fromRows(List<Map<String, Object?>> rows) {
    final entries = <SongSearchEntry>[];
    for (final row in rows) {
      final id = row['id'];
      if (id is! int) continue;
      final title = (row['title'] as String?) ?? '';
      final englishTitle = (row['english_title'] as String?) ?? '';
      final tamilHead = _firstLines(row['lyrics_list_head'] as String?);
      final englishHead = _firstLines(
        row['english_lyrics_list_head'] as String?,
      );
      entries.add(
        SongSearchEntry(
          id: id,
          kaumaramId: ((row['kaumaram_id'] as String?) ?? '').trim(),
          titleLower: title.trim().toLowerCase(),
          englishTitleLower: englishTitle.trim().toLowerCase(),
          titleTamil: foldTamil(title),
          // A few songs (including some of the best known) have no English
          // transliteration in the data. Romanize their Tamil on the fly so
          // typing in English letters can still find them.
          titleLatin: foldLatin(
            englishTitle.trim().isNotEmpty
                ? englishTitle
                : transliterateTamil(title),
          ),
          headTamil: foldTamil(tamilHead),
          headLatin: foldLatin(
            englishHead.trim().isNotEmpty
                ? englishHead
                : transliterateTamil(tamilHead),
          ),
        ),
      );
    }
    return SongSearchIndex(entries);
  }

  static final RegExp _quoted = RegExp(r'"([^"]*)"');

  /// The first two entries of a JSON string list, joined, tolerating a head
  /// that was cut off mid-way through the third.
  static String _firstLines(String? jsonHead) {
    if (jsonHead == null) return '';
    return _quoted
        .allMatches(jsonHead)
        .take(2)
        .map((m) => m.group(1) ?? '')
        .join(' ');
  }

  // --- Folding -----------------------------------------------------------

  static final RegExp _tamilChar = RegExp(r'[஀-௿]');
  static final RegExp _latinLetter = RegExp(r'[a-zA-Z]');
  static final RegExp _keepLetters = RegExp(r'[^\p{L}\p{M}\p{N}]', unicode: true);
  static final RegExp _keepAlnum = RegExp(r'[^a-z0-9]');
  static final RegExp _repeats = RegExp(r'(.)\1+');

  /// Tamil letters people routinely mix up in spelling, mapped to one
  /// representative each: ன ண ந, ர ற, ல ள ழ, and the grantha sibilants.
  static const Map<String, String> _tamilFold = {
    'ன': 'ந', 'ண': 'ந',
    'ற': 'ர',
    'ள': 'ல', 'ழ': 'ல',
    'ஜ': 'ச', 'ஷ': 'ச', 'ஸ': 'ச',
  };

  /// Ordered rewrites that collapse casual and scholarly Roman spellings of
  /// Tamil toward one form (Tamil does not distinguish voiced/unvoiced
  /// stops, so d/t, b/p, g/k, j/s/ch all merge). Case is ignored first, so
  /// the long-vowel capitals in the bundled transliteration (kAyam) already
  /// match plain typing (kayam).
  static const List<List<String>> _latinRules = [
    ['zh', 'l'],
    ['z', 'l'],
    ['ee', 'i'],
    ['oo', 'u'],
    ['sh', 's'],
    ['ch', 's'],
    ['th', 't'],
    ['dh', 't'],
    ['bh', 'p'],
    ['kh', 'k'],
    ['gh', 'k'],
    ['j', 's'],
    ['c', 's'],
    ['d', 't'],
    ['b', 'p'],
    ['g', 'k'],
    ['w', 'v'],
    ['q', 'k'],
  ];

  static const Map<String, String> _vowels = {
    'அ': 'a', 'ஆ': 'aa', 'இ': 'i', 'ஈ': 'ii', 'உ': 'u', 'ஊ': 'uu',
    'எ': 'e', 'ஏ': 'ee', 'ஐ': 'ai', 'ஒ': 'o', 'ஓ': 'oo', 'ஔ': 'au',
  };

  static const Map<String, String> _signs = {
    'ா': 'aa', 'ி': 'i', 'ீ': 'ii', 'ு': 'u', 'ூ': 'uu',
    'ெ': 'e', 'ே': 'ee', 'ை': 'ai', 'ொ': 'o', 'ோ': 'oo', 'ௌ': 'au',
  };

  static const Map<String, String> _consonants = {
    'க': 'k', 'ங': 'ng', 'ச': 'ch', 'ஞ': 'nj', 'ட': 't', 'ண': 'n',
    'த': 'th', 'ந': 'n', 'ப': 'p', 'ம': 'm', 'ய': 'y', 'ர': 'r',
    'ல': 'l', 'வ': 'v', 'ழ': 'zh', 'ள': 'l', 'ற': 'r', 'ன': 'n',
    'ஜ': 'j', 'ஷ': 'sh', 'ஸ': 's', 'ஹ': 'h',
  };

  static const String _pulli = '்';

  /// A rough Tamil-to-Roman transliteration, good enough to be [foldLatin]ed
  /// and compared with what someone types -- not meant to be read.
  static String transliterateTamil(String input) {
    final chars = input.runes.map(String.fromCharCode).toList();
    final out = StringBuffer();
    for (var i = 0; i < chars.length; i++) {
      final ch = chars[i];
      final consonant = _consonants[ch];
      if (consonant != null) {
        out.write(consonant);
        final next = i + 1 < chars.length ? chars[i + 1] : '';
        if (next == _pulli) {
          i++; // bare consonant
        } else if (_signs.containsKey(next)) {
          out.write(_signs[next]);
          i++;
        } else {
          out.write('a'); // inherent vowel
        }
      } else if (_vowels.containsKey(ch)) {
        out.write(_vowels[ch]);
      } else if (ch == 'ஃ') {
        out.write('k');
      } else if (!_signs.containsKey(ch) && ch != _pulli) {
        out.write(ch); // spaces, punctuation, Latin letters pass through
      }
    }
    return out.toString();
  }

  /// Folds Tamil-script text for matching: drops spacing/punctuation and
  /// merges easily-confused letters.
  static String foldTamil(String input) {
    final stripped = input.replaceAll(_keepLetters, '');
    final out = StringBuffer();
    for (final rune in stripped.runes) {
      final ch = String.fromCharCode(rune);
      out.write(_tamilFold[ch] ?? ch);
    }
    return out.toString();
  }

  /// Folds Roman-letter text for matching (see [_latinRules]).
  static String foldLatin(String input) {
    var s = input.toLowerCase();
    for (final rule in _latinRules) {
      s = s.replaceAll(rule[0], rule[1]);
    }
    s = s.replaceAll(_keepAlnum, '');
    // Doubled letters (arukku/aruku, muththai/muthai) read the same.
    return s.replaceAllMapped(_repeats, (m) => m.group(1)!);
  }

  // --- Ranking -----------------------------------------------------------

  static const int _maxResults = 50;

  /// Song ids, best match first, for [query]. Empty when the query is too
  /// short to rank meaningfully (the database search still covers it).
  ///
  /// Tiers, best first: the song's number; the title starts with what was
  /// typed; the title starts with it after folding; the title contains it;
  /// the opening lines start with / contain it; every typed word appears
  /// somewhere in the title or opening lines, in any order.
  List<int> rank(
    String query, {
    bool searchTitle = true,
    bool searchLyrics = true,
  }) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const [];

    final isNumber = RegExp(r'^\d+$').hasMatch(q);
    final number = isNumber ? int.tryParse(q) : null;

    final hasTamil = _tamilChar.hasMatch(q);
    final hasLatin = _latinLetter.hasMatch(q);
    final qTamil = hasTamil ? foldTamil(q) : '';
    final qLatin = hasLatin ? foldLatin(q) : '';
    final canFold = qTamil.length >= 2 || qLatin.length >= 2;
    if (!isNumber && !canFold) return const [];

    final tokens = query
        .trim()
        .split(RegExp(r'\s+'))
        .where((t) => t.isNotEmpty)
        .toList();
    final tokensTamil = [
      for (final t in tokens)
        if (hasTamil) foldTamil(t),
    ].where((t) => t.isNotEmpty).toList();
    final tokensLatin = [
      for (final t in tokens)
        if (hasLatin) foldLatin(t),
    ].where((t) => t.isNotEmpty).toList();

    final scored = <(int tier, int id)>[];
    for (final e in entries) {
      final tier = _tierFor(
        e,
        q: q,
        number: number,
        qTamil: qTamil,
        qLatin: qLatin,
        tokensTamil: tokensTamil,
        tokensLatin: tokensLatin,
        searchTitle: searchTitle,
        searchLyrics: searchLyrics,
      );
      if (tier != null) scored.add((tier, e.id));
    }

    scored.sort((a, b) {
      final byTier = a.$1.compareTo(b.$1);
      return byTier != 0 ? byTier : a.$2.compareTo(b.$2);
    });
    return [for (final s in scored.take(_maxResults)) s.$2];
  }

  int? _tierFor(
    SongSearchEntry e, {
    required String q,
    required int? number,
    required String qTamil,
    required String qLatin,
    required List<String> tokensTamil,
    required List<String> tokensLatin,
    required bool searchTitle,
    required bool searchLyrics,
  }) {
    if (number != null) {
      final own = int.tryParse(e.kaumaramId);
      return (e.id == number || own == number) ? 0 : null;
    }

    if (searchTitle) {
      if (e.titleLower.startsWith(q) || e.englishTitleLower.startsWith(q)) {
        return 1;
      }
      if ((qTamil.length >= 2 && e.titleTamil.startsWith(qTamil)) ||
          (qLatin.length >= 2 && e.titleLatin.startsWith(qLatin))) {
        return 2;
      }
      if ((qTamil.length >= 2 && e.titleTamil.contains(qTamil)) ||
          (qLatin.length >= 2 && e.titleLatin.contains(qLatin))) {
        return 3;
      }
    }

    if (searchLyrics) {
      if ((qTamil.length >= 2 && e.headTamil.startsWith(qTamil)) ||
          (qLatin.length >= 2 && e.headLatin.startsWith(qLatin))) {
        return 4;
      }
      if ((qTamil.length >= 2 && e.headTamil.contains(qTamil)) ||
          (qLatin.length >= 2 && e.headLatin.contains(qLatin))) {
        return 5;
      }
    }

    // Several words, in any order, across the title and opening lines.
    if ((searchTitle || searchLyrics) &&
        (tokensTamil.length > 1 || tokensLatin.length > 1)) {
      final tamilBlob =
          '${searchTitle ? e.titleTamil : ''}${searchLyrics ? e.headTamil : ''}';
      final latinBlob =
          '${searchTitle ? e.titleLatin : ''}${searchLyrics ? e.headLatin : ''}';
      if ((tokensTamil.length > 1 && tokensTamil.every(tamilBlob.contains)) ||
          (tokensLatin.length > 1 && tokensLatin.every(latinBlob.contains))) {
        return 6;
      }
    }
    return null;
  }
}
