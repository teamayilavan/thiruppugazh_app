"""Short prayers (fewer than 6 lines), with word-separated (பதம் பிரித்த) lyrics.

Takes the filtered prayers with fewer than 6 lines, drops those whose sentence starts
mid-word or that have no stored meaning, and replaces each lyric line with the matching
line of `mayuragiri_lyrics_separated` (or the `words` chunks when a song has none).

Usage (from the repo root):
  python3 scriptures/prayers/scripts/make_short.py scriptures/prayers
"""
import json, os, re, sqlite3, sys, unicodedata, difflib
sys.stdout.reconfigure(encoding="utf-8")

out_dir = sys.argv[1]
db = sqlite3.connect('assets/thiruppugazh.db')
src = json.load(open(os.path.join(out_dir, 'prayers-ta-filtered.json')))

NO_START = set('னறணழளங')
SKIP = set(' \t.-–—,;:!?"\'…()*')


def mid_word(line):
    ch = line.strip()[0]
    return ch in NO_START or unicodedata.category(ch) in ('Mn', 'Mc')


def norm(s):
    """Normalized characters and their raw indices."""
    chars, idx = [], []
    for i, ch in enumerate(s):
        if ch not in SKIP:
            chars.append(ch); idx.append(i)
    return ''.join(chars), idx


def similar(a, b):
    return difflib.SequenceMatcher(None, norm(a)[0], norm(b)[0], autojunk=False).ratio()


def covers(orig, new):
    """Share of the original line's letters found, in order, in the new line."""
    a = norm(orig)[0]
    sm = difflib.SequenceMatcher(None, a, norm(new)[0], autojunk=False)
    return sum(n for _, _, n in sm.get_matching_blocks()) / max(1, len(a))


def tidy(s):
    s = s.replace('......', ' ').replace('–', ' ').replace('…', ' ').replace('*', ' ')
    s = re.sub(r'\s+', ' ', s).strip()
    return s.rstrip(' .,')


def suffix_in(orig_line, orig_suffix, sep_line):
    """Cut sep_line where orig_suffix starts inside orig_line, snapped to a word start."""
    a, _ = norm(orig_line)
    b, bidx = norm(sep_line)
    start = len(a) - len(norm(orig_suffix)[0])
    sm = difflib.SequenceMatcher(None, a, b, autojunk=False)
    pos = None
    for i, j, n in sm.get_matching_blocks():
        if i <= start < i + n:
            pos = j + (start - i); break
        if i > start:
            pos = j; break
    if pos is None or pos >= len(bidx):
        return sep_line
    k = bidx[pos]
    while k > 0 and sep_line[k - 1] not in ' –':
        k -= 1
    return sep_line[k:]


def locate(L, lines):
    """Index of the first lyric line of the prayer in L, and whether it starts mid-line."""
    n = len(lines)
    for e in range(n - 1, len(L)):
        s = e - n + 1
        if L[s + 1:e + 1] == lines[1:] and L[s].endswith(lines[0]):
            return s, L[s] != lines[0]
    raise ValueError('prayer lines not found')


def from_words(L, s, e, j0, chunks):
    """Fallback: align the song's `words` chunks to the whole song, keep the chunks that
    lie mostly inside the prayer (line s from raw char j0 to the end of line e), and put
    each on the line that holds most of its letters."""
    vstr, vpos = [], []
    for li, l in enumerate(L):
        for j, ch in enumerate(l):
            if ch not in SKIP:
                vstr.append(ch); vpos.append((li, j))
    cstr, cown = [], []
    for ci, t in enumerate(chunks):
        for ch in t:
            if ch not in SKIP:
                cstr.append(ch); cown.append(ci)
    sm = difflib.SequenceMatcher(None, ''.join(cstr), ''.join(vstr), autojunk=False)
    votes = {}
    for i, j, n in sm.get_matching_blocks():
        for k in range(n):
            votes.setdefault(cown[i + k], []).append(vpos[j + k])
    inside = lambda li, j: (li == s and j >= j0) or s < li <= e
    out = [[] for _ in range(e - s + 1)]
    for ci in sorted(votes):
        v = votes[ci]
        ins = [li for li, j in v if inside(li, j)]
        if len(ins) * 2 > len(norm(chunks[ci])[0]):
            out[max(set(ins), key=ins.count) - s].append(chunks[ci])
    return [' '.join(x) for x in out]


THRESHOLD = 0.75
out, fallback, original = [], [], []
for p in src:
    if len(p['lines']) >= 6 or not p['ta'] or mid_word(p['lines'][0]):
        continue
    ll, ms, ws = db.execute(
        'select lyrics_list, mayuragiri_lyrics_separated, words from songs where id=?',
        (p['id'],)).fetchone()
    L = [l.strip() for l in json.loads(ll) if l.strip()]
    M = [m.strip() for m in json.loads(ms or '[]') if m.strip()]
    s, partial = locate(L, p['lines'])
    e = s + len(p['lines']) - 1
    sep = None
    if len(M) == len(L):
        sep = M[s:e + 1]
        if partial:
            sep[0] = suffix_in(L[s], p['lines'][0], sep[0])
        if min(similar(a, b) for a, b in zip(p['lines'], sep)) < THRESHOLD:
            sep = None  # separated lyrics out of step with the song's lines
    if sep is None:
        fallback.append(p['id'])
        sep = from_words(L, s, e, len(L[s]) - len(p['lines'][0]), json.loads(ws or '[]'))
        # a line the chunks do not cover well keeps its original text
        # An empty line is a word fragment whose word continues on the next line. If the
        # chunks miss part of any line, keep the original lines rather than mix the two.
        if any(x and covers(o, x) < 0.85 for o, x in zip(p['lines'], sep)):
            sep = list(p['lines']); original.append(p['id'])
    sep = [tidy(x) for x in sep if tidy(x)]
    out.append(dict(id=p['id'], title=p['title'], place=p['place'], word=p['word'],
                      separated=p['id'] not in original, lines=sep, ta=p['ta']))

json.dump(out, open(os.path.join(out_dir, 'prayers-ta-short.json'), 'w'),
          ensure_ascii=False, indent=0)
print(len(out), 'prayers;', 'from words chunks:', fallback, '; original lyrics:', original)
