"""Print section headings (with first verse number) of a padalam, optionally filtered:
python -I kamba_heads.py <kandam> <padalam> [kw1,kw2]"""
import os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
sys.stdout.reconfigure(encoding="utf-8")
from find_kamba import verses
k, p = sys.argv[1], sys.argv[2]
kws = sys.argv[3].split(",") if len(sys.argv) > 3 else []
last = None
for n, h, v in verses(k, p):
    if h != last:
        last = h
        if not kws or any(w in h for w in kws):
            print(f"{p[:14]} {n}\t{h[:120]}")
