# T-113 — Worker xử lý hàng đợi bằng PostgreSQL

| Thuộc tính | Giá trị |
|---|---|
| Story | [US-006 — Trạng thái xử lý tài liệu](../../requirements/User_Stories.md) |
| Giai đoạn | Sprint 1 (09/11 → 20/11/2026) |
| Loại | Backend |
| Ước lượng | 1 ngày |
| Phụ trách đề xuất | BE1 |
| Phụ thuộc (phải xong trước) | [T-004](T-004-db-baseline.md) |
| Mở khóa cho | [T-116](T-116-ingest-pipeline.md) |
| Nhánh git | `feat/T-113-worker-loop` |
| Trạng thái | `To do` |

## Mục tiêu

Tiến trình worker lấy việc an toàn từ bảng `ingestion_jobs` (ADR-010); nhiều worker chạy song song không lấy trùng việc.

## Phạm vi & đặc tả

**`worker/main.py`:**

```python
while not stopping:
    job = await claim_job()        # SQL bên dưới, trong transaction riêng
    if job is None:
        await asyncio.sleep(2); continue
    await run_ingest(job)          # T-116
```

**Truy vấn lấy việc:**

```sql
UPDATE ingestion_jobs j SET state='running', started_at=now(), attempt=j.attempt+1
WHERE j.id = (SELECT id FROM ingestion_jobs
              WHERE state IN ('queued','retrying') AND next_run_at <= now()
              ORDER BY next_run_at FOR UPDATE SKIP LOCKED LIMIT 1)
RETURNING j.id, j.document_id, j.attempt;
```

**Đồng thời:** cập nhật `documents.status='processing'` cho tài liệu tương ứng.

**Việc định kỳ** (kiểm tra mỗi 60 s trong cùng vòng lặp):

- **Job treo:** job `running` có `started_at < now() - 10 phút` → `state='retrying'`, `next_run_at=now()`.
- **Dọn phiên:** xóa phiên hết hạn (T-101) mỗi giờ.

**Dừng an toàn:** bắt SIGTERM → đặt `stopping=True`, chạy nốt job hiện tại rồi thoát.

**Chạy:** 2 bản sao `worker` (`deploy.replicas: 2` hoặc 2 service).

## Các bước thực hiện

1. Viết `worker/main.py` và `documents/adapters/job_queue.py`.
2. Thêm service `worker` vào compose.
3. Viết test.

## File cần tạo / sửa

- `backend/app/worker/main.py`
- `backend/app/modules/documents/adapters/job_queue.py`

## Tiêu chí hoàn thành

- [ ] Với 2 worker và 10 job, mỗi job chỉ được xử lý đúng 1 lần.
- [ ] Kill worker giữa chừng → sau 10 phút job được lấy lại.
- [ ] SIGTERM → worker thoát sau khi xong job hiện tại.
- [ ] Đạt Definition of Done chung ([User_Stories.md §9](../../requirements/User_Stories.md)): code review, CI xanh, đã deploy lên môi trường AWS.

## Kiểm thử

- Integration: 2 coroutine `claim_job` song song trên 10 job → 10 id khác nhau.

## Ngoài phạm vi task này

- Redis / Celery (ADR-010).

## Tham chiếu

- [SAD.md](../../design/SAD.md) ADR-010, 'Phạm vi kiến trúc cho MVP'
