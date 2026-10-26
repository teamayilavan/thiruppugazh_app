"""Shiva episode catalogue: stories grouped into domains, and which songs allude to which story.

Songs and stories come from shiva/song-story-map.txt (hand-read). References are added at build time from
shiva/refs-sanskrit.json, shiva/refs-saints.json and shiva/tirumurai-deeds.json (see deity_shiva.py).
Slugs shiva-form, shiva-son, shiva-general and not-shiva name no story: those songs go to "no identified story".
"""
import types
from pathlib import Path

MAP = Path(__file__).resolve().parent.parent / "shiva" / "song-story-map.txt"
CONF = {"high": "h", "med": "m", "low": "l"}

# domain -> ordered episodes (eid is the slug without "shiva-")
DOMAIN_EPISODES = {
    "deeds": ["tripura", "kama", "poison", "daksha", "yama", "brahma-head", "bhikshatana", "annamalai", "ganga", "ravana", "sarabha"],
    "forms": ["nataraja", "ardhanari", "dakshinamurti"],
    "saints": ["sambandar", "tiruvilaiyadal", "nayanmar", "kurundam"],
    "murugan": ["pranava", "skanda-birth"],
}
TITLES = {
    "tripura": "Burning of the three cities (Tripura)", "kama": "Kama burned by the forehead eye",
    "poison": "Shiva drinks the Halahala poison", "daksha": "Destruction of Daksha's sacrifice",
    "yama": "Shiva kicks Yama (Markandeya)", "brahma-head": "Brahma's fifth head cut off",
    "bhikshatana": "Shiva as the wandering beggar", "annamalai": "The fire pillar (Annamalai)",
    "ganga": "Ganga in the matted hair", "ravana": "Ravana lifts Kailasa", "sarabha": "Shiva as Sarabha",
    "nataraja": "Shiva the dancer (Nataraja)", "ardhanari": "Ardhanari: half Uma", "dakshinamurti": "Dakshinamurti",
    "sambandar": "Sambandar and the Jains", "tiruvilaiyadal": "The sacred sports at Madurai",
    "nayanmar": "Saints of the Tamil Shaiva tradition", "kurundam": "Manikkavasagar under the kurundam tree",
    "pranava": "Murugan teaches Shiva the Pranava", "skanda-birth": "Murugan born from Shiva's eye",
}


def _assignments():
    by_slug = {}
    for line in MAP.read_text(encoding="utf-8").splitlines():
        if not line.strip() or line.startswith("#"):
            continue
        sid, slugs, note, conf = line.split("|")
        for s in slugs.split(","):
            by_slug.setdefault(s.removeprefix("shiva-"), []).append((sid, CONF[conf], note))
    return by_slug


def build():
    """Return {domain: module-like with E and A_} in the shape build_master.py expects."""
    by = _assignments()
    mods = {}
    for dom, eids in DOMAIN_EPISODES.items():
        m = types.SimpleNamespace(E={}, A_={})
        for eid in eids:
            m.E[eid] = dict(title=TITLES[eid], note="", slug=f"shiva-{eid}")
            for sid, conf, note in by.get(eid, []):
                rec = m.A_.setdefault(sid, dict(eps=[], conf=conf, note=note))
                rec["eps"].append(eid)
        mods[dom] = m
    return mods
