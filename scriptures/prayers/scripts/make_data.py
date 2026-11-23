"""Write the Typst data files from the sentence-level prayers.

Usage (from the repo root):
  python3 scriptures/prayers/scripts/make_data.py WORKDIR scriptures/prayers
"""
import json, sys, os
sys.path.insert(0, os.path.dirname(__file__))
from filter_women import courtesan

work, out = sys.argv[1], sys.argv[2]
d = json.load(open(os.path.join(work, 'prayers3.json')))
d.sort(key=lambda e: e['id'])
ta = [dict(id=e['id'], title=e['title'], place=e['place'], word=e['word'],
           lines=e['lines'], ta=e['ta'] or '') for e in d]
drop = {(e['id'], e['word']) for e in d if courtesan(e)}
keep = [e for e in ta if (e['id'], e['word']) not in drop]
gone = [e for e in ta if (e['id'], e['word']) in drop]
json.dump(ta, open(os.path.join(out, 'prayers-ta.json'), 'w'), ensure_ascii=False, indent=0)
json.dump(keep, open(os.path.join(out, 'prayers-ta-filtered.json'), 'w'), ensure_ascii=False, indent=0)
with open(os.path.join(out, 'removed.txt'), 'w') as f:
    f.write(''.join(f"{e['id']}\t{e['title']}\t{e['place']}\t{e['word']}\n" for e in gone))
print(len(ta), 'prayers;', len(keep), 'kept after filter;', len(gone), 'removed')
