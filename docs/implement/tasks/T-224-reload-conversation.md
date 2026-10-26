# T-224 — Tải lại hội thoại khi refresh trang

| Thuộc tính | Giá trị |
|---|---|
| Story | [US-011 — Hỏi và nhận câu trả lời](../../requirements/User_Stories.md) |
| Giai đoạn | Sprint 2 (23/11 → 04/12/2026) |
| Loại | Frontend |
| Ước lượng | 0,5 ngày |
| Phụ trách đề xuất | FE |
| Phụ thuộc (phải xong trước) | [T-201](T-201-conversation-api.md), [T-211](T-211-citation-ui.md) |
| Mở khóa cho | [T-302](T-302-security-review.md), [T-303](T-303-a11y-responsive.md) |
| Nhánh git | `feat/T-224-reload-conversation` |
| Trạng thái | `To do` |

## Mục tiêu

Refresh trang `/chat/{id}` vẫn thấy đầy đủ câu hỏi, câu trả lời, trích dẫn và trạng thái.

## Phạm vi & đặc tả

- **`ChatPage` có `conversationId`:** `useQuery(['messages', id], GET /conversations/{id}/messages)`.
- **Render theo `state` của message assistant:**
  - `complete` → `Answer` (marker → chip, citations → mục Nguồn);
  - `not_found` → `NotFoundCard`;
  - `failed` / `incomplete` → `InterruptedCard` với nút Hỏi lại (lấy câu hỏi user ngay trước đó).
- **404** (không thuộc quyền hoặc không tồn tại) → `/error/404`.

## Các bước thực hiện

1. Viết query và mapping trạng thái.
2. Viết test.

## File cần tạo / sửa

- `frontend/src/features/chat/ChatPage.tsx`

## Tiêu chí hoàn thành

- [ ] Refresh sau mỗi loại trạng thái hiển thị đúng; mở hội thoại của người khác → trang 404.
- [ ] Đạt Definition of Done chung ([User_Stories.md §9](../../requirements/User_Stories.md)): code review, CI xanh, đã deploy lên môi trường AWS.

## Kiểm thử

- Playwright.

## Ngoài phạm vi task này

- Danh sách lịch sử hội thoại (US-020 hoãn).

## Tham chiếu

- [User_Stories.md](../../requirements/User_Stories.md) US-003, US-011, US-013
