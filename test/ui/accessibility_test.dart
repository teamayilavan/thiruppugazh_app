import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thiruppugazh/l10n/app_localizations.dart';
import 'package:thiruppugazh/providers/lyrics_font_size_provider.dart';
import 'package:thiruppugazh/providers/lyrics_language_provider.dart';
import 'package:thiruppugazh/providers/reading_state_provider.dart';
import 'package:thiruppugazh/theme/app_theme.dart';
import 'package:thiruppugazh/ui/screens/chanting_screen.dart';
import 'package:thiruppugazh/ui/screens/main_wrapper.dart';

import '../support/fake_song_repo.dart';
import '../support/shell_harness.dart';

/// A phone-width window tall enough to show whole lists. The contrast check
/// reads pixels, so a list item built just off screen would be measured in the
/// wrong place; showing everything avoids those false reports.
const Size _tallPhone = Size(400, 2600);

/// Flutter's own accessibility guidelines, run over every tab and the reading
/// pane: controls big enough to hit (48 dp), every tappable thing labelled for
/// a screen reader, and readable text contrast, in light and dark themes.
///
/// A failure here names a real control a TalkBack user or a shaky thumb would
/// have trouble with.
void main() {
  Future<void> check(WidgetTester tester, String where) async {
    final handle = tester.ensureSemantics();
    await expectLater(
      tester,
      meetsGuideline(androidTapTargetGuideline),
      reason: 'tap target size: $where',
    );
    await expectLater(
      tester,
      meetsGuideline(labeledTapTargetGuideline),
      reason: 'labels: $where',
    );
    await expectLater(
      tester,
      meetsGuideline(textContrastGuideline),
      reason: 'text contrast: $where',
    );
    handle.dispose();
  }

  AppLocalizations l10n(WidgetTester tester) =>
      AppLocalizations.of(tester.element(find.byType(MainWrapper)))!;

  for (final mode in const [ThemeMode.light, ThemeMode.dark]) {
    for (final language in const ['en', 'ta']) {
      testWidgets('every tab on a phone, $mode, $language', (tester) async {
        await pumpShell(
          tester,
          _tallPhone,
          language: language,
          themeMode: mode,
        );
        final strings = l10n(tester);
        final tabs = [
          strings.songs,
          strings.temples,
          strings.categories,
          strings.myLibrary,
          strings.more,
        ];
        for (final label in tabs) {
          await tester.tap(find.text(label).last);
          await settleShell(tester);
          await check(tester, '$label tab, $mode, $language');
        }
      });
    }
  }

  testWidgets('the tablet reading pane with its previous/next bar', (
    tester,
  ) async {
    await pumpShell(tester, tabletLandscape, lastSongId: 3);
    await check(tester, 'tablet reader');
  });

  testWidgets('the tablet reading pane in dark theme', (tester) async {
    await pumpShell(
      tester,
      tabletLandscape,
      lastSongId: 3,
      themeMode: ThemeMode.dark,
    );
    await check(tester, 'tablet reader, dark');
  });

  for (final mode in const [ThemeMode.light, ThemeMode.dark]) {
    testWidgets('the Library with highlights, notes and links, $mode', (
      tester,
    ) async {
      await pumpShell(
        tester,
        _tallPhone,
        themeMode: mode,
        repo: PopulatedFakeSongRepo(),
      );
      final strings = l10n(tester);
      await tester.tap(find.text(strings.myLibrary).last);
      await settleShell(tester);
      for (final tab in [strings.highlights, strings.notes, strings.links]) {
        await tester.tap(find.text(tab).first);
        await settleShell(tester);
        await check(tester, 'Library $tab, $mode');
      }
    });
  }

  for (final mode in const [ThemeMode.light, ThemeMode.dark]) {
    testWidgets('search with results and recent searches, $mode', (
      tester,
    ) async {
      await pumpShell(tester, _tallPhone, themeMode: mode);
      final strings = l10n(tester);
      await tester.tap(find.byTooltip(strings.globalSearch));
      await settleShell(tester);
      await check(tester, 'search, empty, $mode');

      await tester.enterText(find.byType(TextField), 'song');
      await tester.pump(const Duration(seconds: 1));
      await settleShell(tester);
      expect(find.text('Alpha Song'), findsOneWidget);
      await check(tester, 'search, results, $mode');
    });
  }

  for (final mode in const [ThemeMode.light, ThemeMode.dark]) {
    testWidgets('chanting mode, $mode', (tester) async {
      tester.view.physicalSize = phonePortrait;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      SharedPreferences.setMockInitialValues({});
      final reading = ReadingStateProvider();
      await tester.runAsync(() => reading.ready);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
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
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: mode,
            home: ChantingScreen(song: testSong(1, 'Alpha Song')),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));
      await check(tester, 'chanting, $mode');
    });
  }
}
