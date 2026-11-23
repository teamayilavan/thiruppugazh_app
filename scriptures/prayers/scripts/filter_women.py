import json,sys,re
COURT_TA=r'விலைமாத|விலை மாத|பொதுமா|பொது மா|பொது மகளி|பொதுமகளி|வேசை|வேசி|விலைமகளி|விலை மகளி|பரத்தை|மாதர்|மடவார|மடந்தையர்|மகளிர'
COURT_EN=r'whore|harlot|courtesan|prostitut|seductress|flirt'
LY_COURT=r'மாதர்|விலைமா|வேசை|பொதுமா|மடவார்|மகளிர்|மடவியர்|வேசியர்'
WOMEN_EN=r'\b(?:these|those|young|pretty|beautiful|such|stupid|deceitful|whorish|enticing)?\s*(?:women|girls|damsels|maidens|ladies)\b|their (?:bosom|breasts|hair|eyes|lips|waist|gait|smile|chest|thighs)'
LUST_EN=r'lust|infatuat|passion|obsess|enchant|tempt|fell for|falling for|hanker|ensnar|trap|tricks|seduc|captivat|union|carnal|erotic|kiss|bosom|breasts|lips|amorous|arous|sensual|pleasure'
NEUTRAL=r'women ?folk|womenfolk|women of (?:this|the) (?:world|town)|celestial (?:women|maidens|damsels)|DEva ?(?:women|maidens)|gossip|mourn|wail|weep|cry|crying|VaLLi[^.;]*|DEvayAnai[^.;]*|the (?:two )?(?:great )?Goddesses[^.;]*|virtuous women'
NEUT_TA=r'தேவ மங்கையர்|தேவலோக மங்கையர்|அர மகளிர்|அரமகளிர்|வள்ளி[^,.;]*|தேவயானை[^,.;]*|மனைவி|தாய்|தாயின்|அழுது|அழுகை|கதற'
FORCE_REMOVE={42,149,414,443,669,1030,1141,96,177,338,526,564,852,972}
FORCE_KEEP={205,265,286,381,647,898,1139,1215,65,91,94,174,196,755,785,1211,1293,256,285,302,380,389,610,693,955,1083,996,1163,616,110,1189}
def courtesan(e):
    if e['id'] in FORCE_REMOVE: return True
    if e['id'] in FORCE_KEEP: return False
    ta=re.sub(NEUT_TA,'',e['ta'] or ''); en=re.sub(NEUTRAL,'',e['en'] or '',flags=re.I)
    ly=' '.join(e['lines'])
    if re.search(COURT_TA,ta) or re.search(COURT_EN,en,re.I) or re.search(LY_COURT,ly): return True
    w=len(re.findall(WOMEN_EN,en,re.I)); l=len(re.findall(LUST_EN,en,re.I))
    return w>=1 and l>=1
if __name__=='__main__':
    d=json.load(open(sys.argv[1]))
    R=[e for e in d if courtesan(e)];K=[e for e in d if not courtesan(e)]
    print('remove',len(R),'keep',len(K),'songs kept',len({e['id'] for e in K}))
    mode=sys.argv[2] if len(sys.argv)>2 else ''
    if mode=='r':
        for e in R:
            ta=re.sub(NEUT_TA,'',e['ta'] or ''); en=re.sub(NEUTRAL,'',e['en'] or '',flags=re.I)
            if not(re.search(COURT_TA,ta) or re.search(COURT_EN,en,re.I) or re.search(LY_COURT,' '.join(e['lines']))):
                m=re.search(WOMEN_EN,en,re.I); i=m.start() if m else 0
                print(e['id'],'|',en[max(0,i-60):i+90])
    if mode=='rc':
        for e in R:
            ta=re.sub(NEUT_TA,'',e['ta'] or '')
            m=re.search(COURT_TA,ta)
            if m and not re.search(COURT_EN,e['en'] or '',re.I) and not re.search(LY_COURT,' '.join(e['lines'])):
                i=m.start(); print(e['id'],'|',ta[max(0,i-60):i+60])
    if mode=='k':
        for e in K:
            en=e['en'] or ''
            m=re.search(r'women|girls|damsel|bosom|breast|lust|passion',en,re.I)
            if m: i=m.start(); print(e['id'],'|',en[max(0,i-70):i+70])
