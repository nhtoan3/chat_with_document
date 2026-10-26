# T-213 — AnswerGuard (logic chống bịa)

| Thuộc tính | Giá trị |
|---|---|
| Story | [US-014 — Không tìm thấy thông tin](../../requirements/User_Stories.md) |
| Giai đoạn | Sprint 2 (23/11 → 04/12/2026) |
| Loại | Backend |
| Ước lượng | 1 ngày |
| Phụ trách đề xuất | BE1 |
| Phụ thuộc (phải xong trước) | Không |
| Mở khóa cho | [T-203](T-203-ask-question-usecase.md) |
| Nhánh git | `feat/T-213-answer-guard` |
| Trạng thái | `To do` |

## Mục tiêu

Logic thuần quyết định khi nào phải trả "không tìm thấy" thay vì đưa ra câu trả lời.

## Phạm vi & đặc tả

**`qa/domain/answer_guard.py`** (không I/O, không phụ thuộc framework):

```python
class NotFound(Exception): reason: Literal["low_relevance", "model_declined", "no_citations"]
class AnswerGuard:
    def __init__(self, tau: float): ...
    def check_relevance(self, chunks: list[RetrievedChunk]) -> None   # ném NotFound("low_relevance")
    def finalize(self, text: str, citations: list[Citation]) -> None   # ném NotFound("model_declined" | "no_citations")
```

| Hàm | Điều kiện | Kết quả |
|---|---|---|
| `check_relevance` | `chunks` rỗng **hoặc** `max(c.sim) < tau` | `low_relevance` |
| `finalize` | `text.strip()` (đã bỏ marker) bắt đầu bằng `NOT_FOUND` | `model_declined` |
| `finalize` | `len(citations) == 0` | `no_citations` |

`AskQuestion` bắt `NotFound` → phát SSE `not_found{reason}`, lưu `state='not_found'`.

Với `low_relevance`: **không gọi LLM** (tiết kiệm chi phí và tránh bịa).

## Các bước thực hiện

1. Viết module.
2. Viết unit test đủ các nhánh và giá trị biên (`sim == tau`).

## File cần tạo / sửa

- `backend/app/modules/qa/domain/answer_guard.py`

## Tiêu chí hoàn thành

- [ ] 100% nhánh có unit test; `mypy --strict` sạch.
- [ ] Đạt Definition of Done chung ([User_Stories.md §9](../../requirements/User_Stories.md)): code review, CI xanh, đã deploy lên môi trường AWS.

## Kiểm thử

- Unit.

## Ngoài phạm vi task này

- Reranker / LLM-judge để chống bịa.

## Tham chiếu

- [SAD.md](../../design/SAD.md) §1.1 (D1), §3.2.1 bước 6 và 8
- [Blueprint_Design.md](../../design/Blueprint_Design.md) DR-01
