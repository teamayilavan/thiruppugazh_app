import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thiruppugazh/data/models/song_model.dart';
import 'package:thiruppugazh/data/repositories/song_repository.dart';
import 'package:thiruppugazh/l10n/app_localizations.dart';
import 'package:thiruppugazh/providers/lyrics_language_provider.dart';
import 'package:thiruppugazh/providers/reading_state_provider.dart';
import 'package:thiruppugazh/theme/app_theme.dart';
import 'package:thiruppugazh/ui/widgets/continue_card.dart';

Song _song(int id, String title) => Song(
  id: id,
  kaumaramId: '$id',
  title: title,
  place: 'P',
  tune: '',
  lyrics: '',
  lyricsList: const ['a', 'b', 'c', 'd', 'e', 'f'],
  tuneList: const ['t1', 't2'],
  words: const [],
  meanings: const [],
  pathavurai: '',
  patham: const [],
);

class _FakeRepo extends SongRepository {
  final songs = {1: _song(1, 'First Song'), 2: _song(2, 'Second Song')};

  @override
  Future<Song?> getSongById(int id) async => songs[id];
}

/// Stands in for the song page, which records itself as opened from
/// initState -- that is, in the middle of a build.
class _OpensSong extends StatefulWidget {
  const _OpensSong(this.songId);

  final int songId;

  @override
  State<_OpensSong> createState() => _OpensSongState();
}

class _OpensSongState extends State<_OpensSong> {
  @override
  void initState() {
    super.initState();
    context.read<ReadingStateProvider>().recordOpened(widget.songId);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(),
    body: const Text('song page'),
  );
}

Future<ReadingStateProvider> _pump(
  WidgetTester tester, {
  Widget? home,
}) async {
  SharedPreferences.setMockInitialValues({});
  final reading = ReadingStateProvider();
  await tester.runAsync(() => reading.ready);
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<SongRepository>(create: (_) => _FakeRepo()),
        ChangeNotifierProvider(create: (_) => LyricsLanguageProvider()),
        ChangeNotifierProvider.value(value: reading),
      ],
      child: MaterialApp(
        theme: lightTheme,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: home ?? const Scaffold(body: ContinueCard()),
      ),
    ),
  );
  await tester.pump();
  return reading;
}

void main() {
  testWidgets('is hidden until a song has been opened', (tester) async {
    await _pump(tester);
    expect(find.text('Continue where you left off'), findsNothing);
  });

  testWidgets('shows the last opened song', (tester) async {
    final reading = await _pump(tester);
    await reading.recordOpened(1);
    await tester.pumpAndSettle();
    expect(find.text('First Song'), findsOneWidget);
    expect(find.text('Last opened'), findsOneWidget);
  });

  testWidgets('follows the user to a different song', (tester) async {
    final reading = await _pump(tester);
    await reading.recordOpened(1);
    await tester.pumpAndSettle();
    expect(find.text('First Song'), findsOneWidget);

    await reading.recordOpened(2);
    await tester.pumpAndSettle();
    expect(find.text('Second Song'), findsOneWidget);
    expect(find.text('First Song'), findsNothing);
  });

  testWidgets('shows the chanting verse, then switches songs', (tester) async {
    final reading = await _pump(tester);
    await reading.recordChantPosition(1, 2);
    await tester.pumpAndSettle();
    expect(find.text('First Song'), findsOneWidget);
    expect(find.text('Chanting: 3 of 3'), findsOneWidget);

    await reading.recordOpened(2);
    await tester.pumpAndSettle();
    expect(find.text('Second Song'), findsOneWidget);
    expect(find.text('Last opened'), findsOneWidget);
  });

  testWidgets('updates when a song page records itself while it is being built', (tester) async {
    final reading = await _pump(
      tester,
      home: Builder(
        builder: (context) => Scaffold(
          body: Column(
            children: [
              const ContinueCard(),
              ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const _OpensSong(2)),
                ),
                child: const Text('open'),
              ),
            ],
          ),
        ),
      ),
    );
    await reading.recordOpened(1);
    await tester.pumpAndSettle();
    expect(find.text('First Song'), findsOneWidget);

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(reading.lastSongId, 2);

    // Back on Home, the card must follow.
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Second Song'), findsOneWidget);
    expect(find.text('First Song'), findsNothing);
  });
}
