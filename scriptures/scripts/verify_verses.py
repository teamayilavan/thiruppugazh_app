# -*- coding: utf-8 -*-
"""Stage 3: Tamil Shaiva references (Shiva set): are the cited opening words in the cited verse NUMBER (not just on the page)?
thevaaram.org pages list verses with class="heading">N</span> ... class="Padal"; Tamil Wikisource pages (Kanda Puranam) are checked elsewhere."""
import json, re, sys, hashlib, html, collections
from pathlib import Path
sys.stdout.reconfigure(encoding="utf-8")
SC = Path(__file__).resolve().parents[1]; CA = SC / "scripts" / ".cache" / "audit"
def raw(u):
    f = CA / (hashlib.sha1(u.encode()).hexdigest()[:16] + ".html")
    return f.read_text(encoding="utf-8", errors="replace") if f.exists() else None
tam = lambda s: re.sub(r"[\s\.…,;:!?'\"()\[\]\-]", "", s)
def verses(u):
    t = raw(u); out = {}
    if t is None: return out
    for m in re.finditer(r'class="heading">\s*(\d+)\s*</span></h3>\s*<div[^>]*class="Padal">(.*?)</div>', t, re.S):
        out.setdefault(int(m.group(1)), tam(html.unescape(re.sub(r"<[^>]+>", "", re.sub(r"<br\s*/?>", " ", m.group(2))))))
    return out
res = collections.Counter(); bad = []
m = json.loads((SC / "shiva" / "master.json").read_text(encoding="utf-8"))
for sid, s in m["stories"].items():
    for r in s.get("dp") or []:
        u = r.get("url") or ""; first = r.get("first") or ""; ref = r.get("ref") or ""
        if "thevaaram.org" not in u or not first:
            res["not applicable (no thevaaram url or no first words)"] += 1; continue
        vn = re.search(r"verse\s+(\d+)", ref)
        vs = verses(u)
        if not vs: res["page has no parsable verses"] += 1; bad.append((sid, r["prabandham"][:22], ref[:50], "no verses parsed")); continue
        if not vn:
            ok = any(tam(first) in v for v in vs.values()); res["whole-pathigam ok (no verse number given)" if ok else "NOT FOUND (no verse number)"] += 1
            if not ok: bad.append((sid, r["prabandham"][:22], ref[:50], first[:30])); continue
            continue
        n = int(vn.group(1)); v = vs.get(n)
        if v is None: res["verse number not on page"] += 1; bad.append((sid, r["prabandham"][:22], ref[:50], f"verse {n} missing (page has {max(vs)})")); continue
        if tam(first) in v: res["ok: in the cited verse"] += 1
        else:
            where = [k for k, x in vs.items() if tam(first) in x]
            res["words found in a DIFFERENT verse" if where else "words not in any verse"] += 1
            bad.append((sid, r["prabandham"][:22], ref[:55], f"cited verse {n}; first words '{first[:24]}' found in verse {where}"))
print(dict(res))
for b in bad: print(" ", b)
