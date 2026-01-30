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
  /// **'Kaumaram website founder'**
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
  /// **'Ayilavan Ani'**
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
