from bs4 import BeautifulSoup

from mayuragiri_scraper import split_paragraph_into_lines


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
