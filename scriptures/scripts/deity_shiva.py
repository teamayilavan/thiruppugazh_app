"""Shiva configuration for build_master.py (run with --deity shiva). See deity_vishnu.py for the required names.

Primary-text references (Sanskrit Puranas, Mahabharata, Ramayana) come from shiva/refs-sanskrit.json; the Tamil Shaiva
corpus (Tevaram, Tiruvasagam, Periya Puranam, Tiruvilaiyadal Puranam, Kanda Puranam) comes from shiva/tirumurai-deeds.json
and shiva/refs-saints.json. Each file is keyed by story slug; a missing file simply gives no references.
"""
import json
import re
import sqlite3
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))

import shiva_episodes  # noqa: E402
from shiva_story_data import S as STORY  # noqa: E402,F401

FOLDER = "shiva"
V = HERE.parent / FOLDER
DB = HERE.parent.parent / "assets" / "thiruppugazh.db"
_MODS = shiva_episodes.build()
DOMAINS = list(_MODS.items())
DOMAIN_NAME = {"deeds": "Deeds of Shiva", "forms": "Forms and dance of Shiva", "saints": "Saints and the sacred sports",
               "murugan": "Murugan and Shiva"}
TAMIL_SOURCE = "Tamil Shaiva texts"
TITLE = "Thiruppugazh: stories of Shiva"
HEADING = "Thiruppugazh songs that name Shiva or tell a story of Shiva: stories and sources"
PDF_NAME = "thiruppugazh-shiva-stories.pdf"
HTML_NAME = "thiruppugazh-shiva-stories.html"
INTRO = ("Part A is by song number: the verse, then the story, then every reference. Part B is by story, with the Tamil Shaiva verses "
         "and their links. Primary-text references are Sanskrit (Puranas, Mahabharata, Ramayana) and the Tamil Shaiva texts "
         "(Tevaram, Tiruvasagam, Periya Puranam, Kanda Puranam); each is marked confirmed only when its page was opened and read. "
         "The shortlist rule is keyword-based and was refined by reading every song; songs that only name Shiva or call "
         "Murugan his son are in Part C.")
PART_C_NOTE = "The song names Shiva, his form or his fatherhood of Murugan, but no story could be identified."

# songs found by the second pass (not in shortlist.json): the line to show
SECOND_PASS_LINE = {"139": r"அரவணி", "957": r"சொக்கர்", "1063": r"மறலி", "1161": r"சொக்கர்", "1177": r"பகீரதி", "1252": r"சுத்தசொற்ப"}


def slug_for(domain, eid):
    return f"shiva-{eid}"


def _load(name):
    f = V / name
    return json.loads(f.read_text(encoding="utf-8")) if f.exists() else {}


_SANSKRIT = _load("refs-sanskrit.json")
_DEEDS = _load("tirumurai-deeds.json")
_SAINTS = _load("refs-saints.json")


def build_refs(domain, e):
    slug = e["slug"]
    return [dict(src=r["src"], ref=r["ref"], gist=r.get("gist", ""), quote=r.get("quote", ""), pinned=bool(r.get("confirmed")),
                 url=r.get("url", "")) for r in _SANSKRIT.get(slug, [])]


def dp_for(domain, eid):
    slug = f"shiva-{eid}"
    out = []
    for r in _DEEDS.get(slug, []):
        ref = r.get("ref", "")
        if r.get("tirumurai"):
            ref = f"Tirumurai {r['tirumurai']}, {ref}"
        out.append(dict(prabandham=r.get("text", ""), ref=ref, first=r.get("first_words_ta", ""), gist=r.get("gist", ""),
                        url=r.get("url", ""), confirmed=bool(r.get("confirmed"))))
    for r in _SAINTS.get(slug, []):
        out.append(dict(prabandham=r.get("text", ""), ref=r.get("ref", ""), first=r.get("first_words_ta", ""), gist=r.get("gist", ""),
                        url=r.get("url", ""), confirmed=bool(r.get("confirmed"))))
    return out


def load_hits():
    """{song id: {song, title, place, line_no}} for every mapped song that is not purely 'not-shiva'."""
    con = sqlite3.connect(f"file:{DB.as_posix()}?mode=ro", uri=True)
    shortlist = {}
    for h in json.loads((V / "shortlist.json").read_text(encoding="utf-8")):
        shortlist.setdefault(str(h["song"]), h)
    hits = {}
    for line in (V / "song-story-map.txt").read_text(encoding="utf-8").splitlines():
        if not line.strip() or line.startswith("#"):
            continue
        sid, slugs, _note, _conf = line.split("|")
        if set(slugs.split(",")) == {"not-shiva"}:
            continue
        if sid in shortlist:
            h = shortlist[sid]
            hits[sid] = dict(song=int(sid), title=h["title"], place=h["place"], line_no=h["line_no"])
            continue
        title, place, ll = con.execute("select title, place, lyrics_list from songs where id=?", (int(sid),)).fetchone()
        lines = json.loads(ll)
        pat = SECOND_PASS_LINE.get(sid)
        n = next((i for i, l in enumerate(lines) if pat and re.search(pat, re.sub(r"\s+", "", l))), 0)
        hits[sid] = dict(song=int(sid), title=title, place=place, line_no=n + 1)
    return hits
