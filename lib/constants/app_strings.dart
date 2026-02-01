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

  // ==================== Song Detail Screen ====================
  static const String temple = 'திருத்தலம்';
  static const String tune = 'சந்தம்';
  static const String lyrics = 'பாடல்';
  static const String meaning = 'பொருள்';
  static const String shareSong = 'Share this Song';
  static const String searchOnYouTube = 'Search on YouTube';
  static const String openKaumaramPage = 'Open Kaumaram Page';
  static const String share = 'Share';
  static const String addToCategories = 'Add to Categories';
  static const String createCategory = 'Create Category';
  static const String cancel = 'Cancel';
  static const String save = 'Save';

  static String songAddedToFavorites(String songTitle) =>
      'Song $songTitle added to Favorites';
  static String songRemovedFromFavorites(String songTitle) =>
      'Song $songTitle removed from Favorites';
  static String categoriesUpdated(String songTitle) =>
      'Categories updated for $songTitle';
  static String couldNotLaunchYouTube(String songTitle) =>
      'Could not launch YouTube for $songTitle';
  static const String couldNotLaunchUrl = 'Could not launch the custom URL';
  static const String invalidUrl = 'Invalid URL';

  // ==================== Categories Screen ====================
  static const String noCategoriesFound = 'No categories found.';
  static const String createNewCategory = 'Create New Category';
  static const String categoryName = 'Category Name';
  static const String pleaseEnterCategoryName = 'Please enter a category name.';
  static const String categoryMinLength = 'Category name must be at least 2 characters.';
  static const String categoryMaxLength = 'Category name must not exceed 50 characters.';
  static const String enterValidCategoryName = 'Please enter a valid category name.';
  static const String categoryExists = 'A category with this name already exists.';
  static const String errorCreatingCategory = 'Error creating category';
  static const String create = 'Create';
  static const String customCategories = 'Custom Categories';
  static const String noCustomCategories = 'No custom categories created';

  // ==================== Search Screen ====================
  static const String globalSearch = 'Global Search';
  static const String searchByTitleOrLyrics = 'Search by title or lyrics...';
  static const String startTypingToSearch = 'Start typing to search';
  static const String noResultsFound = 'No results found.';

  // ==================== Settings Screen ====================
  static const String theme = 'Theme';
  static const String current = 'Current';
  static const String chooseTheme = 'Choose Theme';
  static const String light = 'Light';
  static const String dark = 'Dark';
  static const String systemDefault = 'System Default';

  // Settings - Credits (Tamil)
  static const String creditsTitle = 'நன்றிகள்';
  static const String sriGopalaSundaram = 'ஸ்ரீ கோபால சுந்தரம்';
  static const String thiruppugazhExplanatoryText = 'திருப்புகழ் விளக்க உரை எழுதியவர்';
  static const String thiruSendhan = 'திரு. சேந்தன்';
  static const String kaumaramFounder = 'கௌமாரம் இணையதளம் நிறுவுனர்';
  static const String kaumaramTeam = 'கௌமாரம் குழுவினர்';
  static const String kaumaramCoFounders = 'கௌமாரம் இணையதளம் நிறுவுனர்';
  static const String appDevelopment = 'செயலி உருவாக்கம்';
  static const String ayilavanAni = 'அயிலவன் அணி';
  static const String contact = 'தொடர்பிற்கு';
  static const String contactEmail = 'teamayilvan@gmail.com';

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
