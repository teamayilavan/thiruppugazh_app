#!/usr/bin/env python3
"""
Generate the static fallback web site (song pages + index) for
thiruppugazh.ayilavan.org from assets/thiruppugazh.db.

These pages exist so a shared song link (https://thiruppugazh.ayilavan.org/song/{id})
still shows real content -- title, temple, lyrics, meanings -- with proper
Open Graph link-preview metadata, when the visitor doesn't have the app
installed. The app itself intercepts these URLs via Android App Links /
iOS Universal Links when it IS installed (see AndroidManifest.xml,
Runner.entitlements, and lib/ui/screens/main_wrapper.dart).

Run from the project root: python web_app/generate_site.py
"""

import html
import json
import shutil
import sqlite3
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
DB_PATH = ROOT / "assets" / "thiruppugazh.db"
STATIC_DIR = Path(__file__).resolve().parent / "static"
OUTPUT_DIR = Path(__file__).resolve().parent / "dist"

BASE_URL = "https://thiruppugazh.ayilavan.org"
DEEP_LINK_SCHEME = "thiruppugazh"
PLAY_STORE_URL = "https://play.google.com/store/apps/details?id=org.ayilavan.thiruppugazh"
ANDROID_PACKAGE = "org.ayilavan.thiruppugazh"
# SHA-256 fingerprint of the release signing certificate (alias ayilavan_key).
# Required for Android to auto-verify this domain as an App Link. Re-extract
# with:
#   keytool -list -v -keystore <path-to-release-keystore> -alias ayilavan_key | grep SHA256
RELEASE_CERT_SHA256 = (
    "D6:73:FA:D0:26:3C:63:3C:BE:27:EE:A2:E8:E5:BF:C0:"
    "10:D0:27:90:DF:2E:80:1B:3A:86:77:06:3B:07:AF:5F"
)
APP_ICON = "assets/icons/icon.png"
HERO_IMAGE = "assets/images/hero.png"


def load_json_list(value):
    if not value:
        return []
    return json.loads(value)


def esc(value):
    return html.escape(value or "", quote=True)


def build_stanza_html(lines, tune_list):
    """Groups verse lines into stanzas the same way SongDetailScreen does in
    the app (_buildLyricsTextSpans): every len(tune_list) lines gets a blank
    line between stanzas, otherwise lines just wrap normally."""
    tune_length = len(tune_list)
    parts = []
    for i, line in enumerate(lines):
        if not line.strip():
            continue
        parts.append(esc(line))
        parts.append("\n\n" if tune_length > 0 and (i + 1) % tune_length == 0 else "\n")
    return "".join(parts).rstrip()


def page_shell(*, title, description, canonical_url, deep_link, content):
    return f"""<!doctype html>
<html lang="ta">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>{esc(title)}</title>
<meta name="description" content="{esc(description)}">
<meta property="og:title" content="{esc(title)}">
<meta property="og:description" content="{esc(description)}">
<meta property="og:type" content="article">
<meta property="og:url" content="{esc(canonical_url)}">
<meta property="og:image" content="{BASE_URL}/static/hero.png">
<meta name="twitter:card" content="summary">
<link rel="icon" href="/static/icon.png">
<link rel="stylesheet" href="/static/style.css">
</head>
<body>
<header class="site-header">
  <a href="/" class="brand">
    <img src="/static/icon.png" alt="" class="brand-icon">
    <span>திருப்புகழ்</span>
  </a>
</header>
<main>
{content}
</main>
<footer class="get-app-banner">
  <div class="get-app-text">
    <strong>Get the full app</strong>
    <span>Search, favorites, offline access &amp; more</span>
  </div>
  <div class="get-app-buttons">
    <a id="open-app-btn" href="{esc(deep_link)}" class="btn btn-primary">Open in App</a>
    <a href="{PLAY_STORE_URL}" class="btn btn-secondary">Google Play</a>
  </div>
</footer>
<script>
(function() {{
  var btn = document.getElementById('open-app-btn');
  if (!btn) return;
  btn.addEventListener('click', function(e) {{
    e.preventDefault();
    var start = Date.now();
    window.location = btn.getAttribute('href');
    setTimeout(function() {{
      if (Date.now() - start < 2000 && !document.hidden) {{
        window.location = '{PLAY_STORE_URL}';
      }}
    }}, 1500);
  }});
}})();
</script>
</body>
</html>
"""


def render_song_page(song):
    song_id = song["id"]
    title = song["title"] or ""
    english_title = song["english_title"]
    place = song["place"] or ""
    english_venue = song["english_venue"]
    tune = song["tune"] or ""

    tune_list = load_json_list(song["tune_list"])
    lyrics_list = load_json_list(song["lyrics_list"])
    english_tune_list = load_json_list(song["english_tune_list"])
    english_lyrics_list = load_json_list(song["english_lyrics_list"])
    words = load_json_list(song["words"])
    meanings = load_json_list(song["meanings"])

    description_source = place or (lyrics_list[0] if lyrics_list else "")
    description = f"{title} — {description_source}"[:160]

    english_title_html = (
        f'<p class="english-title">{esc(english_title)}</p>' if english_title else ""
    )

    lyrics_html = build_stanza_html(lyrics_list, tune_list)
    lyrics_section = (
        f"""
<section class="lyrics">
  <h2>பாடல்</h2>
  <p>{lyrics_html}</p>
</section>
"""
        if lyrics_html
        else ""
    )

    english_section = ""
    if english_lyrics_list:
        english_lyrics_html = build_stanza_html(english_lyrics_list, english_tune_list)
        english_section = f"""
<section class="lyrics-en">
  <h2>Lyrics (English)</h2>
  <p>{english_lyrics_html}</p>
</section>
"""

    meanings_section = ""
    if words and meanings:
        rows = "".join(
            f"<dt>{esc(word)}</dt><dd>{esc(meaning)}</dd>"
            for word, meaning in zip(words, meanings)
            if word or meaning
        )
        meanings_section = f"""
<section class="meanings">
  <h2>பொருள்</h2>
  <dl>{rows}</dl>
</section>
"""

    kaumaram_id = str(song["kaumaram_id"] or "").zfill(4)
    kaumaram_url = f"https://kaumaram.com/thiru/nnt{kaumaram_id}_u.html"

    content = f"""<article class="song">
  <h1>{esc(title)}</h1>
  {english_title_html}
  <div class="song-meta">
    <div><span class="label">திருத்தலம்</span><span class="value">{esc(place)}{f' / {esc(english_venue)}' if english_venue else ''}</span></div>
    <div><span class="label">சந்தம்</span><span class="value">{esc(tune)}</span></div>
  </div>
  {lyrics_section}
  {english_section}
  {meanings_section}
  <p class="kaumaram-link"><a href="{esc(kaumaram_url)}" target="_blank" rel="noopener">Kaumaram.com-இல் காண்க</a></p>
</article>
"""

    canonical_url = f"{BASE_URL}/song/{song_id}/"
    deep_link = f"{DEEP_LINK_SCHEME}://song/{song_id}"

    return page_shell(
        title=f"{title} — திருப்புகழ்",
        description=description,
        canonical_url=canonical_url,
        deep_link=deep_link,
        content=content,
    )


def render_index_page(songs):
    items = "".join(
        f'<li><a href="/song/{s["id"]}/">{esc(s["title"])} '
        f'<span class="place">{esc(s["place"] or "")}</span></a></li>'
        for s in songs
    )
    content = f"""<div class="index">
  <p class="tagline">{len(songs)} திருப்புகழ் பாடல்கள் — search, favorites and offline access in the full app.</p>
  <ul class="song-list">{items}</ul>
</div>
"""
    return page_shell(
        title="திருப்புகழ் — Thiruppugazh",
        description="Thiruppugazh songs by Arunagirinathar — lyrics, meanings, and tune information.",
        canonical_url=f"{BASE_URL}/",
        # Not a specific song -- main_wrapper.dart only matches host == 'song',
        # so this just launches the app to its default home screen.
        deep_link=f"{DEEP_LINK_SCHEME}://home",
        content=content,
    )


def main():
    # Overwrite in place rather than deleting OUTPUT_DIR first -- avoids
    # failing on Windows when something (a local test server, an open
    # explorer window, ...) has the directory locked, and is idempotent
    # either way.
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    shutil.copytree(STATIC_DIR, OUTPUT_DIR / "static", dirs_exist_ok=True)
    shutil.copy(ROOT / APP_ICON, OUTPUT_DIR / "static" / "icon.png")
    shutil.copy(ROOT / HERO_IMAGE, OUTPUT_DIR / "static" / "hero.png")

    assetlinks_json = json.dumps(
        [
            {
                "relation": ["delegate_permission/common.handle_all_urls"],
                "target": {
                    "namespace": "android_app",
                    "package_name": ANDROID_PACKAGE,
                    "sha256_cert_fingerprints": [RELEASE_CERT_SHA256],
                },
            }
        ],
        indent=2,
    )
    # Netlify (and some other static hosts) don't serve dot-folders like
    # .well-known/ directly -- netlify.toml redirects /.well-known/* to
    # /well-known/:splat, so the file needs to exist at both paths.
    (OUTPUT_DIR / ".well-known").mkdir(exist_ok=True)
    (OUTPUT_DIR / ".well-known" / "assetlinks.json").write_text(
        assetlinks_json, encoding="utf-8"
    )
    (OUTPUT_DIR / "well-known").mkdir(exist_ok=True)
    (OUTPUT_DIR / "well-known" / "assetlinks.json").write_text(
        assetlinks_json, encoding="utf-8"
    )

    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    songs = conn.execute("SELECT * FROM songs ORDER BY title").fetchall()
    conn.close()

    for song in songs:
        song_dir = OUTPUT_DIR / "song" / str(song["id"])
        song_dir.mkdir(parents=True, exist_ok=True)
        (song_dir / "index.html").write_text(
            render_song_page(song), encoding="utf-8"
        )

    (OUTPUT_DIR / "index.html").write_text(
        render_index_page(songs), encoding="utf-8"
    )

    print(f"Generated {len(songs)} song pages + index into {OUTPUT_DIR}")


if __name__ == "__main__":
    main()
