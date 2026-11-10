"""Build the A4 reading volumes of "Stories in the Thiruppugazh" with Typst.

  python -I -X utf8 scriptures/scripts/make_pdf.py                    # 4 volumes x 2 editions = 8 PDFs in scriptures/pdf/
  python -I -X utf8 scriptures/scripts/make_pdf.py --volume 3         # one volume, both editions
  python -I -X utf8 scriptures/scripts/make_pdf.py --volume 3 --edition verses
  python -I -X utf8 scriptures/scripts/make_pdf.py --stories m-jayanta d-mahisha --name sample

Volumes: I Vishnu, II Shiva, III Murugan, IV Sambandar + saints + Devi + Ganesha + Tamil lore.
Editions: full (each song printed once in full with its Tamil meaning, later appearances show only the lines) and
verses (only the lines that carry the allusion). The story files (<set>/stories/*.md) stay the single source of truth;
the story texts are in pdf/narratives/<slug>.txt. Needs typst on PATH and a Tamil font (Nirmala UI on Windows).
"""
import argparse
import datetime
import json
import re
import sqlite3
import subprocess
import sys
import urllib.parse
from pathlib import Path

sys.stdout.reconfigure(encoding="utf-8")
ROOT = Path(__file__).resolve().parent.parent
PDF = ROOT / "pdf"
SETS = ["sambandar", "saints", "devi", "murugan", "ganesha", "tamil-lore", "vishnu", "shiva"]
DB = ROOT.parent / "assets" / "thiruppugazh.db"
NARR = PDF / "narratives"
VERIFIED = ("machine-read", "checked", "opened", "local")


def key(t):
    return re.sub(r"[\s.…]+", "", t)


PROCESS = re.compile(r"NOTE|project notes|earlier|not located|candidate|machine|re-checked|checked|page read|page was|opened|not opened|search|from memory|cache|verified|downloaded|keyword", re.I)


def polish(t):
    """Drop the working notes (how a reference was checked) so that only the scholarly description is printed."""
    t = re.split(r"NOTE", t)[0]
    t = re.sub(r"\s*\([^()]*(?:checked|machine|page read)[^()]*\)", "", t)
    parts = re.split(r"(?<=[;.])\s+", t)
    parts = [x for x in parts if not PROCESS.search(x)]
    return clean(" ".join(parts)).rstrip(";")


_MASTER = {}
_TA = {}


def tamil_first(url):
    if not _TA:
        for f in (ROOT / "vishnu" / "dp").glob("*.json"):
            for x in json.loads(f.read_text(encoding="utf-8")):
                if x.get("url") and x.get("first_words_ta"):
                    _TA[x["url"]] = x["first_words_ta"]
    return _TA.get(url, "")


def from_master(set_name, slug):
    """Vishnu and Shiva keep their references, with links, in master.json."""
    if set_name not in _MASTER:
        _MASTER[set_name] = json.loads((ROOT / set_name / "master.json").read_text(encoding="utf-8"))["stories"]
    u = _MASTER[set_name].get(slug)
    if not u:
        return None
    refs = []
    for r in u.get("refs", []):
        if r.get("pinned", True) is False:
            continue
        says = clean(r.get("quote") or r.get("gist") or "")
        url = r.get("url", "")
        m = re.match(r"SB (\d+)\.(\d+)", r["ref"])
        if not url and r["src"] == "Bhagavata Purana" and m:
            url = f"https://vedabase.io/en/library/sb/{m.group(1)}/{m.group(2)}/"
        refs.append(dict(source=r["src"], ref=clean(r["ref"]), says=says, status="", links=[url] if url else []))
    for d in u.get("dp", []):
        if not d.get("confirmed"):
            continue
        first = tamil_first(d.get("url", "")) or (d.get("first", "") if set_name == "shiva" else "")
        says = clean((first + " — " if first else "") + d.get("gist", ""))
        src = "Divya Prabandham" if set_name == "vishnu" else "Tamil Shaiva texts"
        refs.append(dict(source=src, ref=clean(f"{d['prabandham']} {d['ref']}"), says=says, status="", links=[d["url"]] if d.get("url") else []))
    return refs


def load_songs(numbers):
    con = sqlite3.connect(f"file:{DB}?mode=ro", uri=True)
    out = {}
    for n in numbers:
        r = con.execute("select title, place, tune_list, lyrics_list, english_pathavurai, pathavurai from songs where id=?", (n,)).fetchone()
        if not r:
            continue
        title, place, tune, lyrics, en, ta = r
        tune = " ".join(json.loads(tune)).replace("......", " … ") if tune else ""
        meaning, mlang = (clean(en), "en") if en else (clean(ta or ""), "ta")
        out[n] = dict(title=title, place=place or "", tune=re.sub(r"\s+", " ", tune).strip(), lines=json.loads(lyrics), meaning=meaning, mlang=mlang)
    return out


URL = re.compile(r"\[(https?://[^\]\s]+)\]|(?<![\[\w])(https?://[^\s|\]]+)")


def clean(t):
    return re.sub(r"\s+", " ", t.replace("**", "")).strip()


def split_links(cell):
    links = []
    def grab(m):
        u = m.group(1) or m.group(2)
        links.append(u)
        return ""
    text = URL.sub(grab, cell)
    return clean(text), links


def parse(path, set_name):
    lines = path.read_text(encoding="utf-8").splitlines()
    title = next(l[2:].strip() for l in lines if l.startswith("# "))
    idline = next(l for l in lines if l.startswith("`"))
    m = re.match(r"`([^`]+)`\s*\|\s*([^|]+?)\s*\|\s*(\d+) songs?(?:\s*\|\s*(.+))?", idline)
    slug, domain, nsongs, basis = m.group(1), m.group(2), int(m.group(3)), (m.group(4) or "").strip()
    # sections split on '## '
    secs, cur, name = {}, [], "head"
    for l in lines:
        if l.startswith("## "):
            secs[name] = cur
            name, cur = l[3:].strip(), []
        else:
            cur.append(l)
    secs[name] = cur
    head = secs["head"]
    i = head.index(idline)
    brief = clean(" ".join(x for x in head[i + 1:] if x.strip() and not x.startswith("<!--")))
    refs, note = [], ""
    for l in secs.get("References", []):
        if l.startswith("|") and not l.startswith("|---") and not l.startswith("| Source"):
            cells = [c.strip() for c in l.strip().strip("|").split(" | ")]
            if len(cells) == 3:      # Vishnu / Shiva: source, reference, what it says
                src, ref, says = cells
                status = ""
            elif len(cells) >= 4:
                src, ref, says, status = cells[0], cells[1], cells[2], cells[3]
            else:
                continue
            links = []
            out = []
            for c in (src, ref, says):
                t, lk = split_links(c)
                links += lk
                out.append(t)
            refs.append(dict(source=out[0], ref=out[1], says=out[2], status=clean(status), links=links))
        elif l.startswith("Note:"):
            note = clean(l[5:])
    hand = clean(" ".join(x for x in secs.get("Hand-read notes", []) if x.strip()))
    songs = []
    block = None
    for l in secs.get("Songs", []):
        h = re.match(r"###\s+(\d+)\s+(.*?)(?:\s+\(([^()]*)\))?\s*$", l)
        if h:
            block = dict(no=int(h.group(1)), name=h.group(2).strip(), place=(h.group(3) or "").strip(), lines=[], comment="", conf="")
            songs.append(block)
            continue
        if block is None:
            continue
        if l.startswith(">"):
            t = l[1:].strip()
            if t.startswith("(no Tamil keyword line"):
                continue
            hit = t.startswith("**") or "**" in t
            block["lines"].append(dict(t=t.replace("**", "").replace("......", "  …  "), hit=hit))
        elif l.startswith("Commentary:"):
            block["comment"] = clean(l[len("Commentary:"):])
        elif l.startswith("Confidence"):
            block["conf"] = clean(l[len("Confidence"):])
    songs.sort(key=lambda s: s["no"])
    links = []
    for r in refs:
        for u in r["links"]:
            if u not in [x["url"] for x in links]:
                links.append(dict(url=u, show=urllib.parse.unquote(u), label=(r["source"] + (", " + r["ref"] if r["ref"] else ""))[:110]))
    return dict(slug=slug, set=set_name, title=title, domain=domain, nsongs=nsongs, basis=basis, brief=brief,
                refs=refs, note=note, hand=hand, songs=songs, links=links)


VOLUMES = {
    1: dict(roman="I", name="Vishnu", sets=["vishnu"], file="vishnu"),
    2: dict(roman="II", name="Shiva", sets=["shiva"], file="shiva"),
    3: dict(roman="III", name="Murugan", sets=["murugan"], file="murugan"),
    4: dict(roman="IV", name="Sambandar, the Saints, the Goddess, Ganesha and Tamil Lore",
            sets=["sambandar", "saints", "devi", "ganesha", "tamil-lore"], file="others"),
}


def split_verses(lines, tune_len):
    """The app's rule (lib/utils/verses.dart): a verse is tune_len consecutive lines, or 2 when there is no tune pattern."""
    size = tune_len if tune_len > 0 else 2
    verses, cur = [], []
    for i, l in enumerate(lines):
        l = l.strip()
        if l:
            cur.append(l)
        if (i + 1) % size == 0:
            if cur:
                verses.append(cur)
            cur = []
    if cur:
        verses.append(cur)
    return verses


def disp(t):
    return t.replace("......", "  …  ")


def build_stories(sets, only=None):
    stories = []
    for s in sets:
        for f in sorted((ROOT / s / "stories").glob("*.md")):
            st = parse(f, s)
            if s in ("vishnu", "shiva"):
                mr = from_master(s, st["slug"])
                if mr is not None:
                    st["refs"] = mr
            if only and st["slug"] not in only:
                continue
            stories.append(st)
    stories.sort(key=lambda s: s["title"].lower())
    return stories


def prepare(stories, edition):
    """Fill every story with its narrative, references, links and songs laid out for the chosen edition."""
    con = sqlite3.connect(f"file:{DB}?mode=ro", uri=True)
    biblio, seen = {}, set()
    for st in stories:
        f = NARR / f"{st['slug']}.txt"
        st["story"] = [p.strip() for p in re.split(r"\n\s*\n", f.read_text(encoding="utf-8")) if p.strip()] if f.exists() else [st["brief"]]
        st["narrated"] = f.exists()
        st["refs"] = [r for r in st["refs"] if (not r["status"]) or any(v in r["status"] for v in VERIFIED)]
        st["links"] = []
        for r in st["refs"]:
            for u in r["links"]:
                if u not in [x["url"] for x in st["links"]]:
                    st["links"].append(dict(url=u, show=urllib.parse.unquote(u), label=(r["source"] + ": " + re.split(r"[(;:]", r["ref"])[0].strip()[:70]).rstrip(": ")))
            r["says"], r["ref"] = polish(r["says"]), polish(r["ref"])
            biblio.setdefault(r["source"], set()).update(r["links"])
        out, nohit = [], []
        for sg in st["songs"]:
            row = con.execute("select title, place, tune_list, lyrics_list, meanings, pathavurai from songs where id=?", (sg["no"],)).fetchone()
            hits = {key(l["t"]) for l in sg["lines"] if l["hit"]}
            sg.pop("lines", None); sg.pop("comment", None); sg.pop("conf", None)
            if not row:
                continue
            title, place, tune, lyrics, meanings, patha = row
            tune_l = json.loads(tune) if tune else []
            lines = json.loads(lyrics)
            verses = split_verses(lines, len(tune_l))
            vs = [[dict(t=disp(l), hit=key(l) in hits) for l in v] for v in verses]
            ref_groups = [[x for x in v if x["hit"]] for v in vs]
            ref_groups = [g for g in ref_groups if g]
            meaning = re.sub(r"\s*(?:\.{3,}|…)\s*", " ", patha if patha and patha.strip() else " ".join(json.loads(meanings))); meaning = clean(meaning)
            tune_txt = re.sub(r"\s+", " ", " ".join(tune_l).replace("......", " … ")).strip()
            base = dict(no=sg["no"], name=title, place=(place or sg["place"] or "").strip(), tune=tune_txt, has_hit=bool(ref_groups), refs=ref_groups)
            if edition == "verses":
                if base["has_hit"]:
                    out.append(base)
                else:
                    nohit.append(dict(no=base["no"], name=base["name"]))
            else:
                if sg["no"] in seen:
                    base["xref"] = True            # printed in full earlier in this volume: only the lines here
                    out.append(base)
                else:
                    seen.add(sg["no"])
                    base.update(full=vs, meaning=meaning, first=True, xref=False)
                    out.append(base)
        st["songs"] = out
        st["nohit"] = nohit
        st.pop("hand", None)
    return biblio


def make(stories, edition, name, title_line, volume_line, sets):
    biblio = prepare(stories, edition)
    songs = {}
    for st in stories:
        for sg in st["songs"]:
            songs.setdefault(sg["no"], dict(no=sg["no"], name=sg["name"], place=sg["place"], stories=[]))["stories"].append(st["slug"])
        for sg in st["nohit"]:
            songs.setdefault(sg["no"], dict(no=sg["no"], name=sg["name"], place="", stories=[]))["stories"].append(st["slug"])
    sources = sorted((k, sorted({urllib.parse.urlparse(u).netloc for u in v})) for k, v in biblio.items())
    data = dict(stories=stories, songs=[songs[k] for k in sorted(songs)], date=datetime.date.today().isoformat(), edition=edition,
                title_line=title_line, volume_line=volume_line, n_stories=len(stories), n_songs=len(songs), sets=sets,
                sources=[dict(name=k, urls=v) for k, v in sources])
    PDF.mkdir(exist_ok=True)
    (PDF / f"{name}.json").write_text(json.dumps(data, ensure_ascii=False), encoding="utf-8")
    out = PDF / f"{name}.pdf"
    cmd = ["typst", "compile", "--root", str(PDF), "--input", f"data={name}.json", str(PDF / "book.typ"), str(out)]
    r = subprocess.run(cmd, capture_output=True, text=True, encoding="utf-8")
    print(f"{name}: {len(stories)} stories, {len(songs)} songs -> {out.name}" + ("" if r.returncode == 0 else "  FAILED\n" + r.stderr))
    return r.returncode


def main():
    ap = argparse.ArgumentParser(description="Build the Stories in the Thiruppugazh volumes (Typst, A4).")
    ap.add_argument("--volume", type=int, nargs="*", help="1 Vishnu, 2 Shiva, 3 Murugan, 4 the rest; default all four")
    ap.add_argument("--edition", choices=["full", "verses", "both"], default="both")
    ap.add_argument("--stories", nargs="*", help="only these story slugs (for a sample)")
    ap.add_argument("--name", help="output name for a --stories sample")
    a = ap.parse_args()
    editions = ["full", "verses"] if a.edition == "both" else [a.edition]
    rc = 0
    if a.stories:
        for ed in editions:
            stories = build_stories(SETS, set(a.stories))
            nm = f"{a.name or 'sample'}-{ed}"
            rc |= make(stories, ed, nm, "Stories in the Thiruppugazh", "Sample", SETS)
        sys.exit(rc)
    for v in (a.volume or sorted(VOLUMES)):
        vol = VOLUMES[v]
        for ed in editions:
            stories = build_stories(vol["sets"])
            pre = "thiruppugazh-stories" if ed == "full" else "thiruppugazh-verses"
            title = "Stories in the Thiruppugazh" if ed == "full" else "Stories in the Thiruppugazh: the Verses"
            rc |= make(stories, ed, f"{pre}-vol{v}-{vol['file']}", title, f"Volume {vol['roman']}: {vol['name']}", vol["sets"])
    sys.exit(rc)


if __name__ == "__main__":
    main()
