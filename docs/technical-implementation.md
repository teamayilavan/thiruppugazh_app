# Technical Implementation Documentation

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Project Structure](#project-structure)
3. [State Management](#state-management)
4. [UI Components](#ui-components)
5. [Data Layer](#data-layer)
6. [Theming System](#theming-system)
7. [Navigation](#navigation)
8. [Search Implementation](#search-implementation)
9. [Category Management](#category-management)
10. [Platform-Specific Considerations](#platform-specific-considerations)
11. [Performance Optimizations](#performance-optimizations)
12. [Testing Strategy](#testing-strategy)

---

## Architecture Overview

The Thiruppugazh app follows a **Clean Architecture** pattern with clear separation of concerns:

```
┌─────────────────────────────────────────────┐
│           Presentation Layer (UI)           │
│  - Screens                                  │
│  - Widgets                                  │
│  - Theme Configuration                      │
└──────────────┬──────────────────────────────┘
               │
               │ Provider Pattern
               │
┌──────────────▼──────────────────────────────┐
│          Business Logic Layer              │
│  - SongRepository                          │
│  - ThemeProvider                           │
└──────────────┬──────────────────────────────┘
               │
               │ Repository Pattern
               │
┌──────────────▼──────────────────────────────┐
│            Data Layer                       │
│  - DatabaseHelper (SQLite)                 │
│  - Models (Song, Category)                 │
└─────────────────────────────────────────────┘
```

### Design Patterns Used

1. **Singleton Pattern**: Database connection management
2. **Repository Pattern**: Data access abstraction
3. **Provider Pattern**: State management
4. **Factory Pattern**: Object creation from database maps
5. **Observer Pattern**: State change notifications

---

## Project Structure

### Directory Organization

```
lib/
├── main.dart                          # App entry point
│
├── constants/                         # Global constants
│   ├── app_colors.dart               # Color constants (currently unused)
│   └── app_dimensions.dart           # Dimension constants (currently unused)
│
├── data/                             # Data layer
│   ├── database/
│   │   └── database_helper.dart      # SQLite database management
│   ├── models/                       # Data models
│   │   ├── song_model.dart           # Song entity
│   │   └── category_model.dart       # Category entity
│   └── repositories/                 # Data repositories
│       └── song_repository.dart      # Business logic for data
│
├── providers/                        # State management
│   └── theme_provider.dart           # Theme state & persistence
│
├── theme/                           # App theming
│   └── app_theme.dart              # Light/Dark theme definitions
│
└── ui/                             # Presentation layer
    ├── screens/                    # Application screens
    │   ├── main_wrapper.dart       # Bottom navigation wrapper
    │   ├── home_screen.dart        # Home - song list
    │   ├── song_detail_screen.dart # Song detail view
    │   ├── categories_screen.dart  # Categories list
    │   ├── song_list_screen.dart   # Songs in category
    │   ├── search_screen.dart      # Search functionality
    │   └── settings_screen.dart    # Settings & credits
    └── widgets/                    # Reusable components (empty)
```

### Key Files

| File | Purpose | Lines of Code |
|------|---------|---------------|
| `main.dart` | App initialization, Provider setup | 51 |
| `main_wrapper.dart` | Navigation bar, screen routing | 101 |
| `database_helper.dart` | Database operations | 155 |
| `song_repository.dart` | Data repository logic | 69 |
| `app_theme.dart` | Theme definitions | 151 |
| `theme_provider.dart` | Theme state management | 42 |

---

## State Management

### Provider Implementation

The app uses the **Provider** package for reactive state management.

### Setup in main.dart

```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (context) => SongRepository()),
    ChangeNotifierProvider(create: (context) => ThemeProvider()),
  ],
  child: const MyApp(),
)
```

### Provider Classes

#### 1. SongRepository
**File**: `lib/data/repositories/song_repository.dart`

**Responsibilities**:
- Manages data operations (CRUD)
- Notifies UI listeners of data changes
- Abstracts database operations from UI

**Methods**:
- `getAllSongs()` - Fetch all songs
- `searchSongs(query)` - Search songs
- `getAllCategories()` - Get categories with counts
- `createCategory(name)` - Create new category
- `deleteCategory(id)` - Delete category
- `addSongToCategory(songId, categoryId)` - Link song to category
- `removeSongFromCategory(songId, categoryId)` - Unlink song from category
- `getCategoryIdsForSong(songId)` - Get song's categories
- `getSongsByCategoryId(categoryId)` - Get songs in category

**State Flow**:
```
Database Operation → notifyListeners() → Consumer Widgets Rebuild
```

#### 2. ThemeProvider
**File**: `lib/providers/theme_provider.dart`

**Responsibilities**:
- Manage theme mode (Light/Dark/System)
- Persist theme preference using SharedPreferences
- Notify theme changes

**Methods**:
- `setThemeMode(mode)` - Change and persist theme
- `_loadThemeMode()` - Load saved theme on startup

**Storage**:
- Key: `"themeMode"`
- Values: `"light"`, `"dark"`, `"system"`

### Consumer Usage Example

```dart
Consumer<SongRepository>(
  builder: (context, repository, child) {
    return FutureBuilder<List<Category>>(
      future: repository.getAllCategories(),
      builder: (context, snapshot) {
        // UI updates when repository notifies listeners
      },
    );
  },
)
```

---

## UI Components

### Screen Architecture

All screens follow similar patterns:
1. **StatefulWidget** or **StatelessWidget**
2. **FutureBuilder** for async data loading
3. **Consumer** for state changes
4. **Material 3 Design** components
5. **Responsive layouts** with constraints

### Screen Details

#### 1. MainWrapper
**File**: `lib/ui/screens/main_wrapper.dart`

**Features**:
- Bottom navigation bar with 4 destinations
- IndexedStack for state preservation
- Exit confirmation dialog
- Focus management on tab switch

**Navigation Destinations**:
1. Songs (Home)
2. Categories
3. Search
4. Settings

**Key Code**:
```dart
IndexedStack(index: _selectedIndex, children: _widgetOptions)
```

#### 2. HomeScreen
**File**: `lib/ui/screens/home_screen.dart`

**Features**:
- Hero image display
- Song list with numbering
- Custom scrollbar
- Loading and error states
- Song detail navigation

**Components**:
- `CustomScrollView` with `SliverList`
- `FutureBuilder` for async song loading
- `Scrollbar` with interactive property

**Performance**:
- ScrollController properly disposed
- Focus management on init

#### 3. SongDetailScreen
**File**: `lib/ui/screens/song_detail_screen.dart`

**Features**:
- Complete song information display
- Word-by-word meanings
- Category management
- Favorites toggle
- Share functionality
- YouTube search integration
- Kaumaram website link

**Actions**:
- `_toggleFavorite()` - Add/remove from favorites
- `_shareSong()` - Share via native share sheet
- `_launchYouTubeSearch()` - Open YouTube with query
- `_launchCustomUrl()` - Open Kaumaram reference
- `_showCategoryDialog()` - Category selection dialog

**State Management**:
- `_isFavorite` boolean for heart icon state
- `categoryIds` list updated on dialog save

**UI Components**:
- `SelectableText` for lyrics and meanings
- `FloatingActionButton` for favorites and categories
- `ElevatedButton` for external actions

#### 4. CategoriesScreen
**File**: `lib/ui/screens/categories_screen.dart`

**Features**:
- List of categories with song counts
- Create new category dialog
- Dynamic song count display
- Special Favorites category (ID: 1)

**StatelessWidget** implementation:
- Uses Consumer for reactive updates
- No local state needed for list updates

#### 5. SongListScreen
**File**: `lib/ui/screens/song_list_screen.dart`

**Features**:
- Filtered songs by category
- Shows Kaumaram ID and title
- Temple location as subtitle
- Separated list items

#### 6. SearchScreen
**File**: `lib/ui/screens/search_screen.dart`

**Features**:
- Real-time search with debouncing
- Search across title and lyrics
- Clear search button
- Results count display
- Keyboard dismissal on tap

**Debounce Implementation**:
```dart
Timer? _debounce;

void _onSearchChanged(String query) {
  if (_debounce?.isActive ?? false) _debounce!.cancel();
  _debounce = Timer(const Duration(milliseconds: 500), () {
    _performSearch(query);
  });
}
```

#### 7. SettingsScreen
**File**: `lib/ui/screens/settings_screen.dart`

**Features**:
- Theme selection dialog
- Credits and acknowledgments
- Contact information

**Theme Options**:
- Light
- Dark
- System Default

---

## Data Layer

### DatabaseHelper Class

**File**: `lib/data/database/database_helper.dart`

**Pattern**: Singleton

```dart
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;
  static const String _dbName = "thiruppugazh.db";
}
```

### Database Initialization

**Process**:
1. Get application documents directory
2. Delete existing database (force replacement)
3. Load database from assets
4. Copy to documents directory
5. Open database connection

**Force Replacement Logic**:
```dart
if (await databaseExists(path)) {
  await deleteDatabase(path);
}
ByteData data = await rootBundle.load(join('assets', _dbName));
List<int> bytes = data.buffer.asUint8List(...);
await File(path).writeAsBytes(bytes, flush: true);
```

### Query Methods

| Method | Purpose | Returns |
|--------|---------|---------|
| `getAllSongs()` | Fetch all songs ordered by title | `Future<List<Song>>` |
| `searchSongs(query)` | Search by title or lyrics | `Future<List<Song>>` |
| `getCategoriesWithSongCounts()` | Get categories with song count | `Future<List<Category>>` |
| `createCategory(name)` | Insert new category | `Future<int>` |
| `deleteCategory(id)` | Delete category | `Future<void>` |
| `addSongToCategory(songId, categoryId)` | Link song to category | `Future<void>` |
| `removeSongFromCategory(songId, categoryId)` | Unlink song from category | `Future<void>` |
| `getCategoryIdsForSong(songId)` | Get song's category IDs | `Future<List<int>>` |
| `getSongsByCategoryId(categoryId)` | Get songs in category | `Future<List<Song>>` |

### Data Models

#### Song Model
**Immutability**: All fields are `final` except `categoryIds`

**Factory Constructor**:
```dart
factory Song.fromMap(Map<String, dynamic> map) {
  return Song(
    id: map['id'],
    title: map['title'] ?? ''.toString(),
    lyricsList: List<String>.from(jsonDecode(map['lyrics_list'] ?? '[]')),
    // ... other fields
  );
}
```

#### Category Model
**Calculated Field**: `songCount` is not stored, calculated at query time

---

## Theming System

### Theme Architecture

**File**: `lib/theme/app_theme.dart`

### ThemeExtension Pattern

Custom theme extension for app-specific colors:

```dart
@immutable
class AppColorExtension extends ThemeExtension<AppColorExtension> {
  const AppColorExtension({
    required this.container,
    required this.card,
    required this.textHigh,
    required this.textMuted,
  });

  final Color? container;
  final Color? card;
  final Color? textHigh;
  final Color? textMuted;
}
```

### Color Palettes

#### Light Theme
```dart
background: #D8EFD3 (Light Green)
container: #CAE8BD
card: #B3D8A8
primary: #80AF81 (Green Accent)
textHigh: #196519
text: #0D3619
```

#### Dark Theme
```dart
background: #1F4529 (Dark Green)
container: #255F38
card: #357943
primary: #609755
textHigh: #63B467
text: #ECECEC
```

### Navigation Bar Theme

Custom navigation bar styling:
```dart
navigationBarTheme: NavigationBarThemeData(
  backgroundColor: AppColors.container,
  indicatorColor: AppColors.accent,
  iconTheme: WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.selected)) {
      return const IconThemeData(color: AppColors.dbackground);
    } else {
      return IconThemeData(color: AppColors.dtextMuted);
    }
  }),
)
```

### Theme Switching

**In MyApp**:
```dart
Consumer<ThemeProvider>(
  builder: (context, themeProvider, child) {
    return MaterialApp(
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeProvider.themeMode,
      home: const MainWrapper(),
    );
  },
)
```

---

## Navigation

### Navigation Structure

```
MainWrapper (Bottom Navigation)
├── HomeScreen
│   └── SongDetailScreen
├── CategoriesScreen
│   └── SongListScreen
│       └── SongDetailScreen
├── SearchScreen
│   └── SongDetailScreen
└── SettingsScreen
```

### Navigation Patterns

#### 1. Push Navigation
```dart
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) => SongDetailScreen(song: song),
  ),
);
```

#### 2. Pop with Result
```dart
Navigator.of(dialogContext).pop();
```

#### 3. Back Button Handling
```dart
PopScope(
  canPop: false,
  onPopInvoked: (bool didPop) {
    if (didPop) return;
    // Show exit confirmation dialog
  },
)
```

---

## Search Implementation

### Search Architecture

**File**: `lib/ui/screens/search_screen.dart`

### Features

1. **Debounced Search**: 500ms delay to prevent excessive queries
2. **Multi-field Search**: Searches both title and lyrics
3. **Real-time Results**: Results update as user types
4. **Clear Functionality**: Instant clear with results reset

### Implementation

**Controller Setup**:
```dart
final TextEditingController _searchController = TextEditingController();
final FocusNode _searchFocusNode = FocusNode();
Timer? _debounce;
```

**Debounce Logic**:
```dart
void _onSearchChanged(String query) {
  if (_debounce?.isActive ?? false) _debounce!.cancel();
  _debounce = Timer(const Duration(milliseconds: 500), () {
    _performSearch(query);
  });
}
```

**Search Query**:
```sql
SELECT * FROM songs
WHERE title LIKE ? OR lyrics LIKE ?
```

**Performance Optimizations**:
- Cancel previous search before starting new one
- Empty query check before database hit
- Mounted check before setState

---

## Category Management

### Category System Architecture

**Many-to-Many Relationship**:
```
Songs ←→ SongCategories ←→ Categories
```

### Special Category: Favorites

- **ID**: 1
- **Name**: "Favorites"
- **Behavior**:
  - Cannot be deleted
  - Excluded from category creation dialog
  - Special heart icon in UI
  - Quick access floating action button

### Category Operations

#### 1. Create Category
```dart
Future<int> createCategory(String name) async {
  final result = await dbHelper.createCategory(name);
  notifyListeners();
  return result;
}
```

#### 2. Add Song to Category
```dart
Future<void> addSongToCategory(int songId, int categoryId) async {
  await dbHelper.addSongToCategory(songId, categoryId);
  notifyListeners();
}
```

#### 3. Category Selection Dialog
- Checkbox list tile for each category
- Excludes Favorites (ID: 1)
- Multiple selection support
- Batch update on save

---

## Platform-Specific Considerations

### Cross-Platform Support

**Database**:
- Uses `sqflite_common_ffi` for desktop support
- `sqflite` for mobile platforms
- `sqlite3_flutter_libs` for native libraries

### Platform Initialization

**In main.dart**:
```dart
WidgetsFlutterBinding.ensureInitialized();
sqfliteFfiInit();
databaseFactory = databaseFactoryFfi;
```

### File System Paths

**Mobile**: `getApplicationDocumentsDirectory()`
**Desktop**: Platform-specific documents directory

### Keyboard Handling

**Dismiss on Tap**:
```dart
GestureDetector(
  onTap: () {
    FocusManager.instance.primaryFocus?.unfocus();
  },
  child: Scaffold(...),
)
```

---

## Performance Optimizations

### 1. Database Optimization

- **Singleton Pattern**: Single database connection
- **Lazy Loading**: Data loaded on-demand with FutureBuilder
- **Efficient Queries**: JOINs and aggregates for category counts
- **Debouncing**: Search operations throttled

### 2. UI Optimization

- **IndexedStack**: Preserves screen state in navigation
- **Scrollbar**: Interactive scrollbar for large lists
- **CustomScrollView**: Efficient scrolling with slivers
- **ListView.builder**: Efficient list rendering

### 3. Memory Management

- **Controller Disposal**: All controllers properly disposed
- **Cancel Timers**: Debounce timer cancelled on dispose
- **Mounted Checks**: Prevent setState on disposed widgets

### 4. Network Optimization

- **Debounced Search**: Reduces unnecessary queries
- **Asset Copying**: Database copied once on initialization

---

## Testing Strategy

### Current State

**Test File**: `test/widget_test.dart`
- Basic widget test exists
- No comprehensive test suite implemented

### Recommended Tests

#### Unit Tests
- Model serialization (`Song.fromMap`, `Category.fromMap`)
- Repository methods
- Database helper queries
- Theme provider logic

#### Widget Tests
- Screen rendering
- User interactions
- Navigation flows
- Theme switching

#### Integration Tests
- End-to-end user flows
- Database operations
- State management

### Testing Tools

- `flutter_test` - Built-in testing framework
- `mockito` - Mocking (if needed)
- `integration_test` - Integration testing

---

## Best Practices Implemented

### 1. Code Organization
- Clear separation of concerns
- Consistent naming conventions
- Modular file structure

### 2. State Management
- Provider pattern for reactive updates
- Immutable data models
- Proper state propagation

### 3. Error Handling
- Try-catch blocks for async operations
- User-friendly error messages
- Graceful degradation

### 4. Code Reusability
- Reusable models
- Consistent patterns across screens
- Theme abstraction

### 5. Performance
- Efficient database queries
- Proper disposal of resources
- Debounced user input

---

## Future Enhancements

### 1. Architecture
- Implement Riverpod or Bloc for advanced state management
- Add dependency injection
- Implement repository interface pattern

### 2. Database
- Add FTS5 virtual table for faster search
- Implement database versioning and migrations
- Add offline sync capabilities
- Incremental database updates

### 3. UI/UX
- Add animations and transitions
- Implement pull-to-refresh
- Add pagination for large lists
- Improve accessibility

### 4. Features
- Song playback integration
- Lyrics synchronization
- Advanced search filters
- Export/import functionality
- Cloud backup

### 5. Testing
- Comprehensive unit tests
- Widget tests for all screens
- Integration tests for critical flows
- Performance testing

---

## Dependencies

### Core Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  sqflite: ^2.4.2
  path_provider: ^2.1.5
  path: ^1.9.1
  provider: ^6.1.5
  dynamic_color: ^1.8.1
  share_plus: ^11.0.0
  shared_preferences: ^2.5.3
  sqlite3_flutter_libs: ^0.5.38
  sqflite_common_ffi: ^2.3.6
  url_launcher: ^6.3.2
  cupertino_icons: ^1.0.8
```

### Development Dependencies

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_launcher_icons: ^0.14.4
  flutter_lints: ^5.0.0
```

---

## Conclusion

The Thiruppugazh app demonstrates a well-structured Flutter application with:
- Clean architecture principles
- Efficient state management
- Responsive UI with Material 3
- Robust data layer with SQLite
- Cross-platform compatibility
- Performance optimizations

The codebase is maintainable, scalable, and follows Flutter best practices.
