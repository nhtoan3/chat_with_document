# T-104 — Màn hình đăng nhập, route guard và đăng xuất

| Thuộc tính | Giá trị |
|---|---|
| Story | [US-001 — Đăng nhập](../../requirements/User_Stories.md) |
| Giai đoạn | Sprint 1 (09/11 → 20/11/2026) |
| Loại | Frontend |
| Ước lượng | 1,5 ngày |
| Phụ trách đề xuất | FE |
| Phụ thuộc (phải xong trước) | [T-007](T-007-frontend-shell.md), [T-102](T-102-auth-api.md) |
| Mở khóa cho | — |
| Nhánh git | `feat/T-104-login-ui` |
| Trạng thái | `To do` |

## Mục tiêu

Màn hình đăng nhập theo thiết kế và luồng đăng nhập / đăng xuất hoàn chỉnh trên frontend.

## Phạm vi & đặc tả

**`features/auth/LoginPage.tsx`** — theo `html_design/01-login.html`, **bỏ nút SSO và phần "hoặc"**:

- Form gồm email và mật khẩu (có nút hiện / ẩn), nút "Đăng nhập".
- **Kiểm tra phía client khi submit:** email sai định dạng hoặc mật khẩu trống → lỗi hiển thị dưới ô và đặt focus vào ô lỗi đầu tiên (AC-US-001-5).
- **Ánh xạ lỗi từ server:**
  - 401 → banner "Email hoặc mật khẩu không đúng. Tài khoản sẽ tạm khóa sau 5 lần sai.";
  - 423 → banner ERR-05 và vô hiệu hóa form;
  - lỗi khác → thông điệp chung.
- **Thành công:** gọi `/me`, rồi chuyển tới `?next=` (chỉ chấp nhận đường dẫn nội bộ bắt đầu bằng `/`), mặc định `/chat`.

**`RequireAuth`:** gọi `useMe()`; nhận 401 thì `<Navigate to="/login?next=…">`.

**Đăng xuất (topbar):** `POST /auth/logout` → `queryClient.clear()` → `/login`.

## Các bước thực hiện

1. Viết `useMe`, `useLogin`, `useLogout` (React Query).
2. Viết LoginPage và RequireAuth.
3. Viết test.

## File cần tạo / sửa

- `frontend/src/features/auth/*`

## Tiêu chí hoàn thành

- [ ] AC-US-001-1, 3, 4 (bản đã sửa), 5 pass.
- [ ] AC-US-023-1, 2: sau khi đăng xuất bấm Back không xem được dữ liệu.
- [ ] Thao tác được hoàn toàn bằng bàn phím; `axe` sạch.
- [ ] Đạt Definition of Done chung ([User_Stories.md §9](../../requirements/User_Stories.md)): code review, CI xanh, đã deploy lên môi trường AWS.

## Kiểm thử

- Vitest cho form validation. Playwright: đăng nhập thành công; sai mật khẩu; tài khoản khóa; đăng xuất rồi bấm Back.

## Ngoài phạm vi task này

- Giữ bản nháp câu hỏi khi phiên hết hạn (AC-US-001-7, đã bỏ trong MVP).

## Tham chiếu

- [docs/design/html_design/01-login.html](../../design/html_design/)
- [User_Stories.md](../../requirements/User_Stories.md) US-001, US-023, §2.1
