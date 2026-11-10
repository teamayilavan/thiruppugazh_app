# -*- coding: utf-8 -*-
"""Do the reference numbers agree with the URLs? koyil.org slugs (periyazhwar-thirumozhi-2-10-6) vs 'ref' (2.10.6);
thevaaram.org Song_idField vs 'pathigam T.P'. Prints every disagreement."""
import json, re, sys
from pathlib import Path
sys.stdout.reconfigure(encoding="utf-8")
SC = Path(__file__).resolve().parents[1]
bad = []; n = 0
for d in ("shiva", "vishnu"):
    m = json.loads((SC / d / "master.json").read_text(encoding="utf-8"))
    for sid, s in m["stories"].items():
        if not s.get("songs"): continue
        for r in s.get("dp") or []:
            u = r.get("url") or ""; ref = r.get("ref") or ""
            if "koyil.org" in u:
                slug = u.rstrip("/").split("/")[-1]
                nums = [str(int(x)) for x in re.findall(r"\d+", slug)]; rn = [str(int(x)) for x in re.findall(r"\d+", ref.split(" ")[0] if ref else "")]
                n += 1
                if nums[:len(rn)] != rn or not rn: bad.append((d, sid, r.get("prabandham"), "ref " + ref, "slug " + slug))
            elif "thevaaram.org" in u:
                mm = re.search(r"Song_idField=(\d+)", u); pm = re.search(r"pathigam\s+(\d+)\.(\d+)", ref)
                if mm and pm:
                    n += 1
                    t, p = int(pm.group(1)), int(pm.group(2))
                    if t <= 7 and int(mm.group(1)) != t * 1000 + p: bad.append((d, sid, r.get("prabandham"), ref[:60], u[-40:]))
print("checked", n, "| disagreements", len(bad))
for b in bad: print(" ", b)
