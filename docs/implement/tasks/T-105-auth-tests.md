# T-105 — Kiểm thử tích hợp cho xác thực

| Thuộc tính | Giá trị |
|---|---|
| Story | [US-001 — Đăng nhập](../../requirements/User_Stories.md) |
| Giai đoạn | Sprint 1 (09/11 → 20/11/2026) |
| Loại | Kiểm thử |
| Ước lượng | 0,5 ngày |
| Phụ trách đề xuất | BE2 |
| Phụ thuộc (phải xong trước) | [T-102](T-102-auth-api.md) |
| Mở khóa cho | — |
| Nhánh git | `feat/T-105-auth-tests` |
| Trạng thái | `To do` |

## Mục tiêu

Bộ test tích hợp bảo vệ các hành vi bảo mật của đăng nhập và phiên.

## Phạm vi & đặc tả

`tests/integration/test_auth.py` (Testcontainers Postgres):

| Ca kiểm thử | Kỳ vọng |
|---|---|
| Đăng nhập đúng | 204, có cookie `HttpOnly` và `Secure` |
| Sai 5 lần, lần 6 đúng mật khẩu | 423 |
| Sau 15 phút (giả lập thời gian) | Đăng nhập được |
| Email không tồn tại / sai mật khẩu | Cùng status và body |
| Phiên quá 8 giờ không hoạt động | 401 |
| Phiên quá 7 ngày dù vẫn hoạt động | 401 |
| Logout rồi gọi `/me` | 401 |
| POST không có CSRF | 403 `csrf_invalid` |
| User bị disable | 401 ngay ở request tiếp theo |

## Các bước thực hiện

1. Tạo fixture DB và client (`httpx.AsyncClient`).
2. Viết các ca trong bảng.

## File cần tạo / sửa

- `backend/tests/integration/test_auth.py`

## Tiêu chí hoàn thành

- [ ] Toàn bộ ca kiểm thử pass trong CI.
- [ ] Đạt Definition of Done chung ([User_Stories.md §9](../../requirements/User_Stories.md)): code review, CI xanh, đã deploy lên môi trường AWS.

## Kiểm thử

- (Chính là task kiểm thử.)

## Ngoài phạm vi task này

- Pentest.

## Tham chiếu

- [User_Stories.md](../../requirements/User_Stories.md) US-001, US-023
