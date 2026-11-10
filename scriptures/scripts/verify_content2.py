# -*- coding: utf-8 -*-
"""Stage 2: wisdomlib chapter references (Linga, Shiva, Skanda Purana, Ramayana Uttara): gist words versus the chapter text."""
import json, re, sys, hashlib, html
from pathlib import Path
SC = Path(__file__).resolve().parents[1]; CA = SC / "scripts" / ".cache" / "audit"
sys.stdout.reconfigure(encoding="utf-8")
STOP = set("the a an and of to in on at by for with from is are was were be been his her their its it as that this these those who whom which when then than but or not no into over under after before while where he she they them him up out off also only more most such one two three four five six very much many each other same said says tells told called named allusion passing statement".split())
def text(u):
    f = CA / (hashlib.sha1(u.encode()).hexdigest()[:16] + ".html")
    t = f.read_text(encoding="utf-8", errors="replace")
    t = re.sub(r"<script.*?</script>|<style.*?</style>", " ", t, flags=re.S)
    return re.sub(r"\s+", " ", html.unescape(re.sub(r"<[^>]+>", " ", t)))
rows = []
for d in ("shiva", "vishnu"):
    m = json.loads((SC / d / "master.json").read_text(encoding="utf-8"))
    for sid, s in m["stories"].items():
        if not s.get("songs"): continue
        for r in s.get("refs") or []:
            u = r.get("url") or ""
            if "wisdomlib" not in u: continue
            p = text(u).lower(); gist = r.get("gist") or ""
            kw = {w.lower() for w in re.findall(r"[A-Za-z]{4,}", gist + " " + (s.get("title") or "")) if w.lower() not in STOP}
            hit = sorted(k for k in kw if k[:5] in p)
            miss = sorted(kw - set(hit))
            rows.append((len(hit) / max(1, len(kw)), d, sid, r["src"][:12], r["ref"][:48], gist[:100], miss[:8], len(p)))
rows.sort()
for sc, d, sid, src, ref, gist, miss, n in rows:
    print(f"[{sc:.2f}] {d} {sid} | {src} {ref} | len {n}\n    GIST: {gist}\n    missing words: {miss}")
