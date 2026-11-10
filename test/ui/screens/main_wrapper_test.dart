import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thiruppugazh/constants/app_constants.dart';
import 'package:thiruppugazh/data/repositories/song_repository.dart';
import 'package:thiruppugazh/l10n/app_localizations.dart';
import 'package:thiruppugazh/providers/auto_backup_status_provider.dart';
import 'package:thiruppugazh/providers/keep_screen_on_provider.dart';
import 'package:thiruppugazh/providers/language_provider.dart';
import 'package:thiruppugazh/providers/lyrics_font_size_provider.dart';
import 'package:thiruppugazh/providers/lyrics_language_provider.dart';
import 'package:thiruppugazh/providers/reading_state_provider.dart';
import 'package:thiruppugazh/providers/reminder_settings_provider.dart';
import 'package:thiruppugazh/providers/song_list_provider.dart';
import 'package:thiruppugazh/providers/theme_provider.dart';
import 'package:thiruppugazh/services/daily_song_service.dart';
import 'package:thiruppugazh/services/reminder_notification_service.dart';
import 'package:thiruppugazh/theme/app_theme.dart';
import 'package:thiruppugazh/ui/screens/main_wrapper.dart';
import 'package:thiruppugazh/ui/screens/song_detail_screen.dart';

import '../../support/fake_song_repo.dart';

const Size _phonePortrait = Size(400, 800);
const Size _phoneLandscape = Size(800, 400);
const Size _tabletPortrait = Size(800, 1280);
const Size _tabletLandscape = Size(1280, 800);

Future<void> _pump(
  WidgetTester tester,
  Size size, {
  String language = 'en',
  int? lastSongId,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  // The deep-link plugin has no host in a unit test.
  final messenger = tester.binding.defaultBinaryMessenger;
  for (final name in const [
    'com.llfbandit.app_links/messages',
    'com.llfbandit.app_links/events',
  ]) {
    messenger.setMockMethodCallHandler(MethodChannel(name), (_) async => null);
  }
  addTearDown(() {
    for (final name in const [
      'com.llfbandit.app_links/messages',
      'com.llfbandit.app_links/events',
    ]) {
      messenger.setMockMethodCallHandler(MethodChannel(name), null);
    }
  });

  SharedPreferences.setMockInitialValues({
    AppConstants.languagePrefsKey: language,
    if (lastSongId != null)
      AppConstants.readingStatePrefsKey: jsonEncode({
        'recent': [lastSongId],
        'mode': 'read',
        'chant': <String, int>{},
      }),
  });

  final repo = FakeSongRepo();
  final reading = ReadingStateProvider();
  final language_ = LanguageProvider();
  await tester.runAsync(() async {
    await reading.ready;
    await Future<void>.delayed(const Duration(milliseconds: 50));
  });

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<SongRepository>.value(value: repo),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider.value(value: language_),
        ChangeNotifierProvider(create: (_) => LyricsLanguageProvider()),
        ChangeNotifierProvider(create: (_) => LyricsFontSizeProvider()),
        ChangeNotifierProvider(create: (_) => ReminderSettingsProvider()),
        ChangeNotifierProvider(create: (_) => KeepScreenOnProvider()),
        ChangeNotifierProvider.value(value: reading),
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
        theme: lightTheme,
        darkTheme: darkTheme,
        home: const MainWrapper(),
      ),
    ),
  );
  await _settle(tester);
}

/// Lets async loads (fake repo, restore) finish and animations end.
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump(const Duration(milliseconds: 100));
  }
  // Page transitions (a popped route) take a little longer to leave the tree.
  await tester.pump(const Duration(seconds: 1));
}

AppLocalizations _l10n(WidgetTester tester) =>
    AppLocalizations.of(tester.element(find.byType(MainWrapper)))!;

Finder _readerHint(WidgetTester tester) =>
    find.text(_l10n(tester).selectSongToRead);

Finder _iconButton(String tooltip) =>
    find.byWidgetPredicate((w) => w is IconButton && w.tooltip == tooltip);

Finder _nextButton(WidgetTester tester) => _iconButton(_l10n(tester).nextSong);

Finder _prevButton(WidgetTester tester) =>
    _iconButton(_l10n(tester).previousSong);

bool _enabled(WidgetTester tester, Finder button) =>
    tester.widget<IconButton>(button).onPressed != null;

Future<void> _openFromList(WidgetTester tester, String title) async {
  await tester.tap(find.text(title).first);
  await _settle(tester);
}

/// The title the reader shows (the song page's heading).
Finder _heading(String title) => find.descendant(
  of: find.byType(SongDetailScreen),
  matching: find.text(title),
);

void main() {
  group('navigation by window size', () {
    testWidgets('a phone held upright keeps the bottom bar', (tester) async {
      await _pump(tester, _phonePortrait);
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(NavigationRail), findsNothing);
      expect(_readerHint(tester), findsNothing);
    });

    testWidgets('a phone held sideways gets a rail but no reading pane', (
      tester,
    ) async {
      await _pump(tester, _phoneLandscape);
      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
      expect(_readerHint(tester), findsNothing);
    });

    testWidgets('a tablet in portrait gets a rail but no reading pane', (
      tester,
    ) async {
      await _pump(tester, _tabletPortrait);
      expect(find.byType(NavigationRail), findsOneWidget);
      expect(_readerHint(tester), findsNothing);
    });

    testWidgets('a tablet in landscape shows the list and an empty reader', (
      tester,
    ) async {
      await _pump(tester, _tabletLandscape);
      expect(find.byType(NavigationRail), findsOneWidget);
      expect(_readerHint(tester), findsOneWidget);
      expect(find.text('Alpha Song'), findsWidgets);
    });
  });

  group('reading pane', () {
    testWidgets('starts with the song read last time', (tester) async {
      await _pump(tester, _tabletLandscape, lastSongId: 3);
      expect(_readerHint(tester), findsNothing);
      expect(_heading('Charlie Song'), findsOneWidget);
      // Neighbours are 2 and 5 (there is no 4).
      expect(_enabled(tester, _prevButton(tester)), isTrue);
      expect(_enabled(tester, _nextButton(tester)), isTrue);
    });

    testWidgets('showing the remembered song does not count as opening it', (
      tester,
    ) async {
      await _pump(tester, _tabletLandscape, lastSongId: 3);
      final reading = Provider.of<ReadingStateProvider>(
        tester.element(find.byType(MainWrapper)),
        listen: false,
      );
      // Still the same single entry: restoring didn't touch the history.
      expect(reading.recentSongIds, [3]);
    });

    testWidgets('a remembered song that no longer exists leaves it empty', (
      tester,
    ) async {
      await _pump(tester, _tabletLandscape, lastSongId: 999);
      expect(_readerHint(tester), findsOneWidget);
    });

    testWidgets('tapping a song opens it; next and previous move by number', (
      tester,
    ) async {
      await _pump(tester, _tabletLandscape);
      await _openFromList(tester, 'Charlie Song');
      expect(_heading('Charlie Song'), findsOneWidget);

      await tester.tap(_nextButton(tester));
      await _settle(tester);
      expect(_heading('Echo Song'), findsOneWidget);

      await tester.tap(_prevButton(tester));
      await _settle(tester);
      expect(_heading('Charlie Song'), findsOneWidget);
    });

    testWidgets('previous is disabled at the first song', (tester) async {
      await _pump(tester, _tabletLandscape, lastSongId: 1);
      expect(_heading('Alpha Song'), findsOneWidget);
      expect(_enabled(tester, _prevButton(tester)), isFalse);
      expect(_enabled(tester, _nextButton(tester)), isTrue);
    });

    testWidgets('next is disabled at the last song', (tester) async {
      await _pump(tester, _tabletLandscape, lastSongId: 6);
      expect(_heading('Foxtrot Song'), findsOneWidget);
      expect(_enabled(tester, _nextButton(tester)), isFalse);
      expect(_enabled(tester, _prevButton(tester)), isTrue);
    });

    testWidgets('the arrow keys move through the songs', (tester) async {
      await _pump(tester, _tabletLandscape);
      await _openFromList(tester, 'Bravo Song');

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await _settle(tester);
      expect(_heading('Charlie Song'), findsOneWidget);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await _settle(tester);
      expect(_heading('Bravo Song'), findsOneWidget);
    });

    testWidgets('the arrow keys do nothing at the end of the list', (
      tester,
    ) async {
      await _pump(tester, _tabletLandscape, lastSongId: 6);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await _settle(tester);
      expect(_heading('Foxtrot Song'), findsOneWidget);
    });

    testWidgets('the arrow keys leave a search box alone', (tester) async {
      await _pump(tester, _tabletLandscape);
      await _openFromList(tester, 'Bravo Song');

      // Ctrl+F opens search with its text field focused.
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyF);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await _settle(tester);
      expect(find.byType(TextField), findsOneWidget);
      await tester.tap(find.byType(TextField));
      await _settle(tester);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await _settle(tester);
      expect(_heading('Bravo Song'), findsOneWidget);
      expect(_heading('Charlie Song'), findsNothing);
    });
  });

  group('rotating a tablet', () {
    testWidgets('a song open in the pane becomes a full page in portrait', (
      tester,
    ) async {
      await _pump(tester, _tabletLandscape);
      await _openFromList(tester, 'Charlie Song');
      expect(find.byType(SongDetailScreen), findsOneWidget);

      tester.view.physicalSize = _tabletPortrait;
      await _settle(tester);

      // The song is still on screen, now as a page on top of the tab, and the
      // pane's previous/next bar is gone.
      expect(find.byType(SongDetailScreen), findsOneWidget);
      expect(_heading('Charlie Song'), findsOneWidget);
      expect(_nextButton(tester), findsNothing);
      expect(find.byType(NavigationRail), findsOneWidget);
    });

    testWidgets('a full page folds back into the pane in landscape', (
      tester,
    ) async {
      await _pump(tester, _tabletPortrait);
      await _openFromList(tester, 'Charlie Song');
      expect(find.byType(SongDetailScreen), findsOneWidget);
      expect(_nextButton(tester), findsNothing);

      tester.view.physicalSize = _tabletLandscape;
      await _settle(tester);

      // Exactly one song page, now inside the pane (it has the bar).
      expect(find.byType(SongDetailScreen), findsOneWidget);
      expect(_heading('Charlie Song'), findsOneWidget);
      expect(_nextButton(tester), findsOneWidget);
    });

    testWidgets('the remembered song is not forced open in portrait', (
      tester,
    ) async {
      await _pump(tester, _tabletLandscape, lastSongId: 3);
      expect(_heading('Charlie Song'), findsOneWidget);

      tester.view.physicalSize = _tabletPortrait;
      await _settle(tester);

      // The user never opened it, so rotating doesn't push a page.
      expect(find.byType(SongDetailScreen), findsNothing);
    });
  });

  group('the daily reminder', () {
    // The same song the Home card shows.
    String todaysTitle() =>
        testSongs[dailySongIndexForDate(DateTime.now(), testSongs.length)]
            .title;

    testWidgets("a tap opens today's song in the reading pane", (tester) async {
      await _pump(tester, _tabletLandscape);
      expect(_readerHint(tester), findsOneWidget);

      ReminderNotificationService.emitTapForTesting();
      await _settle(tester);
      expect(_heading(todaysTitle()), findsOneWidget);
    });

    testWidgets("a tap opens today's song as a page on a phone", (
      tester,
    ) async {
      await _pump(tester, _phonePortrait);
      expect(find.byType(SongDetailScreen), findsNothing);

      ReminderNotificationService.emitTapForTesting();
      await _settle(tester);
      expect(find.byType(SongDetailScreen), findsOneWidget);
      expect(_heading(todaysTitle()), findsOneWidget);
    });

    testWidgets("starting the app from the reminder opens today's song", (
      tester,
    ) async {
      final original = ReminderNotificationService.launchCheck;
      ReminderNotificationService.launchCheck = () async => true;
      addTearDown(() => ReminderNotificationService.launchCheck = original);

      await _pump(tester, _phonePortrait);
      expect(find.byType(SongDetailScreen), findsOneWidget);
      expect(_heading(todaysTitle()), findsOneWidget);
    });

    testWidgets('a normal start does not open a song', (tester) async {
      await _pump(tester, _phonePortrait);
      expect(find.byType(SongDetailScreen), findsNothing);
    });
  });

  group('back button', () {
    testWidgets('on the first page of a tab it asks before exiting', (
      tester,
    ) async {
      await _pump(tester, _phonePortrait);
      await tester.binding.handlePopRoute();
      await _settle(tester);
      expect(find.text(_l10n(tester).exitAppTitle), findsOneWidget);
    });
  });

  group('no layout overflow', () {
    // Flutter turns a RenderFlex overflow into a test failure, so simply
    // showing every tab at every size, in both languages, is a broad check.
    const sizes = {
      'phone portrait': _phonePortrait,
      'phone landscape': _phoneLandscape,
      'tablet portrait': _tabletPortrait,
      'tablet landscape': _tabletLandscape,
    };
    for (final language in const ['en', 'ta']) {
      for (final entry in sizes.entries) {
        testWidgets('${entry.key}, $language', (tester) async {
          await _pump(tester, entry.value, language: language, lastSongId: 3);
          final l10n = _l10n(tester);
          final tabs = [
            l10n.songs,
            l10n.temples,
            l10n.categories,
            l10n.myLibrary,
            l10n.more,
          ];
          for (final label in tabs) {
            await tester.tap(find.text(label).last);
            await _settle(tester);
            expect(tester.takeException(), isNull, reason: '$label tab');
          }
        });
      }
    }
  });
}
