import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thiruppugazh/data/models/song_model.dart';
import 'package:thiruppugazh/data/repositories/song_repository.dart';
import 'package:thiruppugazh/l10n/app_localizations.dart';
import 'package:thiruppugazh/providers/lyrics_language_provider.dart';
import 'package:thiruppugazh/theme/app_theme.dart';
import 'package:thiruppugazh/ui/screens/temple_songs_screen.dart';
import 'package:thiruppugazh/ui/screens/temples_screen.dart';

import '../../support/fake_song_repo.dart';

const String _secret = 'SQLITE_ERROR: no such table: temples';

/// Fails the first time it is asked, then works.
class _FlakyRepo extends FakeSongRepo {
  int templeCalls = 0;
  int songCalls = 0;

  @override
  Future<List<Map<String, dynamic>>> getAllTemples() async {
    if (templeCalls++ == 0) throw Exception(_secret);
    return [];
  }

  @override
  Future<List<Song>> getSongsByTemple(String templeName) async {
    if (songCalls++ == 0) throw Exception(_secret);
    return [testSong(1, 'Alpha Song')];
  }
}

Future<AppLocalizations> _pump(WidgetTester tester, Widget home) async {
  SharedPreferences.setMockInitialValues({});
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<SongRepository>.value(
          value: _FlakyRepoHolder.repo,
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
        home: home,
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
  return AppLocalizations.of(tester.element(find.byType(Scaffold).first))!;
}

class _FlakyRepoHolder {
  static _FlakyRepo repo = _FlakyRepo();
}

void main() {
  setUp(() => _FlakyRepoHolder.repo = _FlakyRepo());

  testWidgets('Temples shows a calm message, never the exception text', (
    tester,
  ) async {
    final l10n = await _pump(tester, const TemplesScreen());
    expect(find.text(l10n.failedToLoadTemples), findsOneWidget);
    expect(find.textContaining('SQLITE'), findsNothing);
    expect(find.textContaining('Exception'), findsNothing);
  });

  testWidgets('Temples retries when asked', (tester) async {
    final l10n = await _pump(tester, const TemplesScreen());
    await tester.tap(find.text(l10n.retry));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text(l10n.failedToLoadTemples), findsNothing);
    expect(find.text(l10n.noTemplesFound), findsOneWidget);
    expect(_FlakyRepoHolder.repo.templeCalls, 2);
  });

  testWidgets('Temple songs shows a calm message and can retry', (
    tester,
  ) async {
    final l10n = await _pump(
      tester,
      const TempleSongsScreen(templeName: 'T', templeDisplayName: 'T'),
    );
    expect(find.text(l10n.failedToLoadSongs), findsOneWidget);
    expect(find.textContaining('SQLITE'), findsNothing);

    await tester.tap(find.text(l10n.retry));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Alpha Song'), findsOneWidget);
  });
}
