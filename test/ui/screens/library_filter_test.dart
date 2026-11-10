import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thiruppugazh/data/repositories/song_repository.dart';
import 'package:thiruppugazh/l10n/app_localizations.dart';
import 'package:thiruppugazh/providers/lyrics_language_provider.dart';
import 'package:thiruppugazh/theme/app_theme.dart';
import 'package:thiruppugazh/ui/screens/highlights_notes_screen.dart';
import 'package:thiruppugazh/ui/widgets/adaptive_layout.dart';
import 'package:thiruppugazh/ui/widgets/library_filter.dart';

import '../../support/fake_song_repo.dart';

class _LibraryRepo extends FakeSongRepo {
  _LibraryRepo(this.count);
  final int count;

  List<Map<String, dynamic>> get _notes => [
    for (var i = 1; i <= count; i++)
      {
        'id': i,
        'song_id': i,
        'song_title': i == 3 ? 'Charlie Song' : 'Song $i',
        'content': i == 5 ? 'a reflection on dawn' : 'note $i',
        'created_at': '2026-01-01',
        'updated_at': '2026-01-01',
      },
  ];

  @override
  Future<List<Map<String, dynamic>>> getNotesWithSongs() async => _notes;
}

Future<void> _open(
  WidgetTester tester,
  int count, {
  int? selectedSongId,
}) async {
  SharedPreferences.setMockInitialValues({});
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<SongRepository>.value(
          value: _LibraryRepo(count),
        ),
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
        home: SongPaneScope(
          selectedSongId: selectedSongId,
          onOpen: (_) {},
          child: const HighlightsNotesScreen(),
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
  // Go to the Notes tab.
  final l10n = AppLocalizations.of(
    tester.element(find.byType(Scaffold).first),
  )!;
  await tester.tap(find.text(l10n.notes));
  await tester.pumpAndSettle();
}

void main() {
  group('filterLibraryRows', () {
    final rows = [
      {'a': 'Alpha', 'b': 'one'},
      {'a': 'Bravo', 'b': 'two'},
      {'a': 'Charlie', 'b': null},
    ];

    test('an empty filter keeps everything', () {
      expect(filterLibraryRows(rows, '  ', ['a']), rows);
    });

    test('matches any of the keys, ignoring case', () {
      expect(filterLibraryRows(rows, 'BRAV', ['a']), [rows[1]]);
      expect(filterLibraryRows(rows, 'two', ['a', 'b']), [rows[1]]);
    });

    test('copes with missing text', () {
      expect(filterLibraryRows(rows, 'x', ['b']), isEmpty);
    });
  });

  group('the filter box', () {
    testWidgets('is not shown while the list is short', (tester) async {
      await _open(tester, libraryFilterThreshold - 1);
      expect(find.byType(TextField), findsNothing);
    });

    testWidgets('appears once the list has grown, and narrows it', (
      tester,
    ) async {
      await _open(tester, libraryFilterThreshold + 2);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Charlie Song'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'charlie');
      await tester.pumpAndSettle();
      expect(find.text('Charlie Song'), findsOneWidget);
      expect(find.text('Song 1'), findsNothing);
    });

    testWidgets('also searches the note text', (tester) async {
      await _open(tester, libraryFilterThreshold + 2);
      await tester.enterText(find.byType(TextField), 'dawn');
      await tester.pumpAndSettle();
      expect(find.text('Song 5'), findsOneWidget);
      expect(find.text('Song 1'), findsNothing);
    });

    testWidgets('says so when nothing matches', (tester) async {
      await _open(tester, libraryFilterThreshold + 2);
      await tester.enterText(find.byType(TextField), 'zzzzz');
      await tester.pumpAndSettle();
      final l10n = AppLocalizations.of(
        tester.element(find.byType(Scaffold).first),
      )!;
      expect(find.text(l10n.noResultsFound), findsOneWidget);
    });
  });

  group('the open song in the reading pane', () {
    testWidgets('its row is highlighted in the Library', (tester) async {
      await _open(tester, 4, selectedSongId: 3);
      final tiles = tester.widgetList<ListTile>(find.byType(ListTile)).toList();
      final marked = tiles.where((t) => t.tileColor != null).toList();
      expect(marked, hasLength(1));
      expect((marked.single.title as Text).data, 'Charlie Song');
    });

    testWidgets('no row is highlighted without a pane selection', (
      tester,
    ) async {
      await _open(tester, 4);
      final tiles = tester.widgetList<ListTile>(find.byType(ListTile));
      expect(tiles.where((t) => t.tileColor != null), isEmpty);
    });
  });
}
