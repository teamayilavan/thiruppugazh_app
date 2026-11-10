# -*- coding: utf-8 -*-
"""Offline audit of every story file in scriptures/*/stories: (1) each quoted lyric line exists in songs.lyrics_list for that song,
(2) the song headers name the right song, (3) the file's song count equals the STORIES.md count. Prints a summary and the exceptions."""
import json, re, sqlite3, sys, glob
from pathlib import Path
sys.stdout.reconfigure(encoding="utf-8")
ROOT = Path(__file__).resolve().parents[2]
SETS = ["vishnu", "shiva", "sambandar", "saints", "devi", "murugan", "ganesha", "tamil-lore"]
con = sqlite3.connect("file:" + str(ROOT / "assets" / "thiruppugazh.db") + "?mode=ro", uri=True)
DB = {}
for i, t, p, l in con.execute("select id,title,place,lyrics_list from songs"):
    try: lines = json.loads(l)
    except Exception: lines = (l or "").split("\n")
    DB[i] = (t, p, lines)
norm = lambda s: re.sub(r"[\s\.…*]", "", s)
tot = {"files": 0, "songs": 0, "quotes": 0}; bad_quote = []; bad_head = []; bad_count = []; empty = []
for st in SETS:
    idx = (ROOT / "scriptures" / st / "STORIES.md").read_text(encoding="utf-8")
    idxcount = {}
    for m in re.finditer(r"\|\s*([^|]+?)\s*\|\s*(\d+)\s*\|(?:[^|]*\|){1,2}\s*\[([^\]]+)\]\(stories/([^)]+)\.md\)", idx):
        idxcount[m.group(4)] = int(m.group(2))
    for f in sorted(glob.glob(str(ROOT / "scriptures" / st / "stories" / "*.md"))):
        slug = Path(f).stem; tot["files"] += 1
        txt = Path(f).read_text(encoding="utf-8")
        body = txt.split("## Songs", 1)[1] if "## Songs" in txt else ""
        blocks = re.split(r"\n### ", "\n" + body)[1:]
        n = 0
        for b in blocks:
            head, *rest = b.split("\n")
            m = re.match(r"(\d+)\s+(.*?)\s*\((.*)\)\s*$", head)
            if not m: bad_head.append((st, slug, head[:60])); continue
            sid = int(m.group(1)); n += 1; tot["songs"] += 1
            if sid not in DB: bad_head.append((st, slug, f"song {sid} not in DB")); continue
            t, p, lines = DB[sid]
            if norm(m.group(2)) != norm(t): bad_head.append((st, slug, f"{sid} title '{m.group(2)}' != DB '{t}'"))
            dbn = [norm(x) for x in lines]
            for q in rest:
                if q.startswith("> ") and not q.startswith("> (no Tamil"):
                    line = q[2:].replace("**", "").strip(); tot["quotes"] += 1
                    ql = norm(line)
                    if not ql: continue
                    if not any(ql == d or ql in d for d in dbn):
                        bad_quote.append((st, slug, sid, line[:50]))
        ic = idxcount.get(slug)
        if st in ("vishnu", "shiva"):
            if ic is not None and ic != n: bad_count.append((st, slug, f"index {ic} vs file {n}"))
        else:
            if ic is not None and ic != n: bad_count.append((st, slug, f"index {ic} vs file {n}"))
        if n == 0: empty.append((st, slug))
print("story files:", tot["files"], "| song entries:", tot["songs"], "| quoted lines checked:", tot["quotes"])
print("quotes not found in DB lyrics:", len(bad_quote)); [print("  ", x) for x in bad_quote[:25]]
print("bad headers/titles:", len(bad_head)); [print("  ", x) for x in bad_head[:25]]
print("count mismatches:", len(bad_count)); [print("  ", x) for x in bad_count[:25]]
print("stories with 0 songs:", empty)
checked = sum(1 for st in SETS for _ in [0])

