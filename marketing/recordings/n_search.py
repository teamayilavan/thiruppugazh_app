from adbtool import *
launch(fresh=True); time.sleep(7)
tap_xy(964,2010); time.sleep(2)
tap_xy(540,314); time.sleep(1.2)
with Rec("n01_search_match", 11):
    time.sleep(1.0)
    for part in ("ka","dam","bu"):
        type_text(part); time.sleep(0.9)
    time.sleep(2.0)
    shell("input keyevent 66"); time.sleep(1.5)
    swipe(540,1700,540,1200,900); time.sleep(1.5)
shot("n01_end.png")
