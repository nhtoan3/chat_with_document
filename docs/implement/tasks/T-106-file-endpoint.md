# T-106 — Endpoint tải tệp PDF bằng presigned URL

| Thuộc tính | Giá trị |
|---|---|
| Story | [US-002 — Truy cập tệp an toàn](../../requirements/User_Stories.md) |
| Giai đoạn | Sprint 1 (09/11 → 20/11/2026) |
| Loại | Backend |
| Ước lượng | 0,5 ngày |
| Phụ trách đề xuất | BE1 |
| Phụ thuộc (phải xong trước) | [T-101](T-101-session-csrf.md), [T-110](T-110-upload-api.md) |
| Mở khóa cho | [T-107](T-107-file-access-tests.md), [T-222](T-222-open-citation.md) |
| Nhánh git | `feat/T-106-file-endpoint` |
| Trạng thái | `To do` |

## Mục tiêu

Chỉ người đã đăng nhập mới mở được PDF; đường dẫn tải hết hạn sau 5 phút.

## Phạm vi & đặc tả

**`GET /api/v1/documents/{id}/file?page=N`** (cần `current_user`):

1. Tài liệu không tồn tại hoặc `status != 'ready'` → 404 `not_found`.
2. `url = storage.presign_get(key, ttl=300, filename=doc.filename)`, với tham số `ResponseContentType='application/pdf'` và `ResponseContentDisposition='inline; filename*=UTF-8''<tên đã encode>'`.
3. Nếu có `page` (số nguyên từ 1 tới `doc.pages`) → nối thêm `#page=N` vào URL.
4. Trả **302** với header `Location: url` và `Cache-Control: no-store`.

Endpoint này cũng phục vụ US-017 (T-222).

## Các bước thực hiện

1. Thêm route vào `routers/documents.py`.
2. Viết test.

## File cần tạo / sửa

- `backend/app/api/routers/documents.py`

## Tiêu chí hoàn thành

- [ ] Chưa đăng nhập → 401; đã đăng nhập → 302 tới URL S3 tải được PDF (AC-US-002-1, 2).
- [ ] Dùng lại URL sau 5 phút → S3 trả 403 (AC-US-002-3).
- [ ] `page=0` hoặc `page` vượt số trang → bỏ qua tham số (không lỗi).
- [ ] Đạt Definition of Done chung ([User_Stories.md §9](../../requirements/User_Stories.md)): code review, CI xanh, đã deploy lên môi trường AWS.

## Kiểm thử

- Integration (MinIO): các ca trên; giả lập TTL ngắn để test hết hạn.

## Ngoài phạm vi task này

- Trình xem PDF trong ứng dụng (đã đơn giản hóa).

## Tham chiếu

- [User_Stories.md](../../requirements/User_Stories.md) US-002, US-017
- [SAD.md](../../design/SAD.md) §2.4
