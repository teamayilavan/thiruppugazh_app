# Shiva shortlist rule

Songs are found by `python -I scriptures/scripts/shortlist.py --deity shiva` (reads the DB read-only; generated files:
`shortlist.json`, `shortlist.md`, `excluded.md`).

A song is in the shortlist when any of these hits, matched line by line with spaces removed (sandhi text):

- **name**: an epithet of Shiva (சிவன், அரன், ஈசன், சங்கரன், சம்பு, பரமன், சடையன், நீலகண்டன், முக்கண்ணன், கயிலை, நடராஜன், ...).
- **deed**: a Shiva story (Tripura, Kama, poison, Daksha, Yama/Markandeya, Andhaka, Ravana under Kailasa, Kirata/Pashupata,
  Bhikshatana, Dakshinamurti, Brahma's fifth head, Annamalai, Ganga in the hair, the dance, Tiruvilaiyadal, the Tevaram saints,
  Murugan teaching Shiva the Pranava, Murugan born of Shiva's eye).

Not Shiva (rejected): சங்கரி (Devi), சங்கரித்து (destroy), சிவகாமி (Devi), சம்பு inside another word, அரண் (fort).

## First result (2026-10-26)

379 of 1340 songs (49 name and deed, 190 name only, 140 deed only). The largest families: Tripura (74), Kailasa (32),
matted hair (29), சிவன் (27), சங்கரன் (25), Nataraja (24), Tiruvilaiyadal (23).

## Known noise

- A two-line window can join a word split across lines (song 11: `உந்திரி` + `புரம்` reads as Tripura). Reading each song settles these.
- Name hits only say Shiva is mentioned (often as the father of Murugan). They do not mean a story; the hand-reading step separates the two.
- Songs that tell a Shiva story without any word in the lists are not found.
