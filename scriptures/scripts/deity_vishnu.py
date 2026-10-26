"""Vishnu configuration for build_master.py (run with --deity vishnu, the default).

A deity module supplies everything that differs between deities; build_master.py holds the
shared join, markdown and PDF code. To add a deity, write scripts/deity_<name>.py with the
same names and a folder scriptures/<name>/ holding shortlist.json and song-story-map.txt.

Required names:
  FOLDER         folder under scriptures/ (also the output folder)
  DOMAINS        ordered list of (domain, episode module); a module has E (episodes) and A_ (song assignments)
  DOMAIN_NAME    domain -> heading shown in the index and PDF
  STORY          slug -> {"brief": ...} from the story_data module
  slug_for(domain, eid) -> story slug for an episode (None if no brief)
  build_refs(domain, episode) -> list of reference dicts (src, ref, gist, quote, pinned)
  dp_for(domain, eid) -> Tamil devotional verses for the episode (Divya Prabandham for Vishnu)
  TAMIL_SOURCE   label of the Tamil devotional corpus, used in tables
  TITLE, INTRO, PART_C_NOTE, PDF_NAME   PDF texts
"""
import json
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))

import avatar_episodes as AE  # noqa: E402
import krishna_episodes as KE  # noqa: E402
import ramayana_episodes as RE  # noqa: E402
from find_kamba import verses as kamba_verses  # noqa: E402
from fetch_krishna import mbh_lines  # noqa: E402
from story_data import S as STORY  # noqa: E402,F401

FOLDER = "vishnu"
V = HERE.parent / FOLDER
DOMAINS = [("ramayana", RE), ("krishna", KE), ("avatar", AE)]
DOMAIN_NAME = {"ramayana": "Ramayana", "krishna": "Krishna / Mahabharata", "avatar": "Avatars and Vishnu images"}
TAMIL_SOURCE = "Divya Prabandham"
TITLE = "Thiruppugazh: stories of Vishnu"
HEADING = "Thiruppugazh songs that call Murugan the nephew of Vishnu: stories and sources"
PDF_NAME = "thiruppugazh-vishnu-stories.pdf"
HTML_NAME = "thiruppugazh-vishnu-stories.html"
INTRO = ("Part A is by song number: the verse, then the story, then every reference. Part B is by story, with the quoted verses and Divya Prabandham links. "
         "Reference marks: Kamba verse numbers are per padalam (Tamil Wikisource); Mahabharata numbers are Critical Edition lines; "
         "Valmiki numbers follow valmikiramayan.net; Bhagavata numbers follow vedabase.io. 'verse not pinned' = padalam known, verse not yet found.")
PART_C_NOTE = "The nephew word names Vishnu only by an epithet, or the reading is unclear."

# episode -> story_data slug (for the brief)
SLUG = {
    "ramayana": {"birth": "ram-childhood", "tataka": "ram-tataka-yajna", "yajna": "ram-tataka-yajna", "ahalya": "ram-ahalya",
                 "bow": "ram-sita-swayamvara", "exile": "ram-exile", "kaka": "ram-kakasura", "khara": "ram-khara-dushana",
                 "sita-abduction": "ram-sita-abduction", "sita-jewels": "ram-sita-jewels", "maricha": "ram-maricha",
                 "seven-trees": "ram-seven-trees", "garland": "ram-vali", "vali": "ram-vali", "sugriva-crown": "ram-sugriva",
                 "army-march": "ram-sugriva", "lanka-burnt": "ram-hanuman-lanka", "ocean-arrow": "ram-samudra-arrow",
                 "setu": "ram-setu", "vibhishana-refuge": "ram-vibhishana", "vibhishana-crown": "ram-vibhishana",
                 "sita-freed": "ram-sita-recovery", "sita-agni": "ram-sita-agni", "return": "ram-pattabhishekam"},
    "krishna": {"butter-pot": "krishna-butter", "mortar-bound": "krishna-butter", "mud-mouth": "krishna-mannunda",
                "clothes": "krishna-vastra-harana", "naraka-wives": "krishna-16000-wives", "embassy": "krishna-envoy",
                "gita-chariot": "krishna-partha-sarathi", "war-general": "mbh-war", "exile-general": "mbh-war",
                "duryodhana-fall": "mbh-war", "bhishma-shikhandi": "mbh-war", "bhishma-wheel": "mbh-war",
                "jayadratha": "mbh-jayadratha", "kirata": "mbh-kirata", "pandava-coronation": "krishna-pandava-friend",
                "kamsa-malice": "krishna-kamsa", "mausala": "krishna-mausala"},
    "avatar": {"halahala": "samudra-manthana", "mohini": "samudra-manthana", "brahma-origin": "vishnu-brahma-origin",
               "adisesha": "vishnu-sleeping", "pralaya": "vishnu-pralaya", "temple": "vishnu-temple-srirangam"},
}
# avatar episode -> dp slugs in the dp json files
DP_AV = {"gajendra": ["gajendra"], "samudra-manthana": ["samudra-manthana"], "halahala": ["samudra-manthana"],
         "mohini": ["samudra-manthana"], "kurma": ["kurma"], "vamana": ["vamana"], "narasimha": ["narasimha"],
         "varaha": ["varaha"], "brahma-origin": ["vishnu-brahma-origin"], "adisesha": ["vishnu-sleeping"],
         "pralaya": ["vishnu-pralaya"], "temple": ["vishnu-temple-srirangam", "vishnu-temple-tirupati", "vishnu-temple-kanchi"]}

_kv, _mb = {}, {}


def pname(p):
    return p.replace("_", " ")


def quote_kamba(kandam, pad, n):
    key = (kandam, pad)
    if key not in _kv:
        _kv[key] = {num: t for num, _, t in kamba_verses(kandam, pad)}
    return _kv[key].get(str(n), "")


def quote_mbh(parva, ref):
    if parva not in _mb:
        _mb[parva] = {r: t for _, r, t in mbh_lines(parva)}
    return _mb[parva].get(ref, "")


def slug_for(domain, eid):
    slug = SLUG[domain].get(eid, eid if domain != "ramayana" else f"ram-{eid}")
    return slug if STORY.get(slug) else (f"krishna-{eid}" if STORY.get(f"krishna-{eid}") else f"mbh-{eid}")


def build_refs(domain, e):
    refs = []
    if domain == "ramayana":
        for k, s, r, g in e["valmiki"]:
            refs.append(dict(src="Valmiki Ramayana", ref=f"{k} {r}", gist=g, pinned=True))
        for kandam, pad, nums in e["kamba"]:
            if nums:
                for n in nums:
                    refs.append(dict(src="Kamba Ramayanam", ref=f"{pname(pad)} {n}", quote=quote_kamba(kandam, pad, n)[:170], pinned=True))
            else:
                refs.append(dict(src="Kamba Ramayanam", ref=f"{pname(pad)} (verse not pinned)", pinned=False))
    elif domain == "krishna":
        for c, ch, v, g in e["sb"]:
            refs.append(dict(src="Bhagavata Purana", ref=f"SB {c}.{ch}.{v}", gist=g, pinned=True))
        for p, adh, rr, g in e["mbh"]:
            ref = rr[0] if len(rr) == 1 else f"{rr[0]} … {rr[-1]}"
            q = " / ".join(quote_mbh(p, x) for x in rr[:2])
            refs.append(dict(src="Mahabharata (Critical Edition)", ref=ref, gist=g, quote=q, pinned=True))
    else:
        for c, ch, v, g in e["sb"]:
            refs.append(dict(src="Bhagavata Purana", ref=f"SB {c}.{ch}.{v}", gist=g, pinned=True))
        for kanda, sarga, shl, g in e["valmiki"]:
            refs.append(dict(src="Valmiki Ramayana", ref=f"{kanda.title()} {sarga}.{','.join(map(str, shl))}", gist=g, pinned=True))
        for kandam, pad, nums, g in e["kamba"]:
            refs.append(dict(src="Kamba Ramayanam", ref=f"{pname(pad)} {', '.join(map(str, nums))}", gist=g,
                             quote=quote_kamba(kandam, pad, nums[0])[:170] if nums else "", pinned=bool(nums)))
        for book, ch, _doc, _kw, g in e["vp"]:
            refs.append(dict(src="Vishnu Purana (Wilson)", ref=f"VP {book}.{ch}", gist=g, pinned=True))
    return refs


dp_files = {n: json.loads((V / "dp" / f"{n}.json").read_text(encoding="utf-8")) for n in ("ramayana", "krishna", "avatars")}


def dp_for(domain, eid):
    if domain == "ramayana":
        out = [x for x in dp_files["ramayana"] if x["episode"] == eid]
    elif domain == "krishna":
        out = [x for x in dp_files["krishna"] if x["episode"] == eid]
    else:
        slugs = DP_AV.get(eid, [])
        out = [x for x in dp_files["avatars"] if x["story"] in slugs]
    return [dict(prabandham=x["prabandham"], ref=x["ref"], first=x.get("first_words_ta") or x.get("first_words", ""),
                 gist=x.get("gist", ""), url=x.get("url", ""), confirmed=bool(x.get("confirmed"))) for x in out]
