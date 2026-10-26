# T-101 — Phiên đăng nhập và CSRF

| Thuộc tính | Giá trị |
|---|---|
| Story | [US-001 — Đăng nhập](../../requirements/User_Stories.md) |
| Giai đoạn | Sprint 1 (09/11 → 20/11/2026) |
| Loại | Backend |
| Ước lượng | 1,5 ngày |
| Phụ trách đề xuất | BE2 |
| Phụ thuộc (phải xong trước) | [T-004](T-004-db-baseline.md), [T-005](T-005-platform-kernel.md) |
| Mở khóa cho | [T-102](T-102-auth-api.md), [T-106](T-106-file-endpoint.md), [T-108](T-108-conversation-owner-repo.md), [T-110](T-110-upload-api.md) |
| Nhánh git | `feat/T-101-session-csrf` |
| Trạng thái | `To do` |

## Mục tiêu

Hạ tầng phiên phía server lưu trong PostgreSQL (ADR-007) và cơ chế chống CSRF, dùng cho mọi endpoint cần đăng nhập.

## Phạm vi & đặc tả

**`platform/security.py`:**

| Hàm | Hành vi |
|---|---|
| `create_session(conn, user_id) -> (token, csrf)` | `token = secrets.token_urlsafe(32)`; lưu `id = sha256(token).hexdigest()`, `csrf_token = secrets.token_urlsafe(32)`, `expires_at = now() + 8h`. Trả token gốc để đặt cookie |
| `set_session_cookie(resp, token)` | `cwd_session=<token>; HttpOnly; Secure; SameSite=Lax; Path=/` (không đặt Max-Age, để là cookie phiên của trình duyệt) |
| `current_user` (FastAPI dependency) | Đọc cookie → tra `sessions JOIN users` với điều kiện `expires_at > now()` và `users.active`. Không hợp lệ → `AppError('unauthenticated', 401)`. Nếu `now() - last_seen_at > 5 phút` → cập nhật `last_seen_at = now()`, `expires_at = least(now() + 8h, created_at + 7 ngày)` |
| `require_role('admin')` | Dependency gọi `current_user`, sai vai trò → `AppError('forbidden', 403)` |
| `csrf_middleware` | Với method POST / PUT / PATCH / DELETE và path không phải `/api/v1/auth/login`: header `X-CSRF-Token` phải khớp `sessions.csrf_token` (so sánh bằng `hmac.compare_digest`), nếu không → 403 `csrf_invalid` |
| `delete_sessions_of(conn, user_id)` | Dùng cho CLI `disable-user` |

## Các bước thực hiện

1. Viết các hàm trong `security.py`.
2. Đăng ký `csrf_middleware` trong `api/main.py`.
3. Thêm job dọn phiên hết hạn vào worker (T-113): `DELETE FROM sessions WHERE expires_at < now()` mỗi giờ.
4. Viết test.

## File cần tạo / sửa

- `backend/app/platform/security.py`
- `backend/app/api/deps.py`
- `backend/app/api/main.py`

## Tiêu chí hoàn thành

- [ ] Request không có cookie tới endpoint có `current_user` → 401 `unauthenticated` (AC-US-001-1).
- [ ] Phiên không hoạt động quá 8 giờ → 401 (AC-US-001-8).
- [ ] POST thiếu hoặc sai `X-CSRF-Token` → 403 `csrf_invalid`.
- [ ] DB chỉ lưu sha256 của token, không lưu token gốc.
- [ ] Đạt Definition of Done chung ([User_Stories.md §9](../../requirements/User_Stories.md)): code review, CI xanh, đã deploy lên môi trường AWS.

## Kiểm thử

- Unit: tính `expires_at`. Integration: phiên hết hạn (cập nhật `expires_at` về quá khứ), user `active=false` → 401, CSRF sai → 403.

## Ngoài phạm vi task này

- Endpoint đăng nhập (T-102).

## Tham chiếu

- [SAD.md](../../design/SAD.md) §4.1, ADR-007
- [User_Stories.md](../../requirements/User_Stories.md) AC-US-001-1, 8; AC-G-01
