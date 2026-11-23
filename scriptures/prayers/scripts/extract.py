import sqlite3,json,collections,re,sys
sys.stdout.reconfigure(encoding="utf-8")
c=sqlite3.connect('assets/thiruppugazh.db')
def verses(lines,n):
    n=n if n>0 else 2
    out=[];cur=[]
    for i,l in enumerate(lines):
        l=l.strip()
        if l: cur.append(l)
        if (i+1)%n==0:
            if cur: out.append(cur)
            cur=[]
    if cur: out.append(cur)
    return out
CATS=[ # (key, regex on final word)
 ('arul', r'(ருள்வாயே|ருள்வாய்|ருள்வாயோ|ருளுவாயே|ருளாயோ|ருளாதோ|ருள்கூர்வாய்|ருள்கூராய்|ருள்பாராய்|ருள்சேராய்|ருளவேணும்|ருள்வேணும்|ியருள்வாயே)$'),
 ('tharu', r'(தருவாயே|றருவாயே|டருவாயே|தாராய்|தாராயோ|ீவாய்|தந்துஆள்வாய்)$'),
 ('varu', r'(வரவேணும்|வருவாயே|வருவாய்|வாராய்)$'),
 ('venum', r'வேணும்$'),
 ('aal', r'(ஆள்வாய்|யாள்வாய்|னாள்வாய்|தாள்வாய்|லாள்வாய்|மீள்வாய்)$'),
 ('purivaay', r'(புரிவாயே)$'),
 ('other', r'(நினைவாயே|புகல்வாயே|மொழிவாயே|பகர்வாயே|இசைவாயே|களைவாயே|தழுவாயே|தீராய்|சேராய்|பாராய்|கூர்வாய்|கூராய்|அணைவாயே|ணைவாயே|புகுவாயே|உணர்வாயே|ணர்வாயே|திடுவாயே|புணர்வாயே|உறவாயே|றவாயே|மருவாயோ|ழங்குவாயே)$'),
 ('orunaal', r'ருநாளே$'),
]
CATS=[(k,re.compile(p)) for k,p in CATS]
out=[];misalign=0;unc=collections.Counter()
for row in c.execute('select id,title,place,lyrics_list,tune_list,meanings,english_meanings_list,english_title,english_venue,english_lyrics_list from songs order by id'):
    id,title,place,ll,tl,me,eme,et,ev,ell=row
    n=len(json.loads(tl or '[]'))
    vs=verses(json.loads(ll),n)
    evs=verses(json.loads(ell),n) if ell else []
    m=json.loads(me or '[]'); em=json.loads(eme or '[]')
    if len(m)!=len(vs): misalign+=1
    for i,v in enumerate(vs[:-1]):  # last verse ends with பெருமாளே
        last=v[-1].replace('......',' ').rstrip(' .').split()
        if not last: continue
        w=last[-1]
        for k,p in CATS:
            if p.search(w):
                out.append(dict(id=id,title=title,place=place,et=et,ev=ev,cat=k,word=w,vi=i,nv=len(vs),
                    lines=v, rom=evs[i] if i<len(evs) and len(evs)==len(vs) else None,
                    ta=m[i] if len(m)==len(vs) else None, en=em[i] if len(em)==len(vs) else None))
                break
print('entries',len(out),'songs',len({e['id'] for e in out}),'misaligned songs',misalign)
print(collections.Counter(e['cat'] for e in out))
print('no meaning',sum(1 for e in out if not e['ta']), 'no en',sum(1 for e in out if not e['en']))
print('position', collections.Counter((e['vi']+1)/e['nv']<=0.5 for e in out))
json.dump(out,open(sys.argv[1],'w'),ensure_ascii=False)
