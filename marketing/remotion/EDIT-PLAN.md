# Edit plan (draft 1)

**Status 2026-10-25:** music-only cut v1 is built and rendered (`../exports/thiruppugazh-music-v1.mp4`, 120 s, 1080x1920, -14 LUFS). The beat table below is the original plan; the final beat lengths and captions live in `src/timeline.ts` (they differ slightly, because beats were resized to the real clip lengths and captions were shortened for the music-only cut). See `README.md` here for how to rebuild.

How the recorded clips become the 120 s video. Beat times come from `script/en.md`; clip names from `recordings/raw/`.
Remotion is not installed yet; this is the plan it will be built from.

## Composition

- 1080x1920, 30 fps, 3600 frames (120 s). One composition per cut: `Cut-ta` and `Cut-en`. They share every visual and differ only in the voiceover track and its timing marks.
- Layers, bottom to top: background (the app's green) -> phone frame with the clip -> graphic overlays -> English caption -> voiceover and music.
- Source clips are 1080x2400, variable frame rate. Pre-process each with ffmpeg to constant 30 fps (`-vf fps=30`) before Remotion sees it. The phone frame scales the clip to about 1.0x width of a 1080 canvas minus margins, so the screen is about 860x1910 and nothing is cropped.
- Each clip's last frame is held when the clip is shorter than its beat (the recorder drops static tails).

## Beat to clip map

| Beat | Time | Clip(s) | Edit notes |
|------|------|---------|------------|
| 0 Hook | 0:00-0:08 | `b00_hook` | Splash (peacock) then Home. Title card "Thiruppugazh / திருப்புகழ் / Team Ayilavan" over the first second. |
| 1 Library | 0:08-0:16 | `b01_library`, then `b01b_meaning` | Top of the song page (temple, tune), then lyrics, then cut to the meaning card. Soft labels: Lyrics, Meaning, Tune, Temple. |
| 2 Word by word | 0:16-0:22 | `b02_padham` | Start where the "பதம் பிரித்தது" heading arrives. |
| 3 Search | 0:22-0:30 | `b03_search` | Typing `muthaitharu`, result appears. Hold the last frame. |
| 4 Temples | 0:30-0:38 | `b04_temples` | Grid, tap, list. Hold last frame. |
| 5 Language | 0:38-0:45 | `b05_language_theme` | Cut to about 7 s: the app language dialog and the flip to English, the lyrics language dialog, the theme dialog to Dark, then the song with A+ twice. Raw clip is about 42 s with idle gaps. |
| 6 Notes | 0:45-0:52 | `b06_notes` | Speed up the typing and the scroll; keep the highlight moment at real speed. |
| 7 Lists | 0:52-1:00 | `b07_lists` | Cut the snackbar wait (about 5 s) so the heart tap flows into the sheet. |
| 8 Links | 1:00-1:09 | `b08_share_in`, then `b08b_links` | About 6 s of the share flow (menu, Share, More, Thiruppugazh, typing `kaithala`, the song, the toast and the return to YouTube), then about 3 s of Library > Links. Third-party content: see README. |
| 9 Today's song | 1:09-1:16 | `b09_today` | Today's card, the song page, back, then the shuffle button and a random song. |
| 10 Chanting | 1:16-1:30 | `b10_chanting` | Longest beat: manual verse, tune cue hidden and shown, next verse, Auto at 5 s per verse, verses advancing. |
| 11 Continue | 1:30-1:36 | `b11_continue` | The "Continue where you left off" card ("8 இல் 4"), tapped, lands on the saved verse. |
| 12 Reminder | 1:36-1:43 | `b12_reminder` | Toggle on, time row, picker, 6:00 AM. |
| 13 Share | 1:43-1:48 | `b13_share` | Share text sheet, then share link sheet (shows the app link). |
| 14 Promise | 1:48-1:56 | none | Motion graphic: five lines appear one by one, "Open source" under them. |
| 15 Download | 1:56-2:00 | none | End card: icon, name, official Play badge, "Team Ayilavan". |

## Timing rules

- Cut points follow the voiceover, not the clip lengths. Once ElevenLabs audio exists, measure each line and set the beat boundaries from that, per language. Tamil runs longer, so the Tamil cut may stretch some beats and shorten the clip holds.
- Speed ramps (2x to 4x) are allowed for typing, scrolling and waiting. Taps and results stay at real speed.
- Transitions: 6-frame cross-dissolve between beats; no other effects.

## Captions

- English only, from `script/en.md`, one line at a time, bottom third, large and high contrast, safe from the platforms' UI overlays (keep text above the bottom 15 %).
- Caption timing is set from the voiceover timestamps, not guessed.

## Audio

- Voiceover from ElevenLabs (owner generates), one file per cut. Music: quiet, instrumental, royalty-free, ducked about 12 dB under the voice. Loudness target about -14 LUFS for social platforms.

## Still needed before building

- (Done) All screen clips are recorded; see `recordings/README.md` for status and caveats.
- A decision on the third-party content in beat 8 (blur channel names, or get permission).
- The voiceover files, for exact timing.
- The official Play badge file and the app icon at high resolution.
