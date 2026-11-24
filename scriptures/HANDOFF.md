# Scripture work: handoff (end of session, 2026-11-24)

Read this first in the next session, then `README.md` (layout), `STATUS.md` (log) and `AUDIT.md` (what is verified; it is **stale**, see 9, step 6).
`scriptures/` is research material. It is never bundled into the app and never touches `lib/`, the DB or the schema.

There are four strands of work:

1. **The research base** (142 stories, their songs and references), accuracy-first. Largely complete; see 2 and 6.
2. **The books**: *Stories in the Thiruppugazh*, a printable A4 publication built with Typst from that research. **All 142 story texts are written** (2026-11-17); what remains is the owner's and the expert's review and a rebuild. See 0 and 3 to 5.
3. **Animated videos**: 142 storylines at script level (section 11); production is blocked on the Flow motion test (section 12).
4. **Tamil edition** (started 2026-11-23): the story texts in Tamil, for a separate Tamil edition. **138 of 142 done**; the other four are held for owner decisions. See 13.

## 0. Pending after 2026-11-17 (read first)

All 142 book narratives and all 142 animation scripts are written and committed; the story-song index (`scripts/make_index.py`, output `pdf/story-song-index.pdf` and `.xlsx`, copies in `D:/thiruppugazh-books/`) is ready to send to the Thiruppugazh expert. Details of every item below are in `storylines/REVIEW-NOTES.md`.

**Owner decisions**
1. Sambandar and the Jains: the book narratives state the impalement (Periya Puranam 853-855); the film leaves it out. Keep the book paragraph or soften it?
2. Framing for public videos: `krishna-clothes`, `krishna-naraka-wives`, `ramayana-sita-agni`.
3. `avatar-pralaya` is now framed as Markandeya's vision (Bhagavata 12.9.20-27): confirm.
4. `d-idumbai` narrative has one paragraph on the Hidimba episode (Mahabharata); confirm it may stay.

**For the expert (send the index PDF)**
5. Doubtful song assignments: 161 (likely `ramayana-vibhishana-crown`, not `ramayana-sita-agni`), 835 ("Kumban": Kumbha or Kumbhakarna), 1325 (`ramayana-sita-jewels`, weak; maybe Trivikrama).
6. Details written from memory without a verse number, flagged for a spot-check (mostly Ramayana and Shiva Purana).

**Research updates after the review** (change the generators, not the generated files)
7. Briefs that say "not found" but the texts have it: the Pranava whisper (Utpatti 1259-1265), Parvati's birth to Himavan (Utpatti 375-410), Sambandar at Thiruvalangadu (Periya Puranam 1007-1011). Edit `build_new_sets.py` / `new_sets_briefs.py` / `shiva_story_data.py`, rebuild.
8. Apply the expert's song decisions to the song-story maps, then rebuild the books (`make_pdf.py`) and the index (`make_index.py`).

**English fixes found by the Tamil work (2026-11-24; fix both languages together, details in `tamil/PILOT-NOTES.md`)**
9. **"Film" wording in book text**: 18 narratives speak of "the film" (storyline wording that leaked in): `d-battlefield`, `d-idumbai`, `d-kanchi`, `d-matangi`, `d-kamakshi-32`, `n-sundarar-gold`, `ramayana-army-destroyed`, `ramayana-vali`, `saints-kurundam`, `saints-sambandar`, `sam-birth`, `sam-jains`, `sam-milk`, `sam-palanquin`, `sam-poompavai`, `sam-thiruvalangadu`, `sam-todudaiya`, `sam-yazhpanar`. Remove from the English and the Tamil.
10. Likely citation errors: `krishna-bakasura` "Peyalvar … Periya Thiruvandhadhi 64" (that work is Nammazhwar's); `avatar-temple` Thiruchchandha Viruththam 81 for Venkatam (81 is the churning); `sam-fever` "(Madurai)" after songs 527, 789; Purananuru 151 for Kumanan in `t-patrons` (probably 161).
11. Tevaram 6.38.5 in `forms-ardhanari`: the English reads it "male and female, and without birth", the thevaaram.org commentary "no births as woman or man". Decide the reading.

**Still open from before:** the narrative tone (now that all 142 are written, a read of a few per volume), the Kaumaram.com credit line, the introduction text in `pdf/book.typ`, and whether generated PDFs are committed (section 8). **Animation:** the Gemini Flow image-to-video test decides the motion approach (`animation/README.md`).

## 1. State at a glance

- Branch `next`: **everything is committed and pushed** at the end of the 2026-11-24 session (remote `origin` = teamayilavan/thiruppugazh_app). `main` has the scripture work only up to `72ff259` (2026-11-11); the narratives, storylines, animation plan, index and the Tamil work are on `next` only.
- **Two machines.** The earlier sessions ran on Windows (paths below under `D:\`; the source caches in `scripts/.cache/` exist only there). The 2026-11-23 session ran on Linux (see 14): no caches, no Typst checked, so no PDF was rebuilt there. The generated PDFs and their JSON are git-ignored; rebuild them with `make_pdf.py`.
- Typst: upgraded to **0.15.1** at `D:\Software\Typst\typst.exe` (on PATH). The old 0.13.1 binary is kept next to it as `typst-0.13.1.exe.bak`.
- The 8 PDFs and two samples are copied to **`D:\thiruppugazh-books\`** for the owner to review (see 3).
- All build checks pass: `build_new_sets.py` gives sambandar 40/40, saints 33/33, devi 25/25, murugan 62/62, tamil-lore 18/18, **0 warnings**; `audit_local.py` is clean (0 missing quotes, 0 bad titles, 0 count mismatches, 142 stories, 1,494 song entries).

| Set | Stories | Distinct songs | Confidence in the references |
|---|---|---|---|
| `vishnu/` | 68 (3 are catch-all placeholders) | 228 | Highest. Valmiki, Kamba (all episodes now pinned), Bhagavata, Mahabharata numbers machine-checked; Tamil refs confirmed, unsupported candidates removed |
| `shiva/` | 20 | 238 | Highest. Tevaram verses checked at the verse number; unsupported Sanskrit candidates removed |
| `sambandar/` | 12 | 108 | High. 40 verse checks against the Periya Puranam and Tevaram 1.45 |
| `saints/` | 10 | 24 | High for Sundarar (Tevaram 7.92 now alludes to the crocodile), Kannappar, Manikkavasagar, Vandi; Nakkeerar's cave and Cheraman's ascent partly tradition |
| `murugan/` | 12 | 381 | **High** for the stories: all six kandams of the Kanda Puranam are now cached and 62 verse checks run; the song-to-story assignment of the 381 songs is unchanged (keyword-level, doubtful ones read) |
| `devi/` | 12 | 40 | Medium to high: Devi Mahatmya (Sanskrit), Kanda Puranam, Tevaram and Tirumurai 11 pages checked; Kamakshi's 32 dharmas, Idumbai Durga and Matangi have no source |
| `ganesha/` | 3 | 9 | Valli-elephant is in the Kanda Puranam; the race and the scribe are tradition (searched, not in the texts) |
| `tamil-lore/` | 5 | 21 | High: Purananuru poems for Pari, Kari, Ay, Pekan, Nalli, Kumanan, Ori; Sangam and Thiruvanaikka checked |
| **Total** | **142** | **788 of 1,340** | 552 songs are in no story |

## 2. Owner decisions that bind the next session

Research (earlier sessions): no new stories; accuracy of the existing 142 first. Commit and push only when asked (CLAUDE.md), small logical commits, with the co-author trailer from the system reminder. `build_master.py ... --no-pdf` for Vishnu/Shiva rebuilds (the old Vishnu/Shiva reading PDFs from October are superseded by the new books; they sit in `D:\` and the repo, stale).

Books (this session, owner's words in quotes):

- **A4**, for printing. **Four volumes**, each in **two editions = 8 PDFs**:
  - Vol I Vishnu (68 stories), Vol II Shiva (20), Vol III Murugan (12), Vol IV Sambandar + saints + Devi + Ganesha + Tamil lore (42).
  - **Full edition**: story, then each song in full, then references. **Verses edition**: "we don't show the entire songs, only the subset where we have the reference lyrics lines".
- A song that serves several stories is **printed in full once per volume; later stories print only the highlighted lines and the page of the full song** (cross-reference).
- Songs "like code fences, a separate representation", **lyrics centred, smaller font, split into verses by the app's rule** (`lib/utils/verses.dart`: a verse = as many consecutive lines as the song's tune pattern has, else 2).
- **Story text in English; everything else Tamil**: lyrics, and **the full Tamil prose meaning (`pathavurai`)**. Labels on the song panel are Tamil (பாடல், பொருள்); section headings stay English.
- **Colour: green**, associated with Murugan. **Cover shows the title only** (Tamil + English title and one volume line).
- **Contents page at the front (clickable, with a chapter number for every story), footer link back to it on every page, PDF bookmarks for every story and section; each story heading carries its chapter number (alphabetical order within the volume), and the index of songs at the end gives chapter number and page.** (The earlier "index of stories at the end" was replaced by the contents.)
- "Expand the story a bit": **I write all 142 story texts and the owner reviews** (300-450 words each, strictly from the checked texts, verse numbers in brackets, English). "Should feel like a well-researched, high-quality publication with all source and reference materials."
- Remove the process language: no "commentary match", no confidence labels, no "machine-checked" in the printed text. Only references that were **read or machine-checked** are printed; search-only / memory-only / not-found ones are dropped from the tables and explained in the story text where it matters.
- Intended use: **personal study and printing**. Credit line in the book: "The text of the songs and their meanings follow the Thiruppugazh edition made available digitally by Kaumaram.com, as used in the Thiruppugazh app." The owner has **not** confirmed this wording (open question, 8).

## 3. The books: how it works

Files:

| File | What |
|---|---|
| `scripts/make_pdf.py` | Generator. Parses every `<set>/stories/*.md` (and `vishnu|shiva/master.json` for their references and links), reads the songs from `assets/thiruppugazh.db` (read-only), builds a JSON per volume/edition and runs `typst compile` |
| `pdf/book.typ` | The Typst template (cover, contents, introduction, stories, sources appendix, index of songs). One template serves both editions (`data.edition`) |
| `pdf/narratives/<slug>.txt` | The story text, plain paragraphs separated by blank lines. If the file is missing the generator falls back to the short brief from the story file |
| `pdf/.gitignore` | Ignores generated `*.pdf` and `*.json` |

Build (repo root):

```
python -I -X utf8 scriptures/scripts/make_pdf.py                        # all 4 volumes x 2 editions (about 15 s)
python -I -X utf8 scriptures/scripts/make_pdf.py --volume 3             # one volume, both editions
python -I -X utf8 scriptures/scripts/make_pdf.py --volume 3 --edition verses
python -I -X utf8 scriptures/scripts/make_pdf.py --stories m-jayanta d-mahisha --name sample   # a quick sample
```

Output names (in `scriptures/pdf/`): `thiruppugazh-stories-vol1-vishnu.pdf`, `...-vol2-shiva`, `...-vol3-murugan`, `...-vol4-others`, and `thiruppugazh-verses-vol1-vishnu.pdf` etc. Copy them to `D:\thiruppugazh-books\` for the owner.

Current sizes (with the short briefs for most stories): full 395 / 373 / 470 / 286 pages, verses 169 / 135 / 47 / 76. Page counts will grow when the narratives are written (roughly +1 to 2 pages per story).

Design notes: panels are header strip + centred lines in a bordered block; highlighted lines are the lines that carry the allusion (taken from the **bold** lines of the story files, matched to the database lines by `key()`); songs whose allusion is only in the meaning have no highlight (in the verses edition they are listed in one sentence under the story). `splitIntoVerses` is ported as `split_verses`. Reference tables use the `polish()` filter to drop working notes; extend `PROCESS` there if a new kind of internal note leaks.

## 4. Story texts: status and method

**All 142 are written** (2026-11-17; about 57,000 words in `pdf/narratives/<slug>.txt`). The first 14 (12 Murugan, `avatar-gajendra`, `d-mahisha`) were written one by one; the other 128 were written in parallel from the digests and the cached texts, and the corrections and open questions from that pass are in `storylines/REVIEW-NOTES.md`. Any rewrite (after the owner's or the expert's review) keeps the method below.

Method that worked (keep it): for each story, read the actual cached verses (do not trust a brief or a page summariser), write only what a verse says, put the verse numbers in brackets, and say plainly where the songs differ from the text or where nothing was found (see `m-sea-dried`, `m-agastya`). Before finishing, re-read each claim against the verse. This caught real errors in my own first drafts (a wrong "Indra arrives" at Deva 132, "Murugan smiles" that was Surapadman, the moon/sun/elephants of the quarters). Treat every first draft as suspect.

Where the texts are (all under `scripts/.cache/`, see 5):
- Ramayana stories: `valmiki_*` (sargas) and `kamba_*` (padalams), quotes in `vishnu/ramayana-episodes.md`; `build_ramayana_verses.py` lists the pinned verses.
- Krishna / Mahabharata / avatars: `sb_*` (Bhagavata, vedabase.io pages include purports: do not quote a purport as the text), `mbh_*` (GRETIL Critical Edition), `vishnu/krishna-episodes.md`, `avatar-episodes.md`.
- Shiva: `shiva/refs-sanskrit.json`, `tirumurai-deeds.json`, `refs-saints.json`, `tev_index.json` (every Tevaram pathigam 1-7), `tev_misc.json`.
- Sambandar, saints: `pp_all.json` (Periya Puranam, every section), `tvp.json` (Tiruvilaiyadal Puranam), `tev_index.json`.
- Devi, Ganesha, Tamil lore: `markandeya_dm_verses.json`, `kp_*.json`, `kanchi_part1.json`, `purananuru.json`.

For every story, also check its reference table reads cleanly in the PDF (step 4 of section 9).

## 5. Layout of the research base and how to run it

Per set folder (the six newer sets): `README.md`, `STORIES.md`, `by-song.md`, `song-story-map.txt`, `SOURCES.md` (sources, gaps, and the verse-check table), `stories/<slug>.md`. All **generated**; edit the data, not the output.

| What | File |
|---|---|
| Catalogue of the six newer sets (stories, song lists, regexes, refs, `CHECKS`) | `scripts/build_new_sets.py` (hand-written + generator) |
| Corrected briefs for the newer sets | `scripts/new_sets_briefs.py` (`BRIEF_FIX`) |
| Vishnu: episodes, verse refs | `ramayana_episodes.py`, `krishna_episodes.py`, `avatar_episodes.py`, `story_data.py`, `vishnu_briefs.py`, `vishnu/dp/*.json` |
| Shiva: episodes, refs | `shiva_episodes.py`, `shiva_story_data.py`, `shiva/*.json`, `shiva/song-story-map.txt` |
| Join Vishnu/Shiva into `master.json`, `STORIES.md`, `stories/` | `build_master.py --deity vishnu\|shiva --no-pdf` |
| Audits | `audit_all.py` (writes `AUDIT.md`), `audit_local.py` (fast) |
| Cache builders | `fetch_sources.py`, `fetch_krishna.py`, **`parse_kp_pm.py`** (Kanda Puranam), **`fetch_misc.py`** (Devi Mahatmya, Purananuru, selected Tevaram/Tirumurai pages: add pages to `TEV`), **`index_tevaram.py`** (every Tevaram pathigam; resumable) |

```
python -I scriptures/scripts/build_new_sets.py          # rebuild the six newer sets; expect every check ok and 0 warnings
python -I scriptures/scripts/build_master.py --deity vishnu --no-pdf
python -I scriptures/scripts/build_master.py --deity shiva  --no-pdf
python -I scriptures/scripts/audit_local.py             # fast
python -I scriptures/scripts/audit_all.py               # regenerates AUDIT.md (minutes)
```

Song source: `assets/thiruppugazh.db`, table `songs`, read-only. Columns: `id` (= song number), `title`, `place`, `tune_list`, `lyrics_list` (Tamil lines), `pathavurai` (Tamil prose meaning; 6 songs lack it, the generator then joins `meanings`), `english_pathavurai`, `english_meanings_list`. The per-line `meanings` list does **not** align with the lyric lines (it follows `words`), so a line-by-line meaning is not possible.

### Caches (git-ignored, `scriptures/scripts/.cache/`; they exist on this machine)

| Cache | What | How to rebuild |
|---|---|---|
| `mbh_NN.html`, `sb_*`, `valmiki_*`, `kamba_*` | Mahabharata (GRETIL), Bhagavata (vedabase.io), Valmiki, Kamba (Tamil Wikisource) | on demand by `fetch_sources.py` / `fetch_krishna.py`; real Wikisource padalam titles via the prefix-search API |
| `pp_all.json` | Periya Puranam, every section (`12000 + 10n`), verse numbers restart in each | thevaaram.org `onepage.php?thiru=12&Song_idField=<id>` |
| `tvp.json` | Tiruvilaiyadal Puranam padalams 3, 4, 5, 13, 51-61 | Tamil Wikisource render |
| `kp_by_kandam.json`, `kp_verses.json` | Kanda Puranam first kandam (Utpatti, 1-1783) from Wikisource | |
| `pm/*.html` + `kp_mahendra`, `kp_yuddha`, `kp_deva`, `kp_daksha`, `kp_asura`, `kanchi_part1` `.json` | **All six kandams** of the Kanda Puranam and Kanchi Puranam part 1, Project Madurai Unicode text. Files: `pmuni0286_01/02`, `0289_01/02/03`, `0293_01/02/03`, `0304`, `0307_01/02`, `0318_01/02`, `0251`, `0268`, `0273`; Kanchi Puranam `0292`, `0294`, `0299`. Never commit them (their licence needs the header page) | download `https://projectmadurai.org/pm_etexts/utf8/<file>.html` into `.cache/pm/`, then `python -I -X utf8 scriptures/scripts/parse_kp_pm.py`. Printed verse numbers have typos, repaired by `OVERRIDE`. Page omissions: Yuddha 894, 916-925, 1901; Daksha 632, 1361, 1704, 1738, 1747, 1754, 1870-1871; the last ~50 Asura verses drift by up to two (cite only with a word check) |
| `markandeya_dm_verses.json`, `purananuru.json`, `tev_misc.json` | Devi Mahatmya (Markandeya Purana 81-93, Banerjea numbering; the Pune edition counts 78-90), Purananuru 101-160 and 201-210, selected Tevaram/Tirumurai pages | `fetch_misc.py` |
| `tev_index.json` | every Tevaram pathigam 1-7 (title and verses) | `index_tevaram.py` |
| `audit/` | the 293 reference URLs | `audit_urls.py` + curl loop |

## 6. What is and is not verified

**Settled this session:** all 5 unpinned Kamba episodes pinned; Vishnu/Shiva candidate references settled; Kanda Puranam checked for the war, Jayanta, Krouncha, Tarakan, Deivayanai, Valli, Airavata; Devi Mahatmya for Mahishasura; Kanchi Puranam searched (supports the Ekambam legend only in its invocation vv. 4-6); Tevaram for Thiruvathigai (7.38), Pathirippuliyur (4.94), Avinashi (7.92 alludes to the crocodile), Thiruvalangadu (1.45), Tirumurai 11/8 pages.

**Tradition or songs only (stated as such in the briefs and the narratives):** the sea dried by the Vel (the Puranam has the spear's flame over the seas and drying seas in the fighting, not one act), Agastya taught by Murugan (searched all six kandams, none), Ganesha's world race and the Mahabharata scribe (not in the texts searched), Nakkeerar's cave, Cheraman's horse (the Puranam has Sundarar's ascent at 12370:174, the Ula does not name Sundarar), Sundarar's gold in song 947, Kamakshi's thirty-two dharmas (no source), Idumbai Durga, Matangi, the Thiruvalangadu contest details, the Kanchi bangle marks and Vegavati, Pathiri penance.

**Still weaker than the rest:** Kamba/Valmiki for Vishnu are checked for existence and fit to the episode, not wording line by line; the Murugan song-to-story assignments are keyword-level; the Asura kandam beyond verse ~1880 and the Daksha page gaps; Tiruvasagam and Sangam poems beyond the cited pages.

**Dropped on purpose:** Shumbha-Nishumbha-Raktabija (not in the songs); Siruthondar, Karaikkal Ammaiyar, Chandesar, Harishchandra, Nala, Dhruva, Silappathikaram, Manimekalai, Avvaiyar (searched, not found). Songs 555, 862, 911 use அப்பர் for "father" (Shiva), not the saint Appar.

## 7. Gotchas learned (Windows, this machine)

- **Do not write Python or Typst files containing backslashes through a shell heredoc.** `\n`, `\b`, `\s` were silently turned into real newlines and backspace characters twice this session (a regex with literal backspaces matched nothing for an hour). Use the Write/Edit tools for such files, and test a regex on a sample string.
- Run Python as `python -I -X utf8 ...`; `-I` ignores `PYTHONIOENCODING`, so Tamil printing needs `-X utf8` (or write output to a file and Read it).
- Typst: do not name a loop variable `v` (it shadows `v()`); labels must attach to an element (`#metadata(none)#label(...)`); PNG page files from `--pages` are named `p-1.png` without zero padding.
- thevaaram.org may refuse DNS briefly; `index_tevaram.py` retries and resumes. Page summarisers (WebFetch) give wrong verse numbers: parse the page yourself.
- Vedabase (Bhagavata) pages contain the translator's purports and chapter summaries; quote only the numbered Texts.
- `git status` shows CRLF warnings for the scripts; harmless.

## 8. Open questions for the owner

1. **Credit line** for Kaumaram.com (wording above is a draft) and whether to add a title/copyright page or editor name. The cover is title-only by instruction.
2. **Introduction text** in `pdf/book.typ` is my draft (fifteenth-century dating, "1,340 songs", description of the book); the owner should read it.
3. **Narrative tone and length**: all 142 are now written (the old rule "review 14 before writing the rest" is overtaken). The owner should still read a few per volume (`avatar-gajendra`, `m-valli-disguise`, `m-sea-dried`, and some of the 128 written in parallel) before the Tamil translation starts, since Tamil follows the English.
4. Should the generated PDFs be committed (earlier Vishnu/Shiva PDFs were), or stay out of git (current `.gitignore`)?
5. In the verses edition, songs whose allusion is only in the meaning are listed in one sentence; acceptable, or should the first verse be shown?
6. Tamil labels (பாடல், பொருள்) on the song panel and English section headings: keep the mix?

## 9. Next steps, in order (updated 2026-11-24)

1. **Owner:** answer the decisions in section 0 (items 1-4) and the open questions in section 8; read a sample of narratives per volume.
2. **Owner:** send `pdf/story-song-index.pdf` (copy in `D:\thiruppugazh-books\`) to the Thiruppugazh expert.
3. Research corrections that do not wait for the expert (section 0, item 7): fix the three "not found" briefs in the generators, rebuild.
4. Look through the full-edition PDFs of Vishnu, Shiva and Vol IV page by page for layout faults (only Murugan and the samples were inspected closely): long titles, songs with many verses, wide reference tables, blank gaps before panels, Tamil wrapping.
5. When the expert answers: apply the song decisions (section 0, item 8), rebuild the books and the index, copy to `D:\thiruppugazh-books\`.
6. Regenerate `AUDIT.md` (`audit_all.py`; stale, dated 2026-11-10) and fold the results into `STATUS.md`.
7. **Tamil edition** (section 13): 138 of 142 done (2026-11-24). The owner reviews `tamil/PILOT-NOTES.md` (one section per volume), ideally with a Tamil reader. Fix the English items in section 0 (9-11) in both languages. `sam-jains`, `saints-sambandar`, `d-idumbai` and `avatar-pralaya` follow the section 0 decisions. Then propose the book's language switch (`make_pdf.py` / `book.typ`, Tamil titles per story) before changing it.
8. Animation: the owner runs the Flow motion test (section 12).
9. Commit and push only when asked. Small commits: generator/template, then texts per volume, then regenerated sets.
10. Research leftovers if time allows: Kamba/Valmiki wording comparison for the most-told Vishnu stories (Gajendra, Vamana, Krishna butter, Ramayana war); the 552 songs in no story (second keyword pass, then reading); the app side is undecided (CLAUDE.md principles apply if stories ever go in the app: offline, quiet, opt-in, Tamil layout testing).

## 10. Kickoff prompt for the next session

> Read scriptures/HANDOFF.md (section 0, then section 13), then tamil/README.md and tamil/PILOT-NOTES.md.
> 138 of 142 stories are in Tamil; four are held for owner decisions (section 13). First ask which owner decisions are answered: section 0,
> the review items in PILOT-NOTES (respect forms, incl. the Lord in disguise; the Purananuru 151/161 question; Tevaram
> 6.38.5; the "film" wording in 18 English narratives, section 0 item 9), and
> whether a Tamil reader has looked at the pilot. Then translate the held stories that the decisions release, in the same way:
> glossary forms, app song places, original Tamil for quoted lines, and run scripts/glossary_check.py after each
> batch until it reports 0 differences. Commit only when I ask.

## 11. Storylines for animated videos (2026-11-16)

The owner widened the scope: besides the research base and the printed books, every story now has a **storyline for an animated video**, hosted online (not in the app). Rules, format and progress are in [`storylines/README.md`](storylines/README.md) and [`storylines/CHECKLIST.md`](storylines/CHECKLIST.md).

- **English only, under 3 minutes** (7 to 9 scenes, at most 165 seconds), one file per story at `storylines/<set>/<slug>.md`.
- `python -I -X utf8 scriptures/scripts/check_storylines.py` enforces the rules and ticks the checklist. **All 142 first drafts exist and pass it.**
- *(2026-11-17: all 142 are now at script level and committed; the corrections are in `storylines/REVIEW-NOTES.md`. The rest of this list is the 2026-11-16 first-draft state.)*
- **They were first drafts, written fast.** Murugan (12) rest on the verified narratives. Sambandar (12) rest on the research briefs; the files flag the few scenes that need a verse check (`sam-palanquin`, `sam-three-saints`, `sam-todudaiya`). The Saints, Devi, Ganesha, Tamil lore, Shiva and Vishnu films rest on the briefs and on the standard tellings; where the research has only a song or a single line, the file says so and keeps the film to a short invocation. Scenes are storyboard-level (visuals plus a short narration), not yet full scripts.
- **Open owner decisions** are written into the files' production notes: whether the Jain impalement tradition (`sam-jains`) appears at all, and how to frame `krishna-clothes`, `krishna-naraka-wives` and `ramayana-sita-agni` for a public video.
- **Next:** a verse-check pass per set against the caches in section 5, then a richer second pass (fuller narration, dialogue) for the stories chosen for production first.

## 12. Animation production (started 2026-11-16)

The storylines are to become animated videos (2D, owner and Claude only; English female Sarvam voice; synthesised music; 16:9 and 9:16). Everything about the look, tools, decisions, the pending Flow motion test and the next steps is in [`animation/README.md`](animation/README.md). Read it first. The plan, prompts and tools in `animation/` are committed (`ba98d9d`); images, renders and `.env` are git-ignored.

## 13. Tamil edition (started 2026-11-23)

Goal: a **separate Tamil edition** of the four volumes, in **simple modern prose** (owner's decisions, 2026-11-23). The songs and their meanings are already Tamil; the story texts (`pdf/narratives/`, 142 files, about 57,000 words), headings and front matter are what change. The storylines may follow later.

**Where it stands (end of 2026-11-24):**

| Volume | Tamil stories | Notes |
|---|---|---|
| I Vishnu | 67 of 68 | done 2026-11-24; `avatar-pralaya` held for section 0, item 3 |
| II Shiva | 19 of 20 | done 2026-11-24; `saints-sambandar` held for section 0, item 1 (same impalement paragraph as `sam-jains`) |
| III Murugan | 12 of 12 | done |
| IV the rest | 40 of 42 | `sam-jains`, `d-idumbai` held for section 0 decisions |
| **Total** | **138 of 142** | held: `sam-jains`, `saints-sambandar` (item 1), `d-idumbai` (item 4), `avatar-pralaya` (item 3) |

**Files.** `pdf/narratives-ta/<slug>.txt` (same slug and paragraphs as the English); `tamil/GLOSSARY.md` (587 rows, the one Tamil form per name and term, with notes on permitted uses); `tamil/README.md` (style guide and order of work); `tamil/PILOT-NOTES.md` (choices applied and review items, per volume); `tamil/glossary-report.md` (generated).

**The checker** `python3 -I -X utf8 scriptures/scripts/glossary_check.py` (read-only except its report) checks, and at the end of the session reports 0 problems on all of:
- each Tamil story has the English story's paragraphs and **exactly its numbers** (verses, songs, chapters);
- each Tamil story uses only the glossary's forms, or a form a glossary note permits there;
- glossary forms against the app's Tamil meanings, lyrics and song places (`assets/thiruppugazh.db`).

**How a story is translated** (keep this): read the English; look up the app's `place` for every song the English places ("song 928 (Karuvur)" → பாடல் 928 (கருவூர்)); quote Tamil originals where the English quotes or names them (padalam titles, hymn openings, song lines: check song lines against the app's lyrics, padalam titles against the Project Madurai pages the research used); translate the rest into plain modern Tamil, paragraph for paragraph, adding nothing; respect forms for gods, saints, sages and Arunagiri, plain for villains and ordinary characters, neuter for animals; run the checker; fix or note every flag.

**Sources used for quoted Tamil (Linux, no caches):** Kamban verses are in `vishnu/ramayana-episodes.md` (Tamil text of every cited verse; quote the phrase the English renders, gloss it in modern Tamil). Tevaram / Tirumandiram / Periya Puranam: place names, section titles and opening words in `shiva/tirumurai-deeds.json` and `shiva/refs-saints.json`; full verses on thevaaram.org (`onepage.php?thiru=<book>&Song_idField=<id>` with `curl`). Divya Prabandham openings: `vishnu/dp/*.json` (`first_words`, URLs on divyaprabandham.koyil.org). Song words: the app DB's `lyrics` (Python `sqlite3`). Tiruvilaiyadal padalam titles: Tamil Wikisource pages cited in `shiva/stories/`.

**Glossary practice:** an "also seen" form used on purpose (Kamban's இராவணன் in his titles, தில்லை where the English says Thillai) is permitted by naming it in that row's note; the checker then stops flagging it. Rows are edited by name (exact-string replacement failed once on a row with variants). Respect-form rules per volume are in `PILOT-NOTES.md`.

**Open items:** the review list in `tamil/PILOT-NOTES.md`, chiefly: the respect forms for the Lord in disguise (`m-valli-disguise` vs `n-vandi-pittu`); Purananuru 151 for Kumanan, probably 161 (Wikisource's "151-160" page prints 161-170); the unverified Tarakan padalam title; hymn openings quoted from memory, to check against the caches; "(Madurai)" in the English of `sam-fever`.

Ground rules:
- Translate only from the settled English (after the section 0 decisions and the expert's song corrections), so the two editions do not drift. A later change to an English story must be repeated in its Tamil file.
- One glossary for every name and term; add a row before using a new name.
- Where the English quotes or paraphrases a Tamil source, use the original Tamil words, not a back-translation. Sanskrit sources are translated, with the verse numbers kept.
- A Tamil reader the owner trusts should review before the book is built.

## 14. This Linux machine (2026-11-23)

- Repo at `~/dev/projects/thiruppugazh_app`. Git identity is set **for this repo only** (`Ayilavan <teamayilavan@gmail.com>`, matching earlier commits).
- `gh` 2.105.0 installed to `~/.local/bin/gh` (official release, checksum verified), logged in as `teamayilavan`; `gh auth setup-git` makes plain `git push` work.
- No `sqlite3` CLI: read the app DB with Python's `sqlite3` module. No `scripts/.cache/` here, so verse checks against the cached sources must wait for the Windows machine or be fetched again (Project Madurai pages work; Tamil Wikisource's Purananuru pages are mis-numbered).
- Writing Python through a shell heredoc mangled a `\u` escape once this session (the Windows gotcha in section 7 applies here too): use the Write/Edit tools for code.
