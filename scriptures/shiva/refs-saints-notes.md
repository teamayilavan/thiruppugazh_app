# refs-saints notes

Companion to `refs-saints.json` (slugs: shiva-sambandar, shiva-tiruvilaiyadal, shiva-nayanmar, shiva-kurundam, shiva-pranava, shiva-skanda-birth).
Only verse/chapter numbers, a few Tamil first words and my own gists are stored. `confirmed: true` means the page was opened and the passage matches.

## What was opened and used

- **Kanda Puranam (Kachchiyappa Sivachariyar)**: Tamil Wikisource raw wikitext of the whole poem in one page,
  `https://ta.wikisource.org/w/index.php?title=கந்த_புராணம்&action=raw`. Numbering is a running verse number inside the
  kandam (Utpatti Kandam 1-1783), shown at the start of each verse; the padalam headings carry the verse range.
  Used: Utpatti Kandam padalam 11 Tiruvavatara (851-977), 13 Saravana (1015-1051), 16 Ayanai Siraipuri (1205-1223),
  17 Ayanai Sirai Neekku (1224-1265). Numbers were read by parsing the page myself.
- **Periya Puranam (Tirumurai 12)** on thevaaram.org: `onepage.php?thiru=12&Song_idField=<id>` gives a whole puranam.
  The verse numbers are the running number within that puranam (the site's "padal ennn"). Ids used: 12000 (Payiram and
  Tirumalai Charukkam, Sundarar), 12100 Kannappar, 12210 Appar, 12280 Sambandar (1256 verses), 12290 Eyarkon Kalikkama
  (contains the Lord as messenger to Paravai), 12360 Siruthondar. The parsed verse counts match the site's totals.
- **Tevaram and Tiruvasagam** on thevaaram.org (`songview.php?thiru=T&Song_idField=T*1000+padhi&padhi=NNN`, and `onepage.php`
  for Tirumurai 8). The "padhi" number equals the usual Tirumurai.pathigam number (checked: 1.1, 2.66 Tirunirru, 3.54 Vazhga Andhanar,
  4.11 Sorrunai Vedhiyan, 7.1 Pitha Pirai Soodi). The site's "pathiga varalaru" (history note) is what links a pathigam to the
  event; I rely on it and have not checked it against a printed edition. A full scan of the first verse of every pathigam of
  Tirumurai 1-7 was used to find Tiruvedagam (3.32) and Tiruchirappalli (5.85).
- **Tiruvilaiyadal Puranam**: Tamil Wikisource has Paranjothi's work only as a modern prose retelling by Prof. R. Srinivasan
  (2000), 64 padalams, `திருவிளையாடற்_புராணம்/NN`. Its chapter numbering follows Paranjothi's 64 padalams (59 Nari pariyakkiya,
  60 Pari nariyakiya, 61 Man sumantha, 62 Pandiyan suram theertha, 63 Samanarai kazhuvetriya). The raw wikitext of those pages
  only transcludes scanned pages, so I read the rendered text with `action=render`. There is no verse numbering and no
  Tamil verse text, so `first_words_ta` is empty for these.
- **Skanda Purana (Tagare translation)** on wisdomlib: Maheshvara-khanda, Kedara-khanda, Chapter 27 "The Birth of Kumara
  Karttikeya" and Appendix 1 "The story of Skanda's birth" (Mahabharata Shalya 44.6-13 is cited there, not opened by me).
- **kaumaram.com** (devotional, secondary) for the Brahma/Pranava summary.

## Divergences worth knowing

- **Skanda's birth has two traditions.** Kanda Puranam (Tamil, from the Sankara Samhita) has the six sparks from Shiva's
  forehead eyes borne by Vayu and Agni to the Ganga and the Saravana pond, the six Krittikas feeding six babies, and Uma
  uniting the six into one (vv 914-917, 937, 966-967, 1034-1035). Tagare's Skanda Purana ch. 27 has the Agni-and-semen version
  with the sages' wives. The Thiruppugazh lines about the eye match the Kanda Puranam version.
- **Pranava**: Kanda Puranam gives Brahma's failure and imprisonment (1205-1223) and Shiva's request, Brahma's release, and
  Murugan whispering the meaning of the one word into Shiva's ear (1246-1262). Kanda Puranam does not mention
  Swamimalai; the Swamimalai attribution is temple tradition and is listed unconfirmed.
- **Periya Puranam does not contain Manikkavasagar.** His story is in Tiruvilaiyadal Puranam padalam 58-61 and in the Tiruvasagam itself.
  For the Perunthurai kurundam tree and Vadavur: Tiruvasagam Kirththit Tiruvagaval (about lines 35, 46, 60 on the site's line
  numbers), Arutpathu 1 (Tiruvasagam 29) and the prose retelling.
- **Tiruvasagam numbering** on thevaaram.org is by section 1-51 in the book order (e.g. 29 Arutpathu, 50 Ananda Malai). The
  Kirththit Tiruvagaval is one long poem, so I cite by approximate line number from the site's inline counter.
- The Pandya in the Sambandar story is Koon (Ninra Cir) Pandyan; the straightening of his hunch is in PP Sambandar 847.
- Periya Puranam numbers are within-puranam; some editions may number the whole poem continuously (not checked). Do not mix.

## Not reached or not checked

- shaivam.org (HTTP 403 for scripts), sacred-texts.com (blocked).
- Perumparrap Puliyur Nambi's Tiruvalayudaiyar Tiruvilaiyadal: no online text found.
- Chokkar (Sundareswarar) stories and the Sangam board chapters (Tiruvilaiyadal padalams 49-51): only chapter titles seen.
- Tirukkovaiyar (Tirumurai 8, ids 8201+ on thevaaram.org): reachable but not read; no episode matched the map.
- Tamil Wikisource has no Periya Puranam text (search found nothing).
- Kachchiyappar (map song 1114) is the poet of Kanda Puranam, not a Periya Puranam saint; no biography source found.
- Nakkeerar's Tirumurugatruppadai (Tirumurai 11) and Mahabharata Shalya 44.6-13: named only, not opened.
- Shiva Purana Rudra Samhita Kumara Khanda: not opened.
- Tevaram history notes (pathiga varalaru) are the site's editorial summaries, not original texts.
- The scratch scripts and cache are in the scratchpad folder (not in the repo).
