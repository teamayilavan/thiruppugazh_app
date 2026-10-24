import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thiruppugazh/data/models/link_model.dart';
import 'package:thiruppugazh/data/models/search_filter.dart';
import 'package:thiruppugazh/data/models/song_model.dart';
import 'package:thiruppugazh/data/repositories/song_repository.dart';
import 'package:thiruppugazh/l10n/app_localizations.dart';
import 'package:thiruppugazh/providers/lyrics_language_provider.dart';
import 'package:thiruppugazh/ui/screens/pick_song_screen.dart';

Song _song(int id, String title) => Song(
  id: id,
  kaumaramId: '$id',
  title: title,
  place: 'P',
  tune: '',
  lyrics: '',
  lyricsList: const [],
  tuneList: const [],
  words: const [],
  meanings: const [],
  pathavurai: '',
  patham: const [],
);

class _FakeRepo extends SongRepository {
  _FakeRepo({required this.alreadyHasLink});

  final bool alreadyHasLink;
  final List<SongLink> saved = [];

  @override
  Future<List<Song>> searchSongsWithFilter(SearchFilter filter) async => [
    _song(7, 'Arukku Mangaiyar'),
  ];

  @override
  Future<bool> addLinkIfAbsent(SongLink link) async {
    if (alreadyHasLink) return false;
    saved.add(link);
    return true;
  }
}

Future<PickSongResult?> _pickFirstResult(
  WidgetTester tester,
  _FakeRepo repo,
) async {
  SharedPreferences.setMockInitialValues({});
  PickSongResult? result;
  var finished = false;

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<SongRepository>.value(value: repo),
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
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () async {
                result = await Navigator.of(context).push<PickSongResult>(
                  MaterialPageRoute(
                    builder: (_) => const PickSongScreen(
                      url: 'https://youtu.be/abc',
                      title: 'A recital',
                    ),
                  ),
                );
                finished = true;
              },
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();

  await tester.enterText(find.byType(TextField), 'arukku');
  await tester.pump(const Duration(seconds: 1)); // search debounce
  await tester.pumpAndSettle();
  await tester.tap(find.text('Arukku Mangaiyar'));
  await tester.pumpAndSettle();
  expect(finished, isTrue);
  return result;
}

void main() {
  testWidgets('saves the link and reports which song and that it was added', (tester) async {
    final repo = _FakeRepo(alreadyHasLink: false);
    final result = await _pickFirstResult(tester, repo);

    expect(result, isNotNull);
    expect(result!.song.id, 7);
    expect(result.added, isTrue);
    expect(repo.saved.single.songId, 7);
    expect(repo.saved.single.url, 'https://youtu.be/abc');
    expect(repo.saved.single.title, 'A recital');
  });

  testWidgets('reports when the song already had the link', (tester) async {
    final result = await _pickFirstResult(
      tester,
      _FakeRepo(alreadyHasLink: true),
    );
    expect(result!.song.id, 7);
    expect(result.added, isFalse);
  });

  testWidgets('backing out saves nothing and returns no result', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final repo = _FakeRepo(alreadyHasLink: false);
    PickSongResult? result = PickSongResult(song: _song(1, 'x'), added: true);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<SongRepository>.value(value: repo),
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
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () async {
                  result = await Navigator.of(context).push<PickSongResult>(
                    MaterialPageRoute(
                      builder: (_) => const PickSongScreen(url: 'https://a.com'),
                    ),
                  );
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(result, isNull);
    expect(repo.saved, isEmpty);
  });
}
