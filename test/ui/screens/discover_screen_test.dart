import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thiruppugazh/data/repositories/song_repository.dart';
import 'package:thiruppugazh/l10n/app_localizations.dart';
import 'package:thiruppugazh/providers/auto_backup_status_provider.dart';
import 'package:thiruppugazh/providers/keep_screen_on_provider.dart';
import 'package:thiruppugazh/providers/language_provider.dart';
import 'package:thiruppugazh/providers/lyrics_font_size_provider.dart';
import 'package:thiruppugazh/providers/lyrics_language_provider.dart';
import 'package:thiruppugazh/providers/reminder_settings_provider.dart';
import 'package:thiruppugazh/providers/song_list_provider.dart';
import 'package:thiruppugazh/providers/theme_provider.dart';
import 'package:thiruppugazh/theme/app_theme.dart';
import 'package:thiruppugazh/ui/screens/discover_screen.dart';
import 'package:thiruppugazh/ui/screens/search_screen.dart';
import 'package:thiruppugazh/ui/screens/settings_screen.dart';
import 'package:thiruppugazh/ui/screens/song_list_screen.dart';

import '../../support/fake_song_repo.dart';
import '../../support/shell_harness.dart';

/// Tall, so every card is built and can be measured.
const Size _tallPhone = Size(400, 4000);
const Size _tallTablet = Size(1280, 4000);

Future<void> _pump(
  WidgetTester tester,
  Size size, {
  String language = 'en',
  ThemeData? theme,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  SharedPreferences.setMockInitialValues({});

  final repo = FakeSongRepo();
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<SongRepository>.value(value: repo),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => LyricsLanguageProvider()),
        ChangeNotifierProvider(create: (_) => LyricsFontSizeProvider()),
        ChangeNotifierProvider(create: (_) => ReminderSettingsProvider()),
        ChangeNotifierProvider(create: (_) => KeepScreenOnProvider()),
        ChangeNotifierProvider(create: (_) => AutoBackupStatusProvider()),
        ChangeNotifierProvider(create: (_) => SongListProvider(repo)),
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
        theme: theme ?? lightTheme,
        home: const DiscoverScreen(),
      ),
    ),
  );
  await settleShell(tester);
}

Finder _tryItIn(String cardTitle) => find.descendant(
  of: find.ancestor(of: find.text(cardTitle), matching: find.byType(Card)),
  matching: find.byType(TextButton),
);

void main() {
  testWidgets('a phone shows every card except the tablet one', (tester) async {
    await _pump(tester, _tallPhone);
    expect(find.text('Chanting mode'), findsOneWidget);
    expect(find.text('Backup and restore'), findsOneWidget);
    expect(find.text('Reading pane on tablets'), findsNothing);
  });

  testWidgets('a tablet also shows the reading pane card', (tester) async {
    await _pump(tester, _tallTablet);
    expect(find.text('Reading pane on tablets'), findsOneWidget);
  });

  testWidgets('Try it appears only on cards that have somewhere to go', (
    tester,
  ) async {
    await _pump(tester, _tallPhone);
    final withDestination = discoverFeatures()
        .where((f) => f.destination != null && !f.largeScreenOnly)
        .length;
    expect(withDestination, greaterThan(0));
    expect(find.text('Try it'), findsNWidgets(withDestination));
    // How-to cards carry no button.
    expect(_tryItIn('Chanting mode'), findsNothing);
    expect(_tryItIn('Today\'s song widget'), findsNothing);
  });

  testWidgets('Try it on Favorites opens the Favorites list', (tester) async {
    await _pump(tester, _tallPhone);
    await tester.tap(_tryItIn('Favorites'));
    await settleShell(tester);
    expect(find.byType(SongListScreen), findsOneWidget);
  });

  testWidgets('Try it on Daily reminder opens Settings', (tester) async {
    await _pump(tester, _tallPhone);
    await tester.tap(_tryItIn('Daily reminder'));
    await settleShell(tester);
    expect(find.byType(SettingsScreen), findsOneWidget);
  });

  testWidgets('Try it on Search opens Search', (tester) async {
    await _pump(tester, _tallPhone);
    await tester.tap(_tryItIn('Search by title or lyrics'));
    await settleShell(tester);
    expect(find.byType(SearchScreen), findsOneWidget);
  });

  testWidgets('Tamil at 400 dp has no overflow and Try it is 48 dp tall', (
    tester,
  ) async {
    await _pump(tester, _tallPhone, language: 'ta');
    expect(tester.takeException(), isNull);
    final buttons = find.byType(TextButton);
    expect(buttons, findsWidgets);
    for (final e in buttons.evaluate()) {
      expect(
        tester.getSize(find.byWidget(e.widget)).height,
        greaterThanOrEqualTo(48),
      );
    }
  });

  testWidgets('dark theme builds without errors', (tester) async {
    await _pump(tester, _tallPhone, theme: darkTheme);
    expect(tester.takeException(), isNull);
    expect(find.byType(Card), findsWidgets);
  });

  testWidgets('every card has a title and a body in English and Tamil', (
    tester,
  ) async {
    await _pump(tester, _tallPhone);
    for (final locale in AppLocalizations.supportedLocales) {
      final l10n = await AppLocalizations.delegate.load(locale);
      for (final f in discoverFeatures()) {
        expect(f.title(l10n).trim(), isNotEmpty, reason: '${f.id} $locale');
        expect(
          f.description(l10n).trim(),
          isNotEmpty,
          reason: '${f.id} $locale',
        );
      }
    }
  });
}
