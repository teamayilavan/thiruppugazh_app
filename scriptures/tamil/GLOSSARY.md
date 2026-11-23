# Tamil glossary for the story texts

One Tamil form for every name and term in the English story texts (`pdf/narratives/`), so the 142 Tamil stories
spell things the same way. The Tamil edition uses **simple modern prose** (owner's decision, 2026-11-23).

**How a form is chosen (in this order):**
1. Where the Thiruppugazh or its Tamil meaning (`pathavurai` in the app) uses a distinctly Tamil name, use it
   (திருமால், பிரமன், தக்கன், கண்ணன், கயிலை): the reader moves between the story and the song on the same page.
2. Otherwise the common modern Tamil form a general reader knows (ராமன், லட்சுமணன், கிருஷ்ணன்), with Grantha letters
   (ஜ ஷ ஸ ஹ க்ஷ) where modern Tamil normally keeps them.
3. Names inside a quoted Tamil source (Kanda Puranam, Periya Puranam, Tevaram, Kamban, Purananuru) stay as the
   source spells them; this glossary governs only our own prose.

**Columns:** *English* is the main spelling in the narratives; *Other English spellings* are variants that map to
the same Tamil (`;`-separated); *Tamil* is the form to use; *Also seen* are other Tamil forms (for search and for the
checker's evidence), not to be used in our prose; *Note* explains a choice or a usage rule.

**Checker:** `python3 -I -X utf8 scripts/glossary_check.py` reads this file and writes `tamil/glossary-report.md`:
how often each English name occurs in the narratives, how often each Tamil form occurs in the app's song meanings
and lyrics, and the capitalised names in the narratives that this glossary does not cover yet. Edit this file, not
the report. Inflected forms: write the nominative (ராமன்); the checker matches the stem (ராமனை, ராமனின்).

Status: **draft 2 (2026-11-23)**, for the owner's review. Rows marked *check* in the Note column are the ones I am
least sure of. Rows marked *kept on purpose* chose a modern form over a better-attested old one; the checker stops flagging them.

**Song places.** Where the English says "song 928 (Karuvur)", the Tamil uses the app's `place` for that song exactly (கருவூர்), so the story and the song panel agree; the checker counts every app venue as covered. In our own narration a place takes the glossary form below.

**Hymn openings and padalam titles** are quoted in their Tamil original (from the source text), never rebuilt from the English transliteration.

## Murugan and his names

| English | Other English spellings | Tamil | Also seen | Note |
|---|---|---|---|---|
| Murugan | | முருகன் | முருகப்பெருமான் | "Lord Murugan" → முருகப்பெருமான் |
| Kandan | | கந்தன் | கந்தவேள் | |
| Kumara | Kumaran | குமரன் | குமாரன் | |
| Skanda | | ஸ்கந்தன் | கந்தன் | only where a Sanskrit text names him; Skanda Purana → ஸ்கந்த புராணம்; kept on purpose |
| Karttikeya | | கார்த்திகேயன் | | |
| Swaminatha | Swaminathan | சுவாமிநாதன் | | |
| Gurunatha | | குருநாதன் | | |
| Shanmukha | Arumugam | ஆறுமுகன் | சண்முகன் | |
| Subrahmanya | | சுப்பிரமணியன் | | |
| Vel | spear | வேல் | | Murugan's spear → வேல், never ஈட்டி |
| Ugrakumaran | | உக்கிரகுமாரன் | | Murugan born as the Pandya prince |
| Valli | | வள்ளி | | |
| Deivayanai | Devasena | தெய்வயானை | தேவசேனை | Devasena (Sanskrit name) → தேவசேனை |
| Saravana | | சரவணப் பொய்கை | சரவணம் | |
| Krittikas | Krittika; Pleiades | கார்த்திகைப் பெண்கள் | | the six mothers |
| peacock | | மயில் | | |
| cock banner | | சேவல் கொடி | | |

| Veerabahu | | வீரபாகு | வீரவாகு | Kanda Puranam quotes keep வீரவாகு |
| Nambi | | நம்பி | நம்பிராஜன் | Valli's father |
| Vengai | | வேங்கை மரம் | | the tree Murugan becomes |
## Shiva, Devi, Ganesha

| English | Other English spellings | Tamil | Also seen | Note |
|---|---|---|---|---|
| Shiva | | சிவபெருமான் | சிவன் | "Lord Shiva" and Shiva in narration → சிவபெருமான்; சிவன் only in compounds |
| Rudra | | ருத்திரன் | உருத்திரன் | |
| Hara | | ஹரன் | அரன் | kept on purpose |
| Shankara | | சங்கரன் | | |
| Maheshvara | | மகேஸ்வரன் | மகேசன் | |
| Nataraja | | நடராஜர் | நடராசர் | |
| Dakshinamurti | | தட்சிணாமூர்த்தி | | |
| Bhairava | | பைரவர் | வைரவர் | |
| Kalabhairava | | காலபைரவர் | | |
| Virabhadra | | வீரபத்திரர் | | |
| Sarabha | | சரபர் | சரபம் | |
| Bhikshatana | | பிட்சாடனர் | | |
| Kalantaka | Kalasamharamurti | காலசம்ஹார மூர்த்தி | காலகாலன் | |
| Ardhanarishvara | | அர்த்தநாரீஸ்வரர் | உமையொருபாகன் | |
| Somasundarar | | சோமசுந்தரர் | | the Lord of Madurai |
| Sokkanathar | Sokkar | சொக்கநாதர் | சொக்கர் | |
| Linga | | லிங்கம் | இலிங்கம் | |
| Nandi | | நந்தி | | |
| Uma | | உமை | உமா; உமாதேவி | |
| Parvati | | பார்வதி | | |
| Gauri | | கௌரி | | |
| Sati | | சதி | தாட்சாயணி | |
| Goddess | Devi; Mother | தேவி | அம்பிகை; அன்னை | "the Goddess" → தேவி (அம்பிகை where she is addressed as mother); in a name (Goddess Durga) → the name alone; "the Mother" → அன்னை |
| Durga | | துர்க்கை | | |
| Kali | | காளி | | |
| Bhadrakali | Bhadra Kali | பத்திரகாளி | | |
| Chandika | | சண்டிகை | | |
| Katyayani | | காத்யாயனி | | |
| Kamakshi | | காமாட்சி | | |
| Meenakshi | | மீனாட்சி | | |
| Abirami | | அபிராமி | | |
| Tripurasundari | | திரிபுரசுந்தரி | | |
| Matangi | | மாதங்கி | | |
| Bhavani | | பவானி | | |
| Imayavalli | | இமயவல்லி | | |
| Idumbai | | இடும்பை | | Idumbai Durga → இடும்பை துர்க்கை (*check*) |
| Ganesha | Vinayaka; Lord Vinayaka | விநாயகர் | கணேசர்; பிள்ளையார் | |
| Ganapati | | கணபதி | | |
| Himavan | | இமவான் | இமயவான்; மலையரசன் | Parvati's father; "the mountain king" → மலையரசன், where the English says so |
| Menai | | மேனை | | |
| Daksha | | தக்கன் | தட்சன் | Kanda Puranam and the songs say தக்கன் |
| Muyalakan | | முயலகன் | | |
| Tripura | | திரிபுரம் | முப்புரம் | "the three cities" → முப்புரம் |
| Tarakaksha | | தாரகாட்சன் | | |
| Kamalaksha | | கமலாட்சன் | | |
| Vidyunmali | | வித்யுன்மாலி | | |

| Tadatakai | | தடாதகைப் பிராட்டியார் | தடாதகை | Meenakshi as the Pandya princess (*check*) |
| Lord of the Boat | Thoniappar | தோணியப்பர் | | the Lord of the Thoni shrine at Sirkazhi |
| bull | | இடபம் | ரிஷபம்; விடை | Shiva's mount; விடை is the poetic word, kept on purpose |
| Kamari | | காமாரி | | "the enemy of Kama"; explain with காமன் |
| Ananga | | அனங்கன் | | Kama, "the bodiless" |
## Vishnu and his forms

| English | Other English spellings | Tamil | Also seen | Note |
|---|---|---|---|---|
| Vishnu | | திருமால் | விஷ்ணு; மால் | in our prose திருமால்; விஷ்ணு only in a Sanskrit title (விஷ்ணு புராணம்) |
| Narayana | | நாராயணன் | | |
| Hari | | ஹரி | அரி | kept on purpose |
| Achyuta | | அச்சுதன் | | |
| Mukunda | | முகுந்தன் | | |
| Madhava | | மாதவன் | | |
| Murari | | முராரி | | |
| Keshava | | கேசவன் | | |
| Damodara | Damodaran | தாமோதரன் | | |
| Gopala | Gopalakrishna | கோபாலன் | கோபாலகிருஷ்ணன் | |
| Ranganatha | Periya Perumal | அரங்கநாதர் | ரங்கநாதர்; பெரிய பெருமாள் | |
| Krishna | Kannan | கண்ணன் | கிருஷ்ணன் | the songs and meanings say கண்ணன்; கிருஷ்ணன் only in a Sanskrit title |
| Rama | | ராமன் | இராமன்; ராமர் | |
| Raghava | | ராகவன் | இராகவன் | |
| Balarama | | பலராமன் | பலதேவன் | |
| Narasimha | | நரசிம்மர் | நரசிங்கம் | |
| Narasingan | | நரசிங்கன் | | where the song's own word is used |
| Vamana | | வாமனன் | | |
| Trivikrama | | திரிவிக்கிரமன் | | |
| Varaha | | வராகர் | வராகம் | |
| Parashurama | | பரசுராமன் | | |
| Mohini | | மோகினி | | |
| Dhanvantari | | தன்வந்திரி | | |
| Lakshmi | | லட்சுமி | இலக்குமி; திருமகள் | kept on purpose |
| Garuda | | கருடன் | | |
| Adisesha | Adishesha; Ananta | ஆதிசேஷன் | அனந்தன் | |
| Sudarshana | discus | சக்கரம் | சுதர்சனம் | the discus → சக்கரம்; by name → சுதர்சனம் |
| Panchajanya | conch | பாஞ்சஜன்யம் | சங்கு | the conch → சங்கு; kept on purpose |
| Kaustubha | | கௌஸ்துபம் | | |

## Gods, sages and others

| English | Other English spellings | Tamil | Also seen | Note |
|---|---|---|---|---|
| Brahma | Creator | பிரமன் | பிரம்மா; நான்முகன் | songs and meanings say பிரமன் |
| Indra | | இந்திரன் | | |
| Sachi | | இந்திராணி | சசி | |
| Jayanta | Jayantan | ஜயந்தன் | சயந்தன் | |
| Airavata | | ஐராவதம் | | |
| Yama | Death | யமன் | எமன்; இயமன் | |
| Agni | | அக்கினி | அக்னி | |
| Vayu | | வாயு | | |
| Varuna | | வருணன் | | |
| Kubera | | குபேரன் | | |
| Kama | | மன்மதன் | காமன்; மதன் |; காமன் only to explain காமாரி |
| Surya | Sun | சூரியன் | | |
| Chandra | | சந்திரன் | | |
| Rahu | | ராகு | | |
| Narada | | நாரதர் | | |
| Agastya | | அகத்தியர் | அகத்தியன் | |
| Markandeya | | மார்க்கண்டேயர் | | |
| Vyasa | | வியாசர் | | |
| Durvasa | | துர்வாசர் | | |
| Kashyapa | | காசிபர் | காசிபன் | |
| Aditi | | அதிதி | | |
| Vasishtha | | வசிஷ்டர் | வசிட்டர் | |
| Vishwamitra | Vishvamitra; Viswamitra | விசுவாமித்திரர் | விஸ்வாமித்திரர் | |
| Gautama | | கௌதமர் | | |
| Sanaka | | சனகர் | | |
| Maitreya | | மைத்ரேயர் | | |
| Nalakuvara | | நளகூபரன் | | |
| Manigriva | | மணிக்ரீவன் | | |
| Matali | | மாதலி | | Indra's charioteer |
| Vishvakarma | | விஸ்வகர்மா | | |
| Mayan | Maya | மயன் | | the asura architect (Tripura, Surapadman's city) |
| Ganga | Ganges | கங்கை | | |
| Yamuna | | யமுனை | | |
| Kaveri | | காவிரி | | |
| Vaigai | | வைகை | | |
| Godavari | | கோதாவரி | | |
| Narmada | | நர்மதை | | |
| Vegavati | | வேகவதி | | |
| Gedilam | | கெடிலம் | | |
| Vasuki | | வாசுகி | | |
| Uccaihshravas | | உச்சைச்சிரவம் | | |
| Halahala | | ஆலகால விஷம் | ஆலகாலம் | |

| Devala | | தேவல முனிவர் | | |
| gandharva | | கந்தர்வன் | | |
| wish-giving tree | | கற்பக மரம் | கற்பகம் | |
## Asuras and demons

| English | Other English spellings | Tamil | Also seen | Note |
|---|---|---|---|---|
| asura | asuras; demon | அசுரன் | அவுணன்; அரக்கன் | plural அசுரர்கள்; a Ramayana rakshasa → அரக்கன் |
| deva | devas; gods | தேவர்கள் | வானவர் | |
| Surapadman | Suran; Sura | சூரபத்மன் | சூரன்; சூரபன்மன் | the meanings' form; சூரன் for short. Kanda Puranam quotes keep சூரபன்மன்; kept on purpose |
| Tarakan | Taraka | தாரகன் | | |
| Mahendrapuri | | மகேந்திரபுரி | | Surapadman's city |
| Krouncha | | கிரவுஞ்ச மலை | கிரௌஞ்சம் | |
| Mahishasura | Mahisha | மகிஷாசுரன் | மகிடன்; மகிஷன் | |
| Naraka | | நரகாசுரன் | நரகன் | |
| Mura | | முரன் | | |
| Hiranyakashipu | Hiranya; Iraniyan | இரணியன் | இரணியகசிபு | |
| Hiranyaksha | | இரணியாட்சன் | | |
| Mahabali | Bali; King Bali | மகாபலி | | Vishnu's Bali; Vali the monkey king is வாலி |
| Shukracharya | | சுக்கிராச்சாரியார் | | |
| Vindhyavali | | விந்தியாவளி | | |
| Kamsa | | கம்சன் | கஞ்சன் | |
| Putana | | பூதனை | | |
| Kaliya | | காளிங்கன் | காளியன் | Tamil tradition says காளிங்கன் (*check*) |
| Sakatasura | Sakata | சகடாசுரன் | சகடன் | |
| Baka | | பகாசுரன் | | |
| Kuvalayapida | | குவலயாபீடம் | | the elephant |
| Chanura | | சாணூரன் | | |
| Mushtika | | முஷ்டிகன் | | |
| Hidimba | | இடும்பன் | | the rakshasa of the Mahabharata |
| Hidimbi | | இடும்பி | | |

## Ramayana

| English | Other English spellings | Tamil | Also seen | Note |
|---|---|---|---|---|
| Sita | | சீதை | சீதா | |
| Janaki | | ஜானகி | சானகி | |
| Lakshmana | | லட்சுமணன் | இலக்குவன் | |
| Bharata | | பரதன் | | |
| Shatrughna | | சத்ருக்னன் | சத்துருக்கன் | |
| Dasaratha | King Dasaratha | தசரதன் | | |
| Kausalya | | கௌசல்யை | கோசலை | |
| Kaikeyi | Queen Kaikeyi | கைகேயி | | |
| Sumitra | | சுமித்திரை | | |
| Manthara | | கூனி | மந்தரை | Kamban's name, the one Tamil readers know |
| Janaka | King Janaka | ஜனகன் | சனகன் | |
| Ahalya | | அகலிகை | | |
| Tataka | | தாடகை | | |
| Subahu | | சுபாகு | | |
| Maricha | | மாரீசன் | | |
| Ravana | | ராவணன் | இராவணன் | |
| Kumbhakarna | Kumbakarnan | கும்பகர்ணன் | கும்பகருணன் | |
| Kumbha | Kumban | கும்பன் | | son of Kumbhakarna; see song 835 in REVIEW-NOTES |
| Vibhishana | | விபீஷணன் | வீடணன் | |
| Indrajit | | இந்திரஜித் | இந்திரசித்து | |
| Atikaya | | அதிகாயன் | | |
| Surpanakha | | சூர்ப்பணகை | | |
| Khara | | கரன் | | |
| Dushana | | தூஷணன் | | |
| Trishira | | திரிசிரன் | | |
| Viradha | | விராதன் | | |
| Jatayu | | ஜடாயு | சடாயு | |
| Sampati | | சம்பாதி | | |
| Hanuman | | அனுமன் | ஹனுமான்; அனுமான் | |
| Sugriva | King Sugriva | சுக்ரீவன் | சுக்கிரீவன் | |
| Vali | | வாலி | | |
| Angada | | அங்கதன் | | |
| Tara | | தாரை | | |
| Kesari | | கேசரி | | |
| Nala | | நளன் | | the monkey who built the bridge |
| Guha | | குகன் | | |
| Pushpaka | | புஷ்பக விமானம் | | |

| Ashoka | | அசோக வனம் | | "the Ashoka grove" |
## Mahabharata and the Krishna stories

| English | Other English spellings | Tamil | Also seen | Note |
|---|---|---|---|---|
| Arjuna | Arjuna Devadatta | அர்ஜுனன் | அருச்சுனன்; விசயன் | Devadatta is the conch: தேவதத்தம்; kept on purpose |
| Partha | | பார்த்தன் | | |
| Dhananjaya | Dhananjayan | தனஞ்சயன் | | |
| Bhima | | பீமன் | வீமன் | |
| Yudhishthira | | தருமர் | யுதிஷ்டிரன்; தருமன் | |
| Nakula | | நகுலன் | | |
| Sahadeva | | சகாதேவன் | | |
| Draupadi | | திரௌபதி | பாஞ்சாலி | |
| Kunti | | குந்தி | | |
| Duryodhana | Suyodhana | துரியோதனன் | சுயோதனன் | |
| Dhritarashtra | King Dhritarashtra | திருதராஷ்டிரன் | | |
| Gandhari | | காந்தாரி | | |
| Bhishma | | பீஷ்மர் | வீடுமன் | |
| Drona | | துரோணர் | | |
| Karna | | கர்ணன் | | |
| Shakuni | | சகுனி | | |
| Vidura | | விதுரர் | | |
| Jayadratha | | ஜயத்ரதன் | சயத்திரதன் | |
| Abhimanyu | | அபிமன்யு | | |
| Shikhandi | | சிகண்டி | | |
| Sanjaya | | சஞ்சயன் | | |
| Satyaki | | சாத்யகி | | |
| Ghatotkacha | | கடோத்கஜன் | | |
| Yuyutsu | | யுயுத்சு | | |
| Dhaumya | | தௌம்யர் | | |
| King Virata | Virata | விராட மன்னன் | | |
| Pandavas | Pandava | பாண்டவர்கள் | பாண்டவர் | |
| Kauravas | Kaurava; Kurus; Kuru | கௌரவர்கள் | | Kuru as a dynasty → குரு வம்சம் |
| Yadavas | Yadava | யாதவர்கள் | | |
| Vrishnis | Andhakas; Bhojas | விருஷ்ணிகள் | | Andhakas → அந்தகர்கள்; Bhojas → போஜர்கள் |
| Yashoda | | யசோதை | | |
| Nanda | | நந்தகோபர் | நந்தன் | |
| Vasudeva | | வசுதேவர் | | |
| Devaki | | தேவகி | | |
| Rohini | | ரோகிணி | | |
| Satyabhama | | சத்யபாமா | | |
| Jambavati | | ஜாம்பவதி | | |
| Ugrasena | King Ugrasena | உக்கிரசேனன் | | |
| Pradyumna | | பிரத்யும்னன் | | |
| Samba | | சாம்பன் | | |
| Kuchela | Sudama | குசேலர் | சுதாமா | |
| Sandipani | | சாந்தீபனி | | |
| Daruka | | தாருகன் | | |
| Jara | | ஜரா | | the hunter |
| Gajendra | | கஜேந்திரன் | ஆனை; களிறு | the elephant king |
| Indradyumna | | இந்திரத்யும்னன் | | |
| Huhu | | ஹூஹூ | | |
| Prahlada | | பிரகலாதன் | | |
| Bhagiratha | | பகீரதன் | | |
| Sagara | King Sagara | சகரன் | | |
| Manu | | மனு | | |

| Vijaya | | விஜயன் | விசயன் | Arjuna |
## Saints, poets and authors

| English | Other English spellings | Tamil | Also seen | Note |
|---|---|---|---|---|
| Arunagiri | Arunagirinathar | அருணகிரிநாதர் | அருணகிரியார் | |
| Sambandar | Thirugnanasambandar; Thirugnana Sambandar; Gnanasambandan | திருஞானசம்பந்தர் | சம்பந்தர்; ஞானசம்பந்தன் | first mention திருஞானசம்பந்தர், then சம்பந்தர் |
| Appar | Thirunavukkarasar | அப்பர் | திருநாவுக்கரசர் | |
| Marulneekkiyar | | மருள்நீக்கியார் | | Appar's birth name |
| Sundarar | Arurar; Vanthondan | சுந்தரர் | ஆரூரர்; வன்தொண்டர் | |
| Manikkavasagar | | மாணிக்கவாசகர் | | |
| Vathavurar | Vadavurar; Tiruvadavurar | திருவாதவூரர் | வாதவூரர் | |
| Kannappar | Kannappa | கண்ணப்பர் | | |
| Thinnan | | திண்ணன் | | Kannappar's birth name |
| Nakkeerar | | நக்கீரர் | | |
| Sekkizhar | | சேக்கிழார் | | |
| Kachiyappa Sivachariyar | Kachchiyappa Sivachariyar; Kachchiyappar; Sivachariyar | கச்சியப்ப சிவாச்சாரியார் | கச்சியப்பர் | author of the Kanda Puranam |
| Paranjothi Munivar | Paranjothi | பரஞ்சோதி முனிவர் | | Tiruvilaiyadal Puranam |
| Sivagnana Munivar | | சிவஞான முனிவர் | | Kanchi Puranam |
| Kamban | Kamba; Kampa | கம்பர் | கம்பன் | |
| Valmiki | | வால்மீகி | | |
| Tiruvalluvar | | திருவள்ளுவர் | | |
| Tolkappiyar | | தொல்காப்பியர் | | |
| Kapilar | | கபிலர் | | |
| Paranar | | பரணர் | | |
| Tirumular | | திருமூலர் | | |
| Karaikkal Ammaiyar | Ammaiyar | காரைக்கால் அம்மையார் | | |
| Cheraman Perumal | | சேரமான் பெருமாள் | | |
| Kazharitrarivar | | கழறிற்றறிவார் | | Cheraman's Nayanar name |
| Paravai | | பரவையார் | | |
| Sangili | | சங்கிலியார் | | |
| Poompavai | | பூம்பாவை | | |
| Mangaiyarkkarasi | Mangayarkkarasi | மங்கையர்க்கரசியார் | | |
| Kulachchirai | | குலச்சிறையார் | | |
| Koon Pandyan | Nindrasir Nedumaran; Maran | கூன் பாண்டியன் | நின்றசீர் நெடுமாறன் | after his cure → நின்றசீர் நெடுமாறன் |
| Sivapadahridayar | | சிவபாத இருதயர் | | Sambandar's father (*check*) |
| Bhagavathiyar | | பகவதியார் | | Sambandar's mother |
| Thiruneelakanta Yazhpanar | Yazhpanar | திருநீலகண்ட யாழ்ப்பாணர் | | |
| Tilakavathiyar | | திலகவதியார் | | |
| Kochchengat Chola | Kochchengannan | கோச்செங்கட் சோழர் | கோச்செங்கணான் | |
| Eyarkon Kalikkama | | ஏயர்கோன் கலிக்காமர் | | |
| Rudrasarman | | உருத்திரசன்மன் | | the mute child of the Sangam story |
| Dharumi | Brahmin Dharumi | தருமி | | |
| Vandi | | வந்தி | | |
| Nayanmars | Nayanmar | நாயன்மார்கள் | | |
| Alvars | Azhwars; Alvar; Azhwar | ஆழ்வார்கள் | ஆழ்வார் | |
| Andal | | ஆண்டாள் | | |
| Periyazhwar | | பெரியாழ்வார் | | |
| Kulasekhara Alvar | Kulasekhara Azhwar; Kulasekhara | குலசேகர ஆழ்வார் | | |
| Thirumangai Alvar | | திருமங்கை ஆழ்வார் | | |
| Nammazhwar | | நம்மாழ்வார் | | |
| Poigai Alvar | | பொய்கையாழ்வார் | | |
| Bhutattalvar | | பூதத்தாழ்வார் | | |
| Peyalvar | | பேயாழ்வார் | | |
| Thirumazhisai Alvar | | திருமழிசையாழ்வார் | | |

| Kavuniya | Kavuniyas | கவுணியர் | | Sambandar's clan; "the Kavuniya house" → கவுணியர் குடி |
| Sivagochariyar | | சிவகோசரியார் | | the priest of Kalahasti |
| Sivanesar | | சிவநேசர் | | Poompavai's father |
| Kundaiyur Kizhar | | குண்டையூர்க் கிழார் | | |
| Neeli | | நீலி | | |
## Kings and chieftains

| English | Other English spellings | Tamil | Also seen | Note |
|---|---|---|---|---|
| Pari | King Pari | பாரி | | |
| Kari | | காரி | | |
| Ay | | ஆய் | | |
| Pekan | | பேகன் | | |
| Nalli | | நள்ளி | | |
| Kumanan | | குமணன் | | |
| Ori | | ஓரி | | |
| Malayadhvaja | | மலயத்துவசன் | | |
| Kanchanamalai | | காஞ்சனமாலை | | |
| Pandya | | பாண்டியன் | பாண்டிய மன்னன் | adjective → பாண்டிய |
| Chola | | சோழன் | | adjective → சோழ |
| Chera | | சேரன் | | adjective → சேர |
| Pallava | | பல்லவன் | | |

## Places: Murugan's shrines

| English | Other English spellings | Tamil | Also seen | Note |
|---|---|---|---|---|
| Palani | Pazhani; Pazhanam | பழநி | பழனி; திருஆவினன்குடி | |
| Thiruchendur | Tiruchendur | திருச்செந்தூர் | செந்தில் | |
| Thiruparankundram | Parankundram | திருப்பரங்குன்றம் | பரங்குன்றம் | |
| Swamimalai | | சுவாமிமலை | திருவேரகம் | Thiru Ooragam / Edagam are other shrines, see below |
| Thiruthani | Tiruttani; Thiruthanigai | திருத்தணி | தணிகை; திருத்தணிகை | |
| Pazhamudircholai | Pazhamudhircholai | பழமுதிர்ச்சோலை | | the app's form |
| Viralimalai | | விராலிமலை | | |
| Vayalur | | வயலூர் | | |
| Vallimalai | | வள்ளிமலை | | |
| Kathirgamam | Kathirkamam | கதிர்காமம் | | |
| Kundrakudi | Kunrakkudi | குன்றக்குடி | | |
| Thiruchengode | | திருச்செங்கோடு | | |
| Ettikudi | | எட்டிகுடி | எட்டுக்குடி | the app's form |
| Thirukkazhukundram | | திருக்கழுக்குன்றம் | | |

## Places: other Tamil shrines and towns

| English | Other English spellings | Tamil | Also seen | Note |
|---|---|---|---|---|
| Madurai | Alavai; Kudal | மதுரை | ஆலவாய்; கூடல் | in Sambandar's and the Tiruvilaiyadal stories ஆலவாய் where the source says it |
| Chidambaram | Thillai; Chitrambalam | சிதம்பரம் | தில்லை; சிற்றம்பலம் | |
| Kanchi | Kanchipuram; Kachchi | காஞ்சி | காஞ்சிபுரம்; கச்சி | kept on purpose; கச்சி also begins கச்சியப்பர், a different name |
| Kamakottam | Kamakkottam | காமக்கோட்டம் | | |
| Ekambam | Ekambareshwara | ஏகாம்பரம் | ஏகாம்பரநாதர் | the god → ஏகாம்பரநாதர் |
| Thiruvannamalai | Tiruvannamalai; Thiruvarunai; Annamalai; Arunachala; Arunacala | திருவண்ணாமலை | அண்ணாமலை; அருணை; அருணாசலம் | the hill → அண்ணாமலை |
| Sirkazhi | | சீர்காழி | காழி | its twelve names: next table; kept on purpose |
| Tiruvarur | Thiruvarur | திருவாரூர் | ஆரூர் | |
| Srirangam | Thiruvarangam | ஸ்ரீரங்கம் | திருவரங்கம்; அரங்கம் | |
| Thiruvanaikka | | திருவானைக்கா | | |
| Thiruvalangadu | Alangadu | திருவாலங்காடு | ஆலங்காடு | |
| Pazhaiyanur | | பழையனூர் | | |
| Thiruvathigai | Tiruvadigai; Thiruvathigai Veerattanam | திருவதிகை | அதிகை | Veerattanam → வீரட்டானம் |
| Veerattanam | Virattam | வீரட்டானம் | | |
| Thiruppathirippuliyur | Pattaliyur; Padalanagar | திருப்பாதிரிப்புலியூர் | | today's Cuddalore (கடலூர்) |
| Vedaranyam | Maraikkadu; Thirumaraikkadu | வேதாரண்யம் | திருமறைக்காடு | |
| Mylapore | Thirumayilai | மயிலாப்பூர் | திருமயிலை | |
| Kapaliccharam | | கபாலீச்சரம் | | |
| Avinashi | Avinasi; Thirupukkoliyur | அவிநாசி | திருப்புக்கொளியூர் | |
| Perunthurai | Thiruperunthurai | திருப்பெருந்துறை | பெருந்துறை | |
| Thiruvathavur | Vadavur | திருவாதவூர் | வாதவூர் | |
| Thirukkadavur | Kadavur; Kadavur Virattam | திருக்கடவூர் | கடவூர் | |
| Thiruvidaikkazhi | | திருவிடைக்கழி | | |
| Kandiyur | | கண்டியூர் | | |
| Vriddhachalam | | விருத்தாசலம் | திருமுதுகுன்றம் | |
| Thiruvennainallur | | திருவெண்ணெய்நல்லூர் | | |
| Thirunavalur | | திருநாவலூர் | | |
| Kalahasti | Thirukkalathi | காளஹஸ்தி | திருக்காளத்தி | |
| Tirupati | Thiruvenkatam; Thiruvengadam; Venkatam | திருப்பதி | திருவேங்கடம்; வேங்கடம் | |
| Kumbakonam | Kudanthai | கும்பகோணம் | குடந்தை | |
| Tiruchirappalli | Thiruchirappalli | திருச்சிராப்பள்ளி | சிராப்பள்ளி |the app writes திருசிராப்பள்ளி (without ச்); our prose keeps the standard spelling |
| Thanjavur | | தஞ்சாவூர் | | |
| Mayiladuthurai | | மயிலாடுதுறை | | |
| Tiruvorriyur | | திருவொற்றியூர் | | |
| Thiruvamathur | | திருவாமாத்தூர் | | |
| Uthiramerur | | உத்திரமேரூர் | | |
| Thiruvallikkeni | | திருவல்லிக்கேணி | | |
| Tiruvalanchuli | Valanchuli | திருவலஞ்சுழி | | |
| Thiruvenkadu | Venkadu | திருவெண்காடு | | |
| Tiruppuvanam | Thiruppoovanam | திருப்பூவணம் | | |
| Chennai | | சென்னை | | |
| Cuddalore | | கடலூர் | | |
| Panruti | | பண்ருட்டி | | |
| Kongu | | கொங்கு நாடு | | |
| Pothigai | Podiya; Mount Pothigai | பொதிகை | பொதியமலை | |
| Kasi | Kashi; Varanasi | காசி | வாரணாசி | |
| Kedara | | கேதாரம் | | |

| Kundaiyur | | குண்டையூர் | | |
| Tirumurugan Poondi | | திருமுருகன்பூண்டி | | |
| Thiruvedagam | Edagam | திருவேடகம் | | |
| Maranpadi | | மாறன்பாடி | | (*check*) |
| Nelvayil | | நெல்வாயில் | | |
| Thiruvarathurai | Arathurai | திருவரத்துறை | | the app's form |
| Sri Purushamangai | | ஸ்ரீ புருஷமங்கை | | the app's form |
| Thiru Ooragam | | திருஊரகம் | | at Kanchi |
| Malaya | | மலய மலை | | |
| Kurukkai | | குறுக்கை | திருக்குறுக்கை | a Virattanam |
| Anga | | அங்க நாடு | | |
## Places: the twelve names of Sirkazhi

| English | Other English spellings | Tamil | Also seen | Note |
|---|---|---|---|---|
| Brahmapuram | | பிரமபுரம் | | |
| Venupuram | | வேணுபுரம் | | |
| Pugali | | புகலி | | |
| Venguru | | வெங்குரு | | |
| Thonipuram | Thoni | தோணிபுரம் | தோணி | the boat → தோணி; kept on purpose |
| Poontharai | | பூந்தராய் | | |
| Sirapuram | | சிரபுரம் | | |
| Puravam | | புறவம் | | |
| Shanbai | | சண்பை | | |
| Kazhi | | காழி | | |
| Kochchaivayam | Kochchai | கொச்சைவயம் | | |
| Kazhumalam | | கழுமலம் | | |

## Places: north India, epic and Puranic

| English | Other English spellings | Tamil | Also seen | Note |
|---|---|---|---|---|
| Kailasa | | கயிலை | கயிலாயம்; கைலாசம் | |
| Meru | Mount Meru | மேரு மலை | | |
| Mandara | Mount Mandara | மந்தர மலை | | |
| Himalaya | Himalayas | இமயமலை | இமயம் | |
| Milk Ocean | Milky Ocean; Ocean of Milk | பாற்கடல் | | |
| Lanka | | இலங்கை | | |
| Ayodhya | | அயோத்தி | | |
| Mithila | | மிதிலை | | |
| Kishkindha | | கிஷ்கிந்தை | கிட்கிந்தை | |
| Chitrakuta | | சித்திரகூடம் | | |
| Panchavati | | பஞ்சவடி | | |
| Dandaka | | தண்டகாரண்யம் | | |
| Janasthana | | ஜனஸ்தானம் | | |
| Nandigrama | | நந்திகிராமம் | | |
| Siddhashrama | | சித்தாசிரமம் | | |
| Mathura | | மதுரா | வடமதுரை | |
| Gokula | | கோகுலம் | ஆயர்பாடி | |
| Vraja | | ஆயர்பாடி | விரஜம் | |
| Vrindavan | | பிருந்தாவனம் | | |
| Govardhana | | கோவர்த்தன மலை | | |
| Dwaraka | | துவாரகை | | |
| Hastinapura | | அஸ்தினாபுரம் | | |
| Kurukshetra | | குருக்ஷேத்திரம் | | |
| Prabhasa | | பிரபாசம் | | |
| Pragjyotisha | | பிராக்ஜோதிஷம் | | |
| Kamyaka | | காம்யக வனம் | | |
| Sutala | | சுதலம் | | |
| Mandakini | | மந்தாகினி | | |

## Texts and their parts

| English | Other English spellings | Tamil | Also seen | Note |
|---|---|---|---|---|
| Thiruppugazh | | திருப்புகழ் | | |
| Tevaram | | தேவாரம் | | |
| Tirumurai | | திருமுறை | | |
| Periya Puranam | | பெரியபுராணம் | | |
| Kanda Puranam | | கந்தபுராணம் | | |
| Tiruvilaiyadal Puranam | | திருவிளையாடல் புராணம் | | |
| Kanchi Puranam | | காஞ்சிப் புராணம் | | |
| Kamba Ramayanam | Tamil Ramayana | கம்பராமாயணம் | | |
| Valmiki Ramayana | Ramayana | வால்மீகி ராமாயணம் | | the story itself → ராமாயணம் |
| Bhagavata Purana | Bhagavata | பாகவத புராணம் | ஸ்ரீமத் பாகவதம் | |
| Mahabharata | Bharata | மகாபாரதம் | பாரதம் | |
| Critical Edition | | செம்பதிப்பு | | the Pune Critical Edition (*check*) |
| Harivamsa | | ஹரிவம்சம் | | |
| Bhagavad Gita | Gita | பகவத் கீதை | | |
| Shiva Purana | | சிவ புராணம் | | the Sanskrit Purana; Manikkavasagar's poem is சிவபுராணம் (one word) |
| Sivapuranam | | சிவபுராணம் | | the first poem of Tiruvasagam |
| Linga Purana | | லிங்க புராணம் | | |
| Skanda Purana | | ஸ்கந்த புராணம் | | |
| Vishnu Purana | | விஷ்ணு புராணம் | | |
| Markandeya Purana | | மார்க்கண்டேய புராணம் | | |
| Devi Mahatmya | | தேவி மகாத்மியம் | | |
| Divya Prabandham | | நாலாயிர திவ்யப் பிரபந்தம் | திவ்யப் பிரபந்தம் | |
| Periyazhwar Thirumozhi | | பெரியாழ்வார் திருமொழி | | |
| Perumal Thirumozhi | | பெருமாள் திருமொழி | | |
| Periya Thirumozhi | | பெரிய திருமொழி | | |
| Nachiyar Thirumozhi | | நாச்சியார் திருமொழி | | |
| Tiruppavai | Thiruppavai | திருப்பாவை | | |
| Thiruvaimozhi | | திருவாய்மொழி | | |
| Thiruppalliyezhuchchi | | திருப்பள்ளியெழுச்சி | | |
| Thiruchchandha Viruththam | | திருச்சந்த விருத்தம் | | |
| Nanmugan Thiruvandhadhi | | நான்முகன் திருவந்தாதி | | |
| Mudhal Thiruvandhadhi | | முதல் திருவந்தாதி | | |
| Irandam Thiruvandhadhi | | இரண்டாம் திருவந்தாதி | | |
| Periya Thiruvandhadhi | | பெரிய திருவந்தாதி | | |
| Tiruvasagam | | திருவாசகம் | | |
| Tirumandiram | | திருமந்திரம் | | |
| Tirumurugatruppadai | | திருமுருகாற்றுப்படை | | |
| Purananuru | | புறநானூறு | | |
| Tirukkural | Thirukkural | திருக்குறள் | | |
| Iraiyanar Akapporul | | இறையனார் அகப்பொருள் | | |
| Tirukkailaya Gnana Ula | Adi Ula; Ula | திருக்கயிலாய ஞான உலா | ஆதி உலா | |
| Vedas | Veda; Tamil Veda | வேதங்கள் | மறை | Tamil Veda → தமிழ் வேதம் |
| Upanishads | | உபநிடதங்கள் | | |
| Agamas | | ஆகமங்கள் | | |
| Puranas | Purana; Puranam | புராணங்கள் | புராணம் |; a single Purana → புராணம் |
| Parva | | பர்வம் | பருவம் | Adi → ஆதி; Sabha → சபா; Vana → வன; Virata → விராட; Udyoga → உத்யோக; Bhishma → பீஷ்ம; Drona → துரோண; Karna → கர்ண; Shalya → சல்லிய; Sauptika → சௌப்திக; Shanti → சாந்தி; Mausala → மௌசல; kept on purpose |
| padalam | Padalam | படலம் | | **padalam titles (Kamban, Kanda Puranam) are written in their Tamil original**, from `scripts/story_data.py` and the caches; never translated from the English transliteration |
| Puranam (a Periya Puranam life) | | புராணம் | | "Kannappa Nayanar Puranam" → கண்ணப்ப நாயனார் புராணம் |
| pathigam | hymn | பதிகம் | திருப்பதிகம் | |

| kandam | Kanda | காண்டம் | | |
| Utpatti Kandam | Utpatti | உற்பத்திக் காண்டம் | | Kanda Puranam |
| Asura Kandam | | அசுர காண்டம் | | Kanda Puranam |
| Mahendra Kandam | | மகேந்திர காண்டம் | | Kanda Puranam |
| Yuddha Kandam | Yuddha Kanda; Yuddha | யுத்த காண்டம் | | Kanda Puranam and Ramayana |
| Deva Kandam | | தேவ காண்டம் | | Kanda Puranam |
| Daksha Kandam | | தட்ச காண்டம் | | Kanda Puranam |
| Bala Kandam | Bala Kanda; Bala | பால காண்டம் | | |
| Aranya Kanda | Aranya | ஆரணிய காண்டம் | | |
| Kishkindha Kanda | | கிஷ்கிந்தா காண்டம் | கிட்கிந்தா காண்டம் | Kamban's quoted titles keep கிட்கிந்தா |
| Sundara Kandam | Sundara Kanda; Sundara | சுந்தர காண்டம் | | |
| Satarudra | | சதருத்ர சம்ஹிதை | | Shiva Purana |
| Vidyesvara | | வித்யேஸ்வர சம்ஹிதை | | Shiva Purana |
| Tiruchchazhal | | திருச்சாழல் | | Tiruvasagam |
| Tiruvundiyar | | திருவுந்தியார் | | Tiruvasagam |
| Kirththit Tiruvagaval | | கீர்த்தித் திருஅகவல் | | Tiruvasagam |
| Arutpathu | | அருட்பத்து | | Tiruvasagam |
| Tiruvammanai | | திருவம்மானை | | Tiruvasagam |
| Tiruporchunnam | | திருப்பொற்சுண்ணம் | | Tiruvasagam |
| Tantra | | தந்திரம் | | the nine parts of Tirumandiram: "ninth Tantra" → ஒன்பதாம் தந்திரம் |
| Adbhuta Koothu | | அற்புதக் கூத்து | | |
| Pitha pirai soodi | Pitha | பித்தா பிறைசூடி | | Sundarar's first hymn |
| Todudaiya Seviyan | Todudaiya | தோடுடைய செவியன் | | Sambandar's first hymn |
| Mantiramavathu Neeru | | மந்திரமாவது நீறு | | |
## Groups, religion and terms

| English | Other English spellings | Tamil | Also seen | Note |
|---|---|---|---|---|
| Tamil | | தமிழ் | | |
| Sanskrit | | சமஸ்கிருதம் | வடமொழி | |
| Sangam | Tamil Sangam; Madurai Sangam | சங்கம் | தமிழ்ச் சங்கம் | |
| Shaiva | Saiva; Tamil Shaiva; Shaivism; Tamil Shaivism | சைவம் | சைவ | adjective → சைவ; kept on purpose |
| Vaishnava | | வைணவம் | வைணவ | |
| Shakta | | சாக்தம் | | |
| Jains | Jain | சமணர்கள் | சமணர் | |
| Buddhists | | பௌத்தர்கள் | | |
| Brahmins | Brahmin | அந்தணர்கள் | பிராமணர் | |
| Vellalas | Vellala | வேளாளர்கள் | | |
| Kapalika | | காபாலிகர் | | |
| Om | Pranava | ஓம் | பிரணவம் | "the Pranava" → பிரணவம் |
| sage | | முனிவர் | ரிஷி | |
| Brahmahatya | | பிரமஹத்தி | | |
| Pashupata | | பாசுபதம் | | the weapon |
| Tandava | | தாண்டவம் | | Urdhva Tandava → ஊர்த்துவ தாண்டவம் |
| Lord | Supreme Lord; Great Lord; Supreme Being; God | இறைவன் | பெருமான் | "the Lord" on its own → இறைவன்; with a name, use the honorific form of that name; kept on purpose; பெருமான் in an epithet such as உலகை உண்ட பெருமான் |
| verse | | பாடல் | செய்யுள் | "verse 1851" → பாடல் 1851 |
| song | | பாடல் | | "song 835" → பாடல் 835 (the Thiruppugazh number) |
| trident | | சூலம் | திரிசூலம் | |
| Vedic | | வேத | | adjective |
| Dharma | | தருமம் | | |
| Gayatri | | காயத்ரி | | |
| Thiruvathirai | Ardra | திருவாதிரை | | the star |
