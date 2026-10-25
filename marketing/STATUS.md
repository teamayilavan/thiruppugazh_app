# Marketing video: status and handoff

Last updated 2026-10-25 (end of session 1). Read this first when resuming.

## Where we are

A 120 s vertical (1080x1920) music-only cut is built and rendered: `exports/thiruppugazh-music-v1.mp4` (git-ignored; rebuild with `remotion/README.md`). All screen recordings exist in `recordings/raw/` (git-ignored). The voiceover cuts are not started.

| Stage | State | Where |
|---|---|---|
| Feature inventory and "must not claim" list | done | `feature-inventory.md` |
| Design (goals, pipeline, constraints) | approved | `DESIGN.md` |
| Scripts (team talking to a devotee), English and Tamil | approved by owner, Tamil still wants a native read | `script/en.md`, `script/ta.md` |
| Visual plan and shot list | done (some details changed during recording) | `visuals/shot-list.md` |
| Emulator recordings, 16 clips | done | `recordings/` (tooling committed, clips ignored) |
| Remotion project, music-only cut v1 | done | `remotion/`, `exports/` |
| Voiceover (ElevenLabs), owner generates | not started | `audio/` |
| Voiceover cuts (Tamil, English) | not started | add to `remotion/src/Root.tsx` |
| Real music track | not started (synthesized placeholder in use) | `remotion/public/music-placeholder.m4a` |

## Decisions made (owner)

- Goal: more downloads, honest and gimmick-free; the viewer should feel the app helps with study and daily practice.
- Posted to all social media; vertical 9:16 master, about 120 s.
- Two versions from one set of recordings: Tamil voiceover and English voiceover, both with English captions. For now a music-only version first; voiceover is an addition.
- Narrator is Team Ayilavan (the dev team) talking to a devotee, conversational ("we" to "you"). No invented backstory.
- Features are balanced; time follows how long a feature takes to show, and related features share a beat.
- Footage in Tamil UI; the English UI appears only in the language beat.
- Large media is git-ignored; scripts, plans, tap scripts and the Remotion source are tracked.
- Official Google Play badge on the end card. No "free" claim until the price is confirmed.

## Open items for the owner

1. **Beat 8 uses third-party YouTube content.** Face-free thumbnails, but channel names (Yaazh Music, KaavadiTV) are visible. Blur them, or get permission, before publishing.
2. **Tamil script** (`script/ta.md`) needs a native read before it goes to ElevenLabs; two word choices are flagged in the file ("செயலி" vs "பயன்பாடு", "தற்செயலாக" for random).
3. **Is the app free on Google Play?** The last line avoids saying so until confirmed.
4. **Reason for building the app.** If wanted, a one-line "why" for the opening; none was invented.
5. **Real music** to replace the placeholder (same filename, or tell me the name). It is already normalized to about -14 LUFS in the render.
6. **Speed:** the language beat runs about 3.4x and the links beat is fast; lengthen if it feels rushed.
7. **Open source** is on the end card but not spoken; say if it should be spoken.

## Next steps

1. Review `exports/thiruppugazh-music-v1.mp4` end to end and note changes (captions, speed, beat order, the third-party content).
2. Owner generates the ElevenLabs voiceover from the paste-ready blocks in `script/en.md` and `script/ta.md` into `audio/`.
3. Measure each line's length, then add `Cut-ta` and `Cut-en` compositions: full English captions from `script/en.md`, beat lengths from the audio, music ducked about 12 dB under the voice.
4. Swap in the real music, render, run the loudness pass, export 9:16 (and 1:1 or 16:9 if wanted).
5. Smoke-check the final files on a phone, then publish.

## How to resume

- **Rebuild the video:** `remotion/README.md` (`npm install`, `npm run prep`, `npm run render`, loudness pass).
- **Re-record a beat:** see `recordings/README.md` (pitfalls and measured positions) and `recordings/beats.py` (one function per beat). The emulator AVD is `Medium_Phone_API_36`; it needs the signed release APK installed, the demo data seeded (`recordings/seed_demo.py`), and demo mode for a clean status bar. A restart wipes the emulator's data, so reinstall after one. Run order: b10 before b11, b5 last.
- **Rebuild the release APK** (if the app changed): `flutter build apk --release` in the repo root.

## Notes

- Everything here lives on the `next` branch. It does not touch `lib/`, `assets/`, `android/` or `pubspec.yaml`.
- The app build used for all recordings: `next`, 1.6.0+8, release APK, Tamil UI.
