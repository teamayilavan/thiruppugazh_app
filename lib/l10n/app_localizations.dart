import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ta.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ta'),
  ];

  /// No description provided for @songs.
  ///
  /// In en, this message translates to:
  /// **'Songs'**
  String get songs;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @myLibrary.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get myLibrary;

  /// No description provided for @temples.
  ///
  /// In en, this message translates to:
  /// **'Temples'**
  String get temples;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @exitAppTitle.
  ///
  /// In en, this message translates to:
  /// **'Exit App?'**
  String get exitAppTitle;

  /// No description provided for @exitAppMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to close Thiruppugazh?'**
  String get exitAppMessage;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @thiruppugazhTitle.
  ///
  /// In en, this message translates to:
  /// **'Thiruppugazh'**
  String get thiruppugazhTitle;

  /// No description provided for @noSongsFound.
  ///
  /// In en, this message translates to:
  /// **'No songs found in the database.'**
  String get noSongsFound;

  /// No description provided for @tuneNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Tune not available'**
  String get tuneNotAvailable;

  /// No description provided for @temple.
  ///
  /// In en, this message translates to:
  /// **'Temple'**
  String get temple;

  /// No description provided for @tune.
  ///
  /// In en, this message translates to:
  /// **'Tune'**
  String get tune;

  /// No description provided for @lyrics.
  ///
  /// In en, this message translates to:
  /// **'Lyrics'**
  String get lyrics;

  /// No description provided for @meaning.
  ///
  /// In en, this message translates to:
  /// **'Meaning'**
  String get meaning;

  /// No description provided for @shareSong.
  ///
  /// In en, this message translates to:
  /// **'Share this Song'**
  String get shareSong;

  /// No description provided for @searchOnYouTube.
  ///
  /// In en, this message translates to:
  /// **'Search on YouTube'**
  String get searchOnYouTube;

  /// No description provided for @openKaumaramPage.
  ///
  /// In en, this message translates to:
  /// **'Open Kaumaram Page'**
  String get openKaumaramPage;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @addToCategories.
  ///
  /// In en, this message translates to:
  /// **'Add to Categories'**
  String get addToCategories;

  /// No description provided for @createCategory.
  ///
  /// In en, this message translates to:
  /// **'Create Category'**
  String get createCategory;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deleteNote.
  ///
  /// In en, this message translates to:
  /// **'Delete Note'**
  String get deleteNote;

  /// No description provided for @deleteNoteConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this note?'**
  String get deleteNoteConfirmation;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @songAddedToFavorites.
  ///
  /// In en, this message translates to:
  /// **'Song {songTitle} added to Favorites'**
  String songAddedToFavorites(Object songTitle);

  /// No description provided for @songRemovedFromFavorites.
  ///
  /// In en, this message translates to:
  /// **'Song {songTitle} removed from Favorites'**
  String songRemovedFromFavorites(Object songTitle);

  /// No description provided for @categoriesUpdated.
  ///
  /// In en, this message translates to:
  /// **'Categories updated for {songTitle}'**
  String categoriesUpdated(Object songTitle);

  /// No description provided for @couldNotLaunchYouTube.
  ///
  /// In en, this message translates to:
  /// **'Could not launch YouTube for {songTitle}'**
  String couldNotLaunchYouTube(Object songTitle);

  /// No description provided for @couldNotLaunchUrl.
  ///
  /// In en, this message translates to:
  /// **'Could not launch the custom URL'**
  String get couldNotLaunchUrl;

  /// No description provided for @invalidUrl.
  ///
  /// In en, this message translates to:
  /// **'Invalid URL'**
  String get invalidUrl;

  /// No description provided for @noCategoriesFound.
  ///
  /// In en, this message translates to:
  /// **'No categories found.'**
  String get noCategoriesFound;

  /// No description provided for @createNewCategory.
  ///
  /// In en, this message translates to:
  /// **'Create New Category'**
  String get createNewCategory;

  /// No description provided for @categoryName.
  ///
  /// In en, this message translates to:
  /// **'Category Name'**
  String get categoryName;

  /// No description provided for @pleaseEnterCategoryName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a category name.'**
  String get pleaseEnterCategoryName;

  /// No description provided for @categoryMinLength.
  ///
  /// In en, this message translates to:
  /// **'Category name must be at least 2 characters.'**
  String get categoryMinLength;

  /// No description provided for @categoryMaxLength.
  ///
  /// In en, this message translates to:
  /// **'Category name must not exceed 50 characters.'**
  String get categoryMaxLength;

  /// No description provided for @enterValidCategoryName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid category name.'**
  String get enterValidCategoryName;

  /// No description provided for @categoryExists.
  ///
  /// In en, this message translates to:
  /// **'A category with this name already exists.'**
  String get categoryExists;

  /// No description provided for @errorCreatingCategory.
  ///
  /// In en, this message translates to:
  /// **'Error creating category'**
  String get errorCreatingCategory;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @globalSearch.
  ///
  /// In en, this message translates to:
  /// **'Global Search'**
  String get globalSearch;

  /// No description provided for @searchByTitleOrLyrics.
  ///
  /// In en, this message translates to:
  /// **'Search by title or lyrics...'**
  String get searchByTitleOrLyrics;

  /// No description provided for @startTypingToSearch.
  ///
  /// In en, this message translates to:
  /// **'Start typing to search'**
  String get startTypingToSearch;

  /// No description provided for @noResultsFound.
  ///
  /// In en, this message translates to:
  /// **'No results found.'**
  String get noResultsFound;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @current.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get current;

  /// No description provided for @chooseTheme.
  ///
  /// In en, this message translates to:
  /// **'Choose Theme'**
  String get chooseTheme;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @systemDefault.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get systemDefault;

  /// No description provided for @creditsTitle.
  ///
  /// In en, this message translates to:
  /// **'Credits'**
  String get creditsTitle;

  /// No description provided for @sriGopalaSundaram.
  ///
  /// In en, this message translates to:
  /// **'Sri Gopala Sundaram'**
  String get sriGopalaSundaram;

  /// No description provided for @thiruppugazhExplanatoryText.
  ///
  /// In en, this message translates to:
  /// **'Thiruppugazh explanatory text author'**
  String get thiruppugazhExplanatoryText;

  /// No description provided for @thiruSendhan.
  ///
  /// In en, this message translates to:
  /// **'Thiru. Sendhan'**
  String get thiruSendhan;

  /// No description provided for @kaumaramFounder.
  ///
  /// In en, this message translates to:
  /// **'Kaumaram Website founder'**
  String get kaumaramFounder;

  /// No description provided for @kaumaramTeam.
  ///
  /// In en, this message translates to:
  /// **'Kaumaram Team'**
  String get kaumaramTeam;

  /// No description provided for @kaumaramCoFounders.
  ///
  /// In en, this message translates to:
  /// **'Kaumaram website founders'**
  String get kaumaramCoFounders;

  /// No description provided for @appDevelopment.
  ///
  /// In en, this message translates to:
  /// **'App Development'**
  String get appDevelopment;

  /// No description provided for @ayilavanAni.
  ///
  /// In en, this message translates to:
  /// **'Team Ayilavan'**
  String get ayilavanAni;

  /// No description provided for @contact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contact;

  /// No description provided for @contactEmail.
  ///
  /// In en, this message translates to:
  /// **'teamayilvan@gmail.com'**
  String get contactEmail;

  /// No description provided for @anErrorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get anErrorOccurred;

  /// No description provided for @failedToLoadSongs.
  ///
  /// In en, this message translates to:
  /// **'Failed to load songs'**
  String get failedToLoadSongs;

  /// No description provided for @failedToLoadCategories.
  ///
  /// In en, this message translates to:
  /// **'Failed to load categories'**
  String get failedToLoadCategories;

  /// No description provided for @errorUpdatingFavorite.
  ///
  /// In en, this message translates to:
  /// **'Error updating favorite'**
  String get errorUpdatingFavorite;

  /// No description provided for @errorUpdatingCategories.
  ///
  /// In en, this message translates to:
  /// **'Error updating categories'**
  String get errorUpdatingCategories;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @openExternalLink.
  ///
  /// In en, this message translates to:
  /// **'Open External Link'**
  String get openExternalLink;

  /// No description provided for @openExternalLinkConfirmation.
  ///
  /// In en, this message translates to:
  /// **'You are about to visit {domain}. Continue?'**
  String openExternalLinkConfirmation(Object domain);

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// No description provided for @kaumaramDomain.
  ///
  /// In en, this message translates to:
  /// **'Kaumaram'**
  String get kaumaramDomain;

  /// No description provided for @youTubeDomain.
  ///
  /// In en, this message translates to:
  /// **'YouTube'**
  String get youTubeDomain;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @appLanguage.
  ///
  /// In en, this message translates to:
  /// **'App Language'**
  String get appLanguage;

  /// No description provided for @lyricsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Lyrics Language'**
  String get lyricsLanguage;

  /// No description provided for @englishLyricsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'English not available — showing Tamil'**
  String get englishLyricsUnavailable;

  /// No description provided for @tamil.
  ///
  /// In en, this message translates to:
  /// **'Tamil'**
  String get tamil;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @dataManagement.
  ///
  /// In en, this message translates to:
  /// **'Data Management'**
  String get dataManagement;

  /// No description provided for @exportData.
  ///
  /// In en, this message translates to:
  /// **'Export Data'**
  String get exportData;

  /// No description provided for @importData.
  ///
  /// In en, this message translates to:
  /// **'Import Data'**
  String get importData;

  /// No description provided for @importConfirmationTitle.
  ///
  /// In en, this message translates to:
  /// **'Import Backup'**
  String get importConfirmationTitle;

  /// No description provided for @importConfirmationMessage.
  ///
  /// In en, this message translates to:
  /// **'This will import data from a backup file.\n\n• Categories and Favorites will be merged.\n• Notes and Highlights will be overwritten for existing songs.\n\nDo you want to continue?'**
  String get importConfirmationMessage;

  /// No description provided for @exportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Export successful'**
  String get exportSuccess;

  /// No description provided for @exportFailed.
  ///
  /// In en, this message translates to:
  /// **'Export failed'**
  String get exportFailed;

  /// No description provided for @importSuccess.
  ///
  /// In en, this message translates to:
  /// **'Import completed successfully'**
  String get importSuccess;

  /// No description provided for @importFailed.
  ///
  /// In en, this message translates to:
  /// **'Import failed'**
  String get importFailed;

  /// No description provided for @songNote.
  ///
  /// In en, this message translates to:
  /// **'Song Note'**
  String get songNote;

  /// No description provided for @enterThoughts.
  ///
  /// In en, this message translates to:
  /// **'Enter your thoughts here!'**
  String get enterThoughts;

  /// No description provided for @shareText.
  ///
  /// In en, this message translates to:
  /// **'Share Text'**
  String get shareText;

  /// No description provided for @shareLink.
  ///
  /// In en, this message translates to:
  /// **'Share Link'**
  String get shareLink;

  /// No description provided for @searchInGoogle.
  ///
  /// In en, this message translates to:
  /// **'Search in Google'**
  String get searchInGoogle;

  /// No description provided for @removeFromFavorites.
  ///
  /// In en, this message translates to:
  /// **'Remove from favorites'**
  String get removeFromFavorites;

  /// No description provided for @addToFavorites.
  ///
  /// In en, this message translates to:
  /// **'Add to favorites'**
  String get addToFavorites;

  /// No description provided for @tapToToggleFavorite.
  ///
  /// In en, this message translates to:
  /// **'Tap to toggle favorite status'**
  String get tapToToggleFavorite;

  /// No description provided for @randomSong.
  ///
  /// In en, this message translates to:
  /// **'Random song'**
  String get randomSong;

  /// No description provided for @tapToViewRandomSong.
  ///
  /// In en, this message translates to:
  /// **'Tap to view a random song'**
  String get tapToViewRandomSong;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get loading;

  /// No description provided for @tapToAddCategories.
  ///
  /// In en, this message translates to:
  /// **'Tap to add song to categories'**
  String get tapToAddCategories;

  /// No description provided for @renameCategory.
  ///
  /// In en, this message translates to:
  /// **'Rename Category'**
  String get renameCategory;

  /// No description provided for @deleteCategoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Category'**
  String get deleteCategoryTitle;

  /// No description provided for @deleteCategoryConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{categoryName}\"? This action cannot be undone.'**
  String deleteCategoryConfirmation(Object categoryName);

  /// No description provided for @rename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get rename;

  /// No description provided for @customCategories.
  ///
  /// In en, this message translates to:
  /// **'Custom Categories'**
  String get customCategories;

  /// No description provided for @noCustomCategories.
  ///
  /// In en, this message translates to:
  /// **'No custom categories created'**
  String get noCustomCategories;

  /// No description provided for @searchFilterTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get searchFilterTitle;

  /// No description provided for @searchFilterLyrics.
  ///
  /// In en, this message translates to:
  /// **'Lyrics'**
  String get searchFilterLyrics;

  /// No description provided for @searchFilterTemple.
  ///
  /// In en, this message translates to:
  /// **'Temple'**
  String get searchFilterTemple;

  /// No description provided for @searchFilterKaumaramId.
  ///
  /// In en, this message translates to:
  /// **'Kaumaram ID'**
  String get searchFilterKaumaramId;

  /// No description provided for @checkOutSong.
  ///
  /// In en, this message translates to:
  /// **'Check out \"{songTitle}\" on the Thiruppugazh App!'**
  String checkOutSong(Object songTitle);

  /// No description provided for @tapToOpenInApp.
  ///
  /// In en, this message translates to:
  /// **'Tap to open in app:'**
  String get tapToOpenInApp;

  /// No description provided for @getTheAppHere.
  ///
  /// In en, this message translates to:
  /// **'Get the app here:'**
  String get getTheAppHere;

  /// No description provided for @genericError.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred.'**
  String get genericError;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Network error occurred.'**
  String get networkError;

  /// No description provided for @databaseError.
  ///
  /// In en, this message translates to:
  /// **'Database error occurred.'**
  String get databaseError;

  /// No description provided for @fileNotFound.
  ///
  /// In en, this message translates to:
  /// **'File not found.'**
  String get fileNotFound;

  /// No description provided for @permissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Permission denied.'**
  String get permissionDenied;

  /// No description provided for @timeout.
  ///
  /// In en, this message translates to:
  /// **'Request timed out.'**
  String get timeout;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'This field is required.'**
  String get required;

  /// No description provided for @emailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address.'**
  String get emailInvalid;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters.'**
  String get passwordTooShort;

  /// No description provided for @passwordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get passwordMismatch;

  /// No description provided for @phoneInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid phone number.'**
  String get phoneInvalid;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @noTemplesFound.
  ///
  /// In en, this message translates to:
  /// **'No temples found'**
  String get noTemplesFound;

  /// No description provided for @noSongsFoundForTemple.
  ///
  /// In en, this message translates to:
  /// **'No songs found for this temple'**
  String get noSongsFoundForTemple;

  /// No description provided for @thiruppugazhHeroImage.
  ///
  /// In en, this message translates to:
  /// **'Thiruppugazh hero image'**
  String get thiruppugazhHeroImage;

  /// No description provided for @tapToViewSongDetails.
  ///
  /// In en, this message translates to:
  /// **'Tap to view song details'**
  String get tapToViewSongDetails;

  /// No description provided for @highlights.
  ///
  /// In en, this message translates to:
  /// **'Highlights'**
  String get highlights;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @noHighlightsFound.
  ///
  /// In en, this message translates to:
  /// **'No highlights yet.'**
  String get noHighlightsFound;

  /// No description provided for @noNotesFound.
  ///
  /// In en, this message translates to:
  /// **'No notes yet.'**
  String get noNotesFound;

  /// No description provided for @highlight.
  ///
  /// In en, this message translates to:
  /// **'Highlight'**
  String get highlight;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ta'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ta':
      return AppLocalizationsTa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
