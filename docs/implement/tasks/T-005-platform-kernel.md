# T-005 — Platform kernel: cấu hình, DB, lỗi, log, audit, lưu trữ tệp

| Thuộc tính | Giá trị |
|---|---|
| Story | — (hạng mục nền tảng) |
| Giai đoạn | Sprint 0 (02/11 → 06/11/2026) |
| Loại | Backend |
| Ước lượng | 2 ngày |
| Phụ trách đề xuất | BE2 |
| Phụ thuộc (phải xong trước) | [T-001](T-001-repo-skeleton.md), [T-004](T-004-db-baseline.md) |
| Mở khóa cho | [T-101](T-101-session-csrf.md), [T-110](T-110-upload-api.md), [T-124](T-124-delete-document-api.md) |
| Nhánh git | `feat/T-005-platform-kernel` |
| Trạng thái | `To do` |

## Mục tiêu

Các tiện ích dùng chung mà mọi module dựa vào, để các story chỉ phải viết logic nghiệp vụ.

## Phạm vi & đặc tả

| File | Nội dung |
|---|---|
| `platform/config.py` | `Settings(BaseSettings)` với toàn bộ biến ở Dev_Tasks.md §0.3; `get_settings()` có cache |
| `platform/db.py` | `create_async_engine` (pool 5, `pool_pre_ping`); dependency `get_db()` cấp 1 `AsyncConnection` / transaction mỗi request |
| `platform/errors.py` | `class AppError(Exception)` với `code: str`, `status: int`, `detail: str = ""`. Handler trả `application/problem+json` `{type: "about:blank", title, status, code, detail}`. Bảng `ERRORS` ánh xạ code → (status, title tiếng Anh) cho ERR-01..20: `unauthenticated 401`, `forbidden 403`, `not_found 404`, `csrf_invalid 403`, `account_locked 423`, `invalid_credentials 401`, `not_pdf 422`, `file_too_large 413`, `too_many_files 422`, `duplicate_name 409`, `collection_full 409`, `question_too_long 422`, `service_unavailable 503`, `storage_error 502`. Exception lạ → 500 `internal_error` và log stacktrace |
| `platform/logging.py` | structlog JSON; middleware gắn `request_id` (header `X-Request-ID` hoặc uuid4), log `method`, `path`, `status`, `latency_ms`, `user_id`. **Không log body** |
| `platform/audit.py` | `async def audit(conn, actor_id, action, target_type=None, target_id=None, details=None, ip=None)` → `INSERT audit_log` trong transaction hiện tại |
| `platform/storage.py` | `ObjectStoragePort` (Protocol) + `S3Storage`: `put_stream(key, fileobj) -> sha256` (multipart upload, `ServerSideEncryption='aws:kms'`; khi chạy local với MinIO thì bỏ KMS), `presign_get(key, ttl, filename) -> url`, `delete_all_versions(key)` |

## Các bước thực hiện

1. Viết từng file theo bảng; giữ cho chúng không phụ thuộc module nghiệp vụ.
2. Đăng ký error handler và middleware log trong `api/main.py`.
3. Viết unit test cho `errors` (định dạng JSON) và `config` (đọc env).
4. Viết integration test cho `S3Storage` với MinIO: put → presign → GET → delete.

## File cần tạo / sửa

- `backend/app/platform/{config,db,errors,logging,audit,storage}.py`
- `backend/app/api/main.py`

## Tiêu chí hoàn thành

- [ ] Ném `AppError('not_pdf')` trong một route thử → client nhận 422 với `code=not_pdf`, content-type `application/problem+json`.
- [ ] Log mỗi request là một dòng JSON có `request_id`.
- [ ] Test với MinIO pass.
- [ ] Đạt Definition of Done chung ([User_Stories.md §9](../../requirements/User_Stories.md)): code review, CI xanh, đã deploy lên môi trường AWS.

## Kiểm thử

- Unit: errors, config. Integration: storage (MinIO), audit (Postgres).

## Ngoài phạm vi task này

- Phiên đăng nhập và CSRF (T-101).

## Tham chiếu

- [Blueprint_Design.md](../../design/Blueprint_Design.md) §3.5.4 (danh mục ERR-xx)
- [SAD.md](../../design/SAD.md) §2.4 (quy ước lỗi RFC 9457)
