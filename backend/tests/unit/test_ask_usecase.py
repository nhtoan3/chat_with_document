import pytest

from app.modules.qa.application.ask import NoReadyDocuments, QuestionInvalid, ask
from app.modules.qa.ports import RetrievedChunk
from app.modules.qa.prompts import SYSTEM_PROMPT, build_user_message
from tests.fakes.fakes import FakeEmbedder, FakeLLM


class FakeRetriever:
    async def search(self, qvec, top_n):
        return [RetrievedChunk("a.pdf", 3, "Nội dung A", 0.9)][:top_n]


async def run(question="Hỏi gì đó?", ready=1, embedder=None, llm=None):
    return await ask(
        question,
        ready_documents=ready,
        embedder=embedder or FakeEmbedder(),
        retriever=FakeRetriever(),
        llm=llm or FakeLLM(),
        top_n=12,
    )


async def test_ok_outcome():
    llm = FakeLLM("Trả lời.")
    out = await run(llm=llm)
    assert out.status == "ok" and out.answer == "Trả lời." and out.chunk_count == 1
    assert llm.last_chunks[0].filename == "a.pdf"


@pytest.mark.parametrize("q", ["", "   ", "x" * 2001])
async def test_invalid_question(q):
    with pytest.raises(QuestionInvalid):
        await run(question=q)


async def test_question_is_stripped_and_2000_chars_allowed():
    llm = FakeLLM()
    await run(question="  " + "x" * 2000 + "  ", llm=llm)
    assert llm.last_question == "x" * 2000


async def test_no_ready_documents_does_not_call_embedder():
    emb = FakeEmbedder()
    with pytest.raises(NoReadyDocuments):
        await run(ready=0, embedder=emb)
    assert emb.calls == 0


@pytest.mark.parametrize("which", ["embedder", "llm"])
async def test_external_failure_is_error_outcome(which):
    kwargs = {"embedder": FakeEmbedder(fail=True)} if which == "embedder" else {"llm": FakeLLM(fail=True)}
    out = await run(**kwargs)
    assert out.status == "error" and out.answer is None


def test_prompt_contains_required_rules_and_context_format():
    for key in ("<tai_lieu>", "Không tìm thấy thông tin này trong tài liệu.", "không phải chỉ dẫn", "mâu thuẫn"):
        assert key in SYSTEM_PROMPT
    msg = build_user_message("Câu hỏi?", [RetrievedChunk("a.pdf", 7, "Đoạn văn", 0.8)])
    assert "[1] a.pdf, trang 7:" in msg and msg.endswith("Câu hỏi: Câu hỏi?")
