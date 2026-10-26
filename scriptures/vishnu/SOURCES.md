# Sources used and what each confirmed (session 1, 2026-10-26)

| Source | URL | Used for |
|---|---|---|
| Valmiki Ramayana contents pages (Bala, Ayodhya, Aranya, Kishkindha, Sundara, Yuddha) | valmikiramayan.net/utf8/<kanda>/<kanda>_contents.htm | sarga numbers for every ✔ Valmiki reference |
| Kamba Ramayanam on Tamil Wikisource | ta.wikisource.org/wiki/கம்பராமாயணம் | padalam names per kandam (Yuddha has 42 padalams); verses are numbered per padalam (e.g. சேது பந்தனப் படலம் has 71) |
| Bhagavata Purana Cantos 8 and 10 | vedabase.io/en/library/sb/8/ and /10/ | chapter numbers for Gajendra, churning, Vamana, Putana, Yamalarjuna, Kaliya, Govardhana, Kuvalayapida, Kamsa, Naraka, Banasura, Sudama |
| Vishnu Purana (Wilson) contents | wisdomlib.org/hinduism/book/vishnu-purana-wilson | book.chapter for Varaha, Prahlada, Putana, wagon, Kaliya, Govardhana, Naraka, Parijata, Bana |
| Mahabharata sub-parvas | en.wikipedia.org/wiki/Udyoga_Parva, Drona_Parva, Vana_Parva, Bhishma_Parva | chapter ranges (traditional numbering, not the Critical Edition) for Bhagavat-yana, Jayadratha-vadha, Kairata, Gita |
| Divya Prabandham commentary site | divyaprabandham.koyil.org | Thiruvaimozhi 3.5.1 (earlier written wrongly as Periya Tirumozhi); Periyazhwar Thirumozhi 2.1.9 and 2.10.8 (Gajendra); Tiruppavai 6, 12, 13, 24 content |

## Not yet checked (marked `?` in the story files)

- Many Divya Prabandham pointers (Periyazhwar, Kulasekhara, Tirumangai, Tiruvaimozhi); only Gajendra and four
  Tiruppavai verses are confirmed.
- Bhagavata chapter numbers marked `?` (Narasimha 7.8, Varaha 3.13, Kurma 8.7, Vatsasura 10.11, gopi clothes 10.22,
  Rama 9.10-11, Mausala 11.30, Parijata, Banasura 10.62).
- The Kakasura episode's exact Kamba/Valmiki location; the seven trees sarga.
- Vishnu Purana for Vamana, Rama, Yamalarjuna.
- Kamba verse numbers (need an edition decided; Wikisource numbers per padalam, Kamban Kazhagam usually numbers per kandam).
- Mahabharata Critical Edition numbers (current numbers follow the Vulgate/Ganguli sub-parvas).
- The Wikisource and vedabase pages were read through a summarising fetch tool, not line by line.

## Added in the verse-level pass (2026-10-26)

- Valmiki shloka numbers come from the per-sarga pages `valmikiramayan.net/utf8/<kanda>/sarga<N>/<kanda>sans<N>.htm`
  (Sanskrit with the verse number, word-for-word and prose). Bala and Kishkindha use a different translator's
  page layout; their shloka numbers follow the bracketed tags on the page.
- Kamba verse numbers come from the raw wikitext of `ta.wikisource.org/wiki/கம்பராமாயணம்/<kandam>/<padalam>`,
  parsed by `scripts/find_kamba.py`. Numbers restart in every padalam.
- Not pinned yet: Kamba verses for Khara's fall, Maricha's cry, Vali's death and the garland, Atikaya, Vibhishana's refuge
  and Rama shattering Ravana's crown; Kishkindha/Sundara Valmiki shloka detail beyond what is listed.

## Added in the Krishna / Mahabharata pass (2026-10-26)

- Bhagavata: vedabase.io chapter pages (`/en/library/sb/<canto>/<chapter>/`), parsed by `scripts/fetch_krishna.py` into
  'Text N' blocks; the build fails if a cited verse number is not on the page. The translation is copyrighted, so only
  verse numbers and my own gists are stored.
- Mahabharata: Critical Edition (BORI) Sanskrit from GRETIL (`gretil.sub.uni-goettingen.de/.../mbh/mbh_NN_u.htm`),
  numbers like `6,023.021c`. These are not the Vulgate/Ganguli section numbers used by Wikipedia or older translations
  (for example Jayadratha's death is 7,121 in the CE and section 146 in Ganguli). sacred-texts.com blocks automated
  access, so Ganguli's section numbers were not looked up directly.
- Notable finding: the Sudarshana discus hiding the sun appears only in star passages of the CE (7,121.014d*1010 and
  7,121.041b*1025); the constituted text has Krishna urging Arjuna before sunset, with no sun-hiding.
- Not pinned: Harivamsa (Narakasura, Parijata, Banasura detail), Bhagavata verses for Trinavarta, the poets' episode in
  song 1170, Vidura's hospitality (only that Krishna stayed at Vidura's: 5,089.034-035), the exact CE line for Krishna
  placing the pestle powder in the sea, and Divya Prabandham verses for any Krishna story.

## Divya Prabandham and the avatar pass (2026-10-26, parallel research)

- Divya Prabandham references come from divyaprabandham.koyil.org (per-pasuram pages and its wp-json search). Each
  confirmed entry in `vishnu/dp/*.json` carries the URL that was opened and a `confirmed` flag; a few rest on commentary
  mentions or search snippets and say so. The site is incomplete for some decads and gives no 1-4000 running numbers, so
  references are prabandham + decad.pasuram. Tamil first-words are transliteration-based and need a printed-edition check.
- Ramayana DP: 23 of 33 episodes confirmed (best source: Perumal Thirumozhi decad 10, Periyazhwar Thirumozhi 3.10, 4.9.1).
  Krishna DP: 19 episodes confirmed, 74 entries; Periyazhwar Thirumozhi 4.1.8 states the sun hidden by the discus
  (the Tamil tradition, unlike the Critical Edition). Avatar DP: 16 stories, 46 entries.
- Kamba: Khara, Maricha, seven trees, garland, Vali, Sugriva's crown, Atikaya, Vibhishana, crown shattering and exile are
  now pinned. Still unpinned: Rama's birth, army march, army destroyed, the Surpanakha/Ravana-ploy padalams.
- Bhagavata for avatars: Gajendra 8.2-4 (the crocodile is the cursed gandharva Huhu, 8.4.3-4); Narasimha in Kamba is told by
  Vibhishana in the Yuddha kandam (Hiranyan Vadhai padalam).
- Vishnu Purana: only chapter-level (1.4, 1.9, 1.20); Vamana not found.
- The general-songs review corrected songs 233 (Varaha), 272 (Ramayana: Surpanakha and Sita's abduction), 586, 902
  (Jayadratha) and 193, and moved 9, 95, 237, 1325 into the Ramayana.
