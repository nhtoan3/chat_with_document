# T-205 — AnthropicLLMAdapter (streaming + citations)

| Thuộc tính | Giá trị |
|---|---|
| Story | [US-011 — Hỏi và nhận câu trả lời](../../requirements/User_Stories.md) |
| Giai đoạn | Sprint 2 (23/11 → 04/12/2026) |
| Loại | Backend |
| Ước lượng | 2 ngày |
| Phụ trách đề xuất | BE2 |
| Phụ thuộc (phải xong trước) | [T-204](T-204-system-prompt.md), [T-008](T-008-poc-llm-latency.md) |
| Mở khóa cho | [T-203](T-203-ask-question-usecase.md), [T-209](T-209-citation-mapping.md) |
| Nhánh git | `feat/T-205-anthropic-adapter` |
| Trạng thái | `To do` |

## Mục tiêu

Adapter gọi Claude qua Anthropic API, trả về luồng văn bản và trích dẫn theo định dạng trung lập của `LLMPort`.

## Phạm vi & đặc tả

**Port** (`qa/ports.py`):

```python
class LLMPort(Protocol):
    def stream_answer(self, question: str, chunks: list[RetrievedChunk]) -> AsyncIterator[LLMEvent]: ...
# LLMEvent = TextDelta(text) | CitationRef(document_index, cited_text) | BlockEnd() | Completed(usage, stop_reason)
# Exceptions: LLMUnavailable, LLMTimeout, LLMRefused
```

**Adapter** (`qa/adapters/anthropic_llm.py`):

```python
client = anthropic.AsyncAnthropic(max_retries=2, timeout=settings.LLM_TIMEOUT_S)
docs = [{"type": "document",
         "source": {"type": "content", "content": [{"type": "text", "text": c.content}]},
         "title": f"{c.filename} — tr. {c.page_start}",
         "citations": {"enabled": True}} for c in chunks]      # document_index = vị trí trong list
async with client.beta.messages.stream(
        model=settings.LLM_MODEL, max_tokens=4096,
        thinking={"type": "adaptive"}, output_config={"effort": "low"},
        betas=["server-side-fallback-2026-07-01"], fallbacks="default",
        system=[{"type": "text", "text": SYSTEM_PROMPT, "cache_control": {"type": "ephemeral"}}],
        messages=[{"role": "user", "content": [*docs, {"type": "text", "text": question}]}]) as stream:
    async for event in stream: ...   # chuyển thành TextDelta / CitationRef / BlockEnd
    final = await stream.get_final_message()   # usage, stop_reason
```

**Xử lý lỗi** (bắt từ lớp cụ thể tới lớp chung):

| Trường hợp | Kết quả |
|---|---|
| `anthropic.RateLimitError`, `APIStatusError` với status ≥ 500, `APIConnectionError` | `LLMUnavailable` |
| Không có `TextDelta` sau 20 s (watchdog bằng `asyncio.wait_for` cho event đầu) | `LLMTimeout` |
| `stop_reason == "refusal"` | `LLMRefused` (use case ánh xạ thành `not_found{model_declined}`) |
| `stop_reason == "max_tokens"` | Ghi log `warning`, vẫn trả kết quả |
| `APIStatusError` 400 / 401 | Ghi log `error` + `LLMUnavailable` (không retry) |

⚠ **Bắt buộc trước khi code:** đối chiếu tài liệu Anthropic Python SDK (mục streaming + citations) để xác nhận:

- tên event delta của trích dẫn (citations delta) và vị trí `document_index` khi dùng `content_block_location`;
- cú pháp chính xác của `betas` / `fallbacks` trong phiên bản SDK đang pin.

Ghi lại một lần gọi thật thành fixture JSON (`tests/fixtures/anthropic_stream_*.json`) để làm contract test.

## Các bước thực hiện

1. Đọc tài liệu SDK; ghi fixture từ một lần gọi thật (dùng tài liệu mẫu, không dùng dữ liệu thật).
2. Viết port, exception và adapter.
3. Viết `FakeLLM` (phát sự kiện từ fixture) dùng cho test của các task khác.
4. Viết contract test: chạy chung một bộ kiểm tra cho cả `FakeLLM` và adapter thật (adapter thật chỉ chạy khi có `ANTHROPIC_API_KEY`, đánh marker `live`).

## File cần tạo / sửa

- `backend/app/modules/qa/ports.py`
- `backend/app/modules/qa/adapters/anthropic_llm.py`
- `backend/tests/fakes/fake_llm.py`
- `backend/tests/contract/test_llm_port.py`

## Tiêu chí hoàn thành

- [ ] Contract test pass với fixture.
- [ ] Lỗi 529 / 500 giả lập → `LLMUnavailable`; không có token sau 20 s → `LLMTimeout`.
- [ ] Log mỗi lần gọi có model, token, `cache_read_input_tokens`, `stop_reason`, `PROMPT_VERSION` — **không** có nội dung.
- [ ] Đạt Definition of Done chung ([User_Stories.md §9](../../requirements/User_Stories.md)): code review, CI xanh, đã deploy lên môi trường AWS.

## Kiểm thử

- Contract (fixture). Live test thủ công trước khi merge.

## Ngoài phạm vi task này

- Adapter Bedrock (chỉ làm nếu OQ-008 yêu cầu — Implement_plan §5).

## Tham chiếu

- [SAD.md](../../design/SAD.md) §3.2.1 bước 7, ADR-005
- [Blueprint_Design.md](../../design/Blueprint_Design.md) §3.5.3 (IF-20)
