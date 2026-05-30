/// Centralized constants for the application.
/// Contains all magic numbers and configuration values.
class AppConstants {
  AppConstants._();

  // ==================== Database Constants ====================
  static const int dbVersion = 3;
  static const String dbName = 'thiruppugazh.db';
  static const String assetsPath = 'assets';
  static const String englishDataAsset = 'assets/english_data.json';

  // ==================== Preferences Keys ====================
  static const String themePrefsKey = 'themeMode';
  static const String languagePrefsKey = 'app_language';
  static const String lyricsLanguagePrefsKey = 'lyrics_language';

  // ==================== Deep Link ====================
  static const String deepLinkDomain = 'thiruppugazh.ayilavan.org';

  // ==================== Search Constants ====================
  static const int searchDebounceMs = 500;
  static const int maxSearchQueryLength = 100;
  static const int minSearchQueryLength = 2;

  // ==================== UI Dimensions ====================
  static const double heroImageHeight = 350.0;
  static const double cardBorderRadius = 12.0;
  static const double cardElevation = 2.0;
  static const double dividerThickness = 1.0;
  static const double dividerIndent = 16.0;

  // ==================== Text Sizing ====================
  static const double titleFontSize = 24.0;
  static const double bodyFontSize = 16.0;
  static const double subtitleFontSize = 12.0;
  static const double headingFontSize = 16.0;

  // ==================== Spacing ====================
  static const double spacingXSmall = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 12.0;
  static const double spacingLarge = 16.0;
  static const double spacingXLarge = 24.0;
  static const double spacingXXLarge = 32.0;
  static const double spacingXXXLarge = 48.0;

  // ==================== Category Validation ====================
  static const int categoryMinNameLength = 2;
  static const int categoryMaxNameLength = 50;

  // ==================== Pagination ====================
  static const int pageSize = 50;
  static const int defaultPage = 0;

  // ==================== Special IDs ====================
  static const int favoritesCategoryId = 1;
}

/// Animation duration constants.
class AnimationDurations {
  AnimationDurations._();

  static const Duration short = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration long = Duration(milliseconds: 500);
}

/// Border radius constants.
class BorderRadiuses {
  BorderRadiuses._();

  static const double small = 8.0;
  static const double medium = 12.0;
  static const double large = 16.0;
  static const double xLarge = 24.0;
}

/// Padding constants.
class Paddings {
  Paddings._();

  static const double xSmall = 4.0;
  static const double small = 8.0;
  static const double medium = 12.0;
  static const double large = 16.0;
  static const double xLarge = 24.0;
  static const double xxLarge = 32.0;
}
