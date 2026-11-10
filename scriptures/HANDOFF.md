# Scripture work: handoff (written 2026-11-11, updated end of session 2026-11-11 later)

Read this first in the next session, then `README.md` (layout), `STATUS.md` (log) and `AUDIT.md` (what is verified).
`scriptures/` is research material. It is never bundled into the app and never touches `lib/`, the DB or the schema.

## 1. Where we are

Goal of the whole effort: for every story the Thiruppugazh alludes to, know the stories, the songs that allude to them, and the primary-text
references, **with maximum confidence** (owner's words, 2026-11-11: "we don't want to look for more stories; for existing stories let us be very
thorough and accurate"). The last two sessions therefore went into verification, not new stories.

| Set (folder) | Stories | Songs | How built | Confidence |
|---|---|---|---|---|
| `vishnu/` | 68 (3 are catch-all placeholders) | 228 | hand-read (session 1) + verse-level scripts | Highest. Valmiki, Kamba, Bhagavata, Mahabharata numbers machine-checked; 144 of 157 Tamil refs confirmed |
| `shiva/` | 20 | 238 | hand-read (session 1) | Highest. 200 of 211 Tamil refs confirmed; Tevaram verses checked at the verse number |
| `sambandar/` | 12 | 108 | commentary sweep, then read and corrected | High. 39 verse checks against the Periya Puranam text |
| `saints/` | 10 | 24 | same | High for Sundarar, Kannappar, Manikkavasagar, Vandi; Nakkeerar's cave and the crocodile are tradition |
| `devi/` | 12 | 40 | same | Medium. Temple legends only for Kanchi, Pathiri, Kali's dance; Tiruvilaiyadal text for the fisher-girl |
| `murugan/` | 12 | 381 | same, large lists read where doubtful | Medium. First kandam of the Kanda Puranam checked; the war, Valli, Deivayanai rest on the songs' commentary |
| `ganesha/` | 3 | 9 | same | Low-medium. Song and tradition only |
| `tamil-lore/` | 5 | 21 | same | High for Sangam/Rudrasarman and Thiruvanaikka (Tiruvilaiyadal and Periya Puranam texts) |
| **Total** | **142** | **788 distinct of 1340** | | 552 songs are in no story |

**Correction of an earlier message:** I once said "948 songs covered" and "392 in no story". That counted map rows for songs without a story.
The true figures are 788 and 552.

Git: at the start of this session everything was committed and pushed on `next` (`02314ac`). This session's changes (parse_kp_pm.py, build_new_sets.py, new_sets_briefs.py and the regenerated murugan/devi/saints/sambandar/tamil-lore files) are uncommitted until the owner asks. `main` is untouched.

## 2. Owner decisions that bind the next session

- No new stories for now. Accuracy of the existing 142 comes first.
- No PDFs. The existing Vishnu and Shiva PDFs are stale for three Vishnu stories and the Shiva briefs changed; do not rebuild unless asked.
- One folder per theme, same shape as `shiva/` and `vishnu/`.
- Commit and push only when asked (CLAUDE.md). Small logical commits. Co-author trailer as given by the system reminder.
- `build_master.py ... --no-pdf` must be used for Vishnu/Shiva rebuilds.

## 3. Layout

Per set folder (new sets): `README.md`, `STORIES.md` (index), `by-song.md`, `song-story-map.txt`, `SOURCES.md` (sources, gaps, and the verse-check table), `stories/<slug>.md`.
All of these are **generated**; edit the catalogue/data, not the output.

| What | File | Hand-written or generated |
|---|---|---|
| Catalogue of the six newer sets (stories, song lists, regexes, refs, source notes) | `scripts/build_new_sets.py` | hand-written + generator |
| Corrected briefs for the newer sets | `scripts/new_sets_briefs.py` (`BRIEF_FIX`) | hand-written |
| Vishnu: episodes, verse refs, briefs | `ramayana_episodes.py`, `krishna_episodes.py`, `avatar_episodes.py`, `story_data.py`, `vishnu_briefs.py` (per-episode brief overrides), `vishnu/dp/*.json` (Tamil refs) | hand-written |
| Shiva: episodes, refs, briefs | `shiva_episodes.py`, `shiva_story_data.py`, `shiva/refs-sanskrit.json`, `shiva/tirumurai-deeds.json`, `shiva/refs-saints.json`, `shiva/song-story-map.txt` | hand-written |
| Joins Vishnu/Shiva into `master.json`, `STORIES.md`, `by-song.md`, `stories/` | `build_master.py --deity vishnu|shiva --no-pdf` (`deity_*.py` hold per-deity settings) | generator |
| Audits | `audit_all.py` (writes `AUDIT.md`) runs `audit_local.py`, `audit_dp.py`, `audit_refnum.py`, `audit_refs.py`; `audit_urls.py` lists URLs | scripts |
| Content-level checks | `verify_content.py` (Valmiki/Bhagavata), `verify_content2.py` (wisdomlib), `verify_verses.py` (Tevaram verse numbers), `verify_dp_gist.py` (Vishnu Tamil gists) | scripts, print to stdout |
| Text helpers | `fetch_sources.py`, `fetch_krishna.py`, `find_kamba.py`, `find_valmiki.py`, `kamba_q.py`, `vq.py` | helpers |

Song source: `assets/thiruppugazh.db`, table `songs`, always opened read-only (`file:...?mode=ro`). Useful columns: `lyrics_list` (Tamil lines, JSON list),
`english_meanings_list` and `english_pathavurai` (the English commentary: **the best place to find which story a song alludes to**), `meanings`/`pathavurai` (Tamil).

## 4. How to run things

From the repo root, always with `python -I`:

```
python -I scriptures/scripts/build_new_sets.py          # rebuild the six newer sets; prints verse-check results (expect all ok, 0 warnings)
python -I scriptures/scripts/build_master.py --deity vishnu --no-pdf
python -I scriptures/scripts/build_master.py --deity shiva  --no-pdf
python -I scriptures/scripts/audit_all.py               # regenerates AUDIT.md (takes a few minutes; also rebuilds the new sets)
python -I scriptures/scripts/audit_local.py             # fast: quotes, titles, counts for all 142 files
```

`build_new_sets.py` also deletes story files whose slug left a set. Rebuilding Vishnu/Shiva only changes files when data changed; check `git diff --stat`.

### Caches (git-ignored, in `scriptures/scripts/.cache/`)

They exist on this machine. On another machine recreate them (a few minutes):

| Cache | What | How |
|---|---|---|
| `mbh_NN.html`, `sb_*`, `valmiki_*`, `kamba_*` | Mahabharata (GRETIL), Bhagavata (vedabase.io), Valmiki (valmikiramayan.net), Kamba (Tamil Wikisource) | filled on demand by `fetch_sources.py` / `fetch_krishna.py` |
| `pp_all.json` | Periya Puranam, every section: `{section_id: {verse: text}}`; section id = `12000 + 10n` from `https://thevaaram.org/thirumurai_1/onepage.php?thiru=12&Song_idField=<id>` (n = 0..70); verse numbers restart in each section; Sambandar is 12280 (1256 verses), Kannappar 12100, Eyarkon 12290, Kazharitrarivar 12370, Kochchengat 12680 | download each page, regex `class="heading">N</span></h3>...class="Padal">` |
| `tvp.json` | Tiruvilaiyadal Puranam padalams 3, 4, 5, 13, 51-61 (rendered text, spaces removed) | `https://ta.wikisource.org/w/index.php?action=render&title=திருவிளையாடற்_புராணம்/NN` |
| `kp_by_kandam.json`, `kp_verses.json` | Kanda Puranam: one Wikisource page (`கந்த_புராணம்`, action=raw). **Numbering restarts at 1 in each kandam** (Utpatti 1-1783, Asura 1-925). `kp_verses.json` is Utpatti only | parse lines `N<TAB> text`, new kandam when N falls back to <=5 |
| `pm/*.html`, `kp_mahendra.json`, `kp_yuddha.json`, `kp_deva.json`, `kanchi_part1.json` | Kanda Puranam (Mahendra 1-1178, Yuddha 1-2967, Deva 1-421) and Kanchi Puranam part 1, Project Madurai Unicode text. Files `pmuni0286_01/02`, `0289_01/02/03`, `0293_01/02/03`, `0304` (Kanda Puranam), `0292`, `0294`, `0299` (Kanchi Puranam); header pages must stay intact, so never commit them | download `https://projectmadurai.org/pm_etexts/utf8/<file>.html` into `.cache/pm/`, then `python -I scriptures/scripts/parse_kp_pm.py`. The page's printed verse numbers have typos; `parse_kp_pm.py` repairs them (see `OVERRIDE`). The Yuddha page omits verses 894, 916-925, 1901. Numbers run within each kandam |
| `audit/` | all 293 reference URLs, file name = first 16 hex of sha1(url) | `audit_urls.py` then a curl loop (strip CR from the list first) |

## 5. Lessons and gotchas

- The Tamil lyrics are in sandhi form; searching them by name finds almost nothing. Sweep the English commentary columns instead.
- Keyword-level assignments are noisy. Every automatic list needs reading; loose regexes (`Krouncha`, `mango tree`, `peacock`) caught similes and place descriptions.
- Page summarisers (WebFetch) give wrong verse numbers and sometimes wrong plots (it said the yazh "broke"; the text says otherwise). **Parse the page yourself** and read the verse.
- thevaaram.org verse numbers are running numbers within a puranam/pathigam; the Shiva file and the newer sets use the same scheme (settled).
- The koyil.org (Divya Prabandham) site is still publishing; some pasurams (e.g. Periya Thirumozhi 11.5.5) are not up yet. Pages carry transliteration, not Tamil script, so Tamil opening words are matched by a consonant skeleton (`audit_dp.py`).
- Valmiki net groups shlokas as `1-75-14b, 15, 16a`; one interior shloka (1.36.15) is unlabelled.
- Kanda Puranam Wikisource has only the first kandam and the start of the second. The Mahendra, Yuddha and Deva kandams are on Project Madurai (see caches). Not found yet: the Valli padalam, the Daksha kandam, and the Asura kandam beyond Wikisource's start.
- Windows: write URL lists with `\n` only; avoid long heredocs containing Tamil or quotes (use the Write tool then run); print Tamil with `sys.stdout.reconfigure(encoding="utf-8")`.
- Generated files must not be hand-edited. A brief in a generated story file is overwritten on the next build.

## 6. What is NOT verified (be honest about these when telling stories)

- **Songs/tradition only (labelled in the briefs):** the sea dried by the Vel (the Puranam has Sura stand in the sea; the Vel's fire spreads over the seas), Agastya taught by Murugan, Valli's wooing (its padalam is not in the Project Madurai files found), Ganesha as the elephant, the world race, the Mahabharata scribe, Nakkeerar's cave, Sundarar and the crocodile, Cheraman's Kailasa ascent, Sundarar's gold in song 947, Kamakshi's thirty-two dharmas, the Thiruvalangadu contest details, the Kanchi and Pathiri temple legends.
- **Never fetched:** Devi Mahatmya Sanskrit (GRETIL 404, sanskritdocuments blocked); chapter numbers come from two edition descriptions (81-93 Banerjee, 78-90 Venkatesh). Tiruvasagam, Tirumurugatruppadai, Adi Ula, Sangam poems, Tevaram hymn numbers for Sundarar's episodes.
- **Existence checked, not wording:** Kamba and Valmiki verse numbers for Vishnu (the verse exists and was read against the episode title, but the Tamil/English wording was not compared line by line).
- **Candidates:** Shiva has 11 and Vishnu 13 Tamil references still labelled candidates (`confirmed: false`); 5 Kamba references say "verse not pinned" (birth, Surpanakha, Ravana's scheming, army march, army destroyed).
- **Dropped on purpose:** Shumbha-Nishumbha-Raktabija are not in the songs; Siruthondar, Karaikkal Ammaiyar, Chandesar, Harishchandra, Nala, Dhruva, Silappathikaram, Manimekalai, Avvaiyar were searched and not found.
- Songs 555, 862, 911 use அப்பர் for "father" (Shiva), not the saint Appar.

## 7. Suggested next steps (in order of value for confidence)

Done 2026-11-11 (later): step 1 and part of step 2 of the earlier list. Mahendra, Yuddha and Deva kandams of the Kanda Puranam are now cached and
machine-checked (`parse_kp_pm.py`, checks `kpm`/`kpy`/`kpd`); briefs for m-mango-sura, m-sea-dried, m-peacock-cock, m-jayanta, m-deivayanai were rewritten from the text
(Surapadman goes into the sea as a mango tree, 1,100 yojanas; the Vel fells the tree and splits his body; the halves return as cock and peacock; Indra had earlier been a peacock mount;
Veerabahu frees Jayanta; the wedding is at Thiruparankundram). The Kanchi Puranam (Sivagnana Munivar, vv. 1-1691) was searched: only invocation vv. 4-6 support the Ekambam legend (Kampa river, embrace, breast mark); no 'thirty-two dharmas'.

1. Read the rest of the Kanda Puranam text for the Murugan stories not yet checked against it: m-krouncha and m-tarakasura (Asura kandam, find it), the war details in `m-mango-sura` (Banukopan, Hiranyan, Simhamukhan days), and look for the Valli padalam (try Project Madurai file numbers around `pm0286`-`pm0304`, the catalogue at https://www.projectmadurai.org/pmworks.html, and tamilvu).
2. Devi: Devi Mahatmya Sanskrit for `d-mahisha`; a Thiruvalangadu source for `d-kali-dance`; the Ekambam padalam of the Kanchi Puranam (may be a separate part) for `d-kanchi`.
3. Pin the 5 unpinned Kamba verses (padalam page names for two of them 404; check the real Wikisource page titles with the prefix-search API).
4. Confirm the remaining 11 Shiva and 13 Vishnu candidate Tamil references, or remove them.
5. Open Tevaram hymns for Sundarar's episodes and Tiruvasagam/Tirumurugatruppadai pages; add them to `REF2`/`CHECKS` in `build_new_sets.py`.
6. Compare Kamba/Valmiki wording with each Vishnu episode (deeper than the existence check) for the stories that will be told most (Gajendra, Vamana, Krishna butter, Ramayana war).
7. Only after 1-6: the 552 songs in no story, and any new stories.
8. The app side is undecided. If stories ever go into the app, the CLAUDE.md principles apply (offline, quiet, opt-in, Tamil layout testing, additive schema with backup export). Nothing is planned.

## 8. Kickoff prompt for the next session

> Read scriptures/HANDOFF.md, then README.md, STATUS.md and AUDIT.md. We are continuing accuracy work on the existing 142 stories (no new stories, no PDFs).
> Start with step 1 of section 7, report what you find before changing data, and keep every change
> machine-checked through build_new_sets.py. Commit only when I ask.
