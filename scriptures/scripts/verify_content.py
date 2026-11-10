# -*- coding: utf-8 -*-
"""Content-level check: does the cited passage actually support the claim?  Stage 1: Valmiki and Bhagavata references.
For each reference, the cited verse range is extracted (English translation in the caches) and compared with the gist and story title:
score = share of the gist's key words found in the passage. Low scores are printed with the passage for reading."""
import json, re, sys, os
from pathlib import Path
SC = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(SC / "scripts"))
sys.stdout.reconfigure(encoding="utf-8")
from fetch_sources import valmiki_verses
import fetch_krishna as FK
STOP = set("the a an and of to in on at by for with from is are was were be been his her their its it as that this these those who whom which when then than but or not no into over under after before while where he she they them him up out off also only more most such one two three four five six very much many each other same said says tells told called named".split())
def keys(*texts):
    out = set()
    for t in texts:
        for w in re.findall(r"[A-Za-z]{4,}", t or ""):
            w = w.lower()
            if w not in STOP: out.add(w)
    return out
def score(passage, kw):
    p = passage.lower()
    hit = [k for k in kw if k[:5] in p]
    return len(hit) / max(1, len(kw)), hit
KANDA = {"bala": "bala", "ayodhya": "ayodhya", "aranya": "aranya", "kishkindha": "kishkindha", "sundara": "sundara", "yuddha": "yuddha"}
KN = {1: "bala", 2: "ayodhya", 3: "aranya", 4: "kishkindha", 5: "sundara", 6: "yuddha"}
_vc = {}
def val(k, s):
    if (k, s) not in _vc: _vc[(k, s)] = valmiki_verses(k, s)
    return _vc[(k, s)]
_sc = {}
def sbv(c, ch):
    if (c, ch) not in _sc: _sc[(c, ch)] = FK.sb(str(c), str(ch))
    return _sc[(c, ch)]
def rng(a, b): return range(int(a), int(b or a) + 1)
rows = []
for d in ("vishnu", "shiva"):
    m = json.loads((SC / d / "master.json").read_text(encoding="utf-8"))
    for sid, s in m["stories"].items():
        if not s.get("songs"): continue
        for r in s.get("refs") or []:
            src, ref, gist = r.get("src") or "", r.get("ref") or "", r.get("gist") or ""
            texts = []
            try:
                if src.startswith("Valmiki"):
                    for mm in re.finditer(r"(Bala|Ayodhya|Aranya|Kishkindha|Sundara|Yuddha)\s+(\d+)(?:\.(\d+)(?:\s*[–-]\s*(\d+))?)?|Ramayana\s+(\d)\.(\d+)\.(\d+)(?:\s*[–-]\s*(\d+))?", ref):
                        if mm.group(1): k, sg, v1, v2 = mm.group(1).lower(), int(mm.group(2)), mm.group(3), mm.group(4)
                        else: k, sg, v1, v2 = KN[int(mm.group(5))], int(mm.group(6)), mm.group(7), mm.group(8)
                        vs = val(k, sg)
                        want = set(rng(v1, v2)) if v1 else None
                        texts += [t for n, t in vs if (want is None or int(n) in want)]
                elif src.startswith("Bhagavata"):
                    for mm in re.finditer(r"(\d+)\.(\d+)\.(\d+)(?:\s*[–-]\s*(\d+))?", ref):
                        c, ch, v1, v2 = mm.groups()
                        want = set(rng(v1, v2))
                        for n, t in sbv(c, ch):
                            nums = [int(x) for x in re.findall(r"\d+", n)]
                            if nums and (want & set(range(nums[0], nums[-1] + 1))): texts.append(t)
            except Exception as e:
                rows.append((d, sid, src, ref, -1, f"ERR {e}", "")); continue
            if not (src.startswith("Valmiki") or src.startswith("Bhagavata")): continue
            kw = keys(gist, s.get("title"))
            sc, hit = score(" ".join(texts), kw)
            nverse = len(texts)
            rows.append((d, sid, src[:9], ref[:36], round(sc, 2), gist[:90], (" ".join(texts)[:(900 if os.environ.get("FULL") else 260)]) if texts else "NO TEXT EXTRACTED", nverse))
LO, HI = float(os.environ.get("LO", 0)), float(os.environ.get("HI", 0.3))
rows.sort(key=lambda x: x[4])
import statistics
print("refs scored:", len(rows), "| median score", statistics.median(r[4] for r in rows), "| below 0.3:", sum(1 for r in rows if r[4] < 0.3))
for r in rows:
    if LO <= r[4] < HI: print(f"\n[{r[4]}] {r[0]} {r[1]} | {r[2]} {r[3]}\n   GIST: {r[5]}\n   TEXT: {r[6]}")
