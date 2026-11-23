# Tamil translation notes for the owner's review

## Volume IV: done except two held stories (2026-11-23)

38 more stories translated: Sambandar 11 of 12, saints 10 of 10, Devi 11 of 12, Ganesha 3 of 3, Tamil lore 5 of 5
(with `sam-milk` and `t-patrons` from the pilot). 54 Tamil stories in all; every one has the English paragraphs and
exactly its numbers, and uses only glossary forms (or a form the glossary notes as permitted there).

**Held back** until the owner decides (HANDOFF section 0): `sam-jains` (keep or soften the impalement paragraph) and
`d-idumbai` (the Hidimba paragraph). Translating them now would mean translating twice.

Quoted in the original Tamil (from the app's song text, or the opening words of well-known hymns):
- song 94 "காளவிட மூணி மாதங்கி" (`d-matangi`), song 540 "அறம்வளர் சுந்தரி" (`d-kamakshi-32`), song 745
  "பாடல வளநகர்" (`d-pathiri`), all checked against the app's lyrics.
- hymn openings: "செய்யனே திருஆலவாய்", "பையவே", "மந்திரமாவது நீறு", "மானினேர்விழி" (`sam-fever`); "வாழ்க அந்தணர்"
  (`sam-ordeals`); "மட்டிட்ட புன்னை" (`sam-poompavai`); "துஞ்ச வருவாரும்" (`sam-thiruvalangadu`); "மாதர் மடப்பிடி"
  (`sam-yazhpanar`); "பித்தா பிறைசூடி" (`n-sundarar-wedding`); "நமச்சிவாய வாழ்க" (`n-manikkavasagar`); and the
  Lord's "நில்லு கண்ணப்ப" (`n-kannappar`). These are well known but were not checked against the cached texts on
  this machine: confirm when the caches are at hand.

To check:
- **The disguised Lord.** `m-valli-disguise` gives the disguised Murugan respectful forms throughout; `n-vandi-pittu`
  gives the labourer (the Lord in disguise) plain forms until he is revealed, as most Tamil tellings do. One rule
  should apply to both; say which.
- `sam-fever` keeps the English's "Many songs, such as 527, 789 and 962 (Madurai)": in the app only 962 is a
  Madurai song (527 is திருவேங்கடம், 789 is பாகை). The English should probably move "(Madurai)" or drop it.
- `d-angayarkanni`: Kulasekhara here is the Pandya king (குலசேகரன்), not the Alvar; the glossary row now says so.
- `t-spider-elephant`: the queen's words are rendered "என் செங்கண்ணன்", from the English; the Periya Puranam's own
  wording was not at hand.
- `n-sundarar-paddy`: "dwarf attendants" → குள்ளப் பூதகணங்கள்.


## Volume III, Murugan: done (2026-11-23)

All 12 Murugan stories are in `pdf/narratives-ta/` (`m-valli-disguise` from the pilot, 11 more), with the pilot's
choices below. The checker now also compares each Tamil story with its English: same paragraphs and exactly the
same numbers (0 differences over all 16 files).

Verified from the Project Madurai Kanda Puranam pages the research used (2026-11-23) and written in the original:
- padalam titles: சயந்தன் புலம்புறு படலம், சயந்தன் கனவுகாண் படலம், வீரவாகு சயந்தனை தேற்று படலம் (Mahendra 9-11,
  `m-jayanta`); தெய்வயானையம்மை திருமணப் படலம் (Deva 2, `m-deivayanai`); கிரவுஞ்சப் படலம் (Asura 24, `m-krouncha`).
- two quoted lines: "மருப்பிரண் டுடையதோர் வார ணத்துடன்" (Deva 46, `m-airavata`) and "சுமக்குதி எம்மை"
  (Yuddha 2896, `m-peacock-cock`), each glossed in modern Tamil.

To check:
- `m-tarakasura`: the English names the padalam "Tarakan Varaip Padalam"; the Utpatti Kandam page was not
  available, so the Tamil says only "the padalam named for him". Fill in the Tamil title when the text is at hand
  ("Varaip" may be a misreading of வதைப்).
- `m-brahma-prison`: "the Skanda mountain" is rendered கந்தகிரி (*check* in the glossary).
- The speeches in `m-brahma-prison` (1229, 1245), `m-deivayanai` (51-53) and Agastya's curse in `m-krouncha`
  (1218-1221) are modern Tamil from the English, not the verses; the verse openings are known (Deva 51-53,
  Asura 1218-1221) if the owner prefers a quoted line.
- `m-jayanta` and `m-tarakasura` drop the English's "whom Sanskrit calls Jayanta / Taraka": in Tamil the two
  spellings do not differ the same way. `m-jayanta` says instead that the Kanda Puranam calls him சயந்தன்.
- `m-agastya` keeps the English's first person (நான் படித்த அளவில்).

# Pilot (2026-11-23)

Five stories translated from the settled English into simple modern Tamil, in `pdf/narratives-ta/`:

| Story | Volume | Why chosen |
|---|---|---|
| `m-valli-disguise` | III Murugan | the best-known Murugan story; a padalam title and verse runs |
| `avatar-gajendra` | I Vishnu | a Sanskrit source (Bhagavata) plus the Alvars; an animal hero |
| `sam-milk` | IV | Periya Puranam; a child saint; a quoted Tamil cry and a hymn opening |
| `t-patrons` | IV | Sangam poems; song places; a quoted speech of the patron's flatterer |
| `deeds-kama` | II Shiva | many Sanskrit section names; Tevaram and Tirumandiram references |

`scripts/glossary_check.py` now also reads the Tamil texts: it reports any form the glossary did not choose
(0 for the pilot, after six permitted uses were written into the glossary notes).

## Choices applied in the pilot (please confirm or change)

1. **Respect forms.** Gods, saints, sages and Arunagiri take the respectful plural (முருகன் வந்தார், சேக்கிழார்
   விவரிக்கிறார்); human characters inside a story (Nambi, Indradyumna, Pekan), villains and Kama take the plain form
   (நம்பி சென்றான், மன்மதன் சாம்பலானான்); animals take the neuter (முதலை கவ்விக்கொண்டது), except Gajendra, who is
   the hero and takes the plain masculine (கஜேந்திரன் போராடினான்).
2. **Valli as a girl** takes the plain feminine (வள்ளி காவல் காத்து வந்தாள்), as in most Tamil tellings. The other
   choice is the respectful form throughout (வள்ளி காத்து வந்தார்).
3. **Child Sambandar** takes the neuter while he is "the child" (குழந்தை அழுதது) and the respectful form once he is
   named (திருஞானசம்பந்தர் ஆனார்). This follows ordinary Tamil; the Periya Puranam itself honours him even as a baby.
4. **Shiva** is சிவபெருமான் throughout; **Krishna** is கண்ணன் (`deeds-kama`: கண்ணனின் மகனான பிரத்யும்னன்).
5. **Verse references** follow the English: the first one spelled out (பாடல் 1851, பாடல்கள் 56–57), later ones bare
   numbers. Sanskrit section names are transliterated (ருத்ர சம்ஹிதை, பார்வதி கண்டம், அத்தியாயம் 19).
6. **Song places** are the app's: "song 436, sung at Thiruvannamalai" became திருவருணையில் பாடிய பாடல் 436, and
   song 242 is (திருத்தணிகை). Where the English gives no place, none was added.
7. **Quoted Tamil** is the original: வள்ளியம்மை திருமணப் படலம், "அம்மே! அப்பா!", "தோடுடைய செவியன்", "மூலமே!"
   (as in songs 484 and 704), காமாரி. No Sangam or Tevaram line is quoted that the English only paraphrases;
   the cached source texts are not on this machine, so nothing was quoted from memory.

## Found while translating

- **Purananuru 151 for Kumanan is probably wrong in the English and in the research** (`t-patrons`; also
  `tamil-lore/stories/t-patrons.md`). Tamil Wikisource's page titled "poems 151-160" actually prints poems 161-170,
  and poem 161 is addressed to Kumanan (by Perunchithiranar); 164 and 165 are too (by Perunthalai Sathanar). The
  research build most likely read 161 as 151. **Not changed** in either language: confirm against a printed
  Purananuru, then fix the research (`build_new_sets.py` / briefs), the English narrative and the Tamil together.
  The other Purananuru numbers in this story come from pages whose numbering was not checked the same way.
- `deeds-kama` English says Shiva's "titles" include Kamari; the Tamil keeps that (not "Murugan's father's", which a
  first draft wrongly said and was corrected).

## Not yet done

- No Tamil story **titles** yet: the book takes titles from the story data, so the Tamil edition needs a title per
  story (to be added with the book's language switch).
- A **native Tamil reader** has not read these. That review is the point of the pilot.
- The book build is unchanged; the Tamil texts are not in any PDF yet.
