import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thiruppugazh/constants/app_constants.dart';
import 'package:thiruppugazh/l10n/app_localizations.dart';
import 'package:thiruppugazh/providers/discover_provider.dart';
import 'package:thiruppugazh/theme/app_theme.dart';
import 'package:thiruppugazh/ui/screens/discover_screen.dart';
import 'package:thiruppugazh/ui/widgets/discover_card.dart';

/// A provider whose saved value has not been read yet.
class _NotLoaded extends DiscoverProvider {
  @override
  bool get loaded => false;
}

Future<DiscoverProvider> _pump(
  WidgetTester tester, {
  Map<String, Object> prefs = const {},
  String language = 'en',
  Size size = const Size(400, 800),
  bool notLoaded = false,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  SharedPreferences.setMockInitialValues(prefs);
  final provider = notLoaded ? _NotLoaded() : DiscoverProvider();
  await tester.runAsync(() => provider.ready);
  await tester.pumpWidget(
    ChangeNotifierProvider.value(
      value: provider,
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
        home: const Scaffold(body: DiscoverCard()),
      ),
    ),
  );
  await tester.pump();
  return provider;
}

void main() {
  testWidgets('shows when not dismissed and loaded', (tester) async {
    await _pump(tester);
    expect(find.text('New here? See what the app can do'), findsOneWidget);
  });

  testWidgets('is hidden before the saved value has been read', (tester) async {
    await _pump(tester, notLoaded: true);
    expect(find.text('New here? See what the app can do'), findsNothing);
  });

  testWidgets('is hidden when it was dismissed earlier', (tester) async {
    await _pump(
      tester,
      prefs: {AppConstants.discoverCardDismissedPrefsKey: true},
    );
    expect(find.text('New here? See what the app can do'), findsNothing);
  });

  testWidgets('the close button hides it for good and saves that', (
    tester,
  ) async {
    await _pump(tester);
    await tester.tap(find.byTooltip('Close'));
    await tester.pump();
    expect(find.text('New here? See what the app can do'), findsNothing);
    // No Discover page was opened.
    expect(find.byType(DiscoverScreen), findsNothing);

    final saved = await tester.runAsync(() async {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(AppConstants.discoverCardDismissedPrefsKey);
    });
    expect(saved, isTrue);
  });

  testWidgets('tapping the card opens Discover and dismisses it', (
    tester,
  ) async {
    final provider = await _pump(tester);
    await tester.tap(find.text('New here? See what the app can do'));
    await tester.pumpAndSettle();
    expect(find.byType(DiscoverScreen), findsOneWidget);
    expect(provider.cardDismissed, isTrue);
  });

  testWidgets('Tamil at 320 dp has no overflow and a 48 dp close button', (
    tester,
  ) async {
    await _pump(tester, language: 'ta', size: const Size(320, 640));
    expect(tester.takeException(), isNull);
    final size = tester.getSize(find.byType(IconButton));
    expect(size.width, greaterThanOrEqualTo(48));
    expect(size.height, greaterThanOrEqualTo(48));
  });
}
