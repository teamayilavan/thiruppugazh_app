# Workflow: building a story repository for a deity or theme

This is the exact process used for **Lord Vishnu** (songs that call Murugan the nephew of Vishnu), written so a new
session can repeat it for **Lord Shiva** or any other theme. Read `README.md` (layout) and `STATUS.md` (where we are) first.

## 0. Ground rules

- `scriptures/` is research material. It is never bundled into the app and never touches the app database or `lib/`.
  The app's offline-first principles (CLAUDE.md) are untouched.
- The songs come from `assets/thiruppugazh.db` (table `songs`, column `lyrics_list` = the Tamil lines the song page uses),
  always opened **read-only** (`file:...?mode=ro`).
- Every cited verse number must be machine-checked: the build scripts fail if a number does not exist in the source text.
  A reference that was not opened and checked is marked `?` (from memory) or `candidate`; never presented as confirmed.
- Copyright: keep only verse numbers, my own short gists, and short quotes of public-domain texts (Kamba, Sanskrit).
  Do not store the translated English text of Valmiki (valmikiramayan.net) or the Bhagavata (vedabase.io) in tracked
  files; the download cache (`scripts/.cache`) is git-ignored.
- Commit only when the owner asks. Small, logical commits.

## 1. Pipeline overview

```
songs (DB) -> shortlist -> hand-read song->story map -> episode catalogues (verse refs)
           -> Tamil devotional parallel (Divya Prabandham / for Shiva: Tirumurai)
           -> build_master.py -> stories/, STORIES.md, by-song.md, master.json, PDF
```

Folder per deity: `scriptures/vishnu/` exists; create `scriptures/shiva/` with the same shape. Shared helper scripts
live in `scriptures/scripts/`.

## 2. Step by step

### Step 1: define the shortlist rule (ask the owner; do not guess)
Vishnu used the word family மருகன் (nephew). For Shiva the relation is different (Murugan is Shiva's **son**), so the
keyword is not a single word. Propose, then confirm with the owner, a rule such as:
- epithets of Shiva in the stanza (சிவன், அரன், ஈசன், சங்கரன், பரமன், சிவபெருமான், நடராஜன், உமையாள் மணாளன், ...), **and/or**
- a Shiva deed in the stanza (Tripura burning, burning Kama, drinking the poison, Ganga in the matted hair, the dance,
  Daksha's sacrifice, Andhaka, Markandeya and Yama, Ravana under Kailasa, Arjuna's Pashupata, Bhikshatana, Dakshinamurti,
  Brahma's fifth head, the Linga/Annamalai story, Tiruvilaiyadal), **and/or** the address form (`சிவன் மைந்தா`, `பாலா`, `குமரா` after Shiva words).
Write the rule into `scriptures/shiva/README.md` first. Count how many songs it catches before going further.

### Step 2: make the shortlist script reusable
`scripts/shortlist_maruga.py` is hard-wired to மருகன் and Vishnu words. Copy the structure into a parameterised
`scripts/shortlist.py --deity shiva` (keyword families, false-positive list, output folder). Keep these behaviours:
- search `lyrics_list` line by line, strip spaces for keyword matching (the lyrics are in sandhi form, spacing is unreliable),
- keep the previous 3 lines as context (the deed usually precedes the keyword),
- write `shortlist.json` (every hit with context) and `excluded.md` (look-alike words rejected, with the reason),
- first-pass keyword tags are only guesses; never treat them as conclusions.

### Step 3: hand-read every song and map it to stories
Create `scriptures/shiva/song-story-map.txt` (format: `song | slug,slug | what it alludes to | confidence`).
- Read the full context of every song, not only the keyword line (200+ songs: read in chunks of about 70).
- Use the database commentary too: `meanings`/`pathavurai` (Tamil prose) often names the story. The vague songs in the
  Vishnu run were fixed this way (`vishnu/general-songs-review.md`).
- Use one slug per distinct story; use `*-general` only when the line names the deity without any deed.
- Mark doubt honestly (`low`); a wrong confident tag costs more than an honest "general".

### Step 4: write story briefs
`scripts/story_data.py` holds one brief per story slug (2-3 sentences in plain English). For Shiva create
`scripts/story_data_shiva.py` (or add a `deity` key) so the Vishnu data is not mixed in.

### Step 5: episode catalogues with verse-level references
One Python module per source family, same pattern as `ramayana_episodes.py`, `krishna_episodes.py`, `avatar_episodes.py`:
`ep(id, title, refs...)` plus `a(song, "episode ids", confidence, note)`; and one `build_*_verses.py` that **fails if any
cited verse is missing** and writes `*-episodes.md` and `*-verses.md`.
Likely sources for Shiva (check each is reachable before promising it):
- Valmiki/Mahabharata (Shiva appears in Ramayana Bala 45 poison/churning, Uttara; Mahabharata Kairata 3,40-41, Drona, Sauptika,
  Anushasana's Shiva sahasranama): `fetch_krishna.py mbh_lines(parva)` (GRETIL Critical Edition) already works.
- Puranas: Shiva Purana, Linga Purana, Skanda Purana (Murugan's own birth and the Surasamharam: Kandapuranam); Bhagavata
  4.2-7 (Daksha), 8.7 (poison), 10.62-63 (Banasura). vedabase.io covers the Bhagavata; Shiva/Linga/Skanda need a source
  that exposes verse numbers (try wisdomlib, Wikisource, archive.org text; test with curl first).
- **Tamil Saiva texts** (the Shiva counterpart of the Divya Prabandham): Tevaram (Tirumurai 1-7), Tiruvasagam (8), Tirumandiram (10),
  Periya Puranam (12), Tiruvilaiyadal Puranam, Kanda Puranam (Kachchiyappar). Candidate sites: thevaaram.org, shaivam.org,
  Tamil Wikisource, tamilvu.org. For Kamba-style numbering use per-padalam or per-pathigam numbers as the site shows and
  say so.
- For each source family record how verses are numbered and where the numbering differs from other editions
  (Kamba per padalam, Mahabharata CE vs Vulgate, Tevaram pathigam.verse vs running number).

### Step 6: Tamil devotional verses (Divya Prabandham analogue)
Use parallel research agents, one per story group, each writing only its own files (`dp-*.md`, `dp/*.json` pattern;
for Shiva `tirumurai-*.md`, `tirumurai/*.json`). Rules for the agents:
- only mark a verse `confirmed` if the page was opened and it mentions the story; keep the URL;
- unconfirmed ideas go under "candidates, not confirmed";
- do not edit shared files (README, STATUS, SOURCES, the map); report instead.

### Step 7: join everything
`scripts/build_master.py` joins the catalogues, briefs and Tamil-verse JSON into `master.json`, `STORIES.md`,
`by-song.md`, `stories/<domain>-<episode>.md` and the PDF. It currently has the Vishnu domains hard-coded (`SLUG`, `DP_AV`,
`DOMAIN_NAME`, paths to `vishnu/`). **Session task #1 for Shiva: refactor it to take `--deity <name>` and read its inputs
from `scriptures/<deity>/`**, then check the Vishnu output is byte-for-byte unchanged (diff `master.json` before/after).

### Step 8: PDF
`build_master.py` writes HTML and prints it with headless Microsoft Edge (`--print-to-pdf`), which shapes Tamil correctly
with the Nirmala UI font (reportlab does not; do not switch). Part A by song number (verse, story, references), Part B by
story with quotes and links, Part C songs with no identified story. Open a few pages as images and check Tamil, tables and
page breaks before declaring done.

### Step 9: review, counts, commit
- Report the counts the owner asked for: stories with songs, with a primary-text reference, with a confirmed Tamil
  devotional verse, with both, with neither.
- Update `STATUS.md` (done / next), `SOURCES.md` (what was checked, what was not), `README.md` (layout).
- Commit when asked; message: what was added, counts, what is unverified.

## 3. Practical notes and pitfalls (learned the hard way)

- Windows + Git Bash: shell heredocs can mangle backslashes in Python files that contain regexes. Write such files with the
  Write tool, not `cat <<EOF`.
- `python -I` ignores the script folder: scripts that import siblings insert their own folder into `sys.path`. When running ad hoc code
  from another folder use `PYTHONPATH=scriptures/scripts python ...`.
- Print Tamil with `sys.stdout.reconfigure(encoding="utf-8")`.
- Tools that work: valmikiramayan.net pages (`<kanda>sans<N>.htm` give numbered shlokas), Tamil Wikisource raw wikitext
  (`index.php?title=...&action=raw`), vedabase.io chapter pages (all verses on one page), GRETIL Critical Edition Mahabharata,
  divyaprabandham.koyil.org (per-pasuram pages, `wp-json/wp/v2/posts?search=`). Blocked: sacred-texts.com (Cloudflare 403).
  Wikisource has no Ganguli section pages; the Vulgate numbers (Wikipedia parva tables) differ from the Critical Edition.
- Kamba on Wikisource numbers verses per padalam; Aranya/Kishkindha/Sundara pages split lines by blank lines, so
  `find_kamba.py` quotes show only the last line there (numbers are right).
- The fetch tool that summarises pages is useful for structure, not for exact numbers: confirm numbers by parsing the page yourself.
- Parallel agents: give each its own output files, say "do not edit shared files, do not commit", and ask for a short report.
  Merge their results yourself, then run the builds.

## 4. Kickoff prompt for the next session (Shiva)

Paste this to start:

> Read scriptures/README.md, STATUS.md and WORKFLOW.md. We are starting Lord Shiva. First propose the shortlist rule
> (Step 1), run it, and show me the count and a sample before reading any songs. Then follow the workflow. Refactor
> `build_master.py` to be deity-agnostic first and prove the Vishnu output is unchanged. Use parallel agents for the
> Tamil-verse research. Do not commit until I ask.

## 5. Open items carried over from Vishnu (optional, any time)

See `STATUS.md`: spot-check the Divya Prabandham first-words and verse numbers against a printed edition; pin the
remaining Kamba scenes (Rama's birth, the army's march, general battle); Harivamsa for Narakasura/Parijata/Banasura;
the 34 songs that stay general; whether to add running Kamban Kazhagam verse numbers.
