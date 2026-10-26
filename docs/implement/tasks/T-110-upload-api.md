# T-110 — API tải lên PDF

| Thuộc tính | Giá trị |
|---|---|
| Story | [US-005 — Tải lên PDF](../../requirements/User_Stories.md) |
| Giai đoạn | Sprint 1 (09/11 → 20/11/2026) |
| Loại | Backend |
| Ước lượng | 2 ngày |
| Phụ trách đề xuất | BE1 |
| Phụ thuộc (phải xong trước) | [T-005](T-005-platform-kernel.md), [T-101](T-101-session-csrf.md) |
| Mở khóa cho | [T-106](T-106-file-endpoint.md), [T-111](T-111-upload-ui.md), [T-112](T-112-upload-tests.md), [T-117](T-117-documents-list-api.md), [T-124](T-124-delete-document-api.md) |
| Nhánh git | `feat/T-110-upload-api` |
| Trạng thái | `To do` |

## Mục tiêu

Nhận 1–10 tệp PDF, kiểm tra từng tệp, lưu S3 và xếp hàng xử lý; tệp lỗi không ảnh hưởng tệp khác.

## Phạm vi & đặc tả

**`POST /api/v1/documents`** (`multipart/form-data`, trường `files` lặp lại; cần đăng nhập và CSRF).

**Kiểm tra cả lô (trước khi lưu bất kỳ tệp nào):**

| Điều kiện | Kết quả |
|---|---|
| Số tệp = 0 hoặc > `UPLOAD_MAX_FILES` (10) | 422 `too_many_files` |
| Số tài liệu chưa gỡ + số tệp > `COLLECTION_MAX_DOCS` (50) | 409 `collection_full` |

**Từng tệp** (đọc dạng stream bằng `UploadFile`, **không** đọc cả tệp vào RAM):

| Kiểm tra | `error_code` |
|---|---|
| 5 byte đầu ≠ `%PDF-` | `not_pdf` |
| Đếm byte vượt 20 MB (dừng ngay khi vượt) | `file_too_large` |
| Tên tệp đã tồn tại trong collection (chỉ mục `documents_active_filename_uq`) | `duplicate_name` |

**Tệp hợp lệ:**

1. Tạo `document_id = uuid4()`.
2. `sha256 = storage.put_stream("collections/{cid}/documents/{id}/original.pdf", file)`.
3. Trong **một** transaction: `INSERT documents(status='queued', size_bytes, sha256, uploaded_by, filename)` + `INSERT ingestion_jobs(document_id)` + `audit('document_upload', target=document)`.
4. Lỗi S3 → item lỗi `storage_error`; lỗi DB sau khi đã lưu S3 → xóa object vừa lưu.

**Response 202:**

```json
{"items": [
  {"filename": "a.pdf", "document_id": "…", "status": "queued"},
  {"filename": "b.docx", "error_code": "not_pdf"}
]}
```

Chuẩn hóa tên tệp: bỏ đường dẫn (`os.path.basename`), NFC, tối đa 255 ký tự.

## Các bước thực hiện

1. Viết `documents/application/upload.py` (use case) và repository `documents`.
2. Viết route; dùng `python-multipart` với giới hạn kích thước request 210 MB ở Nginx (`client_max_body_size`).
3. Viết test (T-112).

## File cần tạo / sửa

- `backend/app/modules/documents/**`
- `backend/app/api/routers/documents.py`
- `infra/nginx.conf`

## Tiêu chí hoàn thành

- [ ] AC-US-005-2, 4, 5, 7 pass.
- [ ] Tải 10 tệp × 20 MB không làm RAM tiến trình `api` tăng quá 100 MB.
- [ ] Audit log có bản ghi `document_upload` cho mỗi tệp hợp lệ.
- [ ] Đạt Definition of Done chung ([User_Stories.md §9](../../requirements/User_Stories.md)): code review, CI xanh, đã deploy lên môi trường AWS.

## Kiểm thử

- Xem T-112.

## Ngoài phạm vi task này

- Idempotency-Key, hộp thoại trùng tên (US-024 hoãn).

## Tham chiếu

- [User_Stories.md](../../requirements/User_Stories.md) US-005, §2.1
- [SAD.md](../../design/SAD.md) §2.4, §3.2.2
