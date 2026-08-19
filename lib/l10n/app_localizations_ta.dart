// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Tamil (`ta`).
class AppLocalizationsTa extends AppLocalizations {
  AppLocalizationsTa([String locale = 'ta']) : super(locale);

  @override
  String get songs => 'பாடல்கள்';

  @override
  String get categories => 'வகைகள்';

  @override
  String get search => 'தேடு';

  @override
  String get settings => 'அமைப்புகள்';

  @override
  String get myLibrary => 'தொகுப்பு';

  @override
  String get temples => 'கோயில்கள்';

  @override
  String get more => 'மேலும்';

  @override
  String get exitAppTitle => 'செயலியை வெளியேற?';

  @override
  String get exitAppMessage => 'திருப்புகழ் செயலியை மூட விரும்புகிறீர்களா?';

  @override
  String get no => 'இல்லை';

  @override
  String get yes => 'ஆம்';

  @override
  String get thiruppugazhTitle => 'திருப்புகழ்';

  @override
  String get noSongsFound => 'தரவுத்தளத்தில் பாடல்கள் எதுவும் இல்லை.';

  @override
  String get tuneNotAvailable => 'சந்தம் கிடைக்கவில்லை';

  @override
  String get temple => 'திருத்தலம்';

  @override
  String get tune => 'சந்தம்';

  @override
  String get lyrics => 'பாடல்';

  @override
  String get meaning => 'பொருள்';

  @override
  String get shareSong => 'இந்த பாடலை பகிர்';

  @override
  String get searchOnYouTube => 'YouTube இல் தேடு';

  @override
  String get openKaumaramPage => 'கௌமாரம் பக்கத்தை திற';

  @override
  String get share => 'பகிர்';

  @override
  String get addToCategories => 'வகைகளில் சேர்';

  @override
  String get createCategory => 'வகை உருவாக்கு';

  @override
  String get cancel => 'ரத்துசெய்';

  @override
  String get save => 'சேமி';

  @override
  String get delete => 'நீக்கு';

  @override
  String get deleteNote => 'குறிப்பை நீக்கு';

  @override
  String get deleteNoteConfirmation =>
      'இந்தக் குறிப்பை நிச்சயமாக நீக்க விரும்புகிறீர்களா?';

  @override
  String get favorites => 'பிடித்தவை';

  @override
  String songAddedToFavorites(Object songTitle) {
    return 'பாடல் $songTitle பிடித்தவையில் சேர்க்கப்பட்டது';
  }

  @override
  String songRemovedFromFavorites(Object songTitle) {
    return 'பாடல் $songTitle பிடித்தவையிலிருந்து அகற்றப்பட்டது';
  }

  @override
  String categoriesUpdated(Object songTitle) {
    return '$songTitle க்கான வகைகள் புதுப்பிக்கப்பட்டன';
  }

  @override
  String couldNotLaunchYouTube(Object songTitle) {
    return '$songTitle க்கு YouTube ஐ திறக்க முடியவில்லை';
  }

  @override
  String get couldNotLaunchUrl => 'தனிப்பயன் URL ஐ திறக்க முடியவில்லை';

  @override
  String get invalidUrl => 'தவறான URL';

  @override
  String get noCategoriesFound => 'வகைகள் எதுவும் இல்லை.';

  @override
  String get createNewCategory => 'புதிய வகையை உருவாக்கு';

  @override
  String get categoryName => 'வகையின் பெயர்';

  @override
  String get pleaseEnterCategoryName => 'தயவுசெய்து வகையின் பெயரை உள்ளிடவும்.';

  @override
  String get categoryMinLength =>
      'வகையின் பெயர் குறைந்தது 2 எழுத்துக்கள் இருக்க வேண்டும்.';

  @override
  String get categoryMaxLength =>
      'வகையின் பெயர் 50 எழுத்துக்களுக்கு மேல் இருக்கக்கூடாது.';

  @override
  String get enterValidCategoryName =>
      'தயவுசெய்து சரியான வகையின் பெயரை உள்ளிடவும்.';

  @override
  String get categoryExists => 'இந்த பெயரில் ஏற்கனவே ஒரு வகை உள்ளது.';

  @override
  String get errorCreatingCategory => 'வகையை உருவாக்குவதில் பிழை';

  @override
  String get create => 'உருவாக்கு';

  @override
  String get globalSearch => 'உலகளாவிய தேடல்';

  @override
  String get searchByTitleOrLyrics => 'தலைப்பு அல்லது பாடல்வரிகளால் தேடு...';

  @override
  String get startTypingToSearch => 'தேட தட்டச்சு செய்யவும்';

  @override
  String get noResultsFound => 'முடிவுகள் எதுவும் இல்லை.';

  @override
  String get theme => 'கருப்பொருள்';

  @override
  String get current => 'தற்போதுள்ளது';

  @override
  String get chooseTheme => 'கருப்பொருளைத் தேர்வுசெய்';

  @override
  String get light => 'ஒளி';

  @override
  String get dark => 'இருள்';

  @override
  String get systemDefault => 'கணினி இயல்புநிலை';

  @override
  String get creditsTitle => 'நன்றிகள்';

  @override
  String get sriGopalaSundaram => 'ஸ்ரீ கோபால சுந்தரம்';

  @override
  String get thiruppugazhExplanatoryText => 'திருப்புகழ் விளக்க உரை எழுதியவர்';

  @override
  String get thiruSendhan => 'திரு. சேந்தன்';

  @override
  String get kaumaramFounder => 'கௌமாரம் இணையதளம் நிறுவுனர்';

  @override
  String get kaumaramTeam => 'கௌமாரம் குழுவினர்';

  @override
  String get kaumaramCoFounders => 'கௌமாரம் இணையதளம் நிறுவுனர்';

  @override
  String get appDevelopment => 'செயலி உருவாக்கம்';

  @override
  String get ayilavanAni => 'அயிலவன் அணி';

  @override
  String get contact => 'தொடர்பிற்கு';

  @override
  String get contactEmail => 'teamayilvan@gmail.com';

  @override
  String get anErrorOccurred => 'ஒரு பிழை ஏற்பட்டது';

  @override
  String get failedToLoadSongs => 'பாடல்களை ஏற்றுவதில் தோல்வி';

  @override
  String get failedToLoadCategories => 'வகைகளை ஏற்றுவதில் தோல்வி';

  @override
  String get errorUpdatingFavorite => 'பிடித்தவையை புதுப்பிப்பதில் பிழை';

  @override
  String get errorUpdatingCategories => 'வகைகளை புதுப்பிப்பதில் பிழை';

  @override
  String get retry => 'மீண்டும் முயற்சி';

  @override
  String get openExternalLink => 'வெளிப்புற இணைப்பைத் திற';

  @override
  String openExternalLinkConfirmation(Object domain) {
    return 'நீங்கள் $domain க்குச் செல்லப்போகிறீர்கள். தொடரவா?';
  }

  @override
  String get open => 'திற';

  @override
  String get kaumaramDomain => 'கௌமாரம்';

  @override
  String get youTubeDomain => 'YouTube';

  @override
  String get language => 'மொழி';

  @override
  String get appLanguage => 'பயன்பாட்டு மொழி';

  @override
  String get lyricsLanguage => 'பாடல் மொழி';

  @override
  String get englishLyricsUnavailable =>
      'ஆங்கிலம் இல்லை — தமிழில் காட்டப்படுகிறது';

  @override
  String get tamil => 'தமிழ்';

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
  String get songNote => 'பாடல் குறிப்பு';

  @override
  String get enterThoughts => 'உங்கள் எண்ணங்களை இங்கே உள்ளிடவும்!';

  @override
  String get shareText => 'உரையைப் பகிர்';

  @override
  String get shareLink => 'இணைப்பைப் பகிர்';

  @override
  String get searchInGoogle => 'Google இல் தேடு';

  @override
  String get removeFromFavorites => 'பிடித்தவையிலிருந்து நீக்கு';

  @override
  String get addToFavorites => 'பிடித்தவையில் சேர்';

  @override
  String get tapToToggleFavorite => 'பிடித்தவை நிலையை மாற்ற தட்டவும்';

  @override
  String get randomSong => 'சீரற்ற பாடல்';

  @override
  String get tapToViewRandomSong => 'ஒரு சீரற்ற பாடலைக் காண தட்டவும்';

  @override
  String get loading => 'ஏற்றப்படுகிறது';

  @override
  String get tapToAddCategories => 'வகைகளில் சேர்க்க தட்டவும்';

  @override
  String get renameCategory => 'வகையை மறுபெயரிடு';

  @override
  String get deleteCategoryTitle => 'வகையை நீக்கு';

  @override
  String deleteCategoryConfirmation(Object categoryName) {
    return '\"$categoryName\" வகையை நிச்சயமாக நீக்க விரும்புகிறீர்களா? இச்செயலை ரத்து செய்ய முடியாது.';
  }

  @override
  String get rename => 'மறுபெயரிடு';

  @override
  String get customCategories => 'தனிப்பயன் வகைகள்';

  @override
  String get noCustomCategories =>
      'தனிப்பயன் வகைகள் எதுவும் உருவாக்கப்படவில்லை';

  @override
  String get searchFilterTitle => 'தலைப்பு';

  @override
  String get searchFilterLyrics => 'பாடல் வரிகள்';

  @override
  String get searchFilterTemple => 'திருத்தலம்';

  @override
  String get searchFilterKaumaramId => 'கௌமாரம் எண்';

  @override
  String checkOutSong(Object songTitle) {
    return 'திருப்புகழ் செயலியில் \"$songTitle\" பாடலைப் பாருங்கள்!';
  }

  @override
  String get tapToOpenInApp => 'செயலியில் திறக்க தட்டவும்:';

  @override
  String get getTheAppHere => 'செயலியை இங்கே பெறவும்:';

  @override
  String get genericError => 'எதிர்பாராத பிழை ஏற்பட்டது.';

  @override
  String get networkError => 'பிணைய பிழை ஏற்பட்டது.';

  @override
  String get databaseError => 'தரவுத்தள பிழை ஏற்பட்டது.';

  @override
  String get fileNotFound => 'கோப்பு காணப்படவில்லை.';

  @override
  String get permissionDenied => 'அனுமதி மறுக்கப்பட்டது.';

  @override
  String get timeout => 'கோரிக்கை காலாவதியானது.';

  @override
  String get required => 'இலம் கட்டாயம் நிரப்பப்பட வேண்டும்.';

  @override
  String get emailInvalid => 'சரியான மின்னஞ்சல் முகவரியை உள்ளிடவும்.';

  @override
  String get passwordTooShort =>
      'கடவுச்சொல் குறைந்தது 8 எழுத்துக்கள் இருக்க வேண்டும்.';

  @override
  String get passwordMismatch => 'கடவுச்சொற்கள் பொருந்தவில்லை.';

  @override
  String get phoneInvalid => 'சரியான தொலைபேசி எண்ணை உள்ளிடவும்.';

  @override
  String get title => 'தலைப்பு';

  @override
  String get noTemplesFound => 'கோயில்கள் எதுவும் காணப்படவில்லை';

  @override
  String get noSongsFoundForTemple => 'இந்த கோயிலுக்கான பாடல்கள் எதுவும் இல்லை';

  @override
  String get thiruppugazhHeroImage => 'திருப்புகழ் முகப்பு படம்';

  @override
  String get tapToViewSongDetails => 'பாடல் விவரங்களைக் காண தட்டவும்';

  @override
  String get highlights => 'சிறப்பம்சங்கள்';

  @override
  String get notes => 'குறிப்புகள்';

  @override
  String get noHighlightsFound => 'சிறப்பம்சங்கள் எதுவும் இல்லை.';

  @override
  String get noNotesFound => 'குறிப்புகள் எதுவும் இல்லை.';

  @override
  String get highlight => 'வண்ணமிடு';

  @override
  String get privacyPolicy => 'தனியுரிமைக் கொள்கை';

  @override
  String get viewSourceCode => 'GitHub-இல் மூலக் குறியீட்டைக் காண்க';
}
