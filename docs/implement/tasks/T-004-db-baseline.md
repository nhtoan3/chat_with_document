# T-004 — Migration CSDL baseline cho MVP

| Thuộc tính | Giá trị |
|---|---|
| Story | — (hạng mục nền tảng) |
| Giai đoạn | Sprint 0 (02/11 → 06/11/2026) |
| Loại | Cơ sở dữ liệu |
| Ước lượng | 1,5 ngày |
| Phụ trách đề xuất | BE1 |
| Phụ thuộc (phải xong trước) | [T-002](T-002-docker-compose.md) |
| Mở khóa cho | [T-005](T-005-platform-kernel.md), [T-101](T-101-session-csrf.md), [T-108](T-108-conversation-owner-repo.md), [T-113](T-113-worker-loop.md) |
| Nhánh git | `feat/T-004-db-baseline` |
| Trạng thái | `To do` |

## Mục tiêu

Alembic revision `0001_mvp` tạo đủ các bảng MVP, có thể nâng cấp và hạ cấp.

## Phạm vi & đặc tả

Dựa trên `docs/design/schema.sql`, nhưng **chỉ tạo** các thành phần sau:

- Extension `vector`, `pg_trgm`, `pgcrypto`, `citext`.
- Các enum.
- Các bảng: `collections`, `users`, `documents`, `ingestion_jobs`, `chunks` (kèm HNSW + chỉ mục), `conversations`, `messages`, `citations`, `audit_log` (**không partition**).
- Bảng mới `sessions`.
- Seed collection `default`.

**Thay đổi so với `schema.sql`:**

```sql
CREATE TABLE sessions (
  id char(64) PRIMARY KEY,                 -- sha256(token)
  user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  csrf_token char(43) NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  last_seen_at timestamptz NOT NULL DEFAULT now(),
  expires_at timestamptz NOT NULL);
CREATE INDEX sessions_user_idx ON sessions (user_id);

-- job_state có thêm 'queued'; ingestion_jobs có thêm cột:
created_at timestamptz NOT NULL DEFAULT now(),
next_run_at timestamptz NOT NULL DEFAULT now()   -- state mặc định 'queued'
CREATE INDEX ingestion_jobs_pick_idx ON ingestion_jobs (next_run_at) WHERE state IN ('queued','retrying');

-- citations: document_id nullable, FK ON DELETE SET NULL; thêm document_title text NOT NULL
-- audit_log: bảng thường, PK bigint identity
```

**Không tạo:** `feedback`, `analytics_events`, view `weekly_usage`, role `cwd_app`. Ứng dụng dùng user DB riêng và không có quyền `TRUNCATE` trên `audit_log`.

## Các bước thực hiện

1. `alembic init backend/app/migrations`; cấu hình `env.py` đọc `DATABASE_URL` (dùng driver sync `psycopg` cho migration).
2. Viết revision `0001_mvp` bằng `op.execute` với SQL thuần (dễ đối chiếu với `schema.sql`).
3. Viết `downgrade()` xóa theo thứ tự ngược lại.
4. Thêm model SQLAlchemy Core (`Table`) tương ứng trong `app/platform/db_schema.py` để repository dùng.

## File cần tạo / sửa

- `backend/app/migrations/versions/0001_mvp.py`
- `backend/app/platform/db_schema.py`

## Tiêu chí hoàn thành

- [ ] `alembic upgrade head` rồi `alembic downgrade base` chạy được trên DB trống.
- [ ] `\d chunks` có chỉ mục `hnsw (embedding vector_cosine_ops)`.
- [ ] Có 1 dòng trong `collections` với `name='default'`.
- [ ] Đạt Definition of Done chung ([User_Stories.md §9](../../requirements/User_Stories.md)): code review, CI xanh, đã deploy lên môi trường AWS.

## Kiểm thử

- Integration test (Testcontainers): upgrade → insert mẫu vào mỗi bảng → downgrade không lỗi.

## Ngoài phạm vi task này

- Partition, tạo partition tự động (giai đoạn 2).

## Tham chiếu

- [docs/design/schema.sql](../../design/schema.sql)
- [SAD.md](../../design/SAD.md) 'Phạm vi kiến trúc cho MVP'
- [Dev_Tasks.md](../Dev_Tasks.md) §2.1
