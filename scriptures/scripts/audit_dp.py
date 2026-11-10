# -*- coding: utf-8 -*-
"""For each Tamil devotional reference ('dp') of the Shiva and Vishnu sets: does the cached page contain the cited opening words?"""
import json, re, sys, hashlib, html, collections
from pathlib import Path
sys.stdout.reconfigure(encoding="utf-8")
ROOT = Path(__file__).resolve().parents[2]; SC = ROOT / "scriptures"; CA = SC / "scripts" / ".cache" / "audit"
def page(u):
    f = CA / (hashlib.sha1(u.encode()).hexdigest()[:16] + ".html")
    if not f.exists(): return None
    t = f.read_text(encoding="utf-8", errors="replace")
    t = re.sub(r"<script.*?</script>|<style.*?</style>", " ", t, flags=re.S)
    return html.unescape(re.sub(r"<[^>]+>", " ", t))
def lat(s): return re.sub(r"[^a-z0-9]", "", s.lower().replace("ā","a").replace("ī","i").replace("ū","u"))
def tam(s): return re.sub(r"[\s\.…,;:!?'\"()\[\]\-]", "", s)
TAM = {}
for ch, c in {"க":"K","ங":"N","ச":"S","ஞ":"N","ட":"T","ண":"N","த":"T","ந":"N","ப":"P","ம":"M","ய":"Y","ர":"R","ல":"L","வ":"V","ழ":"L","ள":"L","ற":"R","ன":"N","ஜ":"S","ஷ":"S","ஸ":"S","ஹ":"H","ஶ":"S"}.items(): TAM[ch] = c
def skel_tamil(s):
    out = [TAM[c] for c in s if c in TAM]
    return re.sub(r"(.)+", r"", "".join(out))
def skel_latin(s):
    s = s.lower()
    for a, b in (("zh", "L"), ("th", "T"), ("dh", "T"), ("ch", "S"), ("sh", "S"), ("kh", "K"), ("gh", "K"), ("bh", "P")):
        s = s.replace(a, b.lower() if False else b)
    m = {"k":"K","g":"K","c":"S","s":"S","j":"S","t":"T","d":"T","n":"N","p":"P","b":"P","m":"M","y":"Y","r":"R","l":"L","v":"V","w":"V","h":"H","K":"K","T":"T","N":"N","P":"P","S":"S","L":"L"}
    out = [m[c] for c in s if c in m]
    return re.sub(r"(.)+", r"", "".join(out))
def region(p):
    i = p.find("pAsuram")
    return p[i:i + 4500] if i >= 0 else p[:6000]
res = collections.Counter(); fails = []; weak = []
for d in ("shiva", "vishnu"):
    m = json.loads((SC / d / "master.json").read_text(encoding="utf-8"))
    for sid, s in m["stories"].items():
        if not s.get("songs"): continue
        for r in s.get("dp") or []:
            u = r.get("url"); first = r.get("first", "")
            if not u: res[(d, "no url")] += 1; fails.append((d, sid, r.get("prabandham"), r.get("ref", "")[:40], "NO URL", r.get("confirmed"))); continue
            p = page(u)
            if p is None: res[(d, "page missing")] += 1; continue
            if not first: res[(d, "no first-words")] += 1; continue
            how = "script"
            if re.search(r"[஀-௿]", first):
                tpart = re.split(r"\(", first)[-1] if "(" in first and re.search(r"[஀-௿]", first.split("(")[-1]) else first
                ok = tam(tpart) in tam(p)
                if not ok:
                    sk = skel_tamil(tpart); how = "skeleton"
                    ok = bool(sk) and sk in skel_latin(region(p))
                    if not ok and sk:
                        ok = sk in skel_latin(p); how = "skeleton-wholepage"
                    if ok and len(sk) < 7: how = "skeleton-weak"
            else:
                ok = lat(first) in lat(p)
            res[(d, ("ok:" + how) if ok else "NOT FOUND")] += 1
            if ok and how == "skeleton-weak": weak.append((d, sid, r.get("ref"), first[:30]))
            if not ok: fails.append((d, sid, r.get("prabandham"), r.get("ref", "")[:50], first[:40], r.get("confirmed")))
print(dict(res))
for f in fails: print(" ", f)
print("weak (short skeleton) matches:", len(weak)); [print("  ", w) for w in weak]
