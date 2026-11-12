# Recording notes

Emulator `Medium_Phone_API_36`, 1080x2400. Build under test: `next` debug APK (1.6.0+8).
`adb` is at `%LOCALAPPDATA%\Android\Sdk\platform-tools`, not on PATH.

## Working recipe (verified 2026-10-25)

Use **Git Bash**, with `MSYS_NO_PATHCONV=1`:

    ADB="$LOCALAPPDATA/Android/Sdk/platform-tools/adb.exe"
    "$ADB" shell screenrecord --time-limit 7 --bit-rate 16000000 /sdcard/x.mp4 &
    "$ADB" shell input swipe 540 1700 540 900 1400      # taps and swipes go here
    wait; "$ADB" pull /sdcard/x.mp4 raw/x.mp4; "$ADB" shell rm /sdcard/x.mp4
    "$ADB" exec-out screencap -p > raw/x.png            # screenshots

## Gotchas

- **Screenshots:** never use PowerShell's `>` for `screencap`; it corrupts the PNG. Use Git Bash.
- **Frame rate:** clips come out variable-rate (reported as 90000 fps). Normalise to 30 fps in the edit (`ffmpeg -vf fps=30`).
- **`screenrecord` limit:** 3 minutes per file. Each beat is its own clip.
- **A different-signature install blocks a debug install.** `adb uninstall org.ayilavan.thiruppugazh` first (this wipes the emulator's app data, which is what we want for a clean demo state).
- **List numbers are positions, not song ids.** The home list is alphabetical; song id 21 (அங்கை மென்குழல்) appears around item 10. Find songs by search in tap scripts.
- **Record the release build, not debug.** Debug builds show spinners and jank (temple list, search). Install `app-release.apk` (signed with the local key, emulator only). It is not debuggable, so DB edits use `adb root` (the emulator is `userdebug`): `adbtool.db_edit(...)` and `seed_demo.py`.
- **`uiautomator dump` takes about 2.2 s.** Look positions up *before* `Rec` starts and replay them with `tap_xy`, or the clip fills with dead time and the action lands after the clip ends. Flutter exposes labels in the dump, so most buttons can be found by text.
- **Snackbars cover the FABs.** After tapping the heart, wait about 5 s before tapping the playlist FAB; the "added to favorites" snackbar sits on top of it and swallows taps.
- **Back:** the back key did not pop the song page; an edge swipe (`swipe(4,1200,700,1200,300)`) does, but only a few seconds after a bottom sheet has closed.
- **Static tails are dropped.** `screenrecord` only writes frames when the screen changes, so a clip ends at its last change (a 9 s limit can give a 5 s file). Hold the last frame in the edit.
- **No Tamil typing.** `adb input text` cannot type Tamil; demo notes are in English.
- **Seeding is not idempotent.** `seed_demo.py` adds to whatever is in the DB. To reset one song use `db_edit`. For a fully clean state: uninstall, reinstall, launch once, run `seed_demo.py`.
- Raw clips live in `raw/` and are git-ignored. Tap scripts and this file are committed.

## Beat status (2026-10-25, release build, Tamil UI)

All screen beats are recorded (the clips are in `raw/`, git-ignored): b0 hook, b1 library, b1b meaning, b2 padham, b3 search, b4 temples, b5 language/theme, b6 notes, b7 lists, b8 share-in (YouTube), b8b links tab, b9 today/random, b10 chanting, b11 continue, b12 reminder, b13 share. Beats 14 and 15 are motion graphics (no recording).

Run order matters because the app keeps state: b10 before b11 (the continue card needs a saved verse); b5 last (it changes language and theme; reset with `pm clear`, launch once, `seed_demo.py`). The emulator's data was wiped by a restart once, so after any restart reinstall the release APK first.

**b8 uses third-party content** (YouTube results, the Yaazh Music "Kaithala Niraikani" title graphic and a KaavadiTV graphic). Both thumbnails are face-free. YouTube's results and layout change often, so re-check the frames before reusing the clip, and every control is looked up live (which leaves idle gaps; the raw clip is about 48 s and is cut to about 9 s in the edit). Consider blurring channel names, or getting permission, before publishing.

Clip lengths are not real time: `screenrecord` drops static stretches and the recorder ends at the last change, so check the last frame (`ffmpeg -sseof -0.3`), not a coarse contact sheet.

Measured positions (1080x2400): nav bar y=2250 at x=108/324/540/756/972; search FAB (964,2010); song page chant icon (723,919); first lyric line hold (300,1135) then toolbar Highlight (433,1013); end-of-page buttons Note (283,1066), Add Link (797,1066), Share Text (283,1318), Share Link (797,1318); heart FAB (964,2032), playlist FAB (964,2221); category sheet first row (540,1903), Save (931,2232); chanting screen tune toggle (765,137), Manual (404,2096), Auto (675,2096), next verse (975,2243).

## 1.7.0 beats (2026-11-12, release build of `next`)

New tap scripts, one per clip: `n_search.py` (search showing the matching line), `n_share.py` (share a Chrome page into the app; needs Chrome past its first-run screens and a couple of songs opened first so the recent-songs picker is filled), `n_widget.py` (the widget must already be on the home screen), `n_set.py` (keep-screen-on and daily reminder; resets both to off first), `n_tab.py` (run on `Tablet_API_36`: 2560x1600, reading pane and arrow keys).

- Place the widget: long-press the launcher, Widgets, search "Thiruppugazh", then `input draganddrop 300 1000 300 700 2500` on the preview (a plain `swipe` does not pick it up).
- Run `python n_x.py` scripts from this folder (`python -I` drops the script directory, so `adbtool` is not found).
- Demo mode drops out when the clock changes; re-send the `com.android.systemui.demo` broadcasts (enter, clock, battery, network, notifications visible false).
- The 8:00 reminder was scheduled for 08:00 UTC on the emulator, so moving the clock did not trigger it; the notification-tap beat was not recorded.
- Tablet clip: the emulator reports 2560x1600; seed with `seed_demo.py` after the first launch, as for the phone.
