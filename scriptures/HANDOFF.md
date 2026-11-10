# Scripture work: handoff (end of session, 2026-11-11)

Read this first in the next session, then `README.md` (layout), `STATUS.md` (log) and `AUDIT.md` (what is verified; it is **stale**, see 9).
`scriptures/` is research material. It is never bundled into the app and never touches `lib/`, the DB or the schema.

There are now two strands of work:

1. **The research base** (142 stories, their songs and references), accuracy-first. Largely complete; see 2 and 6.
2. **The books**: *Stories in the Thiruppugazh*, a printable A4 publication built with Typst from that research. A working pipeline exists; the main remaining job is **writing the story texts** (14 of 142 done). See 3 to 5.

## 1. State at a glance

- Branch `next`: **everything is committed and pushed** (last commit `b0f0af8`, 2026-11-11; remote `origin` = teamayilavan/thiruppugazh_app). `main` untouched. The generated PDFs and their JSON are git-ignored; rebuild them with `make_pdf.py`.
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

**Written (14 of 142):** all 12 Murugan stories (`m-agastya`, `m-airavata`, `m-brahma-prison`, `m-deivayanai`, `m-jayanta`, `m-krouncha`, `m-mango-sura`, `m-peacock-cock`, `m-saravana`, `m-sea-dried`, `m-tarakasura`, `m-valli-disguise`) plus `avatar-gajendra` and `d-mahisha`. **128 remain** (brief only): Vishnu 67, Shiva 20, Vol IV 41.

Method that worked (keep it): for each story, read the actual cached verses (do not trust a brief or a page summariser), write only what a verse says, put the verse numbers in brackets, and say plainly where the songs differ from the text or where nothing was found (see `m-sea-dried`, `m-agastya`). Before finishing, re-read each claim against the verse. This caught real errors in my own first drafts (a wrong "Indra arrives" at Deva 132, "Murugan smiles" that was Surapadman, the moon/sun/elephants of the quarters). Treat every first draft as suspect.

Where the texts are (all under `scripts/.cache/`, see 5):
- Ramayana stories: `valmiki_*` (sargas) and `kamba_*` (padalams), quotes in `vishnu/ramayana-episodes.md`; `build_ramayana_verses.py` lists the pinned verses.
- Krishna / Mahabharata / avatars: `sb_*` (Bhagavata, vedabase.io pages include purports: do not quote a purport as the text), `mbh_*` (GRETIL Critical Edition), `vishnu/krishna-episodes.md`, `avatar-episodes.md`.
- Shiva: `shiva/refs-sanskrit.json`, `tirumurai-deeds.json`, `refs-saints.json`, `tev_index.json` (every Tevaram pathigam 1-7), `tev_misc.json`.
- Sambandar, saints: `pp_all.json` (Periya Puranam, every section), `tvp.json` (Tiruvilaiyadal Puranam), `tev_index.json`.
- Devi, Ganesha, Tamil lore: `markandeya_dm_verses.json`, `kp_*.json`, `kanchi_part1.json`, `purananuru.json`.

Suggested order: **Vol IV first** (42 stories, texts already in hand), then **Shiva (20)**, then **Vishnu (68, the largest)**. Have the owner review each volume's narratives before moving on. For every story whose narrative is written, also check its reference table reads cleanly in the PDF.

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
3. **Narrative tone and length**: review the 14 written stories (especially `avatar-gajendra`, `m-valli-disguise`, `m-sea-dried`) before the other 128 are written in the same style.
4. Should the generated PDFs be committed (earlier Vishnu/Shiva PDFs were), or stay out of git (current `.gitignore`)?
5. In the verses edition, songs whose allusion is only in the meaning are listed in one sentence; acceptable, or should the first verse be shown?
6. Tamil labels (பாடல், பொருள்) on the song panel and English section headings: keep the mix?

## 9. Next steps, in order

1. Owner reviews the PDFs in `D:\thiruppugazh-books\` (cover, contents, a Murugan volume, the samples) and answers 8. **Do not write the remaining 128 narratives until the owner has accepted the style of the first 14.**
2. Write narratives volume by volume (Vol IV, Shiva, Vishnu), rebuild, copy to `D:\thiruppugazh-books\`, ask for review of each volume.
3. Look through the full-edition PDFs of Vishnu, Shiva and Vol IV page by page for layout faults (only Murugan and the samples were inspected closely): long titles, songs with many verses, wide reference tables, blank gaps before panels, Tamil wrapping.
4. Regenerate `AUDIT.md` (`audit_all.py`; it is stale, dated 2026-11-10) and fold this session's results into `STATUS.md`.
5. Commit and push only when asked (the work up to `b0f0af8` was committed and pushed at the owner's request). Suggested small commits as you go: generator/template, then narratives per volume, then regenerated sets.
6. Research leftovers if time allows: Kamba/Valmiki wording comparison for the most-told Vishnu stories (Gajendra, Vamana, Krishna butter, Ramayana war); the 552 songs in no story (second keyword pass, then reading); the app side is undecided (CLAUDE.md principles apply if stories ever go in the app: offline, quiet, opt-in, Tamil layout testing).

## 10. Kickoff prompt for the next session

> Read scriptures/HANDOFF.md, then README.md and STATUS.md. We are writing the story texts for the book "Stories in the Thiruppugazh"
> (pdf/narratives/<slug>.txt, built with scripts/make_pdf.py). 14 of 142 are written. First ask whether I have reviewed the PDFs in D:\thiruppugazh-books
> and answered the open questions in section 8; then continue with Volume IV (the 42 stories of Sambandar, saints, Devi, Ganesha, Tamil lore), writing each
> strictly from the cached verses, checking every claim against the verse, and rebuilding the PDFs. Commit only when I ask.
