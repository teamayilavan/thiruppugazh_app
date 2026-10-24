/// Centralized constants for the application.
/// Contains all magic numbers and configuration values.
class AppConstants {
  AppConstants._();

  // ==================== Database Constants ====================
  static const int dbVersion = 6;
  static const String dbName = 'thiruppugazh.db';
  static const String englishDataAsset = 'assets/english_data.json';
  static const String mayuragiriDataAsset = 'assets/mayuragiri_data.json';
  static const String songFixesV5Asset = 'assets/song_fixes_v5.json';
  static const String songRestoreV5Asset = 'assets/song_restore_v5.json';

  // ==================== Preferences Keys ====================
  static const String themePrefsKey = 'themeMode';
  static const String languagePrefsKey = 'app_language';
  static const String lyricsLanguagePrefsKey = 'lyrics_language';
  static const String lyricsFontSizePrefsKey = 'lyrics_font_size';
  static const String reminderEnabledPrefsKey = 'reminder_enabled';
  static const String reminderTimePrefsKey = 'reminder_time_minutes';
  static const String autoBackupLastWriteAtPrefsKey = 'auto_backup_last_write_at';
  static const String readingStatePrefsKey = 'reading_state';
  static const String chantPaceSecondsPrefsKey = 'chant_pace_seconds';
  static const String chantAutoPrefsKey = 'chant_auto';
  static const String chantShowTunePrefsKey = 'chant_show_tune';

  // ==================== Deep Link ====================
  static const String deepLinkDomain = 'thiruppugazh.ayilavan.org';

  // ==================== Search Constants ====================
  static const int searchDebounceMs = 500;
  static const int maxSearchQueryLength = 100;

  // ==================== Category Validation ====================
  static const int categoryMinNameLength = 2;
  static const int categoryMaxNameLength = 50;

  // ==================== Pagination ====================
  static const int pageSize = 50;
  static const int defaultPage = 0;

  // ==================== Special IDs ====================
  static const int favoritesCategoryId = 1;
}
