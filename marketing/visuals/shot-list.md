# Visual plan and shot list (draft 1)

Matches `script/en.md` / `script/ta.md` beat for beat. One set of recordings serves both cuts; only the voiceover track differs. Captions are the English script lines.
Everything below comes from reading the current app code (v1.6.0+8, branch `next`) and the bundled database. Items marked **verify** get confirmed on the emulator before recording.

## Look and feel

- **Canvas:** 1080x1920 (9:16), 30 fps.
- **The phone:** the emulator `Medium_Phone_API_36` records at 1080x2400 (20:9), taller than 9:16. We scale the recording to fit inside a simple phone frame on a calm background in the app's own green (from `app_theme.dart`), with room above for the caption. No cropping of the app's UI.
- **Captions:** English, large, high contrast, bottom third, one line at a time, in sync with the voiceover. Tamil text appears only as the app's own content.
- **Motion:** gentle. A soft push-in on the tapped element, a subtle tap indicator, cross-dissolves between beats. No spinning, no flashing, no sound effects.
- **Language of the footage (my call):** record the app in **Tamil** (app language and lyrics), since that is what a devotee sees. Beat 5 flips to English on screen. Tap scripts are repeatable, so an English-UI pass is cheap if you want it later.
- **Demo song:** **song 21, அங்கை மென்குழல் (Thiruchendur)** has everything: word-by-word lyrics, English transliteration, meanings, a 3-line tune, 8 verses. Final pick **verify** after viewing it.
- **Do not use songs 1 to 6 as the main demo.** The database has no word-by-word or English data for them (the changelog says they were restored without it). Beat 3 searches for `muthaitharu` (song 6) only to show the spelling-tolerant search; the song page beats use song 21.

## Clean demo state (set up once, before recording)

Fresh install of the `next` debug build, then:

- Favorites: 4 to 5 songs, including song 21.
- Two categories (for example "Morning" and "Learning") holding a few songs.
- A short, generic note on song 21 (invented text, no personal data), one highlighted verse, one saved link with a label.
- Daily reminder switched on, at a believable time.
- Device clock, battery and signal clean; no other notifications. Light theme for most beats, dark only in beat 5.
- "Continue where you left off" populated: open song 21 in chanting mode to verse 3 before beat 11.

## Shots

Taps below are the real UI paths. `FAB` = floating button.

| # | Time | Voiceover idea | On screen (what we record) | Motion graphic / caption extras | Verify |
|---|------|----------------|----------------------------|-------------------------------|--------|
| 0 | 0:00-0:08 | Hi, we're Team Ayilavan | App icon settles, then **Home**: hero image, title, "Today's Song" card. Slow scroll of the song list. | Title card: "Thiruppugazh" and "திருப்புகழ்" with "Team Ayilavan". | Home scroll looks smooth on the recording |
| 1 | 0:08-0:16 | All in one place | From Home list tap song 21. Slow scroll the **song page**: title, info card (temple, tune), lyrics, meaning. | Soft labels pop in: Lyrics, Meaning, Tune, Temple. | Info card shows temple and tune |
| 2 | 0:16-0:22 | Word by word | Continue scroll to **Word-separated Lyrics** section, then the **meaning** card. | Zoom on one line as it aligns with its words. | Section is present for song 21 |
| 3 | 0:22-0:30 | Type it the way it sounds | Home **search FAB**, type `muthaitharu` (casual spelling), results appear with song 6. Clear, type a Tamil word with a confusable letter if it reads well. | Show the typed text in the caption styling. | Result list matches; filter chips visible |
| 4 | 0:30-0:38 | Browse by temple | Bottom nav **Temples**: the 2x3 Arupadai Veedu grid with counts, tap Thiruchendur, show its songs. | Number of songs highlighted briefly. | Counts match the grid |
| 5 | 0:38-0:45 | Tamil or English, bigger text, dark | **More** (Settings): App Language and Lyrics Language dialogs, switch to English. Song page: tap A+ twice. Settings > Theme > Dark. | Cross-dissolve light to dark. | English transliteration shows on song 21 |
| 6 | 0:45-0:52 | Highlight and note | Song page: long-press and drag to select a verse, tap **Highlight** in the menu (yellow). Tap **Song Note**, type a short note, save. | Brief glow on the highlighted lines. | Context menu shows Highlight |
| 7 | 0:52-1:00 | Favorites and lists | Song page FABs: tap the heart, tap the **playlist-add** FAB, check "Morning" and save. Then **Categories** tab with the lists. | Heart pulse, list names appear. | Bottom sheet looks right in Tamil |
| 8 | 1:00-1:09 | Share a kirtan to the app | From a YouTube video in the emulator (**verify** the YouTube app or browser is installed on the AVD), tap Share, choose Thiruppugazh, pick a song, toast "Link added", returns to YouTube. Cut to **Library > Links**. | Arrow showing "back where you were". | YouTube/browser available; share-sheet target appears |
| 9 | 1:09-1:16 | A song a day | Home: **Today's Song** card, tap it. Back, tap the **shuffle FAB**. | Small "same song for everyone, all day" is not said; leave it out. | Card opens the song |
| 10 | 1:16-1:30 | Chanting mode | Song page: tap the **play icon** by "Lyrics" to open **Chanting mode**. Show large verse and tune cue, tap the tune toggle, switch **Auto**, choose a pace, let it advance a verse or two, show pause. | Slow zoom on the verse. This is the longest beat. | Auto-advance recorded without cutting mid-verse |
| 11 | 1:30-1:36 | It remembers | Leave chanting mid-song, back to **Home**: the **Continue where you left off** card ("Chanting: 3 of 8"), tap it. | Highlight the card. | Card text shows verse count |
| 12 | 1:36-1:43 | Daily reminder | **More**: Daily notification toggle on, reminder time row, pick a time. Then (**verify**) a recorded status-bar notification with the vel icon. | Clock time caption. | Notification permission is granted on the AVD |
| 13 | 1:43-1:48 | Share a song | Song page: tap **Share Text**, then **Share Link**, the system share sheet appears. | None. | Share sheet opens |
| 14 | 1:48-1:56 | Our promise | No new recording. Motion graphic over a calm backdrop: lines appear one by one: No ads, No tracking, No account, Works offline, Backed up to your own Google account. | Small "Open source" line under it. | Wording matches the app's privacy policy |
| 15 | 1:56-2:00 | Google Play | End card: app icon, "Thiruppugazh | திருப்புகழ்", Play Store badge, "Team Ayilavan". | Badge from Google's brand assets | Official badge file and rules |

## Recording plan (for the next step, after your approval)

- Launch the emulator detached from PowerShell (it hangs on first boot sometimes; kill and retry). `adb` lives at `%LOCALAPPDATA%\Android\Sdk\platform-tools`.
- Each beat is a short `adb shell input` script (tap, swipe, text) saved in `marketing/recordings/` so the same clip can be re-recorded after any app change. `adb shell screenrecord` has a 3-minute cap per file, so each beat is its own clip.
- Long-press selection (beat 6) is hard to script exactly; I'd record it with a swipe-hold and trim in the edit, falling back to a manual take with you if it looks off.
- Beat 8 needs a YouTube link to be shared from outside the app; it is the one beat that depends on another app.
- Raw clips are git-ignored; the tap scripts are committed.

## Open choices (yours)

1. **Footage language:** Tamil UI throughout (my pick), or English UI throughout? Or Tamil for both cuts and an extra English-UI take only for the English cut?
2. **Beat 8** shows a real YouTube page. OK to show YouTube's UI for a second, or would you rather use a plain browser page with a placeholder kirtan page?
3. **Play Store badge:** OK to use Google's official badge on the end card (follows their brand rules)?
