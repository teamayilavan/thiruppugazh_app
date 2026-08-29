"""Extracts word-separated (பதம் பிரித்தது) Tamil and English-easy lyrics
for Thiruppugazh songs from mayuragiri.com.

Produces scripts/output/mayuragiri_lyrics_separated.json, keyed by
kaumaram_id, for manual review. Makes no changes to the Flutter app.
"""

from __future__ import annotations

import argparse
import json
import subprocess
import time
from pathlib import Path

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

    Each language's heading and its stanza paragraphs live inside their
    own `wp-block-column` div (verified against real pages — every
    language section, in every layout variant seen, gets its own column),
    so scoping the paragraph search to that ancestor is what naturally
    stops at the section boundary without pulling in the next language's
    content.

    The heading's content is NOT always its direct `<p>` siblings: some
    pages nest the stanza paragraphs one level deeper inside an extra
    wrapping `<div>` alongside the heading, rather than as siblings of the
    heading itself. Searching the whole column (not just direct siblings)
    handles both shapes.
    """
    heading = find_heading_by_text(soup, heading_text)
    if heading is None:
        return None

    column = heading.find_parent(class_="wp-block-column") or heading.parent
    paragraphs = [p for p in column.find_all("p") if p is not heading]
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


class _CurlResponse:
    def __init__(self, status_code: int, text: str):
        self.status_code = status_code
        self.text = text


_CURL_STATUS_MARKER = "\n__MAYURAGIRI_HTTP_STATUS__:"


def _default_get(url: str, headers: dict, timeout: int):
    """Fetches via a `curl` subprocess rather than `requests`.

    mayuragiri.com's bot protection blocks Python's `requests`/urllib3
    with HTTP 429 even with a matching browser User-Agent header and a
    slow request pace — verified side-by-side: `curl` got 200 for the
    same URL, at the same moment, from the same machine, while `requests`
    got 429. This points at TLS/client fingerprinting rather than a
    request-rate limit, so shelling out to `curl` (whose fingerprint is
    not blocked) is the fix, not a slower pace.
    """
    user_agent = headers.get("User-Agent", "")
    result = subprocess.run(
        [
            "curl",
            "-sL",
            "-A",
            user_agent,
            "--max-time",
            str(timeout),
            "-w",
            _CURL_STATUS_MARKER + "%{http_code}",
            url,
        ],
        capture_output=True,
    )
    stdout = result.stdout.decode("utf-8", errors="replace")
    body, _, status_str = stdout.rpartition(_CURL_STATUS_MARKER)
    status_code = int(status_str) if status_str.strip().isdigit() else 0
    return _CurlResponse(status_code, body)


class RateLimitedFetcher:
    """Fetches Mayuragiri song pages, caching HTML to disk and rate-
    limiting live requests. `get_func` is injectable so tests never hit
    the network; it defaults to a real curl-based fetch (see
    `_default_get`).
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

        if response.status_code == 429:
            # Transient rate-limit response, not a permanent outcome like
            # 404 — don't cache it, so a later run retries this id instead
            # of replaying a stale 429 forever.
            return None, 429

        status_path.write_text(str(response.status_code), encoding="utf-8")
        if response.status_code == 200:
            html_path.write_text(response.text, encoding="utf-8")
            return response.text, 200
        return None, response.status_code


def run(songs_dir: Path, fetcher: RateLimitedFetcher, output_path: Path) -> dict:
    """Scrapes every locally-known song and writes the combined JSON."""
    songs = load_local_songs(songs_dir)
    results: dict[str, dict] = {}

    for kid in sorted(songs, key=int):
        html, status = fetcher.fetch(kid)
        if html is None:
            results[kid] = {
                "mayuragiri_url": f"https://mayuragiri.com/thiruppugal{kid}",
                "lyrics_separated": None,
                "lyrics_separated_line_count_match": None,
                "english_lyrics_separated": None,
                "english_lyrics_separated_line_count_match": None,
                "source_layout": "not_found",
                "http_status": status,
            }
            continue

        record = scrape_song(
            html, kid, songs[kid]["lyrics_list"], songs[kid]["english_lyrics_list"]
        )
        record["http_status"] = status
        results[kid] = record

    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(
        json.dumps(results, ensure_ascii=False, indent=2), encoding="utf-8"
    )
    return results


def print_summary(results: dict) -> None:
    total = len(results)
    ta_found = sum(1 for r in results.values() if r["lyrics_separated"] is not None)
    ta_match = sum(
        1 for r in results.values() if r["lyrics_separated_line_count_match"] is True
    )
    ta_mismatch = sum(
        1 for r in results.values() if r["lyrics_separated_line_count_match"] is False
    )
    en_found = sum(
        1 for r in results.values() if r["english_lyrics_separated"] is not None
    )
    en_match = sum(
        1
        for r in results.values()
        if r["english_lyrics_separated_line_count_match"] is True
    )
    en_mismatch = sum(
        1
        for r in results.values()
        if r["english_lyrics_separated_line_count_match"] is False
    )
    missing = sum(
        1 for r in results.values() if r["source_layout"] in ("missing", "not_found")
    )
    mismatched_ids = sorted(
        (
            kid
            for kid, r in results.items()
            if r["lyrics_separated_line_count_match"] is False
            or r["english_lyrics_separated_line_count_match"] is False
        ),
        key=int,
    )

    print(f"Total songs processed: {total}")
    print(
        f"Tamil lyrics_separated found: {ta_found} "
        f"(matched: {ta_match}, mismatched: {ta_mismatch})"
    )
    print(
        f"English lyrics_separated found: {en_found} "
        f"(matched: {en_match}, mismatched: {en_mismatch})"
    )
    print(f"Songs with no padham section (missing/not_found): {missing}")
    print(f"Mismatched IDs: {mismatched_ids}")


def main(argv: list[str] | None = None) -> None:
    parser = argparse.ArgumentParser(
        description="Scrape mayuragiri.com padham-separated lyrics for all local songs."
    )
    parser.add_argument(
        "--min-interval",
        type=float,
        default=1.0,
        help=(
            "Minimum seconds between live HTTP requests to mayuragiri.com "
            "(default: 1.0). A 1 req/sec pace triggered site-wide HTTP 429 "
            "rate-limiting in practice; a much slower pace (e.g. 60) is "
            "needed for a full run to complete without being blocked."
        ),
    )
    args = parser.parse_args(argv)

    root = Path(__file__).resolve().parent.parent
    fetcher = RateLimitedFetcher(
        root / "scripts" / "mayuragiri_cache", min_interval=args.min_interval
    )
    results = run(
        root / "songs",
        fetcher,
        root / "scripts" / "output" / "mayuragiri_lyrics_separated.json",
    )
    print_summary(results)


if __name__ == "__main__":
    main()
