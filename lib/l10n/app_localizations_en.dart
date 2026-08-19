// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get songs => 'Songs';

  @override
  String get categories => 'Categories';

  @override
  String get search => 'Search';

  @override
  String get settings => 'Settings';

  @override
  String get myLibrary => 'Library';

  @override
  String get temples => 'Temples';

  @override
  String get more => 'More';

  @override
  String get exitAppTitle => 'Exit App?';

  @override
  String get exitAppMessage => 'Are you sure you want to close Thiruppugazh?';

  @override
  String get no => 'No';

  @override
  String get yes => 'Yes';

  @override
  String get thiruppugazhTitle => 'Thiruppugazh';

  @override
  String get noSongsFound => 'No songs found in the database.';

  @override
  String get tuneNotAvailable => 'Tune not available';

  @override
  String get temple => 'Temple';

  @override
  String get tune => 'Tune';

  @override
  String get lyrics => 'Lyrics';

  @override
  String get meaning => 'Meaning';

  @override
  String get shareSong => 'Share this Song';

  @override
  String get searchOnYouTube => 'Search on YouTube';

  @override
  String get openKaumaramPage => 'Open Kaumaram Page';

  @override
  String get share => 'Share';

  @override
  String get addToCategories => 'Add to Categories';

  @override
  String get createCategory => 'Create Category';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get deleteNote => 'Delete Note';

  @override
  String get deleteNoteConfirmation =>
      'Are you sure you want to delete this note?';

  @override
  String get favorites => 'Favorites';

  @override
  String songAddedToFavorites(Object songTitle) {
    return 'Song $songTitle added to Favorites';
  }

  @override
  String songRemovedFromFavorites(Object songTitle) {
    return 'Song $songTitle removed from Favorites';
  }

  @override
  String categoriesUpdated(Object songTitle) {
    return 'Categories updated for $songTitle';
  }

  @override
  String couldNotLaunchYouTube(Object songTitle) {
    return 'Could not launch YouTube for $songTitle';
  }

  @override
  String get couldNotLaunchUrl => 'Could not launch the custom URL';

  @override
  String get invalidUrl => 'Invalid URL';

  @override
  String get noCategoriesFound => 'No categories found.';

  @override
  String get createNewCategory => 'Create New Category';

  @override
  String get categoryName => 'Category Name';

  @override
  String get pleaseEnterCategoryName => 'Please enter a category name.';

  @override
  String get categoryMinLength =>
      'Category name must be at least 2 characters.';

  @override
  String get categoryMaxLength =>
      'Category name must not exceed 50 characters.';

  @override
  String get enterValidCategoryName => 'Please enter a valid category name.';

  @override
  String get categoryExists => 'A category with this name already exists.';

  @override
  String get errorCreatingCategory => 'Error creating category';

  @override
  String get create => 'Create';

  @override
  String get globalSearch => 'Global Search';

  @override
  String get searchByTitleOrLyrics => 'Search by title or lyrics...';

  @override
  String get startTypingToSearch => 'Start typing to search';

  @override
  String get noResultsFound => 'No results found.';

  @override
  String get theme => 'Theme';

  @override
  String get current => 'Current';

  @override
  String get chooseTheme => 'Choose Theme';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get systemDefault => 'System Default';

  @override
  String get creditsTitle => 'Credits';

  @override
  String get sriGopalaSundaram => 'Sri Gopala Sundaram';

  @override
  String get thiruppugazhExplanatoryText =>
      'Thiruppugazh explanatory text author';

  @override
  String get thiruSendhan => 'Thiru. Sendhan';

  @override
  String get kaumaramFounder => 'Kaumaram Website founder';

  @override
  String get kaumaramTeam => 'Kaumaram Team';

  @override
  String get kaumaramCoFounders => 'Kaumaram website founders';

  @override
  String get appDevelopment => 'App Development';

  @override
  String get ayilavanAni => 'Team Ayilavan';

  @override
  String get contact => 'Contact';

  @override
  String get contactEmail => 'teamayilvan@gmail.com';

  @override
  String get anErrorOccurred => 'An error occurred';

  @override
  String get failedToLoadSongs => 'Failed to load songs';

  @override
  String get failedToLoadCategories => 'Failed to load categories';

  @override
  String get errorUpdatingFavorite => 'Error updating favorite';

  @override
  String get errorUpdatingCategories => 'Error updating categories';

  @override
  String get retry => 'Retry';

  @override
  String get openExternalLink => 'Open External Link';

  @override
  String openExternalLinkConfirmation(Object domain) {
    return 'You are about to visit $domain. Continue?';
  }

  @override
  String get open => 'Open';

  @override
  String get kaumaramDomain => 'Kaumaram';

  @override
  String get youTubeDomain => 'YouTube';

  @override
  String get language => 'Language';

  @override
  String get appLanguage => 'App Language';

  @override
  String get lyricsLanguage => 'Lyrics Language';

  @override
  String get englishLyricsUnavailable =>
      'English not available — showing Tamil';

  @override
  String get tamil => 'Tamil';

  @override
  String get english => 'English';

  @override
  String get dataManagement => 'Data Management';

  @override
  String get exportData => 'Export Data';

  @override
  String get importData => 'Import Data';

  @override
  String get importConfirmationTitle => 'Import Backup';

  @override
  String get importConfirmationMessage =>
      'This will import data from a backup file.\n\n• Categories and Favorites will be merged.\n• Notes and Highlights will be overwritten for existing songs.\n\nDo you want to continue?';

  @override
  String get exportSuccess => 'Export successful';

  @override
  String get exportFailed => 'Export failed';

  @override
  String get importSuccess => 'Import completed successfully';

  @override
  String get importFailed => 'Import failed';

  @override
  String get songNote => 'Song Note';

  @override
  String get enterThoughts => 'Enter your thoughts here!';

  @override
  String get shareText => 'Share Text';

  @override
  String get shareLink => 'Share Link';

  @override
  String get searchInGoogle => 'Search in Google';

  @override
  String get removeFromFavorites => 'Remove from favorites';

  @override
  String get addToFavorites => 'Add to favorites';

  @override
  String get tapToToggleFavorite => 'Tap to toggle favorite status';

  @override
  String get randomSong => 'Random song';

  @override
  String get tapToViewRandomSong => 'Tap to view a random song';

  @override
  String get loading => 'Loading';

  @override
  String get tapToAddCategories => 'Tap to add song to categories';

  @override
  String get renameCategory => 'Rename Category';

  @override
  String get deleteCategoryTitle => 'Delete Category';

  @override
  String deleteCategoryConfirmation(Object categoryName) {
    return 'Are you sure you want to delete \"$categoryName\"? This action cannot be undone.';
  }

  @override
  String get rename => 'Rename';

  @override
  String get customCategories => 'Custom Categories';

  @override
  String get noCustomCategories => 'No custom categories created';

  @override
  String get searchFilterTitle => 'Title';

  @override
  String get searchFilterLyrics => 'Lyrics';

  @override
  String get searchFilterTemple => 'Temple';

  @override
  String get searchFilterKaumaramId => 'Kaumaram ID';

  @override
  String checkOutSong(Object songTitle) {
    return 'Check out \"$songTitle\" on the Thiruppugazh App!';
  }

  @override
  String get tapToOpenInApp => 'Tap to open in app:';

  @override
  String get getTheAppHere => 'Get the app here:';

  @override
  String get genericError => 'An unexpected error occurred.';

  @override
  String get networkError => 'Network error occurred.';

  @override
  String get databaseError => 'Database error occurred.';

  @override
  String get fileNotFound => 'File not found.';

  @override
  String get permissionDenied => 'Permission denied.';

  @override
  String get timeout => 'Request timed out.';

  @override
  String get required => 'This field is required.';

  @override
  String get emailInvalid => 'Please enter a valid email address.';

  @override
  String get passwordTooShort => 'Password must be at least 8 characters.';

  @override
  String get passwordMismatch => 'Passwords do not match.';

  @override
  String get phoneInvalid => 'Please enter a valid phone number.';

  @override
  String get title => 'Title';

  @override
  String get noTemplesFound => 'No temples found';

  @override
  String get noSongsFoundForTemple => 'No songs found for this temple';

  @override
  String get thiruppugazhHeroImage => 'Thiruppugazh hero image';

  @override
  String get tapToViewSongDetails => 'Tap to view song details';

  @override
  String get highlights => 'Highlights';

  @override
  String get notes => 'Notes';

  @override
  String get noHighlightsFound => 'No highlights yet.';

  @override
  String get noNotesFound => 'No notes yet.';

  @override
  String get highlight => 'Highlight';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get viewSourceCode => 'View Source Code on GitHub';
}
