# T-203 — Use case AskQuestion (điều phối hỏi đáp)

| Thuộc tính | Giá trị |
|---|---|
| Story | [US-011 — Hỏi và nhận câu trả lời](../../requirements/User_Stories.md) |
| Giai đoạn | Sprint 2 (23/11 → 04/12/2026) |
| Loại | Backend |
| Ước lượng | 1,5 ngày |
| Phụ trách đề xuất | BE2 |
| Phụ thuộc (phải xong trước) | [T-121](T-121-vector-retrieval.md), [T-202](T-202-sse-endpoint.md), [T-205](T-205-anthropic-adapter.md), [T-213](T-213-answer-guard.md) |
| Mở khóa cho | [T-208](T-208-multi-doc-tuning.md), [T-214](T-214-tau-calibration.md), [T-216](T-216-prompt-injection-tests.md), [T-220](T-220-latency-test.md) |
| Nhánh git | `feat/T-203-ask-question-usecase` |
| Trạng thái | `To do` |

## Mục tiêu

Ghép các bước embedding → truy xuất → kiểm tra → LLM → trích dẫn → lưu thành một use case thuần, kiểm thử được.

## Phạm vi & đặc tả

**`qa/application/ask_question.py`:**

```python
class AskQuestion:
    def __init__(self, embed: EmbeddingPort, retrieve: RetrievalPort, llm: LLMPort,
                 convs: ConversationRepo, guard: AnswerGuard, settings): ...
    async def __call__(self, user, conversation_id, question) -> AsyncIterator[AnswerEvent]: ...
```

Thực hiện đúng 8 bước trong luồng xử lý bên dưới. Quy tắc:

- **Không** import `fastapi` hay `anthropic` trong file này (quy tắc D-1).
- **Đo thời gian:** `t0` tại bước 1; `first_token_ms` tại `TextDelta` đầu tiên; `latency_ms` tại bước 8.
- **Câu hỏi đầu tiên** của hội thoại → cập nhật `title = question[:80]`.
- **Lưu message assistant:** `content` (kèm marker `[[c:n]]`, xem T-210), `state ∈ {complete, not_found, failed, incomplete}`, `not_found_reason`, `model`, `input_tokens`, `output_tokens`, `cache_read_tokens`, `first_token_ms`, `latency_ms`.
- **Ánh xạ lỗi:** `LLMUnavailable` → event `error{code:'ai_unavailable', retryable:true}`; `LLMTimeout` → `error{code:'timeout'}`; TEI lỗi → `error{code:'ai_unavailable'}`.

**Luồng xử lý một câu hỏi** (dùng chung cho US-011..016):

```
FE  POST /api/v1/conversations/{id}/messages {question}
BE  1. current_user + get_owned(conversation) → lưu message(role=user)
    2. SSE meta {message_id, ready_doc_count, processing_doc_count}
    3. embed(question) qua TEI (timeout 2 s)
    4. RetrievalPort.search top QA_TOP_N
    5. AnswerGuard.check_relevance → max(sim) < QA_TAU → SSE not_found{low_relevance} → lưu → KẾT THÚC
    6. LLMPort.stream_answer → SSE delta{text} / citation{…}
    7. AnswerGuard.finalize → NOT_FOUND hoặc 0 trích dẫn → SSE not_found{model_declined|no_citations}
    8. lưu message(assistant) + citations → SSE done{latency_ms, citation_count}
    Lỗi / timeout LLM → SSE error{code, retryable:true}, message.state='failed'
```

## Các bước thực hiện

1. Viết use case và kiểu `AnswerEvent`.
2. Đăng ký trong `api/deps.py`.
3. Viết unit test với port giả lập.

## File cần tạo / sửa

- `backend/app/modules/qa/application/ask_question.py`
- `backend/app/modules/qa/domain/events.py`
- `backend/app/api/deps.py`

## Tiêu chí hoàn thành

- [ ] Unit test đủ nhánh: thành công, `low_relevance`, `model_declined`, `no_citations`, lỗi LLM, timeout.
- [ ] Câu hỏi về kiến thức chung → không gọi LLM hoặc trả `not_found` (AC-US-011-6).
- [ ] Lỗi AI → event `error` và câu hỏi không bị mất (AC-US-011-8).
- [ ] Đạt Definition of Done chung ([User_Stories.md §9](../../requirements/User_Stories.md)): code review, CI xanh, đã deploy lên môi trường AWS.

## Kiểm thử

- Unit với fake port. Integration end-to-end với `FakeLLM` phát citation mẫu.

## Ngoài phạm vi task này

- Viết lại câu hỏi nối tiếp (US-019 hoãn).

## Tham chiếu

- [SAD.md](../../design/SAD.md) §3.2.1
- [Blueprint_Design.md](../../design/Blueprint_Design.md) §3.2 (Logical View)
