# ADR-010: Hàng đợi ingestion bằng PostgreSQL

> Version 0.1 · Trạng thái tài liệu: `Draft` · 2026-11-02 · Chưa được review/duyệt
> Nguồn: `docs/04-design/SAD.md` "Phạm vi kiến trúc cho MVP", §5; `docs/05-development/tasks/T-010-worker-loop.md`; `backend/app/modules/documents/adapters/job_queue.py`

## Status

`Accepted (v0.2)`, ghi nguyên văn theo SAD §5. Repo không có biên bản duyệt riêng cho ADR này.

## Context

SAD v0.2 thu hẹp kiến trúc để rút ngắn thời gian ra mắt. Thiết kế mục tiêu cần Redis 7 + Celery, tức thêm một thành phần vận hành.

## Decision

Bỏ Redis / Celery. Dùng bảng `ingestion_jobs`, worker lấy việc bằng `FOR UPDATE SKIP LOCKED`.

**Hiện trạng code (đúng với quyết định):**

| Tham số | Giá trị | Nguồn |
|---|---|---|
| Chu kỳ poll | 2 s | `platform/config.py:31` |
| Thu hồi job treo | `running` quá 10 phút → `retrying`, kiểm tra mỗi 60 s | `config.py:32`, `worker/main.py:18,30-35` |
| Số lần chạy tối đa | 3 | `config.py:33` |
| Chờ trước lần thử lại | 10 s, rồi 40 s | `job_queue.py:78-80`, `worker/ingest.py:100-107` |
| Hết lượt | `failed`, `error_code = transient_exhausted` | `worker/ingest.py:107` |
| Dừng an toàn | SIGTERM: chạy nốt job hiện tại | `worker/main.py:45-46` |

## Consequences

- Không thêm thành phần vận hành; job được tạo trong cùng transaction với `documents` (`adapters/sql_repo.py:22-30`).
- Có test hai worker không lấy trùng việc và thu hồi việc treo (`docs/05-development/traceability.md`).
- Thu hồi job treo không kiểm tra `attempt` (`job_queue.py:27-32`). Giới hạn số lần chỉ được áp dụng trong `_transient_failure`. Vì vậy một job khiến worker chết liên tục sẽ được nhận lại không giới hạn. Xử lý: [TBD].
- Độ trễ bắt đầu xử lý có thể tới một chu kỳ poll.

## Rejected alternatives

| Phương án | Lý do |
|---|---|
| Redis + Celery | Giữ cho giai đoạn 2 khi cần scale worker (SAD §5) |
