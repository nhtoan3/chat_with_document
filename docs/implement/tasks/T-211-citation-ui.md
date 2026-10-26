# T-211 — Hiển thị trích dẫn và mục Nguồn

| Thuộc tính | Giá trị |
|---|---|
| Story | [US-013 — Trích dẫn tài liệu & trang](../../requirements/User_Stories.md) |
| Giai đoạn | Sprint 2 (23/11 → 04/12/2026) |
| Loại | Frontend |
| Ước lượng | 1,5 ngày |
| Phụ trách đề xuất | FE |
| Phụ thuộc (phải xong trước) | [T-206](T-206-chat-ui.md), [T-210](T-210-citation-markers.md) |
| Mở khóa cho | [T-222](T-222-open-citation.md), [T-224](T-224-reload-conversation.md) |
| Nhánh git | `feat/T-211-citation-ui` |
| Trạng thái | `To do` |

## Mục tiêu

Người dùng thấy số trích dẫn ngay trong câu trả lời và danh sách nguồn (tài liệu + trang) bên dưới.

## Phạm vi & đặc tả

**`features/chat/Answer.tsx`:**

- **Render Markdown** bằng `marked` rồi làm sạch bằng `DOMPurify` (chặn HTML thô và link `javascript:` — UXC-09).
- **Chip trích dẫn:** thay marker `[[c:n]]` bằng `<button class="cite" aria-label="Trích dẫn n" data-c="n">n</button>`. Thay **sau** bước làm sạch, chỉ áp dụng cho đúng mẫu `\[\[c:(\d+)\]\]`.
- **Mục "Nguồn (k)"** dưới câu trả lời: mỗi citation một dòng `n · {document_title} · tr. {page_start}`, kèm 1 dòng trích `"{cited_text}"` (rút gọn bằng CSS line-clamp). Dòng nguồn là nút bấm được (hành vi mở ở T-222).
- **Trong lúc stream:** citation đến qua `onCitation` → thêm vào danh sách Nguồn ngay; marker đến qua `onDelta`.
- **Trích dẫn tới tài liệu đã gỡ** (`document_id == null`): chip và dòng nguồn hiển thị trạng thái vô hiệu (chi tiết ở T-222).

## Các bước thực hiện

1. Viết `Answer` và `SourcesList`.
2. Viết test.

## File cần tạo / sửa

- `frontend/src/features/chat/Answer.tsx`
- `frontend/src/features/chat/SourcesList.tsx`

## Tiêu chí hoàn thành

- [ ] AC-US-013-1, 3 pass.
- [ ] Payload `<img onerror>` trong câu trả lời không được thực thi.
- [ ] Đạt Definition of Done chung ([User_Stories.md §9](../../requirements/User_Stories.md)): code review, CI xanh, đã deploy lên môi trường AWS.

## Kiểm thử

- Vitest: thay marker, làm sạch XSS. Playwright với SSE giả lập.

## Ngoài phạm vi task này

- Panel xem PDF trong ứng dụng (đã đơn giản hóa).

## Tham chiếu

- [docs/design/html_design/04-chat.html](../../design/html_design/)
- [Blueprint_Design.md](../../design/Blueprint_Design.md) UXC-09
