-- =============================================================================
-- Chat với tài liệu (MVP) — Lược đồ CSDL tham chiếu
-- Tài liệu: docs/design/Blueprint_Design.md §3.4 (Information View)
-- Nguồn: SAD-CWD-001 §3.1 · PostgreSQL 16 + pgvector 0.7+
-- Ghi chú: Migration thực tế được quản lý bằng Alembic; file này là bản tham chiếu.
-- =============================================================================

CREATE EXTENSION IF NOT EXISTS vector;     -- embedding + HNSW
CREATE EXTENSION IF NOT EXISTS pg_trgm;    -- tìm tên tệp gần đúng
CREATE EXTENSION IF NOT EXISTS pgcrypto;   -- gen_random_uuid()
CREATE EXTENSION IF NOT EXISTS citext;     -- email không phân biệt hoa thường

-- -----------------------------------------------------------------------------
-- Kiểu liệt kê
-- -----------------------------------------------------------------------------
CREATE TYPE user_role         AS ENUM ('member', 'admin');
CREATE TYPE document_status   AS ENUM ('uploading', 'queued', 'processing', 'ready', 'failed', 'removed');
CREATE TYPE message_role      AS ENUM ('user', 'assistant');
CREATE TYPE message_state     AS ENUM ('pending', 'streaming', 'complete', 'not_found', 'stopped', 'incomplete', 'failed');
CREATE TYPE not_found_reason  AS ENUM ('low_relevance', 'model_declined', 'no_citations');
CREATE TYPE feedback_rating   AS ENUM ('up', 'down');
CREATE TYPE job_state         AS ENUM ('running', 'succeeded', 'failed', 'retrying');

-- -----------------------------------------------------------------------------
-- Collection (MVP có 1 collection mặc định; chuẩn bị cho NFR-009)
-- -----------------------------------------------------------------------------
CREATE TABLE collections (
    id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    name        text NOT NULL UNIQUE,
    created_at  timestamptz NOT NULL DEFAULT now()
);

-- -----------------------------------------------------------------------------
-- Người dùng (module identity)
-- -----------------------------------------------------------------------------
CREATE TABLE users (
    id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    email           citext NOT NULL UNIQUE,
    display_name    text NOT NULL CHECK (length(display_name) BETWEEN 1 AND 120),
    role            user_role NOT NULL DEFAULT 'member',
    active          boolean NOT NULL DEFAULT true,
    password_hash   text,                                   -- Argon2id; NULL khi dùng OIDC
    oidc_sub        text UNIQUE,                            -- subject từ IdP; NULL khi dùng mật khẩu
    failed_logins   smallint NOT NULL DEFAULT 0,
    locked_until    timestamptz,                            -- AC-US-001-2
    created_at      timestamptz NOT NULL DEFAULT now(),
    updated_at      timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT users_auth_method_chk CHECK (password_hash IS NOT NULL OR oidc_sub IS NOT NULL)
);

-- -----------------------------------------------------------------------------
-- Tài liệu (module documents)
-- -----------------------------------------------------------------------------
CREATE TABLE documents (
    id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    collection_id   uuid NOT NULL REFERENCES collections(id),
    filename        text NOT NULL CHECK (length(filename) BETWEEN 1 AND 255),
    sha256          char(64) NOT NULL,
    size_bytes      bigint NOT NULL CHECK (size_bytes > 0 AND size_bytes <= 20 * 1024 * 1024),  -- NFR-004
    pages           integer CHECK (pages IS NULL OR pages BETWEEN 1 AND 300),                   -- NFR-005
    status          document_status NOT NULL DEFAULT 'uploading',
    error_code      text,                                   -- xem danh mục lỗi §3.5.4
    storage_key     text NOT NULL UNIQUE,                   -- collections/{cid}/documents/{id}/original.pdf
    uploaded_by     uuid NOT NULL REFERENCES users(id),
    uploaded_at     timestamptz NOT NULL DEFAULT now(),
    ready_at        timestamptz,
    removed_at      timestamptz,
    removed_by      uuid REFERENCES users(id),
    CONSTRAINT documents_failed_has_code_chk CHECK (status <> 'failed' OR error_code IS NOT NULL),
    CONSTRAINT documents_removed_chk CHECK ((status = 'removed') = (removed_at IS NOT NULL))
);
-- EC-08: tên tệp là duy nhất trong collection, chỉ xét tài liệu chưa bị gỡ
CREATE UNIQUE INDEX documents_active_filename_uq ON documents (collection_id, filename) WHERE removed_at IS NULL;
CREATE INDEX documents_collection_status_idx ON documents (collection_id, status);
CREATE INDEX documents_sha256_idx            ON documents (collection_id, sha256);
CREATE INDEX documents_filename_trgm_idx     ON documents USING gin (filename gin_trgm_ops);
CREATE INDEX documents_purge_idx             ON documents (removed_at) WHERE status = 'removed';

CREATE TABLE ingestion_jobs (
    id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    document_id     uuid NOT NULL REFERENCES documents(id) ON DELETE CASCADE,
    attempt         smallint NOT NULL DEFAULT 1 CHECK (attempt BETWEEN 1 AND 4),
    state           job_state NOT NULL DEFAULT 'running',
    error           text,
    processing_ms   integer,
    started_at      timestamptz NOT NULL DEFAULT now(),
    finished_at     timestamptz
);
CREATE INDEX ingestion_jobs_document_idx ON ingestion_jobs (document_id, started_at DESC);

-- Đoạn văn bản + vector. Một chunk không vượt ranh giới trang (ADR-006), trừ trang ngắn được gộp
CREATE TABLE chunks (
    id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    document_id     uuid NOT NULL REFERENCES documents(id) ON DELETE CASCADE,
    collection_id   uuid NOT NULL REFERENCES collections(id),   -- phi chuẩn hóa để lọc nhanh
    chunk_index     integer NOT NULL CHECK (chunk_index >= 0),
    page_start      integer NOT NULL CHECK (page_start >= 1),
    page_end        integer NOT NULL,
    content         text NOT NULL,
    token_count     integer NOT NULL CHECK (token_count BETWEEN 1 AND 800),
    embedding       vector(1024) NOT NULL,                       -- BAAI/bge-m3
    tsv             tsvector GENERATED ALWAYS AS (to_tsvector('simple', content)) STORED,
    CONSTRAINT chunks_page_range_chk CHECK (page_end >= page_start),
    CONSTRAINT chunks_document_index_uq UNIQUE (document_id, chunk_index)
);
CREATE INDEX chunks_embedding_hnsw_idx ON chunks USING hnsw (embedding vector_cosine_ops) WITH (m = 16, ef_construction = 64);
CREATE INDEX chunks_tsv_gin_idx        ON chunks USING gin (tsv);
CREATE INDEX chunks_collection_idx     ON chunks (collection_id);

-- -----------------------------------------------------------------------------
-- Hội thoại (module conversations + qa)
-- -----------------------------------------------------------------------------
CREATE TABLE conversations (
    id                uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id           uuid NOT NULL REFERENCES users(id),
    collection_id     uuid NOT NULL REFERENCES collections(id),
    title             text NOT NULL DEFAULT 'Hội thoại mới' CHECK (length(title) <= 200),
    created_at        timestamptz NOT NULL DEFAULT now(),
    last_activity_at  timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX conversations_user_activity_idx ON conversations (user_id, last_activity_at DESC);

CREATE TABLE messages (
    id                   uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_id      uuid NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
    role                 message_role NOT NULL,
    content              text NOT NULL DEFAULT '',
    standalone_question  text,                               -- câu hỏi đã viết lại (FR-019)
    state                message_state NOT NULL DEFAULT 'pending',
    not_found_reason     not_found_reason,
    latency_ms           integer,
    first_token_ms       integer,
    model                text,                               -- vd. claude-opus-5-5
    input_tokens         integer,
    output_tokens        integer,
    cache_read_tokens    integer,
    created_at           timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT messages_user_len_chk CHECK (role <> 'user' OR length(content) BETWEEN 1 AND 2000),  -- AC-US-011-3
    CONSTRAINT messages_not_found_chk CHECK ((state = 'not_found') = (not_found_reason IS NOT NULL))
);
CREATE INDEX messages_conversation_idx ON messages (conversation_id, created_at);

CREATE TABLE citations (
    id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    message_id    uuid NOT NULL REFERENCES messages(id) ON DELETE CASCADE,
    idx           smallint NOT NULL CHECK (idx >= 1),
    chunk_id      uuid REFERENCES chunks(id) ON DELETE SET NULL,     -- NULL sau khi purge (EC-10)
    document_id   uuid NOT NULL REFERENCES documents(id) ON DELETE CASCADE,
    page_start    integer NOT NULL,
    page_end      integer NOT NULL,
    cited_text    text NOT NULL CHECK (length(cited_text) <= 2000),
    CONSTRAINT citations_message_idx_uq UNIQUE (message_id, idx)
);
CREATE INDEX citations_document_idx ON citations (document_id);

CREATE TABLE feedback (
    message_id   uuid PRIMARY KEY REFERENCES messages(id) ON DELETE CASCADE,
    user_id      uuid NOT NULL REFERENCES users(id),
    rating       feedback_rating NOT NULL,
    comment      text CHECK (comment IS NULL OR length(comment) <= 1000),
    created_at   timestamptz NOT NULL DEFAULT now()
);

-- -----------------------------------------------------------------------------
-- Sự kiện analytics (module analytics) — partition theo tháng, giữ 12 tháng
-- Không chứa nội dung câu hỏi / câu trả lời / tài liệu (PRD §6.2)
-- -----------------------------------------------------------------------------
CREATE TABLE analytics_events (
    id           bigint GENERATED ALWAYS AS IDENTITY,
    name         text NOT NULL,
    user_ref     text NOT NULL,                         -- HMAC-SHA256(user_id), không lưu user_id gốc
    props        jsonb NOT NULL DEFAULT '{}'::jsonb,
    occurred_at  timestamptz NOT NULL DEFAULT now(),
    PRIMARY KEY (id, occurred_at)
) PARTITION BY RANGE (occurred_at);
CREATE INDEX analytics_events_name_time_idx ON analytics_events (name, occurred_at);

-- -----------------------------------------------------------------------------
-- Audit log (NFR-014) — chỉ ghi thêm, partition theo tháng, giữ 12 tháng
-- -----------------------------------------------------------------------------
CREATE TABLE audit_log (
    id           bigint GENERATED ALWAYS AS IDENTITY,
    actor_id     uuid,                                  -- NULL cho đăng nhập thất bại với email không tồn tại
    action       text NOT NULL,                         -- login_success | login_failed | document_upload | document_remove | document_replace | user_create | user_update | role_change
    target_type  text,
    target_id    uuid,
    ip           inet,
    details      jsonb NOT NULL DEFAULT '{}'::jsonb,
    at           timestamptz NOT NULL DEFAULT now(),
    PRIMARY KEY (id, at)
) PARTITION BY RANGE (at);
CREATE INDEX audit_log_actor_time_idx ON audit_log (actor_id, at);

-- Partition khởi tạo; các tháng tiếp theo do job maintenance tạo trước 1 tháng
CREATE TABLE analytics_events_2026_10 PARTITION OF analytics_events FOR VALUES FROM ('2026-10-01') TO ('2026-11-01');
CREATE TABLE analytics_events_2026_11 PARTITION OF analytics_events FOR VALUES FROM ('2026-11-01') TO ('2026-12-01');
CREATE TABLE analytics_events_2026_12 PARTITION OF analytics_events FOR VALUES FROM ('2026-12-01') TO ('2027-01-01');
CREATE TABLE audit_log_2026_10 PARTITION OF audit_log FOR VALUES FROM ('2026-10-01') TO ('2026-11-01');
CREATE TABLE audit_log_2026_11 PARTITION OF audit_log FOR VALUES FROM ('2026-11-01') TO ('2026-12-01');
CREATE TABLE audit_log_2026_12 PARTITION OF audit_log FOR VALUES FROM ('2026-12-01') TO ('2027-01-01');

-- -----------------------------------------------------------------------------
-- Báo cáo tuần cho bảng số liệu Admin (US-022, MET-003)
-- -----------------------------------------------------------------------------
CREATE VIEW weekly_usage AS
SELECT date_trunc('week', occurred_at)                                   AS week,
       count(DISTINCT user_ref) FILTER (WHERE name = 'question_submitted') AS active_users,
       count(*) FILTER (WHERE name = 'question_submitted')                 AS questions,
       count(*) FILTER (WHERE name = 'answer_completed' AND (props->>'not_found')::boolean) AS not_found_answers,
       count(*) FILTER (WHERE name = 'answer_feedback' AND props->>'rating' = 'up')         AS helpful,
       count(*) FILTER (WHERE name = 'answer_feedback')                                      AS rated
FROM analytics_events
GROUP BY 1;

-- -----------------------------------------------------------------------------
-- Phân quyền CSDL: role ứng dụng không được sửa / xóa audit log
-- -----------------------------------------------------------------------------
CREATE ROLE cwd_app NOLOGIN;
GRANT SELECT, INSERT, UPDATE, DELETE ON
    collections, users, documents, ingestion_jobs, chunks,
    conversations, messages, citations, feedback, analytics_events
    TO cwd_app;
GRANT SELECT, INSERT ON audit_log TO cwd_app;
REVOKE UPDATE, DELETE, TRUNCATE ON audit_log FROM cwd_app;
GRANT SELECT ON weekly_usage TO cwd_app;

-- -----------------------------------------------------------------------------
-- Dữ liệu khởi tạo
-- -----------------------------------------------------------------------------
INSERT INTO collections (name) VALUES ('default');
