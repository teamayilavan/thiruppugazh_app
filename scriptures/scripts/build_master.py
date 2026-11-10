"""Join every source into one master: stories (episodes) x songs x references, then write
vishnu/master.json, vishnu/STORIES.md, vishnu/by-song.md, vishnu/stories/<domain>-<episode>.md and the reading PDF.

Inputs (all generated or hand-written elsewhere in scriptures/):
  ramayana_episodes.py, krishna_episodes.py, avatar_episodes.py   episode catalogues + song assignments
  story_data.py                                                   story briefs
  <deity>/dp/*.json                                               Tamil devotional verses (research passes)
  <deity>/shortlist.json, assets/thiruppugazh.db                  the songs and their lines
  <deity>/song-story-map.txt                                      first-pass map (for songs with no episode)
  deity_<name>.py                                                 per-deity configuration (see deity_vishnu.py)
Run:  python -I scriptures/scripts/build_master.py [--deity vishnu] [--no-pdf]
The PDF needs Microsoft Edge (headless print) and the Nirmala UI font for Tamil.
"""
import html
import importlib
import json
import os
import sqlite3
import subprocess
import sys
from collections import defaultdict
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
sys.stdout.reconfigure(encoding="utf-8")

DEITY = sys.argv[sys.argv.index("--deity") + 1] if "--deity" in sys.argv else "vishnu"
D = importlib.import_module(f"deity_{DEITY}")  # scripts/deity_<name>.py: see deity_vishnu.py for the required names

ROOT = HERE.parent.parent
V = ROOT / "scriptures" / D.FOLDER
DB = ROOT / "assets" / "thiruppugazh.db"
DOMAIN_NAME = D.DOMAIN_NAME
DOMAIN_ORDER = [d for d, _ in D.DOMAINS]
STORY = D.STORY


# ---- unified episodes
U = {}
for domain, M in D.DOMAINS:
    for eid, e in M.E.items():
        uid = f"{domain}-{eid}"
        sd = STORY.get(D.slug_for(domain, eid))
        U[uid] = dict(id=uid, domain=domain, eid=eid, title=e["title"], brief=(getattr(D, "BRIEF_BY_EPISODE", {}).get(uid) or (sd or {}).get("brief", "")),
                      note=e.get("note", ""), refs=D.build_refs(domain, e), dp=D.dp_for(domain, eid), songs={})
    for sid, v in M.A_.items():
        for eid in v["eps"]:
            U[f"{domain}-{eid}"]["songs"][sid] = dict(conf=v["conf"], note=v["note"])

# ---- songs
hits = D.load_hits() if hasattr(D, "load_hits") else {str(h["song"]): h for h in json.loads((V / "shortlist.json").read_text(encoding="utf-8"))}
con = sqlite3.connect(f"file:{DB.as_posix()}?mode=ro", uri=True)


def song_lines(sid):
    h = hits[sid]
    ll = json.loads(con.execute("select lyrics_list from songs where id=?", (sid,)).fetchone()[0])
    i = h["line_no"] - 1
    return ll[max(0, i - 3): i], ll[i]


song_eps = defaultdict(list)
for uid, u in U.items():
    for sid, m in u["songs"].items():
        song_eps[sid].append((uid, m))
smap = {}
for line in (V / "song-story-map.txt").read_text(encoding="utf-8").splitlines():
    if line.strip() and not line.startswith("#"):
        sid, slugs, note, conf = line.split("|")
        smap[sid] = (slugs.split(","), note, conf)
no_story = sorted((s for s in hits if s not in song_eps), key=int)


def has_primary(u):
    return any(r["src"] != D.TAMIL_SOURCE and r.get("pinned") for r in u["refs"])


def has_dp(u):
    return any(d["confirmed"] for d in u["dp"])


live = {k: u for k, u in U.items() if u["songs"]}
n_both = sum(1 for u in live.values() if has_primary(u) and has_dp(u))
n_prim = sum(1 for u in live.values() if has_primary(u))
n_dp = sum(1 for u in live.values() if has_dp(u))
stats = dict(episodes_defined=len(U), stories_with_songs=len(live), with_primary_text=n_prim, with_confirmed_dp=n_dp,
             with_both=n_both, only_primary=sum(1 for u in live.values() if has_primary(u) and not has_dp(u)),
             only_dp=sum(1 for u in live.values() if has_dp(u) and not has_primary(u)),
             neither=sum(1 for u in live.values() if not has_primary(u) and not has_dp(u)),
             songs_total=len(hits), songs_with_story=len(song_eps), songs_without_story=len(no_story))
(V / "master.json").write_text(json.dumps(dict(stats=stats, stories=U, songs={s: [uid for uid, _ in song_eps[s]] for s in song_eps}),
                                          ensure_ascii=False, indent=1), encoding="utf-8")

# ---- markdown outputs
OLD = V / "stories"
OLD.mkdir(exist_ok=True)
for f in OLD.glob("*.md"):
    f.unlink()


def status(u):
    return ("primary text" if has_primary(u) else "no primary text") + " + " + (D.TAMIL_SOURCE if has_dp(u) else "no confirmed DP")


for uid, u in U.items():
    if not u["songs"]:
        continue
    o = [f"# {u['title']}", "", f"`{uid}` | {DOMAIN_NAME[u['domain']]} | {len(u['songs'])} songs | {status(u)}", ""]
    if u["brief"]:
        o += [u["brief"], ""]
    o += ["## References", "", "| Source | Reference | What it says / quote |", "|---|---|---|"]
    for r in u["refs"]:
        txt = r.get("gist", "") or ""
        if r.get("quote"):
            txt = (txt + " — " if txt else "") + "“" + r["quote"].replace("|", "/") + "”"
        o.append(f"| {r['src']} | {r['ref']} | {txt} |")
    for d in u["dp"]:
        o.append(f"| {D.TAMIL_SOURCE}{'' if d['confirmed'] else ' (candidate)'} | {d['prabandham']} {d['ref']} | {d['first']} — {d['gist']} [{d['url']}] |")
    if u["note"]:
        o += ["", f"Note: {u['note']}"]
    o += ["", "## Songs", ""]
    for sid in sorted(u["songs"], key=int):
        h = hits[sid]
        pre, line = song_lines(sid)
        m = u["songs"][sid]
        o += [f"### {sid} {h['title']} ({h['place'] or ''})", ""] + [f"> {x}" for x in pre] + [f"> **{line}**", "",
              f"Confidence {m['conf']}" + (f" — {m['note']}" if m["note"] else ""), ""]
    (OLD / f"{uid}.md").write_text("\n".join(o), encoding="utf-8")

idx = ["# Stories index", "", "Generated by `scripts/build_master.py`. Source of truth: the episode catalogues, `story_data.py`, `song-story-map.txt` and `dp/*.json`.", "",
       f"- Stories (episodes) with at least one song: **{stats['stories_with_songs']}**",
       f"- With a pinned reference in a primary text (Valmiki, Kamba, Mahabharata, Bhagavata, Vishnu Purana): **{n_prim}**",
       f"- With at least one confirmed {D.TAMIL_SOURCE} verse: **{n_dp}**",
       f"- With both: **{n_both}**; primary only: {stats['only_primary']}; {D.TAMIL_SOURCE} only: {stats['only_dp']}; neither: {stats['neither']}",
       f"- Songs: {stats['songs_total']} total, {stats['songs_with_story']} assigned to a story, {stats['songs_without_story']} with no identified story", ""]
for dom in DOMAIN_ORDER:
    idx += [f"## {DOMAIN_NAME[dom]}", "", "| Story | Songs | Primary refs | DP | File |", "|---|---|---|---|---|"]
    for uid, u in sorted(live.items(), key=lambda kv: -len(kv[1]["songs"])):
        if u["domain"] != dom:
            continue
        npr = sum(1 for r in u["refs"] if r.get("pinned"))
        idx.append(f"| {u['title']} | {len(u['songs'])} | {npr} | {sum(1 for d in u['dp'] if d['confirmed'])} | [{uid}](stories/{uid}.md) |")
    idx.append("")
(V / "STORIES.md").write_text("\n".join(idx) + "\n", encoding="utf-8")

bs = ["# By song", "", "One row per song: stories and their primary references. Generated.", "",
      "| Song | Title | Stories |", "|---|---|---|"]
for sid in sorted(hits, key=int):
    st = "; ".join(f"[{U[uid]['title']}](stories/{uid}.md)" for uid, _ in song_eps.get(sid, [])) or "_no identified story_ (" + ", ".join(smap.get(sid, (['?'],))[0]) + ")"
    bs.append(f"| {sid} | {hits[sid]['title']} | {st} |")
(V / "by-song.md").write_text("\n".join(bs) + "\n", encoding="utf-8")
print(json.dumps(stats, ensure_ascii=False))

if "--no-pdf" in sys.argv:
    sys.exit(0)

# ---- PDF (HTML -> Edge headless)
esc = html.escape


def ref_rows(u, with_quote, links=True):
    rows = []
    for r in u["refs"]:
        t = esc(r.get("gist", "") or "")
        if with_quote and r.get("quote"):
            t += (" " if t else "") + f"<span class=q>“{esc(r['quote'])}”</span>"
        rows.append(f"<tr><td class=s>{esc(r['src'])}</td><td class=r>{esc(r['ref'])}</td><td>{t}</td></tr>")
    for d in u["dp"]:
        tag = "" if d["confirmed"] else " (candidate)"
        url = f" <a href='{esc(d['url'])}'>link</a>" if d["url"] and links else ""
        rows.append(f"<tr><td class=s>{esc(D.TAMIL_SOURCE)}{tag}</td><td class=r>{esc(d['prabandham'])} {esc(d['ref'])}</td>"
                    f"<td><span class=ta>{esc(d['first'])}</span> {esc(d['gist'])}{url}</td></tr>")
    return "".join(rows)


css = """
@page { size: A4; margin: 16mm 14mm 16mm 14mm; @bottom-center { content: counter(page); font: 8pt 'Segoe UI'; color:#666 } }
body { font: 9pt/1.35 'Segoe UI','Noto Sans','Nirmala UI',sans-serif; color:#111 }
h1 { font-size:20pt; margin:0 0 4pt } h2 { font-size:13pt; margin:14pt 0 4pt; border-bottom:1px solid #999 }
h3 { font-size:10.5pt; margin:0 0 3pt }
.song { border:1px solid #bbb; border-radius:4px; padding:6pt 8pt; margin:0 0 8pt }
tr { break-inside:avoid } td { font-size:8.5pt }
.verse { font: 10pt/1.5 'Nirmala UI','Noto Sans Tamil',sans-serif; background:#f6f1e6; padding:4pt 6pt; border-left:3px solid #a67c1a; margin:3pt 0 }
.verse b { color:#8a1c1c }
.ep { margin:5pt 0 1pt; font-weight:600 } .brief { color:#333; margin:0 0 2pt }
table { border-collapse:collapse; width:100%; margin:2pt 0 4pt } td { border:1px solid #ddd; padding:1.5pt 4pt; vertical-align:top }
td.s { width:19%; color:#445 } td.r { width:23%; font-family:Consolas,monospace; font-size:8pt }
.q { font: 8.5pt 'Nirmala UI','Noto Sans',serif; color:#333 } .ta { font-family:'Nirmala UI'; color:#133 }
.meta { color:#555; font-size:8pt } .toc a { color:#1a3d7c; text-decoration:none } .toc li { margin:1pt 0 }
.pb { break-before:page } .low { color:#a33 }
"""
parts = [f"<!doctype html><html><head><meta charset=utf-8><title>{esc(D.TITLE)}</title><style>{css}</style></head><body>"]
parts.append(f"<h1>{esc(D.HEADING)}</h1>")
parts.append(f"<p class=meta>{stats['songs_total']} songs, {stats['songs_with_story']} with an identified story, {stats['stories_with_songs']} stories. "
             + esc(D.INTRO) + "</p>")
parts.append("<h2>Contents</h2><ul class=toc>"
             f"<li><a href='#A'>Part A: songs by number</a> ({stats['songs_with_story']} songs)</li>"
             "<li><a href='#B'>Part B: stories</a></li><li><a href='#C'>Part C: songs with no identified story</a></li></ul>")
parts.append("<h2 id=A class=pb>Part A: songs by number</h2>")
for sid in sorted(song_eps, key=int):
    h = hits[sid]
    pre, line = song_lines(sid)
    verse = "<br>".join(esc(x) for x in pre) + ("<br>" if pre else "") + f"<b>{esc(line)}</b>"
    parts.append(f"<div class=song><h3>Song {sid} · {esc(h['title'])} <span class=meta>· {esc(h['place'] or '')}</span></h3><div class=verse>{verse}</div>")
    for uid, m in song_eps[sid]:
        u = U[uid]
        cls = " class=low" if m["conf"] == "l" else ""
        parts.append(f"<div class=ep>Story: {esc(u['title'])} <span{cls}>[match {esc(m['conf'])}]</span></div>")
        if u["brief"]:
            parts.append(f"<div class=brief>{esc(u['brief'])}</div>")
        if m["note"]:
            parts.append(f"<div class=meta>Reading note: {esc(m['note'])}</div>")
        parts.append(f"<table>{ref_rows(u, True, False)}</table>")
    parts.append("</div>")
parts.append("<h2 id=B class=pb>Part B: stories, with quoted verses</h2>")
for dom in DOMAIN_ORDER:
    parts.append(f"<h2>{DOMAIN_NAME[dom]}</h2>")
    for uid, u in sorted(live.items(), key=lambda kv: -len(kv[1]["songs"])):
        if u["domain"] != dom:
            continue
        parts.append(f"<div class=song><h3>{esc(u['title'])} <span class=meta>· {len(u['songs'])} songs: {', '.join(sorted(u['songs'], key=int))}</span></h3>")
        if u["brief"]:
            parts.append(f"<div class=brief>{esc(u['brief'])}</div>")
        if u["note"]:
            parts.append(f"<div class=meta>Note: {esc(u['note'])}</div>")
        parts.append(f"<table>{ref_rows(u, True)}</table></div>")
parts.append("<h2 id=C class=pb>Part C: songs with no identified story</h2><p class=meta>" + esc(D.PART_C_NOTE) + "</p>")
for sid in no_story:
    h = hits[sid]
    pre, line = song_lines(sid)
    sl = ", ".join(smap.get(sid, (["?"], "", ""))[0])
    parts.append(f"<div class=song><h3>Song {sid} · {esc(h['title'])} <span class=meta>· {esc(h['place'] or '')} · tag: {esc(sl)}</span></h3>"
                 f"<div class=verse>{'<br>'.join(esc(x) for x in pre)}{'<br>' if pre else ''}<b>{esc(line)}</b></div></div>")
parts.append("</body></html>")
pdfdir = ROOT / "scriptures" / "pdf"
pdfdir.mkdir(exist_ok=True)
htmlf = pdfdir / D.HTML_NAME
htmlf.write_text("\n".join(parts), encoding="utf-8")
pdff = ROOT / "scriptures" / D.PDF_NAME
edge = next((p for p in (r"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe", r"C:\Program Files\Microsoft\Edge\Application\msedge.exe") if os.path.exists(p)), None)
if not edge:
    sys.exit("Edge not found; open the HTML in a browser and print to PDF")
subprocess.run([edge, "--headless=new", "--disable-gpu", "--no-pdf-header-footer", f"--print-to-pdf={pdff}", htmlf.as_uri()], check=True, timeout=600)
print("pdf", pdff, pdff.stat().st_size)
