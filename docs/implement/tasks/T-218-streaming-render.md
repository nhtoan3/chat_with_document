# T-218 — Hiển thị câu trả lời tăng dần

| Thuộc tính | Giá trị |
|---|---|
| Story | [US-016 — Câu trả lời hiện dần](../../requirements/User_Stories.md) |
| Giai đoạn | Sprint 2 (23/11 → 04/12/2026) |
| Loại | Frontend |
| Ước lượng | 1,5 ngày |
| Phụ trách đề xuất | FE |
| Phụ thuộc (phải xong trước) | [T-206](T-206-chat-ui.md), [T-207](T-207-sse-client.md) |
| Mở khóa cho | [T-219](T-219-stream-interrupted.md) |
| Nhánh git | `feat/T-218-streaming-render` |
| Trạng thái | `To do` |

## Mục tiêu

Câu trả lời xuất hiện dần ngay khi có token đầu, mượt mà và dùng được với trình đọc màn hình.

## Phạm vi & đặc tả

- **Ngay khi bấm Gửi** (≤ 300 ms): tin nhắn AI hiện 3 chấm nhấp nháy, `aria-label="Đang tạo câu trả lời"` (AC-US-016-3).
- **`onDelta`:** nối text vào bộ đệm; cập nhật state qua `requestAnimationFrame` (tối đa 1 lần render mỗi frame); hiện con trỏ nhấp nháy ở cuối.
- **Tự cuộn:** chỉ khi người dùng đang ở cuối danh sách (cách đáy < 80 px). Nếu người dùng đã cuộn lên thì không kéo xuống (AC-US-016-4).
- **Trình đọc màn hình:** vùng tin nhắn có `aria-live="polite"` và `aria-busy=true` trong lúc stream. Khi `done`: `aria-busy=false` và đọc toàn bộ câu trả lời một lần, tránh đọc từng mảnh.
- **Trong lúc stream:** khóa nút Gửi để không gửi chồng câu hỏi.

## Các bước thực hiện

1. Viết hook `useStreamingAnswer`.
2. Tích hợp vào `AiMessage`.
3. Viết test.

## File cần tạo / sửa

- `frontend/src/features/chat/useStreamingAnswer.ts`

## Tiêu chí hoàn thành

- [ ] AC-US-016-3, 4 pass; không giật hình khi stream 500 token.
- [ ] Đạt Definition of Done chung ([User_Stories.md §9](../../requirements/User_Stories.md)): code review, CI xanh, đã deploy lên môi trường AWS.

## Kiểm thử

- Playwright với SSE giả lập phát delta mỗi 30 ms.

## Ngoài phạm vi task này

- Nút Dừng (US-025 hoãn).

## Tham chiếu

- [User_Stories.md](../../requirements/User_Stories.md) US-016
- [Blueprint_Design.md](../../design/Blueprint_Design.md) UXS-07
