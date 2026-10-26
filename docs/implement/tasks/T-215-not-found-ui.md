# T-215 — Giao diện "Không tìm thấy thông tin"

| Thuộc tính | Giá trị |
|---|---|
| Story | [US-014 — Không tìm thấy thông tin](../../requirements/User_Stories.md) |
| Giai đoạn | Sprint 2 (23/11 → 04/12/2026) |
| Loại | Frontend |
| Ước lượng | 0,5 ngày |
| Phụ trách đề xuất | FE |
| Phụ thuộc (phải xong trước) | [T-206](T-206-chat-ui.md) |
| Mở khóa cho | — |
| Nhánh git | `feat/T-215-not-found-ui` |
| Trạng thái | `To do` |

## Mục tiêu

Phản hồi "không tìm thấy" khác biệt rõ với câu trả lời thường và gợi ý người dùng làm gì tiếp.

## Phạm vi & đặc tả

Khi nhận `onNotFound`:

- **Xóa** phần văn bản đã stream của tin nhắn đó, nếu có (trường hợp `model_declined` hoặc `no_citations`).
- **Hiển thị khung** theo `html_design/04-chat.html` (trạng thái "Không tìm thấy" trong bảng điều khiển demo):
  - viền trái màu cảnh báo, icon tìm kiếm;
  - tiêu đề "Không tìm thấy thông tin trong tài liệu";
  - câu "Bộ tài liệu hiện tại không có nội dung đủ căn cứ để trả lời câu hỏi này. Hệ thống không đưa ra câu trả lời suy đoán.";
  - 2 gợi ý: diễn đạt lại bằng từ khóa có trong tài liệu; kiểm tra tài liệu đã được tải lên và Sẵn sàng (link `/documents`).
- **Khi tải lại trang:** message có `state='not_found'` render cùng khung này.

## Các bước thực hiện

1. Viết `NotFoundCard`.
2. Nối với handler.
3. Viết test.

## File cần tạo / sửa

- `frontend/src/features/chat/NotFoundCard.tsx`

## Tiêu chí hoàn thành

- [ ] AC-US-014-3 pass.
- [ ] Đạt Definition of Done chung ([User_Stories.md §9](../../requirements/User_Stories.md)): code review, CI xanh, đã deploy lên môi trường AWS.

## Kiểm thử

- Playwright với SSE giả lập: delta rồi not_found → chỉ còn khung not-found.

## Tham chiếu

- [docs/design/html_design/04-chat.html](../../design/html_design/)
- [PRD.md](../../requirements/PRD.md) UI-05
