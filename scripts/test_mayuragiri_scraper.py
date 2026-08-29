from bs4 import BeautifulSoup

from mayuragiri_scraper import split_paragraph_into_lines, determine_source_layout, find_heading_by_text


def _first_p(html: str):
    return BeautifulSoup(html, "html.parser").find("p")


def test_splits_on_br_when_lines_are_span_wrapped():
    html = (
        "<p><span style='color:#67009b'><strong>line one</strong></span>"
        "<br /><span style='color:#67009b'><strong>line two</strong></span>"
        "<br /><span style='color:#67009b'><strong>line three</strong></span></p>"
    )
    assert split_paragraph_into_lines(_first_p(html)) == [
        "line one",
        "line two",
        "line three",
    ]


def test_splits_on_br_when_lines_are_bare_strong():
    html = "<p><strong>line one</strong><br /><strong>line two</strong></p>"
    assert split_paragraph_into_lines(_first_p(html)) == ["line one", "line two"]


def test_splits_on_br_without_closing_slash():
    html = "<p>line one<br>line two<br>line three</p>"
    assert split_paragraph_into_lines(_first_p(html)) == [
        "line one",
        "line two",
        "line three",
    ]


def test_decodes_entities_and_strips_nbsp():
    html = "<p>vasamAki &#8211; thiRamAvE<br>&nbsp;&nbsp;second line&nbsp;</p>"
    assert split_paragraph_into_lines(_first_p(html)) == [
        "vasamAki – thiRamAvE",
        "second line",
    ]


def test_drops_empty_lines():
    html = "<p>line one<br><br>line two</p>"
    assert split_paragraph_into_lines(_first_p(html)) == ["line one", "line two"]


LEGACY_FRAGMENT = """
<div class="wp-block-column is-layout-flow wp-block-column-is-layout-flow">
<h3 style="text-align: center;"><span style="color: #a10000;">பதம் பிரித்தது</span></h3>
<p><span style="color: #0000d6;"><strong>meter line</strong></span></p>
<p><span style="color: #67009b;"><strong>lyric line one</strong></span></p>
</div>
"""

GUTENBERG_FRAGMENT = """
<div class="wp-block-column is-layout-flow wp-block-column-is-layout-flow">
<p class="has-text-align-left has-medium-font-size wp-block-paragraph">
<strong><mark style="background-color:rgba(0, 0, 0, 0)" class="has-inline-color has-vivid-red-color">பதம் பிரித்தது</mark></strong></p>
<p class="wp-block-paragraph"><strong>meter line</strong></p>
<p class="wp-block-paragraph"><strong>lyric line one</strong></p>
</div>
"""

MISSING_FRAGMENT = """
<div class="wp-block-column is-layout-flow wp-block-column-is-layout-flow">
<h3 style="text-align: center;"><span style="color: #a10000;">பாடல்</span></h3>
<p><span><strong>meter line</strong></span></p>
</div>
"""

NAV_BREADCRUMB_FRAGMENT = """
<li><a href="#">திருப்புகழ் பாடல்கள் எண் வரிசைப் பட்டியல் (பதம் பிரித்தது)</a></li>
<div class="wp-block-column">
<h3><span>பதம் பிரித்தது</span></h3>
<p><strong>meter line</strong></p>
</div>
"""


def test_finds_legacy_h3_span_heading():
    soup = BeautifulSoup(LEGACY_FRAGMENT, "html.parser")
    heading = find_heading_by_text(soup, "பதம் பிரித்தது")
    assert heading is not None
    assert heading.name == "h3"


def test_finds_gutenberg_p_mark_heading():
    soup = BeautifulSoup(GUTENBERG_FRAGMENT, "html.parser")
    heading = find_heading_by_text(soup, "பதம் பிரித்தது")
    assert heading is not None
    assert heading.name == "p"


def test_returns_none_when_heading_absent():
    soup = BeautifulSoup(MISSING_FRAGMENT, "html.parser")
    assert find_heading_by_text(soup, "பதம் பிரித்தது") is None


def test_ignores_nav_breadcrumb_substring_match():
    # The site nav contains "... (பதம் பிரித்தது)" as part of a longer
    # breadcrumb string — must not match that, only the exact heading text.
    soup = BeautifulSoup(NAV_BREADCRUMB_FRAGMENT, "html.parser")
    heading = find_heading_by_text(soup, "பதம் பிரித்தது")
    assert heading is not None
    assert heading.name == "h3"


def test_detects_legacy_layout():
    soup = BeautifulSoup(LEGACY_FRAGMENT, "html.parser")
    assert determine_source_layout(soup) == "legacy"


def test_detects_gutenberg_layout():
    soup = BeautifulSoup(GUTENBERG_FRAGMENT, "html.parser")
    assert determine_source_layout(soup) == "gutenberg"


def test_detects_missing_layout():
    soup = BeautifulSoup(MISSING_FRAGMENT, "html.parser")
    assert determine_source_layout(soup) == "missing"


from mayuragiri_scraper import extract_section

LEGACY_FULL_SECTION = """
<div class="wp-block-column is-layout-flow wp-block-column-is-layout-flow">
<h3 style="text-align: center;"><span style="color: #a10000;">பதம் பிரித்தது</span></h3>
<p><span style="color: #0000d6;"><strong>தனதந்தன தந்தன தந்தன</strong></span></p>
<p><span style="color: #67009b;"><strong>சருவும்படி வந்தனன்</strong></span><br /><span style="color: #67009b;"><strong>மதன் நின்றிட</strong></span></p>
<p><strong>சயிலம் கொளும் மன்றல்</strong><br /><strong>பொழிலின் பயில்</strong></p>
</div>
<div class="wp-block-column is-layout-flow wp-block-column-is-layout-flow">
<h3 style="text-align: center;"><strong><span style="color: #a10000;">English</span></strong></h3>
<p><span><strong>should not be included</strong></span></p>
</div>
"""

GUTENBERG_FULL_SECTION = """
<div class="wp-block-column is-layout-flow wp-block-column-is-layout-flow">
<div class="wp-block-group"><div class="wp-block-group__inner-container is-layout-flow wp-block-group-is-layout-flow">
<p class="has-text-align-left has-medium-font-size wp-block-paragraph">
<strong><mark class="has-inline-color has-vivid-red-color">பதம் பிரித்தது</mark></strong></p>
<p class="has-text-color wp-block-paragraph" style="color:#00058c"><strong>meter line</strong></p>
<p class="wp-block-paragraph"><strong>lyric one<br>lyric two</strong><br><strong>lyric three</strong></p>
<p class="wp-block-paragraph">lyric four<br>lyric five</p>
</div></div>
</div>
<div class="wp-block-column is-layout-flow wp-block-column-is-layout-flow">
<div class="wp-block-group"><div class="wp-block-group__inner-container is-layout-flow wp-block-group-is-layout-flow">
<p class="has-vivid-red-color has-text-color has-medium-font-size wp-block-paragraph"><strong><strong><em>English</em></strong></strong></p>
<p class="wp-block-paragraph">should not be included</p>
</div></div>
</div>
"""


def test_extract_section_drops_meter_line_legacy():
    soup = BeautifulSoup(LEGACY_FULL_SECTION, "html.parser")
    assert extract_section(soup, "பதம் பிரித்தது") == [
        "சருவும்படி வந்தனன்",
        "மதன் நின்றிட",
        "சயிலம் கொளும் மன்றல்",
        "பொழிலின் பயில்",
    ]


def test_extract_section_stops_at_next_column_legacy():
    soup = BeautifulSoup(LEGACY_FULL_SECTION, "html.parser")
    lines = extract_section(soup, "பதம் பிரித்தது")
    assert "should not be included" not in lines


def test_extract_section_drops_meter_line_gutenberg():
    soup = BeautifulSoup(GUTENBERG_FULL_SECTION, "html.parser")
    assert extract_section(soup, "பதம் பிரித்தது") == [
        "lyric one",
        "lyric two",
        "lyric three",
        "lyric four",
        "lyric five",
    ]


def test_extract_section_stops_at_next_column_gutenberg():
    soup = BeautifulSoup(GUTENBERG_FULL_SECTION, "html.parser")
    lines = extract_section(soup, "பதம் பிரித்தது")
    assert "should not be included" not in lines


def test_extract_section_returns_none_when_heading_missing():
    soup = BeautifulSoup(MISSING_FRAGMENT, "html.parser")
    assert extract_section(soup, "பதம் பிரித்தது") is None


def test_extract_section_returns_none_when_only_meter_line_present():
    html = """
    <div><h3><span>பதம் பிரித்தது</span></h3>
    <p><strong>only the meter line</strong></p></div>
    """
    soup = BeautifulSoup(html, "html.parser")
    assert extract_section(soup, "பதம் பிரித்தது") is None


from mayuragiri_scraper import scrape_song

SONG_14_STYLE_HTML = """
<div class="wp-block-column is-layout-flow wp-block-column-is-layout-flow">
<h3 style="text-align: center;"><span style="color: #a10000;">பதம் பிரித்தது</span></h3>
<p><span><strong>meter</strong></span></p>
<p><span><strong>line one</strong></span><br /><span><strong>line two</strong></span></p>
</div>
<div class="wp-block-column is-layout-flow wp-block-column-is-layout-flow">
<h3 style="text-align: center;"><span style="color: #a10000;">English Easy Version</span></h3>
<p><span><strong>meter</strong></span></p>
<p><span><strong>english one</strong></span><br /><span><strong>english two</strong></span></p>
</div>
"""


def test_scrape_song_matching_line_counts():
    result = scrape_song(SONG_14_STYLE_HTML, "14", ["a", "b"], ["x", "y"])
    assert result == {
        "mayuragiri_url": "https://mayuragiri.com/thiruppugal14",
        "lyrics_separated": ["line one", "line two"],
        "lyrics_separated_line_count_match": True,
        "english_lyrics_separated": ["english one", "english two"],
        "english_lyrics_separated_line_count_match": True,
        "source_layout": "legacy",
    }


def test_scrape_song_mismatched_line_count_is_stored_and_flagged():
    result = scrape_song(SONG_14_STYLE_HTML, "14", ["a", "b", "c"], ["x", "y"])
    assert result["lyrics_separated"] == ["line one", "line two"]
    assert result["lyrics_separated_line_count_match"] is False


def test_scrape_song_no_local_english_list_gives_none_match():
    result = scrape_song(SONG_14_STYLE_HTML, "14", ["a", "b"], None)
    assert result["english_lyrics_separated"] == ["english one", "english two"]
    assert result["english_lyrics_separated_line_count_match"] is None


def test_scrape_song_no_sections_present():
    html = "<div><h3><span>பாடல்</span></h3><p><strong>x</strong></p></div>"
    result = scrape_song(html, "999", ["a"], ["x"])
    assert result == {
        "mayuragiri_url": "https://mayuragiri.com/thiruppugal999",
        "lyrics_separated": None,
        "lyrics_separated_line_count_match": None,
        "english_lyrics_separated": None,
        "english_lyrics_separated_line_count_match": None,
        "source_layout": "missing",
    }
