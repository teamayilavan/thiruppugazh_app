/// Centralized string constants for the Thiruppugazh app.
/// This file contains all user-facing strings to support future internationalization.
class AppStrings {
  // Prevent instantiation
  AppStrings._();

  // ==================== Navigation ====================
  static const String songs = 'Songs';
  static const String categories = 'Categories';
  static const String search = 'Search';
  static const String settings = 'Settings';

  // ==================== Main Wrapper ====================
  static const String exitAppTitle = 'Exit App?';
  static const String exitAppMessage = 'Are you sure you want to close Thiruppugazh?';
  static const String no = 'No';
  static const String yes = 'Yes';

  // ==================== Home Screen ====================
  static const String thiruppugazhTitle = 'திருப்புகழ்';
  static const String noSongsFound = 'No songs found in the database.';
  static const String tuneNotAvailable = 'Tune not available';


  // ==================== Error Handling ====================
  static const String anErrorOccurred = 'An error occurred';
  static const String failedToLoadSongs = 'Failed to load songs';
  static const String failedToLoadCategories = 'Failed to load categories';
  static const String errorUpdatingFavorite = 'Error updating favorite';
  static const String errorUpdatingCategories = 'Error updating categories';
  static const String retry = 'Retry';

  // ==================== URL Security ====================
  static const String openExternalLink = 'Open External Link';
  static String openExternalLinkConfirmation(String domain) =>
      'You are about to visit $domain. Continue?';
  static const String open = 'Open';
  static const String kaumaramDomain = 'Kaumaram';
  static const String youTubeDomain = 'YouTube';

  // ==================== Validation ====================
  static const String favorites = 'Favorites';
}

/// String constants for error messages.
class ErrorStrings {
  ErrorStrings._();

  static const String genericError = 'An unexpected error occurred.';
  static const String networkError = 'Network error occurred.';
  static const String databaseError = 'Database error occurred.';
  static const String fileNotFound = 'File not found.';
  static const String permissionDenied = 'Permission denied.';
  static const String timeout = 'Request timed out.';
}

/// String constants for validation messages.
class ValidationStrings {
  ValidationStrings._();

  static const String required = 'This field is required.';
  static const String emailInvalid = 'Please enter a valid email address.';
  static const String passwordTooShort = 'Password must be at least 8 characters.';
  static const String passwordMismatch = 'Passwords do not match.';
  static const String phoneInvalid = 'Please enter a valid phone number.';
}
