"""Ramayana episodes with verse-level references, and which songs allude to which episode.

Valmiki: (kanda, sarga, shloka range, gist in my words). Numbering = valmikiramayan.net (checked in session 1).
         Bala and Kishkindha pages use a different translator's verse numbering; shloka numbers there follow the
         bracketed [kanda-sarga-shloka] tags on that site.
Kamba:   (kandam, padalam, [verse numbers]). Verse numbers are per padalam, as on Tamil Wikisource.
         build_ramayana_verses.py checks each cited number exists and quotes the verse.
"""

E = {}


def ep(eid, title, valmiki, kamba, note=""):
    E[eid] = dict(title=title, valmiki=valmiki, kamba=kamba, note=note)


Y, S, A, K, B, AY = "Yuddha", "Sundara", "Aranya", "Kishkindha", "Bala", "Ayodhya"
YK, SK, AK, KK, BK, AYK = "யுத்த_காண்டம்", "சுந்தர_காண்டம்", "ஆரணிய_காண்டம்", "கிட்கிந்தா_காண்டம்", "பால_காண்டம்", "அயோத்தியா_காண்டம்"

ep("birth", "Rama's birth and childhood",
   [(B, 18, "18.7–14", "Births of Rama and his brothers; Rama as Vishnu's portion")],
   [(BK, "திரு_அவதாரப்_படலம்", [])], "Song 68 (Kausalya calling the child) has no exact verse; the allusion is general.")
ep("tataka", "Tataka killed", [(B, 26, "26.25", "Tataka is felled by Rama's arrow")],
   [(BK, "தாடகை_வதைப்_படலம்", [45, 49])])
ep("yajna", "Vishwamitra's sacrifice protected", [(B, 31, "31 (whole sarga)", "Rama guards the sacrifice; Subahu killed, Maricha flung away")],
   [(BK, "வேள்விப்_படலம்", [39, 41])])
ep("ahalya", "Ahalya freed", [(B, 49, "49.16–17", "Rama and Lakshmana touch Ahalya's feet after the curse ends")],
   [(BK, "அகலிகைப்_படலம்", [14, 15])],
   "In Valmiki Rama does not touch the stone with his foot; the 'dust of his feet frees her' image is Kamba (Ahalya padalam 14).")
ep("bow", "Shiva's bow broken", [(B, 67, "67.17", "The bow is broken at the handgrip; the break described to Janaka")],
   [(BK, "கார்முகப்_படலம்", [33, 35])])
ep("exile", "Exile at the mother's word", [(AY, 11, "11 (whole sarga)", "Kaikeyi's boons"), (AY, 40, "40 (whole sarga)", "Rama leaves Ayodhya")],
   [(AYK, "கைகேயி_சூழ்ச்சிப்_படலம்", [14, 111, 113, 114]), (AYK, "நகர்_நீங்கு_படலம்", [8, 14])])
ep("kaka", "The crow loses an eye", [(S, 38, "38.15–36", "Sita tells Hanuman how a crow clawed her; Rama's grass blade as Brahma weapon; the crow loses its right eye")],
   [(SK, "காட்சிப்_படலம்", [28]), (SK, "சூடாமணிப்_படலம்", [77])],
   "Kamba does not tell the crow episode in the Chitrakuta padalam (no 'காக' there); it is recalled in Sundara Kandam.")
ep("khara", "Khara, Dushana and Trishira killed", [(A, 30, "30.26–31", "Rama's arrow lands in Khara's chest; fourteen thousand rakshasas destroyed")],
   [(AK, "கரன்_வதைப்_படலம்", [127, 131, 136, 158, 161, 182, 185])],
   "Kamba order: Trishira loses two heads (127), fights on (131), falls (136); Dushana loses his head (161); Khara's right arm (182) and head (185).")
ep("sita-abduction", "Surpanakha mutilated; Ravana carries Sita off", [(A, 18, "18.21", "Lakshmana cuts off Surpanakha's ears and nose"), (A, 49, "49.23", "Ravana carries Sita off through the sky")],
   [(AK, "சூர்ப்பணகைப்_படலம்", []), (AK, "இராவணன்_சூழ்ச்சிப்_படலம்", [])], "Kamba verses not pinned yet.")
ep("sita-jewels", "Sita's dropped jewels", [(K, 6, "6.11–20", "Sugriva shows Rama the ornaments and cloth Sita dropped")], [], "Kamba not located.")
ep("maricha", "Maricha as the golden deer", [(A, 44, "44.16–23", "Maricha struck by Rama's arrow, cries in Rama's voice, dies")],
   [(AK, "மாரீசன்_வதைப்_படலம்", [43, 47, 75, 77, 80])],
   "43: Maricha becomes the golden deer; 47: Sita does not see the trick; 77: he falls crying out; 80: Rama realises the cry was Maricha's imitation.")
ep("seven-trees", "Seven sala trees pierced", [(K, 12, "12.3–5", "One arrow pierces seven sala trees and the earth below")],
   [(KK, "மராமரப்_படலம்", [12, 15, 16])])
ep("garland", "Garland to mark Sugriva", [(K, 12, "12.39–41", "Rama has a gaja creeper hung round Sugriva's neck so he can be recognised in the fight")],
   [(KK, "வாலி_வதைப்_படலம்", [61])],
   "Kamba verse 61: Rama tells Sugriva to go wearing a flowering creeper (கொடிப் பூ).")
ep("vali", "Vali killed", [(K, 16, "16.32–36", "Rama draws and releases the arrow; it lands in Vali's chest")],
   [(KK, "வாலி_வதைப்_படலம்", [65, 66, 67])])
ep("sugriva-crown", "Sugriva crowned", [(K, 26, "26 (whole sarga)", "Sugriva's coronation")],
   [(KK, "அரசியற்_படலம்", [5])], "In Kamba Lakshmana places the crown on Sugriva at Rama's order (verse 5).")
ep("army-march", "The vanara army marches to Lanka", [(Y, 4, "4.62–70", "The army marches south, eager for Sita's release")],
   [(KK, "தானை_காண்_படலம்", [])])
ep("lanka-burnt", "Hanuman burns Lanka", [(S, 53, "53.3–5", "Ravana orders the monkey's tail burnt"), (S, 54, "54.6–47", "Hanuman leaps from roof to roof and burns the city")],
   [(SK, "இலங்கை_எரியூட்டு_படலம்", [1, 6, 32, 37])])
ep("ocean-arrow", "Rama's anger at the ocean", [(Y, 21, "21.17–26", "Rama threatens to dry the ocean, takes the bow and looses the arrow")],
   [(YK, "கடல்_சீறிய_படலம்", [4, 12, 13, 16])])
ep("setu", "The bridge built", [(Y, 22, "22.50–78", "Nala builds the bridge; five days' progress at 22.66–70; description at 22.72–78")],
   [(YK, "சேது_பந்தனப்_படலம்", [8, 10, 46, 65, 66])])
ep("vibhishana-refuge", "Vibhishana takes refuge", [(Y, 17, "17.17–26", "Vibhishana comes to Rama for refuge"), (Y, 19, "19.4", "He asks for refuge as Ravana's brother")],
   [(YK, "வீடணன்_அடைக்கலப்_படலம்", [12, 13, 121, 129, 143])],
   "In Kamba Rama grants refuge through Sugriva (121) and makes Vibhishana the seventh brother (143); in Valmiki the debate with Sugriva comes first.")
ep("crown-sugriva", "Sugriva snatches Ravana's crown", [(Y, 40, "40.11", "Sugriva pulls Ravana's crown off and throws it down")],
   [(YK, "மகுட_பங்கப்_படலம்", [32, 45])])
ep("crown-rama", "Rama shatters Ravana's crown", [(Y, 59, "59.140–144", "Rama's crescent arrow shatters Ravana's diadem; Ravana flees to Lanka")],
   [(YK, "முதற்_போர்_புரி_படலம்", [244, 245, 247, 250])],
   "Kamba 244-245: Rama's arrow drops Ravana's crown into the sea; 250: Rama tells him 'go today, come tomorrow' (Valmiki 59.141 ff.).")
ep("kumbhakarna", "Kumbhakarna killed", [(Y, 67, "67.165–172", "Rama cuts off his head; the body falls on Lanka's wall")],
   [(YK, "கும்பகருணன்_வதைப்_படலம்", [337, 344, 357, 359])])
ep("kumbha", "Kumbha killed by Sugriva", [(Y, 76, "76.92–93", "Sugriva's blow fells Kumbha")],
   [(YK, "அதிகாயன்_வதைப்_படலம்", [236, 245, 246])], "Kamba tells Kumbha's death inside the Atikayan padalam.")
ep("atikaya", "Atikaya killed", [(Y, 71, "71.111", "Lakshmana cuts off his head")],
   [(YK, "அதிகாயன்_வதைப்_படலம்", [190, 204, 205, 206])],
   "Kamba: Lakshmana uses the Brahma weapon on Atikaya (204-205), as Vayu advises; in Valmiki also the Brahma missile.")
ep("indrajit", "Indrajit killed", [(Y, 90, "90 (whole sarga)", "Lakshmana kills Indrajit")],
   [(YK, "இந்திரசித்து_வதைப்_படலம்", [51, 53])])
ep("army-destroyed", "Ravana's army destroyed", [(Y, 93, "93.7–34", "Rama destroys the rakshasa troops")],
   [(YK, "படைத்_தலைவர்_வதைப்_படலம்", [])], "General battle; no single verse.")
ep("heads-cut", "Ravana's heads cut off and regrow", [(Y, 107, "107.54–58", "Rama cuts Ravana's head; it regrows; a hundred are cut")],
   [(YK, "இராவணன்_வதைப்_படலம்", [148, 149, 151, 154, 161, 162])])
ep("ravana-death", "Ravana killed by the Brahma weapon", [(Y, 108, "108.15–22", "Rama looses the Brahma weapon; it tears Ravana's heart; he falls from his chariot")],
   [(YK, "இராவணன்_வதைப்_படலம்", [194, 195, 196])])
ep("sita-freed", "Sita brought to Rama", [(Y, 113, "113", "Hanuman tells Sita of the victory"), (Y, 114, "114", "Vibhishana brings Sita")],
   [(YK, "பிராட்டி_திருவடி_தொழுத_படலம்", [25, 34, 44])])
ep("sita-agni", "Sita's fire ordeal", [(Y, 118, "118.5", "Agni returns Sita unharmed")],
   [(YK, "பிராட்டி_திருவடி_தொழுத_படலம்", [66, 71, 73])])
ep("vibhishana-crown", "Vibhishana crowned", [(Y, 112, "112.16", "Vibhishana is consecrated king of Lanka")],
   [(YK, "வீடணன்_அடைக்கலப்_படலம்", [141, 142]), (YK, "வீடணன்_முடி_சூட்டு_படலம்", [6, 7])],
   "Kamba has two scenes: Rama orders the crown at the refuge scene (141-142) and Lakshmana crowns him after Ravana's death (Mudi suttu 6).")
ep("return", "Return to Ayodhya and coronation", [(Y, 128, "128", "Rama's coronation")],
   [(YK, "மீட்சிப்_படலம்", [4]), (YK, "திருமுடி_சூட்டு_படலம்", [11, 12])])

# song id -> episodes (first = main allusion). 'conf' h/m/l; notes only where the line is ambiguous.
A_ = {}


def a(song, eps, conf="m", note=""):
    A_[str(song)] = dict(eps=eps.split(), conf=conf, note=note)


# --- Ravana war group (the 71 songs)
a(19, "setu ravana-death", "m", "Bridge, then Lanka's king and clan fall to one arrow")
a(27, "army-destroyed", "l", "Night-roamers' heads shattered; no single scene")
a(29, "setu heads-cut", "m", "Bridge; Ravana's many crowns cut by Raghava's arrow")
a(44, "heads-cut", "m")
a(66, "army-destroyed heads-cut", "l")
a(73, "ravana-death", "l")
a(89, "heads-cut", "l", "Heads fall like balls")
a(115, "heads-cut", "l")
a(166, "setu heads-cut sita-freed", "m")
a(200, "lanka-burnt heads-cut army-destroyed", "l", "Fire in Lanka, then the heads and army")
a(203, "setu heads-cut", "m")
a(227, "ravana-death", "m", "The Ravana who lifted the mountain falls to one arrow")
a(230, "heads-cut army-destroyed", "l")
a(236, "heads-cut ravana-death", "m", "Ten heads and twenty arms felled by one arrow")
a(248, "heads-cut", "m")
a(252, "heads-cut sita-freed", "m")
a(293, "heads-cut", "m")
a(365, "heads-cut", "m")
a(373, "lanka-burnt setu army-destroyed", "m")
a(381, "heads-cut", "m", "Ten crowns shot off")
a(435, "heads-cut sita-freed", "m")
a(466, "heads-cut", "m")
a(481, "heads-cut", "m")
a(489, "heads-cut", "m")
a(512, "heads-cut", "m")
a(524, "army-destroyed heads-cut", "m", "Hanuman's army besieges Lanka's wall; ten crowns fall")
a(540, "heads-cut", "m")
a(597, "exile vali ravana-death", "m")
a(623, "vibhishana-refuge army-destroyed", "m", "Kumbhakarna's younger brother (Vibhishana) surrenders")
a(633, "heads-cut", "m")
a(644, "heads-cut", "l")
a(684, "heads-cut", "m")
a(700, "lanka-burnt setu", "m")
a(703, "ravana-death sita-freed", "m")
a(707, "army-destroyed ravana-death", "l")
a(731, "seven-trees vali heads-cut", "m")
a(737, "heads-cut", "m")
a(745, "heads-cut", "m")
a(750, "setu army-destroyed", "m")
a(788, "army-destroyed sita-freed", "m")
a(806, "army-destroyed", "l")
a(807, "setu army-destroyed", "m")
a(826, "heads-cut", "m")
a(833, "heads-cut sita-freed", "m")
a(835, "lanka-burnt kumbha", "m", "Lanka burns; Kumbha killed")
a(838, "heads-cut", "m")
a(839, "setu army-destroyed", "m")
a(841, "heads-cut vibhishana-crown", "m")
a(845, "heads-cut army-destroyed", "m")
a(874, "heads-cut", "m")
a(876, "army-destroyed", "l")
a(882, "vali army-destroyed", "m")
a(887, "heads-cut", "m")
a(893, "army-destroyed", "l")
a(895, "heads-cut", "m")
a(959, "ravana-death return", "m")
a(961, "khara kumbhakarna", "l", "Khara, Trisira, Kumbhakarna listed together")
a(977, "heads-cut", "m")
a(1007, "heads-cut", "m")
a(1008, "heads-cut", "m")
a(1012, "heads-cut", "m")
a(1132, "heads-cut", "m")
a(1144, "heads-cut", "m")
a(1153, "heads-cut", "m")
a(1162, "heads-cut ravana-death", "l", "Ravana split in two by an arrow")
a(1197, "heads-cut", "m")
a(1218, "setu heads-cut", "m")
a(1231, "lanka-burnt army-march heads-cut", "m")
a(1245, "heads-cut", "m")
a(1316, "setu heads-cut", "m")
# --- other Rama songs
a(68, "birth", "l", "Kausalya's call to the child; no exact verse")
a(366, "tataka yajna", "h")
a(649, "tataka bow", "h")
a(483, "ahalya", "h")
a(669, "ahalya", "h")
a(799, "bow", "h")
a(968, "bow exile", "h")
a(228, "kaka", "h")
a(1295, "khara", "m")
a(113, "maricha vali", "h")
a(941, "army-march lanka-burnt", "m")
a(266, "garland vali", "m")
a(437, "vali", "h")
a(840, "vali setu vibhishana-crown", "h")
a(738, "ocean-arrow", "m")
a(771, "ocean-arrow", "m")
a(820, "ocean-arrow", "h")
a(1091, "ocean-arrow", "m")
a(1125, "ocean-arrow setu", "m")
a(423, "vibhishana-crown", "m")
a(128, "vibhishana-crown sugriva-crown", "l", "'Younger brother' could be either")
a(161, "vibhishana-crown sita-agni", "h")
a(1265, "exile lanka-burnt", "h")
a(655, "setu", "h")
a(272, "sita-abduction heads-cut", "m", "Per general-songs-review: Surpanakha, Sita carried off, Ravana's clan uprooted")
a(9, "army-destroyed", "l", "Per general-songs-review")
a(95, "army-destroyed", "l", "Per general-songs-review")
a(237, "ocean-arrow", "l", "Per general-songs-review")
a(1325, "sita-jewels", "l", "Per general-songs-review; also Trivikrama")
