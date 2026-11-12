from adbtool import *
launch(fresh=True); time.sleep(7)
with Rec("n05_tablet", 24):
    time.sleep(1.5)
    tap_xy(570,954); time.sleep(3.5)               # today's song opens in the pane
    swipe(1800,1100,1800,600,1200); time.sleep(1.5)  # read down the lyrics
    shell("input keyevent 22"); time.sleep(2.5)    # next song (right arrow)
    shell("input keyevent 22"); time.sleep(2.5)
    shell("input keyevent 21"); time.sleep(2.5)    # previous
shot("n05_end.png")
