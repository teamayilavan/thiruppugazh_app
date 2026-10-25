# Marketing video: design

Date: 2026-10-25. Status: draft for owner approval. Workspace: `marketing/` (no app code is touched).

## Intent

Bring more devotees to the Thiruppugazh app by showing, honestly, what it does. After watching, a viewer should feel the app will help them **study** the songs and keep up a **daily practice**, and should want to download it from Google Play.

Honest means: real screen recordings of the real app, plain words, no hype, no fake urgency, no testimonials, no claims the app cannot back up. Its offline, no-ads, no-tracking nature is part of the pitch.

## Goals

- One recording session produces **two cuts**: Tamil voiceover and English voiceover. Both carry **English captions**, so each works muted.
- Length about **120 seconds** (a 90-second trim is possible later by merging beats 11 to 13).
- Master format **vertical 9:16** (1080x1920) for Reels, Shorts and Status. Other aspect ratios are exports for later.
- Every feature in `feature-inventory.md` appears on screen. Time is balanced; longer runs go only to features that take more steps to show.
- The viewer ends on a clear Play Store call to action.

## Non-goals and anti-goals

- Not a tutorial. No feature is explained in depth.
- No points, streaks, "limited time", "#1", or comparison to other apps.
- No claims from the inventory's "must not claim" list: iOS, in-app audio playback, memorization or quizzes, Panchangam, cloud accounts, complete English lyrics or word meanings for every song.
- No stock footage, AI-generated visuals of deities, or devotional imagery the app does not itself show. It would be a failure if the video looked like a different app.
- No tracking links or analytics in the video itself.

## Beat plan (owner-approved split, times are targets)

| Time | Beat | Covers |
|---|---|---|
| 0:00-0:08 | Hook | Why this app exists |
| 0:08-0:16 | 1 Library | Lyrics, meaning, tune, temple on a song page |
| 0:16-0:22 | 2 Word by word | Padham lyrics and meanings |
| 0:22-0:30 | 3 Search | Casual spelling, any word order |
| 0:30-0:38 | 4 Temples | Arupadai Veedu grid, temple browsing |
| 0:38-0:45 | 5 Your language | Tamil/English (app and lyrics separately), text size, light/dark |
| 0:45-0:52 | 6 Your notes | Highlights and notes |
| 0:52-1:00 | 7 Your lists | Favorites and categories |
| 1:00-1:09 | 8 Links | Look-up buttons, attach a link, share into the app |
| 1:09-1:16 | 9 Today's song | Today's Song, Random |
| 1:16-1:30 | 10 Chanting mode | Verse by verse, tune cue, Auto pace |
| 1:30-1:36 | 11 Pick up again | Continue where you left off |
| 1:36-1:43 | 12 Daily reminder | Opt-in, offline |
| 1:43-1:48 | 13 Share a song | Text or link |
| 1:48-1:56 | 14 Honest close | Offline, no ads, no tracking, backup, open source |
| 1:56-2:00 | 15 Download | Play Store |

## Pipeline (the owner's order)

1. **Script.** One shared English script and one Tamil script, each written to the beat timings above and in a form that pastes straight into ElevenLabs. The Tamil is written natively to its own timings, not translated line by line. Owner reviews both.
2. **Visual plan.** A shot list: per beat, the exact taps to record, the on-screen caption, the motion graphic (if any), and the transition.
3. **Recording.** Emulator `Medium_Phone_API_36`, screen-recorded with `adb shell screenrecord`, driven by repeatable `adb` tap scripts. A clean demo state: seeded favorites, categories, a note, a highlight, a link, a reminder. Clips recorded in both app languages where the Tamil UI is shown. Needs the owner's go-ahead before any recording run.
4. **Remotion edit.** Clips in a phone frame, burned-in English captions, Tamil typography, simple transitions, an end card.
5. **Audio and release.** Owner generates voiceover in ElevenLabs from the approved scripts; music is added and mixed; final renders for both cuts.

## Workspace layout (created when this design is approved)

```
marketing/
  DESIGN.md            this file
  feature-inventory.md
  script/              en.md, ta.md
  visuals/             shot-list.md
  recordings/          raw emulator clips, tap scripts
  remotion/            the Remotion project
  audio/               voiceover, music
  exports/             final renders
```

## Constraints

- Android only; all footage is from the emulator on the current build (`next`, 1.6.0+8).
- Windows: `adb` and the emulator live under `%LOCALAPPDATA%\Android\Sdk`, not on PATH (see CLAUDE.md).
- Tooling needed on the owner's machine: Node.js, ffmpeg. Remotion will be added inside `marketing/remotion/` only.
- Large video files should not bloat the app repo (see "Owner's call" about git).
- Following project rules: nothing here touches `lib/`, `assets/`, or `pubspec.yaml`.

## Builder's calls (mine, not the owner's)

- Remotion, 1080x1920 at 30 fps, h264 MP4.
- The phone is shown inside a simple frame on a calm background in the app's own green.
- Captions are burned into the video, large and high-contrast, in English only.
- Music: quiet, instrumental, royalty-free, ducked under the voice. No devotional recitation is used as music.
- Tamil narration register: simple, clear, spoken Tamil, not literary.
- The app name is written as "Thiruppugazh" in English captions and "திருப்புகழ்" on the end card.
- The end card shows the Play Store badge and the name only, no QR or tracking URL in the first version.
- Demo data is invented (generic note text), never a real user's.

## Left to the builder

Exact shot timings within a beat, transition style, caption wording, and how each tap is scripted.

## Owner's call (open)

- Whether `marketing/recordings`, `audio` and `exports` are git-ignored, or the whole folder is kept out of the app repo. Default proposed: commit scripts and plans, ignore large media.
