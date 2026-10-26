"""Shortlist Thiruppugazh songs that name Shiva or narrate a deed of Shiva.

Unlike the Vishnu run (one word, மருகன்), Shiva has no single keyword, so the rule is two families:
  name  an epithet of Shiva (சிவன், அரன், ஈசன், சங்கரன், சம்பு, கயிலை, ...)
  deed  a Shiva story (Tripura, Kama, poison, Daksha, Yama/Markandeya, Bhikshatana, Dakshinamurti,
        Brahma's fifth head, Annamalai, Tiruvilaiyadal, Tevaram saints, Murugan teaching Shiva, ...)
A song is in the shortlist when either family hits. Hits are keyword guesses; every song is read by hand later.

Reads the bundled DB read-only and writes, under scriptures/shiva/:
  shortlist.json   every hit with 3 lines of context before and 1 after
  shortlist.md     one row per song
  excluded.md      look-alike words rejected, with the reason (e.g. சங்கரி = Devi, சங்கரித்து = destroy)

Run from the repo root:  python -I scriptures/scripts/shortlist.py --deity shiva
Matching ignores spaces because the lyrics are in sandhi form and spacing is unreliable.
"""
import json
import re
import sqlite3
import sys
from collections import Counter
from pathlib import Path

sys.stdout.reconfigure(encoding="utf-8")

ROOT = Path(__file__).resolve().parents[2]
DB = ROOT / "assets" / "thiruppugazh.db"

# A letter just before the match that carries a pulli (்) means the match starts mid-word (தஞ்சம்புரி is not சம்பு).
NOT_MID = r"(?<!்)"

# (label, kind, pattern on space-stripped text). Order does not matter; every pattern is tried.
SHIVA = [
    # ---- epithets
    ("சிவன்", "name", r"சிவன்(?!மலை)|சிவனார்|சிவபிரான்|சிவபெருமான்|சிவனே|சிவனை|சிவனுக்"),
    ("அரன்/ஹரன்", "name", NOT_MID + r"[அஹ]ரன்|[அஹ]ரனார்|[அஹ]ரனும்|[அஹ]ரனே|[அஹ]ரர்"),
    ("ஈசன்", "name", r"ஈசன்|ஈசர்|ஈசுர(?!ி)|ஈசனார்|ஈசானன்|மகேசுர|மகேசன்|மாதேவ|மாதேவர்|மகாதேவ|தேவதேவ"),
    ("சங்கரன்", "name", NOT_MID + r"சங்கர(?![ிீ]|க்|ித்)(?!குமார)(?!தி)"),
    ("சம்பு", "name", NOT_MID + r"சம்பு(?!வ[ிீ]|ள்|க[ழள்]|ரி|ர்ந்|ரந்)|சம்புநாத|சம்புவே"),
    ("பரமன்", "name", r"பரமன்|பரமனே|பரமேசு|பரமேச்வர|பரமசிவ|பரம ?ேச"),
    ("சடையன்", "name", r"சடையன்|சடையினர்|சடையர்|சடைமுடி|சடாதர|சடையில்|சடைமேல்|சடைக்"),
    ("பிறை/மதி சூடி", "name", r"பிறைசூடி|பிறையணி|மதிசூடி|மதிநதி|மதிதரு|மதியறுகு|பிறைமுடி|பிறைதவழ|சசிதர|சந்திரசேகர|சசிசேகர"),
    ("நீலகண்டன்", "name", r"நீலகண்ட|கறைமிடற்|கறைக்கண்ட|நஞ்சணி"),
    ("முக்கண்ணன்", "name", r"முக்கண்|மூன்றுகண்|முக்கட்|நெற்றிக்கண்|நுதற்கண்|நெற்றிவிழி|நுதல்விழி|மூவிழி"),
    ("ஆயுதம்/வடிவம்", "name", r"மழுவேந்த|மழுக்கை|மழுவாள்|மானேந்த|மான்மழு|சூலபாணி|சூலபாணி|சூலதர|சூலமழு|சூலமேந்த|பினாகி|பினாக|விடையேறி|விடையூர்|ரிஷபவாகன|இடபவாகன|இடபமேறு|தோலுடுத்த|புலித்தோல|கரியுரி|ஆனைத்தோல்"),
    ("உமை பாகன்", "name", r"உமைபாக|உமாபதி|உமாமகேசு|உமைமணாளன்|உமைநாயகன்|அம்மையப்பர்|மங்கைபாகன்|மாதிருக்கும்|பாகத்துமை|பாகமாதுமை|வாமத்தி|அர்த்தநாரி|ஆதிசங்கர|உமையொருபாகன்|உமைபங்கன்|பங்கிற்"),
    ("கயிலை", "name", r"கயிலை|கைலை|கயிலாய|கைலாச|கயிலாச|வெள்ளிமலை|வெள்ளியங்கிரி"),
    ("நடராஜன்", "name", r"நடராஜ|நடராச|நடேச|கூத்தன்|ஆடலரசு|அம்பலவாண|அம்பலத்தாடு|அம்பலத்தில்|தில்லை|பொன்னம்பல|சிற்றம்பல|முயலக"),
    ("பரமேட்டி/மற்றவை", "name", r"பசுபதி|சதாசிவ|சோமசுந்தர|சொக்கநாத|சொக்கேச|அண்ணாமலையார்|அருணாசல|வடுகநாத|பைரவ|காலபைரவ|வீரபத்ர"),
    ("திருநீறு", "name", r"திருநீற|வெண்ணீற|நீறணி|பூதிபூசி|சாம்பல்பூசி|சுடலைப்பொடி|சுடலைநீறு|பொடிபூசி"),
    # ---- deeds
    ("திரிபுரம்", "deed", r"திரிபுர|முப்புர(?!ி)|புரமூன்று|புரம்மூன்று|புரமெரி|புரம்எரி|புரம்பொடி|புரமூவ|மூவர்புர|முப்புரம|புராரி|புரத்தை(?:ச்)?(?:சுட|எரி|அழி)|மூன்றுபுர"),
    ("காமனை எரித்தல்", "deed", r"காமனை(?!க்கூ)|மன்மதனை|மதனனை|காமவேள்|மதனைய(?:ெ|ே)ரி|காமன்உடல|காமன்வெந்|மதனன்வெந்|காமனுடல"),
    ("ஆலகால நஞ்சு", "deed", r"ஆலகால|நஞ்சுண்|நஞ்சையுண்|விடமுண்|விடமுண்ட|நஞ்சமுண்|நஞ்சைஉண்|அருந்திநஞ்ச|கறைமிடற"),
    ("தக்கன் வேள்வி", "deed", r"தக்கன்|தக்கனார்|தக்கன(?:து|ை)|தட்ச|தக்ஷன்|தக்கயாக|தக்கன்வேள்வி|வீரபத்திர"),
    ("மார்க்கண்டேயர்/காலன்", "deed", r"மார்க்கண்ட|காலனை|காலனுயிர|காலன்உயிர|மறலியை|கூற்றுவனை|கூற்றை(?:ய)?உதை|காலைத்தூக்கி|எமனை|யமனை|காலகாலன்|காலாந்தக"),
    ("அந்தகாசுரன்", "deed", r"அந்தகாசுர|அந்தகனை|அந்தகன்றனை"),
    ("இராவணன் கயிலை", "deed", r"(?:இராவண|ராவண).{0,30}(?:கயிலை|கைலை|விரல்|அடர்)|(?:கயிலை|கைலை).{0,30}(?:இராவண|ராவண|தசமுகன்|பத்துத்தலை)|விரலாலடர்|கால்விரலூன்"),
    ("கிராதன் / பாசுபதம்", "deed", r"கிராத|பாசுபத|வேடுவனாய்|வேடனாய்|வேடுவவடிவ|பார்த்தனுக்.{0,12}(?:அம்பு|அருள்|பாசுபத)|அருச்சுனனுக்கு.{0,20}(?:அம்பு|பாசுபத|அருள்)|அருச்சுனன்தவ"),
    ("பிட்சாடனர்", "deed", r"பிச்சை(?:க்கு|யெடு|ஏற்|யேற்|கொள்)|பிட்சாடன|பிச்சாடன|பலிதேர|பலிக்குழல|பலிகொள|ஐயமேற்|பிச்சாண்டி|பிக்ஷாடன|தாருகாவன|தாருகவன|பிச்சைகொள்"),
    ("தட்சிணாமூர்த்தி", "deed", r"தட்சிணாமூர்த்தி|தக்ஷிணாமூர்த்தி|கல்லாலடி|ஆலின்கீழ்|ஆலமர்ச|ஆலடி|சனகாதி|சனகர்|சனந்தன|சனற்குமார|சனற்|குருந்தடி|குருந்தமர|கல்லால"),
    ("பிரமனின் ஐந்தாம் தலை", "deed", r"(?:பிரம|அயன்|நான்முக|பங்கய|கமல|தாமரை).{0,12}(?:சிரம்|தலை|முடி|சிரங்).{0,12}(?:கிள்ளி|கொய்|கொய்த|கிள்|நகத்தா|அரிந்த|அறுத்|கிளர)|(?:சிரம்|தலை).{0,6}(?:கிள்ளி|கொய்த).{0,10}(?:பிரம|அயன்)|பிரமகபால|பிரமனதுசிரம்|கபாலம்ஏந்|கபாலமேந்|ஓடேந்த|தலையோடு|பிரமன்தலையோடு|பிரமனைச்சிரம்"),
    ("அடிமுடி / அண்ணாமலை", "deed", r"அடிமுடி|அடிமுடிதேட|முடிதேட|அடிதேட|அண்ணாமலை|சோதிப்பிழம்பு|சோதியாய்நின்|அனல்பிழம்|ஜோதிலிங்க|சோதிலிங்க|லிங்கவடி|தீப்பிழம்பு|தீப்பிளம்பு|அன்னமாய்.{0,10}(?:பறந்|தேட)|கேழலாய்.{0,10}(?:அகழ்|தேட)"),
    ("கங்கை சடையில்", "deed", r"கங்கை(?:யை)?.{0,15}(?:சடை|முடி|சூடி|தரி|செஞ்சடை)|(?:சடை|முடி).{0,12}கங்கை|கங்காதர|கங்கையாள்|கங்கைதரி|ஆறணி|புனலணி|கங்கைசூடி|சுரநதி.{0,8}சடை|சடையில்.{0,6}(?:ஆறு|புனல்|நதி)"),
    ("ஆனந்த தாண்டவம்", "deed", r"தாண்டவ|ஊர்த்துவ|ஆடல்வல்ல|அனலாடி|அனலேந்தி|அனலேந்தும|அனலிலாடு|கூத்தாடு|திருநடன|திருநட்டம்|சுடலையாடு|பேயோடாடு|பூதவேதாள|பேயொடாடு|பேய்களோடாடு|காளியுடன்.{0,6}ஆடி|காளியோடாடு|அம்பலத்தாடு"),
    ("திருவிளையாடல்", "deed", r"நரிபரி|பரிநரி|நரியைப்பரி|பிட்டுக்கு|பிட்டுக்கு(?:மண்|க்கு)|மண்சுமந்|மண்சுமக்|பிரம்படி|பிரம்பால்|தருமிக்|தருமி|நக்கீர|கூன்பாண்டி|நின்றசீர்நெடுமாறன்|கழுவேற்|சமணர்|சமணரை|அனல்வாதம்|புனல்வாதம்|ஏடுதிரும்ப|வைகையில்|வைகைநதி|விறகுவிற்|வலைவீசி|வலையெறி|வளைவிற்|வளையல்விற்|சித்தராய|சித்தர்வேடம்|மாமனாய்|மாமனாக|பாண்டியன்.{0,20}(?:சிவ|சொக்கன்)"),
    ("நாயன்மார் / அடியார்", "deed", r"ஞானசம்பந்த|சம்பந்த|சம்பந்தர்|திருஞான|நாவுக்கரச|அப்பர்|அப்பருக்|சுந்தரர்|சுந்தரமூர்த்தி|மாணிக்கவாசக|வாதவூர|சேரமான்|பரவையார்|கண்ணப்ப|சிறுத்தொண்ட|சிறுத்தொண்டர்|சண்டேசுர|சண்டீசர்|திருமூலர்|காரைக்கால்|அம்மையார்.{0,6}(?:தலை|கால்)|பூசலார்|நந்தனார்|திருநீலகண்ட|அதிபத்த|நமிநந்தி|சாக்கிய|சாக்கியர்|கோச்செங்க|குங்கிலிய|ஏயர்கோன்|இடங்கழி|கணம்புல்ல|ஆனாயர்|இயற்பகை|இளையான்குடி|அரிவாட்டாய|பெருமிழலை|புகழ்த்துணை|குலச்சிறை|மங்கையர்க்கரசி"),
    ("முருகன் தந்தைக்கு உபதேசம்", "deed", r"செவிப்புக்|செவிபுக்|செவியிலுபதேச|செவியிலோத|காதிலுபதேச|காதிலோத|செவிமடு|தகப்பன்சாமி|தந்தைக்குபதேச|தந்தைக்குரை|சிவனுக்குபதேச|பிரணவ|ப்ரணவ|ஓமெனும்|ஏரகம்.{0,20}தந்தை"),
    ("முருகன் பிறப்பு (நெற்றிக்கண்)", "deed", r"நெற்றிக்கண்|நெற்றியிற்|நெற்றியினிற்|நுதற்கண்|நுதல்விழி|விழிநெருப்|கண்ணிற்றோன்ற|கண்ணினிற்றோன்ற|ஆறுபொறி|தீப்பொறி|தீப்பொறிகள்|அனற்பொறி|பொறியாறு|ஆறுதீப்|ஆறுமுகங்கண்டு|சிவமுதல்வ|சிவசுத|சிவகுமார|சிவபாலா|சிவமைந்த|சிவன்மைந்த|சிவனார்மைந்த|ஈசன்மைந்த|சிவனார்குமார|சிவன்குமார|அரன்மைந்த|அரன்குமார|அரனார்மைந்த|சங்கரன்மைந்த|சங்கரன்குமார|சம்புகுமார|சம்புபாலா|சம்புசுத|சம்புமைந்த|அரன்பாலா|அரன்சுத|ஈசன்பாலா|ஈசன்சுத|ஈசன்குமார"),
]

# Words that match a pattern above but are not Shiva. Checked on the matched text; shown in excluded.md.
LOOKALIKES = [
    (r"சங்கரி", "சங்கரி = Devi (Parvati), not Shiva"),
    (r"சங்கரித்", "சங்கரித்து = to destroy, not Shiva"),
    (r"சங்கரகுமார", "சூரசங்கர / சங்கரகுமார: reads சங்கார (destroy), ambiguous; Murugan's slaying of Sura"),
    (r"தஞ்சம்பு|கொஞ்சம்பு|பஞ்சம்பு|மஞ்சம்பு|அஞ்சம்பு", "சம்பு inside another word"),
    (r"சம்புகள்|சம்புவி|சம்புக[ழ்]", "சம்பு = arrow / other word"),
    (r"அரண்|அரணி|அரனை(?=க்)", "அரண் = fort, not அரன்"),
    (r"பசுபதிகாரி", None),
]


def flat(s):
    return re.sub(r"\s+", "", s)


def load():
    c = sqlite3.connect(f"file:{DB.as_posix()}?mode=ro", uri=True)
    return c.execute("select id, title, english_title, place, lyrics_list from songs order by id").fetchall()


def lookalike_reason(window):
    for pat, why in LOOKALIKES:
        if why and re.search(pat, window):
            return why
    return None


def run(deity, rules, out):
    songs = load()
    hits, rejects = [], []
    for sid, title, etitle, place, ll in songs:
        lines = json.loads(ll) if ll else []
        for i, line in enumerate(lines):
            # also try the line joined with the next, so a phrase that spans two lines is found once (on its first line)
            single = flat(line)
            pair = single + (flat(lines[i + 1]) if i + 1 < len(lines) else "")
            for label, kind, pat in rules:
                m = re.search(pat, single) or (re.search(pat, pair) if kind == "deed" else None)
                if not m:
                    continue
                if not m.start() < len(single):
                    continue  # the hit lies wholly in the next line; that line will report it
                token = m.group(0)
                why = lookalike_reason(pair[max(0, m.start() - 1): m.end() + 6])
                if why and kind == "name":
                    rejects.append(dict(song=sid, title=title, line_no=i + 1, label=label, token=token, line=line, why=why))
                    continue
                hits.append(dict(song=sid, title=title, english_title=etitle, place=place, kind=kind, label=label,
                                 token=token, line_no=i + 1, prev_lines=lines[max(0, i - 3): i], line=line,
                                 next_line=lines[i + 1] if i + 1 < len(lines) else ""))
    out.mkdir(parents=True, exist_ok=True)
    (out / "shortlist.json").write_text(json.dumps(hits, ensure_ascii=False, indent=1), encoding="utf-8")
    by_song = {}
    for h in hits:
        by_song.setdefault(h["song"], []).append(h)
    both = [s for s, hs in by_song.items() if {h["kind"] for h in hs} == {"name", "deed"}]
    only_name = [s for s, hs in by_song.items() if {h["kind"] for h in hs} == {"name"}]
    only_deed = [s for s, hs in by_song.items() if {h["kind"] for h in hs} == {"deed"}]

    md = [f"# Shortlist: songs that name Shiva or narrate a Shiva story\n",
          f"Generated by `scriptures/scripts/shortlist.py --deity {deity}` from `assets/thiruppugazh.db` ({len(songs)} songs). Do not hand-edit.\n",
          f"- Songs with at least one hit: **{len(by_song)}** ({len(hits)} hits)",
          f"- Name and deed both: {len(both)}; name only: {len(only_name)}; deed only: {len(only_deed)}\n",
          "Hits are keyword guesses to speed up reading, not conclusions.\n",
          "| Song | Title | Place | Kind | Labels | Lines |", "|---|---|---|---|---|---|"]
    for sid in sorted(by_song):
        hs = by_song[sid]
        kinds = "+".join(sorted({h["kind"] for h in hs}))
        labels = ", ".join(sorted({h["label"] for h in hs}))
        ls = " ⏎ ".join(f'**{h["line"]}**' for h in hs[:3]) + (" …" if len(hs) > 3 else "")
        md.append(f'| {sid} | {hs[0]["title"]} | {hs[0]["place"] or ""} | {kinds} | {labels} | {ls} |')
    (out / "shortlist.md").write_text("\n".join(md) + "\n", encoding="utf-8")
    ex = ["# Look-alike words rejected\n", "| Song | Rule | Token | Why | Line |", "|---|---|---|---|---|"]
    for r in rejects:
        ex.append(f'| {r["song"]} | {r["label"]} | {r["token"]} | {r["why"]} | {r["line"]} |')
    (out / "excluded.md").write_text("\n".join(ex) + "\n", encoding="utf-8")
    c = Counter(h["label"] for h in hits)
    per_label_songs = Counter()
    for sid, hs in by_song.items():
        for lab in {h["label"] for h in hs}:
            per_label_songs[lab] += 1
    print("songs", len(by_song), "hits", len(hits), "rejects", len(rejects), "both", len(both), "name-only", len(only_name), "deed-only", len(only_deed))
    for lab, n in per_label_songs.most_common():
        print(f"  {n:4d} songs  {lab}")


if __name__ == "__main__":
    deity = sys.argv[sys.argv.index("--deity") + 1] if "--deity" in sys.argv else None
    if deity != "shiva":
        sys.exit("usage: shortlist.py --deity shiva   (Vishnu uses shortlist_maruga.py)")
    run(deity, SHIVA, ROOT / "scriptures" / deity)
