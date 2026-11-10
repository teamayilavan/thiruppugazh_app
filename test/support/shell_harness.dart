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
import 'package:thiruppugazh/theme/app_theme.dart';
import 'package:thiruppugazh/ui/screens/main_wrapper.dart';

import 'fake_song_repo.dart';

/// Window sizes the app is tested at.
const Size phonePortrait = Size(400, 800);
const Size phoneLandscape = Size(800, 400);
const Size tabletPortrait = Size(800, 1280);
const Size tabletLandscape = Size(1280, 800);

Future<void> pumpShell(
  WidgetTester tester,
  Size size, {
  String language = 'en',
  int? lastSongId,
  ThemeMode themeMode = ThemeMode.light,
  SongRepository? repo,
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

  final songRepo = repo ?? FakeSongRepo();
  final reading = ReadingStateProvider();
  final language_ = LanguageProvider();
  await tester.runAsync(() async {
    await reading.ready;
    await Future<void>.delayed(const Duration(milliseconds: 50));
  });

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<SongRepository>.value(value: songRepo),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider.value(value: language_),
        ChangeNotifierProvider(create: (_) => LyricsLanguageProvider()),
        ChangeNotifierProvider(create: (_) => LyricsFontSizeProvider()),
        ChangeNotifierProvider(create: (_) => ReminderSettingsProvider()),
        ChangeNotifierProvider(create: (_) => KeepScreenOnProvider()),
        ChangeNotifierProvider.value(value: reading),
        ChangeNotifierProvider(create: (_) => AutoBackupStatusProvider()),
        ChangeNotifierProvider(create: (_) => SongListProvider(songRepo)),
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
        themeMode: themeMode,
        home: const MainWrapper(),
      ),
    ),
  );
  await settleShell(tester);
}

/// Lets async loads (fake repo, restore) finish and animations end.
Future<void> settleShell(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump(const Duration(milliseconds: 100));
  }
  // Page transitions (a popped route) take a little longer to leave the tree.
  await tester.pump(const Duration(seconds: 1));
}
