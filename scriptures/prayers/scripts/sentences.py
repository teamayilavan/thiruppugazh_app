import sys,json,sqlite3,re,difflib
sys.stdout.reconfigure(encoding="utf-8")
S=sys.argv[1]
data=json.load(open(S+'/prayers.json'))
c=sqlite3.connect('assets/thiruppugazh.db')
SKIP=set(' \t.-–—,;:!?"\'…()*')
def nlines(lines):
    """normalized string + map to (line, char)"""
    s=[];m=[]
    for i,l in enumerate(lines):
        for j,ch in enumerate(l):
            if ch in SKIP: continue
            s.append(ch.lower()); m.append((i,j))
    return ''.join(s),m
def nseg(t):
    t=re.sub(r'\(.*?\)','',t)
    return ''.join(ch.lower() for ch in t if ch not in SKIP)
def segspans(L,segs):
    vstr,vmap=nlines(L)
    sstr='';sb=[]
    for t in segs:
        a=len(sstr); sstr+=nseg(t); sb.append((a,len(sstr)))
    sm=difflib.SequenceMatcher(None,sstr,vstr,autojunk=False)
    pos=[None]*len(sstr)
    for a,b,n in sm.get_matching_blocks():
        for k in range(n): pos[a+k]=b+k
    spans=[]
    for a,b in sb:
        ps=[pos[k] for k in range(a,b) if pos[k] is not None]
        spans.append((min(ps),max(ps)) if ps else None)
    return spans,vmap
def ends_sentence(t):
    t=t.strip().rstrip('*').strip()
    return bool(re.search(r'[.?!]["\')\]]*$',t))
def sentence(L,segs,means,pend):
    """L non-empty lines; pend=normalized index of petition's last char.
    returns (start_line,start_char, s_idx, e_idx)"""
    spans,vmap=segspans(L,segs)
    # segment containing pend (or nearest ending before/at)
    e=None;best=1e9
    for j,sp in enumerate(spans):
        if not sp: continue
        if sp[0]<=pend<=sp[1]+2: e=j;break
        d=abs(sp[1]-pend)
        if d<best: best=d;e=j
    s=e
    while s>0 and not ends_sentence(means[s-1]): s-=1
    st=spans[s][0] if spans[s] else 0
    if s==0: st=0
    return vmap[st], s, e, vmap
def clean(t):
    t=t.strip()
    t=re.sub(r'^\.+\s*','',t).rstrip(':').strip()
    return t
def verses_idx(lines,n):
    n=n if n>0 else 2
    out=[];cur=[]
    for i,l in enumerate(lines):
        if l.strip(): cur.append(l.strip())
        if (i+1)%n==0:
            if cur: out.append(cur)
            cur=[]
    if cur: out.append(cur)
    return out
def extract(L, startpos, endline):
    i,j=startpos
    # snap to word start
    while j>0 and L[i][j-1] not in ' ': j-=1
    out=[L[i][j:]]+L[i+1:endline+1]
    return out, j>0
VOC=re.compile(r'(னே|ளே|ரே|மானே|வனே|வோனே|அருளினாய்|அழைப்பார்கள்|விலைமாதரின்|மிக்கவனே)\W*$')
res=[];drop=[]
for e in data:
    if (e['id'],e['word']) in {(825,'வுறவாயே'),(959,'குறவாயே'),(1334,'மணிகூர்வாய்')}: continue
    id=e['id']
    ll,tl,w,m,ell,ew,em=c.execute('select lyrics_list,tune_list,words,meanings,english_lyrics_list,english_words,english_meanings_list from songs where id=?',(id,)).fetchone()
    n=len(json.loads(tl or '[]'))
    vs=verses_idx(json.loads(ll),n)
    L=[l for v in vs for l in v]
    endline=sum(len(v) for v in vs[:e['vi']+1])-1
    w=json.loads(w or '[]'); m=json.loads(m or '[]')
    if not w or len(w)!=len(m):
        st={1329:5}.get(id,0)
        EL=[l for v in verses_idx(json.loads(ell),n) for l in v] if ell else []
        res.append(dict(id=id,title=e['title'],place=e['place'],et=e['et'],ev=e['ev'],cat=e['cat'],word=e['word'],
            lines=L[st:endline+1],partial=False,rom=EL[st:endline+1] if len(EL)==len(L) else None,ta=None,en=None)); continue
    vstr,_=nlines(L[:endline+1]); pend=len(vstr)-1
    (si,sj),s,ei,_=sentence(L,w,m,pend)
    if si>endline: si,sj=0,0
    lines,partial=extract(L,(si,sj),endline)
    ta=' '.join(clean(x) for x in m[s:ei+1])
    lastm=clean(m[ei]).rstrip(' .,;')
    if VOC.search(lastm) and not re.search(r'(வாயாக|அருளுக|தருக|வேண்டும்|\?)',lastm):
        drop.append((id,'vocative:'+lastm[-30:])); continue
    # English
    en=None;rom=None
    ew=json.loads(ew or '[]'); em=json.loads(em or '[]')
    if ell and ew and len(ew)==len(em):
        evs=verses_idx(json.loads(ell),n)
        EL=[l for v in evs for l in v]
        if len(EL)==len(L):
            spans2,vmap2=segspans(EL,ew)
            lo=next(k for k,(li,_) in enumerate(vmap2) if li>=si)
            if partial:
                tot=sum(1 for li,_ in vmap2 if li==si); frac=sj/max(1,len(L[si]))
                lo+=int(tot*frac*0.9)
            hi=max(k for k,(li,_) in enumerate(vmap2) if li<=endline)
            pick=[j for j,sp in enumerate(spans2) if sp and lo-3<=(sp[0]+sp[1])/2<=hi+3]
            if pick:
                en=' '.join(clean(em[j]) for j in range(pick[0],pick[-1]+1))
                rom=EL[si:endline+1]
    nlin=len(lines)
    res.append(dict(id=id,title=e['title'],place=e['place'],et=e['et'],ev=e['ev'],cat=e['cat'],word=e['word'],
        lines=lines,partial=partial,rom=rom,ta=ta,en=en))
print(len(res),'kept; dropped',len(drop))
for d in drop: print(d)
import collections
print(collections.Counter(len(r['lines']) for r in res))
json.dump(res,open(S+'/prayers3.json','w'),ensure_ascii=False)
