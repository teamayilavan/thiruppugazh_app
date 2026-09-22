# Application Architecture & Navigation

The application follows a standard Flutter navigation pattern using a `BottomNavigationBar` within a `Scaffold` controlled by `MainWrapper`. It also supports deep linking for direct access to song details.

## Screen Hierarchy

### Onboarding (`OnboardingScreen`)
Shown by `MainWrapper` **in place of** its normal `Scaffold` whenever `PracticeSettingsProvider.onboardingComplete` is false — a first-run gate, not a tab. One screen, one in-place state transition (picker → value-first reveal), no carousel: a sankalpam picker (four options: daily practice, meanings, temples, just looking), then immediately the corpus framed as heritage ("16,000 composed, 1,334 survived") plus one date-seeded verse and its meaning. The chosen sankalpam is persisted only on the final "continue" tap (`PracticeSettingsProvider.setSankalpam` + `markFirstRunIfUnset`) — committing on tile-tap instead would flip `onboardingComplete` immediately and `MainWrapper` (which watches it) would swap the screen away before the reveal ever showed. No explicit navigation call dismisses it; `MainWrapper` reacts to the provider flipping. See `docs/gamification-implementation-plan.md` T1.9.

### Main Wrapper (`MainWrapper`)
The root widget for the authenticated/main flow (once onboarding is complete). It manages the bottom navigation state and switches between the following tabs:

1.  **Home (`HomeScreen`)**
    -   Displays the list of all songs.
    -   Key Features: Search bar, Filter options, Pull-to-refresh.
    -   **Random song**: a small FAB (shuffle icon) stacked above the search FAB opens a uniformly random song, queried DB-wide (`SELECT * FROM songs ORDER BY RANDOM() LIMIT 1` — `DatabaseHelper.getRandomSong()`), not just from whatever page happens to be loaded.
    -   **Daily practice card** (`DailyPracticeCard`): sits below the hero image and title, above the song list; entirely absent (`SizedBox.shrink()`) when `PracticeSettingsProvider.enabled` is false. A flat, divider-bounded row (no card chrome, matching the song list's own style) showing today's hymn — pinned for the whole calendar day via `PracticeProvider.resolveTodaysHymnId()`, so finishing it does not advance the pick to a new song; only the next local date does. Tap opens `SongDetailScreen`; a leading book icon and a trailing check/chevron carry the visual weight instead of elevation. No date, no daily verse — deliberately minimal, reworked down from an earlier version that also showed the local date and a "today's grace" verse+meaning, both dropped as clutter.
    -   **Practice stats section** (`PracticeStatsSection`): sits below the daily practice card, same absent-when-disabled rule. Two flat stats side by side — days practiced, songs read — each with a leading icon, separated by a thin vertical divider, with a small caption underneath naming the corpus size (1334). Replaces an earlier inline progress bar that lived inside the daily practice card itself.
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
    -   App configuration: **Daily practice** (master opt-out for the whole gamification layer, first item, off by default — see below), Theme, App Language (UI), Lyrics Language (content — Tamil or, where available, English), Privacy Policy, Credits.
    -   **Navigation**: 
        -   Privacy Policy -> `PrivacyPolicyScreen`
        -   Data Import/Export -> `BackupService` (also covers `reading_log`/`practice_days`/`milestones` as of backup version 2 — T1.8)

### Detail Screens

#### `SongDetailScreen`
The core view for reading a song.
-   **Features**: 
    -   View Lyrics, Meaning, and Words (Tamil, or English where available — follows the app-wide Lyrics Language setting).
    -   Add/Remove Favorites.
    -   Create Highlights (text selection).
    -   Add/Edit Notes.
    -   Share content.
    -   **Dwell tracking** (T1.6, only when `PracticeSettingsProvider.enabled`): a `WidgetsBindingObserver` pauses a wall-clock accumulator on `inactive`/`hidden`/`paused`/`detached` and resumes it on `resumed` — never a `Timer.periodic`, which overcounts. Completes on either 90s of accumulated foreground time or the lyrics scroll controller reaching `maxScrollExtent`, whichever comes first. Two guards keep this honest: `maxScrollExtent <= 0` (a song short enough to need no scrolling) falls through to the dwell timer instead of completing on open, and scroll-to-end additionally requires `AppConstants.minSecondsBeforeScrollCompletion` (20s) of real foreground time — without it, a quick flick to the bottom of a short song completed it in a handful of seconds, observed on-device as 6–13s dwell times. Flushes to `PracticeProvider.recordCompletion` on completion and in `dispose`.

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
-   `PracticeSettingsProvider`: Master opt-out (`enabled`, default `false`) and onboarding state (`sankalpam`, `daysSinceFirstRun`) for the practice-tracking layer. Every practice feature checks `enabled` and renders/does nothing when it's false.
-   `PracticeProvider`: Caches `completedCount` / `totalDays` / `continuity` / `todayComplete` for the home screen, loaded on construction and refreshed after `recordCompletion` — never scans `reading_log` on build. The constructor's initial load is exposed as `ready` (a `Future<void>`) so callers — tests especially — can join that exact load instead of racing a second one. `resolveTodaysHymnId()` picks today's hymn once per local date (lowest uncompleted song id) and pins it in `SharedPreferences`, so completing it mid-day doesn't advance the pick — only a new calendar date does.
