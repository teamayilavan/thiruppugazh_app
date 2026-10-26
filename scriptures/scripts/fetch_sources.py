"""Download source texts for verse-level checking into a cache folder (default: ./.cache next to this file).

  python -I fetch_sources.py valmiki yuddha 108          # prose translation of one sarga
  python -I fetch_sources.py kamba  யுத்த_காண்டம் இராவணன்_வதைப்_படலம்   # one padalam, verses numbered

Valmiki text is from valmikiramayan.net (translation by Desiraju Hanumanta Rao, copyrighted):
used only for reading and for citing sarga/verse numbers; the cache is not committed (see .gitignore).
Kamba text is from Tamil Wikisource (public domain); verses are numbered per padalam.
"""
import html
import re
import sys
import urllib.parse
import urllib.request
from pathlib import Path

sys.stdout.reconfigure(encoding="utf-8")
CACHE = Path(__file__).resolve().parent / ".cache"
UA = {"User-Agent": "thiruppugazh-scriptures-research/1.0 (personal study)"}


def _get(url):
    req = urllib.request.Request(url, headers=UA)
    return urllib.request.urlopen(req, timeout=60).read()


def valmiki(kanda, sarga):
    """Return plain text of the prose page for kanda ('yuddha') and sarga (int)."""
    CACHE.mkdir(exist_ok=True)
    f = CACHE / f"valmiki_{kanda}_{sarga}.txt"
    if f.exists():
        return f.read_text(encoding="utf-8")
    url = f"https://www.valmikiramayan.net/utf8/{kanda}/sarga{sarga}/{kanda}_{sarga}_prose.htm"
    raw = _get(url).decode("utf-8", "ignore")
    t = re.sub(r"<[^>]+>", " ", raw)
    t = html.unescape(re.sub(r"\s+", " ", t))
    f.write_text(t, encoding="utf-8")
    return t


def kamba(kandam, padalam):
    """Return raw wikitext of one padalam (verse number follows each verse after a tab)."""
    CACHE.mkdir(exist_ok=True)
    f = CACHE / f"kamba_{kandam}_{padalam}.txt"
    if f.exists():
        return f.read_text(encoding="utf-8")
    title = urllib.parse.quote(f"கம்பராமாயணம்/{kandam}/{padalam}")
    url = f"https://ta.wikisource.org/w/index.php?title={title}&action=raw"
    t = _get(url).decode("utf-8")
    f.write_text(t, encoding="utf-8")
    return t


if __name__ == "__main__":
    a = sys.argv[1:]
    if a[0] == "valmiki":
        print(valmiki(a[1], int(a[2])))
    elif a[0] == "kamba":
        print(kamba(a[1], a[2]))


# kanda -> (directory, file prefix) on valmikiramayan.net
KANDA_PATH = {"bala": ("baala", "bala"), "kishkindha": ("kish", "kishkindha")}
DEV = str.maketrans("०१२३४५६७८९", "0123456789")


def valmiki_verses(kanda, sarga):
    """Return [(shloka_no, english_tail)] for a sarga, from the Sanskrit+word-for-word page.
    english_tail is the last ~400 chars of each verse block, which holds the prose rendering."""
    CACHE.mkdir(exist_ok=True)
    f = CACHE / f"valmiki_sans_{kanda}_{sarga}.txt"
    if f.exists():
        t = f.read_text(encoding="utf-8")
    else:
        d, f2 = KANDA_PATH.get(kanda, (kanda, kanda))
        url = f"https://www.valmikiramayan.net/utf8/{d}/sarga{sarga}/{f2}sans{sarga}.htm"
        raw = _get(url).decode("utf-8", "ignore")
        t = html.unescape(re.sub(r"\s+", " ", re.sub(r"<[^>]+>", " ", raw)))
        f.write_text(t, encoding="utf-8")
    out = []
    for blk in t.split("Verse Locator")[1:]:
        m = re.search(r"[०-९]+-[०-९]+-([०-९]+)", blk)
        if not m:
            continue
        n = int(m.group(1).translate(DEV))
        after = blk[m.end():]
        # prose follows the word-for-word list: take text after the last ';' meaning-run is unreliable,
        # so keep the tail of the block
        out.append((n, after.strip()[-450:]))
    return out
