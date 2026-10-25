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
