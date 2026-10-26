# T-005 — Platform kernel: cấu hình, DB, lỗi, log, lưu trữ tệp

| Thuộc tính | Giá trị |
|---|---|
| Tính năng | — (hạng mục nền tảng) |
| Giai đoạn | Sprint 0 — Nền tảng (02/11 → 06/11/2026) |
| Loại | Backend |
| Ước lượng | 1 ngày |
| Phụ trách đề xuất | BE2 |
| Phụ thuộc (phải xong trước) | [T-004](T-004-db-migration.md) |
| Mở khóa cho | [T-009](T-009-upload-api.md) |
| Nhánh git | `feat/T-005-platform-kernel` |
| Trạng thái | `To do` |

## Mục tiêu

Các tiện ích dùng chung cho cả hai tính năng.

## Phạm vi & đặc tả

| File | Nội dung |
|---|---|
| `platform/config.py` | `Settings(BaseSettings)` với các biến trong `.env.example`. Mặc định: `UPLOAD_MAX_MB=20`, `UPLOAD_MAX_FILES=10`, `PDF_MAX_PAGES=300`, `COLLECTION_MAX_DOCS=50`, `QA_TOP_N=12`, `LLM_MODEL=claude-opus-5-5`, `LLM_TIMEOUT_S=60` |
| `platform/db.py` | Async engine (pool 5); dependency `get_db()` |
| `platform/errors.py` | `AppError(code, status)` + handler trả `application/problem+json` `{code, title, status}`. Các code: `not_pdf 422`, `file_too_large 413`, `too_many_files 422`, `duplicate_name 409`, `collection_full 409`, `question_invalid 422`, `no_documents 409`, `ai_unavailable 503`, `storage_error 502`. Exception lạ → 500 `internal_error` |
| `platform/logging.py` | structlog JSON, `request_id`; **không log body** (không ghi nội dung tài liệu hay câu hỏi) |
| `platform/storage.py` | `S3Storage`: `put_stream(key, fileobj)`, `get_bytes(key)`; SSE-KMS khi chạy trên AWS |

## Các bước thực hiện

1. Viết các file.
2. Đăng ký handler và middleware trong `api/main.py`.
3. Viết test.

## File cần tạo / sửa

- `backend/app/platform/*.py`
- `backend/app/api/main.py`

## Tiêu chí hoàn thành

- [ ] Ném `AppError('not_pdf')` → 422 problem+json.
- [ ] Log mỗi request là một dòng JSON.
- [ ] Test `S3Storage` với MinIO pass.
- [ ] Code đã được review, CI xanh, đã deploy lên môi trường AWS.

## Kiểm thử

- Unit: errors. Integration: storage (MinIO).

## Ngoài phạm vi task này

- Phiên đăng nhập, CSRF, audit (đã lược bỏ).

## Tham chiếu

- [SAD.md](../../design/SAD.md) §2.4
