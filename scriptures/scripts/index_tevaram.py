"""Index Tevaram pathigams (Tirumurai 1-7) on thevaaram.org: place title and verse texts, into .cache/tev_index.json.

  python -I -X utf8 scriptures/scripts/index_tevaram.py

Polite: one request at a time with a short pause. Resumable (skips ids already in the cache).
Key: "<thirumurai>.<pathigam>" -> {"title": place/pann line, "verses": {"1": text, ...}}
The ids follow thevaaram.org: Song_idField = thirumurai*1000 + pathigam.
"""
import html
import json
import re
import sys
import time
import urllib.request
from pathlib import Path

sys.stdout.reconfigure(encoding="utf-8")
F = Path(__file__).resolve().parent / ".cache" / "tev_index.json"
UA = {"User-Agent": "thiruppugazh-scriptures-research/1.0 (personal study)"}
COUNTS = {4: 113, 7: 100, 5: 100, 6: 99, 1: 136, 2: 122, 3: 103}

def fetch(t, p):
    url = f"https://thevaaram.org/thirumurai_1/onepage.php?thiru={t}&Song_idField={t * 1000 + p}"
    raw = urllib.request.urlopen(urllib.request.Request(url, headers=UA), timeout=60).read().decode("utf-8", "replace")
    x = re.sub(r"\s+", " ", html.unescape(re.sub(r"<[^>]+>", " ", re.sub(r"<script.*?</script>|<style.*?</style>", "", raw, flags=re.S))))
    m = re.search(r"பின் செல்க (.*?) பண் ?:", x)
    title = m.group(1).strip() if m else ""
    verses = {n: v.strip() for n, v in re.findall(r"பாடல் எண் : (\d+) (.*?) பொழிப்புரை", x)}
    return {"title": title, "verses": verses}

if __name__ == "__main__":
    d = json.loads(F.read_text(encoding="utf-8")) if F.exists() else {}
    for t, n in COUNTS.items():
        for p in range(1, n + 1):
            k = f"{t}.{p}"
            if k in d:
                continue
            for attempt in range(4):
                try:
                    d[k] = fetch(t, p)
                    break
                except Exception as e:
                    print("retry", k, attempt, e, flush=True)
                    time.sleep(5 * (attempt + 1))
            else:
                continue
            if p % 10 == 0:
                F.write_text(json.dumps(d, ensure_ascii=False), encoding="utf-8")
                print(k, d[k]["title"], flush=True)
            time.sleep(0.15)
    F.write_text(json.dumps(d, ensure_ascii=False), encoding="utf-8")
    print("done", len(d))
