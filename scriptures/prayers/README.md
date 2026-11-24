# அருணகிரிநாதரின் வேண்டுதல்கள் (Arunagirinathar's prayers)

The prayers Arunagirinathar makes to Lord Muruga in the Thiruppugazh, taken from the
app's bundled song database (`assets/thiruppugazh.db`). In most songs the first half ends
with a request: அருள்வாயே, தருவாயே, தாராய், வரவேணும், ஆள்வாய், …ஒருநாளே and similar.

Each prayer is the **complete sentence** that ends in the asking word, starting where
that sentence starts (sometimes mid-line), with its Tamil meaning. One prayer per page.

| File | What it is |
|---|---|
| `Arunagirinathar-Prayers-Tamil.pdf` | All 777 prayers from 765 songs |
| `Arunagirinathar-Prayers-Tamil-Filtered.pdf` | 431 prayers from 420 songs, without the courtesan/lust ones |
| `Arunagirinathar-Prayers-Tamil-Short.pdf` | 140 short prayers (fewer than 6 lines) from the filtered set, word-separated lyrics and meaning, plain text |
| `prayers-short.typ`, `prayers-ta-short.json` | Layout and data for the short PDF |
| `removed.txt` | The 346 prayers left out of the filtered copy (song, title, place, word) |
| `prayers.typ` | Typst layout for both PDFs |
| `prayers-ta.json`, `prayers-ta-filtered.json` | Data the PDFs are built from |
| `scripts/` | The extraction pipeline |

## How the prayers were found

1. `extract.py`: groups lyrics into verses with the same rule as `splitIntoVerses`
   (lines per verse = tune length) and keeps verses, other than the last, whose final word
   is a petition form.
2. `sentences.py`: aligns the stored word-by-word meanings to the lyric text and walks
   back to the previous full stop in the meaning, so the lyric runs from the start of the
   sentence to the asking word. It drops "-வாய்" endings that are vocatives ("O You who
   gave…"), not requests. Songs 1329, 1330, 1331 and 1338 have no stored meaning, so their
   sentence starts at the beginning of the song (1329: after the previous question).
3. `filter_women.py`: removes prayers about courtesans and women's beauty (Tamil and
   English keywords plus hand-checked overrides). Bridal-mysticism (நாயகி பாவம்) prayers,
   Valli and Devayanai, family and deathbed scenes, and one-word mentions in a list of
   attachments are kept.
4. `make_data.py`: writes the JSON files and `removed.txt`.
5. `make_short.py`: takes filtered prayers of fewer than 6 lines with a meaning, skips
   those starting mid-word, and uses the word-separated lines from
   `mayuragiri_lyrics_separated` (or the `words` chunks where that is missing or out of
   step). Where neither covers the whole line, the original lyric is kept with `......`
   removed (songs 3, 343, 681, 920, 1337). Letters restored for metre, like `(ம்)`, are kept.

## Rebuild

```sh
W=$(mktemp -d)
python3 scriptures/prayers/scripts/extract.py $W/prayers.json
python3 scriptures/prayers/scripts/sentences.py $W
python3 scriptures/prayers/scripts/make_data.py $W scriptures/prayers
cd scriptures/prayers
typst compile prayers.typ Arunagirinathar-Prayers-Tamil.pdf
typst compile --input data=prayers-ta-filtered.json prayers.typ Arunagirinathar-Prayers-Tamil-Filtered.pdf
cd ../.. && python3 scriptures/prayers/scripts/make_short.py scriptures/prayers && cd scriptures/prayers
typst compile prayers-short.typ Arunagirinathar-Prayers-Tamil-Short.pdf
```

Run the Python steps from the repo root. Typst needs the Lohit Tamil font.
