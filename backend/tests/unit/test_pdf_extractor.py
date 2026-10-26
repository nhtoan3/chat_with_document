import pytest

from app.modules.documents.ingestion.pdf_extractor import ExtractionError, extract
from tests.fixtures.make_pdfs import (
    SAMPLE_DOCS,
    corrupted_pdf,
    encrypted_pdf,
    many_pages_pdf,
    scanned_pdf,
    text_pdf,
)


def test_text_pdf_keeps_pages_and_vietnamese():
    pages = extract(text_pdf(SAMPLE_DOCS["Hop_dong_khung_ABC_2026.pdf"]), max_pages=300)
    assert [p.number for p in pages] == [1, 2]
    assert "30%" in pages[0].text
    assert "0,05%" in pages[1].text


@pytest.mark.parametrize(
    ("data", "code"),
    [
        (encrypted_pdf(), "encrypted_pdf"),
        (scanned_pdf(), "no_text_layer"),
        (corrupted_pdf(), "corrupted"),
        (b"not a pdf at all", "corrupted"),
    ],
    ids=["encrypted", "scanned", "truncated", "garbage"],
)
def test_rejected_files(data, code):
    with pytest.raises(ExtractionError) as exc:
        extract(data, max_pages=300)
    assert exc.value.code == code


def test_too_many_pages():
    with pytest.raises(ExtractionError) as exc:
        extract(many_pages_pdf(5), max_pages=4)
    assert exc.value.code == "too_many_pages"
