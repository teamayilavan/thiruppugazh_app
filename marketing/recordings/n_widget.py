from adbtool import *
with Rec("n03_widget", 13):
    time.sleep(3.0)
    tap_xy(540,730); time.sleep(3.5)
    swipe(540,1700,540,1300,1200); time.sleep(2.0)
shot("n03_end.png")
