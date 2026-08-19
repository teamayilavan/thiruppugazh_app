# Fallback Web App (`web_app/`)

A static site hosted at `https://thiruppugazh.ayilavan.org`, generated from the same `assets/thiruppugazh.db` the Flutter app ships with. It exists so a shared song link doesn't dead-end for someone who doesn't have the app installed.

This is a separate domain from `thiruppugazhapp.ayilavan.org`, which is the existing single-page marketing/banner site — unrelated to this project's repo.

## Why it exists

- `SongDetailScreen._shareSongLink()` shares `https://thiruppugazh.ayilavan.org/song/{id}`.
- When the app **is** installed, Android/iOS intercept that URL via App Links / Universal Links and never touch the browser (see `docs/architecture.md` → Deep Linking).
- When the app **isn't** installed, the OS falls through to an ordinary web request. Before this existed, that request hit a domain with no DNS record at all (or, briefly during setup, a 404 on the wrong site). Now it lands on a real page with the song's content and a prompt to install the app.

## What it is (and isn't)

Deliberately minimal — one static page per song plus a simple index, not a rebuild of the app for the browser:

- `/` — alphabetical list of all songs, linking to each one.
- `/song/{id}/` — title, temple, tune, lyrics, meanings (mirrors what `SongDetailScreen` shows), a link to the Kaumaram.com reference page, and a "Get the full app" banner.
- No search, no categories, no favorites, no bilingual toggle — those stay app-only.

## Generating the site

```bash
python web_app/generate_site.py
```

Pure Python standard library — no `pip install` needed, matching `scripts/build_db.py`'s existing convention (this repo has no Node tooling and no reason to introduce any for a handful of template pages). Reads `assets/thiruppugazh.db` directly and writes static HTML into `web_app/dist/` (gitignored — rebuild whenever the DB changes; Netlify also reruns this as its build command, see below).

Rendering details worth knowing:
- `build_stanza_html()` reproduces `SongDetailScreen._buildLyricsTextSpans()`'s stanza grouping exactly — a blank line every `len(tune_list)` lines — applied separately to Tamil and English lyrics via their own tune lists. Getting this wrong silently flattens the lyrics into one block, which happened once during development; there's no automated check for it, so if you touch this function, diff a song's rendered output against the app before trusting it.
- `.song-meta .value` needs `white-space: pre-line` in `web_app/static/style.css` — the DB's `tune` field contains real `\n` characters, and without that rule they're collapsed by default HTML whitespace handling. What looks like correct line breaks without it is just accidental word-wrap at whatever width you're testing at; verify at a wide viewport if you touch this.
- Styled with the app's actual theme colors (`lib/theme/app_theme.dart` → `AppColors`), including a `prefers-color-scheme: dark` variant, so it doesn't read as a generic fallback page.

## Hosting on Netlify

`netlify.toml` (repo root) is already configured — connect the repo, Netlify auto-detects it:
- `build.command = "python web_app/generate_site.py"`, `build.publish = "web_app/dist"`.
- `runtime.txt` (repo root) pins the Python version for Netlify's build image.
- Custom domain: add `thiruppugazh.ayilavan.org` in the Netlify dashboard, then point a CNAME at the value Netlify gives you (this project's DNS is on nsone.net, not Netlify DNS — use "external DNS", not "Netlify DNS").

**The `.well-known/` gotcha**: Netlify doesn't serve dot-folders directly. `generate_site.py` writes `assetlinks.json` to *both* `.well-known/` and `well-known/` (no dot); `netlify.toml` redirects `/.well-known/*` → `/well-known/:splat` with the correct `Content-Type`. If you migrate hosts, re-verify this — other static hosts may have the same restriction, or may not need the workaround at all.

## `assetlinks.json` / Android App Link verification

Generated automatically with the release signing certificate's SHA-256 fingerprint hardcoded in `generate_site.py` (`RELEASE_CERT_SHA256`). If the release keystore is ever rotated, re-extract and update it:

```bash
keytool -list -v -keystore <path-to-keystore> -alias ayilavan_key | grep SHA256
```

Without a correct, reachable `assetlinks.json`, Android will still let the intent filter match on-device (the app *can* open the link), but the App Link won't be **auto-verified**, meaning Android may show a disambiguation dialog instead of always preferring the app.

iOS's equivalent (`apple-app-site-association`) is **not** generated — the iOS project isn't actually configured yet (`ios/Runner.xcodeproj` still has the default placeholder bundle ID `com.example.thiruppugazh`, no real Apple Developer Team ID). Add it if/when iOS release signing is set up for real.

## Known data issue surfaced while building this

Song 1328 renders oddly on both the web page and in the app itself — see `docs/database.md` → Known Data Issues. Not a web app bug.
