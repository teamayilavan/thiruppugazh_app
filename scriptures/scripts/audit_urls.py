# -*- coding: utf-8 -*-
"""Collects every reference URL used by the eight story sets and writes scripts/.cache/audit/urls.txt (one per line)."""
import json, re, sys, hashlib
from pathlib import Path
sys.stdout.reconfigure(encoding="utf-8")
ROOT = Path(__file__).resolve().parents[2]
SC = ROOT / "scriptures"
urls = set()
for d in ("shiva", "vishnu"):
    m = json.loads((SC / d / "master.json").read_text(encoding="utf-8"))
    for s in m["stories"].values():
        if not s.get("songs"): continue
        for k in ("refs", "dp"):
            for r in s.get(k) or []:
                if r.get("url"): urls.add(r["url"])
for d in ("sambandar", "saints", "devi", "murugan", "ganesha", "tamil-lore"):
    for f in (SC / d / "stories").glob("*.md"):
        for m in re.finditer(r"\[(https?://[^\]\s]+)\]", f.read_text(encoding="utf-8")):
            urls.add(m.group(1))
out = SC / "scripts" / ".cache" / "audit"
out.mkdir(parents=True, exist_ok=True)
(out / "urls.txt").write_text("\n".join(sorted(urls)) + "\n", encoding="utf-8")
print(len(urls), "unique URLs")
