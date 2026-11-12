# Remotion project: Thiruppugazh marketing video

Not part of the app build. Renders the 1080x1920, 30 fps, 120 s video from the emulator recordings.

## Rebuild

    cd marketing/remotion
    npm install
    npm run prep      # raw recordings -> public/clips/*.mp4 (idle gaps removed, 30 fps, 720x1600) + clips.json
    npm run studio    # preview in the browser
    npm run render    # -> ../exports/thiruppugazh-music-v1.mp4

After `render`, the audio is brought to about -14 LUFS (video stream copied):

    ffmpeg -i thiruppugazh-music-v1.mp4 -c:v copy -af "loudnorm=I=-14:TP=-1.5:LRA=7" -c:a aac -b:a 192k -ar 48000 out.mp4

`prep` needs the raw clips in `../recordings/raw/` (git-ignored; re-record with `../recordings/beats.py`).

## Layout of the code

- `src/timeline.ts`: the beat list (order, seconds, captions, which clips). Beat lengths sum to 120 s. Clip speed is derived from each clip's active length (clamped to 0.6x to 3.5x); a short clip holds its last frame.
- `src/Video.tsx`: background, phone frame, screens, captions, the "promise" and end-card graphics, music.
- `src/theme.ts`: colours, fonts, canvas and phone geometry.
- `public/clips/`: prepared clips (git-ignored video). `public/img/`: app icon (from `assets/icons/icon.png`) and Google's official Play badge.
- `public/music-placeholder.m4a`: a synthesized ambient pad (original, no licence). Replace it with the real track (same name, or pass `music` to `Video`).

## Adding the voiceover later

Add `Cut-ta` and `Cut-en` compositions in `src/Root.tsx` that reuse `Video` with a voiceover `<Audio>` and, once the ElevenLabs files exist, beat lengths measured from each language's audio. Music should duck about 12 dB under the voice. Captions for those cuts are the full English lines from `../script/en.md`.

## Known limits of version 1

- Captions are short, music-only versions of the script lines.
- Beat 8 contains third-party YouTube content (face-free title graphics; channel names visible).
- Placeholder music is a plain synthesized drone, not a composed track.

## v2 cut and posters (2026-11-12)

- `src/v2/`: the `Cut-v2` composition (theme, timeline, video). Beats, headlines, trims and timings live in `src/v2/timeline.ts`; headline syntax is `Line one|*accent words*` (`|` breaks a line). The v1 `Cut-music` composition is unchanged.
- `src/posters/Poster.tsx`: nine 4:5 Instagram posters (`Poster-<id>` compositions). Screens come from `public/posters/` (frames pulled from `recordings/raw`).
- Fonts: Outfit through `@remotion/google-fonts` (needs network at render time). Icons: `@phosphor-icons/react`.
- Prep: `python scripts/prep_clips.py` re-encodes every raw clip; `python scripts/prep_clips.py n0` only the new `n0*` ones (tablet clips are scaled to 1600x1000, phone clips to 720x1600). Optional `from`/`to` in a timeline `seg` trim a clip.
- Render v2: `npm run render:v2` writes `../exports/thiruppugazh-v2-raw.mp4`, then bring it to -14 LUFS:

      ffmpeg -i ../exports/thiruppugazh-v2-raw.mp4 -c:v copy -af "loudnorm=I=-14:TP=-1.5:LRA=7" -c:a aac -b:a 192k -ar 48000 ../exports/thiruppugazh-v2.mp4

- Other music: render with the other track and swap only the audio, no re-render needed:

      ffmpeg -i ../exports/thiruppugazh-v2-raw.mp4 -i ../audio/music-v2-energetic.wav -map 0:v -map 1:a -c:v copy -af "atrim=0:130.6,afade=t=in:d=1.5,afade=t=out:st=126.6:d=4,loudnorm=I=-14:TP=-1.5:LRA=7" -c:a aac -b:a 192k -ar 48000 -t 130.6 ../exports/thiruppugazh-v2-energetic.mp4

- Posters: `npm run posters` writes `../exports/posters/NN-name.png`.
- Music (both original, synthesized, no licence): `../audio/make_music.py` (calm, 134 s) and `../audio/make_music_energetic.py` (108 bpm). Convert the calm one to `public/music-v2.m4a` for the in-composition track (command in the script header).
