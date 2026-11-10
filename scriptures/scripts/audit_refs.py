# -*- coding: utf-8 -*-
"""Mechanical check of the Sanskrit/Puranic references (Shiva set, and the URL-bearing Vishnu ones):
  * Mahabharata (GRETIL critical edition): every cited adhyaya and line number exists in scripts/.cache/mbh_NN.html
  * Bhagavata (vedabase.io): the URL's chapter matches the ref and every cited verse 'Text N' exists on the page
  * Valmiki (valmikiramayan.net): the URL's sarga matches and every cited shloka '1-75-12' exists on the page
  * wisdomlib (Linga/Shiva/Skanda/Ramayana): a chapter number in the ref equals the '[Chapter N]' in the page title
Prints counts and every ref that could not be (fully) checked."""
import json, re, sys, hashlib, html, collections
from pathlib import Path
sys.stdout.reconfigure(encoding="utf-8")
SC = Path(__file__).resolve().parents[1]; CA = SC / "scripts" / ".cache" / "audit"
sys.path.insert(0, str(SC / "scripts"))
import fetch_krishna as FK

def raw(u):
    f = CA / (hashlib.sha1(u.encode()).hexdigest()[:16] + ".html")
    return f.read_text(encoding="utf-8", errors="replace") if f.exists() else None
def text(u):
    t = raw(u)
    if t is None: return None
    t = re.sub(r"<script.*?</script>|<style.*?</style>", " ", t, flags=re.S)
    return re.sub(r"\s+", " ", html.unescape(re.sub(r"<[^>]+>", " ", t)))

MBH = {}
def mbh(parva):
    if parva not in MBH:
        d = collections.defaultdict(set)
        for adh, ref, _ in FK.mbh_lines(parva):
            m = re.match(r"\d+,\d+\.(\d+)", ref); d[adh].add(int(m.group(1)))
        MBH[parva] = d
    return MBH[parva]

res = collections.Counter(); problems = []
def note(kind, status, d, sid, ref, why=""):
    res[(kind, status)] += 1
    if status != "ok": problems.append((kind, status, d, sid, ref[:70], why))

for d in ("shiva", "vishnu"):
    m = json.loads((SC / d / "master.json").read_text(encoding="utf-8"))
    for sid, s in m["stories"].items():
        if not s.get("songs"): continue
        for r in s.get("refs") or []:
            ref = r.get("ref") or ""; src = r.get("src") or ""; u = r.get("url") or ""
            if src.startswith("Mahabharata"):
                bad = []; n = 0
                for tok in re.finditer(r"(?<![\d.])(\d{1,2}),(\d{1,3})(?:\.(\d+))?(?:\s*-\s*(\d+))?", ref):
                    parva, adh = int(tok.group(1)), int(tok.group(2)); n += 1
                    try: lines = mbh(parva)
                    except Exception as e: bad.append(f"parva {parva} unreadable"); continue
                    if adh not in lines: bad.append(f"{parva},{adh} no such adhyaya"); continue
                    if tok.group(3):
                        for ln in {int(tok.group(3)), int(tok.group(4) or tok.group(3))} if not tok.group(4) or int(tok.group(4)) > int(tok.group(3)) else {int(tok.group(3))}:
                            if ln not in lines[adh]: bad.append(f"{parva},{adh}.{ln} line missing")
                note("MBh", "ok" if n and not bad else ("no numbers" if not n else "FAILED"), d, sid, ref, "; ".join(bad))
            elif "vedabase.io" in u:
                t = text(u); mm = re.search(r"/sb/(\d+)/(\d+)/", u)
                if t is None: note("SB", "page missing", d, sid, ref); continue
                bad = []; n = 0; other = 0
                for tok in re.finditer(r"(\d+)\.(\d+)\.(\d+)(?:-(\d+))?", ref):
                    c, ch, v1, v2 = tok.group(1), tok.group(2), int(tok.group(3)), tok.group(4)
                    if (c, ch) != (mm.group(1), mm.group(2)): other += 1; continue
                    n += 1
                    for v in {v1, int(v2) if v2 else v1}:
                        if not re.search(rf"(?i)text(s)? {v}\b|texts? \d+[-–]{v}\b|texts? {v}[-–]\d+", t): bad.append(f"Text {v} not on page")
                if not re.search(r"SB (\d+)\.(\d+)", ref): note("SB", "no numbers", d, sid, ref)
                elif not re.search(rf"SB {mm.group(1)}\.{mm.group(2)}\b|{mm.group(1)}\.{mm.group(2)}\.", ref): note("SB", "URL chapter differs from ref", d, sid, ref, u[-20:])
                else: note("SB", "ok" if not bad else "FAILED", d, sid, ref, "; ".join(bad) + (f" (+{other} verse cites on other chapters not checked)" if other else ""))
            elif "valmikiramayan.net" in u:
                t = text(u); mm = re.search(r"sarga(\d+)/(\w)\w*?(\d+)\.htm", u); sg = re.search(r"sarga(\d+)", u).group(1)
                kd = {"baala": 1, "ayodhya": 2, "aranya": 3, "kishkindha": 4, "sundara": 5, "yuddha": 6}[re.search(r"utf8/(\w+)/", u).group(1)]
                bad = []; n = 0; other = 0
                for tok in re.finditer(r"(\d)\.(\d+)\.(\d+)(?:-(\d+))?", ref):
                    k, sga, v1, v2 = int(tok.group(1)), tok.group(2), int(tok.group(3)), tok.group(4)
                    if (k, sga) != (kd, sg): other += 1; continue
                    n += 1
                    covered = set()
                    for gm in re.finditer(rf"{kd}-{sg}-(\d+)[a-z]?((?:\s*,\s*\d+[a-z]?)*)", t):
                        covered.add(int(gm.group(1))); covered.update(int(x) for x in re.findall(r"\d+", gm.group(2)))
                    for v in range(v1, (int(v2) if v2 else v1) + 1):
                        if v not in covered: bad.append(f"{kd}-{sg}-{v} missing")
                note("Valmiki", ("ok" if n and not bad else "FAILED" if bad else "URL sarga differs from ref"), d, sid, ref, "; ".join(bad[:4]) + (f" (+{other} cites on other sargas)" if other else ""))
            elif "wisdomlib" in u:
                t = raw(u); title = re.search(r"<title>(.*?)</title>", t, re.S).group(1) if t else ""
                cm = re.search(r"Chapter (\d+)", html.unescape(title)); refnums = set(re.findall(r"\d+", re.sub(r"\(.*", "", ref)))
                ch = cm.group(1) if cm else None
                if ch and ch in refnums: note("wisdomlib", "ok", d, sid, ref, "")
                elif ch and any(ch in re.findall(r"\d+", x) for x in re.findall(r"ch\.?\s*([\d\-–, ]+)", ref)): note("wisdomlib", "ok", d, sid, ref)
                else: note("wisdomlib", "chapter not confirmed", d, sid, ref, f"page title: {html.unescape(title)[:70]}")
print(dict(res))
for p in problems: print(" ", p)
