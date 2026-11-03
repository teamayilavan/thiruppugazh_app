import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thiruppugazh/data/models/song_model.dart';
import 'package:thiruppugazh/ui/widgets/adaptive_layout.dart';

Song _song(int id) =>
    Song.fromMap({'id': id, 'kaumaram_id': id, 'title': 't$id'});

void main() {
  group('gutterFor', () {
    test('is zero when the width is at or below the max', () {
      expect(gutterFor(400), 0);
      expect(gutterFor(Breakpoints.contentMaxWidth), 0);
    });

    test('splits the extra width evenly', () {
      expect(gutterFor(1000, maxWidth: 800), 100);
    });
  });

  group('ContentWidth', () {
    testWidgets('caps the child width and centers it', (tester) async {
      tester.view.physicalSize = const Size(1600, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        const MaterialApp(
          home: ContentWidth(child: SizedBox.expand(key: Key('c'))),
        ),
      );
      final rect = tester.getRect(find.byKey(const Key('c')));
      expect(rect.width, Breakpoints.contentMaxWidth);
      expect(rect.center.dx, 800);
    });

    testWidgets('does not shrink a narrow child', (tester) async {
      tester.view.physicalSize = const Size(400, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        const MaterialApp(
          home: ContentWidth(child: SizedBox.expand(key: Key('c'))),
        ),
      );
      expect(tester.getSize(find.byKey(const Key('c'))).width, 400);
    });
  });

  group('openSong', () {
    testWidgets('hands the song to the pane when there is one', (tester) async {
      Song? opened;
      await tester.pumpWidget(
        MaterialApp(
          home: SongPaneScope(
            selectedSongId: null,
            onOpen: (s) => opened = s,
            child: Builder(
              builder: (context) => TextButton(
                onPressed: () => openSong(context, _song(7)),
                child: const Text('go'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('go'));
      expect(opened?.id, 7);
    });
  });
}
