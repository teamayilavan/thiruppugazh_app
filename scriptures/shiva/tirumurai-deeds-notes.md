# Tirumurai verses for the Shiva deed stories: notes

Companion to `tirumurai-deeds.json` (the Shiva counterpart of the Divya Prabandham files).

## Method

- Single source: **thevaaram.org** (Tamil site, "Panniru Thirumurai Paattum Porulum"). Page pattern
  `https://www.thevaaram.org/thirumurai_1/onepage.php?thiru=<T>&Song_idField=<id>` returns a whole pathigam
  (all verses, Tamil text, meaning and notes). Ids: Tirumurai 1-7 = `T*1000 + pathigam number`
  (e.g. 5.4 is 5004); Tiruvasagam (8) = `8100 + section number` (1 = Sivapuranam ... 51 = Achchopathigam);
  Tirumandiram (10) = ids such as 10202 (tantra 2, section 2).
- I downloaded every pathigam of Tirumurai 1-7 (800 pages), the 51 Tiruvasagam sections and every
  Tirumandiram section into a local scratch cache, then searched the Tamil text by story keywords and
  **read each verse listed** before writing a gist. So `confirmed: true` means the page was fetched and the
  verse text read and found to narrate or clearly allude to the story. The `url` is the pathigam page.
- Nothing was marked `confirmed: false`; I did not list anything from memory. (Famous pathigams I know by
  reputation but did not read, such as the Kurukkai Kamadahana temple verses of Sambandar, are simply absent.)
- Gists are my own wording; `first_words_ta` is the first three words as printed on the site.

## Numbering caveats

- Tevaram refs are `pathigam T.P, verse n`: T = Tirumurai (1-3 Sambandar, 4-6 Appar, 7 Sundarar), P = pathigam
  number counted in the Tirumurai in the traditional Tirumurai order, n = verse within the pathigam. This
  matches the usual citation (e.g. Appar 4.81.4 is the "kunittha purvamum" Tillai verse). Some other
  editions (for instance tamilvu / shaivam.org) order Tirumurai 4-6 the same way but may count a few
  pathigams of different length (the site lists 11th "phalasruti" verses where present, which a few
  editions fold into 10). Check the verse against a second edition before quoting.
- Tiruvasagam: `section` is the position of the poem in the thevaaram.org list (5 Tiruchchatakam, 6 Neettal
  Vinnappam, 7 Tiruvempavai, 8 Tiruvammanai, 9 Tiruporchunnam, 12 Tiruchchazhal, 13 Tiruppoovalli,
  14 Tiruvundiyar, 15 Thonokkam, 29 Arutpattu, 43 Tiruvarttai); verse numbers are within the poem.
  Tirukkovaiyar (also Tirumurai 8) was **not** searched for stories; it is an akam love poem.
- Tirumandiram: thevaaram.org splits it by tantra and section (id 10202 = tantra 2, section 2
  "Pathivaliyil Veerattam Ettu", eight verses, one per Veerattam deed). The absolute verse number of
  Tirumular (1-3047) is **not** shown on the pages I read, so refs give the section and the verse within it.
- Tirumurai 9 (Thiruvisaippa), 11 and 12 (Periya Puranam) were not searched. Tirumurai 11 is mostly
  later works; nothing in the deed list requires it.

## Per-story observations

- **Tripura**: richest set. Whole pathigams: Appar 5.4 (Annamalai, refrain recalls the burning in nearly
  every verse). Best narrative detail (gods as chariot, Meru bow, Vasuki string, Vishnu arrow): Sambandar 1.131.4,
  Appar 6.19.1, 6.66.4, Sundarar 7.99.8. Tiruvasagam 8.14 verses 1-3 (Tiruvundiyar) include the **broken axle**,
  which echoes the Thiruppugazh motif (song 1: Ganesha shatters the axle).
- **Kama**: no pathigam is devoted to the story; many one-verse allusions (burned by the eye). Fullest
  verses: Sambandar 2.31.6, Appar 4.14.9.
- **Poison**: the full churning is told in Sambandar 2.91.7, 2.95.6, Appar 4.65.2, 4.70.7, 6.83.8, Sundarar 7.55.5.
- **Daksha**: Tirumandiram tantra 2 section 4 is entirely about Daksha's sacrifice. Tevaram has many
  one-line mentions; Tiruvundiyar 8.14 (8, 16) and Tiruvammanai 8.8.15 give the punishments.
- **Yama (Markandeya)**: Appar's Kadavur Virattam pathigam 4.107 (verses 1, 2) and 4.31.9 are the best; note
  4.107 and 4.31 are both filed under Tirukkadavur Virattam on the site.
- **Brahma's head**: allusions in many pathigams, no narrative one. Tiruvundiyar 8.14.18 and Tirumandiram 2.2
  verse 2 are explicit that the head was cut.
- **Bhikshatana**: verses give the begging with a skull and the women's bangles slipping (3.104 is a whole
  pathigam on this theme) but **not the Daruka forest sages' wives episode by name**. Treat as the
  closest Tamil devotional parallel, not a full telling.
- **Annamalai (Lingodbhava)**: no Tevaram pathigam narrates the boar and swan in detail; many verses
  say Vishnu and Brahma failed to find his feet and crown (listed). Tirumandiram tantra 2 section 8
  "Adimudi thedal" is the only extended one. The Annamalai pathigams themselves (Appar 4.63, 5.4, 5.5,
  Sambandar 1.10) are not about the flame story in the verses I read (5.4 is a Tripura refrain).
- **Ganga**: Sambandar 3.122.3 names Bhagiratha and the gentle descent. Other verses say only that Ganga was
  hidden in his hair.
- **Ravana (Kailasa)**: very many verses, usually the 8th-10th of a pathigam; the ones listed narrate the
  lifting, the toe, the song with the nerve (Sama), and grace.
- **Sarabha**: **none found.** I searched Tirumurai 1-8 and 10 for sarabha / narasimha / lion-man forms.
  The only hits were the nayanar Narasimha Munaiyaraiyar (not related) and Sundarar 7.99.6 where a lion
  emerges from the sages' sacrificial fire (Daruka forest), not the Sarabha story. The Sarabha story is
  Puranic (Linga, Shiva, Sharabha Upanishad, Kanda Purana) and appears in Tamil sources outside the
  Tirumurai canon, so this gap is expected.
- **Dakshinamurti**: banyan-tree teaching of the four sages is attested in many Appar verses; listed.
- **Ardhanari**: only form-descriptions (half woman); no narrative. 1.107 (Tiruchengodu / Kodimadachengunrur,
  the Ardhanari temple) was read: the verses name the Lady at his side but add little; not listed.
- **Nataraja / Muyalakan**: Appar 4.81 and 4.22 (Tillai) and several Muyalakan verses; the Muyalakan verses
  are one-liners.

## Unreachable / not done

- shaivam.org returned 403 to scripted access; tamilvu and Tamil Wikisource were reachable but not used
  because thevaaram.org already had full text with pathigam numbers. No English translations were taken.
- No verse text was copied beyond the first three words; no translation was copied.
- Search was keyword-based on Tamil text with spaces removed (the site spaces words by metre). Verses using
  unusual spellings or synonyms could be missed, so the lists are good samples, not exhaustive.
