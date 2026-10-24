import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thiruppugazh/l10n/app_localizations.dart';
import 'package:thiruppugazh/ui/widgets/link_actions.dart';

Future<bool?> _ask(WidgetTester tester, String url, String tap) async {
  bool? answer;
  await tester.pumpWidget(
    MaterialApp(
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
            onPressed: () async => answer = await confirmOpenLink(context, url),
            child: const Text('go'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('go'));
  await tester.pumpAndSettle();
  expect(find.text('Open External Link'), findsOneWidget);
  expect(
    find.text('You are about to visit youtu.be. Continue?'),
    findsOneWidget,
  );
  await tester.tap(find.text(tap));
  await tester.pumpAndSettle();
  return answer;
}

void main() {
  testWidgets('names the site and returns true on Open', (tester) async {
    expect(await _ask(tester, 'https://youtu.be/abc', 'Open'), isTrue);
  });

  testWidgets('returns false on Cancel', (tester) async {
    expect(await _ask(tester, 'https://youtu.be/abc', 'Cancel'), isFalse);
  });
}
