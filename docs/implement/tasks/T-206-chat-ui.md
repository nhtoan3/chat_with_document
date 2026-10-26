# T-206 — Màn hình hỏi đáp: composer, tin nhắn và lỗi

| Thuộc tính | Giá trị |
|---|---|
| Story | [US-011 — Hỏi và nhận câu trả lời](../../requirements/User_Stories.md) |
| Giai đoạn | Sprint 2 (23/11 → 04/12/2026) |
| Loại | Frontend |
| Ước lượng | 2 ngày |
| Phụ trách đề xuất | FE |
| Phụ thuộc (phải xong trước) | [T-123](T-123-chat-source-indicator.md), [T-207](T-207-sse-client.md) |
| Mở khóa cho | [T-211](T-211-citation-ui.md), [T-215](T-215-not-found-ui.md), [T-218](T-218-streaming-render.md) |
| Nhánh git | `feat/T-206-chat-ui` |
| Trạng thái | `To do` |

## Mục tiêu

Người dùng đặt câu hỏi, thấy câu trả lời và xử lý được lỗi ngay trên màn hình Hỏi đáp.

## Phạm vi & đặc tả

**`features/chat/ChatPage.tsx`** — theo `html_design/04-chat.html`, **bỏ**: mục "Gần đây" ở sidebar, panel xem PDF, nút đánh giá, nút Dừng.

**Composer:**

- `<textarea>` tự giãn chiều cao (tối đa 200 px).
- Enter gửi, Shift+Enter xuống dòng (AC-US-011-5).
- Nút Gửi bị khóa khi nội dung rỗng sau `trim` hoặc dài hơn 2000 ký tự (AC-US-011-4).
- Bộ đếm `n/2000`, chuyển màu đỏ và hiện số ký tự vượt khi quá giới hạn (AC-US-011-3).

**Gửi câu hỏi:**

- Chưa có `conversationId` → `POST /conversations` → `navigate('/chat/'+id, {replace: true})`.
- Thêm ngay bong bóng câu hỏi của người dùng.
- Gọi `streamQuestion` (T-207).

**Tin nhắn AI:** avatar "AI", nội dung (T-211), nhãn "Câu trả lời do AI tạo — hãy kiểm tra nguồn" (AC-US-011-7).

**Lỗi** (event `error` hoặc HTTP lỗi):

- Khung lỗi "Hệ thống đang bận, vui lòng thử lại." (ERR-12) hoặc ERR-13 cho timeout.
- Nút **Hỏi lại** gửi lại đúng câu hỏi cũ; câu hỏi không bị mất (AC-US-011-8).

**"Hội thoại mới"** (sidebar / header) → `/chat` (trạng thái trống).

## Các bước thực hiện

1. Viết `Composer`, `MessageList`, `UserBubble`, `AiMessage`.
2. Nối với `streamQuestion`.
3. Viết test.

## File cần tạo / sửa

- `frontend/src/features/chat/*`

## Tiêu chí hoàn thành

- [ ] AC-US-011-2, 3, 4, 5, 7, 8 pass.
- [ ] Thao tác được hoàn toàn bằng bàn phím; `axe` sạch.
- [ ] Đạt Definition of Done chung ([User_Stories.md §9](../../requirements/User_Stories.md)): code review, CI xanh, đã deploy lên môi trường AWS.

## Kiểm thử

- Vitest cho composer. Playwright với SSE giả lập (route mock trả `text/event-stream`).

## Ngoài phạm vi task này

- Câu hỏi gợi ý, hỏi nối tiếp (US-019 hoãn), dừng câu trả lời (US-025 hoãn).

## Tham chiếu

- [docs/design/html_design/04-chat.html](../../design/html_design/)
- [User_Stories.md](../../requirements/User_Stories.md) US-011
