# Storylines for animated videos

Full, scene-by-scene storylines for the 142 stories in `scriptures/`, written to be turned into short animated videos (hosted online, not in the app). **English only for now.** Progress is in [`CHECKLIST.md`](CHECKLIST.md).

This is separate from the printed books: `pdf/narratives/` feeds the Typst books and is not changed by this work.

## Rules (set by the owner, 2026-11-16)

- **Under 3 minutes per video** (target 2:15 to 2:45): 7 to 9 scenes, each with a duration; the durations add up to 165 seconds or less.
- **English only.** No Tamil text in the storylines. Where a Tamil devotional cry is the point, it is described in English.
- **A real storyline, not a brief:** a clear beginning, turn and ending, with the emotion of each scene, and enough visual direction to animate.
- **Accuracy first, as in the books.** Each story rests on the verses already read for the research base (`scripts/.cache/`). Say what a text says; mark what is tradition or only in the songs; mark what is added for the screen.

## File format

One file per story: `storylines/<set>/<slug>.md`.

1. Title, id, set, running time, tone.
2. **One-line story.**
3. **What the story rests on:** a table of beats against sources, then a note on what is tradition and what is added for the screen.
4. **Characters** (visual notes) and **places**.
5. **The storyline:** numbered scenes. Each has a duration, the visuals and action, the narration (short, spoken, simple English), any dialogue, and the mood or sound.
6. **The Thiruppugazh connection:** the songs that allude to the story (numbers and what they say, in English).
7. **Production notes:** sensitivities, and any open question for the owner.

## Respect

These are sacred stories. Gods and sages are shown with dignity, no mockery, no gore, no violence shown on screen beyond a flash or a silhouette. Where a story has variants, the video follows the source named in the file.

## Two levels of finish

- **Draft (storyboard):** scenes with visuals and a short narration line. All 142 are at this level.
- **Script level (second pass):** each scene has **Visual**, full **Narration**, any **Dialogue**, and **Sound**, with enough spoken words to fill the time (about 1.6 to 2.2 words a second: roughly 300 to 365 words for a 2:45 film), and every claim checked against its source verses. The file's title line says "script level (second pass)". The checker reports how many files reach this level. So far: `avatar-gajendra`, `m-saravana`.
