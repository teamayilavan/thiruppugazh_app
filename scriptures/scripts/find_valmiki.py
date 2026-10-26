"""Search Valmiki sargas for keywords and print shloka numbers: python -I find_valmiki.py yuddha 107,108 head,heads"""
import re, sys, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
sys.stdout.reconfigure(encoding="utf-8")
from fetch_sources import valmiki_verses
kanda, sargas, kws = sys.argv[1], sys.argv[2].split(","), [k.lower() for k in sys.argv[3].split(",")]
for s in sargas:
    for n, tail in valmiki_verses(kanda, int(s)):
        if any(k in tail.lower() for k in kws):
            print(f"{kanda} {s}.{n}: ...{tail[-300:]}")
            print()
