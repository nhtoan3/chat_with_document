# T-107 — Kiểm thử truy cập tệp

| Thuộc tính | Giá trị |
|---|---|
| Story | [US-002 — Truy cập tệp an toàn](../../requirements/User_Stories.md) |
| Giai đoạn | Sprint 1 (09/11 → 20/11/2026) |
| Loại | Kiểm thử |
| Ước lượng | 0,25 ngày |
| Phụ trách đề xuất | BE1 |
| Phụ thuộc (phải xong trước) | [T-106](T-106-file-endpoint.md), [T-103](T-103-admin-cli.md) |
| Mở khóa cho | — |
| Nhánh git | `feat/T-107-file-access-tests` |
| Trạng thái | `To do` |

## Mục tiêu

Xác nhận không thể lấy PDF khi chưa đăng nhập hoặc đã bị vô hiệu hóa.

## Phạm vi & đặc tả

| Ca kiểm thử | Kỳ vọng |
|---|---|
| Chưa đăng nhập | 401 |
| User bị `disable-user` gọi tiếp | 401 |
| Tài liệu đang `processing` | 404 |
| Tài liệu đã bị xóa | 404 |
| URL presigned dùng lại sau TTL | 403 từ S3 |

## Các bước thực hiện

1. Viết test trong `tests/integration/test_documents_access.py`.

## File cần tạo / sửa

- `backend/tests/integration/test_documents_access.py`

## Tiêu chí hoàn thành

- [ ] Mọi ca pass trong CI.
- [ ] Đạt Definition of Done chung ([User_Stories.md §9](../../requirements/User_Stories.md)): code review, CI xanh, đã deploy lên môi trường AWS.

## Kiểm thử

- (Chính là task kiểm thử.)

## Tham chiếu

- [User_Stories.md](../../requirements/User_Stories.md) AC-US-002-1..3
