# T-219 — Xử lý mất kết nối khi đang trả lời

| Thuộc tính | Giá trị |
|---|---|
| Story | [US-016 — Câu trả lời hiện dần](../../requirements/User_Stories.md) |
| Giai đoạn | Sprint 2 (23/11 → 04/12/2026) |
| Loại | Frontend |
| Ước lượng | 0,5 ngày |
| Phụ trách đề xuất | FE |
| Phụ thuộc (phải xong trước) | [T-218](T-218-streaming-render.md) |
| Mở khóa cho | — |
| Nhánh git | `feat/T-219-stream-interrupted` |
| Trạng thái | `To do` |

## Mục tiêu

Khi luồng trả lời bị đứt giữa chừng, người dùng thấy rõ trạng thái và hỏi lại được ngay.

## Phạm vi & đặc tả

**Kích hoạt khi:** `streamQuestion` ném `StreamInterruptedError` hoặc lỗi mạng.

**Hiển thị:**

- Thay nội dung tin nhắn AI bằng khung lỗi "Mất kết nối — câu trả lời chưa hoàn tất" (icon cảnh báo) + nút **Hỏi lại** (gửi lại câu hỏi cũ).
- Theo AC đã sửa trong MVP, **không** giữ phần văn bản đã nhận (AC-US-016-5).
- Lắng nghe `window` `offline` / `online` → banner "Mất kết nối" phía trên ô nhập; khóa nút Gửi khi offline.

**Khi tải lại trang:** message có `state='incomplete'` hoặc `'failed'` hiển thị khung lỗi tương tự.

## Các bước thực hiện

1. Bắt lỗi trong `useStreamingAnswer`.
2. Viết `InterruptedCard`.
3. Viết test.

## File cần tạo / sửa

- `frontend/src/features/chat/InterruptedCard.tsx`

## Tiêu chí hoàn thành

- [ ] AC-US-016-5 (bản đã sửa) pass.
- [ ] Đạt Definition of Done chung ([User_Stories.md §9](../../requirements/User_Stories.md)): code review, CI xanh, đã deploy lên môi trường AWS.

## Kiểm thử

- Playwright: `route.abort()` giữa stream; `context.setOffline(true)`.

## Tham chiếu

- [User_Stories.md](../../requirements/User_Stories.md) §2.1 (US-016)
