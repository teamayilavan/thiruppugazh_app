"""Build scriptures/invitations/ : every place where Arunagiri invites Murugan to come.

The entries below are CURATED BY HAND (each candidate line was read in context; see
invitations/README.md). This script only pulls the text, so no Tamil is retyped:
  - Tamil lines and the Roman transliteration come from assets/thiruppugazh.db (read-only);
  - 'English' = a short literal gloss written here, plus the sentence(s) of the song's own
    published English meaning that say 'come' (auto-picked; the meaning is prose and is not
    aligned line by line with the lyrics).

Run from the repo root:  python -I -X utf8 scriptures/scripts/build_invitations.py
"""
import json
import os
import re
import sqlite3

ROOT = os.path.dirname(os.path.abspath(__file__))
DB = os.path.join(ROOT, "..", "..", "assets", "thiruppugazh.db")
OUT = os.path.join(ROOT, "..", "invitations")

# (song, first_line_index, last_line_index, primary_group, tags, gloss)
# Groups: peacock, peacock-dance, cock, speed, run, accompanied, hour-of-death,
#         today, grace, love, other
E = [
    # ---- "வர வேணும்" : you must come ------------------------------------------------
    (46, 6, 7, "peacock", ["peacock", "see-his-feet"], "Come before me on your peacock, that I may see your pure feet and their anklets."),
    (68, 10, 11, "hour-of-death", ["peacock", "speed", "hour-of-death"], "At the hour my life is failing, come quickly on your peacock."),
    (75, 10, 11, "peacock", ["peacock"], "Come gracefully on your beautiful peacock."),
    (121, 6, 7, "peacock", ["peacock", "protect-me"], "To save me from the net of sensual ties, and to take charge of me, come mounted on your peacock."),
    (156, 4, 5, "grace", ["reassurance"], "Come to me, who wander in vain illusion, and tell me 'fear not'."),
    (166, 10, 11, "peacock", ["peacock"], "Grant me your feet, and come on your peacock."),
    (168, 6, 7, "grace", ["accept-me"], "Come, to bless me and take me wholeheartedly as your servant."),
    (180, 10, 11, "today", ["today", "grace"], "Come today and graciously rule me."),
    (182, 6, 7, "grace", ["worship"], "Come, that I may worship you."),
    (205, 6, 7, "peacock", ["peacock", "sages"], "While countless sages praise you, come strolling with your great peacock."),
    (209, 6, 7, "grace", ["grace"], "Come with joy, your grace flourishing, to my poor words."),
    (294, 6, 7, "today", ["today", "place"], "Come today to victorious Thiruthani."),
    (302, 6, 7, "peacock", ["peacock", "grace"], "Come on the green peacock, granting me devotion and liberation."),
    (379, 6, 7, "peacock", ["peacock", "always"], "Come always, mounted on your peacock."),
    (380, 6, 7, "peacock", ["peacock", "always"], "Come always, mounted on your peacock."),
    (381, 6, 7, "peacock", ["peacock", "always"], "Come, mounted on your gleaming peacock."),
    (404, 6, 7, "grace", ["place"], "Come, on the hill of Tiruvannamalai."),
    (414, 2, 3, "peacock", ["peacock"], "Come, mounted on your peacock."),
    (419, 6, 7, "peacock-dance", ["peacock", "speed"], "Come, setting your blue peacock bounding."),
    (430, 6, 7, "love", ["love"], "Come to embrace the maiden (the soul, as the devoted bride)."),
    (434, 6, 7, "peacock", ["peacock"], "Come, joyfully seeking me, on your peacock."),
    (502, 6, 7, "grace", ["praise"], "Come, so that I may sing your wondrous grace."),
    (505, 6, 7, "grace", ["reassurance"], "Come! Heal the worries of my heart. Come before me."),
    (585, 12, 13, "cock", ["cock"], "Come with your red cock (the cock on your banner)."),
    (605, 10, 11, "grace", ["place", "praise"], "Come once to Tiruvannamalai, where I praise you in Tamil and the Vedas."),
    (619, 6, 7, "peacock", ["peacock", "compassion"], "Come before me on your peacock, with compassion."),
    (645, 6, 7, "love", ["love"], "Come to give life to this one (the love-sick maiden of the song)."),
    (647, 6, 7, "love", ["love"], "Come to embrace the tormented maiden."),
    (648, 6, 7, "speed", ["speed"], "Come quickly, before the end."),
    (693, 6, 7, "love", ["love"], "Come to embrace me on the bed of flowers."),
    (724, 6, 7, "peacock-dance", ["peacock", "dance"], "Come dancing with your mighty peacock."),
    (743, 6, 7, "love", ["love"], "Come to embrace me, who languish in longing."),
    (777, 6, 7, "hour-of-death", ["hour-of-death", "grace"], "Come at the last day, when I am helpless, and take me to you."),
    (937, 6, 7, "peacock", ["peacock", "today"], "Come this very day, with your fine peacock, and destroy my bad deeds."),
    (945, 10, 11, "peacock", ["peacock", "hour-of-death"], "Come on your peacock, before my life is snatched, to grant me your two feet."),
    (974, 6, 7, "today", ["today", "love"], "Come today, as my longing grows."),
    (1025, 6, 7, "grace", ["grace"], "Come, intending to grant me your feet."),
    (1026, 6, 7, "grace", ["grace", "knowledge"], "Come, to destroy my past sins and give me a mind that thinks only of your names."),
    (1053, 6, 7, "peacock-dance", ["peacock", "dance"], "Come dancing, as the peacock dances too."),
    (1064, 6, 7, "peacock", ["peacock", "compassion"], "Come with compassion, on the beautiful peacock."),
    (1074, 6, 7, "hour-of-death", ["peacock", "hour-of-death"], "Come on your great peacock before Yama's messengers afflict me."),
    (1114, 6, 7, "speed", ["speed", "peacock", "fly"], "Come swiftly, flying at great speed on your victorious green peacock."),
    (1189, 6, 7, "love", ["love", "valli"], "Come to the languishing maiden, on those feet that went after Valli."),
    (1204, 6, 7, "accompanied", ["valli", "peacock", "protect-my-life"], "Come quickly on your peacock, with Valli (the best of the hunter clan), to save my life."),
    (1241, 6, 7, "grace", ["grace"], "Come before me, that my karma and my diseases may be driven away."),
    (1244, 6, 7, "run", ["speed", "run"], "Come hurrying."),
    (1307, 2, 3, "run", ["run"], "Come running before me, so that this humble one may live in the great world."),
    (1337, 6, 7, "grace", ["grace"], "Come, to give me your two feet."),
    (115, 22, 23, "grace", ["poetry"], "Come now, to grant me the love that praises you in Tamil verse and melts in worship."),
    # ---- "வருவாயே" : will you come / come ------------------------------------------
    (8, 10, 11, "peacock", ["peacock", "speed", "hour-of-death"], "In an instant, on the back of your peacock, come and drive out my fear."),
    (57, 10, 11, "peacock", ["peacock", "when"], "When will you come, on your thunderbolt-bright peacock?"),
    (63, 10, 11, "hour-of-death", ["hour-of-death"], "Come when Yama arrives, and say 'he is my devotee'."),
    (91, 10, 11, "peacock", ["peacock", "when"], "When will you come, on your golden peacock?"),
    (116, 10, 11, "peacock", ["peacock"], "Come on your peacock, your swift mount."),
    (151, 14, 15, "grace", ["gods"], "Come, so that the learned and the gods may worship."),
    (172, 10, 11, "grace", ["knowledge"], "Come, to give me a cool, devoted mind."),
    (417, 6, 7, "peacock", ["peacock", "spear"], "Come on your majestic peacock, spear in hand."),
    (483, 10, 11, "grace", ["knowledge"], "Come, to give me the knowledge of wisdom."),
    (513, 0, 1, "grace", ["promise"], "Come; do not fail the word you gave."),
    (564, 19, 20, "grace", ["close"], "Come to my side."),
    (688, 6, 7, "grace", ["grace"], "Come, to grant me your feet."),
    (694, 6, 7, "peacock", ["peacock", "see-his-faces"], "Come on your peacock, so that I may see your six faces and your spear."),
    (699, 6, 7, "grace", ["grace"], "Come, and bless me."),
    (702, 40, 41, "peacock", ["peacock"], "Come on your peacock."),
    (706, 2, 3, "love", ["embrace"], "Come, to embrace me with your twelve arms."),
    (833, 6, 7, "grace", ["grace"], "Come, to bless me with your friendship."),
    (834, 10, 11, "peacock-dance", ["peacock"], "Come on your bounding peacock."),
    (885, 10, 11, "grace", ["garland"], "Come, with your kadamba garland shining."),
    (971, 5, 7, "accompanied", ["valli", "peacock", "hour-of-death"], "Come seated on your peacock, with Valli at your side, to end my births and keep off Death."),
    (1169, 6, 7, "grace", ["grace"], "Come, seeing the world's grief."),
    (1186, 6, 7, "peacock", ["peacock", "gods"], "Come, as the gods shower flowers at your feet."),
    (1196, 10, 11, "grace", ["sages", "vedas"], "Come, as the sages gather round and the Vedas resound."),
    (1298, 2, 3, "grace", ["grace"], "Come, to give me your blessings."),
    (1309, 2, 3, "peacock-dance", ["dance"], "Come, performing the dance of wisdom."),
    (1325, 10, 11, "accompanied", ["valli", "deivayanai", "hour-of-death"], "Come before me with your two consorts (the forest-maiden Valli and Deivayanai), at the hour of my death."),
    # ---- "வாராய்" and similar: come! --------------------------------------------------
    (39, 7, 7, "grace", ["reassurance"], "Come, saying 'fear not, fear not'."),
    (84, 6, 7, "grace", ["worship"], "Come, that I may worship your victorious feet."),
    (705, 5, 6, "grace", ["reassurance"], "Come! Look on me! Be close to me!"),
    # ---- "வந்தருள்" : come and bless ---------------------------------------------------
    (11, 10, 11, "grace", ["grace"], "Come, and bring my sins to an end."),
    (76, 22, 23, "grace", ["grace"], "Come, and rule me, your servant."),
    (173, 6, 7, "peacock", ["peacock"], "Come marvellously, on your peacock."),
    (189, 10, 11, "grace", ["grace"], "Come, and rule me."),
    (198, 18, 19, "peacock", ["peacock", "speed"], "Come in an instant, on your great peacock."),
    (443, 6, 7, "grace", ["grace"], "Come, and end my anger."),
    (549, 15, 16, "peacock", ["peacock"], "Come on the peacock and take me as your own."),
    (726, 9, 10, "peacock", ["peacock", "speed"], "Come in an instant, graciously, mounted on your peacock."),
    (892, 5, 6, "peacock", ["peacock"], "Come gently, on the peacock, and end my sorrow."),
    (1310, 5, 6, "peacock", ["peacock"], "Come on the peacock, that I may bow at your feet."),
    (1311, 14, 15, "peacock", ["peacock", "fly"], "Come, mounted on the peacock that flies about the grove."),
]

# Songs whose auto-picked commentary clause is not about the invitation
NO_COMMENTARY = {1053}

# Murugan calling the devotee: 'come!' (the other direction, kept separate)
CALLS = [
    (201, 4, 5, "Call me 'Come!' — me, the ignorant one."),
    (911, 4, 5, "Call me 'Come!', and end my desires."),
    (920, 10, 11, "Call me 'Come!' with love, and rule me."),
    (1127, 5, 6, "You called me 'Come!' there, and ..."),
    (1127, 13, 14, "You called 'Come, come!' to rule the heavens."),
]
# Invitation lines addressed to someone else, found in the same songs
OTHER_ADDRESSEES = [
    (68, 12, 16, "Kausalya calling the child Rama: 'Come, my father, come, Raghunayaka ...' (Vishnu as Rama, not Murugan)."),
    (626, 10, 13, "The gopis calling Krishna: 'Come, come!' (Krishna, not Murugan)."),
]

STRONG = re.compile(
    r"(must (come|appear|arrive|be present|show)|should (come|appear)|kindly (come|appear)|please (come|appear)|do come|"
    r"come (running|dancing|riding|mounting|mounted|on|before|in front|to me|and|with|swiftly|quickly|fast|now|today|hurriedly)|"
    r"(appear|arrive|be present) (before|in front|to me|on|mounted|riding)|You (will|shall) come|will You come|when will You)",
    re.I)
AVOID = re.compile(r"messengers|Rope of|Kousalya|Rama \(Vishnu\)|gopis", re.I)


def sentences(text):
    """Clauses: split on sentence ends and semicolons."""
    return [x.strip() for x in re.split(r"(?<=[.!?;])\s+", text or "") if x.strip()]


def pick(comm):
    """The clause(s) of the English meaning that invite Murugan to come (the last matches)."""
    ss = [x for x in sentences(comm) if STRONG.search(x) and not AVOID.search(x)]
    out = []
    for x in ss[-2:]:
        if len(x) > 330:
            m = STRONG.search(x)
            a = max(0, m.start() - 200)
            b = min(len(x), m.end() + 130)
            x = ("... " if a else "") + x[a:b].strip() + (" ..." if b < len(x) else "")
        out.append(x)
    return out


def main():
    c = sqlite3.connect("file:" + os.path.abspath(DB).replace("\\", "/") + "?mode=ro", uri=True)
    songs = {}
    for r in c.execute("select id,title,place,english_venue,english_title,lyrics_list,english_lyrics_list,english_pathavurai from songs"):
        songs[r[0]] = r
    os.makedirs(OUT, exist_ok=True)

    def lines(sid, a, b):
        r = songs[sid]
        L = json.loads(r[5])
        T = json.loads(r[6]) if r[6] else []
        aligned = len(T) == len(L)
        ta = [L[i] for i in range(a, b + 1)]
        ro = [T[i] for i in range(a, b + 1)] if aligned else []
        return ta, ro

    out = []
    for n, (sid, a, b, group, tags, gloss) in enumerate(E, 1):
        r = songs[sid]
        ta, ro = lines(sid, a, b)
        out.append({
            "n": n, "song": sid, "title": r[1], "place": r[2], "venue_en": r[3],
            "line_range": [a, b], "group": group, "tags": tags,
            "tamil": ta, "roman": ro, "gloss": gloss,
            "commentary": [] if sid in NO_COMMENTARY else pick(r[7]),
        })
    calls = []
    for sid, a, b, gloss in CALLS:
        r = songs[sid]
        ta, ro = lines(sid, a, b)
        calls.append({"song": sid, "title": r[1], "venue_en": r[3], "tamil": ta, "roman": ro, "gloss": gloss})
    others = []
    for sid, a, b, gloss in OTHER_ADDRESSEES:
        r = songs[sid]
        ta, ro = lines(sid, a, b)
        others.append({"song": sid, "title": r[1], "venue_en": r[3], "tamil": ta, "roman": ro, "gloss": gloss})

    json.dump({"invitations": out, "murugan_calls_devotee": calls, "other_addressees": others},
              open(os.path.join(OUT, "invitations.json"), "w", encoding="utf-8"), ensure_ascii=False, indent=1)

    GROUPS = [
        ("peacock", "On the peacock (the vahana)"),
        ("peacock-dance", "On the peacock, dancing or bounding"),
        ("cock", "With the cock (the banner)"),
        ("speed", "Quickly, without delay"),
        ("run", "Running"),
        ("accompanied", "Come with Valli and Deivayanai"),
        ("hour-of-death", "At the hour of death"),
        ("today", "Come today, come now"),
        ("love", "Come to embrace (the soul as the devoted bride)"),
        ("grace", "Come to bless, to rule, to answer"),
    ]
    md = ["# Arunagiri invites Murugan: the lines where he says \"come\"", "",
          f"{len(out)} invitations in {len({e['song'] for e in out})} songs, in Tamil with the Roman transliteration from the app, and in English. "
          "Method and limits: [`README.md`](README.md). Machine-readable: [`invitations.json`](invitations.json).", "",
          "**About the English.** *Gloss* is a short literal rendering written for this collection. *Commentary* is the sentence of the song's own published English meaning (the Kaumaram.com edition, as in the app) that says \"come\"; the app's meanings are prose and not aligned line by line, so these were picked automatically and are shown as published.", ""]
    for g, title in GROUPS:
        items = [e for e in out if e["group"] == g]
        if not items:
            continue
        md += [f"## {title} ({len(items)})", ""]
        for e in items:
            md.append(f"### Song {e['song']} · {e['title']} · {e['venue_en'] or e['place']}  ·  {', '.join(e['tags'])}")
            md.append("")
            for t in e["tamil"]:
                md.append(f"> {t}  ")
            md.append("")
            if e["roman"]:
                for t in e["roman"]:
                    md.append(f"> *{t}*  ")
                md.append("")
            md.append(f"**Gloss:** {e['gloss']}")
            md.append("")
            for s in e["commentary"]:
                md.append(f"**Commentary:** {s}")
            md.append("")
    md += ["## Murugan calling the devotee: \"come!\" (the other direction)", "",
           "In these lines it is Murugan who says \"come\" to Arunagiri.", ""]
    for e in calls:
        md.append(f"### Song {e['song']}: {e['venue_en']}")
        md.append("")
        md += [f"> {t}  " for t in e["tamil"]] + [""]
        if e["roman"]:
            md += [f"> *{t}*  " for t in e["roman"]] + [""]
        md += [f"**Gloss:** {e['gloss']}", ""]
    md += ["## Not Murugan (found by the search, kept out of the count)", ""]
    for e in others:
        md.append(f"### Song {e['song']}: {e['venue_en']}")
        md.append("")
        md += [f"> {t}  " for t in e["tamil"]] + [""]
        md += [f"**Note:** {e['gloss']}", ""]
    open(os.path.join(OUT, "INVITATIONS.md"), "w", encoding="utf-8", newline="\n").write("\n".join(md))
    print(len(out), "invitations,", len({e['song'] for e in out}), "songs;",
          sum(1 for e in out if not e["roman"]), "without aligned transliteration;",
          sum(1 for e in out if not e["commentary"]), "without commentary sentence")


if __name__ == "__main__":
    main()
