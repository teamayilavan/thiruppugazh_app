# Animation production: plan, decisions and status

Read this first in the next session. Last updated 2026-11-16 (end of the session). The scripts it works from are in [`../storylines/`](../storylines/README.md) (142 drafts; `avatar-gajendra` and `m-saravana` are at script level).

## 1. Owner decisions (binding)

- **2D only.** Made by the owner and Claude alone, no other people.
- **Quality: top-notch.**
- **Voice:** English, **female**, via **Sarvam AI** (Bulbul, `https://api.sarvam.ai/text-to-speech`); ElevenLabs only as fallback. The owner has the Sarvam key but it is **not yet in `.env`**.
- **Music and sound:** synthesised (Python), loudness-normalised with FFmpeg.
- **Outputs:** 16:9 for the website, 9:16 for YouTube Shorts and Instagram Reels. **For now landscape only**; tall versions later (native tall art, never crops).
- **Images:** the owner generates with **ChatGPT** (preferred: richer than Gemini) from prompts in `style/`, saves into `assets/inbox/`. Gemini Pro plan gives no API access. **Higgsfield** (official skill/MCP, subscription) is the planned later route so Claude can generate directly. An **OpenAI API key** is the other option (separate billing from the ChatGPT plan; set a monthly cap).
- **Two sample films first** (`m-saravana` and `avatar-gajendra`), then all 142.
- Never paste keys in chat. Keys go in `scriptures/animation/.env` (git-ignored; template `.env.example`).

## 2. The look (decided)

- **Style:** backlit, ornately perforated **cut-leather in the manner of Tamil shadow puppetry** (glowing amber and red, deep indigo and green), from the ChatGPT image.
- **Style anchor (approved):** `assets/inbox/anchor_wide.png` (1672x941). The baby Murugan is correct: three horizontal white ash lines, small top-knot, round cheeks, eyes closed, **no vertical tilaka and no crown**; Saravana lake with tall green reeds; palms on the far shore; moon, stars, perforated clouds.
- **Reusable frame (approved):** `assets/inbox/frame_wide.png`: a gold Tanjore arch with red enamel and gems, chroma-green opening. `tools/key_frame.py` cuts the green out cleanly (no fringe) and composites it over a scene. **Composition rule:** the frame hides about 27% of the picture, so every scene must be composed inside the arch's opening: keep the moon and key detail in the central ~80% of the width and below the top ~12%.
- **Iconography lessons (apply to every prompt):** Murugan is Shaiva: **vibhuti (three horizontal ash lines), top-knot; never a vertical tilaka.** Reeds are narrow tall green with feathery plumes, not wheat. Newborns calm, round-cheeked, not fetal.
- **Compared and set aside:** Gemini's three images (A shadow puppet: lovely mood but the baby looked fetal; B Tanjore: most authentic; C papercut: generic) and ChatGPT's B (Tanjore) and C (papercut). Kept in `assets/inbox/style-test/` for reference. Gemini images carry a small visible sparkle watermark and are 2752x1536; ChatGPT images are 1672x941 (need AI upscaling for crisp 1080p; do it later, e.g. Real-ESRGAN).

## 3. What was proven (tools in `tools/`)

| Tool | What it does | Result |
|---|---|---|
| `voice_test.py` | Samples about ten Sarvam English voices speaking the same line with Kailasa, Saravana, Murugan | **Not yet run** (needs the key). Female voices are not labelled in Sarvam's docs, so the owner listens and picks. |
| `key_frame.py` | Chroma-keys the frame and composites it over a scene | Clean key; composite looks finished |
| `motion_test_single.py` | A crude 6 s test from ONE flat image: push-in, glow pulse, twinkling stars, shimmering water, rising sparks, with the frame | Renders 1080p30 H.264 in about 71 s (FFmpeg works). **Not the final look**; no depth layers. |

Machine: Blender 5.3 (and 4.2) installed at `C:\Program Files\Blender Foundation\` (not on PATH); FFmpeg 8.1; Python 3.13 with numpy, Pillow, pycairo, moviepy, scipy, playwright; Audacity; RTX 3050.

## 4. The open question: how things move

The first plan was **2.5D layered parallax** (separate sky, water, lotus, reeds plates moved at different depths in Blender). The owner doubts it ("front and back movement may not work"): flat plates can look like cardboard. Options:

| Approach | Notes |
|---|---|
| Layered parallax | Cheap, fully controlled; risk of a cut-out look. Plates prompts exist in `style/PROMPTS-chatgpt-v2.md` step 3 (a sky, b water, c lotus and baby, d reeds, e pads; landscape). Not generated yet. |
| **AI image-to-video from the approved art** | Real motion inside the painting. Shorter clips (5 to 10 s); risk of drift in ornate details and the sacred faces; credits. Higgsfield later, Veo in Gemini Flow now. |
| Frame-by-frame generation | Rejected: flicker, about 2,000 images per film. |
| **Hybrid (suggested)** | Image-to-video for motion; Claude's compositing for the gold frame, captions, transitions, sound and music |

**Pending test (the owner to run at no extra cost):** in Gemini **Flow** (Veo, limited on the Pro plan), upload `assets/inbox/anchor_wide.png` and use:
```
Animate this artwork with very gentle motion only. Keep the artwork exactly as it is, including the child, the lotus, the ash marks and all the cut-leather patterns. Add: a slow camera push-in; a soft pulsing golden glow behind the child; the water shimmering with small ripples; the stars twinkling; a few golden sparks rising from the lotus; the reeds swaying slightly. No new characters, no text. Calm and devotional. 6 seconds.
```
Judge: does it keep the style and the baby's face? Save the clip as `assets/inbox/flow_test_1.mp4` and tell Claude. **That test decides the production approach.**

## 5. Next session: do in this order

1. Ask the owner for the Flow test result. Choose the motion approach (image-to-video hybrid vs layered parallax).
2. Put the Sarvam key in `.env`; run `voice_test.py`; owner picks one female voice; build a pronunciation list (Kailasa, Saravana, Krittika, Gajendra, Trikuta, Murugan, Agni, Ganga).
3. Write `tools/gen_image.py` (OpenAI Images API: generate and edit with reference images; `--list-models` first, since model names are changing and sources disagree) once the owner supplies `OPENAI_API_KEY` and a spending cap. Or install Higgsfield's official skill (`npx skills add higgsfield-ai/skills`, `higgsfield auth login`; MCP: `claude mcp add --transport http --scope user higgsfield https://mcp.higgsfield.ai/mcp`) and use that.
4. Storyboard `m-saravana`: one key image per scene (8) in the anchor style, composed for the frame opening; then the motion, voice-over (Sarvam), synthesised music, assembly in FFmpeg; then `avatar-gajendra`.
5. Check commercial-use terms of the image and video tools used (YouTube monetisation); upscale ChatGPT images; later, native 9:16 versions.

## 6. Other open items

- Owner decisions flagged in `../storylines/` notes: the Jain impalement tradition (`sam-jains`) and the framing of `krishna-clothes`, `krishna-naraka-wives`, `ramayana-sita-agni`.
- The 142 storylines are drafts; only 2 are script level. Do the verse-check pass and the second pass for each story before it is produced.
- Platform limits and safe zones for Shorts and Reels: check current rules at publish time.

## 7. Files and git

`style/PROMPTS-style-test.md` (round 1 prompts), `style/PROMPTS-chatgpt-v2.md` (corrected anchor, frame, layer plates) · `assets/inbox/` (images, git-ignored) · `out/` (renders, git-ignored; `out/frame-test/motion_test.mp4`) · `tools/` · `.gitignore`, `.env.example`. **Uncommitted** at the end of this session: the whole `scriptures/animation/` folder (small files only; images and renders are ignored).
