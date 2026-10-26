# T-102 — API đăng nhập, đăng xuất và /me

| Thuộc tính | Giá trị |
|---|---|
| Story | [US-001 — Đăng nhập](../../requirements/User_Stories.md) |
| Giai đoạn | Sprint 1 (09/11 → 20/11/2026) |
| Loại | Backend |
| Ước lượng | 1,5 ngày |
| Phụ trách đề xuất | BE2 |
| Phụ thuộc (phải xong trước) | [T-101](T-101-session-csrf.md) |
| Mở khóa cho | [T-103](T-103-admin-cli.md), [T-104](T-104-login-ui.md), [T-105](T-105-auth-tests.md) |
| Nhánh git | `feat/T-102-auth-api` |
| Trạng thái | `To do` |

## Mục tiêu

Người dùng đăng nhập bằng email và mật khẩu; tài khoản bị khóa tạm thời sau 5 lần sai; đăng xuất hủy phiên phía server.

> ⚠ **AC-US-001-4 cần PO làm rõ:** hiển thị "số lần thử còn lại" sẽ làm lộ email có tồn tại hay không. Task này triển khai thông điệp cố định; nếu PO chọn khác thì cập nhật T-104.

## Phạm vi & đặc tả

**`POST /api/v1/auth/login`** — body `{email: str, password: str}`:

1. `email = email.strip().lower()`; tìm user.
2. User có `locked_until > now()` → audit `login_failed{reason: locked}` → 423 `account_locked`.
3. Kiểm tra mật khẩu bằng `argon2.PasswordHasher` (m=64 MiB, t=3, p=1). **User không tồn tại vẫn gọi `verify` với một hash giả** để thời gian phản hồi như nhau.
4. **Sai mật khẩu:** `failed_logins += 1`. Nếu `failed_logins >= LOGIN_MAX_FAILS` → `locked_until = now() + 15 phút`, `failed_logins = 0`. Audit `login_failed` → 401 `invalid_credentials`.
5. **Đúng:** đặt `failed_logins = 0`, `locked_until = NULL`; nếu `ph.check_needs_rehash` thì cập nhật hash; `create_session` → đặt cookie → audit `login_success` → 204.

**`POST /api/v1/auth/logout`** (cần đăng nhập + CSRF): xóa dòng session, xóa cookie, audit `logout` → 204.

**`GET /api/v1/me`** → `{id, email, display_name, role, csrf_token}`.

Rate limit đăng nhập **không** làm trong MVP (ADR-011); khóa tài khoản là đủ.

## Các bước thực hiện

1. Viết `modules/identity/application/login.py` (use case thuần) và repository `users`.
2. Viết router `api/routers/auth.py`.
3. Viết `identity/adapters/password.py` (bọc `argon2-cffi`).

## File cần tạo / sửa

- `backend/app/modules/identity/**`
- `backend/app/api/routers/auth.py`

## Tiêu chí hoàn thành

- [ ] Đăng nhập đúng → 204 + cookie; `GET /me` trả đúng thông tin (AC-US-001-3).
- [ ] Sai 5 lần liên tiếp → lần thứ 6 nhận 423, kể cả khi mật khẩu đúng (AC-US-001-2).
- [ ] Email không tồn tại và mật khẩu sai trả **cùng** mã lỗi và thông điệp (AC-US-001-4, xem lưu ý).
- [ ] Logout → gọi `/me` bằng cookie cũ nhận 401 (AC-US-023-1, 2).
- [ ] Audit log có `login_success`, `login_failed`, `logout` (AC-G-07).
- [ ] Đạt Definition of Done chung ([User_Stories.md §9](../../requirements/User_Stories.md)): code review, CI xanh, đã deploy lên môi trường AWS.

## Kiểm thử

- Integration: đủ các nhánh trên; giả lập thời gian để kiểm tra mở khóa sau 15 phút.

## Ngoài phạm vi task này

- SSO / OIDC (chỉ làm nếu OQ-014 chọn SSO).

## Tham chiếu

- [User_Stories.md](../../requirements/User_Stories.md) US-001, US-023
- [SAD.md](../../design/SAD.md) §4.1
