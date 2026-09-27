import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'l10n/app_localizations.dart';

import 'data/database/database_helper.dart';
import 'data/repositories/song_repository.dart';
import 'providers/auto_backup_status_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/language_provider.dart';
import 'providers/lyrics_language_provider.dart';
import 'providers/lyrics_font_size_provider.dart';
import 'providers/reminder_settings_provider.dart';
import 'providers/song_list_provider.dart';
import 'services/auto_backup_service.dart';
import 'ui/screens/main_wrapper.dart';
import 'utils/app_logger.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  final autoBackupStatus = AutoBackupStatusProvider();
  final autoBackupService = AutoBackupService(statusProvider: autoBackupStatus);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => SongRepository()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => LanguageProvider()),
        ChangeNotifierProvider(create: (context) => LyricsLanguageProvider()),
        ChangeNotifierProvider(create: (context) => LyricsFontSizeProvider()),
        ChangeNotifierProvider(create: (context) => ReminderSettingsProvider()),
        ChangeNotifierProvider.value(value: autoBackupStatus),
        ChangeNotifierProvider(
          create: (context) => SongListProvider(
            Provider.of<SongRepository>(context, listen: false),
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );

  // Fire-and-forget: the database self-heal/copy logic (see
  // DatabaseHelper._initDatabase) must run first so wasFreshlyCreated is
  // accurate, then the one-shot silent restore check, then start watching
  // for future mutations and do the opportunistic staleness check. None of
  // this blocks the first frame.
  unawaited(() async {
    try {
      await DatabaseHelper().database;
      await autoBackupService.maybeRestore(
        isFreshDatabase: DatabaseHelper().wasFreshlyCreated,
      );
      autoBackupService.startWatchingMutations();
      // The staleness check reads lastBackupAt, so wait for the provider's
      // initial SharedPreferences load to finish first.
      await autoBackupStatus.ready;
      await autoBackupService.runOpportunisticCheck();
    } catch (e, stackTrace) {
      AppLogger.error(
        'Auto-backup startup sequence failed',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, LanguageProvider>(
      builder: (context, themeProvider, languageProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Thiruppugazh',
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale(languageProvider.currentLanguage.code),
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeProvider.themeMode,
          builder: (context, child) {
            final mediaQuery = MediaQuery.of(context);
            return MediaQuery(
              data: mediaQuery.copyWith(
                textScaler: const TextScaler.linear(0.9),
              ),
              child: child!,
            );
          },
          home: const MainWrapper(),
        );
      },
    );
  }
}
