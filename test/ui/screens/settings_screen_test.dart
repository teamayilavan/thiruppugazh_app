import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thiruppugazh/l10n/app_localizations.dart';
import 'package:thiruppugazh/providers/auto_backup_status_provider.dart';
import 'package:thiruppugazh/providers/keep_screen_on_provider.dart';
import 'package:thiruppugazh/providers/language_provider.dart';
import 'package:thiruppugazh/providers/lyrics_language_provider.dart';
import 'package:thiruppugazh/providers/reminder_settings_provider.dart';
import 'package:thiruppugazh/providers/theme_provider.dart';
import 'package:thiruppugazh/ui/screens/settings_screen.dart';

Widget _wrapped() {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ChangeNotifierProvider(create: (_) => LyricsLanguageProvider()),
      ChangeNotifierProvider(create: (_) => ReminderSettingsProvider()),
      ChangeNotifierProvider(create: (_) => AutoBackupStatusProvider()),
      ChangeNotifierProvider(create: (_) => KeepScreenOnProvider()),
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

  testWidgets('shows the Mayuragiri credit block but no link button', (
    tester,
  ) async {
    await tester.pumpWidget(_wrapped());
    await tester.pumpAndSettle();
    // The credit sits at the bottom of a long list.
    await tester.scrollUntilVisible(find.text('Mayuragiri.com Team'), 300);

    expect(find.text('Mayuragiri.com Team'), findsOneWidget);
    expect(find.text('Thiru. Subramaniyan, Devakottai'), findsOneWidget);

    // The outbound link button was intentionally removed -- the credit
    // text is enough, no button to visit mayuragiri.com.
    expect(find.byIcon(Icons.language), findsNothing);
    expect(
      find.widgetWithText(OutlinedButton, 'Visit Mayuragiri.com'),
      findsNothing,
    );
  });

  testWidgets('keeping the screen on while reading is an opt-in switch', (
    tester,
  ) async {
    await tester.pumpWidget(_wrapped());
    await tester.pumpAndSettle();

    final tile = find.widgetWithText(
      SwitchListTile,
      'Keep the screen on while reading',
    );
    expect(tile, findsOneWidget);
    expect(tester.widget<SwitchListTile>(tile).value, isFalse);

    await tester.tap(tile);
    await tester.pumpAndSettle();
    expect(tester.widget<SwitchListTile>(tile).value, isTrue);

    final provider = Provider.of<KeepScreenOnProvider>(
      tester.element(find.byType(SettingsScreen)),
      listen: false,
    );
    expect(provider.enabled, isTrue);
  });
}
