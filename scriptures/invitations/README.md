# Arunagiri invites Murugan: how this collection was made

**Result:** [`INVITATIONS.md`](INVITATIONS.md) (read it), [`invitations.json`](invitations.json) (use it). Built by [`../scripts/build_invitations.py`](../scripts/build_invitations.py).

89 invitations, one per song, in 89 of the 1,340 songs: lines where Arunagiri asks Murugan to *come*. Each entry gives the Tamil lines, the Roman transliteration, an English gloss, and (for 61 of them) the clause of the song's own published English meaning that says "come". Murugan calling the devotee "Come!" is kept in a separate section (5 lines in 4 songs), and two songs that call someone else (Rama, Krishna) are listed apart and not counted.

## How it was done

1. **Scan.** All 1,340 songs were searched for every "come" form: *வரவேணும்* (you must come), *வருவாயே* (will you come), *வாராய் / வாவா* (come!), *வந்தருள்* (come and bless), *வருக*, and quickness and speed words. That gave about 240 candidate lines.
2. **Read.** Every candidate was read in its verse. Most are not invitations (*வருக* inside other words, *வாரா* meaning "does not come", the poet's epithets such as *வந்தருள் பெருமாளே* "the Lord who came and graced this place"). Only real requests to come were kept.
3. **Text from the app, not retyped.** The script pulls the Tamil and the Roman transliteration from `assets/thiruppugazh.db` by song and line number, so there are no typing errors.
4. **English.** The app has no line-by-line English: the song's English meaning is prose. So each entry has (a) a short literal **gloss** written for this collection from the Tamil, and (b) where there is one, the **commentary clause** from the published English meaning that says "come". The commentary is shown as published, untouched. Glosses were checked against it where it exists; where it does not (28 songs, mostly short ones or those whose meaning words it differently) the gloss rests on the Tamil alone.

## What the 89 say (by how he is asked to come)

| How | Songs |
|---|---|
| **On the peacock** (his vahana) | 30 songs, plus 5 where the peacock **dances or bounds**; the peacock is named in 39 of the 89 entries |
| **With the cock** (his banner) | 585 |
| **With his consorts** | **Valli** alone: 1204, 971; **Valli and Deivayanai together**: 1325 (the "forest-maiden" and the elephant-reared). 1189 asks him to come on the feet "that went after Valli" |
| **Quickly, at once** | 648, 1114 (flying at great speed), 8, 198, 726 ("in an instant"), 1244 (hurrying) |
| **Running** | 1307 ("come running before me") |
| **Flying** | 1114, 1311 (the peacock "that flies about the grove") |
| **At the hour of death** | 68, 63 (to tell Yama "he is my devotee"), 777, 1074, 1325, 945 |
| **Today / now** | 180, 294, 974, 937 |
| **To embrace** (the soul as the devoted bride) | 430, 645, 647, 693, 743, 706, 1189 |
| **To bless, rule, answer** (the rest) | 32 |

**What is *not* there.** A literal **"walk to me"** never appears as an invitation; the nearest are "strolling" (205) and the processions of the epithets (110, 198, 958). "Come **running**" appears once, "come **flying**" only through the peacock. The strongest, most repeated mode is the **peacock**, then **quickness**, then the **hour of death**. If a different shape of invitation was in mind, give the song numbers or a line and it will be added.

## What was left out on purpose

- **Epithets with "வந்தருள்"** (about a dozen lines, e.g. 11 line 20, 14 line 20, 65, 612, 1139): "the Lord who came and graced (this hill)": a description of him, not a request.
- **"வருவோனே"** (31 lines in 31 songs): "O one who comes on the peacock": an epithet.
- **Song 68** has *வருக வருக* seven times, but they are Kausalya calling the child Rama (Vishnu); kept apart. Same for song 626 (the gopis calling Krishna).
- **Doubtful readings:** songs 869, 664, 1042 and 446 (not clearly addressed to Murugan).

## Limits, plainly

- **Curated by hand from a text search**, so an invitation that uses none of the searched forms (a rare verb, or one split oddly) can be missing. The search forms are listed above; the candidates file is not kept.
- **The glosses are my literal renderings**, not a published translation. For publication they should be reviewed by a Tamil scholar; the Tamil, transliteration and commentary clauses are exact copies from the app.
- **The commentary clause is auto-picked**, so in a few entries it is a neighbouring clause of the same sentence (see 1053, left blank on purpose).
- The "English" lyrics field of the app is the **Roman transliteration**, not a translation; 13 songs have none (none of those are in this collection).
