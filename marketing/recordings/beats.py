"""Record one beat: python beats.py b1  (app must be installed, seeded, demo mode on).
Each beat starts from a known state (home, fresh launch) so it can be re-recorded alone.
"""
import sys
from adbtool import *

SONG = "அங்கை மென்குழல்"  # song 21, Thiruchendur: full data


def home():
    launch(fresh=True)
    time.sleep(7)


def slow_scroll(dy=700, ms=1500):
    swipe(540, 1750, 540, 1750 - dy, ms)


def scroll_to(text, tries=14):
    for _ in range(tries):
        if find(text):
            return True
        swipe(540, 1800, 540, 900, 400)
        time.sleep(0.4)
    return False


def open_song():
    scroll_to(SONG, 4)
    tap(SONG)
    time.sleep(1.5)


def b0():
    launch(fresh=True)
    # recording starts after launch so we catch a settled home; icon animation added in the edit
    time.sleep(3)
    with Rec("b00_hook", 9):
        time.sleep(1.5)
        slow_scroll(650, 1800)
        time.sleep(1)
        slow_scroll(650, 1800)


def b1():
    home()
    open_song()
    with Rec("b01_library", 9):
        time.sleep(1.5)
        slow_scroll(600, 1800)
        time.sleep(0.8)
        slow_scroll(600, 1800)
        time.sleep(0.8)


def b2():
    home()
    open_song()
    if not scroll_to("பதம் பிரித்தது"):
        raise SystemExit("padham section not found")
    with Rec("b02_padham", 13):
        time.sleep(1.2)
        slow_scroll(650, 1800)
        time.sleep(1)
        slow_scroll(700, 1800)
        time.sleep(1)
        slow_scroll(700, 1800)
        time.sleep(1)
        slow_scroll(700, 1800)




def b1b():
    home()
    open_song()
    if not scroll_to("பொருள்", 30):
        raise SystemExit("meaning card not found")
    swipe(540, 1700, 540, 900, 500)
    time.sleep(0.8)
    with Rec("b01b_meaning", 7):
        time.sleep(1.5)
        slow_scroll(600, 1800)
        time.sleep(1.5)


SEARCH_FAB = (964, 2010)


def b3():
    home()
    tap_xy(*SEARCH_FAB)
    time.sleep(2)
    tap_xy(540, 314)  # the search field has no label in the accessibility tree
    time.sleep(1)
    with Rec("b03_search", 8):
        time.sleep(1.0)
        type_text("muthaitharu")
        time.sleep(3.5)
    shot("b03_end.png")


def b4():
    home()
    tap("கோயில்கள்")
    time.sleep(2)
    tile = find("திருச்செந்தூர்")
    with Rec("b04_temples", 9):
        time.sleep(3)
        tap_xy(tile["cx"], tile["cy"])
        time.sleep(4)
    shot("b04_end.png")



def fling_to_end(n=8):
    for _ in range(n):
        swipe(540, 2000, 540, 300, 250)
        time.sleep(0.3)


def b6():
    """Highlight a verse and write a note on the hero song. Coordinates measured on 1080x2400."""
    home()
    open_song()
    time.sleep(1)
    with Rec("b06_notes", 20):
        time.sleep(1.2)
        hold(300, 1135, 1000)          # select a word in the first verse
        time.sleep(1.0)
        tap_xy(433, 1013)              # toolbar: வண்ணமிடு (Highlight)
        time.sleep(2.5)
        fling_to_end()
        time.sleep(1.0)
        tap_xy(283, 1066)              # பாடல் குறிப்பு (note)
        time.sleep(1.2)
        tap_xy(540, 1167)
        time.sleep(0.8)
        type_text("Revise this one in the morning.")
        time.sleep(1.2)
        tap_xy(805, 1328)              # சேமி (save), position with keyboard up
        time.sleep(1.5)



NAV = {"songs": (108, 2250), "temples": (324, 2250), "categories": (540, 2250), "library": (756, 2250), "more": (972, 2250)}


def b7():
    """Favorite a song and add it to a list, then show Categories. Uses song 'அங்கை நீட்டி' (not a favorite in the seed)."""
    db_edit(["UPDATE songs SET is_favorite=0 WHERE title='அங்கை நீட்டி'",
             "DELETE FROM song_categories WHERE song_id IN (SELECT id FROM songs WHERE title='அங்கை நீட்டி')"])
    home()
    scroll_to("அங்கை நீட்டி", 6)
    tap("அங்கை நீட்டி")
    time.sleep(2)
    with Rec("b07_lists", 30):
        time.sleep(1.2)
        tap_xy(964, 2032)              # heart FAB
        time.sleep(4.8)                # the snackbar covers the next FAB until it times out
        tap_xy(964, 2221)              # playlist-add FAB
        time.sleep(1.8)
        tap_xy(540, 1903)              # check the first custom list
        time.sleep(1.2)
        tap_xy(931, 2232)              # சேமி (save)
        time.sleep(3.0)                # a back gesture right after the sheet closes is ignored
        swipe(4, 1200, 700, 1200, 300)   # edge swipe back (the back key did not pop the page)
        time.sleep(2.0)
        tap_xy(*NAV["categories"])
        time.sleep(2.0)



def b10():
    """Chanting mode: manual verse, tune cue on/off, Auto at 5 s per verse, pause. Leaves a saved verse for b11."""
    home()
    open_song()
    time.sleep(1)
    with Rec("b10_chanting", 40):
        time.sleep(1.2)
        tap_xy(723, 919)               # chanting-mode icon beside "Lyrics"
        time.sleep(3.0)
        tap_xy(765, 137)               # hide the tune cue
        time.sleep(1.8)
        tap_xy(765, 137)               # show it again
        time.sleep(1.5)
        tap_xy(975, 2243)              # next verse (manual layout)
        time.sleep(2.2)
        tap_xy(675, 2096)              # switch to Auto (starts playing at once)
        time.sleep(1.5)
        tap_xy(212, 1919)              # pace: 5 s per verse
        time.sleep(11.5)               # two or three verses advance on their own
        tap_xy(540, 2232)              # நிறுத்து (pause)
        time.sleep(2.0)
    tap_xy(74, 137)                    # leave chanting (not recorded) so the verse is remembered
    time.sleep(1.5)


def b11():
    """Home shows 'Continue where you left off'; tap it and land on the saved verse."""
    home()
    card = find("விட்ட இடத்திலிருந்து")
    if not card:
        raise SystemExit("continue card not on Home: run b10 first")
    with Rec("b11_continue", 14):
        time.sleep(2.5)
        tap_xy(card["cx"], card["cy"])
        time.sleep(4.0)



def b9():
    """Today's Song card, then the shuffle FAB for a random song."""
    home()
    card = find("இன்றைய பாடல்")
    with Rec("b09_today", 32):
        time.sleep(2.0)
        tap_xy(card["cx"], card["cy"])
        time.sleep(3.5)
        swipe(4, 1200, 700, 1200, 300)   # edge swipe back
        time.sleep(3.5)
        tap_xy(964, 1833)                # shuffle FAB (random song)
        time.sleep(4.5)
    shot("b09_end.png")


def b13():
    """Share text and share link from the song page (system share sheet each time)."""
    home()
    open_song()
    fling_to_end()
    time.sleep(1)
    with Rec("b13_share", 22):
        time.sleep(1.5)
        tap_xy(283, 1318)              # உரையைப் பகிர் (share text)
        time.sleep(3.5)
        back()                         # closes the system share sheet
        time.sleep(2.0)
        tap_xy(797, 1318)              # இணைப்பைப் பகிர் (share link)
        time.sleep(3.5)
        back()
        time.sleep(1.5)



def b12():
    """Daily reminder: toggle on, open the time row, pick 6:00 AM. Starts from reminder OFF."""
    home()
    tap_xy(*NAV["more"])
    time.sleep(2)
    with Rec("b12_reminder", 30):
        time.sleep(1.5)
        tap_xy(540, 934)               # தினசரி அறிவிப்பு toggle on
        time.sleep(2.0)
        tap_xy(540, 1102)              # நினைவூட்டல் நேரம் row
        time.sleep(2.0)
        tap_xy(540, 1553)              # hour 6 on the dial
        time.sleep(1.8)
        tap_xy(540, 1128)              # minutes: 00 (top of the dial)
        time.sleep(1.5)
        tap_xy(863, 1690)              # சரி
        time.sleep(2.0)



def b8():
    """Share a YouTube video into the app, pick its song, land back in YouTube.

    Third-party content: the Yaazh Music 'Thiruppugazh Kaithala Niraikani' result for `katithala thiruppugazh`
    (a face-free title graphic). YouTube's layout and results change often, so every control is looked up live
    (a lookup costs ~2 s of idle time, trimmed in the edit). Check the frames before using the clip.
    """
    shell(f"am force-stop {PKG}")
    shell("am force-stop com.google.android.youtube")
    shell('am start -a android.intent.action.VIEW -d "https://www.youtube.com/results?search_query=katithala+thiruppugazh" com.google.android.youtube')
    time.sleep(11)
    with Rec("b08_share_in", 70):
        time.sleep(2.0)
        title = find("kaiththala niRaikani") or find("Kaithala")
        menus = [n for n in nodes() if n["desc"] == "Action menu"]
        menu = min(menus, key=lambda n: abs(n["cy"] - title["cy"]))
        tap_xy(menu["cx"], menu["cy"])
        time.sleep(1.5)
        tap_exact("Share", wait=2.0)
        tap_exact("More", wait=2.5)
        tap("Thiruppugazh", wait=3.5)   # the share target
        type_text("kaithala")
        time.sleep(3.0)
        tap("கைத்தல நிறைகனி", wait=5.0)  # the song; toast, then back in YouTube
    shot("b08_end.png")


def b8b():
    """Library > Links tab with the saved links."""
    home()
    tap_xy(*NAV["library"])
    time.sleep(2)
    tab = find("இணைப்புகள்")
    with Rec("b08b_links", 16):
        time.sleep(1.5)
        tap_xy(tab["cx"], tab["cy"])
        time.sleep(3.5)



def b5():
    """Language and theme: app language -> English, lyrics language -> English, theme -> Dark, then a song with A+ twice.
    Changes persistent settings: run LAST (reset with pm clear + seed_demo.py). Controls are looked up live."""
    home()
    tap_xy(*NAV["more"])
    time.sleep(2)
    with Rec("b05_language_theme", 90):
        time.sleep(1.5)
        tap_xy(540, 304)                       # பயன்பாட்டு மொழி (app language)
        time.sleep(1.5)
        tap_exact("English", wait=2.5)         # UI flips to English
        tap_xy(540, 493)                       # Lyrics Language
        time.sleep(1.5)
        tap_exact("English", wait=2.5)
        tap_xy(540, 724)                       # Theme
        time.sleep(1.5)
        tap_exact("Dark", wait=3.0)
        tap_xy(*NAV["songs"])
        time.sleep(2.0)
        scroll_to("angkai menkuzhal", 8)       # English transliteration of song 21
        tap("angkai menkuzhal", wait=2.5)
        tap_xy(975, 919)                       # A+
        time.sleep(1.2)
        tap_xy(975, 919)                       # A+
        time.sleep(2.0)
        slow_scroll(600, 1500)
        time.sleep(1.5)
    shot("b05_end.png")


if __name__ == "__main__":
    for name in sys.argv[1:]:
        globals()[name]()
        print("recorded", name)
