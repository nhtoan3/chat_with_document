# T-016 — Bộ tệp mẫu và kiểm thử Xử lý PDF

| Thuộc tính | Giá trị |
|---|---|
| Tính năng | F1 — Xử lý PDF |
| Giai đoạn | Sprint 1 — Xử lý PDF + Hỏi đáp AI (09/11 → 20/11/2026) |
| Loại | Kiểm thử |
| Ước lượng | 1 ngày |
| Phụ trách đề xuất | BE1 |
| Phụ thuộc (phải xong trước) | [T-009](T-009-upload-api.md), [T-013](T-013-ingest-pipeline.md) |
| Mở khóa cho | — |
| Nhánh git | `feat/T-016-pdf-tests` |
| Trạng thái | `To do` |

## Mục tiêu

Test tích hợp cho tải lên và ingestion, với bộ tệp lỗi mẫu.

## Phạm vi & đặc tả

**Fixture** (`tests/fixtures/make_pdfs.py` sinh lại được):

- `encrypted.pdf`, `scanned.pdf`, `corrupted.pdf`, `fake.pdf` (docx đổi đuôi);
- `301_pages.pdf` (sinh khi chạy test);
- `sample/*.pdf`: 3 PDF tiếng Việt có văn bản.

| Ca kiểm thử | Kỳ vọng |
|---|---|
| 3 PDF hợp lệ | 202 → ingest → `ready`, có chunk |
| 11 tệp | 422 `too_many_files` |
| `fake.pdf` | `not_pdf` |
| PDF 21 MB | `file_too_large` |
| Trùng tên | `duplicate_name` |
| `encrypted.pdf` / `scanned.pdf` / `corrupted.pdf` / `301_pages.pdf` | `failed` với mã tương ứng |

## Các bước thực hiện

1. Viết script tạo fixture.
2. Viết test.

## File cần tạo / sửa

- `backend/tests/fixtures/*`
- `backend/tests/integration/test_documents.py`

## Tiêu chí hoàn thành

- [ ] Mọi ca pass trong CI.
- [ ] Code đã được review, CI xanh, đã deploy lên môi trường AWS.

## Kiểm thử

- (Chính là task kiểm thử.)

## Tham chiếu

- [User_Stories.md](../../requirements/User_Stories.md) US-005, US-007
