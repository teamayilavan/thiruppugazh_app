# Style test: prompts for Gemini (Nano Banana / Flow)

Goal: choose ONE look for all 142 films. We test the same moment in three directions and pick.

**The test moment:** *m-saravana*, scene 5: on a still lake among reeds at night, a lotus opens and in its heart lies a glowing newborn. It is the simplest scene to judge the look: no complex iconography, mostly light, water, lotus and reeds. (The sacred figures with many faces and arms come later, once the style is chosen.)

## How to run it

1. Open Gemini (or Flow) with image generation. Use the highest-quality image model your plan offers.
2. Paste **one prompt at a time**. Generate 2 to 3 variants of each; keep the best.
3. Save each pick into `scriptures/animation/assets/inbox/style-test/` with the name shown (`A-wide-v1.png`, `A-tall-v1.png`, ...). Do not rename after, I read the names.
4. Run each direction in **both shapes**: wide 16:9 and tall 9:16 (just add the shape line shown). Many images look good in one shape and fall apart in the other; we need to know early.
5. Tell me when they are in the folder. I will look at them and report on animation-readiness (can I split it into depth layers? are there clean edges? does the glow animate well?).

If an image comes with a visible sparkle or watermark, tell me which plan/tool made it.

## Common line to add to every prompt

> No text, no letters, no signature, no watermark, no logo. No modern objects. Respectful, serene, devotional tone. Rich detail, clean edges, layered depth with a distinct foreground, middle ground and background.

## Shape line (add one)

- Wide: `Horizontal composition, 16:9 aspect ratio, the glowing child and lotus at the centre.`
- Tall: `Vertical composition, 9:16 aspect ratio, the glowing child and lotus in the centre third, sky above, reeds below.`

---

## Direction A: Tamil shadow-puppet (Tholpavai Koothu)

> A night scene in the style of traditional Tamil shadow puppetry (Tholpavai Koothu): figures and plants shown as ornately cut, translucent coloured leather, backlit by a warm lamp. A still lake among tall reeds under a starry sky. In the centre a large lotus has just opened, and in its heart lies a newborn child made of soft golden light, the brightest point in the picture. Intricate perforated patterns in the reeds, the lotus petals and the sky; jewel-toned reds, ambers, deep greens and indigo; the glow spills through the cut patterns onto the water. Flat, graphic, layered silhouettes with fine ornamental detail.

## Direction B: Tanjore painting

> A devotional scene in the style of traditional Thanjavur (Tanjore) painting: rich reds, deep blues and greens, with raised gold-leaf relief and inlaid-gem detail on a flat, frontal composition. A sacred lake with a large golden lotus in the centre, reeds on either side, a night sky of gold stars. In the heart of the lotus lies a newborn child radiating a golden halo. Ornate arched frame suggested by curved golden foliage. Smooth, jewel-like, richly decorated, calm and reverent.

## Direction C: Layered papercut / folk-art illustration

> A layered papercut illustration inspired by South Indian folk art and Kalamkari-style floral patterns: stacked paper layers with soft shadows between them, a deep indigo night, a moonlit lake with tall reeds in the foreground, a huge lotus at the centre, and a newborn child glowing warm gold in its heart. Decorative leaf and flower patterns in the reeds and the water, glowing fireflies, strong depth between the layers, a limited palette of indigo, teal, saffron and gold.

---

## What I will check when the images are in

| Question | Why it matters |
|---|---|
| Can the scene be split into clean depth layers (sky, far reeds, lake, lotus, child)? | Blender parallax and camera moves need layers |
| Are edges clean enough to cut out characters? | Puppet-style animation needs separable shapes |
| Does the glow look animatable (pulsing, sparks)? | Most of our scenes are light |
| Does it survive both shapes without losing the subject? | One art asset serves wide and tall |
| Is it reverent, and recognisable as Tamil / Indian sacred art? | Tone and trust |
| Can the look be repeated across 142 films by a reference image? | Consistency is the whole game |

## After you pick a direction

1. Take the best image in that direction and call it the **style anchor**. Upload it as a reference image with every later prompt (Gemini lets you attach images).
2. Phase 2 prompts, written once the style is locked: character sheets (Murugan as child and as youth, six-faced twelve-armed form, Parvati, Shiva, Vishnu, Garuda, the peacock, the elephant and others) on plain backgrounds from several angles, so they can be cut out and rigged.
3. Then the background plates for the two sample films, as separate far, middle and near layers.
