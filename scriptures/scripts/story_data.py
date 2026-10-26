"""Story metadata for scriptures/vishnu: brief + source pointers per story slug.

Marks:  ✔ = checked this session against an online source (named in SOURCES.md)
        ? = from memory, still to be checked
Verse numbers: Valmiki = kanda.sarga (valmikiramayan.net numbering). Kamba = padalam name
(verse numbers inside a padalam differ by edition; to be added once an edition is chosen).
Mahabharata chapter ranges follow the traditional (Vulgate/Ganguli-style) sub-parva numbering
as given by Wikipedia, not the Critical Edition. Bhagavata = canto.chapter (vedabase.io).
Vishnu Purana = Wilson's book.chapter. DP = Nalayira Divya Prabandham.
"""

S = {}


def story(slug, title, brief, **refs):
    S[slug] = dict(title=title, brief=brief, **refs)


# ---------------------------------------------------------------- Ramayana
story("ram-childhood", "Rama's childhood / Kausalya's love",
      "Kausalya calls the infant Rama to her ('come here, king'). The Thiruppugazh image is of the child Vishnu "
      "as a mother's baby.",
      valmiki="Bala 18 ✔ (births of Rama and brothers)", kamba="Bala: திரு அவதாரப் படலம் ✔",
      bhagavata="9.10 ?", dp="Perumal Thirumozhi 8 (Kulasekhara's lullaby of Rama) ?")
story("ram-tataka-yajna", "Tataka killed; Vishwamitra's sacrifice protected",
      "Vishwamitra takes the boy Rama and Lakshmana to guard his yajna. On the way Rama kills the demoness Tataka, "
      "receives divine missiles, then protects the sacrifice at Siddhashrama from Maricha and Subahu.",
      valmiki="Bala 19–31 ✔ (Tataka killed 26 ✔; weapons 27–28 ✔; sacrifice protected 31 ✔)",
      kamba="Bala: தாடகை வதைப் படலம் ✔, வேள்விப் படலம் ✔", bhagavata="9.10 ?")
story("ram-ahalya", "Ahalya freed from the curse",
      "On the way to Mithila the dust of Rama's feet frees Ahalya, Gautama's wife, who had stood as stone/unseen "
      "for years after Indra's deceit. Murugan's hymn picks 'the foot that touched the stone'.",
      valmiki="Bala 48–49 ✔ (50 continues ✔)", kamba="Bala: அகலிகைப் படலம் ✔",
      dp="Periya Tirumozhi / Kulasekhara allude to Ahalya (exact verses to find) ?")
story("ram-sita-swayamvara", "Shiva's bow broken; Sita's wedding",
      "At Mithila King Janaka offers Sita to whoever strings Shiva's bow. Rama lifts and breaks it; the weddings follow. "
      "Parashurama then challenges Rama and is humbled.",
      valmiki="Bala 66–67 ✔ (bow), 73 ✔ (wedding), 74–76 ✔ (Parashurama)",
      kamba="Bala: கார்முகப் படலம் ✔ (bow), கடிமணப் படலம் ✔, பரசுராமப் படலம் ✔",
      bhagavata="9.10 ?")
story("ram-exile", "Exile to the forest",
      "On the eve of his coronation Kaikeyi claims her two boons and Rama goes to the forest at his father's word with "
      "Sita and Lakshmana. Several verses name this as the Lord 'going to the forest at his mother's word'.",
      valmiki="Ayodhya 3 ✔ (coronation preparation), 11 ✔ (Kaikeyi's boons), 40 ✔ (departure)",
      kamba="Ayodhya: மந்திரப் ✔, கைகேயி சூழ்ச்சிப் ✔, நகர் நீங்கு ✔, குகப் படலம் ✔",
      dp="Perumal Thirumozhi 9 (Dasaratha's lament) ?")
story("ram-kakasura", "The crow (Kakasura/Jayanta)",
      "A crow (Indra's son) pecks at Sita; Rama takes a blade of grass, empowers it as a missile and blinds the crow's eye, "
      "sparing its life. Sita later tells it to Hanuman as a token of Rama's compassion.",
      valmiki="Sundara 38.15–36 ✔ (Sita tells it), retold Sundara 67 ✔ (Hanuman to Rama)",
      kamba="Sundara: காட்சிப் படலம் 28 ✔, சூடாமணிப் படலம் 77 ✔",
      notes="Thiruppugazh 228 'காது மொருவிழி காக முறஅருள்' (the crow loses one eye).")
story("ram-khara-dushana", "Khara, Dushana and Trishira killed",
      "After Surpanakha is mutilated, her brother Khara marches with fourteen thousand rakshasas. Rama alone destroys them "
      "and their generals Dushana and Trishira.",
      valmiki="Aranya 17–19 ✔ (Surpanakha), 20–30 ✔ (the battle; Dushana 26, Trishira 27, Khara 30)",
      kamba="Aranya: சூர்ப்பணகைப் ✔, கரன் வதைப் படலம் ✔")
story("ram-maricha", "Maricha as the golden deer",
      "Ravana asks Maricha to lure Rama away; Maricha becomes a golden deer, Sita asks for it, and Rama follows and kills "
      "it. Maricha's cry draws Lakshmana off, and Ravana carries Sita away.",
      valmiki="Aranya 35–41 ✔ (Ravana and Maricha), 42–44 ✔ (deer, lure, Maricha killed), 49 ✔ (abduction)",
      kamba="Aranya: மாரீசன் வதைப் படலம் ✔, இராவணன் சூழ்ச்சிப் படலம் ✔")
story("ram-sugriva", "Friendship with Sugriva; the monkey army",
      "Hanuman brings Rama and Sugriva together; they swear friendship before fire. Sugriva's armies are gathered and "
      "sent to find Sita and then march to Lanka.",
      valmiki="Kishkindha 3 ✔ (Hanuman meets Rama), 5 ✔ (friendship); Yuddha 4 ✔ (march)",
      kamba="Kishkindha: அனுமப் ✔, நட்புக் கோட் ✔, தானை காண் ✔")
story("ram-seven-trees", "The seven sala trees",
      "To prove his strength to Sugriva, Rama's single arrow pierces seven sala trees and returns to his quiver.",
      valmiki="Kishkindha 12.3–5 ✔", kamba="Kishkindha: மராமரப் படலம் ✔")
story("ram-vali", "Vali killed",
      "Sugriva fights his brother Vali, who has driven him out; Rama, hidden by a tree, shoots Vali. Tara, Vali's wife, "
      "laments; Sugriva is crowned. The 'garland to mark Sugriva' is the identification used in the second fight.",
      valmiki="Kishkindha 16 ✔ (Vali falls), 20 ✔/23 ✔ (Tara's lament), 22 ✔ (Vali's words), 26 ✔ (Sugriva crowned)",
      kamba="Kishkindha: வாலி வதைப் ✔, தாரை புலம்புறு ✔, அரசியற் ✔",
      bhagavata="9.10 ?")
story("ram-hanuman-lanka", "Hanuman in Lanka; Lanka burned",
      "Hanuman leaps the sea, finds Sita, gives her Rama's ring and takes her jewel back. Captured by Indrajit, "
      "his tail is set alight and he burns Lanka.",
      valmiki="Sundara 1 ✔ (leap), 15 ✔ (sees Sita), 36 ✔ (ring), 38 ✔ (token), 48 ✔ (Indrajit), 53–54 ✔ (tail, burning), 57 ✔ (return)",
      kamba="Sundara: கடல் தாவு ✔, காட்சிப் ✔, உருக் காட்டு ✔, சூடாமணிப் ✔, இலங்கை எரியூட்டு படலம் ✔")
story("ram-samudra-arrow", "Rama's anger at the ocean",
      "When the sea-god does not appear Rama takes his bow against the ocean; frightened, the sea-god advises him how to "
      "build the bridge.",
      valmiki="Yuddha 21 ✔ (angry at ocean), 22 ✔ (sea-god advises)",
      kamba="Yuddha: கடல் சீறிய படலம் ✔, வருணன் அடைக்கலப் படலம் ✔")
story("ram-setu", "The bridge to Lanka (Setu)",
      "The monkeys build a causeway across the sea with Nala as architect; the whole army crosses to Lanka.",
      valmiki="Yuddha 22 ✔ (Setu construction), 31 ✔ (enters Lanka)",
      kamba="Yuddha: சேது பந்தனப் படலம் ✔ (71 verses in the Wikisource text)", bhagavata="9.10 ?",
      dp="Periya Tirumozhi / Tirumangai Alvar on Setu ? ")
story("ram-vibhishana", "Vibhishana takes refuge; crowned king of Lanka",
      "Ravana's brother Vibhishana, rejected for urging the return of Sita, joins Rama and is given refuge. After Ravana's "
      "death Rama installs him king of Lanka.",
      valmiki="Yuddha 17–19 ✔ (joins Rama), 112 ✔ (installation)",
      kamba="Yuddha: வீடணன் அடைக்கலப் படலம் ✔, வீடணன் முடி சூட்டு படலம் ✔")
story("ram-vibhishana-sugriva", "Crown given to the younger brother (Vibhishana or Sugriva)",
      "Song 128 does not say which 'younger brother' received the crown; both are options.",
      valmiki="See ram-vali and ram-vibhishana")
story("ram-ravana-war", "The war with Ravana; his ten heads cut",
      "Rama and Lakshmana, with the vanara army, fight Ravana's rakshasas: Kumbhakarna, Atikaya, Indrajit and Ravana "
      "fall. Rama cuts Ravana's ten heads with arrows. This is the most common story in the list (about 70 songs).",
      valmiki="Yuddha 67 ✔ (Kumbhakarna), 71 ✔ (Atikaya), 85–91 ✔ (Indrajit), 99–108 ✔ (Rama-Ravana), 108 ✔ (Ravana killed)",
      kamba="Yuddha: கும்பகருணன் வதைப் ✔, அதிகாயன் வதைப் ✔, இந்திரசித்து வதைப் ✔, இராவணன் வதைப் படலம் ✔",
      bhagavata="9.10 ?",
      dp="Tiruppavai 12 ✔ (Lanka's lord), 24 ✔ (Lanka destroyed); many Periya Tirumozhi / Kulasekhara verses ?")
story("ram-sita-recovery", "Sita freed from Ravana's captivity",
      "After the victory Hanuman tells Sita and Vibhishana brings her to Rama. The Thiruppugazh lines treat the war as "
      "freeing Sita from prison.",
      valmiki="Yuddha 113 ✔, 114 ✔", kamba="Yuddha: பிராட்டி திருவடி தொழுத படலம் ✔")
story("ram-sita-agni", "Sita's fire ordeal",
      "Rama asks Sita to prove her purity; she enters the fire, and Agni returns her unharmed.",
      valmiki="Yuddha 115–118 ✔ (118 Fire-god returns her)",
      kamba="Yuddha: பிராட்டி திருவடி தொழுத படலம் ✔ (Kamba's wording differs; compare)")
story("ram-pattabhishekam", "Return to Ayodhya and coronation",
      "Rama, Sita and Lakshmana return by the Pushpaka chariot; Rama is crowned king.",
      valmiki="Yuddha 121–128 ✔ (128 coronation)", kamba="Yuddha: மீட்சிப் ✔, திருமுடி சூட்டு படலம் ✔")
story("ram-sita", "Rama and Sita (no specific episode)",
      "Song 115 only mentions Raghurama as Sita's husband; no deed named.", valmiki="—")
story("ram-general", "Rama (no specific episode)",
      "The line names Rama, Raghava or Dasaratha's son without an episode. Read the song for any hints before assigning.",
      valmiki="—")

story("ram-sita-abduction", "Surpanakha mutilated; Ravana carries Sita off",
      "After Lakshmana cuts off Surpanakha's nose and ears, Ravana lures Rama away with the golden deer and carries Sita through the sky.",
      valmiki="Aranya 18.21 ✔ (mutilation), 49.23 ✔ (abduction)",
      kamba="Aranya: சூர்ப்பணகைப் படலம் ✔, இராவணன் சூழ்ச்சிப் படலம் ✔ (verses not pinned)")
story("ram-sita-jewels", "Sita's dropped jewels",
      "As Ravana carries her off Sita drops her ornaments and upper cloth among the monkeys; Sugriva later shows them to Rama.",
      valmiki="Kishkindha 6.11–20 ✔", kamba="Kishkindha: நட்புக் கோட் படலம் ? (to check)")

# ------------------------------------------------------------------ Krishna
story("krishna-putana", "Putana killed",
      "The ogress Putana, sent by Kamsa, tries to nurse the infant Krishna with poisoned milk; he drinks her life out.",
      bhagavata="10.6 ✔", vp="5.5 ✔", dp="Tiruppavai 6 ✔ (Putana, cart, serpent bed); Periyazhwar Thirumozhi 1st Pattu ?")
story("krishna-sakata", "The cart demon (Sakatasura)",
      "Baby Krishna kicks a heavy cart haunted by a demon, and it shatters.",
      bhagavata="10.7 ?", vp="5.6 ✔", dp="Tiruppavai 6 ✔, 24 ✔")
story("krishna-butter", "Butter theft; tied to the mortar (Damodara)",
      "Krishna steals butter and curds from the hanging pots (uri) in gopi houses. Yashoda ties him to a wooden mortar "
      "with a rope, giving him the name Damodara.",
      bhagavata="10.8 ✔ (mud-eating, butter) / 10.9 ✔ (Yashoda binds him)",
      dp="Tiruppavai 5 ? (Damodara); Periyazhwar Thirumozhi 1st Pattu ?")
story("krishna-mannunda", "Eating mud; the universe in his mouth",
      "Accused of eating mud, Krishna opens his mouth and Yashoda sees the whole universe inside.",
      bhagavata="10.8 ✔")
story("krishna-yamalarjuna", "The twin arjuna trees",
      "Dragging the mortar, Krishna passes between two arjuna (maruda) trees; they break and release Kubera's sons "
      "Nalakuvara and Manigriva from Narada's curse.",
      bhagavata="10.10 ✔", vp="5.? (not found in the contents list) ?", dp="Periya Tirumozhi / Periyazhwar ? ")
story("krishna-vatsasura", "Vatsasura (the calf demon)",
      "A demon comes as a calf among the herd; Krishna swings it against a vilva/wood-apple tree.",
      bhagavata="10.11 ?", dp="Tiruppavai 24 ? ('கன்று குணிலா எறிந்தாய்')")
story("krishna-kaliya", "Dancing on the serpent Kaliya",
      "Krishna jumps into the Yamuna, dances on the hoods of the five-headed serpent Kaliya and sends him away.",
      bhagavata="10.16 ✔–17 ✔", vp="5.7 ✔", dp="Periyazhwar Thirumozhi ? ")
story("krishna-cowherd", "Cowherd life at Vrindavan",
      "Cattle-keeping scenes: grazing, calling the herd with the flute, cowherds' hamlets.",
      bhagavata="10.11–10.15 ?")
story("krishna-flute", "Krishna's flute",
      "Krishna plays the flute in Vrindavan, drawing cows, animals and gopis.",
      bhagavata="10.21 ?", dp="Periyazhwar Thirumozhi ? ")
story("krishna-vastra-harana", "Gopis' clothes on the kurunda tree",
      "Gopis bathing in the Yamuna to win Krishna as husband find their clothes taken to the kurunda (kadamba) tree.",
      bhagavata="10.22 ?", dp="Tiruppavai 20–? ?")
story("krishna-govardhana", "Lifting Govardhana",
      "When Indra's rain threatens Vrindavan, Krishna lifts Govardhana hill on one hand as an umbrella for seven days.",
      bhagavata="10.24 ✔–25 ✔", vp="5.11 ✔–12 ✔", dp="Tiruppavai 24 ✔ ('குன்று குடையாய் எடுத்தாய்')")
story("krishna-kuvalayapida", "Kuvalayapida elephant killed",
      "At Mathura's gate Krishna meets Kamsa's elephant Kuvalayapida, breaks its tusks and kills it.",
      bhagavata="10.43 ✔")
story("krishna-kamsa", "Kamsa killed",
      "Krishna and Balarama go to Mathura, defeat the wrestlers and kill their maternal uncle Kamsa.",
      bhagavata="10.44 ✔", vp="5.? (nearest listed: 5.16 Keshin, 5.18 depart for Mathura) ?",
      dp="Tiruppavai 5 ? ")
story("krishna-pandava-friend", "Friend and counsellor of the Pandavas",
      "Krishna as the Pandavas' ally and friend, steering the Kurukshetra war.",
      mbh="Udyoga Bhagavat-yana ch.74–150 ✔ (peace mission), Bhishma Gita ch.25–42 ✔")
story("krishna-envoy", "Krishna's peace mission to Hastinapura",
      "Before the war Krishna goes to the Kuru court as envoy, stays with Vidura, asks for five villages, and when Duryodhana "
      "tries to seize him shows his divine form.",
      mbh="Udyoga: Bhagavat-yana Parva ch.74–150 ✔ (Vulgate/Ganguli numbering)",
      notes="Songs naming 'Vidura' (747, 574) point to Krishna staying at Vidura's house.")
story("krishna-partha-sarathi", "Krishna as Arjuna's charioteer",
      "Krishna drives Arjuna's chariot through the Kurukshetra war and speaks the Gita at its start.",
      mbh="Bhishma: Bhagavad-gita Parva ch.25–42 ✔ (Gita); Drona and Bhishma ch.43–124 ✔ (the war)",
      dp="Periyazhwar / Periya Tirumozhi (Parthasarathi at Triplicane) ?")
story("mbh-war", "The Kurukshetra war (general)",
      "General references to the Bharata war, the Kauravas' fall and its aftermath.",
      mbh="Bhishma, Drona, Karna, Shalya, Sauptika parvas ?")
story("mbh-jayadratha", "Jayadratha killed; the sun hidden",
      "On the fourteenth day Krishna hides the sun (tradition: with the Sudarshana discus), Jayadratha steps out thinking "
      "the day is done, and Arjuna kills him.",
      mbh="Drona: Jayadratha-vadha Parva ch.85–152 ✔ (the sun-darkening near its end; Wikipedia describes it as Krishna's "
          "'darkness'; the Sudarshana version needs a text check)")
story("mbh-kirata", "Arjuna and Shiva as the hunter",
      "Arjuna's austerity; Shiva appears as a Kirata and they fight over a boar; Shiva then grants the Pashupata weapon.",
      mbh="Vana: Kairata Parva ch.38–41 ✔",
      notes="Song 233 ('சூகரத்தொடம்பு') may be this story. Kept low-confidence.")
story("krishna-banasura", "Banasura",
      "Krishna fights Banasura (and Shiva) at Shonitapura to free his grandson Aniruddha.",
      bhagavata="10.62–63 ✔ (63 verified)", vp="5.32 ✔–33 ✔")
story("krishna-mausala", "The pestle (Mausala) and the Yadavas' end",
      "A curse leads to an iron pestle; its powder grows into reeds with which the Yadavas destroy each other; the pestle's "
      "last piece is thrown into the sea.",
      mbh="Mausala Parva (book 16) ?", bhagavata="11.30 ?")
story("krishna-16000-wives", "Narakasura and the 16,000 princesses",
      "Krishna kills Narakasura and marries the princesses he had imprisoned.",
      bhagavata="10.59 ✔", vp="5.29 ✔")
story("krishna-parijata", "The parijata tree",
      "Krishna brings the heavenly parijata tree from Indra's garden for Satyabhama.",
      bhagavata="10.59 ?", vp="5.30 ✔")
story("krishna-sudama", "Sudama",
      "The poor Brahmin friend Sudama (Kuchela) visits Krishna at Dwaraka.",
      bhagavata="10.80 ✔–81 ✔")
story("krishna-general", "Krishna (no specific episode)", "Names Krishna without an episode.", bhagavata="—")

# --------------------------------------------------------- Other avatars/deeds
story("gajendra", "Gajendra moksha",
      "The elephant king Gajendra is seized by a crocodile in a pond; after long struggle he calls out and Vishnu rides "
      "Garuda to kill the crocodile with his discus. One of the most common images (about 20 songs).",
      bhagavata="8.2 ✔–4 ✔", vp="—",
      dp="Thiruvaimozhi 3.5.1 ✔; Periyazhwar Thirumozhi 2.1.9 ✔, 2.10.8 ✔")
story("narasimha", "Narasimha and Hiranyakashipu",
      "Vishnu appears from a pillar as man-lion at dusk and tears open the demon Hiranyakashipu to save his son Prahlada.",
      bhagavata="7.8 ?", vp="1.17–20 ✔ (Prahlada legend)",
      kamba="Yuddha: இரணியன் வதைப் படலம் ✔", dp="Periyazhwar / Periya Tirumozhi (many) ?")
story("vamana", "Vamana and Mahabali; Trivikrama",
      "The dwarf Vamana asks King Bali for three paces of land, then grows to measure the worlds with two steps and sends "
      "Bali to Sutala with the third.",
      bhagavata="8.15 ✔–23 ✔ (18–22 Vamana and Bali)", valmiki="Bala 29 ✔ (legend of Vamana)",
      kamba="Bala: வேள்விப் படலம் ✔ (Siddhashrama as Vamana's place)",
      dp="Tiruppavai 3 ?, 24 ✔ ('அன்று இவ்வுலகம் அளந்தாய்')")
story("samudra-manthana", "Churning the milk ocean",
      "Gods and demons churn the milk ocean with Mount Mandara and the serpent Vasuki; poison is drunk by Shiva, nectar "
      "emerges, Vishnu as Mohini keeps it from the demons.",
      bhagavata="8.5 ✔–12 ✔", valmiki="Bala 45 ✔", vp="1.9 ✔ (Wilson: legend of Lakshmi, includes the churning)")
story("kurma", "Kurma (the tortoise avatar)",
      "Vishnu as a tortoise holds Mount Mandara on his back during the churning.",
      bhagavata="8.7 ?")
story("varaha", "Varaha (the boar avatar)",
      "Vishnu lifts the earth from the cosmic ocean on his tusks and kills the demon Hiranyaksha.",
      bhagavata="3.13 ?", vp="1.4 ✔")
story("matsya", "Matsya (the fish avatar)", "Vishnu as a fish saves the Vedas and Manu.", bhagavata="8.24 ✔")
story("vishnu-pralaya", "Vishnu swallows the worlds; the banyan-leaf child",
      "At the end of a cycle the world is held in Vishnu's belly; he lies as a child on a banyan leaf.",
      bhagavata="12.9 (Markandeya) ?")
story("vishnu-sleeping", "Vishnu reclining on Adisesha in the milk ocean",
      "A repeating image rather than a story: Vishnu asleep on the serpent bed (Ananta/Adisesha) in the milk ocean.",
      dp="Tiruppavai 6 ✔ ('வெள்ளத்தரவில் துயில் அமர்ந்த'), 2 ? ('பாற்கடலுள் பையத் துயின்ற')")
story("vishnu-brahma-origin", "Brahma born from Vishnu's navel",
      "Brahma sits on the lotus that grows from Vishnu's navel; Murugan is Vishnu's nephew and Brahma's rival.",
      bhagavata="3.8 ?")
story("vishnu-temple-srirangam", "Srirangam", "Ranganatha reclining on Adisesha at Srirangam.",
      dp="Many (Periyazhwar, Tondaradippodi, Kulasekhara) ?")
story("vishnu-temple-tirupati", "Tirupati/Venkatam", "Vishnu at Tirumala on the Venkata hill.",
      dp="Tiruvaimozhi 3.3 ? / Periyazhwar ?")
story("vishnu-temple-kanchi", "Kanchi (Ulagalanda Perumal at Ooragam)",
      "Vishnu as the world-measurer at the Ooragam shrine in Kanchi.", dp="Divya desam, Tirumangai ?")
story("vishnu-panchajanya", "Panchajanya conch and weapons", "Songs naming the conch Panchajanya.", dp="—")
story("vishnu-sudarshana", "Sudarshana discus", "Songs naming the discus.", dp="—")
story("vishnu-lakshmi", "Vishnu and Lakshmi", "Songs naming Vishnu with Sri on his chest, no deed.", dp="—")
story("vishnu-supreme", "Vishnu as the supreme reality", "Mayon as the unchanging supreme beyond the three.", dp="—")
story("vishnu-asura-victory", "Vishnu defeats the asura clans", "A general reference to Vishnu's victories.", dp="—")
story("vishnu-war", "Vishnu as warrior (unspecified)", "Battlefield line with a Vishnu name, Rama or Mahabharata unclear.", dp="—")
story("vishnu-general", "Vishnu (no specific episode)",
      "The song names Vishnu with an epithet only: Hari, Mukunda, Madhava, Tirumal, Narayana, etc. Read in full before assigning.",
      dp="—")
story("not-vishnu", "Not a Vishnu reference",
      "Songs where the nephew word is about someone else (song 63: list of kin; song 1143: Indra's son-in-law).", dp="—")
