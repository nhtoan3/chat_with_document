from app.modules.documents.ingestion.chunker import chunk_pages
from app.modules.documents.ingestion.pdf_extractor import ExtractedPage


def words(text: str) -> int:  # simple token counter for tests: 1 word = 1 token
    return len(text.split())


def sentence(i: int, n: int = 20) -> str:
    return " ".join(f"w{i}_{j}" for j in range(n - 1)) + " end."


def test_long_page_is_split_within_limits_and_overlaps():
    page = ExtractedPage(1, " ".join(sentence(i) for i in range(150)))  # ~3000 tokens
    chunks = chunk_pages([page], "a.pdf", target=500, max_tokens=800, overlap=75, count=words)
    assert len(chunks) >= 5
    assert all(c.token_count <= 800 for c in chunks)
    assert all(c.page_start == c.page_end == 1 for c in chunks)
    # consecutive chunks share text (overlap)
    assert chunks[0].content.split()[-1] in chunks[1].content
    assert [c.index for c in chunks] == list(range(len(chunks)))


def test_short_pages_are_merged_with_next():
    pages = [ExtractedPage(1, "ngắn " * 30), ExtractedPage(2, "ngắn " * 30), ExtractedPage(3, "dài " * 200)]
    chunks = chunk_pages(pages, "b.pdf", count=words)
    assert len(chunks) == 1
    assert (chunks[0].page_start, chunks[0].page_end) == (1, 3)


def test_chunks_never_span_two_normal_pages():
    pages = [ExtractedPage(1, "một " * 300), ExtractedPage(2, "hai " * 300)]
    chunks = chunk_pages(pages, "c.pdf", count=words)
    assert [(c.page_start, c.page_end) for c in chunks] == [(1, 1), (2, 2)]


def test_empty_pages_skipped_and_embed_text_has_prefix():
    pages = [ExtractedPage(1, ""), ExtractedPage(2, "nội dung " * 100)]
    chunks = chunk_pages(pages, "Hop_dong.pdf", count=words)
    assert len(chunks) == 1
    assert chunks[0].embed_text.startswith("Hop_dong.pdf — trang 2: ")
    assert not chunks[0].content.startswith("Hop_dong.pdf")
