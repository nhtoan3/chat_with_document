# T-007 — Frontend shell và API client

| Thuộc tính | Giá trị |
|---|---|
| Tính năng | — (hạng mục nền tảng) |
| Giai đoạn | Sprint 0 — Nền tảng (02/11 → 06/11/2026) |
| Loại | Frontend |
| Ước lượng | 1 ngày |
| Phụ trách đề xuất | FE |
| Phụ thuộc (phải xong trước) | [T-001](T-001-repo-skeleton.md) |
| Mở khóa cho | [T-015](T-015-documents-ui.md), [T-021](T-021-ask-ui.md) |
| Nhánh git | `feat/T-007-frontend-shell` |
| Trạng thái | `To do` |

## Mục tiêu

Khung SPA với 2 trang (Tài liệu, Hỏi đáp), dùng lại giao diện từ `html_design`.

## Phạm vi & đặc tả

- **Router:** `/` → chuyển tới `/ask`; `/ask` (Hỏi đáp); `/documents` (Tài liệu).
- **Layout:** topbar (logo + tên sản phẩm) và sidebar 2 mục (Hỏi đáp, Tài liệu kèm số tài liệu Sẵn sàng); dưới 1280 px sidebar thành drawer. Lấy từ `html_design/04-chat.html`, **bỏ** thông tin người dùng và nút Đăng xuất.
- **`shared/ui/tokens.css`:** sao chép biến CSS `:root` từ html_design. Component: `Button`, `Badge`, `Banner`, `Toast`, `EmptyState`, `Table`.
- **`shared/api/client.ts`:** `apiFetch` với tiền tố `/api/v1`; body problem+json → `ApiError(code)`.
- **`shared/i18n/vi.json`:** toàn bộ chuỗi giao diện và thông điệp lỗi tiếng Việt.

## Các bước thực hiện

1. Router, React Query, i18n.
2. Layout và component.
3. API client.

## File cần tạo / sửa

- `frontend/src/app/*`
- `frontend/src/shared/*`

## Tiêu chí hoàn thành

- [ ] Hai trang trống hiển thị đúng layout ở 1440 px và 1024 px.
- [ ] Không có chuỗi giao diện viết cứng.
- [ ] Code đã được review, CI xanh, đã deploy lên môi trường AWS.

## Kiểm thử

- Vitest cho `apiFetch`.

## Ngoài phạm vi task này

- Trang đăng nhập, trang lỗi riêng (đã lược bỏ).

## Tham chiếu

- [docs/design/html_design/04-chat.html](../../design/html_design/)
- [docs/design/html_design/03-documents.html](../../design/html_design/)
