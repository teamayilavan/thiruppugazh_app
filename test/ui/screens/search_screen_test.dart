import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thiruppugazh/constants/app_constants.dart';
import 'package:thiruppugazh/data/models/search_filter.dart';
import 'package:thiruppugazh/data/models/song_model.dart';
import 'package:thiruppugazh/data/repositories/song_repository.dart';
import 'package:thiruppugazh/l10n/app_localizations.dart';
import 'package:thiruppugazh/providers/lyrics_language_provider.dart';
import 'package:thiruppugazh/theme/app_theme.dart';
import 'package:thiruppugazh/ui/screens/search_screen.dart';
import 'package:thiruppugazh/ui/widgets/adaptive_layout.dart';

Song _song(int id, String title, List<String> lyrics) => Song(
  id: id,
  kaumaramId: '$id',
  title: title,
  place: 'Place $id',
  tune: '',
  lyrics: '',
  lyricsList: lyrics,
  tuneList: const [],
  words: const [],
  meanings: const [],
  pathavurai: '',
  patham: const [],
);

class _SearchRepo extends SongRepository {
  final List<Song> songs = [
    _song(10, 'Alpha Song', ['the peacock dances at dawn']),
    _song(11, 'Bravo Song', ['a different line']),
  ];

  @override
  Future<List<Song>> searchSongsWithFilter(SearchFilter filter) async {
    final q = filter.query.toLowerCase();
    return songs
        .where(
          (s) =>
              s.title.toLowerCase().contains(q) ||
              s.lyricsList.any((l) => l.toLowerCase().contains(q)),
        )
        .toList();
  }
}

/// The song the search screen last asked to open.
Song? _opened;

Future<void> _open(
  WidgetTester tester, {
  Map<String, Object> prefs = const {},
}) async {
  SharedPreferences.setMockInitialValues(prefs);
  _opened = null;
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<SongRepository>.value(value: _SearchRepo()),
        ChangeNotifierProvider(create: (_) => LyricsLanguageProvider()),
      ],
      child: MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        theme: lightTheme,
        // A pane that just records the song, so no real song page is built.
        home: SongPaneScope(
          selectedSongId: null,
          onOpen: (song) => _opened = song,
          child: const SearchScreen(),
        ),
      ),
    ),
  );
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 30)),
  );
  await tester.pump(const Duration(milliseconds: 100));
}

Future<void> _type(WidgetTester tester, String text) async {
  await tester.enterText(find.byType(TextField), text);
  await tester.pump(const Duration(seconds: 1)); // debounce
  await tester.pumpAndSettle();
}

AppLocalizations _l10n(WidgetTester tester) =>
    AppLocalizations.of(tester.element(find.byType(Scaffold).first))!;

void main() {
  testWidgets('a song found by its lyrics shows the matching line', (
    tester,
  ) async {
    await _open(tester);
    await _type(tester, 'peacock');
    expect(find.text('Alpha Song'), findsOneWidget);
    // The line is shown with the matched word in bold: a rich text.
    expect(
      find.byWidgetPredicate(
        (w) =>
            w is RichText &&
            w.text.toPlainText() == 'the peacock dances at dawn',
      ),
      findsOneWidget,
    );
  });

  testWidgets('a song found by its title shows no extra line', (tester) async {
    await _open(tester);
    await _type(tester, 'alpha');
    expect(find.text('Alpha Song'), findsOneWidget);
    expect(find.textContaining('peacock'), findsNothing);
  });

  group('recent searches', () {
    testWidgets('nothing is offered before the first search', (tester) async {
      await _open(tester);
      expect(find.text(_l10n(tester).recentSearches), findsNothing);
      expect(find.text(_l10n(tester).startTypingToSearch), findsOneWidget);
    });

    testWidgets('opening a result remembers the search', (tester) async {
      await _open(tester);
      await _type(tester, 'peacock');
      await tester.tap(find.text('Alpha Song'));
      await tester.pumpAndSettle();
      expect(_opened?.id, 10);
      final saved = await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 50));
        return (await SharedPreferences.getInstance()).getString(
          AppConstants.recentSearchesPrefsKey,
        );
      });
      expect(saved, contains('peacock'));
    });

    testWidgets('typing alone does not record anything', (tester) async {
      await _open(tester);
      await _type(tester, 'peacock');
      final saved = (await SharedPreferences.getInstance()).getString(
        AppConstants.recentSearchesPrefsKey,
      );
      expect(saved, isNull);
    });

    testWidgets('saved searches are listed and run again when tapped', (
      tester,
    ) async {
      await _open(
        tester,
        prefs: {AppConstants.recentSearchesPrefsKey: '["peacock","bravo"]'},
      );
      final l10n = _l10n(tester);
      expect(find.text(l10n.recentSearches), findsOneWidget);
      expect(find.text('peacock'), findsOneWidget);
      expect(find.text('bravo'), findsOneWidget);

      await tester.tap(find.text('bravo'));
      await tester.pumpAndSettle();
      expect(find.text('Bravo Song'), findsOneWidget);
      expect(find.text(l10n.recentSearches), findsNothing);
    });

    testWidgets('they can be cleared', (tester) async {
      await _open(
        tester,
        prefs: {AppConstants.recentSearchesPrefsKey: '["peacock"]'},
      );
      final l10n = _l10n(tester);
      await tester.tap(find.text(l10n.clearRecentSearches));
      await tester.pumpAndSettle();
      expect(find.text('peacock'), findsNothing);
      expect(find.text(l10n.startTypingToSearch), findsOneWidget);
    });
  });
}
