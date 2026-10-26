# T-103 — CLI quản trị tài khoản

| Thuộc tính | Giá trị |
|---|---|
| Story | [US-001 — Đăng nhập](../../requirements/User_Stories.md) |
| Giai đoạn | Sprint 1 (09/11 → 20/11/2026) |
| Loại | Backend |
| Ước lượng | 0,5 ngày |
| Phụ trách đề xuất | BE2 |
| Phụ thuộc (phải xong trước) | [T-102](T-102-auth-api.md) |
| Mở khóa cho | [T-107](T-107-file-access-tests.md), [T-304](T-304-runbook.md) |
| Nhánh git | `feat/T-103-admin-cli` |
| Trạng thái | `To do` |

## Mục tiêu

Tạo và quản lý tài khoản bằng dòng lệnh, thay cho màn hình quản lý người dùng (US-004 đã hoãn).

## Phạm vi & đặc tả

`python -m app.cli <lệnh>` (dùng `typer` hoặc `argparse`):

| Lệnh | Hành vi |
|---|---|
| `create-user --email --name --role member\|admin` | Sinh mật khẩu tạm `secrets.token_urlsafe(12)` (khoảng 16 ký tự), **in ra màn hình đúng một lần**, lưu hash. Email trùng → báo lỗi, exit code 1 |
| `reset-password --email` | Sinh mật khẩu tạm mới, xóa mọi phiên của user |
| `disable-user --email` / `enable-user --email` | Đổi `active`; khi disable thì xóa mọi phiên (AC-US-002-1) |
| `list-users` | In bảng email, tên, vai trò, `active`, `locked_until` |
| `unlock-user --email` | Đặt `failed_logins = 0`, `locked_until = NULL` |

Mọi lệnh ghi audit với `actor_id = NULL` và `details.source = 'cli'`.

Chạy trên AWS: `docker compose exec api python -m app.cli …`.

## Các bước thực hiện

1. Viết `app/cli.py`.
2. Dùng lại repository / use case của identity.
3. Ghi hướng dẫn vào README và Runbook (T-304).

## File cần tạo / sửa

- `backend/app/cli.py`

## Tiêu chí hoàn thành

- [ ] Tạo user bằng CLI → đăng nhập được bằng mật khẩu tạm.
- [ ] `disable-user` → phiên đang mở bị đăng xuất ngay.
- [ ] Đạt Definition of Done chung ([User_Stories.md §9](../../requirements/User_Stories.md)): code review, CI xanh, đã deploy lên môi trường AWS.

## Kiểm thử

- Integration: từng lệnh.

## Ngoài phạm vi task này

- Màn hình quản lý người dùng (US-004, giai đoạn 2).

## Tham chiếu

- [User_Stories.md](../../requirements/User_Stories.md) §2 (US-004 hoãn)
