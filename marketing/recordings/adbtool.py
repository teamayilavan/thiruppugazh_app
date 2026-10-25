"""Small adb helper for recording the demo: tap by on-screen text, swipe, type, record.
Usage as a module: from adbtool import *
"""
import os, re, subprocess, sys, time, xml.etree.ElementTree as ET

ADB = os.path.join(os.environ["LOCALAPPDATA"], "Android", "Sdk", "platform-tools", "adb.exe")
RAW = os.path.join(os.path.dirname(os.path.abspath(__file__)), "raw")
PKG = "org.ayilavan.thiruppugazh"
env = dict(os.environ, MSYS_NO_PATHCONV="1")


def sh(*args, check=True):
    return subprocess.run([ADB, *args], capture_output=True, env=env, check=check).stdout


def shell(cmd):
    return sh("shell", cmd).decode("utf-8", "replace")


def dump():
    sh("shell", "uiautomator", "dump", "/sdcard/ui.xml")
    xml = sh("exec-out", "cat", "/sdcard/ui.xml").decode("utf-8", "replace")
    return ET.fromstring(xml[xml.index("<"):])


def nodes():
    out = []
    for n in dump().iter("node"):
        b = re.findall(r"\d+", n.get("bounds", ""))
        if len(b) == 4:
            x1, y1, x2, y2 = map(int, b)
            out.append(dict(text=n.get("text", ""), desc=n.get("content-desc", ""), cx=(x1 + x2) // 2,
                            cy=(y1 + y2) // 2, box=(x1, y1, x2, y2), clickable=n.get("clickable") == "true"))
    return out


def find(substr, nth=0):
    hits = [n for n in nodes() if substr in n["text"] or substr in n["desc"]]
    return hits[nth] if len(hits) > nth else None


def tap_xy(x, y):
    shell(f"input tap {x} {y}")


def tap(substr, nth=0, wait=0.8):
    n = find(substr, nth)
    if not n:
        raise SystemExit(f"not found on screen: {substr!r}")
    tap_xy(n["cx"], n["cy"])
    time.sleep(wait)
    return n


def swipe(x1, y1, x2, y2, ms=600):
    shell(f"input swipe {x1} {y1} {x2} {y2} {ms}")


def hold(x, y, ms=900):
    swipe(x, y, x, y, ms)


def back():
    shell("input keyevent 4")


def type_text(s):
    shell("input text " + s.replace(" ", "%s"))


def shot(name):
    with open(os.path.join(RAW, name), "wb") as f:
        f.write(sh("exec-out", "screencap", "-p"))


def launch(fresh=False):
    if fresh:
        shell(f"am force-stop {PKG}")
    shell(f"monkey -p {PKG} -c android.intent.category.LAUNCHER 1")


class Rec:
    """with Rec('b1_library', 12): ... performs taps while screenrecord runs."""
    def __init__(self, name, seconds):
        self.name, self.seconds = name, seconds

    def __enter__(self):
        self.p = subprocess.Popen([ADB, "shell", f"screenrecord --time-limit {self.seconds} --bit-rate 16000000 /sdcard/{self.name}.mp4"], env=env)
        time.sleep(1.0)

    def __exit__(self, *a):
        self.p.wait()
        time.sleep(0.5)
        sh("pull", f"/sdcard/{self.name}.mp4", os.path.join(RAW, self.name + ".mp4"))
        sh("shell", "rm", f"/sdcard/{self.name}.mp4")


def db_edit(sql_statements):
    """Run SQL against the app's DB on the emulator (needs `adb root`; closes the app first)."""
    import sqlite3, tempfile
    subprocess.run([ADB, "root"], env=env, capture_output=True)
    shell(f"am force-stop {PKG}")
    path = f"/data/data/{PKG}/databases/thiruppugazh.db"
    local = os.path.join(RAW, "edit.db")
    with open(local, "wb") as f:
        f.write(subprocess.run([ADB, "exec-out", "cat", path], capture_output=True, env=env, check=True).stdout)
    db = sqlite3.connect(local)
    for s in sql_statements:
        db.execute(s)
    db.commit()
    db.execute("PRAGMA wal_checkpoint(TRUNCATE)")
    db.close()
    sh("push", local, "/data/local/tmp/edit.db")
    uid = shell(f"stat -c %u /data/data/{PKG}").strip()
    shell(f"cp /data/local/tmp/edit.db {path} && rm -f {path}-journal {path}-wal {path}-shm && chown {uid}:{uid} {path} && chmod 600 {path} && restorecon {path} && rm /data/local/tmp/edit.db")


def find_exact(label, nth=0):
    """Node whose text or content-desc equals `label` exactly (case-sensitive)."""
    hits = [n for n in nodes() if n["text"] == label or n["desc"] == label]
    return hits[nth] if len(hits) > nth else None


def tap_exact(label, nth=0, wait=1.0):
    n = find_exact(label, nth)
    if not n:
        raise SystemExit(f"not found on screen (exact): {label!r}")
    tap_xy(n["cx"], n["cy"])
    time.sleep(wait)
    return n
