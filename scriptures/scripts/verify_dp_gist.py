# -*- coding: utf-8 -*-
"""Stage 4: Vishnu Tamil references: does the English meaning/commentary on the cited koyil.org page support the gist?"""
import json, re, sys, hashlib, html, os
from pathlib import Path
sys.stdout.reconfigure(encoding="utf-8")
SC = Path(__file__).resolve().parents[1]; CA = SC / "scripts" / ".cache" / "audit"
STOP = set("the a an and of to in on at by for with from is are was were be been his her their its it as that this these those who whom which when then than but or not no into over under after before while where he she they them him up out off also only more most such one two three four five six very much many each other same said says tells told called named alvar azhwar sings speaks recalls describes mentions".split())
def text(u):
    f = CA / (hashlib.sha1(u.encode()).hexdigest()[:16] + ".html")
    t = f.read_text(encoding="utf-8", errors="replace")
    t = re.sub(r"<script.*?</script>|<style.*?</style>", " ", t, flags=re.S)
    return re.sub(r"\s+", " ", html.unescape(re.sub(r"<[^>]+>", " ", t))).lower()
m = json.loads((SC / "vishnu" / "master.json").read_text(encoding="utf-8"))
rows = []
for sid, s in m["stories"].items():
    if not s.get("songs"): continue
    for r in s.get("dp") or []:
        u = r.get("url") or ""
        if "koyil.org" not in u: continue
        p = text(u); gist = r.get("gist") or ""
        kw = {w.lower() for w in re.findall(r"[A-Za-z]{4,}", gist) if w.lower() not in STOP}
        hit = [k for k in kw if k[:5] in p]
        rows.append((len(hit) / max(1, len(kw)), sid, r["prabandham"][:22], r["ref"], gist[:110], sorted(kw - set(hit))[:7]))
rows.sort()
LO, HI = float(os.environ.get("LO", 0)), float(os.environ.get("HI", 0.45))
print("scored", len(rows), "| below 0.45:", sum(1 for r in rows if r[0] < 0.45))
for sc, sid, pr, ref, gist, miss in rows:
    if LO <= sc < HI: print(f"[{sc:.2f}] {sid} | {pr} {ref}\n    GIST: {gist}\n    missing: {miss}")
