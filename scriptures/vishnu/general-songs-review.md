# Review of the vague and low-confidence songs

Session 1, 2026-10-26. Covers the 57 songs in `song-story-map.txt` whose only tags are `vishnu-general`,
`vishnu-lakshmi`, `vishnu-war`, `vishnu-asura-victory`, `ram-general`, `krishna-general` or `ram-sita`, or whose
confidence is `low`. For each I read the line-by-line commentary stored in the app database (`meanings`, aligned with
`words`) around the nephew line and the other stanzas of the song, not just the line before the nephew word.
Nothing in the map has been changed; this file proposes changes for the owner to apply.

Slugs are those in `scripts/story_data.py`. Proposed new slugs are marked NEW. Confidence: h / m / l.

## Result in one line

- 17 songs get a concrete story (or a confirmed story): 9, 14, 89, 95, 193, 233, 237, 272, 534, 586, 587, 679, 752,
  875, 902, 1325, and 449 (Rama confirmed, no episode).
- 6 more get only a weak specific tag (a weapon, the cosmic form, Trivikrama): 172, 718, 808, 852, 1186, 1191.
- 34 stay general: the commentary names Vishnu with an epithet and nothing else.
- 5 songs contradict the current map: 233, 272, 586, 902, 193 (details in the last section).

## A. Concrete story found

| Song | Title | Nephew line | What the commentary says | Proposed slug(s) | Conf | vs current map |
|---|---|---|---|---|---|---|
| 9 | கருவடைந்து | அரிமுகுந்தன் மெச்சுற்ற பண்பின் மருகோனே | Defeated the asura clans, glossed 'ஹரிமுகுந்தனாம் ஸ்ரீராமன்', i.e. Rama | `ram-ravana-war` | m | was `vishnu-asura-victory` (low): now Rama |
| 14 | சருவும்படி | செயதுங்கமுகுந்தன் மகிழ்ந்தருள் மருகோனே | Same song also says he ate curd stolen from the cowherds' houses (தயிர் உண்டவன்); the Mukunda line adds a wrestling victory ('மற்போரில் வெல்லும்') | `krishna-butter`, `krishna-kamsa` (wrestlers) | m | was `vishnu-general` (low) |
| 89 | மான்போல் கண் | காண்டேர்க்கொண் டேவு மச்சுதன் மருகோனே | Heads rolling like balls, arrow shot from a fine chariot, 'ராமனாம் திருமால்' | `ram-ravana-war` | h | confirms; raise from low to high |
| 95 | வஞ்சங்கொண்டும் | உயர்ந்தம்புங் கொண்டுவெல் மாதவன் மருகோனே | Killed the asuras with arrows, 'ராமனின் (திருமாலின்) மருகனே' | `ram-ravana-war` | h | was `vishnu-war` (low): now Rama |
| 193 | வஞ்சனை மிஞ்சி | கண்குளிருந் திருமால் மகிழ்ந்தருள் மருகோனே | Names Kamsa's cart demon (சகடாசுரன்) defeated, then climbing the kurunda tree with the gopis' eyes red with anger | `krishna-sakata`, `krishna-vastra-harana` | h | was `vishnu-general` (low) |
| 233 | வாரம் உற்ற | சூகரத்தொடு ... சூதனுக்கிசைந்த மருகோனே | 'பன்றியின் உருக்கொண்டு அழகிய பூமியை மேலே எடுத்து வந்த ... திருமால்' (the boar lifting the earth) | `varaha` | h | **contradicts**: map said `krishna-partha-sarathi, mbh-kirata`; remove those |
| 237 | விரித்த பைங்குழல் | வணத்த ரம்பர முறவிடு கணையினர் மருகோனே | Vishnu wearing tulasi, 'கடல் மீது செலுத்திய (கோதண்ட) பாணத்தை உடையவர்' | `ram-samudra-arrow` | m | was `ram-general` (low) |
| 272 | தாக்கு அமருக்கு | மார்க்கமுடித்தவிலாளிகள் நாயகன் மருகோனே | Surpanakha, noseless, goes to Ravana and describes Sita's beauty; Ravana carries Sita off in a single chariot to Lanka and imprisons her; her clan is then uprooted; 'வில்லாதி வீரர்களின் தலைவனாம் ராமனின் மருமகனே' | `ram-ravana-war` plus NEW `ram-sita-abduction` | h | **contradicts**: map said `krishna-banasura` (low); remove it |
| 449 | கனகசபை மேவும் | சனகிமண வாளன் மருகனென | 'ஜானகியின் மணவாளன் ஸ்ரீராமனின் மருமகன்' | `ram-general` (no episode) | h | confirms; just a relationship |
| 534 | கள்ளக் குவால் பை | வெள்ளுத்தி மாற்கு மருகோனே | Nephew of Indra (white elephant) and of Vishnu 'வெண்ணிறமான திருப்பாற் கடலில் உறையும்' | `vishnu-sleeping` | m | was `vishnu-general` (low) |
| 586 | பந்து ஆடி அம் கை | கன்றா முகுந்தன் மருகோனே | 'கன்றுகளை உடைய பசுக்களுக்குப் பிரியமானவர் ஆகிய கண்ணன்': Krishna beloved of cows with calves, not a calf demon | NEW-use `krishna-cowherd` | m | **contradicts**: map said `krishna-vatsasura` (low) |
| 587 | வண்டார் மதங்கள் | பண்போனுகந்த மருகோனே | 'சக்கரம், சங்கு ... பாற்கடலில் துயில் கொள்ளும் திருமால்' | `vishnu-sleeping`, `vishnu-panchajanya` | h | was `vishnu-panchajanya` (low): add sleeping |
| 679 | பாற்றுக் கணங்கள் | பாய்க்குட் டுயின்ற வன்றன் மருகோனே | The five weapons named (nandaka sword, Sudarshana, Panchajanya, Kaumodaki mace, Sarnga bow), Vishnu on Adisesha in the milk sea | `vishnu-sleeping`, `vishnu-sudarshana`, `vishnu-panchajanya` | h | was `vishnu-sleeping` (low): confirms, adds weapons |
| 752 | பசை அற்ற உடல் | வடிவுற்ற முகில்கிட்ணன் மருகோனே | Krishna of 'கணக்கற்ற வடிவங்கள்' (countless forms, footnoted) out of lasting love for the Pandavas; the Vishwarupa shown in the Kuru court fits | `krishna-envoy`, `krishna-pandava-friend` | l | was `krishna-general` (low): a guess |
| 875 | கடகரிம ருப்பிற்க | விழைமருக கொக்கிற்ச ... | 'திருமால் ... யானை கூச்சலிட்டதை ... கருடன் மேல் ... வந்த' (the elephant's cry, Garuda); the 'crane' in the line is the mango-tree Surapadma | `gajendra`, `vishnu-sleeping` | h | was `vishnu-general` (low) |
| 902 | இகல்கடின முகபடவி | அரிமருக அறுமுகவ முக்கட்கணத்தர்துதி | A battlefield image: 'பட்டப் பகலில் சூரியனை சக்ராயுதத்தை விடுத்து அஸ்தமிக்க வைத்தது போல இருளாக்க' (as if the discus made the sun set at midday) | NEW-use `mbh-jayadratha` | h | was `vishnu-general` (low); this is the Sudarshana sun-hiding story, same as song 568 |
| 1325 | உரையுஞ் சென்றது | அன்புறு மருகன் தென்புன வாயில் | Hanuman tells Rama how Sita, carried off in the Pushpaka chariot, threw her jewels down; also Narayana measuring the sky as Trivikrama | NEW `ram-sita-jewels` (Sita's dropped ornaments shown to Rama), `vamana` | h | was `vishnu-general` (low): Ramayana |

## B. Weak specific tags

| Song | Title | Nephew line | What the commentary says | Proposed slug(s) | Conf |
|---|---|---|---|---|---|
| 172 | நெற்றி வெயர்த்துளி | நத்தணி செக்கரன் மகிழ்ச்சி கூர்தரு மருகோனே | Vishnu with the conch in his red hands, delighted | `vishnu-panchajanya` | l |
| 718 | குதிபாய்ந்தி ரத்தம் | அடற்சக்ரந் தரித்த கொண்டல் மருகோனே | Lists mace, Sarnga, sword, Panchajanya and Sudarshana | `vishnu-panchajanya`, `vishnu-sudarshana` | m |
| 808 | பச்சை யொண்கிரி | நற்கரந்தநு கோல்வளை நேமியர் மருகோனே | Sleeps on Adisesha; holds bow, arrow, conch, discus | `vishnu-sleeping`, `vishnu-sudarshana` | m |
| 852 | எகினி னம்பழி | திருவு றைந்துள மார்பகனார் திருமருகோனே | 'செகமும் அண்டமும் ஓர் உருவாய் நிறை' (filling worlds and universes as one form), Lakshmi on his chest | `vishnu-supreme`, `vishnu-lakshmi` | l |
| 1186 | மதனேவிய கணை | வெளியாசையொ டடைபூவணர் மருகா | 'ஆகாயம், திசைகள் எல்லாம் நிறைந்துள்ள ... நீலவண்ணத்து திருமால்': the all-pervading blue Lord | `vishnu-supreme` | l |
| 1191 | முத்தம் உலாவு | மைத்துன னாகி யவிக்ரமன் மருகோனே | Lakshmi's brother-in-law, 'வலிமையாளனான திருமால்' (footnoted); Vikraman may allude to Trivikrama | `vishnu-lakshmi`, possibly `vamana` | l |

## C. Stay general

For each the commentary only names Vishnu by an epithet, a colour, a consort or a weapon, with no episode.

| Song | Title | Nephew line | Commentary says |
|---|---|---|---|
| 35 | உருக்கம் பேசிய | செகச்செஞ் சோதியுமாகிய மாதவன் மருகோனே | Madhava as the world's great light |
| 78 | பரிமள களப | அரிதிரு மருகக டம்பத் தொங்கற் றிருமார்பா | Nephew of Vishnu and Lakshmi |
| 98 | வரியார் கருங்கண் | அரிகே சவன்றன் மருகோனே | Hari-Keshava's nephew |
| 122 | உலகபசு பாச | சரவணபவாமு குந்தன் மருகோனே | Mukunda's nephew |
| 130 | கரிய மேகமதோ | பழைய மாயவர் மாதவனார்திரு மருகோனே | Lakshmi's lover, Narayana who removes sins, the ancient Mayavan; the banyan-leaf line is about a woman's belly |
| 151 | கொந்துத் தரு | செங்கட் கருமுகில் மருகா குகனே | Red-eyed dark-cloud Vishnu |
| 206 | எந்தத் திகையினும் | அம்பொற்கொடியிடை புணரரி மருகநல் | Husband of Lakshmi |
| 225 | நிறைமதி முகமெனும் | மறைபயி லரிதிரு மருகோனே | Vishnu and Lakshmi named in the Vedas |
| 246 | உய்யஞானத்து நெறி | கையமால் வைத்ததிரு மருகோனே | 'திருமால் அன்போடு மார்பில் வைத்த லக்ஷ்மி': Lakshmi's nephew (the 'unclear' reading is settled) |
| 385 | உருகும் மாமெழுகாக | துளபமாலையை மார்பணி மாயவன் மருகோனே | Keshava with five weapons, tulasi garland |
| 391 | கெஜ நடை மடவார் | திருநெடு கருமால் மருகோனே | Dark Vishnu; the same stanza has Murugan imprisoning Brahma |
| 417 | கேதகையபூ முடித்த | நீலநிற மால்தனக்கு மருகோனே | Blue Vishnu |
| 467 | முகசந்திர புருவம் | மருகென்றணி விருதும்பல ... | Reads 'மருகன் என்று': Manmatha's father Vishnu, ruined by wording; no episode |
| 494 | தறுகணன் மறலி | நறுமல ரிறைவி யரிதிரு மருக | Nephew of Lakshmi and Vishnu |
| 603 | புற்புதம் | சக்ரகதை பாணி மருகோனே | Discus and mace in hand |
| 632 | குதலை மொழியினார் | முகிலை யனையதா நிறத்த மால்திரு மருகோனே | Cloud-coloured Vishnu |
| 636 | திருமகள் உலாவும் | திருமருக நாமப் பெருமாள்காண் | Murari, Lakshmi playing on his arms |
| 680 | ஆலம் போல் எழு | பாசந்தா திருமாலின் மருகோனே | Vishnu who loves Shiva, the slayer of Andhaka with the trident; no Vishnu deed |
| 685 | மருமல்லி யார் | கருநெல்லி மேனியரி மருகோனே | Hari the colour of a dark gooseberry |
| 687 | சொருபப் பிரகாச | பிடிகைத்தல ஆதியரி மருகோனே | Hari with weapons in hand |
| 698 | குசமாகி யாருமலை | நிசநார ணாதிதிரு மருகாவு லாசமிகு | True Narayana; worshipped by Brahma, Indra |
| 713 | திமிர மாமன | சிவசு தாவரி நாரணன் மருகோனே | Hari Narayana |
| 751 | திருமொழி | கருமுகில் பொருநிற அரிதிரு மருமக | Hari and Lakshmi |
| 757 | வாருமிங்கே | நாயகன் பூவாயன் மருகோனே | Narayana, Rama, Keshava, discus-bearer, cowherd of the earth: a list of names |
| 777 | விடம் என மிகுத்த | கமலமல ரொத்தவிழி யரிமருக | Lotus-eyed Hari |
| 827 | புலவரை ரக்ஷி | எழிலியெ ழிற்பற்றுங்காய மாயவன் மருகோனே | Cloud-bodied Vishnu |
| 834 | மைக்குழல் ஒத்த | மொய்த்தம ணத்தது ழாயோன் மாயோன் மருகோனே | Vishnu with the tulasi garland |
| 847 | எருவாய் கருவாய் | சிறுவா திருமால் மருகோனே | Vishnu's nephew |
| 913 | நெய்த்த சுரி | சக்ரதரஅரி மருகா முருகா | Discus-bearer |
| 1073 | கலந்த மாதும் | மலர்ந்த பூவின் மங்கையை மருவரி மருகோனே | Embraced Lakshmi |
| 1085 | கொலையிலே மெத்த | உடையனே விஷ்ணு மருகோனே | Names Vishnu outright |
| 1213 | ஆசைக் கொளுத்தி | சீர்பொற் பதத்தஅரி மருகோனே | Hari with golden feet |
| 1275 | மூலா நிலமதின் | நாராயணர்திரு மருகோனே | 'ஹரிஹரி' Narayana and Lakshmi; the 'நாலாயது' in the song reads as 'the four (Vedas)' in the commentary, not a Divya Prabandham reference (not fully verified) |
| 1332 | அனத்தோடொப்பா | முனைப்பாடிக்கே திரிதரும் அரிதிரு மருகோனே | No commentary in the database (`meanings` is empty); the line names Hari-Tiru and the place Munaippadi |

## D. Corrections to apply to `song-story-map.txt`

1. 233: replace `krishna-partha-sarathi,mbh-kirata` with `varaha` (commentary says the boar lifting the earth). Also drop
   its entries in `krishna-episodes.md` / `krishna-verses.md` (`kirata`, `gita-chariot`) when rebuilt.
2. 272: replace `krishna-banasura` with `ram-ravana-war,ram-sita-abduction`. This is a Ramayana song about Surpanakha and
   Ravana carrying off Sita. Remove it from the Krishna episode `banasura`.
3. 586: replace `krishna-vatsasura` with `krishna-cowherd` (Krishna as friend of the cows, not the calf demon).
4. 902: replace `vishnu-general` with `mbh-jayadratha`; it is the same sun-hiding image as song 568. Add to the
   episode `jayadratha`.
5. 193: replace `vishnu-general` with `krishna-sakata,krishna-vastra-harana`.
6. 9, 95, 237, 1325: move into the Ramayana (9, 95: `ram-ravana-war`; 237: `ram-samudra-arrow`; 1325: `ram-sita-jewels`
   plus `vamana`).
7. 14: add `krishna-butter`. 875: `gajendra`. 534, 587, 679, 808: add `vishnu-sleeping`. 752: `krishna-envoy`
   (low).
8. New story files to write if accepted: `ram-sita-abduction` (Surpanakha mutilated; Ravana lures and carries Sita off;
   Valmiki Aranya 17-19 and 49, Kamba Aranya: சூர்ப்பணகைப், இராவணன் சூழ்ச்சிப் படலம்) and `ram-sita-jewels` (Sita drops her
   ornaments from the Pushpaka chariot; Hanuman later shows them to Rama; Valmiki Kishkindha 6 is the likely place, to be
   checked).

## How the review was done

The app database stores a prose rendering per phrase (`meanings` aligned to `words`). For each song I pulled the phrases
that contain the nephew word or a Vishnu term (திருமால், ராமன், கண்ணன், சக்கரம், பாற்கடல்...) and read the song's other
stanzas where the first reading was thin (272, 902, 1325, 752, 875, 1191, 233, 14). Songs whose commentary names only an
epithet were left general rather than guessed. A footnote asterisk in the database text (for example on 752, 1191) marks
a commentator's note that is not stored with the meaning, so those two readings stay low.
