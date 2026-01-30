# Thiruppugazh App

A Flutter mobile application for browsing, searching, and managing Tamil devotional songs (Thiruppugazh). The app provides a rich experience for exploring songs with lyrics, meanings, temple details, and categorization features.

## 📱 Features

- **Song Library**: Browse complete collection of Thiruppugazh songs
- **Detailed Song View**: View song lyrics, meanings (porul), tune (santham), and temple (thiruthalam) information
- **Search Functionality**: Fast search across song titles and lyrics
- **Categories**: Organize songs into custom categories
- **Favorites System**: Mark songs as favorites for quick access
- **Share Feature**: Share songs via native sharing functionality
- **YouTube Integration**: Direct YouTube search for songs
- **Theme Support**: Light and Dark theme options with Material 3 design
- **Responsive UI**: Clean, modern interface following Material Design guidelines

## 🏗️ Architecture

The application follows a clean architecture pattern with separation of concerns:

```
lib/
├── main.dart                      # App entry point
├── constants/                     # App constants
│   ├── app_colors.dart
│   └── app_dimensions.dart
├── data/                          # Data layer
│   ├── database/
│   │   └── database_helper.dart  # SQLite database management
│   ├── models/                    # Data models
│   │   ├── song_model.dart
│   │   └── category_model.dart
│   └── repositories/              # Data repositories
│       └── song_repository.dart
├── providers/                     # State management
│   └── theme_provider.dart       # Theme state management
├── theme/                         # App theming
│   └── app_theme.dart            # Light/Dark theme definitions
└── ui/                            # UI layer
    ├── screens/                   # Screens
    │   ├── main_wrapper.dart      # Main navigation wrapper
    │   ├── home_screen.dart       # Home screen with song list
    │   ├── song_detail_screen.dart # Song detail view
    │   ├── categories_screen.dart # Categories list
    │   ├── song_list_screen.dart  # Songs in a category
    │   ├── search_screen.dart     # Search screen
    │   └── settings_screen.dart    # App settings
    └── widgets/                   # Reusable widgets
```

## 🎨 Screens

### Home Screen
- Displays hero image
- Lists all songs with numbering
- Shows song title and temple location
- Scrollable with custom scrollbar

### Song Detail Screen
- Full song lyrics (padal)
- Word-by-word meanings (porul)
- Temple information (thiruthalam)
- Tune/meter details (santham)
- Add to favorites functionality
- Add to custom categories
- Share song
- Search on YouTube
- Open Kaumaram reference page

### Categories Screen
- List of all categories
- Song count per category
- Create new custom categories
- Navigate to category-specific songs
- Special "Favorites" category (ID: 1)

### Song List Screen
- Filtered list of songs by category
- Shows Kaumaram ID and title
- Displays temple location
- Tap to view song details

### Search Screen
- Real-time search with debouncing
- Search across song titles and lyrics
- Clear search functionality
- Quick navigation to song details

### Settings Screen
- Theme selection (Light/Dark/System)
- App credits and acknowledgments
- Contact information

## 🛠️ Tech Stack

### Core Technologies
- **Flutter**: ^3.8.1 - UI Framework
- **Dart**: Programming language

### Key Packages
- `sqflite`: ^2.4.2 - SQLite database
- `sqflite_common_ffi`: ^2.3.6 - Cross-platform SQLite
- `sqlite3_flutter_libs`: ^0.5.38 - SQLite native libraries
- `provider`: ^6.1.5 - State management
- `path_provider`: ^2.1.5 - File system paths
- `share_plus`: ^11.0.0 - Sharing functionality
- `shared_preferences`: ^2.5.3 - Persistent storage
- `url_launcher`: ^6.3.2 - URL launching
- `dynamic_color`: ^1.8.1 - Dynamic theming support

### Development Tools
- `flutter_lints`: ^5.0.0 - Code linting
- `flutter_launcher_icons`: ^0.14.4 - App icon generation

## 📊 Database

The app uses SQLite database (`thiruppugazh.db`) with the following tables:

- `songs` - Song information including lyrics, meanings, and metadata
- `categories` - Song categories
- `song_categories` - Many-to-many relationship between songs and categories

For detailed schema information, see [Database Schema Documentation](docs/database-schema.md).

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.8.1 or higher)
- Dart SDK
- Android Studio / Xcode / VS Code

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd thiruppugazh
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

### Build for Production

**Android:**
```bash
flutter build apk --release
```

**iOS:**
```bash
flutter build ios --release
```

## 🎨 Theming

The app features custom theming with:

### Light Theme
- Background: Light Green (#D8EFD3)
- Primary: Green Accent (#80AF81)
- Text: Dark Green (#0D3619)

### Dark Theme
- Background: Dark Green (#1F4529)
- Primary: Green Accent (#609755)
- Text: Light (#ECECEC)

Themes are defined in `lib/theme/app_theme.dart` and use Material 3 design system.

## 📱 State Management

The app uses **Provider** package for state management:

- `SongRepository`: Manages data operations and notifies listeners
- `ThemeProvider`: Manages theme persistence and changes

State flows from Repository → Provider → Consumer Widgets

## 🔧 Key Features Implementation

### Database Management
- Singleton pattern for database connection
- Database initialization with asset copying
- FTS (Full-Text Search) for efficient song search
- Query optimization with proper indexing

### Search Implementation
- Debounced search (500ms delay)
- Search across multiple fields (title, lyrics)
- Efficient SQL LIKE queries
- Real-time results update

### Category System
- Many-to-many relationship between songs and categories
- Special handling for Favorites category (ID: 1)
- Dynamic song count calculation
- User can create custom categories

### Theme Persistence
- SharedPreferences for theme storage
- System default theme support
- Smooth theme switching

## 📄 License

This project is private and not published to pub.dev.

## 👨‍💻 Credits

### Content Contributors
- **Sri Gopala Sundaram** - Thiruppugazh explanatory text author
- **Thiru. Sendhan** - Kaumaram website founder
- **Kaumaram Team** - Kaumaram website founders

### App Development
- **Ayilavan Ani** - App development

### Contact
- Email: teamayilvan@gmail.com

## 📚 Additional Documentation

- [Database Schema](docs/database-schema.md) - Complete database structure and relationships
- [Technical Implementation](docs/technical-implementation.md) - Detailed technical architecture and implementation details

## 🤝 Contributing

This is a private project. For contributions or suggestions, please contact the development team.

## 📝 Version History

- **Version 1.0.0+1** - Initial release
  - Core song browsing functionality
  - Search across songs
  - Category management
  - Theme support
  - Favorites system
