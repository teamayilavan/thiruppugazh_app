"""Rebuild the small text caches used by build_new_sets.py checks (all go to scripts/.cache, git-ignored).

  python -I -X utf8 scriptures/scripts/fetch_misc.py

markandeya_dm_verses.json  Devi Mahatmya (Markandeya Purana 81-93, Banerjea numbering) from Sanskrit Wikisource: {"83.38": text}
purananuru.json            Purananuru poems 101-210 from Tamil Wikisource, with the poet/patron header: {"107": text}
tev_misc.json              Tevaram pathigams by "thirumurai.pathigam:verse" from thevaaram.org (only those listed in TEV below)
"""
import html
import json
import re
import sys
import urllib.parse
import urllib.request
from pathlib import Path

sys.stdout.reconfigure(encoding="utf-8")
C = Path(__file__).resolve().parent / ".cache"
C.mkdir(exist_ok=True)
UA = {"User-Agent": "thiruppugazh-scriptures-research/1.0 (personal study)"}


def get(url):
    return urllib.request.urlopen(urllib.request.Request(url, headers=UA), timeout=60).read().decode("utf-8", "replace")


def markandeya():
    dig = str.maketrans("०१२३४५६७८९", "0123456789")
    V = {}
    for t in ("अध्यायः ०८१-०८५", "अध्यायः ०८६-०९०", "अध्यायः ९१-९३"):
        raw = get("https://sa.wikisource.org/w/index.php?action=raw&title=" + urllib.parse.quote("मार्कण्डेयपुराणम्/" + t.replace(" ", "_")))
        raw = re.sub(r"\{\{header.*?\n\}\}", "", raw, flags=re.S)
        for m in re.finditer(r"([^॥]*?)॥([०-९]+)\.([०-९]+)॥", raw, re.S):
            V[f"{m.group(2).translate(dig)}.{m.group(3).translate(dig)}"] = re.sub(r"\s+", " ", m.group(1)).strip()
    (C / "markandeya_dm_verses.json").write_text(json.dumps(V, ensure_ascii=False), encoding="utf-8")
    print("markandeya", len(V), "verses (the first verse of each chapter also carries the previous colophon)")


def purananuru():
    P = {}
    for rng in ("101-110", "111-120", "121-130", "141-150", "151-160", "201-210"):
        t = get("https://ta.wikisource.org/w/index.php?action=raw&title=" + urllib.parse.quote("புறநானூறு/பாடல்_" + rng))
        lo = int(rng.split("-")[0])
        seq = [lo] + [int(x) for x in re.findall(r"</poem>\s*(\d+)", t)]
        for n, p in zip(seq, re.findall(r"<poem>(.*?)</poem>", t, re.S)):
            P[str(n)] = p.strip()
    (C / "purananuru.json").write_text(json.dumps(P, ensure_ascii=False), encoding="utf-8")
    print("purananuru", len(P), "poems")


TEV = {"1.45": (1, 1045),            # Sambandar, Thiruvalangadu
       "11.2": (11, 11002),          # Karaikkal Ammaiyar, Mootha Tirupathigam
       "11.8": (11, 11008),          # Cheraman Perumal, Tirukkailaya Gnana Ula (Adi Ula)
       "11.17": (11, 11017),         # Nakkeerar, Tirumurukarruppadai
       "8.101": (8, 8101)}           # Manikkavasagar, Tiruvasagam: Sivapuranam


def tevaram():
    out = {}
    for key, (thiru, sid) in TEV.items():
        t = get(f"https://thevaaram.org/thirumurai_1/onepage.php?thiru={thiru}&Song_idField={sid}")
        x = re.sub(r"\s+", " ", html.unescape(re.sub(r"<[^>]+>", " ", t)))
        for n, v in re.findall(r"பாடல் எண் : (\d+) (.*?) பொழிப்புரை", x):
            out[f"{key}:{n}"] = v
    (C / "tev_misc.json").write_text(json.dumps(out, ensure_ascii=False), encoding="utf-8")
    print("tev_misc", len(out), "verses")


if __name__ == "__main__":
    markandeya()
    purananuru()
    tevaram()
