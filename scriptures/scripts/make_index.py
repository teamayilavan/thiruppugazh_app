"""Story and song reference index for expert verification: an Excel workbook and an A4 PDF.

  python -I -X utf8 scriptures/scripts/make_index.py

Writes scriptures/pdf/story-song-index.xlsx and scriptures/pdf/story-song-index.pdf (via pdf/index.typ, Typst).
Stories are numbered as in the books: volume (I Vishnu, II Shiva, III Murugan, IV the rest), then alphabetical
order of title within the volume, e.g. III.5. For every story: title, brief, references, and each song that refers to
it with its title, temple and the lyric lines that carry the allusion (from the story files, matched to the database).
Reads assets/thiruppugazh.db read-only.
"""
import datetime
import json
import sqlite3
import subprocess
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import make_pdf as mp  # noqa: E402

from openpyxl import Workbook  # noqa: E402
from openpyxl.styles import Alignment, Font, PatternFill, Border, Side  # noqa: E402
from openpyxl.utils import get_column_letter  # noqa: E402

PDF = mp.PDF
OUT = "story-song-index"


def collect():
    con = sqlite3.connect(f"file:{mp.DB}?mode=ro", uri=True)
    stories = []
    for v, vol in mp.VOLUMES.items():
        sts = mp.build_stories(vol["sets"])
        for i, st in enumerate(sts, 1):
            refs = []
            for r in st["refs"]:
                if r["status"] and not any(x in r["status"] for x in mp.VERIFIED):
                    continue
                ref = mp.polish(r["ref"]) or r["ref"]
                refs.append(dict(source=r["source"], ref=ref, says=mp.polish(r["says"])))
            songs = []
            for sg in st["songs"]:
                row = con.execute("select title, place from songs where id=?", (sg["no"],)).fetchone()
                title, place = (row if row else (sg["name"], sg["place"]))
                hits = [mp.disp(l["t"]) for l in sg["lines"] if l["hit"]]
                ctx = [dict(t=mp.disp(l["t"]), hit=l["hit"]) for l in sg["lines"]] if hits else []
                songs.append(dict(no=sg["no"], title=title, place=(place or sg["place"] or "").strip(), lines=hits, ctx=ctx))
            narr = mp.NARR / f"{st['slug']}.txt"
            stories.append(dict(
                id=f"{vol['roman']}.{i}", vol=vol["roman"], volname=vol["name"], slug=st["slug"], title=st["title"],
                domain=st["domain"], brief=st["brief"], refs=refs, songs=songs,
                narrative=narr.read_text(encoding="utf-8").strip() if narr.exists() else ""))
    return stories


def by_song(stories):
    idx = {}
    for st in stories:
        for sg in st["songs"]:
            e = idx.setdefault(sg["no"], dict(no=sg["no"], title=sg["title"], place=sg["place"], stories=[]))
            e["stories"].append(dict(id=st["id"], title=st["title"]))
    return [idx[k] for k in sorted(idx)]


def excel(stories, songs, path):
    wb = Workbook()
    head_font = Font(bold=True, color="FFFFFF", name="Calibri")
    head_fill = PatternFill("solid", fgColor="2E6B3A")
    thin = Side(style="thin", color="C8D6C8")
    border = Border(left=thin, right=thin, top=thin, bottom=thin)
    wrap = Alignment(wrap_text=True, vertical="top")
    ta = Font(name="Nirmala UI")

    def sheet(ws, headers, widths, rows, tamil_cols=()):
        ws.append(headers)
        for c in range(1, len(headers) + 1):
            cell = ws.cell(row=1, column=c)
            cell.font, cell.fill, cell.alignment, cell.border = head_font, head_fill, Alignment(wrap_text=True, vertical="center"), border
        for r in rows:
            ws.append(r)
        for row in ws.iter_rows(min_row=2):
            for cell in row:
                cell.alignment, cell.border = wrap, border
                if cell.column in tamil_cols:
                    cell.font = ta
        for i, w in enumerate(widths, 1):
            ws.column_dimensions[get_column_letter(i)].width = w
        ws.freeze_panes = "A2"
        ws.auto_filter.ref = ws.dimensions

    ws = wb.active
    ws.title = "Stories"
    sheet(ws, ["No.", "Volume", "Story Title", "Story Brief", "Songs (count)", "Thiruppugazh song numbers", "Main references", "Expert remarks"],
          [7, 14, 34, 80, 8, 40, 60, 40],
          [[s["id"], f"{s['vol']}: {s['volname']}", s["title"], s["brief"], len(s["songs"]),
            ", ".join(str(g["no"]) for g in s["songs"]),
            "\n".join(f"{r['source']}: {r['ref']}" for r in s["refs"]), ""] for s in stories])

    ws = wb.create_sheet("Song lines per story")
    rows = []
    for s in stories:
        for g in s["songs"]:
            rows.append([s["id"], s["title"], g["no"], g["title"], g["place"],
                         "\n".join(g["lines"]) if g["lines"] else "(allusion in the meaning, no single line)",
                         "\n".join(("► " if c["hit"] else "    ") + c["t"] for c in g["ctx"]), "", ""])
    sheet(ws, ["Story No.", "Story Title", "Song No.", "Song title", "Temple / place", "Lyric line(s) carrying the allusion",
               "With surrounding lines (► = allusion)", "Correct? (Y/N)", "Expert remarks"],
          [9, 34, 9, 24, 20, 55, 65, 10, 40], rows, tamil_cols=(4, 5, 6, 7))

    ws = wb.create_sheet("By song number")
    sheet(ws, ["Song No.", "Song title", "Temple / place", "Stories (No.)", "Story titles"],
          [9, 26, 22, 20, 70],
          [[g["no"], g["title"], g["place"], ", ".join(x["id"] for x in g["stories"]), "; ".join(x["title"] for x in g["stories"])] for g in songs],
          tamil_cols=(2, 3))

    ws = wb.create_sheet("Story texts")
    sheet(ws, ["No.", "Story Title", "Story text (book narrative)"], [7, 34, 120],
          [[s["id"], s["title"], s["narrative"]] for s in stories])
    wb.save(path)


def main():
    stories = collect()
    songs = by_song(stories)
    excel(stories, songs, PDF / f"{OUT}.xlsx")
    vols = []
    for v, vol in mp.VOLUMES.items():
        vols.append(dict(roman=vol["roman"], name=vol["name"], stories=[s for s in stories if s["vol"] == vol["roman"]]))
    data = dict(date=datetime.date.today().strftime("%d %B %Y"), volumes=vols, songs=songs,
                n_stories=len(stories), n_songs=len(songs), n_entries=sum(len(s["songs"]) for s in stories))
    (PDF / f"{OUT}.json").write_text(json.dumps(data, ensure_ascii=False), encoding="utf-8")
    cmd = ["typst", "compile", "--root", str(PDF), "--input", f"data={OUT}.json", str(PDF / "index.typ"), str(PDF / f"{OUT}.pdf")]
    r = subprocess.run(cmd, capture_output=True, text=True, encoding="utf-8")
    print(f"{len(stories)} stories, {len(songs)} songs, {data['n_entries']} story-song entries")
    print("xlsx ->", PDF / f"{OUT}.xlsx")
    print("pdf  ->", PDF / f"{OUT}.pdf" if r.returncode == 0 else "FAILED\n" + r.stderr)
    sys.exit(r.returncode)


if __name__ == "__main__":
    main()
