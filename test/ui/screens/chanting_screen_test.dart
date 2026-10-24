import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thiruppugazh/data/models/song_model.dart';
import 'package:thiruppugazh/l10n/app_localizations.dart';
import 'package:thiruppugazh/providers/lyrics_font_size_provider.dart';
import 'package:thiruppugazh/providers/lyrics_language_provider.dart';
import 'package:thiruppugazh/providers/reading_state_provider.dart';
import 'package:thiruppugazh/ui/screens/chanting_screen.dart';

// Two-line tune pattern, six lines of lyrics -> three verses.
Song _song() => Song(
  id: 42,
  kaumaramId: '42',
  title: 'Test Song',
  place: 'P',
  tune: 'tune1\ntune2',
  lyrics: '',
  lyricsList: const ['L1', 'L2', 'L3', 'L4', 'L5', 'L6'],
  tuneList: const ['tuneA', 'tuneB'],
  words: const [],
  meanings: const [],
  pathavurai: '',
  patham: const [],
);

Future<ReadingStateProvider> _pump(
  WidgetTester tester, {
  int initialIndex = 0,
}) async {
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
        home: ChantingScreen(song: _song(), initialIndex: initialIndex),
      ),
    ),
  );
  await tester.pump();
  return reading;
}

void main() {
  testWidgets('shows the first verse, its tune cue and progress', (tester) async {
    await _pump(tester);

    expect(find.text('L1'), findsOneWidget);
    expect(find.text('L2'), findsOneWidget);
    expect(find.text('L3'), findsNothing);
    expect(find.text('tuneA'), findsOneWidget);
    expect(find.text('1 of 3'), findsOneWidget);
  });

  testWidgets('next and previous move one verse at a time', (tester) async {
    await _pump(tester);

    await tester.tap(find.byTooltip('Next verse'));
    await tester.pumpAndSettle();
    expect(find.text('L3'), findsOneWidget);
    expect(find.text('2 of 3'), findsOneWidget);

    await tester.tap(find.byTooltip('Previous verse'));
    await tester.pumpAndSettle();
    expect(find.text('L1'), findsOneWidget);
    expect(find.text('1 of 3'), findsOneWidget);
  });

  testWidgets('previous is disabled on the first verse, next on the last', (tester) async {
    await _pump(tester);
    expect(
      tester
          .widget<IconButton>(
            find.widgetWithIcon(IconButton, Icons.chevron_left),
          )
          .onPressed,
      isNull,
    );

    await tester.tap(find.byTooltip('Next verse'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Next verse'));
    await tester.pumpAndSettle();
    expect(find.text('3 of 3'), findsOneWidget);
    expect(
      tester
          .widget<IconButton>(
            find.widgetWithIcon(IconButton, Icons.chevron_right),
          )
          .onPressed,
      isNull,
    );
  });

  testWidgets('starts on the requested verse', (tester) async {
    await _pump(tester, initialIndex: 2);
    expect(find.text('L5'), findsOneWidget);
    expect(find.text('3 of 3'), findsOneWidget);
  });

  testWidgets('swiping moves to the next verse', (tester) async {
    await _pump(tester);
    await tester.fling(find.byType(PageView), const Offset(-400, 0), 1000);
    await tester.pumpAndSettle();
    expect(find.text('L3'), findsOneWidget);
  });

  testWidgets('tune cue can be hidden', (tester) async {
    await _pump(tester);
    await tester.tap(find.byTooltip('Show tune'));
    await tester.pump();
    expect(find.text('tuneA'), findsNothing);
  });

  testWidgets('auto mode advances on its own and can be paused', (tester) async {
    await _pump(tester);

    await tester.tap(find.text('Auto'));
    await tester.pump();
    // Choosing Auto starts it; default pace is 20 seconds per verse.
    expect(find.byTooltip('Pause'), findsOneWidget);

    await tester.pump(const Duration(seconds: 19));
    expect(find.text('1 of 3'), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle(const Duration(milliseconds: 100));
    expect(find.text('2 of 3'), findsOneWidget);

    await tester.tap(find.byTooltip('Pause'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 60));
    expect(find.text('2 of 3'), findsOneWidget);
  });

  testWidgets('a faster pace shortens the wait', (tester) async {
    await _pump(tester);
    await tester.tap(find.text('Auto'));
    await tester.pump();
    await tester.tap(find.text('10s'));
    await tester.pump();

    await tester.pump(const Duration(seconds: 11));
    await tester.pumpAndSettle(const Duration(milliseconds: 100));
    expect(find.text('2 of 3'), findsOneWidget);
  });

  testWidgets('auto mode finishes at the last verse and can start again', (tester) async {
    await _pump(tester, initialIndex: 2);
    await tester.tap(find.text('Auto'));
    await tester.pump();

    await tester.pump(const Duration(seconds: 21));
    expect(find.text('Song complete'), findsOneWidget);

    await tester.tap(find.text('Start again'));
    await tester.pumpAndSettle();
    expect(find.text('L1'), findsOneWidget);
    expect(find.text('Song complete'), findsNothing);
  });

  testWidgets('remembers the verse for Continue, and forgets it once finished', (tester) async {
    final reading = await _pump(tester);
    expect(reading.lastSongId, 42);
    expect(reading.lastChantIndex, 0);

    await tester.tap(find.byTooltip('Next verse'));
    await tester.pumpAndSettle();
    expect(reading.lastChantIndex, 1);

    await tester.tap(find.byTooltip('Next verse'));
    await tester.pumpAndSettle();
    // On the last verse the song counts as done.
    expect(reading.lastChantIndex, isNull);
    expect(reading.lastMode, ResumeMode.read);
  });
}
