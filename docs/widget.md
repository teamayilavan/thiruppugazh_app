# Home-screen widget: today's song

A resizable (4x2 by default) Android widget that shows the song of the day. The
user adds it from the launcher's widget picker; the app never asks them to.
Entirely offline: no network, no new permission, no new dependency, no schema or
backup change.

## How it works

| Part | File |
|---|---|
| Widget provider | `android/app/src/main/kotlin/org/ayilavan/thiruppugazh/TodaysSongWidget.kt` |
| The daily pick (port of the Dart rule) | `.../DailySong.kt` |
| Layout, size, update period | `res/layout/todays_song_widget.xml`, `res/xml/todays_song_widget_info.xml` |
| Colours (light and night) | `res/values/colors_widget.xml`, `res/values-night/colors_widget.xml` |
| Strings (English and Tamil) | `res/values/strings_widget.xml`, `res/values-ta/strings_widget.xml` |
| Manifest entry | `<receiver android:name=".TodaysSongWidget">` in `AndroidManifest.xml` |

- It opens the app's own song database **read-only** (`getDatabasePath("thiruppugazh.db")`)
  and runs `SELECT ... FROM songs ORDER BY id LIMIT 1 OFFSET <index>`, the same
  query shape as `getSongByIndex` for the Home card.
- The index comes from `DailySong.indexFor`, a Kotlin port of
  `dailySongIndexForDate` (`lib/services/daily_song_service.dart`).
  **The two must stay identical.** `test/services/daily_song_vectors_test.dart` pins the Dart
  side to fixed values; if that test must change, change `DailySong.kt` to match.
- It follows the app's language settings by reading Flutter's preferences file
  (`FlutterSharedPreferences`, keys `flutter.app_language` and `flutter.lyrics_language`):
  the label is Tamil or English, and the title and place are English when the lyrics language is
  English and the song has an English title.
- Tapping it fires `thiruppugazh://song/{id}` (the deep link the app already handles), which opens
  the song in the reading pane on a tablet or as a page on a phone. If the database does not exist yet
  or cannot be read, it shows "Open Thiruppugazh" and a tap opens the app.
- It refreshes every 3 hours and whenever the date, time or time zone changes
  (`DATE_CHANGED`, `TIME_SET`, `TIMEZONE_CHANGED`), so the song changes at midnight.

## Checked on the emulator (Pixel Tablet, API 36, debug build)

- Added from the widget picker; shows today's song; matches the Home card.
- The pick matched the Dart rule on three dates (10 Nov 2026, 14 Mar 2027, 31 Dec 2026), changed by
  moving the emulator clock, which also exercised the date-change refresh.
- Tapping opened the song in the reading pane.
- Dark theme and English (with the lyrics language set to English) rendered correctly.
- Its accessibility description reads "label. title. place".

Not checked: a signed release build (R8), a phone-sized launcher, other launchers, resizing to the
smallest size, the widget picker preview (it shows only the app icon), and a very long Tamil title
(it is limited to two lines with an ellipsis).

## Notes for testing

- A force-stopped app receives no broadcasts until it is launched once, so the widget will not follow a
  date change in that state. Launch the app, then trigger the change.
- `adb` cannot send `APPWIDGET_UPDATE`; setting the clock (`cmd alarm set-time <epoch ms>` with
  `settings put global auto_time 0`) triggers the same refresh.
