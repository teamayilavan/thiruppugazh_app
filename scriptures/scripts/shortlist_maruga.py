"""Shortlist Thiruppugazh songs that call Murugan a "nephew" (மருகன்) of someone.

Reads the bundled DB read-only and writes:
  scriptures/vishnu/shortlist.json   every hit, with context and auto-tags
  scriptures/vishnu/shortlist.md     human-readable index, one row per song
  scriptures/vishnu/excluded.md      look-alike words rejected (and why)

Run from the repo root:  python -I scriptures/scripts/shortlist_maruga.py
Tags are a first pass; the owner reviews them (see scriptures/README.md).
"""
import json
import re
import sqlite3
import sys
from pathlib import Path

sys.stdout.reconfigure(encoding="utf-8")

ROOT = Path(__file__).resolve().parents[2]
DB = ROOT / "assets" / "thiruppugazh.db"
OUT = ROOT / "scriptures" / "vishnu"

TAMIL = r"஀-௿"

# Words that contain "மருக"/"மரும" but are not "nephew". Checked first.
FALSE_POSITIVES = [
    (r"[தடச]மருக", "தமருகம்/டமருகம் = damaru drum; சமருக் = battle"),
    (r"மருக்", "மருக் + ... (மருக்குலாவிய, மருக்கற்புர) = fragrance"),
    (r"மருகல்", "Thirumarugal = a place"),
    (r"மருகரு", None),  # handled below (மருகர் vs மருகருகி)
    (r"மருகு", "மருகு = to wither / fragrance, not nephew"),
    (r"மருமலர்|மருமல்லி|மருமறை|மருமை|மருமாது", "மரு + word (fragrance / mystery)"),
    (r"மருமகள்", "மருமகள் = daughter-in-law, not nephew"),
]

# nephew forms we accept (vocative / nominative), most specific first
FORMS = [
    ("மருகோனே", r"மருகோனே"),
    ("மருகனே", r"மருகனே|மருக னே"),
    ("மருகன்", r"மருகன்|மருகனெ"),
    ("மருகா", r"மருகா"),
    ("மருகர்", r"மருகர்(?!ரு)"),
    ("மருமகன்", r"மருமகன்|மருமகனா|மருமகனே|மருமக(?![ள்])"),
    ("மருக", r"மருக"),  # bare vocative, often fused with next word
]

# Words that name Vishnu or a well-known epithet of his. Keyword guess only.
VISHNU_NAMES = (
    "திருமால்|நெடுமால்|மால்|மாலோன்|மாயன்|மாயோன்|மாயவன்|மாதவன்|மாமாயன்|நாரண|நாராயண|"
    "அரி(?!ய)|ஹரி|சக்ரதர|சக்கிர|சக்ர|சார்ங்க|சங்க பாணி|முகுந்த|அச்சுத|கேசவ|முராரி|சீதர|"
    "கருமுகில்|கொண்டல்|நெடிய|நெடும்புயல்|மாமுகில்|பச்சைப் ?பொற்புயல்|புயலென|நளினன்|"
    "அரங்கர்|பெருமாள்|வேங்கட|ராமன்|இராமன்|ராகவ|இராகவ|கண்ணன்|கிருஷ்ண|கோபால|கோவிந்த|"
    "பரமபத|வைகுந்த|திருமகள்|திருமருக|அரிதிரு|திருமார்ப|மார்பன்"
)

# Story hints, matched on the song's whole text (prev + this line). First pass only.
STORIES = {
    "Ramayana": "ராம|இராம|ராகவ|இராகவ|ஜானகி|சீதை|இலங்கை|ராவண|இராவண|தாடகை|நிசிசர|அரக்கர்|"
                "அனுமன|அநுமன|வாலி|சேது|பாலம்|கோதண்ட|தசரத|குகன்|சனகி",
    "Krishna / Bhagavatam": "கண்ணன்|கிருஷ்ண|க்ருஷ்ண|கோபால|கோவிந்த|ஆயர்|ஆய்ப்பாடி|ஆயன்|வெண்ணெய்|தயிர்|"
                "சகடு|மலை குடை|மலைகுடை|கோவர்த்தன|பூதனை|பேயானாள்|காளிங்க|கன்று|குடைய|"
                "கம்ச|கஞ்ச|உரலில்|உரல்|ஆநிரை|வெண்ணை|யசோதை|யசோதா|மருதிடை|மருதமுதை",
    "Mahabharata": "பாரத|பாண்டவ|பஞ்சவ|தேர்கட|தேர் கட|பார்த்த|அருச்சுன|பாஞ்சாலி|துரியோதன|"
                "கௌரவ|குருகுல|கீதை|தூது|சமர்|பாரதப்",
    "Vamana / Bali": "மாபலி|மாவலி|அளவிடு|அளந்த|குறியவன்|குறளன்|வாமன|மூவடி|உலகளந்த|உலகளந்",
    "Narasimha": "நரசிங்க|நார சிங்க|நரகரி|நரசிம்ம|சிங்கன்|இரணிய|இரண்ய|பிரகலாத|பிரகலா|தூண்|அரிமுகன்|உகிர்|நகம் ?கொண்டு",
    "Varaha": "சூகர|வராக|ஏனம்|கேழல்|மண்ணிடந்த|பூமியை",
    "Kurma / samudra manthana": "கூர்ம|ஆமை|கடல் ?கடை|கடைந்த|மந்தர|மத்து|அமுது|பாற்கடல|வாசுகி|கடல்முன்",
    "Matsya": "மீன|மச்ச|வேதம் ?மீட்ட",
    "Parashurama": "பரசு|மழுவேந்த",
    "Gajendra moksha": "கரி|முதலை|ஆதிமூல|கஜேந்திர|வாரண|யானைக்கு",
    "Ahalya / Rama-pada": "அகலிகை|கல்லை|கல்லாய்|கல் ?பெண்",
    "Vishnu reclining / Adi Sesha": "அரவணை|அரவில்|பாம்பணை|ஆதிசேஷ|அனந்த|அரவு|வேலைமேல்|கண்வளர்|துயில்|பள்ளி",
    "Brahma-Vishnu-Shiva": "நான்முக|பிரமன்|பிரம|கமல ?மலர்|தாமரை|எகினன்|அயன்|தந்தை",
    "Vishnu & Shiva (Mohini, Tripura, etc.)": "மோகினி|புரம் ?எரி|புராரி|சிவன்|அரன்|ஈசன்",
    "Tirumalai / Arangam / temple Vishnu": "அரங்க|ரங்க|வேங்கட|திருப்பதி|அழகர்|கள்ளழகர்|திருமாலிருஞ்|சார்ங்க|பாற்கடல|பரமபத",
    "Valli / Devasena marriage": "குறவர|குறமகள்|வள்ளி|தெய்வானை|மணம்|மணவாளன்|வெற்பு",
}


def load():
    c = sqlite3.connect(f"file:{DB.as_posix()}?mode=ro", uri=True)
    return c.execute(
        "select id, title, english_title, place, lyrics_list from songs order by id"
    ).fetchall()


def nephew_hits(line):
    """Yield (form, start, end, token) for each accepted nephew word in line."""
    for m in re.finditer(r"மரு[கம]", line):
        s = m.start()
        # whole token around the match, for reporting
        ts = s
        while ts > 0 and re.match(rf"[{TAMIL}]", line[ts - 1]):
            ts -= 1
        te = m.end()
        while te < len(line) and re.match(rf"[{TAMIL}]", line[te]):
            te += 1
        token = line[ts:te]
        tail = line[s:s + 12]
        # false-positive checks, anchored where the match starts (allow one prefix char)
        window = line[max(0, s - 1):s + 12]
        reject = None
        for pat, why in FALSE_POSITIVES:
            if pat == r"மருகரு":
                if re.match(r"மருகரு(?!யி)", tail) and not tail.startswith("மருகர்"):
                    reject = "மருகருகி = மருகு + அருகு, not nephew"
                    break
                continue
            if re.search(pat, window if pat.startswith("[தடச]") else tail) and (
                not pat.startswith("[தடச]") or re.match(rf"[தடச]மருக", window)
            ):
                reject = why
                break
        if reject:
            yield ("REJECT", s, te, token, reject)
            continue
        for name, pat in FORMS:
            if re.match(pat, tail):
                yield (name, s, te, token, None)
                break
        else:
            yield ("REJECT", s, te, token, "no accepted nephew form")


def tags(text, table):
    out = []
    for name, pat in table.items():
        if re.search(pat.replace("\u0000", ""), text):
            out.append(name)
    return out


def main():
    songs = load()
    hits, rejects = [], []
    for sid, title, etitle, place, ll in songs:
        lines = json.loads(ll) if ll else []
        for i, line in enumerate(lines):
            for form, s, e, token, why in nephew_hits(line):
                if form == "REJECT":
                    rejects.append(
                        dict(song=sid, title=title, line_no=i + 1, token=token, line=line, why=why)
                    )
                    continue
                prev = lines[i - 1] if i > 0 else ""
                nxt = lines[i + 1] if i + 1 < len(lines) else ""
                # the invocation phrase usually sits in the line itself + the one before
                ctx = f"{prev} / {line}"
                # lyric spacing is unreliable (sandhi), so keyword-match with spaces removed
                flat = re.sub(r"\s+", "", ctx)
                hits.append(
                    dict(
                        song=sid,
                        title=title,
                        english_title=etitle,
                        place=place,
                        form=form,
                        token=token,
                        line_no=i + 1,
                        prev_line=prev,
                        line=line,
                        next_line=nxt,
                        vishnu_name_seen=bool(re.search(VISHNU_NAMES, flat)),
                        story_hints=tags(flat, STORIES),
                    )
                )

    OUT.mkdir(parents=True, exist_ok=True)
    (OUT / "shortlist.json").write_text(
        json.dumps(hits, ensure_ascii=False, indent=1), encoding="utf-8"
    )

    by_song = {}
    for h in hits:
        by_song.setdefault(h["song"], []).append(h)

    seen = [s for s, hs in by_song.items() if any(h["vishnu_name_seen"] for h in hs)]
    unseen = [s for s in by_song if s not in seen]

    md = []
    md.append("# Shortlist: songs where Murugan is called a nephew (மருகன்)\n")
    md.append(
        f"Generated by `scriptures/scripts/shortlist_maruga.py` from `assets/thiruppugazh.db` "
        f"({len(songs)} songs).\n"
    )
    md.append(f"- Songs with a nephew word: **{len(by_song)}**  ({len(hits)} occurrences)")
    md.append(f"- Vishnu name/epithet found in the same or previous line: **{len(seen)}**")
    md.append(f"- No Vishnu name found by keyword: **{len(unseen)}** (read these first; most are an epithet the list missed, a few may not be Vishnu)\n")
    md.append("Tags are keyword guesses to speed up reading, not conclusions.\n")
    for label, ids in (("Vishnu name seen", seen), ("No Vishnu name found (review)", unseen)):
        md.append(f"\n## {label}\n")
        md.append("| Song | Title | Place | Form | Lines | Story hints |")
        md.append("|---|---|---|---|---|---|")
        for sid in sorted(ids):
            hs = by_song[sid]
            h0 = hs[0]
            forms = ", ".join(sorted(set(h["form"] for h in hs)))
            tg = ", ".join(sorted(set(t for h in hs for t in h["story_hints"]))) or "-"
            line = " ⏎ ".join(
                f'{h["prev_line"]} / **{h["line"]}**' if h["prev_line"] else h["line"] for h in hs
            )
            md.append(
                f'| {sid} | {h0["title"]} | {h0["place"] or ""} | {forms} | {line} | {tg} |'
            )
    (OUT / "shortlist.md").write_text("\n".join(md) + "\n", encoding="utf-8")

    ex = ["# Look-alike words rejected\n", "| Song | Token | Why | Line |", "|---|---|---|---|"]
    for r in rejects:
        ex.append(f'| {r["song"]} | {r["token"]} | {r["why"]} | {r["line"]} |')
    (OUT / "excluded.md").write_text("\n".join(ex) + "\n", encoding="utf-8")

    from collections import Counter
    print("songs", len(by_song), "hits", len(hits), "rejects", len(rejects))
    print(Counter(h["form"] for h in hits))
    print("seen", len(seen), "unseen", len(unseen))


if __name__ == "__main__":
    main()
