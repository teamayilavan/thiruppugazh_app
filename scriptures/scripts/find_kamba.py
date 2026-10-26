"""Search a Kamba padalam (Tamil Wikisource text).

  python -I find_kamba.py யுத்த_காண்டம் மகுட_பங்கப்_படலம் keyword1,keyword2
Prints [padalam verse-no] (section heading) and the verse. Verse numbers are per padalam, as on Wikisource.
Without keywords it prints every verse number with the section heading it sits under.
"""
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
sys.stdout.reconfigure(encoding="utf-8")
from fetch_sources import kamba  # noqa: E402


def verses(kandam, padalam):
    """Blocks separated by blank lines: a block whose last line ends with TAB+number is a verse
    (lines joined with ' / '); any other block is a section heading for the verses below it."""
    t = kamba(kandam, padalam)
    out, head = [], ""
    for blk in re.split(r"\n\s*\n", t):
        lines = [ln.rstrip() for ln in blk.strip("\n").splitlines() if ln.strip()]
        if not lines:
            continue
        m = re.match(r"^(.*?[^\d\s])\s+(\d+(?:-\d+)?)$", lines[-1])
        if m:
            lines[-1] = m.group(1)
            out.append((m.group(2), head, " / ".join(ln.strip() for ln in lines if ln.strip())))
        else:
            head = " ".join(ln.strip().strip("'") for ln in lines
                            if not re.match(r"^(<|-{3,}|\{\{|\|)", ln.strip()))
    return out


if __name__ == "__main__":
    k, p = sys.argv[1], sys.argv[2]
    kws = sys.argv[3].split(",") if len(sys.argv) > 3 else []
    last = None
    for n, h, v in verses(k, p):
        if not kws:
            if h != last:
                print(f"{n}\t{h}")
                last = h
        elif any(w in v for w in kws):
            print(f"[{p} {n}] ({h})\n  {v}\n")
