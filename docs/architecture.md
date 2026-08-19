# Application Architecture & Navigation

The application follows a standard Flutter navigation pattern using a `BottomNavigationBar` within a `Scaffold` controlled by `MainWrapper`. It also supports deep linking for direct access to song details.

## Screen Hierarchy

### Main Wrapper (`MainWrapper`)
The root widget for the authenticated/main flow. It manages the bottom navigation state and switches between the following tabs:

1.  **Home (`HomeScreen`)**
    -   Displays the list of all songs.
    -   Key Features: Search bar, Filter options, Pull-to-refresh.
    -   **Random song**: a small FAB (shuffle icon) stacked above the search FAB opens a uniformly random song, queried DB-wide (`SELECT * FROM songs ORDER BY RANDOM() LIMIT 1` — `DatabaseHelper.getRandomSong()`), not just from whatever page happens to be loaded.
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
    -   App configuration: Theme, App Language (UI), Lyrics Language (content — Tamil or, where available, English), Privacy Policy, Credits.
    -   **Navigation**: 
        -   Privacy Policy -> `PrivacyPolicyScreen`
        -   Data Import/Export -> `BackupService`

### Detail Screens

#### `SongDetailScreen`
The core view for reading a song.
-   **Features**: 
    -   View Lyrics, Meaning, and Words (Tamil, or English where available — follows the app-wide Lyrics Language setting).
    -   Add/Remove Favorites.
    -   Create Highlights (text selection).
    -   Add/Edit Notes.
    -   Share content.

#### `AddToCategoryDialog`
Shown from `SongDetailScreen`'s "add to categories" FAB.
-   Checkbox list of existing categories (Favorites excluded — that's a separate FAB).
-   **Create inline**: a text field + "+" button lets you type a new category name without leaving the dialog. It's staged locally (removable via an ✕ icon) until the dialog's Save button is tapped — Cancel discards it, same as unchecking an existing category. On Save, staged names are created (`SongRepository.createCategory`) and the song is linked to them in the same pass. Added to remove the friction of having no categories to pick from on first use.

#### `PrivacyPolicyScreen`
Displays the privacy policy in Tamil and English.

## Navigation Flow

-   **Deep Linking**:
    -   Protocol: `thiruppugazh://song/{id}` (custom scheme) or `https://thiruppugazh.ayilavan.org/song/{id}` (Android App Link / iOS Universal Link).
    -   Parsed and handled in `MainWrapper._handleDeepLink`, navigates directly to `SongDetailScreen` on launch or resume.
    -   `share_plus`-based sharing (`SongDetailScreen._shareSongLink`) generates the `https://` form.
    -   **Platform registration**: `android/app/src/main/AndroidManifest.xml` has `<intent-filter>`s for both the custom scheme and the `autoVerify="true"` App Link on `MainActivity`; iOS uses the Associated Domains entitlement in `ios/Runner/Runner.entitlements`. (These were missing entirely on Android until 2026-08-19 — the Dart-side handler existed but nothing on the platform side ever routed a tapped link into the app.)
    -   Android App Link auto-verification requires `https://thiruppugazh.ayilavan.org/.well-known/assetlinks.json` to be reachable and match the release signing cert — see `docs/web-app.md`.
    -   **Fallback when the app isn't installed**: `web_app/` is a static site (see `docs/web-app.md`) hosted at the same domain, rendering the actual song content plus a "get the app" prompt, so a shared link isn't a dead end for non-app users.

-   **Back Navigation**:
    -   Standard stack-based navigation (`Navigator.push`/`pop`).
    -   Hardware back button on Android is handled to confirm exit on the main tabs.

## State Management
-   **Provider Pattern**: Used for state management across the app.
-   `SongRepository`: Interacts with `DatabaseHelper`.
-   `SongListProvider`: Manages the list of songs and search filters.
-   `ThemeProvider`: Manages light/dark mode.
-   `LanguageProvider`: Manages the app's UI localization (English/Tamil).
-   `LyricsLanguageProvider`: Manages which language *song content* (lyrics, meanings, tune) displays in — independent of the UI language above; falls back to Tamil for the 7 songs without English content.
