# T-123 — Chỉ báo nguồn tài liệu trên màn hình hỏi đáp

| Thuộc tính | Giá trị |
|---|---|
| Story | [US-008 — Mọi tài liệu Sẵn sàng là nguồn trả lời](../../requirements/User_Stories.md) |
| Giai đoạn | Sprint 1 (09/11 → 20/11/2026) |
| Loại | Frontend |
| Ước lượng | 1 ngày |
| Phụ trách đề xuất | FE |
| Phụ thuộc (phải xong trước) | [T-007](T-007-frontend-shell.md), [T-117](T-117-documents-list-api.md) |
| Mở khóa cho | [T-206](T-206-chat-ui.md) |
| Nhánh git | `feat/T-123-chat-source-indicator` |
| Trạng thái | `To do` |

## Mục tiêu

Người dùng biết câu trả lời dựa trên bao nhiêu tài liệu, và không thể hỏi khi chưa có tài liệu nào.

## Phạm vi & đặc tả

Trên khung `/chat` (phần chat thật sự làm ở T-206; ở task này chỉ dựng khung và trạng thái):

- **Header:** pill "{n} tài liệu đang dùng" (`counts.ready` lấy từ `useDocuments`), bấm vào → `/documents` (AC-US-008-3).
- **`counts.processing > 0`:** banner thông tin "{x} tài liệu đang xử lý, chưa được dùng để trả lời" phía trên ô nhập (AC-US-008-1).
- **`counts.ready == 0`:** hiển thị trạng thái trống theo `html_design/02-onboarding-empty.html` (3 bước + nút "Tải lên tài liệu"); ô nhập bị khóa với placeholder "Tải lên tài liệu để bắt đầu" (AC-US-008-4).

## Các bước thực hiện

1. Dựng `ChatPage` khung.
2. Thêm component `SourcePill`, `ProcessingBanner`, `EmptyOnboarding`.

## File cần tạo / sửa

- `frontend/src/features/chat/*`

## Tiêu chí hoàn thành

- [ ] AC-US-008-1 (phần giao diện), 3, 4 pass.
- [ ] Đạt Definition of Done chung ([User_Stories.md §9](../../requirements/User_Stories.md)): code review, CI xanh, đã deploy lên môi trường AWS.

## Kiểm thử

- Playwright với dữ liệu giả lập (route mock): 0 tài liệu; 5 tài liệu Sẵn sàng + 2 đang xử lý.

## Ngoài phạm vi task này

- Câu hỏi gợi ý (US-019 hoãn).

## Tham chiếu

- [docs/design/html_design/02-onboarding-empty.html,](../../design/html_design/) 04-chat.html
