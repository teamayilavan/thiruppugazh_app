"""Quick Kamba queries: python -I kamba_q.py <kandam> <padalam> <kw1,kw2> [max]  -> verse no + first 110 chars.
   python -I kamba_q.py <kandam> <padalam> --tail N   -> last N verses."""
import os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
sys.stdout.reconfigure(encoding="utf-8")
from find_kamba import verses
k, p, q = sys.argv[1], sys.argv[2], sys.argv[3]
v = verses(k, p)
if q == "--tail":
    for n, h, t in v[-int(sys.argv[4]):]:
        print(f"{p[:10]} {n}: {t[:110]}")
elif q == "--heads":
    last = None
    for n, h, t in v:
        if h != last and h:
            last = h; print(f"{p[:12]} {n}\t{h[:90]}")
else:
    kws = q.split(","); mx = int(sys.argv[4]) if len(sys.argv) > 4 else 8; c = 0
    for n, h, t in v:
        if any(w in t for w in kws):
            print(f"{p[:10]} {n}: {t[:110]}"); c += 1
            if c >= mx: break
