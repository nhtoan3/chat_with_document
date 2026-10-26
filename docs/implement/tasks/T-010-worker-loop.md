# T-010 — Worker xử lý hàng đợi bằng PostgreSQL

| Thuộc tính | Giá trị |
|---|---|
| Tính năng | F1 — Xử lý PDF |
| Giai đoạn | Sprint 1 — Xử lý PDF + Hỏi đáp AI (09/11 → 20/11/2026) |
| Loại | Backend |
| Ước lượng | 1 ngày |
| Phụ trách đề xuất | BE1 |
| Phụ thuộc (phải xong trước) | [T-004](T-004-db-migration.md) |
| Mở khóa cho | [T-013](T-013-ingest-pipeline.md) |
| Nhánh git | `feat/T-010-worker-loop` |
| Trạng thái | `To do` |

## Mục tiêu

Tiến trình worker lấy việc an toàn từ `ingestion_jobs`; 2 worker chạy song song không lấy trùng việc.

## Phạm vi & đặc tả

**Vòng lặp** (`worker/main.py`): poll mỗi 2 s.

**Truy vấn lấy việc:**

```sql
UPDATE ingestion_jobs j SET state='running', started_at=now(), attempt=j.attempt+1
WHERE j.id = (SELECT id FROM ingestion_jobs
              WHERE state IN ('queued','retrying') AND next_run_at <= now()
              ORDER BY next_run_at FOR UPDATE SKIP LOCKED LIMIT 1)
RETURNING j.id, j.document_id, j.attempt;
```

Đồng thời đặt `documents.status='processing'`.

- **Job treo:** job `running` quá 10 phút → `retrying` (kiểm tra mỗi 60 s).
- **Dừng an toàn:** SIGTERM → chạy nốt job hiện tại rồi thoát.
- **Chạy:** 2 bản sao `worker`.

## Các bước thực hiện

1. Viết `worker/main.py` và `job_queue.py`.
2. Thêm vào compose.
3. Viết test.

## File cần tạo / sửa

- `backend/app/worker/main.py`
- `backend/app/modules/documents/adapters/job_queue.py`

## Tiêu chí hoàn thành

- [ ] 2 worker + 10 job → mỗi job xử lý đúng 1 lần.
- [ ] Kill worker giữa chừng → job được lấy lại sau 10 phút.
- [ ] Code đã được review, CI xanh, đã deploy lên môi trường AWS.

## Kiểm thử

- Integration: 2 coroutine song song trên 10 job.

## Ngoài phạm vi task này

- Redis / Celery.

## Tham chiếu

- [SAD.md](../../design/SAD.md) ADR-010
