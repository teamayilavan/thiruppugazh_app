import subprocess

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


# Mirrors a real page structure found in the live scrape (e.g. id 216):
# the heading <p> is NOT a direct sibling of the stanza paragraphs — an
# extra wrapping <div class="wp-block-group"> sits between them.
GUTENBERG_NESTED_CONTENT_SECTION = """
<div class="wp-block-column is-layout-flow wp-block-column-is-layout-flow">
<div class="wp-block-group"><div class="wp-block-group__inner-container is-layout-flow wp-block-group-is-layout-flow">
<div class="wp-block-group"><div class="wp-block-group__inner-container is-layout-flow wp-block-group-is-layout-flow">
<p class="has-text-align-left has-medium-font-size wp-block-paragraph">
<strong><mark class="has-inline-color has-vivid-red-color">பதம் பிரித்தது</mark></strong></p>
<div class="wp-block-group"><div class="wp-block-group__inner-container is-layout-flow wp-block-group-is-layout-flow">
<p class="has-text-color wp-block-paragraph" style="color:#00058c"><strong>meter line</strong></p>
<p class="wp-block-paragraph"><strong>nested lyric one<br>nested lyric two</strong></p>
</div></div>
</div></div>
</div></div>
</div>
<div class="wp-block-column is-layout-flow wp-block-column-is-layout-flow">
<div class="wp-block-group"><div class="wp-block-group__inner-container is-layout-flow wp-block-group-is-layout-flow">
<p class="has-vivid-red-color has-text-color has-medium-font-size wp-block-paragraph"><strong><strong><em>English</em></strong></strong></p>
<p class="wp-block-paragraph">should not be included</p>
</div></div>
</div>
"""


def test_extract_section_finds_nested_content_not_just_direct_siblings():
    soup = BeautifulSoup(GUTENBERG_NESTED_CONTENT_SECTION, "html.parser")
    assert extract_section(soup, "பதம் பிரித்தது") == [
        "nested lyric one",
        "nested lyric two",
    ]


def test_extract_section_nested_content_stops_at_next_column():
    soup = BeautifulSoup(GUTENBERG_NESTED_CONTENT_SECTION, "html.parser")
    lines = extract_section(soup, "பதம் பிரித்தது")
    assert "should not be included" not in lines


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


import json

from mayuragiri_scraper import load_local_songs


def test_load_local_songs_reads_lyrics_list_and_filters_blank_english(tmp_path):
    songs_dir = tmp_path / "songs"
    songs_dir.mkdir()
    (songs_dir / "0014.json").write_text(
        json.dumps(
            {
                "kaumaram_id": "14",
                "lyrics_list": ["a", "b"],
                "english_lyrics": ["x", "", "y", ""],
            }
        ),
        encoding="utf-8",
    )
    (songs_dir / "0007.json").write_text(
        json.dumps({"kaumaram_id": "7", "lyrics_list": ["c"]}), encoding="utf-8"
    )

    songs = load_local_songs(songs_dir)

    assert songs["14"] == {
        "lyrics_list": ["a", "b"],
        "english_lyrics_list": ["x", "y"],
    }
    assert songs["7"] == {"lyrics_list": ["c"], "english_lyrics_list": None}


from mayuragiri_scraper import RateLimitedFetcher


class _FakeResponse:
    def __init__(self, status_code: int, text: str = ""):
        self.status_code = status_code
        self.text = text


def test_fetch_caches_html_and_reuses_cache_on_second_call(tmp_path):
    calls = []

    def fake_get(url, headers, timeout):
        calls.append(url)
        return _FakeResponse(200, "<html>page content</html>")

    fetcher = RateLimitedFetcher(tmp_path / "cache", min_interval=0, get_func=fake_get)

    html1, status1 = fetcher.fetch("14")
    html2, status2 = fetcher.fetch("14")

    assert html1 == "<html>page content</html>"
    assert status1 == 200
    assert html2 == html1
    assert status2 == 200
    assert calls == ["https://mayuragiri.com/thiruppugal14"]  # fetched once, cached after
    assert (tmp_path / "cache" / "14.html").exists()


def test_fetch_returns_none_and_caches_404(tmp_path):
    calls = []

    def fake_get(url, headers, timeout):
        calls.append(url)
        return _FakeResponse(404, "not found")

    fetcher = RateLimitedFetcher(tmp_path / "cache", min_interval=0, get_func=fake_get)

    html1, status1 = fetcher.fetch("1340")
    html2, status2 = fetcher.fetch("1340")

    assert html1 is None
    assert status1 == 404
    assert html2 is None
    assert status2 == 404
    assert calls == ["https://mayuragiri.com/thiruppugal1340"]  # 404 cached too


def test_fetch_does_not_cache_429_and_retries_on_next_call(tmp_path):
    # A 429 is a transient rate-limit response, not a permanent outcome
    # like 404 — caching it to disk would make every future run replay a
    # stale 429 forever instead of retrying once the site's limit clears.
    calls = []

    def fake_get(url, headers, timeout):
        calls.append(url)
        return _FakeResponse(429, "rate limited")

    fetcher = RateLimitedFetcher(tmp_path / "cache", min_interval=0, get_func=fake_get)

    html1, status1 = fetcher.fetch("7")
    html2, status2 = fetcher.fetch("7")

    assert html1 is None
    assert status1 == 429
    assert html2 is None
    assert status2 == 429
    assert calls == [
        "https://mayuragiri.com/thiruppugal7",
        "https://mayuragiri.com/thiruppugal7",
    ]  # not cached, so the second fetch() call retried over the network
    assert not (tmp_path / "cache" / "7.status").exists()
    assert not (tmp_path / "cache" / "7.html").exists()


def test_fetch_does_not_cache_curl_failure_and_retries_on_next_call(tmp_path):
    # curl reports a connection failure (timeout, DNS failure, connection
    # reset, etc.) as %{http_code} 000, which _default_get parses as status
    # 0. That's a transient local/network failure, not a real "page doesn't
    # exist" — caching it to disk would make every future run replay a
    # stale 0 forever instead of retrying once the network issue clears.
    calls = []

    def fake_get(url, headers, timeout):
        calls.append(url)
        return _FakeResponse(0, "")

    fetcher = RateLimitedFetcher(tmp_path / "cache", min_interval=0, get_func=fake_get)

    html1, status1 = fetcher.fetch("7")
    html2, status2 = fetcher.fetch("7")

    assert html1 is None
    assert status1 == 0
    assert html2 is None
    assert status2 == 0
    assert calls == [
        "https://mayuragiri.com/thiruppugal7",
        "https://mayuragiri.com/thiruppugal7",
    ]  # not cached, so the second fetch() call retried over the network
    assert not (tmp_path / "cache" / "7.status").exists()
    assert not (tmp_path / "cache" / "7.html").exists()


def test_fetch_builds_unpadded_url(tmp_path):
    seen_urls = []

    def fake_get(url, headers, timeout):
        seen_urls.append(url)
        return _FakeResponse(200, "ok")

    fetcher = RateLimitedFetcher(tmp_path / "cache", min_interval=0, get_func=fake_get)
    fetcher.fetch("14")

    assert seen_urls == ["https://mayuragiri.com/thiruppugal14"]


from mayuragiri_scraper import print_summary, run


def test_run_writes_output_json_and_returns_results(tmp_path, capsys):
    songs_dir = tmp_path / "songs"
    songs_dir.mkdir()
    (songs_dir / "0014.json").write_text(
        json.dumps({"kaumaram_id": "14", "lyrics_list": ["line one", "line two"]}),
        encoding="utf-8",
    )
    (songs_dir / "1340.json").write_text(
        json.dumps({"kaumaram_id": "1340", "lyrics_list": ["only line"]}),
        encoding="utf-8",
    )

    def fake_get(url, headers, timeout):
        if "1340" in url:
            return _FakeResponse(404, "not found")
        return _FakeResponse(200, SONG_14_STYLE_HTML)

    fetcher = RateLimitedFetcher(tmp_path / "cache", min_interval=0, get_func=fake_get)
    output_path = tmp_path / "output" / "mayuragiri_lyrics_separated.json"

    results = run(songs_dir, fetcher, output_path)

    assert output_path.exists()
    written = json.loads(output_path.read_text(encoding="utf-8"))
    assert written == results
    assert results["14"]["lyrics_separated"] == ["line one", "line two"]
    assert results["14"]["lyrics_separated_line_count_match"] is True
    assert results["1340"]["source_layout"] == "not_found"
    assert results["1340"]["lyrics_separated"] is None


def test_print_summary_reports_counts_and_mismatches(capsys):
    results = {
        "14": {
            "lyrics_separated": ["a", "b"],
            "lyrics_separated_line_count_match": True,
            "english_lyrics_separated": None,
            "english_lyrics_separated_line_count_match": None,
            "source_layout": "legacy",
        },
        "15": {
            "lyrics_separated": ["a"],
            "lyrics_separated_line_count_match": False,
            "english_lyrics_separated": ["x"],
            "english_lyrics_separated_line_count_match": True,
            "source_layout": "gutenberg",
        },
        "1340": {
            "lyrics_separated": None,
            "lyrics_separated_line_count_match": None,
            "english_lyrics_separated": None,
            "english_lyrics_separated_line_count_match": None,
            "source_layout": "not_found",
        },
    }

    print_summary(results)

    out = capsys.readouterr().out
    assert "Total songs processed: 3" in out
    assert "Tamil lyrics_separated found: 2 (matched: 1, mismatched: 1)" in out
    assert "English lyrics_separated found: 1 (matched: 1, mismatched: 0)" in out
    assert "Songs with no padham section (missing/not_found): 1" in out
    assert "['15']" in out


from mayuragiri_scraper import _default_get


def test_default_get_parses_curl_status_and_body(monkeypatch):
    captured_args = []

    class _FakeCompletedProcess:
        stdout = "<html>body text</html>\n__MAYURAGIRI_HTTP_STATUS__:200".encode(
            "utf-8"
        )

    def fake_run(args, capture_output):
        captured_args.append(args)
        assert capture_output is True
        return _FakeCompletedProcess()

    monkeypatch.setattr(subprocess, "run", fake_run)

    response = _default_get(
        "https://mayuragiri.com/thiruppugal14", {"User-Agent": "test-agent"}, 30
    )

    assert response.status_code == 200
    assert response.text == "<html>body text</html>"
    args = captured_args[0]
    assert args[0] == "curl"
    assert "-A" in args and args[args.index("-A") + 1] == "test-agent"
    assert "--max-time" in args and args[args.index("--max-time") + 1] == "30"
    assert args[-1] == "https://mayuragiri.com/thiruppugal14"


def test_default_get_parses_non_200_status(monkeypatch):
    class _FakeCompletedProcess:
        stdout = "\n__MAYURAGIRI_HTTP_STATUS__:429".encode("utf-8")

    monkeypatch.setattr(
        subprocess, "run", lambda args, capture_output: _FakeCompletedProcess()
    )

    response = _default_get("https://mayuragiri.com/thiruppugal14", {}, 30)

    assert response.status_code == 429
    assert response.text == ""
