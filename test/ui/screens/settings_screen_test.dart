import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thiruppugazh/l10n/app_localizations.dart';
import 'package:thiruppugazh/providers/language_provider.dart';
import 'package:thiruppugazh/providers/lyrics_language_provider.dart';
import 'package:thiruppugazh/providers/theme_provider.dart';
import 'package:thiruppugazh/ui/screens/settings_screen.dart';

Widget _wrapped() {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ChangeNotifierProvider(create: (_) => LyricsLanguageProvider()),
    ],
    child: const MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: SettingsScreen(),
    ),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('shows the Mayuragiri credit block and link button', (
    tester,
  ) async {
    await tester.pumpWidget(_wrapped());
    await tester.pumpAndSettle();

    expect(find.text('Mayuragiri.com Team'), findsOneWidget);
    expect(find.text('Thiru. Subramaniyan, Devakottai'), findsOneWidget);

    // The link button lives further down the ListView than the default
    // cacheExtent builds eagerly, so scroll it into view before asserting.
    await tester.scrollUntilVisible(find.byIcon(Icons.language), 300.0);
    await tester.pumpAndSettle();

    expect(
      find.widgetWithText(OutlinedButton, 'Visit Mayuragiri.com'),
      findsOneWidget,
    );
  });
}
