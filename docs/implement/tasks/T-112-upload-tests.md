# T-112 — Kiểm thử API tải lên

| Thuộc tính | Giá trị |
|---|---|
| Story | [US-005 — Tải lên PDF](../../requirements/User_Stories.md) |
| Giai đoạn | Sprint 1 (09/11 → 20/11/2026) |
| Loại | Kiểm thử |
| Ước lượng | 0,5 ngày |
| Phụ trách đề xuất | BE1 |
| Phụ thuộc (phải xong trước) | [T-110](T-110-upload-api.md) |
| Mở khóa cho | — |
| Nhánh git | `feat/T-112-upload-tests` |
| Trạng thái | `To do` |

## Mục tiêu

Bộ test tích hợp cho mọi nhánh kiểm tra của API tải lên.

## Phạm vi & đặc tả

| Ca kiểm thử | Kỳ vọng |
|---|---|
| 3 PDF hợp lệ | 202; 3 item `queued`; 3 object trong MinIO; 3 job |
| 11 tệp | 422 `too_many_files`; không lưu gì |
| `.docx` đổi đuôi `.pdf` | item `not_pdf` |
| PDF 21 MB | item `file_too_large` |
| Trùng tên | item `duplicate_name` |
| Đã có 49 tài liệu, gửi 2 | 409 `collection_full` |
| 1 hợp lệ + 1 lỗi | Tệp hợp lệ vẫn được lưu |
| Không có CSRF | 403 |

## Các bước thực hiện

1. Tạo fixture tệp (tạo PDF 21 MB khi chạy test, không commit).
2. Viết test.

## File cần tạo / sửa

- `backend/tests/integration/test_upload.py`

## Tiêu chí hoàn thành

- [ ] Mọi ca pass trong CI.
- [ ] Đạt Definition of Done chung ([User_Stories.md §9](../../requirements/User_Stories.md)): code review, CI xanh, đã deploy lên môi trường AWS.

## Kiểm thử

- (Chính là task kiểm thử.)

## Tham chiếu

- [User_Stories.md](../../requirements/User_Stories.md) US-005
