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
