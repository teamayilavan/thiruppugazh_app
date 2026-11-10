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
                "Poompavai (Mylapore) is in the Periya Puranam late in the Sambandar Puranam; the verse range was not pinned. Hymn is believed to be Tevaram 2.47 (from memory).",
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
                 ("Valli and Deivayanai", ["m-valli-disguise", "m-valli-elephant", "m-deivayanai", "m-airavata", "m-mango-fruit"])],
        sources=[
            ("Kanda Puranam (Kachiyappa Sivacharyar), six kandams: Utpatti, Asura, Mahendra, Yuddha, Deva, Daksha", "kandam list from web search; episode-to-kandam mapping and padalam numbers not confirmed", SEARCH),
            ("Skanda Purana, Sankara Samhita (source of the Tamil work)", "not opened", MEMORY),
            ("Tirumurugatruppadai (Nakkeerar)", "not opened", MEMORY),
        ],
        open_q=["Which kandam holds the Valli marriage was not confirmed.",
                "Kanda Puranam verses are not pinned for any story here.",
                "Counts for Surasamharam stories are inflated by songs that only list Murugan's deeds in a line; read before relying on them.",
                "Already in the Shiva set: Murugan teaches Shiva the Pranava (68 songs) and Murugan born from Shiva's eye (4)."]),
}

# ---------------------------------------------------------------- the stories
SAM_ALL = [17,58,82,104,115,116,121,123,132,134,137,149,150,171,189,257,261,263,299,306,308,354,356,358,405,426,490,509,521,527,540,550,565,573,603,604,617,636,639,641,651,653,658,666,668,669,674,677,681,693,708,712,737,744,758,759,762,764,766,767,768,769,771,774,776,789,799,822,823,831,837,846,859,878,888,902,913,920,959,962,971,995,996,1022,1033,1046,1072,1083,1098,1100,1146,1162,1166,1209,1233,1257,1263,1266,1270,1282,1287,1291,1317,1326,1327]

def R(src, ref, note, status, url=""):
    return (src, ref, note, status, url)

CATALOGUE = [
 # ------------------------------------------------------------------ SAMBANDAR
 dict(slug="sam-avatar", set="sambandar", title="Murugan comes as Sambandar (the Tamil Veda)", ids=SAM_ALL,
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
      en=r"milk|breast-?fed|breast", ta=r"உமை|உமா|ஞானப்பால்|பாலுண்|அமுதுண்|முலை",
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
            R("Tevaram, Sambandar, Mylapore pathigam", "believed 2.47 (Mattitta Punnai); not opened", "", MEMORY)]),
 dict(slug="sam-fever", set="sambandar", title="The Pandya's fever and hunchback cured with holy ash", ids=[171,299,527,573,639,666,762,768,789,920,962,1162],
      en=r"fever|hunch|PANdiy|Pandiy|Pandya", ta=r"வெப்பு|கூன்|நீறு|பாண்டிய|நெடுமாற|வெண்பொடி|திருநீ",
      brief=("Under Jain influence the Pandya king (Koon Pandyan, later Nindrasir Nedumaran) fell to a fever after the Jains' fire was turned on him. Queen Mangaiyarkkarasi "
             "and the minister Kulachchirai called Sambandar, who sang 'Mantiramavathu Neeru', put holy ash on the king, cured the fever and straightened his hunchback."),
      refs=[R("Periya Puranam, Sambandar Puranam", "vv. 599-772 (page numbering): summons, the fire plot (678-704), the fever (705-716), the cure (736-772)", "", OPENED, PP_SAM),
            R("Tevaram 2.66.1", "Mantiramavathu Neeru", "the ash hymn", OPENED_EARLIER, TEV266),
            R("Tevaram 3.39.1", "Maninernvizhi", "sung to the frightened queen", OPENED_EARLIER, TEV339),
            R("Tiruvilaiyadal Puranam", "padalam 62", "", OPENED_EARLIER, TVP62)]),
 dict(slug="sam-ordeals", set="sambandar", title="Palm-leaf in the fire and against the Vaigai", ids=[104,149,189,358,542,617,666,920,1098,1270],
      en=r"palm[- ]?leaf|Vaigai|leaves", ta=r"ஏடு|வைகை|புனல்|எதிரேற|கனல்|தீயிட",
      brief=("The Jains proposed contests: both sides' palm-leaf scriptures were thrown into fire (Sambandar's stayed green), then into the flooded Vaigai (his leaf went upstream "
             "and halted at Tiruvedagam while theirs was swept away)."),
      refs=[R("Periya Puranam, Sambandar Puranam", "fire test vv. 773-796, river test 797-816 (page numbering)", "", OPENED, PP_SAM),
            R("Tevaram 3.54.1", "Vazhga Andhanar", "river test", OPENED_EARLIER, TEV354),
            R("Tevaram 3.32.1", "Tiruvedagam", "the leaf halts", OPENED_EARLIER, TEV332),
            R("Tiruvilaiyadal Puranam", "padalam 63", "", OPENED_EARLIER, TVP63)]),
 dict(slug="sam-jains", set="sambandar", title="The Jains impaled (further songs)", ids=[17,132,263,306,405,509,603,653,658,668,669,677,681,767,769,771,799,859,888,1162,1209,1257,1327],
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
      en=r"thousand sovereigns|gold|Tiruvarur|ThiruvArUr", ta=r"பொன்",
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
      en=r"pAthiri|Padal|PAdalanagar|ThiruppAthirip|penance", ta=r"பாதிரி|பாடலி|புலியூர்|தவம்",
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
 dict(slug="m-mango-sura", set="murugan", title="Surapadman as a mango tree split by the Vel", auto=True,
      en=r"(SUran|SUrapadman|Surapadman|demon)[^.]{0,200}mango[- ]tree|mango[- ]tree[^.]{0,200}(SUran|Surapadman|demon|split|felled|disguise)|(disguise|form) of (a |an )?(old )?mango", ta=r"மாமரம்|மாவாய்|மாவாகி|மாவடி|மாமுதல்",
      brief="In the last day of the war Surapadman took the form of a huge mango tree; Murugan's Vel split it in two, and the halves became the peacock and the cock.",
      refs=[R("Kanda Puranam, Yuddha Kandam", "Sura samharam", "kandam unconfirmed", SEARCH)]),
 dict(slug="m-krouncha", set="murugan", title="The Krouncha mountain pierced", auto=True,
      en=r"Kroun?cha|Kraunch|KrouncA", ta=r"கிர[வௌெ]",
      brief="Murugan's Vel pierced the Krouncha mountain, the demon Tarakasura's hiding place and stronghold, which crumbled.",
      refs=[R("Kanda Puranam / Skanda Purana", "Taraka and Krouncha episode", "", SEARCH)]),
 dict(slug="m-sea-dried", set="murugan", title="The sea dried by the Vel", auto=True,
      en=r"(sea|ocean)[^.]{0,60}(dried|dry up|boil)|dried up the (sea|ocean)|(seven|seas)[^.]{0,40}dried", ta=r"கடல்வற்ற|வற்றிட|வற்றக்|வற்றி|வறள|அலைகடல்",
      brief="Surapadman fled into the sea; Murugan's Vel made the ocean dry up or boil, driving him out.",
      refs=[R("Kanda Puranam, Yuddha Kandam", "", "", SEARCH)]),
 dict(slug="m-peacock-cock", set="murugan", title="The peacock and the cock", auto=True,
      en=r"(SUran|Surapadman|SUrapadman)[^.]{0,200}(peacock|cock)|(peacock|cock)[^.]{0,120}(SUran|Surapadman)", ta=r"சேவல்|மயில்",
      brief="The two halves of the split Surapadman became Murugan's vehicle, the peacock, and the cock on his flag.",
      refs=[R("Kanda Puranam, Yuddha Kandam", "", "", SEARCH)]),
 dict(slug="m-tarakasura", set="murugan", title="Tarakasura", auto=True,
      en=r"Tharaka|Taraka", ta=r"தாரக",
      brief="Tarakasura, Surapadman's brother, was killed by Murugan before the final battle (Asura Kandam).",
      refs=[R("Kanda Puranam, Asura Kandam", "", "", SEARCH)]),
 dict(slug="m-jayanta", set="murugan", title="Jayanta, Indra's son, freed from Sura's prison", ids=[582],
      en=r"Jayanth", ta=r"சயந்த",
      brief="Indra's son Jayanta fled Surapadman's persecution and was freed from prison by Murugan, who restored the heavens to Indra.",
      refs=[R("Kanda Puranam, Mahendra Kandam / Yuddha Kandam", "", "kandam unconfirmed", SEARCH)]),
 dict(slug="m-brahma-prison", set="murugan", title="Brahma imprisoned for failing the Pranava", auto=True,
      en=r"BrahmA[^.]{0,60}(imprison|prison|jail|confin)|imprison[^.]{0,40}BrahmA|BrahmA[^.]{0,40}(ashamed|failed to explain)", ta=r"சிறை",
      brief="When Brahma could not explain the meaning of Om to Murugan, the boy tapped his head and locked him in prison; Shiva then asked for his release. Related to the Shiva-set story murugan-pranava.",
      refs=[R("Kanda Puranam / Skanda Purana", "Brahma's imprisonment", "", SEARCH),
            R("Shiva set", "shiva/stories/murugan-pranava.md", "Murugan teaches Shiva the Pranava", "local", "")]),
 dict(slug="m-agastya", set="murugan", title="Murugan teaches Agastya", ids=[598,627,878,915,954,1081,1152],
      en=r"Agasth", ta=r"அகத்திய|அகத்தி",
      brief="Murugan is said to have taught Agastya the secret of the sage's own wisdom and to have given Tamil to him.",
      refs=[R("Skanda Purana; Tamil tradition", "", "", MEMORY)]),
 dict(slug="m-saravana", set="murugan", title="Born in the Saravana lake; the six Krittikas", auto=True,
      en=r"(six|6)[^.]{0,40}(KArthigai|Karthigai|Krithika|nymphs|ladies|mothers|damsels|maidens|women)|Saravana (lake|Lake|pond|Poigai|poigai)|SaravaNa (lake|Lake|pond)|(KArthigai|Karthigai) (women|ladies|mothers)",
      ta=r"சரவண|கார்த்திகை|பொய்கை",
      brief="Six sparks from Shiva's eye were carried by Agni and Ganga into the Saravana lake, became six babies, and were nursed by the six Krittika women; Parvati joined them into one child with six faces. Related to the Shiva-set story murugan-skanda-birth.",
      refs=[R("Kanda Puranam, Utpatti Kandam", "", "", SEARCH),
            R("Shiva set", "shiva/stories/murugan-skanda-birth.md", "", "local", "")]),
 dict(slug="m-valli-disguise", set="murugan", title="Murugan woos Valli in disguise", auto=True,
      en=r"(old man|aged man|elderly man|old hunter)[^.]{0,200}VaLLi|VaLLi[^.]{0,200}(old man|aged man|elderly man|old hunter)|(Vengai|vEngai|kino tree|neem tree)[^.]{0,200}(VaLLi|disguise)|disguise[^.]{0,120}(Vengai|vEngai|kino|neem)", ta=r"கிழவ|வேடன்|வேங்கை|வேடு|கிழ",
      brief="Murugan came to Valli, the hunter's daughter, in the millet field as a hunter, an old man and a Vengai tree, and won her.",
      refs=[R("Kanda Puranam, Valli Thirumanam", "kandam not confirmed", "", SEARCH)]),
 dict(slug="m-valli-elephant", set="murugan", title="Ganesha as an elephant frightens Valli", ids=[24,146,193,446,465,668,715,832,971],
      en=r"tusked elephant|elephant", ta=r"யானை|ஆனை|கரி|களிறு|கணபதி|கஜ",
      brief="To make Valli run into Murugan's arms, Murugan asked his brother Ganesha to appear as a wild elephant; Valli clung to Murugan in fear.",
      refs=[R("Kanda Puranam, Valli Thirumanam", "", "", SEARCH)]),
 dict(slug="m-deivayanai", set="murugan", title="Murugan marries Deivayanai, Indra's daughter", auto=True,
      en=r"(marri|wed|matrimony|nuptial|wedding)[^.]{0,120}(DEvayAnai|DevayAnai|DEvAnai|Deivayanai)|(DEvayAnai|DevayAnai|DEvAnai|Deivayanai)[^.]{0,120}(marri|wed |wedded|matrimony|nuptial)",
      ta=r"தெய்வயானை|தெய்வானை|தேவசேனை|தேவகுஞ்சரி|இந்திரன்மகள|சுரபதிமகள",
      brief="After the war Indra gave his daughter Deivayanai (Devasena), raised by Airavata, to Murugan; the wedding is at Thiruparankundram.",
      refs=[R("Kanda Puranam, Deva Kandam (per general accounts)", "", "", SEARCH)]),
 dict(slug="m-airavata", set="murugan", title="Airavata raises Deivayanai", auto=True,
      en=r"AirAvat|Airavat", ta=r"ஐராவத|வெள்ளையானை",
      brief="Deivayanai was brought up by Indra's white elephant Airavata, which is why songs call Murugan the son-in-law of Indra and Airavata's ward.",
      refs=[R("Kanda Puranam", "", "", SEARCH)]),
 dict(slug="m-mango-fruit", set="murugan", title="The fruit contest around the world", ids=[30,532,934],
      en=r"fruit|mango|circled|went around|flew around|competition", ta=r"கனி|பழம்|உலகை|மயில்மிசை",
      brief="Narada's fruit of wisdom was to go to the son who circled the world first; Murugan flew round on his peacock, Ganesha went round his parents, and Murugan left for Pazhani in anger.",
      refs=[R("Skanda Purana / Tamil tradition", "", "", MEMORY)]),
]

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

def build():
    songs = load_db()
    by_slug = {}
    warnings = []
    for st in CATALOGUE:
        enrx = re.compile(st["en"], re.I)
        if st.get("auto"):
            ids = [i for i, s in songs.items() if enrx.search(" ".join(s["en"]).replace("\n", " "))]
        else:
            ids = st["ids"]
        recs = []
        for i in sorted(set(ids)):
            if i not in songs:
                warnings.append(f"{st['slug']}: song {i} not in DB"); continue
            s = songs[i]
            blob = " ".join(s["en"]).replace("\n", " ")
            en_ok = bool(enrx.search(blob))
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
NOTE = ("Assignments are KEYWORD-LEVEL: a song is listed when its English commentary (and, where possible, a Tamil lyric line) matches the story. "
        "They have not been hand-read like `shiva/` and `vishnu/`. Confidence: **t** = a Tamil lyric line matched and the commentary agrees; "
        "**c** = commentary only (no Tamil keyword line found); **low** = commentary did not match, check by reading the song.")

def clean(t):
    return re.sub(r"\s+", " ", (t or "").replace("\n", " ")).strip()

def write_all(songs, by_slug):
    catmap = {c["slug"]: c for c in CATALOGUE}
    for key, meta in SETS.items():
        d = SCR / key
        (d / "stories").mkdir(parents=True, exist_ok=True)
        slugs = [s for _, group in meta["domains"] for s in group]
        # stories
        for slug in slugs:
            st = catmap[slug]; recs = by_slug[slug]
            L = [HEADER, f"# {st['title']}\n", f"`{slug}` | {meta['name']} | {len(recs)} songs\n", st["brief"] + "\n", "## References\n",
                 "| Source | Reference | Note | Status |", "|---|---|---|---|"]
            for src, ref, note, status, url in st["refs"]:
                r = ref + (f" [{url}]" if url else "")
                L.append(f"| {src} | {r} | {note} | {status} |".replace("\n", " "))
            L.append("\n" + NOTE + "\n")
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
