# T-209 — Ánh xạ trích dẫn về tài liệu và trang

| Thuộc tính | Giá trị |
|---|---|
| Story | [US-013 — Trích dẫn tài liệu & trang](../../requirements/User_Stories.md) |
| Giai đoạn | Sprint 2 (23/11 → 04/12/2026) |
| Loại | Backend |
| Ước lượng | 1,5 ngày |
| Phụ trách đề xuất | BE1 |
| Phụ thuộc (phải xong trước) | [T-205](T-205-anthropic-adapter.md) |
| Mở khóa cho | [T-210](T-210-citation-markers.md) |
| Nhánh git | `feat/T-209-citation-mapping` |
| Trạng thái | `To do` |

## Mục tiêu

Mỗi trích dẫn mô hình trả về được ánh xạ chắc chắn về đúng tài liệu và trang đã gửi; không thể trỏ tới trang không tồn tại.

## Phạm vi & đặc tả

**`qa/domain/citation.py`** (thuần, không I/O):

```python
@dataclass
class Citation: idx: int; chunk_id; document_id; document_title: str; page_start: int; page_end: int; cited_text: str
class CitationMapper:
    def __init__(self, chunks: list[RetrievedChunk]): ...
    def map(self, ref: CitationRef) -> Citation | None
```

- `ref.document_index` ngoài khoảng `[0, len(chunks))` → trả `None` + log `warning` (không bao giờ tự tạo trang).
- `idx` đánh số theo **thứ tự xuất hiện**, bắt đầu từ 1. Cùng một `chunk_id` → dùng lại `idx` cũ (để không trùng nguồn).
- `cited_text` cắt tối đa 500 ký tự.
- `all()` trả danh sách citation duy nhất theo `idx`.

**`AskQuestion`** gọi `map()` cho mỗi `CitationRef`, phát SSE `citation` (chỉ lần đầu một `idx` xuất hiện), cuối cùng lưu vào bảng `citations` (kèm `document_title`).

## Các bước thực hiện

1. Viết `CitationMapper`.
2. Tích hợp vào `AskQuestion`.
3. Viết unit test.

## File cần tạo / sửa

- `backend/app/modules/qa/domain/citation.py`
- `backend/app/modules/qa/application/ask_question.py`

## Tiêu chí hoàn thành

- [ ] AC-US-013-3 (nguồn không trùng), AC-US-013-4 (không có trang ảo) được chứng minh bằng unit test.
- [ ] Đạt Definition of Done chung ([User_Stories.md §9](../../requirements/User_Stories.md)): code review, CI xanh, đã deploy lên môi trường AWS.

## Kiểm thử

- Unit: index hợp lệ, index ngoài phạm vi, 2 tham chiếu cùng chunk.

## Tham chiếu

- [SAD.md](../../design/SAD.md) §3.2.1 bước 7, ADR-006
- [User_Stories.md](../../requirements/User_Stories.md) US-013
