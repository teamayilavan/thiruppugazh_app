"""Krishna / Mahabharata episodes with verse-level references, and which songs allude to which episode.

Bhagavata: (canto, chapter, 'first-last' verse numbers, my gist). Numbering = vedabase.io (canto.chapter.verse).
Mahabharata: (parva, adhyaya, [refs], my gist). Refs are Critical Edition (BORI) line numbers as given in the GRETIL
text: 'parva,adhyaya.shloka' plus pada letter; star passages (interpolations not in the constituted text) keep their
'*NNNN_NN' tag. Vulgate/Ganguli section numbers differ and are noted in 'note' where known.
build_krishna_verses.py checks that every cited verse exists.
"""

E = {}


def ep(eid, title, sb=(), mbh=(), note=""):
    E[eid] = dict(title=title, sb=list(sb), mbh=list(mbh), note=note)


# ------------------------------------------------------------------ Bhagavata (canto 10 unless stated)
ep("putana", "Putana killed", sb=[(10, 6, "10-13", "Putana puts her poisoned breast in his mouth; he drinks her life out; she falls")])
ep("sakata", "The cart kicked over", sb=[(10, 7, "7-7", "Baby Krishna kicks the handcart and it collapses")])
ep("butter-pot", "Butter and curd stolen from the hanging pots", sb=[(10, 8, "29-31", "Gopis complain: he steals curd from the swinging pot, piling planks to reach it")])
ep("mud-mouth", "Eating earth; the universe in his mouth", sb=[(10, 8, "32-40", "Playmates say he ate mud; he opens his mouth and Yashoda sees the universe")])
ep("mortar-bound", "Tied to the mortar (Damodara)", sb=[(10, 9, "8-9", "He sits on an upturned mortar giving butter to monkeys, runs when she comes with a stick"),
                                                        (10, 9, "15-18", "Every rope is two fingers short; at last he lets her bind him")])
ep("yamalarjuna", "The twin arjuna trees", sb=[(10, 10, "22-23", "Between the two trees, once Kubera's sons cursed by Narada"), (10, 10, "26-27", "Dragging the mortar he uproots both trees")])
ep("vatsasura", "Vatsasura (calf demon)", sb=[(10, 11, "42-43", "A demon among the calves is caught by the hind legs, whirled and thrown on a tree")])
ep("bakasura", "Bakasura (crane demon)", sb=[(10, 11, "48-51", "The crane swallows Krishna, burns in his throat; Krishna splits its beak")])
ep("kaliya", "Dancing on the serpent Kaliya", sb=[(10, 16, "26-30", "He mounts Kaliya's hoods and dances until the serpent is broken"), (10, 16, "63-67", "Kaliya worships him and leaves")])
ep("flute", "Krishna's flute", sb=[(10, 21, "2-5", "In the forest he plays the flute; the cowherd girls describe him")])
ep("clothes", "The gopis' clothes on the kadamba tree", sb=[(10, 22, "9-15", "He takes the girls' garments up a kadamba tree; they plead")])
ep("govardhana", "Lifting Govardhana", sb=[(10, 25, "19-23", "He lifts the hill with one hand like a child holding a mushroom and holds it seven days")])
ep("kuvalayapida", "Kuvalayapida elephant killed", sb=[(10, 43, "2-15", "At the arena gate he fights the elephant, pulls out a tusk and kills it and its keepers")])
ep("kamsa", "Kamsa killed", sb=[(10, 44, "34-37", "He leaps to the dais, seizes Kamsa by the hair, throws him down")])
ep("kamsa-malice", "Kamsa's cruelty to his sister's child", sb=[(10, 4, "1-5", "Kamsa persecutes the newborn; he is Krishna's maternal uncle")])
ep("naraka-wives", "Naraka killed; the sixteen thousand princesses", sb=[(10, 59, "33-42", "He frees 16,000 princesses and marries them all in separate palaces")])
ep("parijata", "The parijata tree brought for Satyabhama", sb=[(10, 59, "38-40", "He takes Aditi's earrings to Indra's abode and brings the parijata to Satyabhama's garden")])
ep("banasura", "Banasura", sb=[(10, 63, "3-8", "Krishna and Balarama fight Bana's army, with Shiva on Bana's side")], note="Song 272 is a low-confidence match.")
ep("sudama", "Sudama's visit", sb=[(10, 80, "6-14", "The poor brahmin friend takes flat rice to Dwaraka")])
ep("mausala", "The iron pestle thrown into the sea", sb=[(11, 1, "20-21", "The pestle is ground down and its pieces thrown into the sea")],
   mbh=[(16, 4, ["16,004.035a", "16,004.036c"], "The Mausala parva: the iron pestle and the Yadavas' mutual slaughter")],
   note="Mahabharata Mausala parva ch.2-4 (CE 16,2-4).")
# ------------------------------------------------------------------ Mahabharata
ep("embassy", "Krishna's peace embassy to the Kuru court", mbh=[
    (5, 89, ["5,089.034c", "5,089.035c"], "Krishna goes to Vidura's house and stays there"),
    (5, 129, ["5,129.002a", "5,129.004a", "5,129.005a", "5,129.012a"], "Duryodhana tries to seize him; Krishna laughs and shows a blazing form with the gods in it; the kings shut their eyes")],
   note="Vulgate/Ganguli: Bhagavat-yana parva ch.74-150 (Wikipedia numbering) = CE Udyoga adhyayas about 5,70-137.")
ep("gita-chariot", "Krishna drives Arjuna's chariot; the Gita opens", mbh=[
    (6, 23, ["6,023.001a", "6,023.015a", "6,023.021c", "6,023.024c"], "Opening of the Bhagavad Gita: conches, Arjuna asks Krishna to halt the chariot between the armies, Krishna does")],
   note="Gita 1.1 = CE 6,23.1.")
ep("bhishma-shikhandi", "Bhishma falls to Arjuna behind Shikhandi", mbh=[(6, 114, ["6,114.053c"], "Arjuna shoots Bhishma with Shikhandi in front")])
ep("bhishma-wheel", "Krishna takes the wheel against Bhishma", mbh=[(6, 55, ["6,055.086c", "6,055.091a", "6,055.093a"], "Krishna leaps from the chariot, takes up a wheel and rushes at Bhishma")])
ep("jayadratha", "Jayadratha killed; the sun hidden", mbh=[
    (7, 121, ["7,121.015c", "7,121.016a", "7,121.032c"], "Krishna urges Arjuna to cut Jayadratha's head before sunset; Arjuna beheads him (constituted text, no sun-hiding)"),
    (7, 121, ["7,121.014d*1010_03", "7,121.014d*1010_05", "7,121.041b*1025_01"], "Star passage (interpolation): Krishna remembers the Sudarshana discus and has darkness cover the sun; later he withdraws it")],
   note="The Sudarshana/darkness version is in a star passage of the Critical Edition (Vulgate Drona 146, Ganguli section CXLVI).")
ep("duryodhana-fall", "Duryodhana's thighs broken", mbh=[(9, 57, ["9,057.006c", "9,057.044c"], "Bhima smashes Duryodhana's thighs with the mace")])
ep("kirata", "Arjuna and Shiva as the hunter", mbh=[(3, 40, ["3,040.005a", "3,040.011c", "3,040.043a"], "Shiva as a Kirata hunter fights Arjuna"), (3, 41, ["3,041.013a"], "Shiva gives the Pashupata weapon")],
   note="Vulgate: Kairata parva ch.38-41.")
ep("pandava-coronation", "Yudhishthira crowned king", mbh=[(12, 40, ["12,040.015a"], "Yudhishthira is anointed king of the earth")])
ep("war-general", "The Bharata war (general)", mbh=[], note="No single verse: the whole war; see the parvas 6-10.")
ep("exile-general", "Pandavas' exile in the forest", mbh=[], note="Vana parva (3); general reference, no single verse.")
ep("krishna-general", "Krishna (no specific episode)", note="Names Krishna or a cowherd image only.")

# song -> episodes
A_ = {}


def a(song, eps, conf="m", note=""):
    A_[str(song)] = dict(eps=eps.split(), conf=conf, note=note)


a(43, "flute", "m", "Fingering the flute's holes (the seven holes)")
a(116, "yamalarjuna sakata govardhana", "h")
a(121, "butter-pot", "h", "Gopis scold him as a curd-thief")
a(155, "gita-chariot bhishma-shikhandi pandava-coronation", "l", "Chariot-driving, the 'eunuch' (Shikhandi) and the Kuru kingdom given to the Pandavas; reading uncertain")
a(156, "butter-pot mortar-bound", "m")
a(158, "kuvalayapida flute", "h")
a(163, "kaliya", "h")
a(178, "mortar-bound butter-pot", "h")
a(181, "yamalarjuna kamsa-malice", "m")
a(186, "sakata yamalarjuna govardhana", "m")
a(248, "mausala", "m", "Pestle thrown into the sea")
a(289, "embassy butter-pot", "m", "Envoy to the Kuru king; butter; the dwarf is a separate story")
a(339, "gita-chariot war-general", "h")
a(355, "flute sudama", "m")
a(442, "naraka-wives", "h")
a(527, "gita-chariot", "h")
a(541, "embassy war-general", "m", "The discus-bearer who sowed enmity before the war")
a(568, "jayadratha", "h", "Hid the sun: only in the interpolated CE passage")
a(573, "pandava-coronation war-general", "m")
a(574, "embassy gita-chariot jayadratha", "h", "Vidura, Drona, the hundred sons, Jayadratha, Dharma's envoy, Vijaya's charioteer")
a(576, "yamalarjuna", "h")
a(586, "krishna-general", "l", "Per general-songs-review: friend of the cows, not the calf demon")
a(614, "clothes flute", "h")
a(615, "kamsa", "h")
a(620, "kaliya embassy", "m", "Dance on the serpent; friend of the Pandavas")
a(626, "putana bakasura", "m", "Kamsa's messengers: the ogress and the wide-mouthed crane")
a(629, "mortar-bound", "h")
a(674, "govardhana mud-mouth", "m")
a(683, "butter-pot", "h")
a(747, "embassy gita-chariot", "h")
a(752, "krishna-general", "l")
a(770, "govardhana", "h")
a(771, "yamalarjuna", "m")
a(785, "exile-general war-general", "m")
a(806, "embassy", "l", "Friend of the five Pandavas")
a(881, "kaliya", "h")
a(885, "parijata", "m")
a(890, "war-general", "m")
a(908, "yamalarjuna mortar-bound", "h")
a(924, "gita-chariot", "h")
a(928, "gita-chariot", "h")
a(930, "gita-chariot war-general", "m")
a(936, "kamsa", "m")
a(970, "butter-pot", "m")
a(987, "butter-pot", "h")
a(989, "flute", "m")
a(1001, "putana", "h")
a(1006, "kaliya", "m")
a(1009, "flute", "h")
a(1019, "butter-pot", "m")
a(1048, "yamalarjuna flute", "m")
a(1053, "gita-chariot", "m", "Arjuna's chariot and conch; cattle returning")
a(1055, "embassy war-general", "m")
a(1056, "war-general", "m")
a(1060, "gita-chariot war-general", "m")
a(1072, "clothes", "m")
a(1091, "yamalarjuna", "l")
a(1098, "mortar-bound butter-pot", "h")
a(1099, "kaliya", "h")
a(1135, "duryodhana-fall war-general", "m")
a(1157, "kuvalayapida sakata", "m")
a(1170, "mud-mouth flute", "m")
a(1183, "mortar-bound govardhana", "m")
a(1196, "gita-chariot war-general", "m")
a(1244, "clothes", "m")
a(1274, "kamsa-malice kamsa", "m", "Kamsa did not treat his nephew as a nephew; 'மருகன்' here is Krishna")
a(851, "yamalarjuna kamsa", "h")
a(902, "jayadratha", "m", "Per general-songs-review: discus makes the sun set at midday")
a(193, "sakata clothes", "l", "Per general-songs-review")
a(14, "butter-pot", "l", "Per general-songs-review")
a(752, "embassy", "l", "Per general-songs-review")
