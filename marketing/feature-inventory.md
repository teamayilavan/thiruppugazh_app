# Feature inventory (v1.6.0+8)

Sources: CHANGELOG.md, README.md, l10n strings, lib/ file list, main_wrapper nav.
Status: **claimed** = from docs/strings, **verify** = confirm on the emulator before the script claims it.

Bottom nav: Songs · Temples · Categories · Library · More

## STUDY

| # | Feature | What it really does | Status |
|---|---------|---------------------|--------|
| S1 | Full song library | All 1,340 songs: lyrics (Padal), meaning (Porul), tune pattern (Santham), temple (Thiruthalam) | claimed |
| S2 | Word-by-word meanings | Word-separated lyrics (Padham) from mayuragiri.com, grouped in stanzas; hidden where no data | claimed (not every song) |
| S3 | Smart search | Ranked: number, title, opening words, rest. Forgives casual spelling (`muthaitharu`, `thirupugazh`), confusable Tamil letters, any word order, spaces optional | claimed |
| S4 | Temples + Arupadai Veedu | 2x3 grid of the six abodes with song counts, plus browse by temple | claimed |
| S5 | Tamil / English | App language and lyrics language chosen independently; English transliteration for most songs (a few Tamil only) | claimed |
| S6 | Adjustable lyric size | A-/A+, 5 sizes | claimed |
| S7 | Look it up | Buttons for YouTube, Google, Kaumaram, Mayuragiri; each asks first, naming the site | claimed |
| S8 | Highlights and notes | Highlight verses, write a personal note per song; both listed in Library | verify how a highlight is made |
| S9 | Links | Attach a kirtan video, discourse or post to a song; Library > Links groups by song | claimed |
| S10 | Share into the app | Share from YouTube/Instagram/browser, pick the song, toast, returns you to the source app | claimed |
| S11 | Categories + Favorites | Own lists, inline category creation in a bottom sheet, heart shortcut on Home | claimed |

## DAILY PRACTICE

| # | Feature | What it really does | Status |
|---|---------|---------------------|--------|
| P1 | Today's Song | Date-seeded; same song for everyone that day | claimed |
| P2 | Random song | Shuffle button on Home | claimed |
| P3 | Chanting mode | One verse at a time, large text, tune cue (hideable), screen stays awake, swipe or buttons, Auto pace 5/10/15/20/25/30s or 1 min, "Song complete" end | claimed |
| P4 | Continue where you left off | Home card: last song, and verse if chanting | claimed |
| P5 | Daily reminder | Opt-in local notification at a chosen time (default 8:00), vel icon, follows device time zone | claimed |
| P6 | Share a song | Text, or a link that opens it in the app (web fallback page if not installed) | claimed |

## TRUST (closing beat)

| # | Feature | Notes |
|---|---------|-------|
| T1 | Offline, no ads, no tracking, no accounts | README + CLAUDE.md principles |
| T2 | Backup | Android Auto Backup to the user's own Google account, plus manual Export/Import; updates tested against every earlier version |
| T3 | Open source | AGPL-3.0, GitHub link in Settings |
| T4 | Light and dark themes | Also System default |
| T5 | Android only | Play Store: org.ayilavan.thiruppugazh |

## Things the script must NOT claim

- No iOS (Android only).
- No audio or recitation playback in the app (it links out to YouTube).
- No streaks, points, progress tracking, or memorization/quiz feature (that plan is not started).
- No Panchangam/calendar (on hold).
- English lyrics are not complete for every song; word-by-word is not available for every song.
- No cloud sync or accounts; backup rides on Android's own Google Auto Backup.
