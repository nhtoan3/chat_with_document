# T-020 — API hỏi đáp

| Thuộc tính | Giá trị |
|---|---|
| Tính năng | F2 — Hỏi đáp AI |
| Giai đoạn | Sprint 1 — Xử lý PDF + Hỏi đáp AI (09/11 → 20/11/2026) |
| Loại | Backend |
| Ước lượng | 1,5 ngày |
| Phụ trách đề xuất | BE2 |
| Phụ thuộc (phải xong trước) | [T-017](T-017-vector-retrieval.md), [T-019](T-019-anthropic-adapter.md), [T-013](T-013-ingest-pipeline.md) |
| Mở khóa cho | [T-021](T-021-ask-ui.md), [T-022](T-022-ask-tests.md) |
| Nhánh git | `feat/T-020-ask-api` |
| Trạng thái | `To do` |

## Mục tiêu

Endpoint nhận câu hỏi và trả câu trả lời dựa trên các tài liệu đang Sẵn sàng.

## Phạm vi & đặc tả

**`POST /api/v1/ask`** — body `{question: str}`:

1. `q = question.strip()`; độ dài phải từ 1 tới 2000, nếu không → 422 `question_invalid`.
2. Không có tài liệu nào `ready` → 409 `no_documents`.
3. `qvec = TEIEmbedding.embed([q])[0]`.
4. `chunks = RetrievalPort.search(qvec, QA_TOP_N)`.
5. `result = LLMPort.answer(q, chunks)`.
6. `INSERT qa_log(status='ok', latency_ms, input_tokens, output_tokens, chunk_count)` — **không lưu** nội dung câu hỏi hay câu trả lời.
7. Trả 200 `{"answer": "...markdown...", "latency_ms": 8421}`.

**Lỗi TEI / LLM** → `qa_log(status='error')` → 503 `ai_unavailable`.

**Use case** `qa/application/ask.py` không import FastAPI hay Anthropic (dễ test).

## Các bước thực hiện

1. Viết use case.
2. Viết route.
3. Viết test với `FakeLLM`.

## File cần tạo / sửa

- `backend/app/modules/qa/application/ask.py`
- `backend/app/api/routers/ask.py`

## Tiêu chí hoàn thành

- [ ] Câu hỏi hợp lệ → 200 có câu trả lời.
- [ ] Chưa có tài liệu → 409.
- [ ] Lỗi LLM → 503 và có dòng `qa_log` lỗi.
- [ ] Code đã được review, CI xanh, đã deploy lên môi trường AWS.

## Kiểm thử

- Unit (fake port) + integration (`FakeLLM`).

## Ngoài phạm vi task này

- Lưu hội thoại, câu hỏi nối tiếp, streaming.

## Tham chiếu

- [User_Stories.md](../../requirements/User_Stories.md) US-011 (bản tối giản)
