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
