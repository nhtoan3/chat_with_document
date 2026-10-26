# T-009 — API tải lên PDF (tối giản)

| Thuộc tính | Giá trị |
|---|---|
| Tính năng | F1 — Xử lý PDF |
| Giai đoạn | Sprint 1 — Xử lý PDF + Hỏi đáp AI (09/11 → 20/11/2026) |
| Loại | Backend |
| Ước lượng | 1,5 ngày |
| Phụ trách đề xuất | BE1 |
| Phụ thuộc (phải xong trước) | [T-005](T-005-platform-kernel.md) |
| Mở khóa cho | [T-014](T-014-documents-list-api.md), [T-015](T-015-documents-ui.md), [T-016](T-016-pdf-tests.md) |
| Nhánh git | `feat/T-009-upload-api` |
| Trạng thái | `To do` |

## Mục tiêu

Nhận 1–10 tệp PDF, kiểm tra cơ bản, lưu S3 và xếp hàng xử lý.

## Phạm vi & đặc tả

**`POST /api/v1/documents`** (`multipart/form-data`, trường `files`):

**Kiểm tra cả lô:**

| Điều kiện | Kết quả |
|---|---|
| 0 tệp hoặc > 10 tệp | 422 `too_many_files` |
| Số tài liệu hiện có + số tệp > 50 | 409 `collection_full` |

**Từng tệp** (đọc stream, không nạp cả tệp vào RAM):

| Kiểm tra | `error_code` |
|---|---|
| 5 byte đầu ≠ `%PDF-` | `not_pdf` |
| > 20 MB (dừng ngay khi vượt) | `file_too_large` |
| Trùng tên với tài liệu đã có | `duplicate_name` |

**Tệp hợp lệ:** `id = uuid4()` → `storage.put_stream("documents/{id}.pdf")` → **một transaction** `INSERT documents(status='queued')` + `INSERT ingestion_jobs`.

**Response 202:**

```json
{"items": [{"filename": "a.pdf", "document_id": "…", "status": "queued"},
           {"filename": "b.docx", "error_code": "not_pdf"}]}
```

Một tệp lỗi không ảnh hưởng tệp khác. Chuẩn hóa tên tệp: bỏ đường dẫn, NFC, tối đa 255 ký tự.

## Các bước thực hiện

1. Viết use case `upload` và repository `documents`.
2. Viết route.
3. Viết test (T-016).

## File cần tạo / sửa

- `backend/app/modules/documents/**`
- `backend/app/api/routers/documents.py`

## Tiêu chí hoàn thành

- [ ] Các ca trong 2 bảng trả đúng mã; tải 10 × 20 MB không làm RAM `api` tăng quá 100 MB.
- [ ] Code đã được review, CI xanh, đã deploy lên môi trường AWS.

## Kiểm thử

- Xem T-016.

## Ngoài phạm vi task này

- Kéo-thả, tiến trình theo tệp, hộp thoại trùng tên, audit log.

## Tham chiếu

- [User_Stories.md](../../requirements/User_Stories.md) US-005 (bản tối giản)
