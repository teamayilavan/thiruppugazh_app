import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:thiruppugazh/data/models/category_model.dart';
import 'package:thiruppugazh/data/repositories/song_repository.dart';
import 'package:thiruppugazh/l10n/app_localizations.dart';
import 'package:thiruppugazh/ui/widgets/add_to_category_dialog.dart';

import '../../support/fake_song_repo.dart';

class _Repo extends FakeSongRepo {
  int categoryQueries = 0;

  @override
  Future<List<Category>> getAllCategories() async {
    categoryQueries++;
    return [
      Category(id: 1, name: 'Favorites'),
      Category(id: 2, name: 'Morning'),
    ];
  }
}

Future<_Repo> _pump(WidgetTester tester) async {
  final repo = _Repo();
  await tester.pumpWidget(
    ChangeNotifierProvider<SongRepository>.value(
      value: repo,
      child: MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: AddToCategoryDialog(
            song: testSong(1, 'Alpha Song'),
            currentCategoryIds: const [],
            onCategoryIdsChanged: (_) {},
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return repo;
}

void main() {
  testWidgets('a Tamil-only new category name is accepted', (tester) async {
    await _pump(tester);

    await tester.enterText(find.byType(TextField), 'முருகன்');
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    // Added to the pending list (shown as a checked row) with no error.
    expect(find.text('முருகன்'), findsWidgets);
    expect(find.text('Please enter a valid category name.'), findsNothing);
  });

  testWidgets('a name with no letters or digits is refused', (tester) async {
    await _pump(tester);

    await tester.enterText(find.byType(TextField), '!!');
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    expect(find.text('Please enter a valid category name.'), findsOneWidget);
  });

  testWidgets('keyboard frames keep ticked categories and do not re-query', (
    tester,
  ) async {
    final repo = await _pump(tester);
    expect(repo.categoryQueries, 1);

    await tester.tap(find.byType(CheckboxListTile));
    await tester.pump();
    expect(tester.widget<CheckboxListTile>(find.byType(CheckboxListTile)).value, isTrue);

    // The keyboard opening changes the view insets on every frame.
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    addTearDown(tester.view.resetViewInsets);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(tester.widget<CheckboxListTile>(find.byType(CheckboxListTile)).value, isTrue);
    expect(repo.categoryQueries, 1);
  });
}
