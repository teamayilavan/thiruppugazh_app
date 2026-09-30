import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))

from build_db import extract_mayuragiri_patch


def test_extracts_both_languages_when_present():
    mayuragiri_data = {
        "14": {
            "mayuragiri_url": "https://mayuragiri.com/thiruppugal14",
            "lyrics_separated": ["tamil line one", "tamil line two"],
            "lyrics_separated_line_count_match": True,
            "english_lyrics_separated": ["english line one"],
            "english_lyrics_separated_line_count_match": False,
            "source_layout": "legacy",
        }
    }
    patch = extract_mayuragiri_patch("14", mayuragiri_data)
    assert patch == {
        "mayuragiri_lyrics_separated": '["tamil line one", "tamil line two"]',
        "mayuragiri_english_lyrics_separated": '["english line one"]',
    }


def test_extracts_tamil_only_when_english_absent():
    mayuragiri_data = {
        "999": {
            "lyrics_separated": ["only tamil"],
            "english_lyrics_separated": None,
        }
    }
    patch = extract_mayuragiri_patch("999", mayuragiri_data)
    assert patch == {
        "mayuragiri_lyrics_separated": '["only tamil"]',
        "mayuragiri_english_lyrics_separated": None,
    }


def test_returns_none_when_song_not_in_mayuragiri_data():
    patch = extract_mayuragiri_patch("777", {})
    assert patch is None


def test_returns_none_when_both_languages_absent():
    mayuragiri_data = {
        "1330": {"lyrics_separated": None, "english_lyrics_separated": None}
    }
    patch = extract_mayuragiri_patch("1330", mayuragiri_data)
    assert patch is None


def test_song_fix_patch_covers_only_the_corrected_columns():
    from build_db import SONG_FIX_COLUMNS_V5, extract_song_fix_patch, extract_song_row

    row = extract_song_row({
        "kaumaram_id": "1338", "title": "t", "lyrics": "a\nb", "tune": "x",
        "tune_list": ["x"], "lyrics_list": ["a", "b"], "place": "p",
    })
    patch = extract_song_fix_patch(row)
    assert list(patch) == SONG_FIX_COLUMNS_V5
    assert "is_favorite" not in patch
    assert patch["lyrics"] == "a\nb"
