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

import '../../support/fake_song_repo.dart';

Future<AppLocalizations> _pump(WidgetTester tester, String language) async {
  SharedPreferences.setMockInitialValues({});
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<SongRepository>.value(value: FakeSongRepo()),
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
        locale: Locale(language),
        theme: lightTheme,
        home: const HighlightsNotesScreen(),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
  return AppLocalizations.of(tester.element(find.byType(Scaffold).first))!;
}

void main() {
  for (final language in const ['en', 'ta']) {
    testWidgets('each empty Library tab explains how it fills up ($language)', (
      tester,
    ) async {
      final l10n = await _pump(tester, language);

      expect(find.text(l10n.noHighlightsFound), findsOneWidget);
      expect(find.text(l10n.highlightsHint), findsOneWidget);

      await tester.tap(find.text(l10n.notes));
      await tester.pumpAndSettle();
      expect(find.text(l10n.noNotesFound), findsOneWidget);
      expect(find.text(l10n.notesHint), findsOneWidget);

      await tester.tap(find.text(l10n.links));
      await tester.pumpAndSettle();
      expect(find.text(l10n.noLinksFound), findsOneWidget);
      expect(find.text(l10n.linksHint), findsOneWidget);

      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('the hints fit a small phone without overflow', (tester) async {
    tester.view.physicalSize = const Size(320, 480);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await _pump(tester, 'ta');
    expect(tester.takeException(), isNull);
  });
}
