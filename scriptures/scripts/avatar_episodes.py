"""Avatar songs (Gajendra, Vamana, Narasimha, churning, Kurma, Varaha, Brahma's origin, Adisesha, banyan leaf, temples):
episodes with verse-level references and the songs that allude to them.

sb:      (canto, chapter, 'first-last', gist)      vedabase.io numbering
valmiki: (kanda, sarga, [shloka numbers], gist)    valmikiramayan.net (Bala uses the page's own [1-sarga-shloka] tags)
kamba:   (kandam, padalam, [verse numbers], gist)  Tamil Wikisource, numbers restart in every padalam
vp:      (book, chapter, doc_id, keyword, gist)    Wilson's Vishnu Purana on wisdomlib; the build checks the keyword is on that page
build_avatar_verses.py fails if any cited verse/keyword is missing.
"""

E = {}


def ep(eid, title, sb=(), valmiki=(), kamba=(), vp=(), note=""):
    E[eid] = dict(title=title, sb=list(sb), valmiki=list(valmiki), kamba=list(kamba), vp=list(vp), note=note)


ep("gajendra", "Gajendra and the crocodile",
   sb=[(8, 2, "27-28", "A crocodile seizes the elephant king's leg in the lake; the herd cannot help"),
       (8, 3, "2-2", "Gajendra's prayer begins by bowing to Vasudeva"),
       (8, 3, "30-33", "Hari comes on Garuda with the discus; Gajendra offers a lotus; the Lord pulls elephant and crocodile out"),
       (8, 4, "3-4", "The crocodile was the gandharva Huhu, freed from a curse"),
       (8, 4, "13-13", "Gajendra is given liberation")],
   note="The Thiruppugazh 'Mulame!' cry is the Tamil devotional form of the elephant's call; the Sanskrit prayer is addressed to Vasudeva/Narayana. "
        "The discus killing the crocodile is a Tamil/Alvar detail more explicit than in the Bhagavata passage cited.")
ep("samudra-manthana", "Churning the milk ocean",
   sb=[(8, 6, "22-23", "Vishnu tells the gods to use Mandara as the rod and Vasuki as the rope"),
       (8, 7, "1-4", "Vasuki summoned; the gods take the tail and the demons the head"),
       (8, 8, "3-6", "Uccaihshravas, Airavata, Kaustubha emerge"),
       (8, 8, "17-17", "Lakshmi takes her garland to Vishnu"),
       (8, 8, "34-36", "Dhanvantari appears with the jug of nectar; the demons snatch it")],
   valmiki=[("bala", 45, [17, 18], "The gods and demons decide to churn the Milky Ocean with Mandara and Vasuki")],
   vp=[(1, 9, 115945, "churn", "Wilson book I chapter IX (Legend of Lakshmi) contains the churning")])
ep("halahala", "The poison drunk by Shiva",
   sb=[(8, 7, "18-19", "The kalakuta poison spreads; all go to Shiva"), (8, 7, "42-42", "Shiva drinks the poison from his palm")],
   valmiki=[("bala", 45, [19, 20, 25], "Halahala rises from Vasuki and from the rocks; Shiva drinks it at Vishnu's word")])
ep("mohini", "Mohini and the nectar",
   sb=[(8, 9, "2-2", "The demons are charmed by the woman"), (8, 9, "8-9", "Mohini smiles and speaks to the demons")],
   note="Nectar given to the gods by Vishnu as Mohini.")
ep("kurma", "The tortoise avatar",
   sb=[(8, 5, "10-10", "Ajita churns the ocean and bears Mandara as a tortoise"), (8, 7, "6-8", "Mandara sinks; the Lord takes a tortoise form and holds it")],
   valmiki=[("bala", 45, [29], "Vishnu as a tortoise holds Mandara at the bottom")],
   vp=[(1, 9, 115945, "tortoise|Kurma", "Same chapter mentions the tortoise")])
ep("vamana", "Vamana and Mahabali; Trivikrama",
   sb=[(8, 18, "12-13", "The dwarf brahmachari appears before the sages"),
       (8, 19, "16-16", "He asks Bali for three paces of land"),
       (8, 20, "23-23", "Bali sees the worlds on the soles of the Lord's cosmic form"),
       (8, 20, "34-34", "The second step covers the heavens; no space for a third"),
       (8, 21, "26-27", "Garuda binds Bali with Varuna's ropes"),
       (8, 22, "32-33", "Bali is sent to Sutala")],
   valmiki=[("bala", 29, [9, 19, 20], "Gods ask Vishnu to take the dwarf form for Bali; the dwarf is born of Aditi; he is Trivikrama")],
   kamba=[("பால_காண்டம்", "வேள்விப்_படலம்", [8, 10, 11, 12, 15, 23, 24, 25, 26, 27],
           "Viswamitra's account: Mavali, the dwarf, three paces, growth, return to the milk-ocean bed")],
   note="Bhagavata's third step is placed on Bali's head at 8.22; the Thiruppugazh lines mostly say 'measured the worlds'.")
ep("narasimha", "Narasimha and Hiranyakashipu",
   sb=[(7, 8, "15-18", "A sound from the pillar; the man-lion form emerges"), (7, 8, "29-31", "He seizes Hiranyakashipu and tears him open")],
   kamba=[("யுத்த_காண்டம்", "இரணியன்_வதைப்_படலம்", [123, 127, 130, 147, 153],
           "Kamba's Narasimha story (told by Vibhishana to Ravana): the pillar, the lion's birth, the fight, the chest torn at dusk at the palace door")],
   vp=[(1, 20, 115956, "Narasimha|man-lion|lion", "Wilson book I chapter XX: Vishnu appears to Prahlada")],
   note="Kamba places the Narasimha story inside the Yuddha Kandam as Vibhishana's warning to Ravana.")
ep("varaha", "Varaha lifts the earth",
   sb=[(3, 13, "18-18", "A tiny boar comes from Brahma's nostril"), (3, 13, "28-31", "The boar searches, dives and lifts the earth on his tusks")],
   vp=[(1, 4, 115939, "boar|Varaha", "Wilson book I chapter IV: Narayana as Varaha")])
ep("brahma-origin", "Brahma born from Vishnu's navel lotus",
   sb=[(3, 8, "14-16", "A lotus grows from Vishnu; Brahma is born in it")])
ep("adisesha", "Vishnu lying on Adisesha in the milk ocean",
   sb=[(3, 8, "10-10", "Vishnu alone on the serpent Ananta over the waters"), (3, 8, "23-23", "Brahma sees the serpent-bed on the water")],
   kamba=[("பால_காண்டம்", "வேள்விப்_படலம்", [27], "After the Vamana story Vishnu returns to his bed on the milk ocean")],
   note="A repeating image rather than one story; the temple songs (Srirangam, Kanchi, Tirupati) use the same image.")
ep("pralaya", "The banyan-leaf child; worlds swallowed",
   sb=[(12, 9, "20-21", "Markandeya sees an infant on a banyan leaf in the flood"), (12, 9, "27-27", "The child inhales and draws the sage inside, where the universe lies as before")])
ep("temple", "Temple Vishnu (Srirangam, Kanchi, Tirupati)",
   note="No Bhagavata or Mahabharata reference. These lines praise a divya desam image; use the Divya Prabandham pass.")

A_ = {}


def a(song, eps, conf="m", note=""):
    A_[str(song)] = dict(eps=eps.split(), conf=conf, note=note)


# Gajendra
for s in (25, 82, 173, 484, 651, 704, 710, 935, 1059, 1084, 1188, 1204, 1336):
    a(s, "gajendra", "h")
a(70, "gajendra halahala", "m", "Poison from the sea, then the elephant")
a(175, "gajendra brahma-origin", "m")
a(403, "samudra-manthana gajendra", "h")
a(963, "gajendra vamana", "m")
a(1001, "gajendra vamana", "h", "Elephant and the world-measuring; the ogress is in the Krishna file")
a(1048, "gajendra", "m", "Elephant 'Mulame'; trees and flute in the Krishna file")
a(1272, "gajendra kurma vamana adisesha", "m", "Crocodile, tortoise, dwarf, serpent bed")
# churning
a(11, "samudra-manthana adisesha", "h")
a(27, "samudra-manthana halahala", "l", "Sea churned; the poison-drinker is Shiva (Murugan's father)")
a(46, "adisesha halahala mohini", "m", "Poison, then the nectar given to the gods")
a(169, "samudra-manthana halahala mohini", "h")
a(367, "samudra-manthana mohini vamana", "h")
a(723, "samudra-manthana kurma", "h", "Mountain planted, serpent wound round, nectar")
a(952, "samudra-manthana mohini", "h")
a(1044, "samudra-manthana", "h", "Sea churned, Lakshmi won")
a(1076, "samudra-manthana", "h", "Mountain and moon whirled")
# Vamana
a(134, "vamana adisesha temple", "h", "Srirangam lord on the serpent; measured the world")
a(248, "vamana", "h", "Mahabali imprisoned")
a(289, "vamana", "m", "The dwarf; envoy and butter are in the Krishna file")
a(293, "vamana", "h")
a(573, "vamana", "m", "The dwarf who 'measured'; the war is in the Krishna file")
a(771, "vamana", "m")
a(841, "vamana", "h", "Mahabali sent down with a step")
a(912, "vamana", "m", "Foot measuring the fourteen worlds")
a(970, "vamana pralaya", "h", "Measured the earth; on the banyan leaf; butter is in the Krishna file")
a(1008, "vamana adisesha", "m")
a(1103, "vamana pralaya", "m", "Measured and swallowed the earth")
a(1256, "vamana", "m", "Asks the king for a gift")
a(1311, "vamana", "h")
# Narasimha
for s in (88, 526, 872, 887, 1174):
    a(s, "narasimha", "h")
a(150, "narasimha brahma-origin adisesha", "h")
a(545, "narasimha varaha", "h")
a(652, "narasimha temple", "h", "Hiranya torn; sleeps at Srirangam")
a(1006, "narasimha", "h", "Prahlada and the lion; the Kaliya dance is in the Krishna file")
a(1183, "narasimha", "m", "Hiranya's chest; the rope-binding and hill are in the Krishna file")
# origin / pralaya
a(612, "brahma-origin", "m", "Narayana as father of the four-faced")
a(743, "brahma-origin", "m")
a(276, "pralaya", "m", "He who swallowed the world")
a(402, "pralaya", "m", "He who swallowed the worlds")
a(727, "pralaya temple", "m", "Banyan leaf; Ooragam (Kanchi)")
# reclining and temples
for s in (168, 199, 253, 525, 679, 693, 738, 806, 828, 881, 987, 1075, 1081, 1091, 1237, 1253):
    a(s, "adisesha", "m")
a(895, "adisesha temple", "m", "Serpent bed at Kanchi")
a(362, "temple", "m")
a(549, "temple", "m")
a(812, "temple", "h", "Vengadam (Tirupati)")
a(971, "temple", "m")
a(233, "varaha", "m", "Per general-songs-review: boar lifting the earth")
a(875, "gajendra", "l", "Per general-songs-review")
a(534, "adisesha", "l", "Per general-songs-review")
a(587, "adisesha", "l", "Per general-songs-review")
a(679, "adisesha", "l", "Milk-sea sleep")
a(808, "adisesha", "l", "Per general-songs-review")
a(1325, "vamana", "l", "Per general-songs-review: Trivikrama; the rest of the song is about the jewels")
