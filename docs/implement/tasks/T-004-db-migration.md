# T-004 — Migration CSDL

| Thuộc tính | Giá trị |
|---|---|
| Tính năng | — (hạng mục nền tảng) |
| Giai đoạn | Sprint 0 — Nền tảng (02/11 → 06/11/2026) |
| Loại | Cơ sở dữ liệu |
| Ước lượng | 0,5 ngày |
| Phụ trách đề xuất | BE1 |
| Phụ thuộc (phải xong trước) | [T-002](T-002-docker-compose.md) |
| Mở khóa cho | [T-005](T-005-platform-kernel.md), [T-010](T-010-worker-loop.md), [T-017](T-017-vector-retrieval.md) |
| Nhánh git | `feat/T-004-db-migration` |
| Trạng thái | `To do` |

## Mục tiêu

Alembic revision `0001_init` tạo các bảng cần cho Xử lý PDF và Hỏi đáp AI.

## Phạm vi & đặc tả

Chỉ gồm 4 bảng (không có `users`, `sessions`, `conversations`, `messages`, `citations`, `audit_log`):

```sql
CREATE EXTENSION IF NOT EXISTS vector;
CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE TYPE document_status AS ENUM ('queued','processing','ready','failed');
CREATE TYPE job_state AS ENUM ('queued','running','retrying','succeeded','failed');

CREATE TABLE documents (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  filename text NOT NULL UNIQUE,
  size_bytes bigint NOT NULL,
  pages integer,
  status document_status NOT NULL DEFAULT 'queued',
  error_code text,
  storage_key text NOT NULL UNIQUE,
  uploaded_at timestamptz NOT NULL DEFAULT now(),
  ready_at timestamptz);

CREATE TABLE ingestion_jobs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  document_id uuid NOT NULL REFERENCES documents(id) ON DELETE CASCADE,
  state job_state NOT NULL DEFAULT 'queued',
  attempt smallint NOT NULL DEFAULT 0,
  error text,
  created_at timestamptz NOT NULL DEFAULT now(),
  next_run_at timestamptz NOT NULL DEFAULT now(),
  started_at timestamptz, finished_at timestamptz, processing_ms integer);
CREATE INDEX ingestion_jobs_pick_idx ON ingestion_jobs (next_run_at) WHERE state IN ('queued','retrying');

CREATE TABLE chunks (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  document_id uuid NOT NULL REFERENCES documents(id) ON DELETE CASCADE,
  chunk_index integer NOT NULL,
  page_start integer NOT NULL, page_end integer NOT NULL,
  content text NOT NULL,
  token_count integer NOT NULL,
  embedding vector(1024) NOT NULL,
  UNIQUE (document_id, chunk_index));
CREATE INDEX chunks_embedding_hnsw_idx ON chunks USING hnsw (embedding vector_cosine_ops) WITH (m=16, ef_construction=64);

-- Nhật ký hỏi đáp để đo mức sử dụng trong pilot (KHÔNG lưu nội dung câu hỏi / câu trả lời)
CREATE TABLE qa_log (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  created_at timestamptz NOT NULL DEFAULT now(),
  status text NOT NULL,                 -- ok | error
  latency_ms integer, input_tokens integer, output_tokens integer, chunk_count integer);
```

## Các bước thực hiện

1. `alembic init`; `env.py` đọc `DATABASE_URL`.
2. Viết revision `0001_init` bằng SQL thuần.
3. Viết `downgrade()`.

## File cần tạo / sửa

- `backend/app/migrations/versions/0001_init.py`
- `backend/app/platform/db_schema.py`

## Tiêu chí hoàn thành

- [ ] `alembic upgrade head` và `downgrade base` chạy được trên DB trống.
- [ ] Có chỉ mục HNSW trên `chunks.embedding`.
- [ ] Code đã được review, CI xanh, đã deploy lên môi trường AWS.

## Kiểm thử

- Integration (Testcontainers): upgrade → insert mẫu → downgrade.

## Ngoài phạm vi task này

- Các bảng người dùng, hội thoại, trích dẫn (đã lược bỏ).

## Tham chiếu

- [docs/design/schema.sql](../../design/schema.sql) (bản mục tiêu)
