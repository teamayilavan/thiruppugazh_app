from adbtool import *
with Rec("n02_share_in", 22):
    time.sleep(2.0)
    tap_xy(1016,137); time.sleep(1.6)
    tap_xy(653,1236); time.sleep(2.4)
    tap_xy(324,2270); time.sleep(3.2)
    tap_xy(300,792); time.sleep(4.5)
shot("n02_end.png")
