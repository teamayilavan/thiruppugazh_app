# Application Architecture & Navigation

The application follows a standard Flutter navigation pattern using a `BottomNavigationBar` within a `Scaffold` controlled by `MainWrapper`. It also supports deep linking for direct access to song details.

## Screen Hierarchy

### Main Wrapper (`MainWrapper`)
The root widget for the authenticated/main flow. It manages the bottom navigation state and switches between the following tabs:

1.  **Home (`HomeScreen`)**
    -   Displays the list of all songs.
    -   Key Features: Search bar, Filter options, Pull-to-refresh.
    -   **Navigation**: Tapping a song navigates to `SongDetailScreen`.

2.  **Temples (`TemplesScreen`)**
    -   Lists temples based on song metadata.
    -   **Navigation**: Tapping a temple navigates to a filtered list of songs for that temple.

3.  **Categories (`CategoriesScreen`)**
    -   Displays system (Favorites) and user-defined categories.
    -   **Navigation**: Tapping a category navigates to `SongListScreen` filtered by that category.

4.  **Library (`HighlightsNotesScreen`)**
    -   Aggregates user-generated content: Highlights and Notes.
    -   **Navigation**: Tapping an item navigates to the respective `SongDetailScreen`.

5.  **Settings (`SettingsScreen`)**
    -   App configuration: Theme, Language, Privacy Policy.
    -   **Navigation**: 
        -   Privacy Policy -> `PrivacyPolicyScreen`
        -   Data Import/Export -> `BackupService`

### Detail Screens

#### `SongDetailScreen`
The core view for reading a song.
-   **Features**: 
    -   View Lyrics, Meaning, and Words.
    -   Play audio (if available).
    -   Add/Remove Favorites.
    -   Create Highlights (text selection).
    -   Add/Edit Notes.
    -   Share content.

#### `PrivacyPolicyScreen`
Displays the privacy policy in Tamil and English.

## Navigation Flow

-   **Deep Linking**:
    -   Protocol: `thiruppugazh://song/{id}` or `https://thiruppugazh.ayilavan.org/song/{id}`
    -   Handled in `MainWrapper`.
    -   Navigates directly to `SongDetailScreen` on launch or resume.

-   **Back Navigation**:
    -   Standard stack-based navigation (`Navigator.push`/`pop`).
    -   Hardware back button on Android is handled to confirm exit on the main tabs.

## State Management
-   **Provider Pattern**: Used for state management across the app.
-   `SongRepository`: Interacts with `DatabaseHelper`.
-   `SongListProvider`: Manages the list of songs and search filters.
-   `ThemeProvider`: Manages light/dark mode.
-   `LanguageProvider`: Manages localization (English/Tamil).
