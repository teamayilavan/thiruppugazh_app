"""Extracts word-separated (பதம் பிரித்தது) Tamil and English-easy lyrics
for Thiruppugazh songs from mayuragiri.com.

Produces scripts/output/mayuragiri_lyrics_separated.json, keyed by
kaumaram_id, for manual review. Makes no changes to the Flutter app.
"""

from __future__ import annotations

import json
import time
from pathlib import Path

import requests
from bs4 import BeautifulSoup, Tag

USER_AGENT = (
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 "
    "(KHTML, like Gecko) Chrome/120.0 Safari/537.36"
)


def split_paragraph_into_lines(p_tag: Tag) -> list[str]:
    """Splits a <p> tag's text into lines on <br>/<br/> boundaries.

    Works whether or not each line is wrapped in <span>/<strong> — the
    site alternates between wrapping lines in <span> and leaving them bare,
    so <br> is the only reliable line boundary.
    """
    p_soup = BeautifulSoup(str(p_tag), "html.parser")
    for br in p_soup.find_all("br"):
        br.replace_with("\n")
    text = p_soup.get_text().replace("\xa0", " ")
    lines = [line.strip() for line in text.split("\n")]
    return [line for line in lines if line]


_HEADING_CANDIDATE_TAGS = ["h2", "h3", "h4", "p", "mark", "span"]


def find_heading_by_text(soup: BeautifulSoup, text: str) -> Tag | None:
    """Finds the first tag whose exact stripped text matches `text`.

    Deliberately not anchored to a fixed tag/class — the site uses an
    <h3><span> heading on older pages and a <p><strong><mark> heading on
    newer ones. Matching on exact text (not substring) also avoids the
    site's nav breadcrumb, which contains this text as part of a longer
    string.
    """
    target = text.strip()
    for tag in soup.find_all(_HEADING_CANDIDATE_TAGS):
        if tag.get_text(strip=True) == target:
            return tag
    return None


def determine_source_layout(soup: BeautifulSoup) -> str:
    """Classifies which page template rendered the பதம் பிரித்தது section.

    QA/debugging field only — never shipped into the app database.
    """
    heading = find_heading_by_text(soup, "பதம் பிரித்தது")
    if heading is None:
        return "missing"
    return "legacy" if heading.name == "h3" else "gutenberg"


def extract_section(soup: BeautifulSoup, heading_text: str) -> list[str] | None:
    """Extracts all lyric lines under a heading, dropping the meter line.

    The heading's subsequent <p> siblings (within its own immediate
    parent) are exactly the section's content on both known page layouts:
    the meter line first, then one or more stanza paragraphs. This also
    naturally stops at the section boundary, since the next language's
    heading and paragraphs live in a sibling container, not as further
    siblings of this heading.
    """
    heading = find_heading_by_text(soup, heading_text)
    if heading is None:
        return None

    paragraphs = heading.find_next_siblings("p")
    if len(paragraphs) <= 1:
        return None

    lines: list[str] = []
    for p in paragraphs[1:]:
        lines.extend(split_paragraph_into_lines(p))
    return lines if lines else None


def _line_count_match(
    extracted: list[str] | None, local: list[str] | None
) -> bool | None:
    if extracted is None or local is None:
        return None
    return len(extracted) == len(local)


def scrape_song(
    html: str,
    kaumaram_id: str,
    local_lyrics_list: list[str] | None,
    local_english_lyrics_list: list[str] | None,
) -> dict:
    """Extracts one song's Mayuragiri data from its already-fetched HTML.

    Never raises on missing sections — absence is represented as None
    fields, and line-count mismatches are stored anyway with their match
    flag set to False (per the "store + flag for review" decision), so a
    parsing surprise on one song can't silently drop its data or crash the
    batch run.
    """
    soup = BeautifulSoup(html, "html.parser")
    lyrics_separated = extract_section(soup, "பதம் பிரித்தது")
    english_lyrics_separated = extract_section(soup, "English Easy Version")

    return {
        "mayuragiri_url": f"https://mayuragiri.com/thiruppugal{kaumaram_id}",
        "lyrics_separated": lyrics_separated,
        "lyrics_separated_line_count_match": _line_count_match(
            lyrics_separated, local_lyrics_list
        ),
        "english_lyrics_separated": english_lyrics_separated,
        "english_lyrics_separated_line_count_match": _line_count_match(
            english_lyrics_separated, local_english_lyrics_list
        ),
        "source_layout": determine_source_layout(soup),
    }


def load_local_songs(songs_dir: Path) -> dict[str, dict]:
    """Reads songs/*.json to get each song's kaumaram_id and local lyric
    line counts, used to validate the scraped data against.
    """
    songs: dict[str, dict] = {}
    for f in sorted(songs_dir.glob("*.json")):
        data = json.loads(f.read_text(encoding="utf-8"))
        kid = str(data.get("kaumaram_id"))
        en_raw = data.get("english_lyrics")
        en_list = [line for line in en_raw if line != ""] if en_raw is not None else None
        songs[kid] = {
            "lyrics_list": data.get("lyrics_list", []),
            "english_lyrics_list": en_list,
        }
    return songs


def _default_get(url: str, headers: dict, timeout: int):
    return requests.get(url, headers=headers, timeout=timeout)


class RateLimitedFetcher:
    """Fetches Mayuragiri song pages, caching HTML to disk and rate-
    limiting live requests. `get_func` is injectable so tests never hit
    the network; it defaults to a real `requests.get` call.
    """

    def __init__(
        self,
        cache_dir: Path,
        min_interval: float = 1.0,
        get_func=None,
    ):
        self.cache_dir = cache_dir
        self.cache_dir.mkdir(parents=True, exist_ok=True)
        self.min_interval = min_interval
        self.get_func = get_func or _default_get
        self._last_request_time = 0.0

    def fetch(self, kaumaram_id: str) -> tuple[str | None, int]:
        html_path = self.cache_dir / f"{kaumaram_id}.html"
        status_path = self.cache_dir / f"{kaumaram_id}.status"

        if status_path.exists():
            status = int(status_path.read_text().strip())
            html = html_path.read_text(encoding="utf-8") if status == 200 else None
            return html, status

        elapsed = time.monotonic() - self._last_request_time
        if elapsed < self.min_interval:
            time.sleep(self.min_interval - elapsed)

        url = f"https://mayuragiri.com/thiruppugal{kaumaram_id}"
        response = self.get_func(url, {"User-Agent": USER_AGENT}, 30)
        self._last_request_time = time.monotonic()

        status_path.write_text(str(response.status_code), encoding="utf-8")
        if response.status_code == 200:
            html_path.write_text(response.text, encoding="utf-8")
            return response.text, 200
        return None, response.status_code
