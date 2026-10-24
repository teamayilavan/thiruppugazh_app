# Memorization practice: plan

**Status:** Idea and design only. Nothing is built. Written 2026-10-24 after a discussion of how the app can help devotees *study* Thiruppugazh and *remember* it properly. Build slowly, in the phases below, on `next`; publish; soak; then merge to `main`.

**One-line goal:** help a devotee commit songs to memory through short, low-effort, spaced practice, without typing and without gamification.

---

## 1. Is the idea sound? (honest assessment)

Spaced repetition and retrieval practice are among the best-supported ways to memorize. The principle is right. The details decide whether it works.

**What is right**
- Short sessions repeated over weeks beat long cramming.
- Breaking a long text into small pieces and scheduling each piece separately is exactly how memorization should be done.
- Avoiding typing (hard on a phone, especially in Tamil) is correct.

**What is weaker than it looks**
- *Reorder the lines* and *pick the missing word from a list* are **recognition** tasks: the answer is on screen and the learner picks it. They build familiarity, which feels like knowing but is not recall. They are good for the first sessions of a new song and poor as the main diet.
- The practice that actually builds memory is **retrieval**: seeing a cue and producing what comes next, from memory.

**What exercises alone will not do**
- Thiruppugazh is **rhythm and melody (chandam), not only text.** Devotees remember it by singing it. A learner could pass every text exercise and still be unable to sing the song. The app can train the text and cue the rhythm; it cannot train singing without audio (see open questions).
- Exercises do not create memory by themselves. Repeated retrieval over weeks, ideally while chanting aloud, does. The app's job is to make that repetition easy, scheduled, and short.

**Other honest risks**
- **Drop-off.** Spaced-repetition apps lose most users within weeks. Sessions must be about three minutes, and the existing opt-in daily reminder is the only nudge we use.
- **Self-rating relies on honesty.** We cannot check a spoken recitation (no reliable Tamil speech recognition), so the learner grades themselves.
- **Data errors become unacceptable.** In a reading app a wrong line is a flaw; in a memorization exercise a wrong line order or line count teaches the wrong thing (see section 8).
- **Scope.** This is much larger than Links: a new table, a scheduler, several screens, backup changes, tests. It is the real learning core of the app, which is why it must stay free of points, streaks and leaderboards.

---

## 2. What the data looks like

Measured on the bundled database (1,340 songs, 2026-10-24):

| Measure | Value |
|---|---|
| Lyric lines per song | median 16, 10th pct 16, 90th pct 24, max 96 |
| Words per song (lyrics) | median 88, 10th pct 64, 90th pct 112, max 400 |
| Songs with word-separated lyrics (`mayuragiri_lyrics_separated`) | 1,300 |
| Songs with no word-by-word meaning data | 9 |

**Consequence:** songs are far more regular than "not of fixed length" suggests. A typical song is about 8 couplets. The scheduled unit is the **couplet (a pair of lyric lines), not the song.** Long songs simply have more units, and the learner can work on a range of them.

Fields available per song that this feature can use: `lyrics_list`, `tune_list` (rhythm syllables), `words` and `meanings_list`, `mayuragiri_lyrics_separated`, and English equivalents where present (`english_lyrics_list`, etc.). Not every song has English data.

---

## 3. Core design

> **Update (2026-10-24, after building chanting mode):** the natural unit is the **verse**, not a fixed pair of lines. Lines are grouped by the length of the song's tune pattern (`tune_list`), exactly as the song detail page already shows them; this agrees with the `......` line-break marker for 1,295 of 1,340 songs and gives the more sensible grouping for most of the rest. Typical verses are 2 or 3 lines. The helper `splitIntoVerses` (`lib/utils/verses.dart`) implements it and should be reused for chunking. Wherever this document says "couplet", read "verse". Open question 3 below is answered by this.

### 3.1 The unit: a chunk
- A **chunk** is one couplet (two consecutive lyric lines).
- If a song has an odd number of lines, or the grouping from the source data is unclear, fall back to single lines for the odd one out rather than guessing.
- A chunk's identity is `(song_id, chunk_index)`. Chunk boundaries must be deterministic from the song data so that a data refresh does not silently shift every learner's progress. (If `lyrics_list` for a song changes in a future release, that song's chunk progress should be reset or remapped on purpose, not by accident.)

### 3.2 "Songs I'm learning"
- Practice is **opt-in per song.** The learner adds a song to a learning list (similar in spirit to Favorites or a category).
- New chunks are introduced **in small steps** (default: 2 couplets at a time), and the next ones only after the earlier ones are reasonably solid. This avoids the common failure of dumping a whole 16-line song into the queue at once.
- The learner can choose a range ("first 4 couplets") for very long songs.

### 3.3 The exercise ladder
Each chunk moves up a ladder as it becomes familiar. Earlier rungs are recognition (easier), later rungs are recall (harder, and what builds real memory).

| # | Exercise | Type | Notes |
|---|---|---|---|
| 1 | **Read with meaning** | Exposure | Lyrics, word-separated form and word meanings, tune syllables. Not scored. |
| 2 | **Tap into order** | Recognition | Shuffled lines (or couplets, for a whole song) shown; tap in order. Tap, not drag: long Tamil words make dragging fiddly. |
| 3 | **Fill the missing words** | Recognition to partial recall | Blanks in a line; choose from options. Start with 1 blank and grow to several; later blank the *start* of lines. **Distractors must be plausible**: similar words from other songs, not obviously wrong ones. |
| 4 | **Cue recall (self-rated)** | Recall | Show the first words of the chunk; learner recites aloud or in their head; tap *Reveal*; rate *Again / Hard / Good / Easy*. No typing. This is the exercise that drives scheduling. |
| 5 | **Whole-song recitation** | Recall | Couplet by couplet through the whole song, each revealed on tap and self-rated. For songs the learner already knows well. |

Principle: **the further a chunk has progressed, the less help it gets.** Exercise 4 is the one to protect and polish; 2 and 3 are on-ramps.

### 3.4 Scheduling
Keep it simple and fully offline. A **Leitner-style box system** per chunk, not a full spaced-repetition algorithm:

- 5 boxes with proposed review gaps of roughly 1, 3, 7, 14 and 30 days. (Starting values only; tune after real use.)
- *Good/Easy* moves a chunk up a box; *Hard* keeps it; *Again* sends it back to box 1.
- A daily session pulls the chunks that are due, capped at a small number (target: about 3 minutes), plus any new chunks for the day.
- A missed day must never punish the learner: overdue chunks simply wait; no streak is broken, no penalty is shown.

### 3.5 Session shape
- Home entry point: a "Practice" card showing how many chunks are due ("5 couplets due, about 3 minutes"). Opt-in; hidden when the learner has no songs in learning.
- A session is a short mixed queue: due chunks first, then a few new ones. The exercise for each chunk is chosen from the ladder by its box.
- Ends with a quiet summary. No scores, points, or streak counters.

### 3.6 Rhythm
- Show the **tune syllables** (`tune_list`) as a cue alongside the lyrics where available, and let the learner view them while reciting. This is the cheap, text-only way to keep chandam in the picture.
- Real audio is out of scope here (see open questions).

---

## 4. Data model sketch (DB v7)

DB is at v6 (the `links` table). This feature is a new table and so DB v7. Additive only, like v6.

Rough shape (not final):

```
learning_songs
  song_id        INTEGER PRIMARY KEY  -> songs(id) ON DELETE CASCADE
  added_at       TEXT
  chunks_unlocked INTEGER             -- how many couplets introduced so far

chunk_progress
  song_id        INTEGER -> songs(id) ON DELETE CASCADE
  chunk_index    INTEGER
  box            INTEGER              -- 1..5
  due_at         TEXT                 -- ISO date
  last_reviewed  TEXT
  PRIMARY KEY (song_id, chunk_index)
```

Notes:
- This is the shared **practice-log** table that the gamification backlog (`docs/gamification-ideas.md`) said any future streak/heatmap work should build on. A `review_log` (one row per review: song, chunk, rating, time) can be added when there is a use for it; do not add it speculatively.
- `ON DELETE CASCADE` keeps it consistent with notes, highlights and links.

---

## 5. Backup and migration (must not be forgotten)

The Links feature showed what this costs. Learning data is user data, so:
- Add `learning_songs` and `chunk_progress` to `BackupService.buildBackupJson` and `applyImport` (and the preview counts and result summary).
- Older backups without these keys must still import; re-importing must not duplicate or reset progress; rows for songs not in this install are skipped and counted.
- `migrateToV7`: additive, idempotent, non-fatal.
- Android Auto Backup already covers the JSON snapshot; no manifest change expected.

---

## 6. Phases

Each phase is shippable on its own and goes through `next` -> publish -> soak -> `main`.

**Phase 0: prerequisites (no feature code)**
- Audit song data quality for the chunking assumptions (section 8). Decide the chunking rule. Fix or flag songs that fail it.

**Phase 1: prototype to validate demand (small)**
- "Learn this song" on the song detail screen for a limited set of songs.
- Exercises 1 to 3 plus the self-rated cue recall (exercise 4), with a fixed simple schedule.
- Ship to a few devotees; watch whether they come back over two weeks. **Do not build the full scheduler or more exercises until this answers "do they use it?"**

**Phase 2: real scheduler**
- `learning_songs` / `chunk_progress` (DB v7), box scheduler, daily due queue, Home "Practice" card, backup support.

**Phase 3: depth**
- Whole-song recitation (exercise 5), better distractors, English-transliteration support for learners who cannot read Tamil script, optional practice reminder wording (reuse the existing reminder, no new permission).

**Phase 4: only if justified**
- Review history / progress view (builds on a `review_log`), audio or rhythm playback if rights and effort make sense.

---

## 7. Deliberately out of scope
- Typing-based answers.
- Points, streaks, badges, leaderboards, social features (the v2 gamification direction was judged misaligned; this feature is about learning, not engagement).
- Speech recognition for grading recitation.
- Network features, accounts, cloud sync of progress (backup covers it).

---

## 8. Data quality prerequisites

Memorization exercises are unforgiving of bad data. Before Phase 1:
- Confirm `lyrics_list` is in the correct order and complete for every song offered for learning. Known problem cases from `docs/database.md`: song 1305 (14 lyric lines vs 6 tune lines, possibly two merged songs); song 1328 (trailing lines of prose dropped; no word meanings); songs without English data.
- Decide how chunking handles songs where the line count is odd, very small, or very large (max 96 lines).
- Verify the word-separated lyrics and the main lyrics agree, since exercise 3 draws on both.
- Consider offering learning only for songs that pass a data check, and hiding "Learn this song" for the rest.

---

## 9. Open questions (decide before or during the phases)

1. **Who is the learner?** A beginner learning a first song, or someone polishing songs they already know? This changes the default ladder (start at exercise 2, or at 4).
2. **Audio.** Is there any legitimately usable recording, and are the rights clear? Without it, rhythm is text-only. If audio is ever added it is its own project.
3. **Couplet vs. natural stanza.** Is "two lines" the right chunk for all songs, or does a song's own structure (e.g. the final summary stanza) need special handling? Needs a look at real songs with someone who knows them.
4. **English / transliteration support** for learners who cannot read Tamil script: how far, and from which fields, given not every song has English data.
5. **Session size.** Is about 3 minutes and a cap of roughly 10 chunks right? Tune with real use.
6. **How is "Hard" treated** when it keeps a chunk in the same box repeatedly? (Probably fine; revisit with data.)
7. **Notifications.** Reuse the existing daily reminder, or offer a separate practice reminder? Prefer reuse.

---

## 10. Related
- `docs/gamification-ideas.md` and the shared practice-log idea (exists on the parked `v2-features` branch; bring over only what is needed, and only the table idea, not the points/streak direction).
- `docs/database.md` (current schema, migration history), `docs/automated-backup-plan.md` (backup rules), `CHANGELOG.md`.
- `CLAUDE.md`: confirm the plan with the owner before any code change.
