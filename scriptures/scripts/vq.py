"""Compact Valmiki query: python -I vq.py kanda sarga[,sarga] kw1,kw2 [maxlen] -> 'sarga.shloka: <prose tail, maxlen chars>'"""
import os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
sys.stdout.reconfigure(encoding="utf-8")
from fetch_sources import valmiki_verses
k, ss, kws = sys.argv[1], sys.argv[2].split(","), [x.lower() for x in sys.argv[3].split(",")]
ml = int(sys.argv[4]) if len(sys.argv) > 4 else 170
for s in ss:
    for n, t in valmiki_verses(k, int(s)):
        if any(w in t.lower() for w in kws):
            print(f"{k[:3]} {s}.{n}: {t[-ml:]}")
