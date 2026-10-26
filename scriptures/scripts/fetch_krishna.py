"""Source lookups for Bhagavata Purana and the Mahabharata (Critical Edition, BORI text via GRETIL).

  python -I fetch_krishna.py sb 10 10 [kw1,kw2]     # Bhagavata canto chapter; lists 'Text N' translations (filtered)
  python -I fetch_krishna.py mbh 7 146 [kw1,kw2]    # Mahabharata parva adhyaya; Sanskrit lines (IAST), filtered

Bhagavata text is the vedabase.io chapter page (translation is copyrighted; used for reading and for citing verse
numbers only). Mahabharata numbers are Critical Edition numbers: parva,adhyaya.shloka (e.g. 7,146.001). The
Vulgate/Ganguli section numbers differ.
Both caches go to scripts/.cache (git-ignored).
"""
import html
import os
import re
import sys
import urllib.request
from pathlib import Path

sys.stdout.reconfigure(encoding="utf-8")
CACHE = Path(__file__).resolve().parent / ".cache"
UA = {"User-Agent": "Mozilla/5.0 (thiruppugazh-scriptures-research)"}


def _get(url, timeout=120):
    return urllib.request.urlopen(urllib.request.Request(url, headers=UA), timeout=timeout).read().decode("utf-8", "ignore")


def sb(canto, chapter):
    """Return [(label, translation)] for a Bhagavata chapter, e.g. ('2-3', '...')."""
    CACHE.mkdir(exist_ok=True)
    f = CACHE / f"sb_{canto}_{chapter}.txt"
    if f.exists():
        t = f.read_text(encoding="utf-8")
    else:
        raw = _get(f"https://vedabase.io/en/library/sb/{canto}/{chapter}/")
        t = html.unescape(re.sub(r"\s+", " ", re.sub(r"<[^>]+>", " ", raw)))
        f.write_text(t, encoding="utf-8")
    parts = re.split(r"\bTexts? (\d+(?:[-–]\d+)?) : ", t)
    out = []
    for i in range(1, len(parts) - 1, 2):
        out.append((parts[i], parts[i + 1][:700]))
    return out


MBH_FILES = {1: 1, 2: 2, 3: 3, 4: 4, 5: 5, 6: 6, 7: 7, 8: 8, 9: 9, 10: 10, 11: 11, 12: 12, 13: 13, 14: 14, 15: 15, 16: 16, 17: 17, 18: 18}


def mbh_lines(parva):
    """Return list of (adhyaya, 'ref', text) for every line of the parva; ref like '7,146.001a'."""
    CACHE.mkdir(exist_ok=True)
    f = CACHE / f"mbh_{parva:02d}.html"
    if not f.exists():
        url = f"http://gretil.sub.uni-goettingen.de/gretil/1_sanskr/2_epic/mbh/mbh_{parva:02d}_u.htm"
        f.write_text(_get(url, 300), encoding="utf-8")
    raw = f.read_text(encoding="utf-8")
    t = html.unescape(re.sub(r"<br\s*/?>", "\n", raw, flags=re.I))
    t = re.sub(r"<[^>]+>", "", t)
    out = []
    for ln in t.splitlines():
        m = re.match(r"^0*(\d+),(\d+)\.(\d+)([a-z]?)(\*?\d*_?\d*)\t(.*)$", ln)
        if m:
            out.append((int(m.group(2)), f"{int(m.group(1))},{m.group(2)}.{m.group(3)}{m.group(4)}{m.group(5)}", m.group(6).strip()))
    return out


if __name__ == "__main__":
    a = sys.argv[1:]
    if a[0] == "sb":
        kws = [k.lower() for k in a[3].split(",")] if len(a) > 3 else []
        for lab, tr in sb(a[1], a[2]):
            if not kws or any(k in tr.lower() for k in kws):
                print(f"SB {a[1]}.{a[2]}.{lab}: {tr[:260]}")
    elif a[0] == "mbh":
        kws = [k.lower() for k in a[3].split(",")] if len(a) > 3 else []
        for adh, ref, tx in mbh_lines(int(a[1])):
            if adh == int(a[2]) and (not kws or any(k in tx.lower() for k in kws)):
                print(ref, tx)
