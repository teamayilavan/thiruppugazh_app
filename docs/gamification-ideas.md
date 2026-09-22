# Gamification Ideas (Backlog)

Status: **brainstorm / not scheduled**. Captured 2026-09-05. To be built one feature at a time.

## Guiding principle

Frame everything as a **sadhana / parayana companion** — tracking spiritual
consistency — not points, coins, XP, levels, or competition. The app stays an
offline-first, privacy-first, ad-free devotional songbook. Gamification is an
opt-in layer, never in the way of reading.

### Constraints every idea must respect

- **Fully offline.** All state in local SQLite (we already use `sqflite`); it
  must flow through `backup_service.dart` backup/restore.
- **No network features.** No leaderboards, no social, no accounts.
- **No dark patterns.** Forgiving streaks, grace days, no streak-shame, no "you
  lost your progress", no daily nagging.
- **Quiet UI.** A settings toggle disables the whole layer. No badges cluttering
  the reading screen.
- **Devotional language.** "parayana", "practice", "recited", "days of devotion"
  — never "XP", "level up", "rewards".

---

## 1. Consistency / streaks (daily practice)

- **Recitation streak** — open a song, tap "recited today"; day is counted. Show
  current + longest streak.
- **Forgiving streaks** — grace days, streak "freezes", no loss-aversion styling.
- **Practice calendar heatmap** — GitHub-style contribution grid of days engaged.
  Local only.
- **"Days with Murugan"** lifetime counter.

## 2. Structured parayana goals

- **Mandala parayana (48 days)** — classic vratam-length cycle with a progress
  ring; restartable.
- **Skanda Sashti 6-day challenge** — calendar-driven reading list, one
  song/section per day.
- **Arupadai Veedu pilgrimage** — songs tied to each of the six abodes of Murugan;
  a temple is "visited" when all its songs are read at least once.
- **Collection completeness** — "% of the corpus explored", "temples completed",
  "thalams encountered".

## 3. Sacred-count milestones (markers, not loot)

- Per-song and lifetime **recitation counters**; acknowledge 108 / 1008
  recitations (traditionally significant counts) with a quiet milestone screen.
- Milestones for notes written, songs highlighted, temples covered — surfaced
  gently, not as trophies.

## 4. Learning & memorization (study becomes progression)

- **Memorization mode** — progressively blur/hide lines, self-assess recall, mark
  a song "memorized". Track memorized count.
- **Porul self-quiz** — match line → meaning, or song → temple / thalam.
  Self-graded, fully offline flashcards.
- **"Learned the meaning"** progress per song.

## 5. Personal reflection stats ("wrapped", offline)

- Locally generated yearly / monthly summary: songs read, most-visited temple,
  notes count, longest streak, time in contemplation.
- Exportable as an image by the user (no server).

## 6. Seasonal tie-ins (local calendar only)

- Themed reading lists + completion tracking for Thaipoosam, Vaikasi Visakam,
  Panguni Uthiram, monthly Karthigai.
- Optional **local notifications** (device-scheduled, works offline) for a
  "song of the day" or festival reminder.

---

## Suggested build order

1. **Recitation streak** + **practice heatmap** + **song-of-the-day tick**
   — low complexity, high alignment, shares one "practice log" data model.
2. Sacred-count recitation counters + milestones (builds on the same log).
3. Structured parayana goals (Mandala, Sashti, Arupadai Veedu).
4. Personal reflection stats / yearly wrapped.
5. Memorization mode + Porul self-quiz.
6. Seasonal reading lists + local notifications.

## Shared foundation to design first

A single **practice log** table (date, song id, action type: recited / read /
memorized / quizzed) underpins streaks, heatmap, counters, milestones, and stats.
Design this schema once, in `docs/database.md`, before starting feature 1.
