# T-210 — Gắn vị trí trích dẫn vào văn bản trả lời

| Thuộc tính | Giá trị |
|---|---|
| Story | [US-013 — Trích dẫn tài liệu & trang](../../requirements/User_Stories.md) |
| Giai đoạn | Sprint 2 (23/11 → 04/12/2026) |
| Loại | Backend |
| Ước lượng | 1 ngày |
| Phụ trách đề xuất | BE1 |
| Phụ thuộc (phải xong trước) | [T-209](T-209-citation-mapping.md) |
| Mở khóa cho | [T-211](T-211-citation-ui.md), [T-212](T-212-citation-eval.md) |
| Nhánh git | `feat/T-210-citation-markers` |
| Trạng thái | `To do` |

## Mục tiêu

Frontend biết chính xác chèn số trích dẫn vào đâu trong câu trả lời, cả khi stream lẫn khi tải lại trang.

## Phạm vi & đặc tả

**Quy ước marker:** chuỗi `[[c:n]]` (n = `idx`) nằm **ngay sau** đoạn văn bản mà trích dẫn đó hỗ trợ.

**Khi stream:**

- Adapter phát `BlockEnd` khi kết thúc một text block.
- `AskQuestion` gom các `idx` của citation trong block đó; tại `BlockEnd`, phát thêm SSE `delta{text: "[[c:1]][[c:3]]"}`.

**Khi lưu:** `messages.content` chứa cả marker → `GET …/messages` trả về nguyên như vậy.

Văn bản gốc có sẵn chuỗi `[[c:` (rất hiếm) → thay bằng `[ [c:` trước khi phát, để tránh nhầm với marker.

## Các bước thực hiện

1. Bổ sung xử lý `BlockEnd` trong `AskQuestion`.
2. Viết unit test.

## File cần tạo / sửa

- `backend/app/modules/qa/application/ask_question.py`

## Tiêu chí hoàn thành

- [ ] Câu trả lời có 2 block, mỗi block 1 trích dẫn → content dạng `...A[[c:1]]...B[[c:2]]`.
- [ ] Đạt Definition of Done chung ([User_Stories.md §9](../../requirements/User_Stories.md)): code review, CI xanh, đã deploy lên môi trường AWS.

## Kiểm thử

- Unit với `FakeLLM`.

## Tham chiếu

- [User_Stories.md](../../requirements/User_Stories.md) AC-US-013-1
