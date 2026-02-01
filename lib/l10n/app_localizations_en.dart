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
  String get kaumaramFounder => 'Kaumaram website founder';

  @override
  String get kaumaramTeam => 'Kaumaram Team';

  @override
  String get kaumaramCoFounders => 'Kaumaram website founders';

  @override
  String get appDevelopment => 'App Development';

  @override
  String get ayilavanAni => 'Ayilavan Ani';

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
}
