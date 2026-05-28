#!/usr/bin/env python3
"""
Build assets/thiruppugazh.db and assets/english_data.json from songs/*.json.
Run from the project root: python scripts/build_db.py
"""

import json
import sqlite3
import os
import shutil
from pathlib import Path

# ---------------------------------------------------------------------------
# Tune transliteration — word-level map, longest match first
# ---------------------------------------------------------------------------
_TUNE_MAP = {
    'தனத்த':  'thanaththa',
    'தந்தன':  'thanthan',
    'தனதன':   'thanathan',
    'தனதான':  'thanathaan',
    'தனத':    'thanatha',
    'தத்தன':  'thaththan',
    'திமித':  'thimitha',
    'திமி':   'thimi',
    'தான':    'thaan',
    'தன':     'thana',
    'தாத':    'thaatha',
    'தா':     'thaa',
    'தித':    'thitha',
    'தி':     'thi',
    'நத':     'natha',
    'நா':     'naa',
    'ன':      'na',
    'ந':      'na',
    'த':      'tha',
    '......': '......',
}
_TUNE_ENTRIES = sorted(_TUNE_MAP.items(), key=lambda kv: -len(kv[0]))


def transliterate_tune_line(line: str) -> str:
    result = line
    for tamil, roman in _TUNE_ENTRIES:
        result = result.replace(tamil, roman)
    return result


# ---------------------------------------------------------------------------
# SQL schema
# ---------------------------------------------------------------------------
CREATE_SONGS = """
CREATE TABLE IF NOT EXISTS songs (
    id                   INTEGER PRIMARY KEY,
    title                TEXT NOT NULL,
    lyrics               TEXT,
    tune                 TEXT,
    place                TEXT,
    kaumaram_id          TEXT,
    tune_list            TEXT,
    lyrics_list          TEXT,
    words                TEXT,
    meanings             TEXT,
    pathavurai           TEXT,
    patham               TEXT,
    search_content       TEXT,
    is_favorite          INTEGER DEFAULT 0,
    english_title        TEXT,
    english_venue        TEXT,
    english_tune_list    TEXT,
    english_lyrics_list  TEXT,
    english_words        TEXT,
    english_meanings_list TEXT,
    english_pathavurai   TEXT
)
"""

CREATE_CATEGORIES = """
CREATE TABLE IF NOT EXISTS categories (
    id   INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE
)
"""

CREATE_SONG_CATEGORIES = """
CREATE TABLE IF NOT EXISTS song_categories (
    song_id     INTEGER,
    category_id INTEGER,
    PRIMARY KEY (song_id, category_id),
    FOREIGN KEY(song_id)     REFERENCES songs(id)      ON DELETE CASCADE,
    FOREIGN KEY(category_id) REFERENCES categories(id) ON DELETE CASCADE
)
"""

CREATE_TEMPLES = """
CREATE TABLE IF NOT EXISTS temples (
    id           INTEGER PRIMARY KEY AUTOINCREMENT,
    name         TEXT NOT NULL UNIQUE,
    song_count   INTEGER DEFAULT 0,
    english_name TEXT
)
"""

CREATE_HIGHLIGHTS = """
CREATE TABLE IF NOT EXISTS highlights (
    id           INTEGER PRIMARY KEY AUTOINCREMENT,
    song_id      INTEGER NOT NULL,
    verse_index  INTEGER NOT NULL,
    text_content TEXT,
    created_at   TEXT NOT NULL,
    FOREIGN KEY(song_id) REFERENCES songs(id) ON DELETE CASCADE
)
"""

CREATE_NOTES = """
CREATE TABLE IF NOT EXISTS notes (
    id         INTEGER PRIMARY KEY AUTOINCREMENT,
    song_id    INTEGER NOT NULL,
    content    TEXT NOT NULL,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL,
    FOREIGN KEY(song_id) REFERENCES songs(id) ON DELETE CASCADE
)
"""

INDEXES = [
    "CREATE INDEX IF NOT EXISTS idx_songs_is_favorite ON songs(is_favorite)",
    "CREATE INDEX IF NOT EXISTS idx_song_categories_category_id ON song_categories(category_id)",
    "CREATE INDEX IF NOT EXISTS idx_highlights_song_id ON highlights(song_id)",
    "CREATE INDEX IF NOT EXISTS idx_notes_song_id ON notes(song_id)",
]


# ---------------------------------------------------------------------------
# Per-song data extraction
# ---------------------------------------------------------------------------
def extract_song_row(data: dict) -> dict:
    wm = data.get('word_meanings', [])
    tamil_words    = [item['words']   for item in wm]
    tamil_meanings = [item['meaning'] for item in wm]
    pathavurai     = ' '.join(tamil_meanings)

    tune_list   = data.get('tune_list', [])
    lyrics_list = data.get('lyrics_list', [])

    search_content = ' '.join([
        data.get('title', ''),
        data.get('lyrics', ''),
        ' '.join(tamil_words),
        data.get('pathavurai', pathavurai),
    ])

    em = data.get('english_meanings', [])
    en_words    = [item['word']    for item in em] if em else None
    en_meanings = [item['meaning'] for item in em] if em else None
    en_pathavurai = ' '.join(en_meanings) if en_meanings else None

    en_lyrics_raw = data.get('english_lyrics')
    if en_lyrics_raw is not None:
        en_lyrics_list = [line for line in en_lyrics_raw if line != '']
    else:
        en_lyrics_list = None

    if data.get('english_lyrics') is not None:
        en_tune_list = [transliterate_tune_line(line) for line in tune_list]
    else:
        en_tune_list = None

    return {
        'id':                   int(data['kaumaram_id']),
        'title':                data.get('title'),
        'lyrics':               data.get('lyrics'),
        'tune':                 data.get('tune'),
        'place':                data.get('place'),
        'kaumaram_id':          str(data.get('kaumaram_id')),
        'tune_list':            json.dumps(tune_list, ensure_ascii=False),
        'lyrics_list':          json.dumps(lyrics_list, ensure_ascii=False),
        'words':                json.dumps(tamil_words, ensure_ascii=False),
        'meanings':             json.dumps(tamil_meanings, ensure_ascii=False),
        'pathavurai':           data.get('pathavurai', pathavurai),
        'patham':               json.dumps(data.get('patham', []), ensure_ascii=False),
        'search_content':       search_content,
        'is_favorite':          0,
        'english_title':        data.get('english_title'),
        'english_venue':        data.get('english_venue'),
        'english_tune_list':    json.dumps(en_tune_list, ensure_ascii=False) if en_tune_list is not None else None,
        'english_lyrics_list':  json.dumps(en_lyrics_list, ensure_ascii=False) if en_lyrics_list is not None else None,
        'english_words':        json.dumps(en_words, ensure_ascii=False) if en_words is not None else None,
        'english_meanings_list': json.dumps(en_meanings, ensure_ascii=False) if en_meanings is not None else None,
        'english_pathavurai':   en_pathavurai,
    }


def extract_english_patch(song_id: int, row: dict) -> dict | None:
    if row['english_title'] is None:
        return None
    return {
        'english_title':         row['english_title'],
        'english_venue':         row['english_venue'],
        'english_tune_list':     row['english_tune_list'],
        'english_lyrics_list':   row['english_lyrics_list'],
        'english_words':         row['english_words'],
        'english_meanings_list': row['english_meanings_list'],
        'english_pathavurai':    row['english_pathavurai'],
    }


# ---------------------------------------------------------------------------
# Main build
# ---------------------------------------------------------------------------
def build(songs_dir: Path, db_path: Path, patch_path: Path):
    json_files = sorted(songs_dir.glob('*.json'))
    if not json_files:
        print(f"ERROR: No JSON files found in {songs_dir}")
        return

    print(f"Found {len(json_files)} song JSON files")

    if db_path.exists():
        db_path.unlink()

    conn = sqlite3.connect(db_path)
    conn.execute('PRAGMA foreign_keys = ON')
    conn.execute(CREATE_SONGS)
    conn.execute(CREATE_CATEGORIES)
    conn.execute(CREATE_SONG_CATEGORIES)
    conn.execute(CREATE_TEMPLES)
    conn.execute(CREATE_HIGHLIGHTS)
    conn.execute(CREATE_NOTES)
    for idx in INDEXES:
        conn.execute(idx)

    conn.execute("INSERT OR IGNORE INTO categories (id, name) VALUES (1, 'Favorites')")

    english_patch = {}
    temple_english: dict = {}

    rows = []
    for f in json_files:
        try:
            data = json.loads(f.read_text(encoding='utf-8'))
            row = extract_song_row(data)
            rows.append(row)

            sid = row['id']
            patch = extract_english_patch(sid, row)
            if patch:
                english_patch[str(sid)] = patch

            place = row.get('place')
            venue = row.get('english_venue')
            if place and venue and place not in temple_english:
                temple_english[place] = venue

        except Exception as e:
            print(f"WARNING: skipping {f.name}: {e}")

    cols = list(rows[0].keys())
    placeholders = ', '.join('?' for _ in cols)
    col_names = ', '.join(cols)
    conn.executemany(
        f"INSERT OR REPLACE INTO songs ({col_names}) VALUES ({placeholders})",
        [[r[c] for c in cols] for r in rows]
    )

    conn.execute("""
        INSERT INTO temples (name, song_count, english_name)
        SELECT place, COUNT(*), NULL
        FROM songs
        WHERE place IS NOT NULL AND place != ''
        GROUP BY place
    """)

    for tamil_name, english_name in temple_english.items():
        conn.execute(
            "UPDATE temples SET english_name = ? WHERE name = ?",
            (english_name, tamil_name)
        )

    conn.commit()
    conn.close()

    patch_path.write_text(
        json.dumps(english_patch, ensure_ascii=False, indent=2),
        encoding='utf-8'
    )

    print(f"DB written to:           {db_path}  ({db_path.stat().st_size // 1024} KB)")
    print(f"Migration patch written: {patch_path}  ({len(english_patch)} songs with English data)")
    missing = len(rows) - len(english_patch)
    print(f"Songs without English:   {missing}")


if __name__ == '__main__':
    root = Path(__file__).parent.parent
    build(
        songs_dir  = root / 'songs',
        db_path    = root / 'assets' / 'thiruppugazh.db',
        patch_path = root / 'assets' / 'english_data.json',
    )
