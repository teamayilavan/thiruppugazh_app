"""Parse the Project Madurai Unicode HTML of the Kanda Puranam (Kachiyappa Sivachariyar) into
.cache/kp_mahendra.json, kp_yuddha.json, kp_deva.json: {running verse number within the kandam: text}.
The HTML files go in scripts/.cache/pm/ (git-ignored; Project Madurai asks that its header stay intact, so they are never committed).
The Daksha kandam (Valli padalam 24 is verses 1801-2067) has a few lost rows and one-off numbering slips near 1842-1850, so every citation is also checked by a word in the verse. The Asura kandam (pmuni0251, 0268, 0273) is numbered reliably up to about verse 1880 (padalam 24, Krouncha, is 1210-1222); the last 50 verses of the third file drift by up to two, so do not cite them without a word check.
Source: https://projectmadurai.org/pm_etexts/utf8/<file>.html . Run: python -I scriptures/scripts/parse_kp_pm.py"""
import json, re, html
from pathlib import Path
C = Path(__file__).resolve().parent / ".cache"
KANDAMS = {
    "kp_mahendra.json": ["pmuni0286_01", "pmuni0286_02"],
    "kp_yuddha.json": ["pmuni0289_01", "pmuni0289_02", "pmuni0289_03", "pmuni0293_01", "pmuni0293_02", "pmuni0293_03"],
    "kp_deva.json": ["pmuni0304"],
    "kp_asura.json": ["pmuni0251", "pmuni0268", "pmuni0273"],
    "kp_daksha.json": ["pmuni0307_01", "pmuni0307_02", "pmuni0318_01", "pmuni0318_02"],
}
ROW = re.compile(r'<tr><td[^>]*>\s*(\d+)\s*<td[^>]*>(.*?)<td[^>]*>\s*(\d+)\s*(?:</td>)?\s*</tr>', re.S)
STARTS = {  # first running verse of each padalam, from the files' own contents lists
    "kp_mahendra.json": [1, 54, 73, 90, 118, 155, 183, 238, 337, 418, 446, 481, 640, 661, 690, 771, 804, 905, 948, 970, 999],
    "kp_yuddha.json": [1, 37, 64, 457, 877, 1093, 1166, 1304, 1546, 1634, 1714, 1923, 2398, 2905, 2915, 2935],
    "kp_deva.json": [1, 36, 304, 350, 356],
    "kp_asura.json": [1], "kp_daksha.json": [1],
}
# (file, printed number, in-padalam number) -> true running number. Found by comparing the printed numbers with each padalam's range
# in the file's own contents list: Mahendra padalam 19 (Veerabahu's return, 948-969) is printed 949-970; Yuddha 916 is a typo for 926.
OVERRIDE = {("pmuni0286_02", 948 + q, q): 947 + q for q in range(1, 23)}
OVERRIDE[("pmuni0289_03", 916, 50)] = 926
OVERRIDE[("pmuni0286_02", 1110, 111)] = 1109
def parse(name, counter, starts):
    """Rows in order. The printed running number (first column) and the in-padalam number (last column) both have typos
    (1501 for 151, 12601 for 1261, 916 for 926, repeats). For each row: the number implied by the padalam start plus the in-padalam number
    is used if it is the expected next one or skips a few ahead, else the printed number under the same test, else previous + 1.
    Every row that needed a fallback is returned for the log."""
    t = (C / "pm" / f"{name}.html").read_text(encoding="utf-8-sig")
    out, diffs = {}, []
    for printed, body, inpad in ROW.findall(t):
        p, q = int(printed), int(inpad)
        exp = counter if counter is not None else p
        start = max([x for x in starts if x <= exp] or [1])
        d = start + q - 1
        ok = lambda v: exp <= v <= exp + 15
        n = OVERRIDE.get((name, p, q)) or (p if ok(p) else exp)
        if n != p:
            diffs.append((n, p))
        txt = html.unescape(re.sub(r"<[^>]+>", " ", body.replace("<br>", "\n")))
        out[str(n)] = re.sub(r"[ \t]+", " ", txt).strip()
        counter = n + 1
    return out, counter, diffs
def parse_kanchi():
    """Kanchi Puranam of Sivagnana Munivar, part 1 (verses 1-444, invocation and padalams 1-6): {printed verse number: text}."""
    t = (C / "pm" / "pmuni0292.html").read_text(encoding="utf-8-sig")
    out = {}
    for printed, body, inpad in ROW.findall(t):
        txt = html.unescape(re.sub(r"<[^>]+>", " ", body.replace("<br>", "\n")))
        out.setdefault(printed, re.sub(r"\s+", " ", txt).strip())
    return out
if __name__ == "__main__":
    k = parse_kanchi()
    (C / "kanchi_part1.json").write_text(json.dumps(k, ensure_ascii=False), encoding="utf-8")
    print("kanchi_part1.json", len(k), "verses")
    for target, files in KANDAMS.items():
        d, counter, alldiffs = {}, None, []
        for f in files:
            o, counter, df = parse(f, counter, STARTS[target])
            d.update(o); alldiffs += df
        nums = sorted(map(int, d))
        gaps = [n for n in range(nums[0], nums[-1] + 1) if str(n) not in d]
        (C / target).write_text(json.dumps(d, ensure_ascii=False), encoding="utf-8")
        print(target, len(d), "verses", nums[0], "-", nums[-1], "gaps:", gaps, "printed-number typos:", alldiffs)
