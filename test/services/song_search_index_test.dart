import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:thiruppugazh/services/song_search_index.dart';

SongSearchEntry _entry(
  int id, {
  String kaumaramId = '',
  String title = '',
  String englishTitle = '',
  String head = '',
  String englishHead = '',
}) => SongSearchEntry(
  id: id,
  kaumaramId: kaumaramId.isEmpty ? '$id' : kaumaramId,
  titleLower: title.toLowerCase(),
  englishTitleLower: englishTitle.toLowerCase(),
  titleTamil: SongSearchIndex.foldTamil(title),
  titleLatin: SongSearchIndex.foldLatin(englishTitle),
  headTamil: SongSearchIndex.foldTamil(head),
  headLatin: SongSearchIndex.foldLatin(englishHead),
);

void main() {
  group('foldLatin', () {
    test('ignores case, spacing and punctuation', () {
      expect(SongSearchIndex.foldLatin('Muthaith Tharu'), 'mutaitaru');
      expect(SongSearchIndex.foldLatin(' a-b, c '), 'aps');
    });

    test('merges casual and scholarly spellings', () {
      // thiruppugazh / tiruppukal / thirupugazh
      final a = SongSearchIndex.foldLatin('thiruppugazh');
      expect(SongSearchIndex.foldLatin('thirupugazh'), a);
      expect(SongSearchIndex.foldLatin('tirupukal'), a);
      // dh / th, zh / l, long-vowel capitals
      expect(
        SongSearchIndex.foldLatin('dhinam'),
        SongSearchIndex.foldLatin('thinam'),
      );
      expect(
        SongSearchIndex.foldLatin('kAyam'),
        SongSearchIndex.foldLatin('kayam'),
      );
      expect(
        SongSearchIndex.foldLatin('mangkaiyar'),
        SongSearchIndex.foldLatin('mangaiyar'),
      );
    });
  });

  group('foldTamil', () {
    test('merges easily-confused letters and drops spacing', () {
      expect(
        SongSearchIndex.foldTamil('பழனி'),
        SongSearchIndex.foldTamil('பழநி'),
      );
      expect(
        SongSearchIndex.foldTamil('அருக்கு மங்கையர்'),
        SongSearchIndex.foldTamil('அருக்குமங்கையர்'),
      );
      expect(
        SongSearchIndex.foldTamil('கறை'),
        SongSearchIndex.foldTamil('கரை'),
      );
    });
  });

  group('transliterateTamil', () {
    test('romanizes closely enough to match casual typing', () {
      String fold(String tamil) =>
          SongSearchIndex.foldLatin(SongSearchIndex.transliterateTamil(tamil));
      expect(fold('முத்தைத்தரு'), SongSearchIndex.foldLatin('muthaitharu'));
      expect(fold('கைத்தல நிறைகனி'), SongSearchIndex.foldLatin('kaithala niraikani'));
      expect(fold('திருப்புகழ்'), SongSearchIndex.foldLatin('thirupugazh'));
      expect(fold('அருக்கு மங்கையர்'), SongSearchIndex.foldLatin('arukku mangaiyar'));
    });

    test('a song with no English data is found by English letters', () {
      final index = SongSearchIndex.fromRows([
        {
          'id': 6,
          'kaumaram_id': '6',
          'title': 'முத்தைத்தரு',
          'english_title': null,
          'lyrics_list_head': '["முத்தைத் தரு பத்தித் திருநகை", "x"]',
          'english_lyrics_list_head': null,
        },
      ]);
      expect(index.rank('muthaitharu'), [6]);
      expect(index.rank('muththai tharu paththi'), [6]);
    });
  });

  group('rank', () {
    final index = SongSearchIndex([
      _entry(1, title: 'முத்தைத்தரு', englishTitle: 'muththaith tharu',
          head: 'முத்தைத் தரு பத்தித் திருநகை', englishHead: 'muththaith tharu paththith thirunagai'),
      _entry(2, title: 'அருக்கு மங்கையர்', englishTitle: 'arukku mangkaiyar',
          head: 'அருக்கு மங்கையர் மலரடி', englishHead: 'arukku mangaiyar malaradi'),
      _entry(3, title: 'கைத்தல நிறைகனி', englishTitle: 'kaiththala niRaikani',
          head: 'கைத்தல நிறைகனி அப்பமொடவல்பொரி', englishHead: 'kaiththala niRaikani appamodavalpori'),
      _entry(40, kaumaramId: '0040', title: 'வேறொரு பாடல்', englishTitle: 'vERoru paadal',
          head: 'உனைத் தினம் தொழுதிலன்', englishHead: 'unaith dhinam thOzhudhilan'),
    ]);

    test('a number finds that song first', () {
      expect(index.rank('40').first, 40);
      expect(index.rank('1').first, 1);
    });

    test('a casually spelled title matches', () {
      expect(index.rank('muthaitharu').first, 1);
      expect(index.rank('kaithala nirai').first, 3);
      expect(index.rank('arukku mangaiyar').first, 2);
    });

    test('opening words match even when they are not in the title', () {
      expect(index.rank('unaith dhinam').first, 40);
      expect(index.rank('unaithinam').first, 40);
    });

    test('Tamil spelling variants match', () {
      expect(index.rank('அருக்குமங்கையர்').first, 2);
      expect(index.rank('முத்தைதரு'), isNot(contains(2)));
    });

    test('words in any order match', () {
      expect(index.rank('niRaikani kaithala'), contains(3));
    });

    test('a title match outranks an opening-lines match', () {
      final idx = SongSearchIndex([
        _entry(1, title: 'அ', englishTitle: 'zzz', englishHead: 'tharu first line'),
        _entry(2, title: 'ஆ', englishTitle: 'tharu song', englishHead: 'other'),
      ]);
      expect(idx.rank('tharu'), [2, 1]);
    });

    test('respects the title / lyrics filters', () {
      expect(index.rank('unaith dhinam', searchLyrics: false), isEmpty);
      expect(index.rank('muthaitharu', searchTitle: false).first, 1);
    });

    test('too-short and empty queries do not rank', () {
      expect(index.rank(''), isEmpty);
      expect(index.rank('   '), isEmpty);
      expect(index.rank('a'), isEmpty);
    });
  });

  // Measures the ranking against the real bundled songs: type each song's
  // title, and its first words, the way a person would, and see whether the
  // song comes back near the top.
  group('against the bundled songs', () {
    late SongSearchIndex index;
    late List<Map<String, Object?>> rows;

    setUpAll(() async {
      sqfliteFfiInit();
      final db = await databaseFactoryFfi.openDatabase(
        File('assets/thiruppugazh.db').absolute.path,
        options: OpenDatabaseOptions(readOnly: true),
      );
      rows = await db.rawQuery('''
        SELECT id, kaumaram_id, title, english_title,
               substr(lyrics_list, 1, 400) AS lyrics_list_head,
               substr(english_lyrics_list, 1, 400) AS english_lyrics_list_head
        FROM songs
      ''');
      await db.close();
      index = SongSearchIndex.fromRows(rows);
    });

    /// Fraction of [cases] (id -> query) whose song is within [topN].
    double hitRate(Map<int, String> cases, int topN) {
      var hits = 0;
      for (final e in cases.entries) {
        if (index.rank(e.value).take(topN).contains(e.key)) hits++;
      }
      return hits / cases.length;
    }

    test('index covers every song', () {
      expect(index.entries.length, rows.length);
    });

    test('typing a song number finds that song first', () {
      for (final id in [1, 7, 340, 555, 1000, 1340]) {
        final ranked = index.rank('$id');
        expect(ranked, isNotEmpty, reason: 'id $id');
        expect(ranked.first, id, reason: 'id $id');
      }
    });

    test('English titles, typed in lower case', () {
      final cases = <int, String>{
        for (final r in rows)
          if ((r['english_title'] as String?)?.trim().isNotEmpty ?? false)
            r['id'] as int: (r['english_title'] as String).toLowerCase(),
      };
      final rate = hitRate(cases, 10);
      // ignore: avoid_print
      print('English title in top 10: ${(rate * 100).toStringAsFixed(1)}% of ${cases.length}');
      expect(rate, greaterThan(0.9));
    });

    test('English titles typed with no spaces and plain spellings', () {
      final cases = <int, String>{
        for (final r in rows)
          if ((r['english_title'] as String?)?.trim().isNotEmpty ?? false)
            r['id'] as int: (r['english_title'] as String)
                .toLowerCase()
                .replaceAll(' ', '')
                .replaceAll('dh', 'th')
                .replaceAll('zh', 'l'),
      };
      final rate = hitRate(cases, 10);
      // ignore: avoid_print
      print('Casual English title in top 10: ${(rate * 100).toStringAsFixed(1)}%');
      expect(rate, greaterThan(0.85));
    });

    test('Tamil titles', () {
      final cases = <int, String>{
        for (final r in rows)
          if ((r['title'] as String?)?.trim().isNotEmpty ?? false)
            r['id'] as int: (r['title'] as String).trim(),
      };
      final rate = hitRate(cases, 10);
      // ignore: avoid_print
      print('Tamil title in top 10: ${(rate * 100).toStringAsFixed(1)}%');
      expect(rate, greaterThan(0.9));
    });

    test('Tamil titles typed without spaces', () {
      final cases = <int, String>{
        for (final r in rows)
          if ((r['title'] as String?)?.trim().isNotEmpty ?? false)
            r['id'] as int: (r['title'] as String).replaceAll(' ', ''),
      };
      final rate = hitRate(cases, 10);
      // ignore: avoid_print
      print('Tamil title without spaces in top 10: ${(rate * 100).toStringAsFixed(1)}%');
      expect(rate, greaterThan(0.9));
    });

    test('the first words of the opening line, spelled casually', () {
      final cases = <int, String>{};
      for (final r in rows) {
        final head = r['english_lyrics_list_head'] as String?;
        if (head == null) continue;
        final m = RegExp(r'"([^"]*)"').firstMatch(head);
        if (m == null) continue;
        final words = m.group(1)!.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
        if (words.length < 3) continue;
        cases[r['id'] as int] = words
            .take(3)
            .join('')
            .toLowerCase()
            .replaceAll('dh', 'th')
            .replaceAll('zh', 'l');
      }
      final rate = hitRate(cases, 10);
      // ignore: avoid_print
      print('Casual first 3 words in top 10: ${(rate * 100).toStringAsFixed(1)}% of ${cases.length}');
      expect(rate, greaterThan(0.9));
    });

    test('the first words of the opening line', () {
      final cases = <int, String>{};
      for (final r in rows) {
        final head = r['english_lyrics_list_head'] as String?;
        if (head == null) continue;
        final m = RegExp(r'"([^"]*)"').firstMatch(head);
        if (m == null) continue;
        final words = m.group(1)!.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
        if (words.length < 3) continue;
        cases[r['id'] as int] = words.take(3).join(' ').toLowerCase();
      }
      final rate = hitRate(cases, 10);
      // ignore: avoid_print
      print('First 3 words of the opening line in top 10: ${(rate * 100).toStringAsFixed(1)}% of ${cases.length}');
      expect(rate, greaterThan(0.9));
    });

    test('songs with no English data are found by English letters', () {
      int idOf(String title) =>
          rows.firstWhere((r) => (r['title'] as String).trim() == title)['id'] as int;
      final muthaithTharu = idOf('முத்தைத்தரு');
      final kaithalaNirai = idOf('கைத்தல நிறைகனி');
      expect(index.rank('muthaitharu').take(3), contains(muthaithTharu));
      expect(index.rank('kaithala nirai').take(3), contains(kaithalaNirai));
      expect(index.rank('kaithalanirai').take(3), contains(kaithalaNirai));
    });

    test('search stays fast', () {
      final stopwatch = Stopwatch()..start();
      for (var i = 0; i < 50; i++) {
        index.rank('thiruppugazh murugan');
      }
      stopwatch.stop();
      // ignore: avoid_print
      print('50 searches over ${index.entries.length} songs: ${stopwatch.elapsedMilliseconds} ms');
      expect(stopwatch.elapsedMilliseconds, lessThan(2000));
    });

    test('JSON heads are parsed (sanity)', () {
      expect(jsonEncode(rows.first).isNotEmpty, isTrue);
    });
  });
}
