# Tamil pilot: notes for the owner's review (2026-11-23)

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
