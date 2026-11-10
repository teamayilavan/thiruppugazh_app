import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thiruppugazh/constants/app_constants.dart';
import 'package:thiruppugazh/data/repositories/song_repository.dart';
import 'package:thiruppugazh/l10n/app_localizations.dart';
import 'package:thiruppugazh/providers/keep_screen_on_provider.dart';
import 'package:thiruppugazh/providers/lyrics_font_size_provider.dart';
import 'package:thiruppugazh/providers/lyrics_language_provider.dart';
import 'package:thiruppugazh/providers/reading_state_provider.dart';
import 'package:thiruppugazh/services/screen_awake_service.dart';
import 'package:thiruppugazh/theme/app_theme.dart';
import 'package:thiruppugazh/ui/screens/song_detail_screen.dart';

import '../../support/fake_song_repo.dart';

late KeepScreenOnProvider _keepOn;
late List<bool> _sent;

Future<void> _show(WidgetTester tester, Widget body) async {
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<SongRepository>.value(value: FakeSongRepo()),
        ChangeNotifierProvider(create: (_) => LyricsFontSizeProvider()),
        ChangeNotifierProvider(create: (_) => LyricsLanguageProvider()),
        ChangeNotifierProvider(create: (_) => ReadingStateProvider()),
        ChangeNotifierProvider<KeepScreenOnProvider>.value(value: _keepOn),
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
        home: body,
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
}

Future<void> _start(WidgetTester tester, {required bool enabled}) async {
  SharedPreferences.setMockInitialValues({
    AppConstants.keepScreenOnReadingPrefsKey: enabled,
  });
  ScreenAwakeService.resetForTesting();
  _sent = [];
  ScreenAwakeService.sender = (keepAwake) async => _sent.add(keepAwake);
  _keepOn = KeepScreenOnProvider();
  await tester.runAsync(() => _keepOn.ready);
}

void main() {
  tearDown(ScreenAwakeService.resetForTesting);

  testWidgets('a song page does not hold the screen by default', (
    tester,
  ) async {
    await _start(tester, enabled: false);
    await _show(tester, SongDetailScreen(song: testSong(1, 'Alpha')));
    expect(ScreenAwakeService.holders, 0);
    expect(_sent, isEmpty);
  });

  testWidgets('with the setting on it holds the screen while open', (
    tester,
  ) async {
    await _start(tester, enabled: true);
    await _show(tester, SongDetailScreen(song: testSong(1, 'Alpha')));
    expect(ScreenAwakeService.holders, 1);
    expect(_sent, [true]);

    await _show(tester, const SizedBox());
    expect(ScreenAwakeService.holders, 0);
    expect(_sent, [true, false]);
  });

  testWidgets('turning the setting off while a song is open lets it sleep', (
    tester,
  ) async {
    await _start(tester, enabled: true);
    await _show(tester, SongDetailScreen(song: testSong(1, 'Alpha')));
    expect(ScreenAwakeService.holders, 1);

    await tester.runAsync(() => _keepOn.setEnabled(false));
    await tester.pump();
    expect(ScreenAwakeService.holders, 0);
    expect(_sent, [true, false]);
  });

  testWidgets('turning it on while a song is open starts holding', (
    tester,
  ) async {
    await _start(tester, enabled: false);
    await _show(tester, SongDetailScreen(song: testSong(1, 'Alpha')));
    expect(ScreenAwakeService.holders, 0);

    await tester.runAsync(() => _keepOn.setEnabled(true));
    await tester.pump();
    expect(ScreenAwakeService.holders, 1);
  });

  testWidgets(
    'moving to the next song in the pane never lets the screen sleep',
    (tester) async {
      await _start(tester, enabled: true);
      await _show(
        tester,
        SongDetailScreen(key: const ValueKey(1), song: testSong(1, 'Alpha')),
      );
      expect(_sent, [true]);

      // The reading pane swaps the page by key: the new page starts before the
      // old one is disposed.
      await _show(
        tester,
        SongDetailScreen(key: const ValueKey(2), song: testSong(2, 'Bravo')),
      );
      expect(ScreenAwakeService.holders, 1);
      expect(_sent, [true], reason: 'it must never have been told to sleep');
    },
  );
}
