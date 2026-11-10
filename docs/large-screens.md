# Large screens (tablets, foldables, landscape phones)

Branch: `feature/large-screens` (cut from `next`). Phones held upright are unchanged.
No data, schema, preference or backup changes.

## Rules

Everything is decided in `lib/ui/widgets/adaptive_layout.dart` (`Breakpoints`).

| Rule | Condition | Effect |
|---|---|---|
| Rail | window width >= 600 dp | Bottom bar becomes a side `NavigationRail`. Includes phones in landscape (a bottom bar would use a fifth of their height). The rail sits in a `SafeArea` so it clears a camera cutout. |
| Large screen | shortest side >= 600 dp | Tablets only. Enables per-tab navigators, the reading pane and the two-column song page. A phone in landscape is wide but short, so it is not "large". |
| Reading pane | large screen and content width >= 760 dp (about 840 dp window minus the rail) and the tab is not Settings | List column 400 dp on the left, open song on the right. |
| Two columns on the song page | large screen and the song page is >= 760 dp wide | Lyrics left, word meanings right, scrolling separately. |
| Content width | any | Lists, settings, library and lyrics cap at 720 dp and centre (`ContentWidth`, `gutterFor`). |
| Short window | height < 500 dp | Home hero image is 40% of the height instead of a fixed 350. |
| Temple grid | its own column >= 600 dp | Three across, else two. Sized from the column, not the window, because it also sits in the 400 dp list pane. |

## How it fits together

- `MainWrapper` (`lib/ui/screens/main_wrapper.dart`) owns the shell: rail or bottom bar, the selected tab, and `_selected`, the song shown in the reading pane.
- On a large screen each tab is wrapped in its own `Navigator` (`_TabNavigator`), so pages a tab opens (a temple's songs, a category, search) stay inside the tab and the rail and pane remain visible. The tabs subtree has a `GlobalKey`, so rotating or resizing between layouts keeps every tab's state.
- `SongPaneScope` (inherited widget) tells lists where a tapped song goes. `openSong(context, song)` is the only way screens open a song: it calls the pane when `onOpen` is set, otherwise pushes `SongDetailScreen` full-screen. Lists highlight the open song with `paneSelectionColor`.
- Back: the single `PopScope` in `MainWrapper` pops the visible tab's navigator first, and only then shows the exit dialog. On phones there are no tab navigators, so behaviour is as before.
- Keyboard: a `HardwareKeyboard` handler (not a focus-bound `Shortcuts`, which missed key events when nothing was focused) gives Esc (back one page in the tab) and Ctrl+F (search). It does nothing while a dialog or full-screen page is on top.
- Pushes that stay on the root navigator on purpose: Chanting mode, dialogs, bottom sheets, the share-in "pick a song" screen. Deep links open into the pane when it is showing.

## Testing

- Unit and widget tests: `test/ui/widgets/adaptive_layout_test.dart` (rules, width cap, pane hand-off, selection colour).
- Emulator: `Tablet_API_36` (Pixel Tablet, 2560x1600). Phone check on the same emulator: `wm size 1080x2400` and `wm density 420`, then `wm size reset` and `wm density reset`. For a 16:9 store screenshot: `wm size 2560x1440`, `wm density 240`. Rotation is `settings put system user_rotation 0` (landscape on this tablet) or `1` (portrait).
- adb gotchas: `input keycombination 113 34` releases Ctrl before F, so it cannot test Ctrl+F; the first key events after an install can be lost until the app has focus; a stylus-handwriting tutorial may pop up over text fields.

## Verified and not verified

Verified (debug build, emulator): rail, split view, selection highlight, per-tab back and Esc, rotation keeping state, search, chanting, bottom sheet, Settings, Library, phone portrait and landscape (including a corner cutout).

Not verified: Ctrl+F, split-screen or resized windows, a cutout on the opposite side, dark theme on a tablet, a real tablet. A signed release APK was built for sideload testing but not smoke-tested by the assistant.

## Possible follow-ups

- Arrow keys for previous and next song in the reader.
- Highlight the selected row in the Library tabs (they open songs through the pane but do not mark the row).
- Persist the open reader song across app restarts (today it starts empty).
- Play listing: tablet screenshots are in `marketing/tablet-screenshots/`.
