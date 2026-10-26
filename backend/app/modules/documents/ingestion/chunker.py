"""Page-aware chunker (T-012, ADR-006).

- A chunk never spans two pages, except that pages shorter than MIN_PAGE_TOKENS
  are merged with the following page.
- Long pages are split by paragraph, then by sentence, aiming at `target`
  tokens and never exceeding `max_tokens`; consecutive chunks of the same page
  overlap by `overlap` tokens.
"""

import re
from collections.abc import Callable, Sequence
from dataclasses import dataclass
from functools import lru_cache

from app.modules.documents.ingestion.pdf_extractor import ExtractedPage

MIN_PAGE_TOKENS = 80
_SENTENCE_SPLIT = re.compile(r"(?<=[.!?…])\s+")

TokenCounter = Callable[[str], int]


@dataclass(frozen=True)
class Chunk:
    index: int
    page_start: int
    page_end: int
    content: str
    embed_text: str
    token_count: int


@lru_cache
def _bge_tokenizer():
    from tokenizers import Tokenizer

    return Tokenizer.from_pretrained("BAAI/bge-m3")


def bge_token_counter(text: str) -> int:
    return len(_bge_tokenizer().encode(text, add_special_tokens=False).ids)


def _split_units(text: str) -> list[str]:
    """Paragraphs first; paragraphs that are still long are split into sentences."""
    units: list[str] = []
    for para in (p.strip() for p in text.split("\n\n")):
        if not para:
            continue
        units.extend(s.strip() for s in _SENTENCE_SPLIT.split(para) if s.strip())
    return units


def _hard_split(unit: str, max_tokens: int, count: TokenCounter) -> list[str]:
    """Split a single over-long sentence by words."""
    words = unit.split()
    parts: list[str] = []
    current: list[str] = []
    for word in words:
        candidate = " ".join([*current, word])
        if current and count(candidate) > max_tokens:
            parts.append(" ".join(current))
            current = [word]
        else:
            current.append(word)
    if current:
        parts.append(" ".join(current))
    return parts


def _tail(text: str, overlap: int, count: TokenCounter) -> str:
    """Last ~`overlap` tokens of text, cut on a word boundary."""
    words = text.split()
    tail: list[str] = []
    for word in reversed(words):
        if count(" ".join([word, *tail])) > overlap:
            break
        tail.insert(0, word)
    return " ".join(tail)


def _merge_short_pages(pages: Sequence[ExtractedPage], count: TokenCounter) -> list[tuple[int, int, str]]:
    """Returns (page_start, page_end, text) groups; short pages join the next page."""
    groups: list[tuple[int, int, str]] = []
    pending: tuple[int, str] | None = None
    for page in pages:
        if not page.text.strip():
            continue
        start, text = (pending[0], f"{pending[1]}\n\n{page.text}") if pending else (page.number, page.text)
        if count(text) < MIN_PAGE_TOKENS and page is not pages[-1]:
            pending = (start, text)
            continue
        groups.append((start, page.number, text))
        pending = None
    if pending:
        groups.append((pending[0], pages[-1].number, pending[1]))
    return groups


def chunk_pages(
    pages: Sequence[ExtractedPage],
    filename: str,
    target: int = 500,
    max_tokens: int = 800,
    overlap: int = 75,
    count: TokenCounter = bge_token_counter,
) -> list[Chunk]:
    chunks: list[Chunk] = []

    def emit(page_start: int, page_end: int, content: str) -> None:
        content = content.strip()
        if not content:
            return
        chunks.append(
            Chunk(
                index=len(chunks),
                page_start=page_start,
                page_end=page_end,
                content=content,
                embed_text=f"{filename} — trang {page_start}: {content}",
                token_count=max(1, count(content)),
            )
        )

    for page_start, page_end, text in _merge_short_pages(pages, count):
        if count(text) <= max_tokens:
            emit(page_start, page_end, text)
            continue

        limit = max_tokens - overlap
        units: list[str] = []
        for unit in _split_units(text):
            units.extend(_hard_split(unit, limit, count) if count(unit) > limit else [unit])

        current = ""
        for unit in units:
            candidate = f"{current} {unit}".strip()
            if current and count(candidate) > target:
                emit(page_start, page_end, current)
                prefix = _tail(current, overlap, count)
                candidate = f"{prefix} {unit}".strip()
                if count(candidate) > max_tokens:
                    candidate = unit
            current = candidate
        emit(page_start, page_end, current)

    return chunks
