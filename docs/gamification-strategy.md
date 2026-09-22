# Gamification Strategy — Octalysis Framework

**Status:** Proposal, not yet implemented
**Drafted:** 2026-09-22
**Goal:** Turn Thiruppugazh from a *library people consult* into a *practice people keep* — daily.

---

## 0. The one-sentence thesis

> **Do not import Duolingo into a devotional app. Digitise the vow.**

Tamil Murugan devotion already contains, natively, every mechanic the Octalysis Framework
describes — and those mechanics carry centuries of legitimacy that a points system never will.
Our job is not to invent a game layer. It is to recognise the game that is already there and
give it a screen.

**The design rule that follows:** every mechanic we ship must have a name a devotee would
recognise. If we cannot name it in Tamil devotional vocabulary, we do not ship it.

| Generic gamification | What we ship instead |
|---|---|
| "7-day streak 🔥" | **விரதம் / நோன்பு** — a kept vow |
| XP bar to next level | **பாராயணம்** — sequential completion of the corpus |
| Badge collection | **அறுபடை வீடு** — the six abodes |
| Daily login bonus | **The festival calendar** — Sashti, Karthigai, Thai Poosam |
| "Daily mission" | **சங்கல்பம்** — a stated intention |
| Points | **Japa count** — 108 |
| Global leaderboard | **Group parayanam** — a family completing the corpus together |
| Mystery box / loot | **அருள்** — the verse that finds you |

---

## 1. What we are working with

Pulled from `assets/thiruppugazh.db` and the current codebase, because a strategy has to be
buildable on what actually exists.

| Asset | Number | Strategic use |
|---|---|---|
| Songs | **1,334** | The corpus. At one a day = 3.6 years. This is an *endgame-length* arc. |
| Temples | **214** | A ready-made exploration map |
| Temples with exactly 1 song | **118** | Genuinely rare finds — scarcity we don't have to invent |
| The six abodes (Arupadai Veedu) | **316 songs** | Palani 98 · Thiruchendur 84 · Thiruthani 64 · Swamimalai 40 · Pazhamudircholai 16 · Thirupparankundram 14 |
| `common` (non-temple-specific) | 315 songs | The "everyday" pool |
| Distinct thālam patterns | **1,005** | A second, completely unexploited axis of exploration |
| Median lyric lines per song | **16** | A song is a 2–4 minute reading. The daily loop fits in a coffee break. |
| Songs with English content | 1,327 / 1,334 | Reaches diaspora and non-Tamil readers |

**All six Arupadai Veedu abodes are already in the data.** The single most culturally loaded
collection set in Murugan devotion is buildable today with zero new content.

### Constraints that shape everything

From the project charter (`README.md`) — these are **features, not obstacles**:

- **No tracking.** No analytics, no telemetry.
- **Offline first.** No server, no account, no sync.
- **No ads.**
- Open source, AGPL-3.0.

This rules out real leaderboards, friend graphs, social feeds, and server-verified
achievements. Which is a gift: it forces the design White Hat and intrinsic. We could not
build a Skinner box here even if we wanted to.

### Technical starting point

- 5 bottom tabs (`lib/ui/screens/main_wrapper.dart:152`) — Home, Temples, Categories, Library, Settings
- DB at **v3**; migration hook already in `lib/data/database/database_helper.dart`
- Existing user-data tables: `categories`, `song_categories`, `highlights`, `notes`, `songs.is_favorite`
- `shared_preferences`, `share_plus`, `file_picker`, `BackupService` all present
- **No notification dependency. No audio dependency.** The first is a real gap (§7); the
  second is out of scope for this document.

---

## 2. Octalysis audit — the app as it stands today

Scored 0–10 on each Core Drive, for shipped v1.3.0.

| # | Core Drive | Today | Evidence |
|---|---|---|---|
| 1 | **Epic Meaning & Calling** | **3** | The *content* is pure epic meaning — Arunagirinathar, Murugan, "Muruga Saranam", free and open forever. But the app never **tells** the user they are part of anything. No narrative, no calling, no custodianship. |
| 2 | **Development & Accomplishment** | **0** | Nothing. A user cannot answer "how much of this have I read?" There is no progress anywhere in the app. |
| 3 | **Empowerment of Creativity & Feedback** | **4** | Highlights, notes, custom categories, font size, dual language toggles — genuine creative agency. But it is **write-only**: the app never responds to what you make. |
| 4 | **Ownership & Possession** | **5** | Favourites, categories, highlights, notes, backup/export. The app's one working drive. But nothing visibly *accrues*. |
| 5 | **Social Influence & Relatedness** | **2** | Deep-link sharing only. No group, no mentorship, no sense that anyone else exists. |
| 6 | **Scarcity & Impatience** | **0** | Everything available at once, forever. 1,334 songs, no pacing, no calendar. |
| 7 | **Unpredictability & Curiosity** | **3** | The random-song shuffle FAB is the single spark. Nothing else ever surprises. |
| 8 | **Loss & Avoidance** | **0** | Nothing to lose. *(And for this app that is mostly correct — see §6.8.)* |
| | **Total** | **17 / 80** | |

### Diagnosis

The app is a **reference work**. A reference work gets opened when you need something.
A **practice** gets opened every day. The entire distance between those two things is
Drive 2 (nothing at all), Drive 7 (one FAB), and Drive 1 (present in the content, absent
from the product).

Drive 4 is already good. Drive 3 is half-built and cheap to finish. That is the wedge.

### Target after the roadmap in §8

| Drive | Today | Target | Brain | Hat |
|---|---|---|---|---|
| 1 Epic Meaning | 3 | **7** | — | White |
| 2 Accomplishment | 0 | **7** | Left | White |
| 3 Empowerment | 4 | **7** | Right | White |
| 4 Ownership | 5 | **8** | Left | White |
| 5 Social | 2 | **5** | Right | Neutral |
| 6 Scarcity | 0 | **3** | Left | Black |
| 7 Curiosity | 3 | **6** | Right | Black |
| 8 Loss | 0 | **3** | — | Black |
| | **17** | **46** | | |

Deliberately **White-Hat heavy, Black-Hat light** — drives 6/7/8 sum to 12 of 46. That is the
correct shape for a devotional app: sustainable daily practice, never compulsion. An app that
makes someone feel *obligated* to pray has failed at the thing it was built for.

---

## 3. The Daily Loop — the actual "come back every day" design

Everything else in this document exists to support this one screen. Target: **under 4 minutes**,
completable before the user puts the phone down.

```
OPEN APP
  │
  ├─ 1. Greeting + calendar context                                   ~1 sec
  │     "செவ்வாய் · கார்த்திகை நட்சத்திரம் in 4 days"
  │     Drive 1 (you are inside a living tradition) + Drive 6 (a real appointment)
  │
  ├─ 2. இன்றைய அருள் — Today's verse                                 ~30 sec
  │     ONE verse. Tamil + meaning. Seeded by date, so every user in the
  │     world sees the same verse today.
  │     Drive 7 (what will it be?) + Drive 5 (a shared object, with no server)
  │
  ├─ 3. இன்றைய பாடல் — Today's hymn                                  2–3 min
  │     The next song in your active parayanam. If none, a suggestion.
  │     Reading it IS the day's completion.
  │     Drive 2 (the count moves) + Drive 4 (the corpus fills in)
  │
  ├─ 4. நிறைவு — Quiet acknowledgment                                 ~2 sec
  │     Not a fanfare. Not confetti. A mark. "இன்று நிறைவு."
  │     Total days kept ticks up.
  │     Drive 2, with restraint
  │
  └─ 5. Optional depth — note, highlight, word meanings
        Never required. Never nagged.
        Drive 3
```

### The completion rule (non-negotiable)

A song counts as read when **either**:

- the detail screen was scrolled to the final verse, **or**
- the detail screen was foregrounded on that song for ≥ 90 seconds.

**Never on tap. Never on open.** If the number can be farmed, the number is worthless — and
the user will know it is worthless, which destroys Drive 2 entirely. The integrity of the
count *is* the product.

### The notification

- **One per day. Maximum.** At a time the user chose.
- **Default OFF.** Asked for on **day 3 of self-directed use** — never at install.
- The content is **the verse itself**, not a nag:
  `இன்றைய அருள் — "<first line>"`
- A user who never opens the app has still received prasādam. The notification has value even
  when it does not convert. That is the test for whether a notification is service or spam.
- **Forbidden:** "Murugan is waiting." "Don't lose your streak." "You haven't read today."
  Any notification that makes someone feel guilty about their own devotion is a failure.

---

## 4. The Four Phases of the Player Journey

### Phase 1 — Discovery (why would I install this?)

The Play listing currently leads with features. Lead with the practice:

> Read all 1,334 Thiruppugazh hymns. A daily practice, not just a library.
> No ads. No account. No tracking. Works fully offline.

The privacy charter is a genuine differentiator in a category full of ad-stuffed devotional
apps — it should be the second line, not buried.

**Organic acquisition channel:** shareable verse cards (§6.5). Devotees already forward verses
on WhatsApp every morning. A beautiful card carrying a link is how this app spreads — not a
referral programme.

### Phase 2 — Onboarding (first 5 minutes)

1. **சங்கல்பம் — the intention.** "Why are you here?"
   - தினசரி பாராயணம் — a daily practice
   - பொருள் அறிய — to understand the meanings
   - கோயில் தொடர்பு — temple by temple
   - சும்மா பார்க்க — just looking

   This is a *Glowing Choice* (Drive 3) and it sets the default daily loop. "Just looking" is a
   real, respected answer — it turns the daily card off and leaves a clean library.

2. **Deliver value before asking for anything.** One verse and its meaning, immediately.
3. **Beginner's Luck** (Drive 2): the first song completes easily; the first milestone (6) is
   reachable inside a week.
4. **Do not show 1,334 as a wall.** Frame it as heritage, not backlog:
   > "Arunagirinathar composed over 16,000 hymns. 1,334 survived. You are one of the people
   > keeping them read."
5. **Set the daily time.** Do **not** ask for notification permission yet.

### Phase 3 — Scaffolding (day 2 → day 100)

**This is where every app dies.** The daily loop (§3) is the entire scaffold. Variety comes from
four inexhaustible sources we already own:

- **214 temples** — "a hymn from a temple you've never opened"
- **1,005 thālam patterns** — rhythm-based exploration, completely untapped today
- **The festival calendar** — Sashti, Thai Poosam, Karthigai, Vaikasi Visakam, monthly Karthigai
  nakshatram, every Tuesday
- **Your own growing highlights** — the app reflecting your past practice back at you

**Milestones with Tamil weight**, not arbitrary levels:

| Count | Why this number |
|---|---|
| **6** | Sashti · the six abodes · reachable in a week |
| **21** | A standard mandala vow length |
| **48** | **மண்டலம்** — the canonical 48-day practice unit |
| **108** | *The* number. Reaching it should feel like an event. |
| **216** | 108 × 2 |
| **540** | 108 × 5 |
| **1,008** | The great count |
| **1,334** | The whole corpus |

**Day 48 — first mandalam completion — is the retention checkpoint that matters.** Design a
genuine ceremony for it: a full-screen moment, a permanent record, an optional completion card.
A user who reaches day 48 will reach day 400.

### Phase 4 — Endgame (the 1,334th hymn, and after)

Most gamification designs have nothing here. At one hymn a day this is 3.6 years away — which is
*exactly* why it must exist, because it defines what the whole arc is for.

- **Second parayanam.** Traditional practice is *repeated*, not completed-once. On finishing, the
  count continues: "2nd parayanam · 40 / 1334." This is the correct answer and it is the
  culturally native one.
- **Depth instead of breadth.** The loop shifts emphasis to meanings, to the word-by-word
  `patham` breakdown (already in the DB), to thālam study.
- **Custodianship.** The endgame user becomes a **corrector** and a **curator** — reporting text
  errors, and exporting mandalam sequences that guide beginners (§6.5).

Note that the endgame is carried by **Drive 1 and Drive 5** — meaning and mentorship. That is
exactly right. Nobody sustains a decade of practice on a progress bar.

---

## 5. Ethical guardrails

This section is not decoration. Gamifying religious practice can do real harm, and a devotee who
feels manipulated by a prayer app does not churn quietly — they feel betrayed.

**The review question for every proposed mechanic:**

> *Would a devotee describe this as helping their practice — or as the app playing with them?*

**Six rules, non-negotiable:**

1. **Never gate a hymn.** All 1,334 stay free, offline, and open. Forever. No content is ever
   locked behind progress, payment, or a streak.
2. **Never shame a missed day.** No red, no "you lost it", no extinguished flame, no guilt.
3. **No leaderboards of devotion.** We will not rank human beings by piety. Not globally, not
   among friends, not ever.
4. **No invented currency.** Hymns read is the only number. Inventing XP on top of a sacred
   corpus is the fastest possible way to make this app feel cheap.
5. **Completion must be earned by actual reading** (§3), or the number is meaningless.
6. **Every number stays on the device.** If a feature cannot be built without a server, we do
   not build the feature.
7. **The whole layer is optional.** A single Settings toggle — *தினசரி பயிற்சி / Daily practice*
   — removes the daily card, all counts, all collections and all notifications, returning the
   app to exactly the v1.3.0 experience. Choosing "சும்மா பார்க்க / just looking" at onboarding
   sets it off from the start. **The README promises a simple, purposeful app; for the user who
   wants a plain library, that promise must remain literally true.** This is a hard requirement
   of v1.4, not a later addition — it ships in the same release as the daily card or the daily
   card does not ship.

---

## 6. The eight drives → concrete features

### 6.1 — Epic Meaning & Calling  *(3 → 7)*

- **Rightful Heritage framing.** "16,000 composed. 1,334 survived. You are a custodian."
  Reframes the library from a thing you consume into a thing you keep alive.
- **Report a correction.** Long-press a verse → "report a correction" → opens a GitHub issue or
  queues an export. Devotees become co-custodians of the text.
  *Ship this early:* `docs/database.md` already records that **song 1328** has its lyrics sitting
  in the `tune` column. That class of bug should be found by ten thousand devotees, not by us
  proof-reading 1,334 songs.
- **The covenant.** Surface the no-ads / no-tracking / no-account promise **once**, at onboarding,
  as a commitment — not as a bullet list of features.
- **Sankalpam** (§4, Phase 2) — the practice begins with a stated intention, as it should.

### 6.2 — Development & Accomplishment  *(0 → 7)*

- **Parayanam progress** as the app's primary number: `நீங்கள் படித்தவை — 47 / 1334`.
- **Mandalam arcs (48 days)** — a culturally standard, visibly finishable unit. Not "Level 34".
- **Milestones at 6 / 21 / 48 / 108 / 216 / 540 / 1008 / 1334** (§4).
- **Per-temple progress** — "பழநி · 12 / 98". This turns the *existing* Temples tab into a
  progress map for almost no work.
- **No points. No XP. No levels.** (Guardrail 4.)

### 6.3 — Empowerment of Creativity & Feedback  *(4 → 7)*

The app's biggest cheap win: highlights, notes and categories exist but are **write-only**.

- **Make the Library tab answer back.** "You've highlighted 14 verses that mention ஞானம்."
  Surface themes across the user's own highlights. Evergreen — it never runs out, and it gets
  better the more they use it.
- **Today's verse drawn from your own highlights**, once you have ≥ 10. The app reflecting your
  past practice back at you is the strongest retention mechanic available, and it requires zero
  tracking and zero new content.
- **Build-your-own parayanam.** Categories already exist — let one be marked an *ordered
  recitation set* with a position pointer. "My morning 9." Resume where you left off.
- **Chain combo — முழுமை.** Read + note + highlight in one sitting earns a small visual
  acknowledgment. An acknowledgment, not a reward.

### 6.4 — Ownership & Possession  *(5 → 8)*

- **🏆 Arupadai Veedu — the flagship collection.** Six panels, 316 songs, filling in as you read.
  Every Tamil devotee already knows this pilgrimage, so completing it in-app reads as a digital
  yātra rather than badge-collecting. **This is the single highest-value feature in this
  document** — maximum cultural resonance, zero new content, data already present.
- **The temple map.** 214 temples; **118 have exactly one song**. Those singletons are genuinely
  rare finds — real scarcity, nothing manufactured.
- **Your personal thirumurai.** Highlights + notes + categories + progress rendered as one
  beautiful, exportable document (Markdown / PDF). `BackupService` is the mechanical version of
  this; this is the emotional one. High attachment — and ethically clean, because the asset is
  genuinely yours and genuinely portable.
- **Alfred effect.** The app already remembers font size, theme, and both language settings.
  Extend to last verse position and preferred reading time.

### 6.5 — Social Influence & Relatedness  *(2 → 5)*

No accounts, no server. So: **artifact-based social, not network-based social.**

- **Share the verse, not the score.** Sharing produces a beautiful verse card (Tamil typography,
  temple name, app link). **Never** "I read 47 songs!" Devotees forward scripture; they do not
  forward statistics. This is Touting done with dignity — and it is the app's main organic
  growth channel.
- **🏆 Group Parayanam, no server.** A family or temple group splits the corpus
  (1,334 ÷ 12 people ≈ 112 each). Each phone tracks its own slice. Progress is shared by
  exporting a short code string, pasted into WhatsApp; any member's app imports it and renders a
  combined progress wheel. **Zero backend, zero accounts, a real Group Quest** — and fully
  compatible with the charter.
- **Mentorship.** An experienced devotee exports a curated 48-day mandalam sequence as a file or
  link; a beginner imports it. Content passed between devotees — not a follower graph.
- **Water cooler.** The GitHub link is already in Settings; point it at Discussions.

### 6.6 — Scarcity & Impatience  *(0 → 3)*  ⚠️ Black Hat — use sparingly

Manufactured scarcity in a devotional app is corrosive. But there is **real** scarcity available
that we do not have to invent:

- **The calendar is genuinely scarce.** Skanda Sashti: once a year. Thai Poosam: once a year.
  Karthigai nakshatram: once a month. Tuesdays: weekly. These appointment dynamics exist whether
  or not we build the app. Surfacing them is **service**, not manipulation.
- **The Sashti six-day arc** — a real, bounded, once-a-year vow with a defined song set. The best
  annual engagement event available to us, and it is culturally authentic.
- **Never** gate content. **Never** throttle. **Never** put a countdown timer on a hymn.

### 6.7 — Unpredictability & Curiosity  *(3 → 6)*

The existing shuffle FAB is the seed of all of this.

- **அருள் — the verse that finds you.** Deterministic per day (seed = date), so the whole
  community receives the same verse. Framed as prasādam, not as a random number generator. The
  shared daily verse creates a social object with **no server at all** — everyone who opens the
  app today can discuss the same verse.
- **The Oracle.** The existing shuffle, reframed: hold a question in mind, tap, receive a verse.
  A recognised practice. **Zero new code** — it is a copy change on a shipped feature.
- **Easter eggs.** On Sashti, on Thai Poosam, on your own 108th hymn — the app quietly changes
  its appearance. Unannounced. Found, not advertised.
- **Mini-quests.** "Today: a hymn from a temple you've never opened." One line, one tap,
  endlessly generative from a 214-row table.

### 6.8 — Loss & Avoidance  *(0 → 3)*  ⚠️⚠️ Most restricted drive

The most dangerous drive in this context, and the one most likely to be misused by a well-meaning
implementer.

- **Kept days, not unbroken streaks.** Track **total days practiced** (never resets) *and* current
  continuity (resets **quietly**, with no ceremony and no colour change). The permanent number is
  the one displayed large. A year of practice is not erased by a fever.
- **Grace is built in.** Viratham traditions already include prāyaścitta — make-up practice. A
  missed day offers a make-up reading. It does not scold.
- **The one legitimate FOMO:** "Sashti begins in 3 days." That is a calendar fact.
- **Sunk cost is acceptable when the asset is real.** Notes and highlights genuinely accumulate
  and are genuinely exportable. Attachment to real, portable property is not a dark pattern.

---

## 7. Data model — proposed v4 migration

```sql
-- Schema v4: practice tracking. All local. Never leaves the device.

CREATE TABLE reading_log (
  id            INTEGER PRIMARY KEY AUTOINCREMENT,
  song_id       INTEGER NOT NULL REFERENCES songs(id) ON DELETE CASCADE,
  read_on       TEXT    NOT NULL,              -- ISO date, local tz
  dwell_seconds INTEGER NOT NULL,
  completed     INTEGER NOT NULL DEFAULT 0,    -- per the §3 completion rule
  UNIQUE(song_id, read_on)
);
CREATE INDEX idx_reading_log_read_on ON reading_log(read_on);
CREATE INDEX idx_reading_log_song_id ON reading_log(song_id);

-- Denormalised from reading_log so the home screen never scans.
CREATE TABLE practice_days (
  day             TEXT PRIMARY KEY,            -- ISO date
  songs_completed INTEGER NOT NULL DEFAULT 0,
  verse_seen      INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE parayanam (
  id          INTEGER PRIMARY KEY AUTOINCREMENT,
  name        TEXT    NOT NULL,
  source_type TEXT    NOT NULL,                -- 'all' | 'temple' | 'category' | 'custom'
  source_key  TEXT,                            -- temple name, or category id
  cursor      INTEGER NOT NULL DEFAULT 0,      -- position in the ordered set
  cycle       INTEGER NOT NULL DEFAULT 1,      -- 2nd parayanam, 3rd, ... (endgame)
  started_on  TEXT    NOT NULL,
  is_active   INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE milestones (
  key         TEXT PRIMARY KEY,                -- 'songs_108', 'arupadai_pazhani', 'mandalam_1'
  achieved_on TEXT NOT NULL
);

-- Ordered recitation sets (§6.3)
ALTER TABLE song_categories ADD COLUMN position INTEGER;
ALTER TABLE categories      ADD COLUMN is_sequence INTEGER NOT NULL DEFAULT 0;
```

### Derived values (no extra storage)

- **Total days kept** — `SELECT COUNT(*) FROM practice_days`
- **Current continuity** — walk `practice_days` backwards from today
- **Corpus progress** — `SELECT COUNT(DISTINCT song_id) FROM reading_log WHERE completed = 1`
- **Per-temple progress** — join `reading_log` → `songs.place`

### ⚠️ Backup becomes critical

`BackupService` **must** be extended to cover these tables in the same release that adds them.
A reinstall that silently wipes three years of practice is the one place in this design where
loss would be real, and it would be unforgivable.

### New dependencies

| Package | For | Phase |
|---|---|---|
| `flutter_local_notifications` | The daily verse notification | v1.5 |
| `timezone` | Correct local scheduling across DST and travel | v1.5 |

Neither exists in `pubspec.yaml` today.

**⚠️ The notification permission needs care.** On Android 13+ (API 33) this requires
`POST_NOTIFICATIONS`, a runtime permission — in an app that advertises "no tracking", a
permission prompt can read as a broken promise if it arrives cold. Mitigations:

- Ask on **day 3**, in-context, immediately after showing what the notification will contain.
- Precede the system prompt with our own screen explaining that the notification is generated
  **on the device**, from the bundled database, and that nothing is sent or received.
- The app must remain fully functional on denial. Notifications are a convenience, never a
  gate.
- Notifications are **local-only** and do not change the Play Data Safety declaration
  (no data collected, no data shared). Confirm this when filing the v1.5 release.

---

## 8. Roadmap

### v1.4 — "The Daily Loop"

*The minimum that changes what kind of app this is.*

- DB v4: `reading_log`, `practice_days` + backup coverage
- Home screen daily card: date, festival context, today's verse (date-seeded), today's hymn
- Dwell-based completion (§3) + **total days kept**
- Corpus progress `n / 1334`
- **No notifications yet.** Prove the loop works when people come on their own. If it only works
  when we ping them, it does not work.

### v1.5 — "Vow & Abode"

- `flutter_local_notifications` + `timezone`; daily verse notification, opt-in, default off,
  asked on day 3
- **🏆 Arupadai Veedu six-panel collection screen**
- Per-temple progress in the existing Temples tab
- Milestones 6 / 21 / 48 / 108 with Tamil framing, plus the day-48 mandalam ceremony
- Festival calendar: Sashti, Thai Poosam, Karthigai, Vaikasi Visakam, monthly Karthigai, Tuesdays

### v1.6 — "Your Thirumurai"

- Ordered parayanam sets from categories, with resume
- Library tab reflections — your own highlights, surfaced back at you
- Exportable personal thirumurai (Markdown / PDF)
- "Report a correction" → GitHub issue / export

### v2.0 — "Together"

- **🏆 Group parayanam** via pasteable code, no server
- Shareable verse cards (image)
- Importable curated mandalams (mentorship)
- Endgame: second parayanam + depth mode

### Where this goes in the UI

The daily card belongs at the **top of Home**, above the song list — not in a sixth tab. Six
bottom tabs is too many, and burying the daily loop in a tab guarantees it is never seen. The
progress and collection surfaces (Arupadai Veedu, milestones, stats) belong inside the **Library**
tab, which is currently the least-loaded and most conceptually appropriate home for them.

---

## 9. Measuring this without tracking anyone

We collect nothing. That is the charter. So measurement has to be honest about its limits:

1. **The user's own stats screen is the mirror.** They see it. We do not. That is the deal.
2. **⚠️ Recommendation: do NOT add opt-in telemetry.** An earlier draft of this document proposed
   a one-shot, opt-in, fully-disclosed "help improve the app" upload. On review, **reject it**:
   - It would change the app's **Play Data Safety declaration** from "no data collected" to
     "app activity collected" — the single strongest line in our store listing — for a trickle
     of self-selected, unrepresentative data.
   - "No tracking" is a promise that survives exactly as long as it has no asterisk. An opt-in
     exception is still an asterisk, and it is the one competitors' listings cannot match.
   - The proxies in point 3 answer the only question that actually matters.

   If the team ever revisits this, it needs a deliberate decision on the record — not a quiet
   addition inside a feature release.
3. **Proxies we already have, for free:**
   - Play Console retention (D1 / D7 / **D30**)
   - Uninstall rate
   - Review text — the richest qualitative signal available to us
   - GitHub issue and Discussion volume
4. **Pre-register the targets now**, before building, so we cannot rationalise whatever happens
   afterwards. Fill in the baselines from Play Console:

| Metric | Baseline | Target after v1.5 |
|---|---|---|
| D30 retention | *(fill from Play Console)* | *(set before shipping)* |
| Median days kept per active user per month | n/a | ≥ 12 |
| Actives with an active parayanam | n/a | ≥ 30% by v1.6 |
| Day-48 mandalam completions | n/a | *(set before shipping)* |

**D30 retention is the single number that says whether the loop works.**

---

## 10. Anti-patterns — what we will be tempted by, and will refuse

Write these down now, because every one of them will be proposed later by someone reasonable:

- ❌ **Leaderboards of devotion.** Ranking human beings by piety.
- ❌ **Streak freezes** — earned, purchased, or otherwise. Making grace a resource is worse than
  having no grace.
- ❌ **"Your devotion score."** A number that claims to measure someone's faith.
- ❌ **9pm push nags.** "Murugan is waiting for you."
- ❌ **Daily login rewards** with no practice attached — rewarding app-opening rather than reading.
- ❌ **Badges for opening the app**, changing settings, or other non-practice actions.
- ❌ **Sharing stats by default.** Share the verse. Never the score.
- ❌ **Gating meanings** — or anything else — behind progress.
- ❌ **Paid tiers, ads, or "supporter" cosmetics.** The charter says free. Free means free.

---

## 11. Design-system alignment

Checked against `docs/color-guide.md`, `lib/theme/app_theme.dart` and the shipped v1.3.0 UI.
Most of this plan drops into the existing system cleanly; these are the constraints it must
respect, and two places where the obvious implementation would break something.

### The palette already suits this

The forest-green depth scale (`background #D8EFD3` → `container #CAE8BD` → `card #B3D8A8` →
`accent #80AF81`) maps directly onto progress surfaces:

| Element | Token | Why |
|---|---|---|
| Daily card background | `container` | Sits one step above the scaffold — reads as a distinct object without shouting |
| Progress track (unfilled) | `card` | The corpus you haven't read yet |
| Progress fill | `accent` | The standard interactive/primary colour |
| Count numerals, milestones | `textHigh` | Already the emphasis colour |
| Dates, "n / 1334" labels | `textMuted` | Theme-invariant, correct in both modes |
| Locked / un-visited abode panel | `card` @ reduced opacity | Depth, not a different hue |

The palette is a calm green, not an arcade palette. It **cannot** render a confetti-and-fireworks
reward moment convincingly — and that is a feature, because §3 calls for quiet acknowledgment.
The design system and the ethics point the same direction here.

### ⚠️ Rule 4: red is reserved

`color-guide.md` rule 4 — *"Red is reserved for destructive/error states only — do not use it
decoratively."* Conventional streak UI is built almost entirely from red and orange: flame
icons, broken-streak warnings, urgency badges. **None of that is available to us**, and it
happens to enforce guardrail 2 (never shame a missed day) at the design-system level. A broken
continuity count renders in `textMuted`, never in red. If a mock-up needs red to work, the
mock-up is wrong.

### ⚠️ `dynamic_color` breaks hardcoded collection colours

The app ships `dynamic_color: ^1.8.1` — Material You palettes derived from the user's wallpaper.
The obvious Arupadai Veedu design (six panels, six hand-picked signature colours per abode)
would clash badly under a user-derived palette. **Constraint:** the six abodes must be
differentiated by *iconography, imagery and typography*, with surfaces derived from the active
`ColorScheme` — never by six hardcoded hues. Same rule for milestone badges.

### Other constraints

- **Never hardcode `Color(0xFF...)` in new widgets** (rule 1). Anything new goes through
  `AppColors` and `AppColorExtension`, with a paired light/dark value (rule 2).
- **Respect the lyrics font-size setting.** v1.3.0 shipped `LyricsFontSizeProvider`. The daily
  verse card renders song content, so it must honour that provider — a fixed-size verse card
  would silently undo an accessibility feature we just shipped.
- **Respect both language providers.** The daily card shows song content, so it follows
  `LyricsLanguageProvider`; its own chrome and labels follow `LanguageProvider`. These are
  independent settings and the card is the first surface where both appear together.
- **Material 3 primitives only.** Everything proposed here is a `Card`, `LinearProgressIndicator`,
  `CircularProgressIndicator`, `Chip`, `ListTile` or `Badge`. No custom-painted game UI, no
  third-party animation dependency.
- **Dark mode is not an afterthought.** Every progress and collection surface needs its
  `d`-prefixed counterpart from day one (rule 2). Devotional reading happens early morning and
  late evening — dark mode is a primary mode for this audience, not a preference.

### Implementation caution: the dwell timer

The 90-second completion rule (§3) must be driven by a foreground timer bound to
`WidgetsBindingObserver`, pausing on `AppLifecycleState.paused`. A naive `Timer.periodic` would
credit a song while the phone sits locked in a pocket — which breaks the integrity rule that
makes the count worth having in the first place.

---

## Appendix — Octalysis reference

The framework (Yu-kai Chou) arranges 8 Core Drives on an octagon:

- **Top = White Hat** (1 Epic Meaning, 2 Accomplishment, 3 Empowerment) — makes people feel
  powerful, fulfilled and satisfied. Long-term, but lacks urgency.
- **Bottom = Black Hat** (6 Scarcity, 7 Unpredictability, 8 Loss) — creates urgency and obsession.
  Effective, but leaves people feeling bad. **Used sparingly here, by design.**
- **Right = Right Brain / intrinsic** (3 Empowerment, 5 Social, 7 Curiosity) — creativity,
  relatedness, curiosity. Rewarding in itself.
- **Left = Left Brain / extrinsic** (2 Accomplishment, 4 Ownership, 6 Scarcity) — logic,
  calculation, possession. Needs an external goal.

A design that leans Black Hat produces high short-term engagement and long-term resentment. For
an app whose purpose is to support devotional practice, that trade is not available to us.

---

<div align="center">
<h3>முருக சரணம் 🙏</h3>
</div>
