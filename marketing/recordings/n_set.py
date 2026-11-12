from adbtool import *
launch(fresh=True); time.sleep(7)
tap_xy(972,2250); time.sleep(2)
tap_xy(540,1016); time.sleep(1); tap_xy(540,1286); time.sleep(1.5)   # reset both to off
shot("n_set0.png")
with Rec("n04_settings", 26):
    time.sleep(1.5)
    tap_xy(900,1016); time.sleep(2.0)        # keep screen on
    tap_xy(900,1286); time.sleep(2.0)        # daily reminder on
    tap_xy(540,1454); time.sleep(2.0)        # time row
    tap_xy(540,1553); time.sleep(1.8)        # hour 6
    tap_xy(540,1128); time.sleep(1.5)        # 00
    tap_xy(863,1690); time.sleep(2.0)        # OK
shot("n_set1.png")
