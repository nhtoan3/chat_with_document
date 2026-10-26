# T-202 — Endpoint SSE gửi câu hỏi

| Thuộc tính | Giá trị |
|---|---|
| Story | [US-011 — Hỏi và nhận câu trả lời](../../requirements/User_Stories.md) |
| Giai đoạn | Sprint 2 (23/11 → 04/12/2026) |
| Loại | Backend |
| Ước lượng | 1 ngày |
| Phụ trách đề xuất | BE2 |
| Phụ thuộc (phải xong trước) | [T-201](T-201-conversation-api.md) |
| Mở khóa cho | [T-203](T-203-ask-question-usecase.md) |
| Nhánh git | `feat/T-202-sse-endpoint` |
| Trạng thái | `To do` |

## Mục tiêu

Endpoint trả câu trả lời dạng luồng sự kiện (SSE), phát hiện được khi client ngắt kết nối.

## Phạm vi & đặc tả

**`POST /api/v1/conversations/{id}/messages`** — body `{question: str}`, cần đăng nhập và CSRF:

- **Validate:** `q = question.strip()`; `len(q)` phải từ 1 tới 2000, nếu không → 422 `question_too_long` (với chuỗi rỗng dùng 422 và code chung `validation_error`) **trước khi** mở stream.
- **Response:** `StreamingResponse(gen(), media_type="text/event-stream", headers={"Cache-Control": "no-cache", "X-Accel-Buffering": "no"})`.
- **`api/sse.py`:**
  - `def sse(event: str, data: dict) -> bytes` → `f"event: {event}\ndata: {json.dumps(data, ensure_ascii=False)}\n\n"`;
  - task ping gửi `: ping\n\n` mỗi 15 s.
- **Phát hiện ngắt kết nối:** giữa các event, kiểm tra `await request.is_disconnected()`. Nếu ngắt → hủy (`aclose`) generator của LLM, lưu `state='incomplete'`, thoát.
- **Các loại event** (hợp đồng với FE):

| Event | Dữ liệu |
|---|---|
| `meta` | `{message_id, ready_doc_count, processing_doc_count}` |
| `delta` | `{text}` |
| `citation` | `{idx, document_id, document_title, page_start, page_end, cited_text}` |
| `not_found` | `{reason}` |
| `done` | `{latency_ms, citation_count}` |
| `error` | `{code, retryable}` |

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

1. Viết `api/sse.py`.
2. Viết route; generator gọi `AskQuestion` (T-203).
3. Viết test với `AskQuestion` giả lập.

## File cần tạo / sửa

- `backend/app/api/sse.py`
- `backend/app/api/routers/conversations.py`

## Tiêu chí hoàn thành

- [ ] Câu hỏi 2001 ký tự → 422 (AC-US-011-3).
- [ ] Đọc stream bằng `httpx` thấy event đúng thứ tự `meta → delta… → citation… → done`.
- [ ] Client đóng kết nối giữa chừng → message có `state='incomplete'`.
- [ ] Đạt Definition of Done chung ([User_Stories.md §9](../../requirements/User_Stories.md)): code review, CI xanh, đã deploy lên môi trường AWS.

## Kiểm thử

- Integration với `AskQuestion` giả lập phát sự kiện mẫu.

## Ngoài phạm vi task này

- Rate limit (AC-US-011-9, đã bỏ).

## Tham chiếu

- [SAD.md](../../design/SAD.md) §2.4 (hợp đồng SSE)
- [User_Stories.md](../../requirements/User_Stories.md) US-011, §2.1
