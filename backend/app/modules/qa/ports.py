"""Ports of the Q&A module. The use case depends only on these protocols, so the
LLM / embedding providers can be swapped (OQ-008) without touching it."""

from dataclasses import dataclass
from typing import Protocol


@dataclass(frozen=True)
class RetrievedChunk:
    filename: str
    page_start: int
    content: str
    sim: float


@dataclass(frozen=True)
class LLMResult:
    text: str
    input_tokens: int = 0
    output_tokens: int = 0


class LLMUnavailable(Exception):
    """The LLM provider failed or timed out; the request may be retried."""


class EmbeddingUnavailable(Exception):
    """The embedding service failed or timed out."""


class EmbeddingPort(Protocol):
    async def embed(self, texts: list[str]) -> list[list[float]]: ...


class RetrievalPort(Protocol):
    async def search(self, qvec: list[float], top_n: int) -> list[RetrievedChunk]: ...


class LLMPort(Protocol):
    async def answer(self, question: str, chunks: list[RetrievedChunk]) -> LLMResult: ...
