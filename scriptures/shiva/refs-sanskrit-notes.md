# Sanskrit/Puranic references for Shiva stories: notes

Companion to `refs-sanskrit.json`. Confirmed means the page was opened and the passage matches the story. Only numbers and own gists are stored.

## Checked and opened
- Valmiki Ramayana (valmikiramayan.net, Sanskrit+word-for-word pages via `find_valmiki.py`): Bala 23, 36, 37, 43, 45, 66, 75.
- Bhagavata (vedabase.io via `fetch_krishna.py sb`): 3.12, 4.2-4.7, 4.24, 5.17, 6.17, 7.10, 8.7, 8.12, 9.9, 10.55, 10.62-63, 12.10.
- Mahabharata CE (GRETIL via `mbh_lines`): parvas 1, 3, 5, 7, 8, 9, 12, 13 keyword-scanned; chapters 3,108; 7,173; 8,24; 9,43; 12,274; 12,328-330; 13,14; 13,17; 13,84-86 read at line level.
- Linga, Shiva, Skanda Puranas on wisdomlib.org (English translations; chapters opened and keyword-scanned; Linga ch.1-108, Shiva Purana about 480 chapters, Skanda Purana Kedara, Kaumarika, Arunacala and Kashi khandas).
- Ramayana Uttara kanda 16 on wisdomlib (Hari Prasad Shastri / Dutt translation).

## Could not reach or not found
- valmikiramayan.net has no Uttara kanda pages (404); Ravana and Kailasa taken from wisdomlib instead.
- Kurma, Matsya, Vamana, Brahmanda, Vayu Puranas: no chapter-level source found on wisdomlib; not checked elsewhere (sacred-texts is blocked, no archive.org text tried).
- Sauptika (parva 10): GRETIL file has a different line format; `mbh_lines(10)` returns nothing. Not needed for the slugs here.
- No source found for: Markandeya kicked by Yama as such (Shiva kicking Yama), Dakshinamurti teaching story, Bhikshatana in the Daruka forest, Muyalakan, Murugan teaching Shiva the Pranava (Skanda Purana Sankara-samhita / Kanda Puranam), Brahma imprisoned by Murugan. These are Tamil/Skanda-Purana-Shankara-samhita themes; try Kanda Puranam (Tamil) instead.
- Mahabharata CE Adi 1,15-17 (churning) has no Shiva poison-drinking line by keyword search.

## Numbering caveats
- Valmiki: sarga.shloka as on valmikiramayan.net (critical-style vulgate numbering). Uttara 16 follows the Shastri/Dutt translation chapter number.
- Bhagavata: vedabase canto.chapter.verse; ranges like 4.2.14-15 are combined verses.
- Mahabharata: Critical Edition (parva,adhyaya.shloka); Vulgate/Ganguli numbers differ. Lines with an asterisk (starred lines) were ignored.
- Wisdomlib labels: its Linga Purana "Section 1 - Uttarabhaga" holds chapters 1-108, which is the traditional Purvabhaga (Part 1); chapter numbers 1-108 are the same as in Shastri's translation. Shiva Purana citations use wisdomlib section names (Vidyesvara, Rudra with khandas, Satarudra, Koti-rudra, Uma, Kailasa, Vayaviya); chapters inside the Rudra-samhita restart at 1 in each khanda. Skanda Purana follows wisdomlib's Maheshvara-khanda (Kedara, Kaumarika, Arunacala) and Kashi-khanda numbering; Venkateshvara-press numbering differs.
- Wisdomlib chapters are cited at chapter level only (opened, title and content match); no verse numbers claimed there. Verse numbers inside Linga and Shiva Purana chapters were not recorded.
- Page URLs of wisdomlib are doc ids; some refs list several chapters but give the URL of the first/main one.
