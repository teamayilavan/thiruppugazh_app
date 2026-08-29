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
