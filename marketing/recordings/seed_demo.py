"""Seed the clean demo state into the debug app's DB on the emulator.

Seeds only what must already exist before recording: favorites, two categories,
and one note + highlight + link on song 7 (so the Library tabs are not empty).
The note, highlight and link on the hero song (21) are added live while recording.
Needs `adb root` (the emulator allows it). Run once after the app has created its DB; the app is closed by the script. All text is invented demo text.
"""
import os, sqlite3, subprocess, sys, datetime
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from adbtool import ADB, PKG, env, RAW, shell

DBDIR = f"/data/data/{PKG}/databases"
DBPATH = DBDIR + "/thiruppugazh.db"
local = os.path.join(RAW, "demo.db")
subprocess.run([ADB, "root"], env=env, capture_output=True)
shell(f"am force-stop {PKG}")
with open(local, "wb") as f:
    f.write(subprocess.run([ADB, "exec-out", "cat", DBPATH], capture_output=True, env=env, check=True).stdout)

db = sqlite3.connect(local)
now = datetime.datetime.now().isoformat()
db.execute("PRAGMA foreign_keys=ON")
fav = [21, 7, 23, 6, 25]
db.executemany("UPDATE songs SET is_favorite=1 WHERE id=?", [(i,) for i in fav])
db.executemany("INSERT OR IGNORE INTO song_categories(song_id,category_id) VALUES(?,1)", [(i,) for i in fav])
cats = {"காலைப் பாராயணம்": [21, 7], "கற்றலுக்கு": [23, 25, 8]}
for name, ids in cats.items():
    db.execute("INSERT OR IGNORE INTO categories(name) VALUES(?)", (name,))
    cid = db.execute("SELECT id FROM categories WHERE name=?", (name,)).fetchone()[0]
    db.executemany("INSERT OR IGNORE INTO song_categories(song_id,category_id) VALUES(?,?)", [(i, cid) for i in ids])
verse0 = db.execute("SELECT lyrics_list FROM songs WHERE id=7").fetchone()[0]
import json
text0 = json.loads(verse0)[0]
db.execute("INSERT INTO highlights(song_id,verse_index,text_content,created_at) VALUES(7,0,?,?)", (text0, now))
db.execute("INSERT INTO notes(song_id,content,created_at,updated_at) VALUES(7,?,?,?)",
           ("காலையில் படிக்க. பொருளைப் பிறகு பார்க்க.", now, now))
db.execute("INSERT INTO links(song_id,url,title,created_at) VALUES(8,?,?,?)",
           ("https://www.youtube.com/", "கீர்த்தனை (மாதிரி)", now))
db.commit()
db.execute("PRAGMA wal_checkpoint(TRUNCATE)")
db.close()

subprocess.run([ADB, "push", local, "/data/local/tmp/demo.db"], env=env, check=True, capture_output=True)
uid = shell(f"stat -c %u /data/data/{PKG}").strip()
shell(f"cp /data/local/tmp/demo.db {DBPATH} && rm -f {DBPATH}-journal {DBPATH}-wal {DBPATH}-shm && chown {uid}:{uid} {DBPATH} && chmod 600 {DBPATH} && restorecon {DBPATH}")
shell("rm /data/local/tmp/demo.db")
print("seeded: favorites", fav, "categories", list(cats))
