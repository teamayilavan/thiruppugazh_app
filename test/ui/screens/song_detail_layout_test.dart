import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thiruppugazh/data/repositories/song_repository.dart';
import 'package:thiruppugazh/l10n/app_localizations.dart';
import 'package:thiruppugazh/providers/lyrics_font_size_provider.dart';
import 'package:thiruppugazh/providers/lyrics_language_provider.dart';
import 'package:thiruppugazh/providers/reading_state_provider.dart';
import 'package:thiruppugazh/theme/app_theme.dart';
import 'package:thiruppugazh/ui/screens/song_detail_screen.dart';

import '../../support/fake_song_repo.dart';

Future<void> _pump(
  WidgetTester tester,
  Size size, {
  String language = 'en',
  bool recordOpened = true,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  SharedPreferences.setMockInitialValues({});

  final reading = ReadingStateProvider();
  await tester.runAsync(() => reading.ready);

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<SongRepository>.value(value: FakeSongRepo()),
        ChangeNotifierProvider(create: (_) => LyricsFontSizeProvider()),
        ChangeNotifierProvider(create: (_) => LyricsLanguageProvider()),
        ChangeNotifierProvider.value(value: reading),
      ],
      child: MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        locale: Locale(language),
        theme: lightTheme,
        home: SongDetailScreen(
          song: testSong(
            3,
            'Charlie Song',
            words: const ['word one', 'word two'],
            meanings: const ['meaning one', 'meaning two'],
          ),
          recordOpened: recordOpened,
        ),
      ),
    ),
  );
  for (var i = 0; i < 4; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  group('song page columns', () {
    // Lyrics and meanings sit side by side only on a tablet-sized window that
    // is wide enough; the divider between the columns is the tell.
    testWidgets('two columns on a wide tablet', (tester) async {
      await _pump(tester, const Size(1000, 1200));
      expect(find.byType(VerticalDivider), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('one column on a narrower tablet', (tester) async {
      await _pump(tester, const Size(700, 1200));
      expect(find.byType(VerticalDivider), findsNothing);
    });

    testWidgets('one column on a phone held upright', (tester) async {
      await _pump(tester, const Size(400, 800));
      expect(find.byType(VerticalDivider), findsNothing);
    });

    testWidgets('one column on a phone held sideways, however wide', (
      tester,
    ) async {
      // Wide but short: not a large screen, so it stays a single column.
      await _pump(tester, const Size(900, 400));
      expect(find.byType(VerticalDivider), findsNothing);
    });

    for (final language in const ['en', 'ta']) {
      for (final size in const [
        Size(1000, 1200),
        Size(700, 1200),
        Size(400, 800),
      ]) {
        testWidgets('no overflow at ${size.width.toInt()} wide, $language', (
          tester,
        ) async {
          await _pump(tester, size, language: language);
          expect(tester.takeException(), isNull);
        });
      }
    }
  });

  group('floating buttons', () {
    testWidgets('have tooltips for mouse and stylus users', (tester) async {
      await _pump(tester, const Size(1000, 1200));
      final l10n = AppLocalizations.of(tester.element(find.byType(Scaffold)))!;
      final tooltips = tester
          .widgetList<FloatingActionButton>(find.byType(FloatingActionButton))
          .map((b) => b.tooltip)
          .toList();
      expect(tooltips, contains(l10n.addToFavorites));
      expect(tooltips, contains(l10n.addToCategories));
    });
  });

  group('recording the song as read', () {
    testWidgets('opening a song records it for the Continue card', (
      tester,
    ) async {
      await _pump(tester, const Size(400, 800));
      final reading = Provider.of<ReadingStateProvider>(
        tester.element(find.byType(SongDetailScreen)),
        listen: false,
      );
      expect(reading.lastSongId, 3);
    });

    testWidgets('a restored song in the pane is not recorded', (tester) async {
      await _pump(tester, const Size(400, 800), recordOpened: false);
      final reading = Provider.of<ReadingStateProvider>(
        tester.element(find.byType(SongDetailScreen)),
        listen: false,
      );
      expect(reading.lastSongId, isNull);
    });
  });
}
