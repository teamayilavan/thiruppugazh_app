# Style v2: ChatGPT prompts (decided 2026-11-16)

**Decision:** ChatGPT is the main image tool (richer detail than Gemini). **Look:** the layered, backlit cut-leather style of `chatgpt_A-shadow-puppet_wide.png`. **Frame:** the gold Tanjore arch of `chatgpt_B-tanjore_wide.png` as a reusable overlay.

**Tips for consistency**
- Keep one chat for the style anchor and attach the anchor image to every later prompt ("use the attached image as the style reference").
- Ask for the largest size available. Wide images are about 1672 px; I upscale for 1080p and 4K. For Shorts and Reels we need **native tall** images (9:16), not crops.
- Plain solid colour backgrounds (below: green `#00FF00`) let me cut out an element cleanly. If ChatGPT can give a **transparent PNG**, even better: ask "transparent background (PNG)".
- Save into `scriptures/animation/assets/inbox/` using the file names shown.

## Fixes found in the first round

- The babies had a **Vaishnava vertical tilaka** (they read as Krishna). Murugan is shown with **three horizontal lines of sacred ash (vibhuti)**, no vertical tilaka.
- Wheat and cattails appeared instead of reeds. The Saravana lake has **tall green reeds**.
- Newborn proportions: calm, content, round-cheeked, not fetal.

## Common sentence (already included below)

> No text, no letters, no watermark, no signature, no logo, no modern objects. Respectful, serene, devotional tone.

---

## Step 1: the style anchor (corrected), wide and tall

Attach `chatgpt_A-shadow-puppet_wide.png` first.

**1a. Wide** (save as `anchor_wide.png`)
```
Use the attached image as the style reference: backlit, ornately perforated cut-leather in the manner of Tamil shadow puppetry, glowing amber and red with deep green and indigo. Recreate the same night scene with these changes. The newborn child asleep in the heart of the glowing lotus is baby Murugan: round-cheeked, calm, eyes closed, with three horizontal lines of sacred white ash (vibhuti) on the forehead, a small top-knot of hair, and simple gold ornaments; no vertical tilaka, no crown. The lake is the Saravana reed lake: tall green reeds with narrow leaves and feathery plumes on both sides, not wheat. Keep the starry sky, the glowing moon, the ornate perforated clouds, the palm-lined far shore, the water reflections. Horizontal 16:9, the lotus and child at the centre. No text, no letters, no watermark, no signature, no logo, no modern objects. Respectful, serene, devotional tone.
```

**1b. Tall** (save as `anchor_tall.png`)
```
Use the attached image as the style reference: backlit, ornately perforated cut-leather in the manner of Tamil shadow puppetry, glowing amber and red with deep green and indigo. Create the same scene in a vertical 9:16 composition: a glowing perforated lotus floating on a still lake in the middle third of the frame, baby Murugan asleep in its heart (round-cheeked, calm, eyes closed, three horizontal lines of sacred white ash on the forehead, small top-knot, simple gold ornaments; no vertical tilaka, no crown). Tall green reeds with narrow leaves and feathery plumes rise on both sides. Above: a starry night sky with a glowing moon and ornate perforated clouds, with plenty of open sky. Below: lake water with golden reflections. Keep the important detail inside the middle 80 percent of the width. No text, no letters, no watermark, no signature, no logo, no modern objects. Respectful, serene, devotional tone.
```

---

## Step 2: the reusable gold frame (wide and tall)

Attach `chatgpt_B-tanjore_wide.png`.

**2a. Wide** (save as `frame_wide.png`)
```
Use the attached image only for the style of the ornate frame. Create just the frame: a Tanjore-style gold-relief arch with red enamel panels, inlaid red and green gems, carved floral scrolls and two slender decorated pillars, in a horizontal 16:9 composition. The entire inside of the arch (everything inside the frame) must be a flat solid pure green colour (#00FF00) with nothing in it, so it can be cut out. Nothing outside the frame either. No text, no watermark, no logo.
```

**2b. Tall** (save as `frame_tall.png`)
```
Use the attached image only for the style of the ornate frame. Create just the frame: a Tanjore-style gold-relief arch with red enamel panels, inlaid red and green gems, carved floral scrolls and two slender decorated pillars, adapted to a vertical 9:16 composition with a tall arched opening. The entire inside of the arch must be a flat solid pure green colour (#00FF00) with nothing in it, so it can be cut out. No text, no watermark, no logo.
```

---

## Step 3: layer plates for scene 5 (after the anchor is chosen)

Attach `anchor_wide.png` to each. Keep the **horizon at about 55 percent of the height** in plates a and b, so they stack.

**3a. Sky and far shore** (`plate_a_sky.png`)
```
Use the attached image as the style reference. Create only the far background of the scene: a starry night sky with a glowing moon and ornate perforated clouds, and, along a horizon line at 55 percent of the height, a distant shore with palm trees and low hills in dark silhouette. Nothing in the lower 45 percent except a plain dark band. No lotus, no baby, no reeds, no water detail. Horizontal 16:9. No text, no watermark, no logo.
```

**3b. Water** (`plate_b_water.png`)
```
Use the attached image as the style reference. Create only the lake water: a calm glowing water surface in the same perforated-leather style, with golden reflections of the moon and lamp-light, small ripples, a few lily pads. It should fill the whole frame as a flat water plane seen from slightly above, with no sky, no lotus, no baby, no reeds. Horizontal 16:9. No text, no watermark, no logo.
```

**3c. The hero lotus and baby** (`plate_c_lotus.png`)
```
Use the attached image as the style reference. Create only the large glowing perforated lotus with baby Murugan asleep in its heart (round-cheeked, calm, eyes closed, three horizontal lines of sacred white ash on the forehead, small top-knot, simple gold ornaments; no vertical tilaka, no crown), with a soft golden glow. Place it on a flat solid pure green (#00FF00) background with nothing else, so it can be cut out. Show the whole lotus with space around it. No text, no watermark, no logo.
```

**3d. Foreground reeds** (`plate_d_reeds.png`)
```
Use the attached image as the style reference. Create only a dense cluster of tall green reeds with narrow leaves and feathery plumes, in the same perforated-leather style, as two separate clumps: one on the far left edge and one on the far right edge, rising from the bottom of the frame. Place them on a flat solid pure green (#00FF00) background, with the middle left empty. No text, no watermark, no logo.
```

---

## What I do with them

1. Cut out the green areas, upscale and clean the edges.
2. Build the scene in Blender: sky, water, lotus and reeds as separate layers at different depths, with a real camera, so the camera drift gives parallax.
3. Animate: a pulsing glow behind the baby, twinkling stars and moon, shimmering water, swaying reeds, drifting sparks.
4. Render once in 16:9 inside the gold frame and once in 9:16 using the tall versions.
