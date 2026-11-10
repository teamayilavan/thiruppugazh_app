# -*- coding: utf-8 -*-
"""Builds the sambandar/, saints/, devi/ and murugan/ story sets under scriptures/.

HAND-WRITTEN catalogue (CATALOGUE below) + generator. Reads assets/thiruppugazh.db READ-ONLY.
Run from anywhere:   python -I scriptures/scripts/build_new_sets.py

How a song gets into a story
  * `ids`  : explicit list from the commentary sweep (research-findings of 2026-11-10), or
  * `auto` : every song whose English commentary matches `en`.
  Each assignment is checked: if the English commentary does not match `en`, the song is still listed
  but marked confidence `low` and printed as a warning.
How a song is quoted
  * the first lyric line (spaces/dots removed) matching the Tamil regex `ta`, with one line either side
    (exact text from songs.lyrics_list); if no line matches, the commentary sentence is quoted instead
    and the song is marked as commentary-only.
Confidence codes:  t = Tamil lyric line found + commentary agrees;  c = commentary only (Tamil keyword line not found);
                   low = commentary did not match the story pattern (check by reading the song).
These are KEYWORD-LEVEL assignments, not yet hand-read like shiva/ and vishnu/. Generated files say so.
"""
import json, re, sqlite3, sys
from pathlib import Path

sys.stdout.reconfigure(encoding="utf-8")
ROOT = Path(__file__).resolve().parents[2]
SCR = ROOT / "scriptures"
DB = ROOT / "assets" / "thiruppugazh.db"

# ---------------------------------------------------------------- source links (opened earlier or this session)
PP_SAM = "https://thevaaram.org/thirumurai_1/onepage.php?thiru=12&Song_idField=12280"
TEV = "https://thevaaram.org/thirumurai_1/songview.php?thiru=%d&Song_idField=%d&padhi=%03d"
TEV111 = TEV % (1, 1001, 1)
TEV266 = TEV % (2, 2066, 66)
TEV339 = TEV % (3, 3039, 39)
TEV354 = TEV % (3, 3054, 54)
TEV332 = TEV % (3, 3032, 32)
TVP62 = "https://ta.wikisource.org/wiki/%E0%AE%A4%E0%AE%BF%E0%AE%B0%E0%AF%81%E0%AE%B5%E0%AE%BF%E0%AE%B3%E0%AF%88%E0%AE%AF%E0%AE%BE%E0%AE%9F%E0%AE%B1%E0%AF%8D_%E0%AE%AA%E0%AF%81%E0%AE%B0%E0%AE%BE%E0%AE%A3%E0%AE%AE%E0%AF%8D/62"
TVP63 = TVP62[:-2] + "63"

OPENED = "opened (summary-level)"
OPENED_EARLIER = "opened in the Shiva pass"
SEARCH = "search result only (tradition)"
MEMORY = "from memory, not opened"

# ---------------------------------------------------------------- the sets
SETS = {
    "sambandar": dict(
        name="Thirugnana Sambandar",
        intro=("Songs that name the child saint Sambandar of Sirkazhi, or tell an episode of his life. In the Thiruppugazh "
               "tradition (and in the English commentary stored with each song) Murugan is said to have come into the world as "
               "Sambandar, so many songs simply say \"You came as Thirugnana Sambandhar\". The existing "
               "`shiva/stories/saints-sambandar.md` covers 20 songs of the Jain contest; this set widens it to the whole life."),
        domains=[("The child saint", ["sam-avatar", "sam-birth", "sam-milk", "sam-todudaiya"]),
                 ("Journeys and companions", ["sam-yazhpanar", "sam-palanquin", "sam-three-saints", "sam-thiruvalangadu"]),
                 ("Miracles", ["sam-poompavai"]),
                 ("Madurai and the Jains", ["sam-fever", "sam-ordeals", "sam-jains"])],
        sources=[
            ("Periya Puranam (Sekkizhar, Tirumurai 12), Sambandar Puranam", "thevaaram.org one-page view, verses 1-822 read through a page summariser; verse numbers are the page's own numbering and approximate. Poompavai and the later part of the Puranam were not reached.", OPENED),
            ("Tevaram of Sambandar (Tirumurai 1-3)", "pathigam links 1.1.1, 2.66.1, 3.32.1, 3.39.1, 3.54.1 were opened in the Shiva pass.", OPENED_EARLIER),
            ("Tiruvilaiyadal Puranam (Paranjothi), padalams 62-63", "prose retelling on Tamil Wikisource, opened in the Shiva pass.", OPENED_EARLIER),
        ],
        open_q=["Verse numbers: the Shiva file cites running numbers (764, 846, 855); the page view used here puts the cure at 736-772 and the river test at 813-816. They differ. Pick one scheme before any machine-check.",
                "Poompavai (Mylapore) is in the Periya Puranam late in the Sambandar Puranam; the verse range was not pinned. The hymn is Tevaram 2.47 (page opened). Accounts differ on how she died (bones in a pot; a snake-bite in one source).",
                "Episodes in the Puranam with NO song found: golden cymbals (Tirukkolakka), the 1000 gold coins at Tiruvavaduthurai, the famine coins at Veezhimizhalai, the Thirumarugal snake-bite, the cure of Kolli Mazhavan's daughter. Not made into stories.",
                "Sambandar's name appears in the commentary of ~105 songs; every one of them is in `sam-avatar`. Songs that tell a specific episode are also in that episode's story."]),
    "saints": dict(
        name="Other Tamil Shaiva saints and poets",
        intro=("Sundarar, Manikkavasagar, Kannappar and the poet Nakkeerar, as the songs allude to them. Appar, Karaikkal Ammaiyar, "
               "Sambandar (own set) and the general `shiva/stories/saints-nayanmar.md` are not repeated. Most of these episodes are retold "
               "only in the English commentary, not by name in the Tamil lyric."),
        domains=[("Sundarar (Tirumurai 7)", ["n-sundarar-messenger", "n-sundarar-wedding", "n-sundarar-paddy", "n-cheraman-kailasa", "n-sundarar-gold", "n-sundarar-crocodile"]),
                 ("Manikkavasagar and the Madurai sports", ["n-manikkavasagar", "n-vandi-pittu"]),
                 ("Other devotees", ["n-kannappar", "n-nakkeerar"])],
        sources=[
            ("Periya Puranam (Tirumurai 12): Sundarar, Cheraman Perumal, Kannappar puranams", "not opened this session", MEMORY),
            ("Tiruvasagam (Tirumurai 8) and Tiruvilaiyadal Puranam: Manikkavasagar, Vandi's pittu", "not opened this session", MEMORY),
            ("Tirumurugatruppadai (Nakkeerar, Tirumurai 11)", "cave legend found on blogs and temple pages only", SEARCH),
        ],
        open_q=["Songs 555, 862 and 911 contain the Tamil word அப்பர் (Appar or 'father'?). Read in context before deciding.",
                "No Tamil lyric names Siruthondar, Karaikkal Ammaiyar, Chandesar, Nandanar or Thirumoolar (Thirumoolar only as a name in 425).",
                "Tevaram/Periya Puranam verse references for Sundarar's episodes were not looked up."]),
    "devi": dict(
        name="Ambal, Parvati, Durga and Kali",
        intro=("Stories of the Goddess as the songs allude to them: her birth to Himavan, her penances at Kanchi and "
               "Thiruppathirippuliyur, her dance contest with Shiva, Durga and Mahishasura, and her part in Murugan's battles. "
               "`shiva/stories/forms-ardhanari.md` (Uma on Shiva's left) is not repeated."),
        domains=[("Parvati and Shiva", ["d-himavan", "d-kanchi", "d-kamakshi-32", "d-pathiri", "d-thiruvathigai", "d-fisher", "d-angayarkanni"]),
                 ("Kali and Durga", ["d-kali-dance", "d-mahisha", "d-battlefield", "d-matangi", "d-idumbai"])],
        sources=[
            ("Devi Mahatmya (Markandeya Purana, usually ch. 81-93; numbering varies by edition): Mahishasura = Madhyama Charitra, ch. 2-4", "chapter structure from a web search; not read", SEARCH),
            ("Kanchi Puranam; Thirukkurippu Thondar Puranam (Parvati and the sand lingam at Kanchi)", "named by a temple website; text not found", SEARCH),
            ("Sthala puranams: Thiruppathirippuliyur, Thiruvalangadu (Kali's dance contest), Kanchi", "temple and news pages", SEARCH),
            ("Tiruvilaiyadal Puranam: Parvati as the fisherman's daughter, Angayarkanni", "not opened this session", MEMORY),
        ],
        open_q=["Shumbha, Nishumbha and Raktabija are NOT in the songs: the Tamil string சும்ப is only part of other words. No story made.",
                "Kamakshi's thirty-two dharmas (முப்பத்திரண்டு அறம்): the source text was not found.",
                "Song 53 (Vana Durga, Kali) may mention Parvati giving the Vel; not confirmed, not assigned.",
                "Kanchi tradition says Parvati embraced the sand lingam as the Vegavati flooded; the Tamil text names are from a temple site."]),
    "murugan": dict(
        name="Murugan's own lore (Kanda Puranam)",
        intro=("The life of Murugan as told in the Kanda Puranam (Kachiyappa Sivacharyar) and the Skanda Purana: the battle with Surapadman, "
               "Valli and Deivayanai, Brahma's imprisonment. These are by far the most frequent stories in the Thiruppugazh. "
               "`shiva/stories/murugan-pranava.md` and `murugan-skanda-birth.md` already exist and are not repeated; they are linked below. "
               "Because the matches here are automatic (see README), expect noise, especially in the Valli and Surasamharam stories."),
        domains=[("Surasamharam", ["m-mango-sura", "m-krouncha", "m-sea-dried", "m-peacock-cock", "m-tarakasura", "m-jayanta"]),
                 ("Brahma and the sages", ["m-brahma-prison", "m-agastya"]),
                 ("Birth and childhood", ["m-saravana"]),
                 ("Valli and Deivayanai", ["m-valli-disguise", "m-deivayanai", "m-airavata"])],
        sources=[
            ("Kanda Puranam (Kachiyappa Sivacharyar), six kandams: Utpatti, Asura, Mahendra, Yuddha, Deva, Daksha", "kandam list from web search; episode-to-kandam mapping and padalam numbers not confirmed", SEARCH),
            ("Skanda Purana, Sankara Samhita (source of the Tamil work)", "not opened", MEMORY),
            ("Tirumurugatruppadai (Nakkeerar)", "not opened", MEMORY),
        ],
        open_q=["Which kandam holds the Valli marriage was not confirmed.",
                "Kanda Puranam verses are not pinned for any story here.",
                "Counts for Surasamharam stories are inflated by songs that only list Murugan's deeds in a line; read before relying on them.",
                "Already in the Shiva set: Murugan teaches Shiva the Pranava (68 songs) and Murugan born from Shiva's eye (4).",
                "Ganesha frightening Valli and the fruit contest moved to `ganesha/`; Agastya and Tamil are also in `tamil-lore/`."]),
    "ganesha": dict(
        name="Ganesha",
        intro=("Three Ganesha stories the songs allude to, usually as 'you are the younger brother of Ganapathi': the elephant that frightens Valli, "
               "the race around the world, and the scribe of the Mahabharata."),
        domains=[("Ganesha", ["g-valli-elephant", "g-race", "g-scribe"])],
        sources=[("Mahabharata (frame story), Shiva Purana Kumara Khanda, Tamil tradition", "not opened", MEMORY)],
        open_q=["The fruit version of the race (Narada's fruit, Pazhani) is in the commentary of only one song (532); song 30 has the race without the fruit, 934 is weaker.",
                "Not found in the songs: Ganesha and the Kaveri crow, Gajamukhasura, Avvaiyar's Vinayagar Agaval."]),
    "tamil-lore": dict(
        name="Tamil literary lore",
        intro="References to Sangam and classical Tamil tradition: the Madurai Sangam, Agastya, Pari and Kari, and a temple legend of the Chola country.",
        domains=[("Sangam and classics", ["t-sangam", "t-agastya", "t-patrons", "t-classics"]), ("Temple legend", ["t-spider-elephant"])],
        sources=[("Tiruvilaiyadal Puranam; Sangam poems; sthala puranams", "not opened this session", MEMORY)],
        open_q=["Not in the songs: Silappathikaram, Manimekalai, Avvaiyar, Kamban as a character, Kapilar (one passing mention in song 138 among sages).",
                "Nakkeerar is in `saints/n-nakkeerar`; the Vandi and Vaigai stories in `saints/n-vandi-pittu`."]),
}

# ---------------------------------------------------------------- the stories
SAM_ALL = [17,58,82,104,115,116,121,123,132,134,137,149,150,171,189,257,261,263,299,306,308,354,356,358,405,426,490,509,521,527,540,550,565,573,603,604,617,636,639,641,651,653,658,666,668,669,674,677,681,693,708,712,737,744,758,759,762,764,766,767,768,769,771,774,776,789,799,822,823,831,837,846,859,878,888,902,913,920,959,962,971,995,996,1022,1033,1046,1072,1083,1098,1100,1146,1162,1166,1209,1233,1257,1263,1266,1270,1282,1287,1291,1317,1326,1327]

def R(src, ref, note, status, url=""):
    return (src, ref, note, status, url)

CATALOGUE = [
 # ------------------------------------------------------------------ SAMBANDAR
 dict(slug="sam-avatar", set="sambandar", title="Murugan comes as Sambandar (the Tamil Veda)", ids=SAM_ALL, review="All 105 read. 95 say outright that Murugan came as, or is, Sambandar. Four (121, 354, 521, 1166) name the saint as a separate figure (author of the Tevaram, companion of Yazhpanar, one of the three saints) without identifying him with Murugan; they stay here because they name him.",
      en=r"Sambandh|ThirugnAna|GnAna ?Sambandh|Sambandhan", ta=r"சம்பந்|ஞானசம்|கவுணிய|புகலி|காழி",
      brief=("The songs say that Murugan himself took birth as the child saint Sambandar of Sirkazhi and gave the world the Tevaram hymns, "
             "'the Tamil Veda'. Most of these songs state this in one line without telling an episode; the specific episodes are in the stories that follow. "
             "This is the umbrella story: every song that names Sambandar is listed here."),
      refs=[R("Tevaram (Tirumurai 1-3)", "Sambandar's 384 pathigams", "the hymns the songs call the Tamil Veda", OPENED_EARLIER, TEV111),
            R("Periya Puranam, Sambandar Puranam", "whole puranam (~1256 verses, running numbers)", "life of the saint", OPENED, PP_SAM)]),
 dict(slug="sam-birth", set="sambandar", title="Born at Sirkazhi among the Kavuniyas", ids=[134,261,521,758,764,774,837,913,1317],
      en=r"Seeg|SeekAzhi|Seekazhi|Pugali|Pukali|SirkAzhi|Sirkazhi|KavuN?iya|Kazhumalam|Kochchai", ta=r"காழி|புகலி|கவுணிய|கொச்சை|கழுமல",
      brief=("Sambandar was born at Sirkazhi (Pugali, Kazhumalam, Kochchai: the town has twelve names) in the Kavuniya Brahmin line, to Sivapadahridayar and Bhagavathiyar. "
             "The songs name the town and the lineage."),
      refs=[R("Periya Puranam, Sambandar Puranam", "vv. 1-26 (page numbering): the town and its twelve names (v. 14), the parents (15-18), the birth (19-26)", "", OPENED, PP_SAM)]),
 dict(slug="sam-milk", set="sambandar", title="Uma feeds the crying child the milk of wisdom", ids=[137,426,641,737,822,837,920,1046,1100,1287],
      en=r"milk|breast-?fed|breast", ta=r"உமைமுலை|முலையின்செழும்பால்|பாலுண்|ஞானப்பால்|பாற்கொடு|பால்குடி|அமுதுண்",
      brief=("As a three-year-old Sambandar was left on the bank of the temple tank while his father bathed, and cried. Shiva and Uma appeared, and Uma gave him milk "
             "of Shiva-wisdom from a golden bowl. The songs say the hymns flowed from that milk."),
      refs=[R("Periya Puranam, Sambandar Puranam", "vv. 59-69 (page numbering); the Shiva pass cites vv. 66 and 68 in running numbers", "", OPENED, PP_SAM),
            R("Tevaram 1.1.1", "Todudaiya Seviyan", "the hymn sung straight after the milk", OPENED_EARLIER, TEV111)]),
 dict(slug="sam-todudaiya", set="sambandar", title="'Todudaiya Seviyan', the first hymn", ids=[776],
      en=r"Th?OdudaiyA?|ThOdudaiya|Todudaiya", ta=r"தோடுடைய|தோடு",
      brief="With the milk still on his lips the child points to Shiva and sings the first Tevaram hymn, beginning 'Todudaiya Seviyan'. Song 776 names it.",
      refs=[R("Tevaram 1.1.1", "Todudaiya Seviyan", "first hymn of the Tevaram", OPENED_EARLIER, TEV111),
            R("Periya Puranam, Sambandar Puranam", "vv. 70-76 (page numbering)", "", OPENED, PP_SAM)]),
 dict(slug="sam-yazhpanar", set="sambandar", title="Thiruneelakanta Yazhpanar plays the hymns on the lyre", ids=[354],
      en=r"yAzh|ThiruneelakaNda|Yazhpan", ta=r"யாழ்|பாணன்|நீலகண்ட",
      brief=("The minstrel Thiruneelakanta Yazhpanar and his wife joined Sambandar and played his hymns on the yazh. One hymn was too large for the instrument, "
             "which broke, and Sambandar gave him a new one. Song 354 names the minstrel at Thiruvanaikka."),
      refs=[R("Periya Puranam, Sambandar Puranam", "vv. 131-141 (arrival), 278-281 (golden cymbal mentioned), 440-459 (the lyre breaks); page numbering", "", OPENED, PP_SAM)]),
 dict(slug="sam-palanquin", set="sambandar", title="The pearl palanquin, umbrella and canopy", ids=[758],
      en=r"palanquin", ta=r"சிவிகை|முத்துக்குடை|முத்துச்",
      brief="At Thiruvarathurai Shiva gave the child saint a pearl palanquin, umbrella and royal insignia, which the local Brahmins carried to him. Song 758 names the gift.",
      refs=[R("Periya Puranam, Sambandar Puranam", "vv. 177-212 (page numbering); key verse 195 'ஏறுதற்குச் சிவிகை இடக்குடை'", "", OPENED, PP_SAM)]),
 dict(slug="sam-three-saints", set="sambandar", title="Appar, Sundarar and Sambandar; Vedaranyam", ids=[121,343,1166],
      en=r"VEdAraNyam|Vedaranyam|Appar, Sundarar|Appar|Three great Saivite", ta=r"அப்பர்|வேதாரண்ய|மறைக்காடு|சுந்தரர்",
      brief=("Sambandar met Appar at Sirkazhi and Tiruvarur and travelled with him; at Vedaranyam (Thirumaraikkadu) Appar's hymn opened the temple doors and "
             "Sambandar's closed them. The songs only name the places or the three saints together; they do not narrate the doors."),
      refs=[R("Periya Puranam, Sambandar Puranam", "vv. 269-277 (first meeting), 493-508 (Tiruvarur), 576-592 (the doors); page numbering", "", OPENED, PP_SAM)]),
 dict(slug="sam-thiruvalangadu", set="sambandar", title="Sambandar at Thiruvalangadu", ids=[674],
      en=r"ThiruvAlangkAdu|Thiruvalangadu", ta=r"ஆலங்காடு|வாலங்காடு",
      brief="Song 674 says Murugan came as Sambandar to Thiruvalangadu, where Shiva danced for the celestials. The link to the Kali contest is in the devi/ set (d-kali-dance).",
      refs=[R("Tevaram, Sambandar (Thiruvalangadu pathigam)", "pathigam number not checked", "", MEMORY)]),
 dict(slug="sam-poompavai", set="sambandar", title="Poompavai brought back from the bones", ids=[150,693,944],
      en=r"P.mb.vai|PUmpAvai|skeleton", ta=r"பூம்பாவை|என்பு|எலும்பு|செட்டி|மயிலை",
      brief=("At Mylapore the merchant Sivanesar had kept the ashes and bones of his dead daughter Poompavai, hoping for Sambandar. The saint sang a Tevaram hymn "
             "and she rose from the pot as a living girl. The songs say 'brought the skeleton back as a girl'."),
      refs=[R("Periya Puranam, Sambandar Puranam", "late in the puranam; verse range not pinned (the page view did not reach it)", "", MEMORY),
            R("Tevaram 2.47 (Thirumayilai / Mylapore)", "the 'Poompavai' pathigam; the page's history note says Sambandar had the pot of bones brought and sang the decad", "number confirmed on the opened page; a search snippet recalled '2.61' from memory, which does not match", OPENED, TEV % (2, 2047, 47))]),
 dict(slug="sam-fever", set="sambandar", title="The Pandya's fever and hunchback cured with holy ash", ids=[171,299,527,573,639,666,762,768,789,920,962,1162],
      en=r"fever|hunch|PANdiy|Pandiy|Pandya", ta=r"வெப்பு|கூன்|நீறு|பாண்டிய|நெடுமாற|வெண்பொடி|திருநீ",
      brief=("Under Jain influence the Pandya king (Koon Pandyan, later Nindrasir Nedumaran) fell to a fever after the Jains' fire was turned on him. Queen Mangaiyarkkarasi "
             "and the minister Kulachchirai called Sambandar, who sang 'Mantiramavathu Neeru', put holy ash on the king, cured the fever and straightened his hunchback."),
      refs=[R("Periya Puranam, Sambandar Puranam", "vv. 599-772 (page numbering): summons, the fire plot (678-704), the fever (705-716), the cure (736-772)", "", OPENED, PP_SAM),
            R("Tevaram 2.66.1", "Mantiramavathu Neeru", "the ash hymn", OPENED_EARLIER, TEV266),
            R("Tevaram 3.39.1", "Maninernvizhi", "sung to the frightened queen", OPENED_EARLIER, TEV339),
            R("Tiruvilaiyadal Puranam", "padalam 62", "", OPENED_EARLIER, TVP62)]),
 dict(slug="sam-ordeals", set="sambandar", title="Palm-leaf in the fire and against the Vaigai", ids=[104,149,189,358,542,617,666,920,1098,1270],
      en=r"palm[- ]?(leaf|leaves)|Vaigai|Vaihai", ta=r"ஏடு|வைகை|புனல்|எதிரேற|கனல்|தீயிட",
      brief=("The Jains proposed contests: both sides' palm-leaf scriptures were thrown into fire (Sambandar's stayed green), then into the flooded Vaigai (his leaf went upstream "
             "and halted at Tiruvedagam while theirs was swept away)."),
      refs=[R("Periya Puranam, Sambandar Puranam", "fire test vv. 773-796, river test 797-816 (page numbering)", "", OPENED, PP_SAM),
            R("Tevaram 3.54.1", "Vazhga Andhanar", "river test", OPENED_EARLIER, TEV354),
            R("Tevaram 3.32.1", "Tiruvedagam", "the leaf halts", OPENED_EARLIER, TEV332),
            R("Tiruvilaiyadal Puranam", "padalam 63", "", OPENED_EARLIER, TVP63)]),
 dict(slug="sam-jains", set="sambandar", review="All 23 read.", drop={771: "Jains stunned by the hymns, not impaled", 888: "Jains named, no gallows"}, title="The Jains impaled (further songs)", ids=[17,132,263,306,405,509,603,653,658,668,669,677,681,767,769,771,799,859,888,1162,1209,1257,1327],
      en=r"[Ss]amaNA|[Cc]hamaNA|[Cc]amaNA|gallows|Jain", ta=r"சமண|கழு|அமண|அருகர்",
      brief=("After losing the debates the Jains were impaled on stakes, according to the tradition the Thiruppugazh repeats. These are songs beyond the 20 already in "
             "`shiva/stories/saints-sambandar.md`; some ids appear in both."),
      refs=[R("Periya Puranam, Sambandar Puranam", "vv. 855-856 in the Shiva pass's running numbers", "", OPENED_EARLIER, PP_SAM),
            R("Shiva set", "shiva/stories/saints-sambandar.md", "the 20 songs and the Puranam verses already collected", "local", "")]),

 # ------------------------------------------------------------------ SAINTS
 dict(slug="n-sundarar-messenger", set="saints", title="Shiva goes as Sundarar's messenger to Paravai", ids=[134,940,1298,1317],
      en=r"messenger|Paravai", ta=r"பரவை|தூது",
      brief="Sundarar had quarrelled with his wife Paravai at Tiruvarur. Shiva himself walked to her door as his devotee's messenger, more than once, to reconcile them.",
      refs=[R("Periya Puranam, Sundarar Puranam (Tirumurai 12)", "the Tiruvarur section", "", MEMORY)]),
 dict(slug="n-sundarar-wedding", set="saints", title="The old man who stops Sundarar's wedding", ids=[717],
      en=r"marriage|rebuk", ta=r"ஓலை|மணம்|திருமண|பித்தா|வழக்கு",
      brief="On Sundarar's wedding day an old man claimed Sundarar was his slave by an ancient bond. Sundarar scorned him, 'you lying madman', until the old man vanished into the temple and was revealed as Shiva.",
      refs=[R("Periya Puranam, Sundarar Puranam (Thadutatkonda Puranam)", "", "", MEMORY)]),
 dict(slug="n-sundarar-paddy", set="saints", title="A mountain of paddy sent to Paravai", ids=[172],
      en=r"paddy", ta=r"நெல்",
      brief="Pleased by Sundarar's Tamil hymns, Shiva ordered heaps of paddy at Kundaiyur delivered to Paravai.",
      refs=[R("Periya Puranam, Sundarar Puranam", "", "", MEMORY)]),
 dict(slug="n-cheraman-kailasa", set="saints", title="Sundarar and Cheraman Perumal go to Kailasa", ids=[170],
      en=r"Cheraman|Chera", ta=r"சேரன்|சேரமான்|குதிரை|கயிலை",
      brief="The Chera king Cheraman Perumal, Sundarar's friend, rode a divine horse to Kailasa after Sundarar was taken up on a white elephant. There the king sang his Kailaya Gnana Ula.",
      refs=[R("Periya Puranam, Cheraman Perumal Nayanar Puranam", "", "", MEMORY),
            R("Adi Ula (Tirumurai 11)", "", "Cheraman's poem", MEMORY)]),
 dict(slug="n-sundarar-gold", set="saints", title="Sundarar's gold from many shrines", ids=[947],
      en=r"thousand sovereigns|earn that gold", ta=r"பொன்",
      brief="Sundarar went to many Shaivite shrines to earn gold for Paravai, exhausted by the walking. Shiva supplied it.",
      refs=[R("Periya Puranam, Sundarar Puranam", "Tiruppukkoliyur / Tirumurugan Poondi episode", "", MEMORY)]),
 dict(slug="n-sundarar-crocodile", set="saints", title="Sundarar calls the crocodile to give back the boy", ids=[1320],
      en=r"crocodile", ta=r"முதலை",
      brief="At Avinashi a boy was swallowed by a crocodile. Years later Sundarar sang to Shiva and the crocodile spat out the boy alive, grown.",
      refs=[R("Periya Puranam, Sundarar Puranam; Tevaram 7 (Avinashi)", "pathigam not checked", "", MEMORY)]),
 dict(slug="n-manikkavasagar", set="saints", title="Manikkavasagar and the horses at Perunthurai", ids=[512],
      en=r"MANikkavAsagar|Manikkavasagar|Perunthurai|ThirupperunthuRai", ta=r"வாதவூர்|மாணிக்க|குதிரை|பெருந்துறை",
      brief="Sent by the Pandya king to buy horses, the minister Vathavurar met Shiva as a guru at Tiruperunthurai under the kurundam tree and gave the money to build the temple. The horses came later as foxes turned horses.",
      refs=[R("Tiruvasagam (Tirumurai 8); Tiruvilaiyadal Puranam", "", "", MEMORY),
            R("Shiva set", "shiva/stories/saints-kurundam.md", "the kurundam-tree meeting", "local", "")]),
 dict(slug="n-vandi-pittu", set="saints", title="Shiva carries earth for Vandi's pittu; beaten by the Pandya", ids=[756,960,1317],
      en=r"pittu|sand|Vandhi|loads", ta=r"பிட்டு|வந்தி|வைகை|மண்",
      brief=("When the Vaigai flooded, every household owed a share of the embankment. Old Vandi had no one, so Shiva came as a labourer, ate her pittu as wages, "
             "slept on the job, and was struck with a cane by the king: the blow was felt by every creature."),
      refs=[R("Tiruvilaiyadal Puranam (Paranjothi)", "Pittukku Man Sumantha padalam", "", MEMORY)]),
 dict(slug="n-kannappar", set="saints", title="Kannappar, the hunter devotee", ids=[510,664,1211],
      en=r"Kannappan|Kannappa|hunter \(Kan", ta=r"கண்ணப்ப|வேடன்|வேடுவ|எச்சில்|ஊன்",
      brief="The hunter Kannappar washed the Kalahasti lingam with water from his mouth, offered it tasted meat and, when its eye bled, gave his own eyes.",
      refs=[R("Periya Puranam, Kannappa Nayanar Puranam", "", "", MEMORY)]),
 dict(slug="n-nakkeerar", set="saints", title="Nakkeerar in the cave; Tirumurugatruppadai", ids=[92,104,431,650,681,726,1008,1192,1279],
      en=r"Nakkeerar", ta=r"நக்கீர|குகை|சிறை",
      brief=("The poet Nakkeerar was seized by a demon and shut in a cave at Thiruparankundram with a thousand other prisoners. He sang the Tirumurugatruppadai, "
             "Murugan opened the cave with his Vel and set them free. (The Pandya-court quarrel with Shiva over the fragrance of hair is a separate Tiruvilaiyadal story.)"),
      refs=[R("Tirumurugatruppadai (Tirumurai 11)", "", "the poem sung in the cave", SEARCH),
            R("Nakkeerar legend", "blogs and temple pages", "no padalam number found", SEARCH)]),

 # ------------------------------------------------------------------ DEVI
 dict(slug="d-himavan", set="devi", title="Parvati, daughter of Himavan", ids=[32,60,63,107,116,137,146,161,163,206,239,240,242,288,291,322,354,359,365],
      en=r"Himav|HimAlay", ta=r"இமய|இமவ|மலையரசன்|மலைமகள|பர்வத|மலைவளர்",
      brief="Parvati (Imayavalli, Umadevi) is the daughter of Himavan, the Mountain-King, born as a boon after his penance. The songs use this as the Devi's identity before saying she gave birth to Murugan.",
      refs=[R("Puranic and Tamil devotional tradition", "no single text pinned", "", MEMORY)]),
 dict(slug="d-kanchi", set="devi", title="Parvati's penance at Kanchi; the sand lingam", ids=[338,347,352,438],
      en=r"penance|Kachchi|KAnchi|KAnj|Kamakshi|KAmAkshi", ta=r"கச்சி|காஞ்சி|தவம்|காமாட்சி|கம்பை",
      brief=("Parvati made a sand lingam under the mango tree beside the Vegavati and worshipped it; when the river flooded she embraced the lingam to save it, and her bangles left "
             "their marks. Shiva then wedded her. The songs add the scar on his chest left by her breast."),
      refs=[R("Kanchi Puranam; Thirukkurippu Thondar Puranam", "named by a temple website", "text not found", SEARCH),
            R("Ekambareswarar legend", "temple pages", "", SEARCH)]),
 dict(slug="d-kamakshi-32", set="devi", title="Kamakshi's thirty-two acts of charity", ids=[291,322,438,540,894],
      en=r"thirty-two|32 |charitable acts|charitable", ta=r"முப்பத்திரண்டு|முப்பத்திரு|அறம்",
      brief="At Kanchi the Goddess is said to have performed thirty-two dharmas (aram) as acts of charity; the songs call her the one who did them.",
      refs=[R("Kanchi tradition", "source text not found", "", MEMORY)]),
 dict(slug="d-pathiri", set="devi", title="Penance at Thiruppathirippuliyur", ids=[745,1162],
      en=r"pAthiri|PAdalanagar|ThiruppAthirip", ta=r"பாதிரி|பாடலி|புலியூர்|தவம்",
      brief="The Goddess performed a penance under the pathiri tree at Thiruppathirippuliyur (Cuddalore) to be one with Shiva; the shrine marks the spot with a bare pedestal.",
      refs=[R("Sthala puranam of Thiruppathirippuliyur", "", "temple websites; also dice game and blindfolded Shiva versions", SEARCH)]),
 dict(slug="d-thiruvathigai", set="devi", title="Abirami at Thiruvathigai, where the cities burn", ids=[292],
      en=r"Abirami|Thiruvathikai|Thiruvathigai", ta=r"அபிராமி|அதிகை",
      brief="Song 292 places the Goddess Abirami at Thiruvathigai, where Shiva burnt the three cities with Meru as his bow and she stood by him.",
      refs=[R("Tevaram (Thiruvathigai pathigams)", "", "not opened", MEMORY)]),
 dict(slug="d-fisher", set="devi", title="Parvati as the fishermen's daughter", ids=[291,1165],
      en=r"fisher|shark", ta=r"வலை|மீனவ|சுறா|பரதவ|செம்படவ",
      brief="Parvati was born to the fisher folk of the coast; Shiva cast his net, caught the shark that was troubling them, and married the fisher-girl.",
      refs=[R("Tiruvilaiyadal Puranam (Paranjothi)", "the net-casting sport", "padalam not pinned", MEMORY)]),
 dict(slug="d-angayarkanni", set="devi", title="Angayarkanni (Meenakshi) at Madurai", ids=[708],
      en=r"Angayar", ta=r"அங்கயற்கண்ணி|மீனாட்சி",
      brief="Song 708 sets Shiva as Madurai's lord with his consort Angayarkanni (Meenakshi).",
      refs=[R("Tiruvilaiyadal Puranam", "Madurai sections", "not opened", MEMORY)]),
 dict(slug="d-kali-dance", set="devi", title="Kali challenges Shiva to a dance", ids=[94,117],
      en=r"challeng[^.]{0,80}(dance|SivA)|(dance|dances)[^.]{0,60}competition|in competition with SivA", ta=r"காளிநட|வாதாடு|காளிவாது",
      brief=("Kali, furious after killing demons, threatened Shiva's town of Thiruvalangadu. Shiva proposed a dance contest; when she matched every pose he lifted his foot "
             "to his ear (Urdhva Tandava), a pose she would not match, and she yielded."),
      refs=[R("Sthala puranam of Thiruvalangadu", "", "Appar's hymn is cited by temple sources; Later Chola Temples (Wisdomlib) quotes a purana", SEARCH)]),
 dict(slug="d-mahisha", set="devi", title="Durga slays Mahishasura", ids=[575,1126],
      en=r"Mahisha", ta=r"மகிட|மகிஷ|எருமை",
      brief="Durga killed the buffalo demon Mahishasura; the songs mention it in passing among the Goddess's deeds.",
      refs=[R("Devi Mahatmya, Madhyama Charitra", "ch. 2-4 (Markandeya Purana ~81-93; numbering varies by edition)", "chapter structure from web search; text not read", SEARCH)]),
 dict(slug="d-battlefield", set="devi", title="Durga and Bhadrakali dance on Murugan's battlefield", ids=[138,900,903,1079,1127],
      en=r"Durga|Bhadra KALi|KALi", ta=r"துர்க்கை|பத்ரகாளி|காளி|சண்டி",
      brief="When Murugan fought the demons, the Goddess's attendants and Bhadrakali danced on the field, shouting the 'kulavai' cry, as the army of fiends feasted.",
      refs=[R("Kanda Puranam, Yuddha Kandam", "battle scenes", "kandam unconfirmed", MEMORY)]),
 dict(slug="d-matangi", set="devi", title="Matangi, the sage's daughter", ids=[94],
      en=r"Mathanga|Matanga", ta=r"மாதங்கி|மதங்க",
      brief="Song 94 names the Goddess as the daughter of Sage Matanga (Matangi), one of the Shakta forms.",
      refs=[R("Shakta tradition", "", "", MEMORY)]),
 dict(slug="d-idumbai", set="devi", title="Durga of the Idumbai forest and the Pandavas", ids=[574],
      en=r"Durga|idumbai", ta=r"இடும்பை|துர்க்கை",
      brief="Song 574 mentions the forest of Idumbai where Goddess Durga dwelt, in the passage about the Pandavas' exile.",
      refs=[R("Mahabharata, Vana Parva", "", "not checked", MEMORY)]),

 # ------------------------------------------------------------------ MURUGAN (auto)
 dict(slug="m-mango-sura", set="murugan", review="All 73 matches name Surapadman and the mango tree together with a verb of disguise, hiding or splitting.", title="Surapadman as a mango tree split by the Vel", auto=True,
      en=r"(SUran|SUrapadman|Surapadman)[^.]{0,200}mango[- ]tree|mango[- ]tree[^.]{0,200}(SUran|Surapadman|split|felled|disguise)|(disguise|form) of (a |an )?(old )?mango", ta=r"மாமரம்|மாவாய்|மாவாகி|மாவடி|மாமுதல்",
      brief="In the last day of the war Surapadman took the form of a huge mango tree; Murugan's Vel split it in two, and the halves became the peacock and the cock.",
      refs=[R("Kanda Puranam, Yuddha Kandam", "Sura samharam", "kandam unconfirmed", SEARCH)]),
 dict(slug="m-krouncha", set="murugan", review="Commentary read for all 28 songs without a clear action verb beside the match: every one describes Murugan attacking the mountain. The 189 others have such a verb. Similes about the Krouncha bird are excluded by pattern.", title="The Krouncha mountain pierced", auto=True,
      en=r"Kroun?cha|Kraunch|KrouncA", excl=r"bird|anRil", ta=r"கிர[வௌெ]",
      brief="Murugan's Vel pierced the Krouncha mountain, the demon Tarakasura's hiding place and stronghold, which crumbled.",
      refs=[R("Kanda Puranam / Skanda Purana", "Taraka and Krouncha episode", "", SEARCH)]),
 dict(slug="m-sea-dried", set="murugan", review="All 48 checked: each has the sea or ocean drying, boiling or burning beside the match.", title="The sea dried by the Vel", auto=True,
      en=r"(sea|ocean)[^.]{0,60}(dried|dry up|boil)|dried up the (sea|ocean)|(seven|seas)[^.]{0,40}dried", ta=r"கடல்வற்ற|வற்றிட|வற்றக்|வற்றி|வறள|அலைகடல்",
      brief="Surapadman fled into the sea; Murugan's Vel made the ocean dry up or boil, driving him out.",
      refs=[R("Kanda Puranam, Yuddha Kandam", "", "", SEARCH)]),
 dict(slug="m-peacock-cock", set="murugan", title="The peacock and the cock", ids=[323,732,945], review="Eleven songs matched automatically; all read. Only these three say the split body became the peacock and the cock; the other eight only say something was split.",
      en=r"(split|halves|two (parts|pieces))[^.]{0,120}(peacock|cock)|(peacock|cock)[^.]{0,120}(split|halves|two (parts|pieces))|(SUran|Surapadman|SUrapadman)[^.]{0,80}(became|turned into|transformed into|changed into)[^.]{0,40}(peacock|cock)", ta=r"சேவல்|மயில்",
      brief="The two halves of the split Surapadman became Murugan's vehicle, the peacock, and the cock on his flag.",
      refs=[R("Kanda Puranam, Yuddha Kandam", "", "", SEARCH)]),
 dict(slug="m-tarakasura", set="murugan", review="All 15 read: each says Tarakasura was killed or dismembered.", title="Tarakasura", auto=True,
      en=r"Tharaka|Taraka", ta=r"தாரக",
      brief="Tarakasura, Surapadman's brother, was killed by Murugan before the final battle (Asura Kandam).",
      refs=[R("Kanda Puranam, Asura Kandam", "", "", SEARCH)]),
 dict(slug="m-jayanta", set="murugan", title="Jayanta, Indra's son, freed from Sura's prison", ids=[582],
      en=r"Jayanth", ta=r"சயந்த",
      brief="Indra's son Jayanta fled Surapadman's persecution and was freed from prison by Murugan, who restored the heavens to Indra.",
      refs=[R("Kanda Puranam, Mahendra Kandam / Yuddha Kandam", "", "kandam unconfirmed", SEARCH)]),
 dict(slug="m-brahma-prison", set="murugan", review="All 22 read. Kept only songs saying Murugan imprisoned Brahma.", drop={279: "Surapadman's prison, not Murugan's", 309: "Daksha's sacrifice and Saraswati", 380: "Brahma jailed by Sura, freed by Murugan", 544: "the Pranava lesson only (see shiva/murugan-pranava)", 1036: "imprisoned by the mountain Krouncha, not by Murugan", 1155: "released from Sura's prison", 1236: "celestials freed from the demons"}, title="Brahma imprisoned for failing the Pranava", auto=True,
      en=r"BrahmA[^.]{0,60}(imprison|prison|jail|confin)|imprison[^.]{0,40}BrahmA|BrahmA[^.]{0,40}(ashamed|failed to explain)", excl=r"celestials were once imprisoned|DEvAs were imprisoned", ta=r"சிறை",
      brief="When Brahma could not explain the meaning of Om to Murugan, the boy tapped his head and locked him in prison; Shiva then asked for his release. Related to the Shiva-set story murugan-pranava.",
      refs=[R("Kanda Puranam / Skanda Purana", "Brahma's imprisonment", "", SEARCH),
            R("Shiva set", "shiva/stories/murugan-pranava.md", "Murugan teaches Shiva the Pranava", "local", "")]),
 dict(slug="m-agastya", set="murugan", title="Murugan teaches Agastya", ids=[598,627,878,915,954,1081,1152],
      en=r"Agasth", ta=r"அகத்திய|அகத்தி",
      brief="Murugan is said to have taught Agastya the secret of the sage's own wisdom and to have given Tamil to him.",
      refs=[R("Skanda Purana; Tamil tradition", "", "", MEMORY)]),
 dict(slug="m-saravana", set="murugan", review="All 22 read.", drop={959: "the month of Karthigai, unrelated"}, title="Born in the Saravana lake; the six Krittikas", auto=True,
      en=r"KAr(th|tth)igai|KArthikai|Karthigai|Karththigai|Krithika|Sa?ravaNa (lake|Lake|pond|Pond|Poigai|poigai)|Saravana (lake|Lake|pond|Pond|Poigai|poigai)",
      ta=r"சரவண|கார்த்திகை|பொய்கை",
      brief="Six sparks from Shiva's eye were carried by Agni and Ganga into the Saravana lake, became six babies, and were nursed by the six Krittika women; Parvati joined them into one child with six faces. Related to the Shiva-set story murugan-skanda-birth.",
      refs=[R("Kanda Puranam, Utpatti Kandam", "", "", SEARCH),
            R("Shiva set", "shiva/stories/murugan-skanda-birth.md", "", "local", "")]),
 dict(slug="m-valli-disguise", set="murugan", review="All 25 name the old man, the sage, the neem or the Vengai tree beside Valli.", title="Murugan woos Valli in disguise", auto=True,
      en=r"(old man|aged man|elderly man|old hunter)[^.]{0,200}VaLLi|VaLLi[^.]{0,200}(old man|aged man|elderly man|old hunter)|(Vengai|vEngai|kino tree|neem tree)[^.]{0,200}(VaLLi|disguise)|disguise[^.]{0,120}(Vengai|vEngai|kino|neem)", ta=r"கிழவ|வேடன்|வேங்கை|வேடு|கிழ",
      brief="Murugan came to Valli, the hunter's daughter, in the millet field as a hunter, an old man and a Vengai tree, and won her.",
      refs=[R("Kanda Puranam, Valli Thirumanam", "kandam not confirmed", "", SEARCH)]),
 dict(slug="m-deivayanai", set="murugan", review="All 42 read: each names Deivayanai as Murugan's wife, embraced by him, or Indra's daughter given to him. About half are consort-epithet mentions rather than a marriage narrative.", title="Murugan and Deivayanai, Indra's daughter", auto=True,
      en=r"(marri|wed|matrimony|nuptial|wedding)[^.]{0,120}(DEvayAnai|DevayAnai|DEvAnai|Deivayanai)|(DEvayAnai|DevayAnai|DEvAnai|Deivayanai)[^.]{0,120}(marri|wed |wedded|matrimony|nuptial)",
      ta=r"தெய்வயானை|தெய்வானை|தேவசேனை|தேவகுஞ்சரி|இந்திரன்மகள|சுரபதிமகள",
      brief="After the war Indra gave his daughter Deivayanai (Devasena), raised by Airavata, to Murugan; the wedding is at Thiruparankundram. Many songs only name her as his consort beside Valli, so this list is partly epithet-level.",
      refs=[R("Kanda Puranam, Deva Kandam (per general accounts)", "", "", SEARCH)]),
 dict(slug="m-airavata", set="murugan", review="Songs that only say Indra rides Airavata were removed; kept are those that name Deivayanai as reared by the elephant.", drop={x: "Indra's mount, not Deivayanai" for x in (81, 191, 213, 877, 900, 947, 1086, 1102, 1150, 1173)}, title="Airavata raises Deivayanai", auto=True,
      en=r"AirAvat|Airavat", ta=r"ஐராவத|வெள்ளையானை",
      brief="Deivayanai was brought up by Indra's white elephant Airavata, which is why songs call Murugan the son-in-law of Indra and Airavata's ward.",
      refs=[R("Kanda Puranam", "", "", SEARCH)]),
 dict(slug="g-valli-elephant", set="ganesha", title="Ganesha as an elephant frightens Valli", ids=[24,146,446,715],
      en=r"tusked elephant|elephant", ta=r"யானை|ஆனை|கரி|களிறு|கணபதி|கஜ",
      brief="To make Valli run into Murugan's arms, Murugan asked his brother Ganesha to appear as a wild elephant; Valli clung to Murugan in fear.",
      refs=[R("Kanda Puranam, Valli Thirumanam", "", "", SEARCH)]),
 dict(slug="g-race", set="ganesha", title="The race around the world; the fruit", ids=[30,532],
      en=r"flew around|circular orbit|went around|fruit|competition|circled", ta=r"கனி|பழம்|உலகை|வலம்|வலமாய்",
      brief="Narada's fruit of wisdom was to go to the son who circled the world first; Murugan flew round on his peacock, Ganesha went round his parents, and Murugan left for Pazhani in anger.",
      refs=[R("Skanda Purana / Tamil tradition", "", "", MEMORY)]),
 dict(slug="g-scribe", set="ganesha", title="Ganesha writes the Mahabharata with his broken tusk", ids=[88,1016,1315],
      en=r"scrib|wrote the MahAbhAratham|BhAratham", ta=r"பாரத|மேரு|மருப்பு|கொம்பு|தந்த",
      brief="Vyasa dictated the Mahabharata and Ganesha wrote it down on Mount Meru, breaking off his own tusk for a pen when the first one failed.",
      refs=[R("Mahabharata, Adi Parva frame story (not in the Critical Edition text)", "", "tradition", MEMORY)]),
 dict(slug="t-sangam", set="tamil-lore", title="Murugan as Rudrasarman at the Madurai Sangam", ids=[126,451,568,987,992],
      en=r"Rudra|Sangam Poet|plank of (Tamil )?Sangam|forty-nine|Sangam poets", ta=r"சங்கப்பலகை|சங்கம்|உருத்திர|ருத்ர|அகப்பொருள்",
      brief=("When the Sangam poets of Madurai could not agree on the meaning of Shiva's Iraiyanar Akapporul, the mute boy Rudrasarman, born in a merchant family, "
             "was brought; he sat on the Sangam plank and the 49 poets' dispute was settled. The songs say Murugan was that boy."),
      refs=[R("Tiruvilaiyadal Puranam (Paranjothi)", "Sangam sports", "padalam not pinned", MEMORY),
            R("Iraiyanar Akapporul commentary (Nakkeerar)", "", "tradition", MEMORY)]),
 dict(slug="t-agastya", set="tamil-lore", title="Agastya of Pothigai and Tamil", ids=[180,619,915,954,1081,1299],
      en=r"Agasth[^.]{0,80}Tamil|Tamil[^.]{0,80}Agasth|Pothigai|Pothikai", ta=r"அகத்திய|அகத்தி|பொதிய",
      brief="The sage Agastya of Mount Pothigai, who gave Tamil its grammar, worshipped Murugan in Tamil and was taught the essence of Tamil knowledge by him. Also in `murugan/m-agastya`.",
      refs=[R("Tamil tradition", "", "", MEMORY)]),
 dict(slug="t-patrons", set="tamil-lore", title="Pari, Kari and the model donors", ids=[169,175,306,436,935],
      en=r"PAri|KAri|twenty-one|celebrated philanthropists", ta=r"பாரி|காரி|வள்ளல்",
      brief="The poet says he wasted his verse comparing miserly patrons with Pari, Kari and the other great donors of the Sangam age. The names are used as models of generosity.",
      refs=[R("Sangam poems (Purananuru)", "Pari, Kari and the seven last great donors", "", MEMORY)]),
 dict(slug="t-classics", set="tamil-lore", title="The Tamil classics named in the songs", ids=[60,76,104,171],
      en=r"Sangam|[Tt]hirukkural|ThirukkuRaL|ThiruvaLLuvar", ta=r"குறள்|திருக்குறள்|சங்கம்|முத்தமிழ்",
      brief="Songs where the poet lists the Tamil classics (Tirukkural, Sangam literature) that false scholars claim to know. A reference list, not a story.",
      refs=[R("Tirukkural; Sangam literature", "", "", MEMORY)]),
 dict(slug="t-spider-elephant", set="tamil-lore", title="The spider and the elephant at Thiruvanaikka", ids=[358],
      en=r"spider", ta=r"சிலந்தி|நூல்|ஆனை|யானை",
      brief="Two Shiva attendants, cursed to be an elephant and a spider, worshipped the lingam at Thiruvanaikka; they fought and died, and the spider was reborn as the Chola king Kochchengat.",
      refs=[R("Thiruvanaikka sthala puranam", "", "temple pages; Kochengat Chola is also a Nayanar in the Periya Puranam", SEARCH)]),
]

# ---------------------------------------------------------------- exact Periya Puranam verses (2026-11-10)
# The thevaaram.org page of the Sambandar Puranam was downloaded and every verse parsed (1256 verses, running numbers 1-1256,
# the same scheme as shiva/stories/saints-sambandar.md). The text is cached in scripts/.cache/pp_sambandar.json (git-ignored).
PPV = "machine-read from the opened page (running verse numbers); the checks below are re-run on every build"
PP = lambda ref, note="": R("Periya Puranam, Sambandar Puranam (Tirumurai 12)", ref, note, PPV, PP_SAM)

# (verse, Tamil text that must occur in it with spaces removed, what it shows)
VERSE_CHECKS = [
    (68, "உமையம்மை", "Uma feeds the child (golden bowl, v.68)"), (76, "தோடுடைய", "first hymn Todudaiya Seviyan"),
    (131, "திருநீலகண்டத்துப்பெரும்பாணர்", "Neelakanta Yazhpanar introduced"), (278, "யாழ்ப்பெரும்பாணனார்", "yazh and the golden cymbal passage"),
    (450, "யாழினால்", "the lyre cannot hold the hymn"), (195, "சிவிகை", "pearl palanquin given"),
    (418, "திருவாவடுதுறை", "Tiruvavaduthurai"), (426, "கிழி", "purse of gold (v.426-428)"), (472, "திருமருகல்", "Thirumarugal"),
    (569, "காசு", "famine coins (v.564-571)"), (582, "கதவு", "the temple doors at Maraikkadu"), (609, "திருமறைக்காடு", "Maraikkadu"),
    (645, "மங்கையர்க்கரசி", "Queen Mangaiyarkkarasi"), (719, "வெப்பு", "the king's fever"), (772, "வெப்பெலாம்", "the fever cured"),
    (788, "தீ", "the fire test"), (807, "வைகை", "the river test"), (846, "திருக்கையால்", "Sambandar's leaf in the river"),
    (847, "கூன்", "the hunchback straightened"), (850, "ஏடகம்", "the leaf halts at Edagam"), (856, "கழு", "the Jains on the stakes"),
    (857, "நீறு", "the king takes the ash"), (898, "கொள்ளம்பூதூர்", "the Kollampudur boat (no song)"), (1033, "திருமயிலாபுரி", "Mylapore opens (Sivanesar)"),
    (1058, "பணம்விரித்து", "the snake that bit Poompavai (hood spread)"), (1088, "மட்டிட்ட", "names the Poompavai hymn 'Mattitta'"), (1119, "திருமயிலை", "Mylapore"), (1245, "பெருமணம்", "Perumanam (no song)"),
]

REF_OVERRIDES = {
    "sam-avatar": [R("Tevaram (Tirumurai 1-3)", "Sambandar's hymns", "the 'Tamil Veda' the songs mean", OPENED_EARLIER, TEV111),
                   PP("whole puranam, 1256 verses")],
    "sam-birth": [PP("vv. 1-26", "the town, the parents, the birth")],
    "sam-milk": [PP("vv. 59-69", "v.68 checked: Uma gives the milk in a bowl"), R("Tevaram 1.1.1", "Todudaiya Seviyan", "sung right after", OPENED_EARLIER, TEV111)],
    "sam-todudaiya": [PP("vv. 70-76", "v.76 checked"), R("Tevaram 1.1.1", "Todudaiya Seviyan", "", OPENED_EARLIER, TEV111)],
    "sam-yazhpanar": [PP("vv. 131-141 (meeting), 278-281 (the cymbal), 448-452 (the lyre breaks)", "131, 278 and 450 checked")],
    "sam-palanquin": [PP("vv. 195-212", "v.195 checked")],
    "sam-three-saints": [PP("vv. 274 (Appar visits), 576-592 (the doors; 582 and 587 checked), 597-609 (Maraikkadu)")],
    "sam-poompavai": [PP("vv. 1033-1120", "Sivanesar's story from 1033; the snake-bite 1055-1058; the miracle at the Kapaliccharam around 1084-1100; v.1088 names the hymn"),
                      R("Tevaram 2.47 (Thirumayilai)", "Mattitta Punnai", "the Poompavai pathigam; its page was opened", OPENED, TEV % (2, 2047, 47))],
    "sam-fever": [PP("vv. 599-772", "summons 603-613; Madurai 645-668; the fire on the matham 678-704; the fever 705-772 (719, 772 checked)"),
                  R("Tevaram 2.66.1", "Mantiramavathu Neeru", "the ash hymn", OPENED_EARLIER, TEV266),
                  R("Tevaram 3.39.1", "Maninernvizhi", "sung to the queen", OPENED_EARLIER, TEV339),
                  R("Tiruvilaiyadal Puranam", "padalam 62", "", OPENED_EARLIER, TVP62)],
    "sam-ordeals": [PP("vv. 773-798 (fire test; 788 checked), 799-852 (river test; 807, 846 and 850 checked)"),
                    R("Tevaram 3.54.1", "Vazhga Andhanar", "river test", OPENED_EARLIER, TEV354),
                    R("Tevaram 3.32.1", "Tiruvedagam", "the leaf halts", OPENED_EARLIER, TEV332),
                    R("Tiruvilaiyadal Puranam", "padalam 63", "", OPENED_EARLIER, TVP63)],
    "sam-jains": [PP("vv. 853-856 (856 checked), then the king takes the ash 857-858"),
                  R("Shiva set", "shiva/stories/saints-sambandar.md", "the 20 songs already collected", "local", "")],
}
for _st in CATALOGUE:
    if _st["slug"] in REF_OVERRIDES:
        _st["refs"] = REF_OVERRIDES[_st["slug"]]
# ---- the other sets: exact locations in the texts opened on 2026-11-10 -------------------------------------------------
KP_URL = "https://ta.wikisource.org/wiki/%E0%AE%95%E0%AE%A8%E0%AF%8D%E0%AE%A4_%E0%AE%AA%E0%AF%81%E0%AE%B0%E0%AE%BE%E0%AE%A3%E0%AE%AE%E0%AF%8D"
PPS = "machine-read from the opened page; re-checked on every build"
def PPX(pid, title, ref, note=""):
    return R(f"Periya Puranam, {title} (Tirumurai 12)", ref, note, PPS, f"https://thevaaram.org/thirumurai_1/onepage.php?thiru=12&Song_idField={pid}")
def TVPR(n, name, ref="", note=""):
    return R(f"Tiruvilaiyadal Puranam (Paranjothi), padalam {n} {name}", ref or "whole padalam", note, "machine-read from Tamil Wikisource; re-checked on every build", TVP62[:-2] + f"{n:02d}")
def KPR(ref, note=""):
    return R("Kanda Puranam (Kachiyappar), Utpatti Kandam", ref, note, "machine-read from Tamil Wikisource (first kandam and the start of the second only)", KP_URL)
PM_URL = "https://projectmadurai.org/pm_etexts/utf8/"
PMS = "machine-read from Project Madurai (Unicode text); re-checked on every build"
def KPM(kandam, f, ref, note=""):
    return R(f"Kanda Puranam (Kachiyappar), {kandam} (Project Madurai text)", ref, note, PMS, PM_URL + f + ".html")
NOT_IN = lambda src, why: R(src, "not located", why, "searched, not found", "")

CHECKS = {"sambandar": [("pp", f"12280:{v}", t, lab) for v, t, lab in VERSE_CHECKS]}
CHECKS["saints"] = [
    ("pp", "12000:189", "ஓலைகாட்டென்று", "the old man demands the bond (wedding dispute)"), ("pp", "12000:220", "பித்தா", "Sundarar's 'Pitha' hymn at Thiruvennainallur"),
    ("pp", "12290:8", "தூதுவிட்ட", "Shiva sent as messenger"), ("pp", "12290:337", "தூதர்", "the messenger at Paravai's house"),
    ("pp", "12290:10", "குண்டையூர்", "Kundaiyur"), ("pp", "12290:11", "செந்நெல்", "the paddy"),
    ("pp", "12370:166", "வேடர்வடிவாய்", "Shiva's hosts as hunters take Sundarar's gold (Poondi)"), ("pp", "12370:173", "ஆரூரர்தமை", "Cheraman misses Sundarar"),
    ("pp", "12100:173", "அம்பால்", "Kannappar's arrow and his eye"), ("pp", "12100:175", "அப்பிய", "the eye placed on the lingam"),
    ("tvp", "52", "தருமி", "Dharumi (Nakkeerar's quarrel)"), ("tvp", "53", "கீரன்", "Keeran rescued from the tank"), ("tvp", "54", "கீரன்", "Keeran taught"),
    ("tvp", "58", "வாதவூர்", "Manikkavasagar"), ("tvp", "59", "குதிரை", "foxes turned into horses"), ("tvp", "60", "நரி", "horses turned back into foxes"),
    ("tvp", "61", "வந்தி", "Vandi"), ("tvp", "61", "பிட்டு", "the pittu"),
]
CHECKS["devi"] = [("tvp", "3", "திருநகரம்", "Madurai founded"), ("tvp", "4", "தடாதகை", "Tatatakai (Meenakshi)"), ("tvp", "57", "வலை", "Shiva casts the net"), ("tvp", "57", "சுறா", "the shark")]
CHECKS["murugan"] = [
    ("kp", "1032", "சரவண", "Saravana"), ("kp", "1048", "பொய்கை", "the lake"), ("kp", "1219", "சிறை", "Brahma jailed"), ("kp", "1223", "சிறை", "Brahma in prison"),
    ("kp", "1329", "கிரவுஞ்ச", "Krouncha"), ("kp", "1332", "தாரக", "Tarakan"), ("kp", "1275", "தெய்வயானை", "Deivayanai named"), ("kp", "1277", "வள்ளி", "Valli named"),
    ("tvp", "13", "வேல்", "the Vel dries the sea (Ugrakumara Pandyan)"), ("tvp", "13", "கடல்", "the sea"),
]
CHECKS["tamil-lore"] = [
    ("tvp", "51", "சங்கப்பலகை", "the Sangam plank"), ("tvp", "55", "உருத்திரசன்மன்", "Rudrasarman"), ("tvp", "52", "தருமி", "Dharumi"),
    ("pp", "12680:3", "திருவானைக்கா", "Thiruvanaikka named"), ("pp", "12680:4", "சிலம்பிவலை", "the spider's web"), ("pp", "12680:12", "கோச்செங்கட்சோழர்", "Kochchengat Chola"),
]

CHECKS["sambandar"] += [
    ("pp", "12280:14", "பன்னிரண்டுதிருப்பெயர்", "Sirkazhi's twelve names"), ("pp", "12280:59", "கரையில்வைத்து", "the child left on the bank"),
    ("pp", "12280:131", "மதங்கசூளாமணியார்", "Yazhpanar's wife Matanga Chulamani"), ("pp", "12280:450", "யாழினால்", "the yazh: Yazhpanar about to destroy it"),
    ("pp", "12280:764", "நீறே", "holy ash is the cure"), ("pp", "12280:765", "தடவ", "Sambandar rubs the ash"), ("pp", "12280:763", "பீலி", "the Jains' peacock feathers on the left side"),
    ("pp", "12280:847", "கூன்நிமிர்ந்த", "the hunchback straightens at the river test"), ("pp", "12280:786", "பச்சை", "the leaf stays green in the fire"),
    ("pp", "12280:1053", "பூம்பாவை", "Poompavai betrothed to Sambandar"), ("pp", "12280:1058", "பணம்", "the snake that bit her"),
]
CHECKS["saints"] += [
    ("pp", "12290:314", "சங்கிலியார்", "Sundarar marries Sangili at Tiruvorriyur"), ("pp", "12290:319", "புலவிக்கடல", "Paravai's sulking"), ("pp", "12290:338", "திறவாய்", "Shiva at Paravai's door: 'open'"),
    ("pp", "12290:25", "குறட்பூதப்படை", "dwarf attendants carry the paddy to Paravai's house"), ("pp", "12000:187", "பித்தனுமாக", "Sundarar calls the old man a madman"),
    ("pp", "12000:190", "ஆவணம்பறிக்க", "Sundarar takes (tears) the bond"), ("pp", "12000:216", "வன்றொண்டன்", "named Vanthondan"),
    ("pp", "12100:118", "வாயினில்", "Kannappar tastes the meat in his mouth"), ("pp", "12100:121", "வாயினிற்கொண்டு", "water carried in the mouth"),
    ("tvp", "57", "நந்தி", "Nandi born a shark"), ("tvp", "57", "புன்னை", "the baby found under the punnai tree"),
]
CHECKS["devi"] += [("kcp", "4", "ஒருமாவிற்பெருமானை", "the Lord of the one mango tree"), ("kcp", "4", "கம்பை", "the river Kampa interrupts Parvati's worship"), ("kcp", "6", "முலைச்சுவடு", "the mark of the breasts"), ("kcp", "5", "காமக்கோட்டத்துமை", "Kamakshi named"), ("tvp", "57", "நந்தி", "Nandi the shark"), ("tvp", "57", "புன்னை", "the baby under the punnai tree"), ("tvp", "57", "மீனாட்சி", "the fisher-girl is Meenakshi")]
CHECKS["murugan"] += [
    ("kp", "1331", "குறுமுனிசூளின்", "Krouncha cursed into a mountain by Agastya"), ("kp", "1336", "தாரகன்", "Tarakan beside the mountain"), ("kp", "1515", "தாரக", "the Vel kills Tarakan and the mountain"),
    ("kp", "1213", "குடிலை", "Brahma gives only the letter-form of Om"), ("kp", "1220", "படைப்பது", "Murugan takes over creation"),
    ("kp", "917", "கங்கையில்", "the sparks are sent to the Ganga"), ("kp", "966", "ஆரலாகும்மாதர்", "the six Krittika women"), ("kp", "1034", "ராறுபன்னிருபுய", "six faces and twelve arms"),
]
CHECKS["tamil-lore"] += [
    ("tvp", "55", "தனபதி", "the merchant Dhanapati"), ("tvp", "55", "கபிலர்", "Kapilar ranked highest"), ("pp", "12680:5", "துதிக்கையினில்புக்கு", "the spider bites the elephant's trunk"),
    ("pp", "12680:8", "கமலவதி", "Kamalavati"), ("pp", "12680:10", "கோச்செங்கண்ணானோ", "the red-eyed child"),
]

CHECKS["murugan"] += [
    ("kpy", "2864", "தொடுகடல்நடுவண்", "Sura goes into the middle of the sea"), ("kpy", "2865", "சூதமாய்", "he stands as a mango tree"),
    ("kpy", "2867", "பராரைமாவுருவமாகி", "a huge mango form"), ("kpy", "2886", "மாவுருச்சாய்தலோடும்", "the mango form falls"),
    ("kpy", "2887", "கூறாக்கி", "the body is split in two"), ("kpy", "2889", "சேவலும்மயிலுமாகி", "the two halves become a cock and a peacock"),
    ("kpy", "2894", "கொடியேஆகி", "the cock is told to become the banner"), ("kpy", "2896", "மஞ்ஞையேறி", "Murugan mounts the peacock"),
    ("kpy", "2775", "மயிலாய்த்தோன்றி", "Indra appears as a peacock"), ("kpy", "2779", "மகவான்தன்மேல்", "Murugan mounts Indra the peacock"),
    ("kpy", "2776", "வறந்திடப்", "the peacock's wings dry the sea"), ("kpy", "2592", "வறந்துளது", "the sea dried in the duel"), ("kpy", "2883", "பௌவம்", "the Vel's fire spreads over the seas"),
    ("kpm", "337", "சயந்தன்", "Jayantan in prison with the devas"), ("kpy", "2936", "சயந்தன்", "Murugan orders Jayantan freed"), ("kpy", "2938", "சிறைக்களத்துச்சென்றனனே", "Veerabahu goes to the prison"),
    ("kpd", "36", "வேந்தியல்முறை", "Indra's rule restored"), ("kp", "1276", "அயிராவதம்", "Airavata tends Deivayanai"),
    ("kpd", "46", "திருப்பரங்குன்றிடை", "Deivayanai arrives at Thiruparankundram"), ("kpd", "86", "பரங்குன்றில்வைகினான்", "Murugan stays at Thiruparankundram"), ("kpd", "87", "தெய்வயானை", "Indra gives Deivayanai"),
]

REF2 = {
    "n-sundarar-wedding": [PPX("12000", "Sundarar: Thadutatkonda Puranam (Thirumalai Sargam)", "vv. ~189-230; 189 and 220 checked", "the old man demands to see the bond; Sundarar scorns him")],
    "n-sundarar-messenger": [PPX("12290", "Eyarkon Kalikkama Nayanar Puranam", "v. 8 (Shiva sent as messenger), v. 337 (at Paravai's house); both checked")],
    "n-sundarar-paddy": [PPX("12290", "Eyarkon Kalikkama Nayanar Puranam", "vv. 10-27 (Kundaiyur and the paddy); 10 and 11 checked")],
    "n-cheraman-kailasa": [PPX("12370", "Kazharitrarivar (Cheraman Perumal) Nayanar Puranam", "vv. 112-118 (the friendship), 173-175 (Cheraman misses Sundarar; 173 checked)", "the Kailasa ascent itself was not located in the downloaded sections"),
                           R("Adi Ula (Tirumurai 11)", "", "Cheraman's poem on the Kailasa journey", MEMORY)],
    "n-sundarar-gold": [PPX("12370", "Kazharitrarivar Nayanar Puranam", "vv. 164-172 (Tirumurugan Poondi: Shiva's hosts as hunters take Sundarar's gold; 166 checked)", "song 947 speaks of earning gold for Paravai at many shrines; that reading is not confirmed in the Puranam")],
    "n-sundarar-crocodile": [NOT_IN("Periya Puranam (all sections 12000-12700 downloaded)", "the word 'crocodile' (முதலை) occurs only in unrelated verses; the Avinashi story is tradition and the Tevaram 7 hymn, not the Puranam")],
    "n-manikkavasagar": [TVPR(58, "Thiruvathavur Adigalukku Upadesitha", "", "Manikkavasagar named (58 checked)"), R("Tiruvasagam (Tirumurai 8)", "", "not opened", MEMORY)],
    "n-vandi-pittu": [TVPR(61, "Man Sumantha", "", "Vandi and the pittu (61 checked)"), TVPR(59, "Nari Pariyakkiya"), TVPR(60, "Pari Nariyakiya")],
    "n-kannappar": [PPX("12100", "Kannappa Nayanar Puranam", "vv. 173-176 (the eye offering; 173 and 175 checked)")],
    "n-nakkeerar": [TVPR(52, "Tarumikkup Porkizhi Aliththa", "", "Dharumi and Nakkeerar's quarrel with Shiva (52 checked)"), TVPR(53, "Keeranaik Karai Etriya", "", "Nakkeerar saved from the tank"), TVPR(54, "Keeranukku Upadesiththa"),
                    NOT_IN("Tiruvilaiyadal Puranam padalams 52-54", "the cave captivity and Tirumurugatruppadai are not in these padalams; that story is tradition"),
                    R("Tirumurugatruppadai (Tirumurai 11)", "", "", MEMORY)],
    "d-fisher": [TVPR(57, "Valai Veesina", "", "Shiva casts the net; the shark (57 checked)")],
    "d-angayarkanni": [TVPR(3, "Thirunagaram Kanda", "", "Madurai founded"), TVPR(4, "Tatatakai Pirati Thiruavatara", "", "Meenakshi's birth (4 checked)"), TVPR(5, "Thirumana", "", "the wedding")],
    "m-saravana": [KPR("padalam 13 Saravana Padalam, vv. 1015-1051 (1032 and 1048 checked)"), R("Shiva set", "shiva/stories/murugan-skanda-birth.md", "", "local", "")],
    "m-brahma-prison": [KPR("padalam 16 Ayanaich Chiraipuri, vv. 1205-1223 (1219, 1223 checked); padalam 17 Ayanaich Chirai Neekku, vv. 1224-1265"), R("Shiva set", "shiva/stories/murugan-pranava.md", "Murugan teaches Shiva the Pranava", "local", "")],
    "m-tarakasura": [KPR("padalam 20 Tarakan Varaip Padalam, vv. 1329-1531 (1332 checked)")],
    "m-krouncha": [KPR("the mountain is introduced in the Tarakan padalam, vv. 1329-1331 (1329 checked)", "the great battle is in the Yuddha Kandam, which is not on Wikisource")],
    "m-deivayanai": [KPR("v. 1276 Airavata tends Deivayanai as the Milk Ocean tended Lakshmi; vv. 1275-1277 name her and Valli as Murugan's future wives (1275 and 1276 checked)"),
                     KPM("Deva Kandam", "pmuni0304", "padalam 2 Deivayanai Ammai Tirumana Padalam, vv. 36-303; vv. 42-46 (Indra sends Deivayanai from Meru on Airavata to Thiruparankundram), 86-88 (Murugan at Thiruparankundram, Indra gives Deivayanai, the wedding is announced), 132 (Murugan reaches Thiruparankundram for the wedding)", "the wedding place is stated in the text: Thiruparankundram")],
    "m-valli-disguise": [KPR("v. 1277 names Valli (checked)", "the wooing is in a later kandam, not on Wikisource")],
    "m-sea-dried": [KPM("Yuddha Kandam", "pmuni0293_03", "padalam 13 Surapadman Vadhai, vv. 2864 (Sura goes into the middle of the sea), 2882-2883 (the Vel's fire spreads over the seas), 2776 (the peacock's wings dry the sea), 2592 (the sea dries in the duel)", "the Puranam does not say the Vel dried the sea to drive Sura out; that is the songs' telling. Sura stands in the sea as the mango tree"),
                    TVPR(13, "Kadal Suvara Vel Vitta", "", "a separate sport in which the Pandya prince Ugrakumara dries the sea with the Vel Shiva gives him (13 checked)")],
    "m-mango-sura": [KPM("Yuddha Kandam", "pmuni0293_03", "padalam 13 Surapadman Vadhai, vv. 2864-2868 (Sura goes into the sea and becomes a mango tree 1,100 yojanas tall), 2884-2886 (the Vel strikes and the tree falls), 2887 (Sura takes his own form again; the Vel splits him in two)", "the Puranam has the Vel fell the tree and then split Sura's body; the songs fold both into 'split the mango tree'")],
    "m-peacock-cock": [KPM("Yuddha Kandam", "pmuni0293_03", "padalam 13 Surapadman Vadhai, vv. 2889-2895 (the two halves rise as a cock and a peacock and attack; Murugan's look cleanses Sura; the cock becomes his banner), 2896-2900 (Murugan mounts the peacock)", "earlier in the same padalam Indra himself becomes a peacock and carries Murugan (vv. 2775-2780); the permanent vehicle and banner come from Sura's two halves"),
                       ],
    "m-jayanta": [KPM("Mahendra Kandam", "pmuni0286_01", "padalam 9 Jayantan Pulambu Padalam, v. 337 (Jayantan in prison with the devas); padalam 11, v. 450 (Veerabahu reaches the prison)"),
                  KPM("Yuddha Kandam", "pmuni0293_03", "padalam 16 Meetchip Padalam, vv. 2935-2943 (Murugan orders Veerabahu to bring Jayantan and the devas back from prison; Veerabahu goes and frees them)"),
                  KPM("Deva Kandam", "pmuni0304", "v. 36 (Indra rules the golden city again), v. 42 (Sura dead, the devas freed from prison)")],
    "d-mahisha": [R("Devi Mahatmya, Madhyama Charitra", "ch. 2 (Mahishasura's armies), ch. 3 (Mahishasura slain), ch. 4 (hymn of the gods)", "Markandeya Purana chapters 81-93 in the Banerjee edition, 78-90 in the Venkatesh Press edition; chapter titles taken from two printed-edition descriptions found by search, the Sanskrit text was not fetched", SEARCH)],
    "d-kamakshi-32": [NOT_IN("Kanchi Puranam of Sivagnana Munivar, parts 1-3 (vv. 1-1691), searched on Project Madurai", "the words for 'thirty-two' (முப்பத்திரண்டு and spelling variants) do not occur in the three parts; Kamakshi is named only in invocation v. 5. Earlier searches also found no source; the tradition rests on the songs' commentary")],
    "d-kali-dance": [R("Thiruvalangadu sthala puranam", "", "the dance contest and the raised foot are told on every temple page; accounts differ (17 poses; an earring or an anklet gem; left or right leg)", SEARCH),
                     R("Mootha Tirupathigam (Karaikkal Ammaiyar, Tirumurai 11)", "", "named by one source as the hymn of Tiruvalangadu; an Appar hymn on the contest is claimed but no hymn number was found", SEARCH)],
    "d-kanchi": [R("Ekambareswarar temple legend (Kanchi)", "", "sand lingam under the mango tree, the flooding Vegavati, bangle marks; several temple websites agree", SEARCH),
                 R("Kanchi Puranam (Sivagnana Munivar), part 1 (Project Madurai text)", "invocation vv. 4-6", "v. 4: Parvati's worship is broken off when the river Kampa rises; she clasps the lingam, and the Lord of the one mango tree (oru ma) is praised; v. 6 praises Kamakkottiyammai who gives the mark of her breasts (4 and 6 checked)", PMS, PM_URL + "pmuni0292.html"),
                 NOT_IN("Kanchi Puranam, parts 1-3 (vv. 1-1691, padalams 1-50)", "the three parts on Project Madurai give the Ekambam story only in the invocation; the padalam on Ekambam itself is not in them, so the bangle marks and the Vegavati detail rest on temple tradition")],
    "d-pathiri": [R("Thiruppathirippuliyur sthala puranam", "", "Parvati worshipped here after 1007 other places, in the formless state, under the pathiri tree; the shrine marks the spot with a bare pedestal (temple websites)", SEARCH)],
    "t-sangam": [TVPR(51, "Sangap Palakai Thanda", "", "the Sangam plank (51 checked)"), TVPR(55, "Sangaththar Kalagam Theertha", "", "Rudrasarman settles the poets' quarrel (55 checked)")],
    "t-spider-elephant": [PPX("12680", "Kochchengat Chola Nayanar Puranam", "vv. 2-6 (spider, web and elephant at Thiruvanaikka), 7-12 (Kochchengat's birth); 3, 4 and 12 checked")],
}
for _st in CATALOGUE:
    if _st["slug"] in REF2:
        _st["refs"] = REF2[_st["slug"]]

sys.path.insert(0, str(Path(__file__).resolve().parent))
from new_sets_briefs import BRIEF_FIX   # briefs corrected after reading the primary texts
for _st in CATALOGUE:
    if _st["slug"] in BRIEF_FIX:
        _st["brief"] = BRIEF_FIX[_st["slug"]]

SETS["sambandar"]["open_q"] = [
    "Periya Puranam numbering is now settled: the page and the Shiva file both use running verses 1-1256 (checks in this file's table).",
    "Episodes in the Puranam with NO song found (exact verses): Thirumarugal snake-bite 472-484; purse of gold at Tiruvavaduthurai 418-431; famine coins 564-571; "
    "the Kollampudur boat 897-900 (898 checked); the Perumanam wedding and merging 1236-1256; the cure of Kolli Mazhavan's daughter 310-320. Not made into stories.",
    "Poompavai: the Puranam says a snake bit her in the garden (vv. 1055-1058); her father kept her bones in a pot (v.1086). The hymn is Tevaram 2.47.",
    "Sambandar's name appears in the commentary of ~105 songs; every one of them is in `sam-avatar`. Songs that tell a specific episode are also in that episode's story.",
]

SETS["saints"]["sources"] = [
    ("Periya Puranam sections 12000-12700 (thevaaram.org)", "all downloaded and parsed; used: Thirumalai Sargam/Thadutatkonda (12000), Kannappar (12100), Eyarkon Kalikkama (12290), Kazharitrarivar (12370)", "opened; verses re-checked on every build"),
    ("Tiruvilaiyadal Puranam padalams 52-54, 58-61 (Tamil Wikisource)", "rendered pages fetched; keywords re-checked on every build", "opened; re-checked on every build"),
    ("Tiruvasagam (Tirumurai 8), Tirumurugatruppadai (Tirumurai 11), Adi Ula", "not opened", MEMORY),
]
SETS["saints"]["open_q"] = [
    "Songs 555, 862 and 911: the word அப்பர் means 'father' (Shiva), not the saint Appar. Resolved; no story.",
    "No Tamil lyric names Siruthondar, Karaikkal Ammaiyar, Chandesar, Nandanar or Thirumoolar (Thirumoolar only as a name in 425).",
    "Sundarar and the crocodile (song 1320) is NOT in the Periya Puranam text searched; it comes from tradition and Sundarar's Avinashi hymn (Tevaram 7), not checked.",
    "Cheraman's Kailasa ascent: the Puranam's Cheraman section ends with him missing Sundarar (vv. 173-175); the ascent verses were not located in the downloaded sections.",
    "Nakkeerar's cave captivity and the Tirumurugatruppadai are not in the Tiruvilaiyadal Puranam padalams 52-54 (those tell the Dharumi poem quarrel); the cave is tradition.",
]
SETS["devi"]["sources"] = [
    ("Devi Mahatmya, Madhyama Charitra ch. 2-4 (Markandeya Purana 81-93 or 78-90 by edition)", "chapter titles from printed-edition descriptions found by search; the Sanskrit text could not be fetched (GRETIL 404, sanskritdocuments blocked)", SEARCH),
    ("Tiruvilaiyadal Puranam padalams 3-5, 57 (Tamil Wikisource)", "rendered pages fetched; keywords re-checked on every build", "opened; re-checked on every build"),
    ("Sthala puranams: Kanchi (Ekambareswarar), Thiruppathirippuliyur, Thiruvalangadu", "temple and news pages only; the Tamil texts were not found online", SEARCH),
]
SETS["devi"]["open_q"] = [
    "Shumbha, Nishumbha and Raktabija are NOT in the songs: the Tamil string சும்ப is only part of other words. No story made.",
    "Kamakshi's thirty-two dharmas: no source text found after two searches; the tradition is named only in the songs' commentary.",
    "Thiruvalangadu's dance contest: accounts differ (17 poses; an earring or an anklet gem; left or right leg). One source names Karaikkal Ammaiyar's Mootha Tirupathigam; an Appar hymn is claimed but no number was found.",
    "Song 53 (Vana Durga, Kali) may mention Parvati giving the Vel; not confirmed, not assigned.",
]
SETS["murugan"]["sources"] = [
    ("Kanda Puranam (Kachiyappar), Utpatti Kandam and the start of the Asura Kandam (Tamil Wikisource)", "one 1.2 MB page parsed into 1781 verses (global numbers 1-1783); padalam names and verse ranges taken from its headings; keywords re-checked on every build", "opened; re-checked on every build"),
    ("Kanda Puranam, Mahendra, Yuddha, Deva and Daksha Kandams", "not on Wikisource (searches returned nothing); the war, Valli and Deivayanai stories cannot be machine-checked", "not available"),
    ("Tiruvilaiyadal Puranam padalam 13 (the Pandya prince Ugrakumara dries the sea with a Vel)", "a different story from Murugan's; may be what some 'sea dried' lines recall", "opened; re-checked on every build"),
]
SETS["murugan"]["open_q"] = [
    "Which kandam holds the Valli marriage: still unknown. The Wikisource text names Valli and Deivayanai only as future wives (vv. 1275-1277).",
    "Padalams pinned: Saravana 13 (vv. 1015-1051), Brahma imprisoned 16 (1205-1223) and freed 17 (1224-1265), Tarakan 20 (1329-1531).",
    "Not in the Wikisource text: the mango tree, peacock and cock, Jayanta, Agastya, the sea drying; they sit in the Asura/Yuddha kandams.",
    "Already in the Shiva set: Murugan teaches Shiva the Pranava (68 songs) and Murugan born from Shiva's eye (4).",
    "Ganesha frightening Valli and the fruit contest moved to `ganesha/`; Agastya and Tamil are also in `tamil-lore/`.",
]
SETS["tamil-lore"]["sources"] = [
    ("Tiruvilaiyadal Puranam padalams 51, 52, 55 (Tamil Wikisource)", "rendered pages fetched; keywords re-checked on every build", "opened; re-checked on every build"),
    ("Periya Puranam, Kochchengat Chola Nayanar Puranam (12680, vv. 2-12)", "parsed; the spider-and-elephant story is in the text itself", "opened; re-checked on every build"),
    ("Sangam poems (Purananuru) for Pari and Kari; Tirukkural", "not opened", MEMORY),
]
SETS["tamil-lore"]["open_q"] = [
    "Not in the songs: Silappathikaram, Manimekalai, Avvaiyar, Kamban as a character, Kapilar (one passing mention in song 138 among sages).",
    "Nakkeerar is in `saints/n-nakkeerar`; the Vandi and Vaigai stories in `saints/n-vandi-pittu`.",
    "t-spider-elephant now rests on the Periya Puranam text (Kochchengat Chola puranam), not only on temple pages.",
]

READ_ALL_SLUGS = {"sam-birth", "sam-milk", "sam-todudaiya", "sam-yazhpanar", "sam-palanquin", "sam-three-saints", "sam-thiruvalangadu",
                  "sam-poompavai", "sam-fever", "sam-ordeals", "m-jayanta", "m-agastya"}
for _st in CATALOGUE:
    if _st["slug"] in READ_ALL_SLUGS or _st["set"] in ("saints", "devi", "ganesha", "tamil-lore"):
        _st.setdefault("review", "Every song read against its quoted lines and commentary (2026-11-10); wrong matches were removed.")

# ---------------------------------------------------------------- generator
def norm(s):
    return re.sub(r"[\s\.…,;:!?'\"()\[\]\-–]", "", s or "")

def load_db():
    con = sqlite3.connect("file:" + str(DB) + "?mode=ro", uri=True)
    rows = con.execute("select id,title,place,lyrics_list,english_meanings_list,english_pathavurai from songs order by id").fetchall()
    out = {}
    for i, t, p, l, em, ep in rows:
        def jl(x):
            try:
                v = json.loads(x)
                return [str(a) for a in v] if isinstance(v, list) else [str(v)]
            except Exception:
                return [a for a in (x or "").split("\n") if a.strip()]
        out[i] = dict(id=i, title=t, place=p, lines=jl(l), en=jl(em) + ([ep] if ep else []))
    return out

def en_snippet(s, rx):
    """Commentary text centred on the first match (window of about 480 characters)."""
    blob = " ".join(s["en"]).replace("\n", " ")
    m = re.search(rx, blob, re.I)
    if not m:
        return None
    a, b = max(0, m.start() - 220), min(len(blob), m.end() + 260)
    return ("..." if a else "") + blob[a:b] + ("..." if b < len(blob) else "")

_CACHE = {}

def _cache(name):
    if name not in _CACHE:
        f = SCR / "scripts" / ".cache" / name
        _CACHE[name] = json.loads(f.read_text(encoding="utf-8")) if f.exists() else None
    return _CACHE[name]

# Kanda Puranam kandams after the first, from Project Madurai (parse_kp_pm.py); numbers run within the kandam
KPPM = {"kpm": "kp_mahendra.json", "kpy": "kp_yuddha.json", "kpd": "kp_deva.json", "kcp": "kanchi_part1.json"}

def run_verse_checks(set_key):
    """Re-check each verse cited for a set against the cached source text.
    Returns [(source, location, word, label, True/False/None)]; None = cache file missing."""
    out = []
    for src, loc, word, label in CHECKS.get(set_key, []):
        text = None
        if src == "pp":
            d = _cache("pp_all.json"); pid, n = loc.split(":")
            text = d and d.get(pid, {}).get(n)
        elif src == "tvp":
            d = _cache("tvp.json"); text = d and d.get(loc)
        elif src == "kp":
            d = _cache("kp_verses.json"); text = d and d.get(loc)
        elif src in KPPM:
            d = _cache(KPPM[src]); text = d and d.get(loc)
        ok = None if (_cache({"pp": "pp_all.json", "tvp": "tvp.json", "kp": "kp_verses.json", **KPPM}[src]) is None) else (word in re.sub(r"\s", "", text or ""))
        out.append((src, loc, word, label, ok))
    return out

def build():
    songs = load_db()
    by_slug = {}
    warnings = []
    for st in CATALOGUE:
        enrx = re.compile(st["en"], re.I)
        exrx = re.compile(st["excl"], re.I) if st.get("excl") else None

        def matches(txt):
            """True if the story pattern matches somewhere whose 100-char neighbourhood does not match `excl`."""
            for m in enrx.finditer(txt):
                if not exrx or not exrx.search(txt[max(0, m.start() - 100): m.end() + 100]):
                    return True
            return False

        if st.get("auto"):
            ids = [i for i, s in songs.items() if matches(" ".join(s["en"]).replace("\n", " "))]
        else:
            ids = st["ids"]
        drop = st.get("drop", {})
        ids = [i for i in ids if i not in drop]
        recs = []
        for i in sorted(set(ids)):
            if i not in songs:
                warnings.append(f"{st['slug']}: song {i} not in DB"); continue
            s = songs[i]
            blob = " ".join(s["en"]).replace("\n", " ")
            en_ok = matches(blob)
            quote = None
            rx = re.compile(st["ta"]) if st.get("ta") else None
            if rx:
                for j, ln in enumerate(s["lines"]):
                    if rx.search(norm(ln)):
                        lo, hi = max(0, j - 1), min(len(s["lines"]), j + 2)
                        quote = [(k, s["lines"][k]) for k in range(lo, hi)] ; hit = j
                        break
            if quote and en_ok:
                conf = "t"
            elif en_ok:
                conf = "c"
            else:
                conf = "low"
                warnings.append(f"{st['slug']}: song {i} commentary did not match pattern")
            recs.append(dict(song=s, quote=quote, hit=(hit if quote else None), conf=conf,
                             comm=(en_snippet(s, st["en"]) if conf != "t" or True else None)))
        by_slug[st["slug"]] = recs
    return songs, by_slug, warnings

HEADER = ("<!-- Generated by scriptures/scripts/build_new_sets.py. Do not hand-edit: change the catalogue in that script and rerun. -->\n")
NOTE = ("Assignments start KEYWORD-LEVEL: a song is listed when its English commentary (and, where possible, a Tamil lyric line) matches the story. "
        "A story with a 'Hand-read notes' section was then read (in full, or the doubtful part, as that section says) and wrong songs removed; "
        "other stories were not. Confidence: **t** = a Tamil lyric line matched and the commentary agrees; "
        "**c** = commentary only (no Tamil keyword line found); **low** = commentary did not match, check by reading the song.")

def clean(t):
    return re.sub(r"\s+", " ", (t or "").replace("\n", " ")).strip()

def write_all(songs, by_slug):
    catmap = {c["slug"]: c for c in CATALOGUE}
    for key, meta in SETS.items():
        d = SCR / key
        (d / "stories").mkdir(parents=True, exist_ok=True)
        slugs = [s for _, group in meta["domains"] for s in group]
        for old in (d / "stories").glob("*.md"):   # drop story files of slugs that left this set
            if old.stem not in slugs:
                old.unlink()
        # stories
        for slug in slugs:
            st = catmap[slug]; recs = by_slug[slug]
            L = [HEADER, f"# {st['title']}\n", f"`{slug}` | {meta['name']} | {len(recs)} songs\n", st["brief"] + "\n", "## References\n",
                 "| Source | Reference | Note | Status |", "|---|---|---|---|"]
            for src, ref, note, status, url in st["refs"]:
                r = ref + (f" [{url}]" if url else "")
                L.append(f"| {src} | {r} | {note} | {status} |".replace("\n", " "))
            L.append("\n" + NOTE + "\n")
            if st.get("review") or st.get("drop"):
                L.append("## Hand-read notes\n")
                if st.get("review"):
                    L.append(st["review"] + "\n")
                for i, why in sorted(st.get("drop", {}).items()):
                    L.append(f"- Removed after reading: {i} ({why})")
                L.append("")
            L.append("## Songs\n")
            for r in recs:
                s = r["song"]
                L.append(f"### {s['id']} {s['title']} ({s['place']})\n")
                if r["quote"]:
                    for k, ln in r["quote"]:
                        L.append(("> **" + ln + "**") if k == r["hit"] else ("> " + ln))
                    L.append("")
                else:
                    L.append("> (no Tamil keyword line found; commentary quoted instead)\n")
                if r["comm"]:
                    L.append("Commentary: " + clean(r["comm"]) + "\n")
                L.append(f"Confidence {r['conf']}\n")
            (d / "stories" / f"{slug}.md").write_text("\n".join(L), encoding="utf-8")
        # STORIES.md
        total_songs = sorted({r["song"]["id"] for sl in slugs for r in by_slug[sl]})
        L = [HEADER, f"# Stories index: {meta['name']}\n", f"- Stories: **{len(slugs)}**", f"- Distinct songs assigned: **{len(total_songs)}**", f"- {NOTE}\n"]
        for dom, group in meta["domains"]:
            L += [f"## {dom}\n", "| Story | Songs | Primary refs | File |", "|---|---|---|---|"]
            for sl in group:
                st = catmap[sl]
                L.append(f"| {st['title']} | {len(by_slug[sl])} | {len(st['refs'])} | [{sl}](stories/{sl}.md) |")
            L.append("")
        (d / "STORIES.md").write_text("\n".join(L), encoding="utf-8")
        # by-song
        per = {}
        for sl in slugs:
            for r in by_slug[sl]:
                per.setdefault(r["song"]["id"], []).append(sl)
        L = [HEADER, "# By song\n", "One row per song: its stories.\n", "| Song | Title | Stories |", "|---|---|---|"]
        for i in sorted(per):
            L.append(f"| {i} | {songs[i]['title']} | " + "; ".join(f"[{catmap[x]['title']}](stories/{x}.md)" for x in per[i]) + " |")
        (d / "by-song.md").write_text("\n".join(L) + "\n", encoding="utf-8")
        # song-story-map
        L = ["# Song -> story map for " + meta["name"] + " (generated from the catalogue; keyword-level, not hand-read).",
             "#   song_id | story slugs | title | confidence per story (t/c/low)"]
        for i in sorted(per):
            confs = []
            for sl in per[i]:
                confs.append(next(r["conf"] for r in by_slug[sl] if r["song"]["id"] == i))
            L.append(f"{i} | {','.join(per[i])} | {songs[i]['title']} | {','.join(confs)}")
        (d / "song-story-map.txt").write_text("\n".join(L) + "\n", encoding="utf-8")
        # SOURCES
        L = [HEADER, f"# Sources: {meta['name']}\n", "| Source | What was done | Status |", "|---|---|---|"]
        for a, b, c in meta["sources"]:
            L.append(f"| {a} | {b} | {c} |")
        L += ["", "## Open questions and gaps\n"] + [f"- {q}" for q in meta["open_q"]]
        chk = run_verse_checks(key)
        if chk:
            L += ["", "## Verse checks (re-run on every build)", "",
                  "Texts are cached in `scripts/.cache/` (git-ignored): `pp_all.json` = Periya Puranam sections from thevaaram.org (id 12000+10n = puranam n, verse numbers restart in each), "
                  "`tvp.json` = Tiruvilaiyadal Puranam padalam pages on Tamil Wikisource, `kp_verses.json` = Kanda Puranam on Tamil Wikisource (global verse numbers, first kandam and the start of the second only); `kp_mahendra.json`, `kp_yuddha.json`, `kp_deva.json` = the Mahendra, Yuddha and Deva kandams from Project Madurai's Unicode text, made by `parse_kp_pm.py` (verse numbers run within each kandam; the Yuddha page omits verses 894, 916-925 and 1901). "
                  "A line passes if the word occurs in that verse or page once spaces are removed.", "",
                  "| Text | Location | Word | Shows | Result |", "|---|---|---|---|---|"]
            names = {"pp": "Periya Puranam", "tvp": "Tiruvilaiyadal Puranam padalam", "kp": "Kanda Puranam verse (Utpatti)", "kpm": "Kanda Puranam, Mahendra Kandam verse", "kpy": "Kanda Puranam, Yuddha Kandam verse", "kpd": "Kanda Puranam, Deva Kandam verse", "kcp": "Kanchi Puranam (Sivagnana Munivar) part 1 verse"}
            for src, loc, word, lab, ok in chk:
                L.append(f"| {names[src]} | {loc} | {word} | {lab} | {'ok' if ok else ('NOT FOUND' if ok is False else 'cache missing')} |")
            bad = [c for c in chk if c[4] is False]
            print(f"{key} checks: {len(chk) - len(bad)}/{len(chk)} ok" + (f", FAILED: {[(c[0], c[1]) for c in bad]}" if bad else ""))
        (d / "SOURCES.md").write_text("\n".join(L) + "\n", encoding="utf-8")
        # README
        counts = {c: sum(1 for sl in slugs for r in by_slug[sl] if r["conf"] == c) for c in ("t", "c", "low")}
        L = [HEADER, f"# {meta['name']}\n", meta["intro"] + "\n", "## Files\n",
             "- `STORIES.md` index, `by-song.md`, `song-story-map.txt`, `SOURCES.md`, `stories/<slug>.md` (one per story).",
             "- Built by `scriptures/scripts/build_new_sets.py` (hand-written catalogue + generator); rerun it after editing the catalogue.",
             "- Nothing here is bundled into the app or touches the DB.\n", "## Method (research pass of 2026-11-10)\n",
             "1. Keyword sweeps of the Tamil lyrics found almost nothing (names are split by sandhi), so the English commentary columns "
             "(`english_meanings_list`, `english_pathavurai`) were swept instead.",
             "2. Each story lists songs from that sweep; each assignment is re-checked against the commentary when this script runs, and a Tamil lyric line is quoted where one matches.",
             "3. Source locations come from web checks (see `SOURCES.md`); verse numbers are not machine-checked.\n",
             f"Assignments by confidence: t={counts['t']}, c={counts['c']}, low={counts['low']}.\n", NOTE + "\n",
             "## Open questions\n"] + [f"- {q}" for q in meta["open_q"]]
        (d / "README.md").write_text("\n".join(L) + "\n", encoding="utf-8")
        print(f"{key}: {len(slugs)} stories, {len(total_songs)} songs, conf {counts}")

if __name__ == "__main__":
    songs, by_slug, warnings = build()
    write_all(songs, by_slug)
    print("WARNINGS:", len(warnings))
    for w in warnings:
        print("  ", w)
