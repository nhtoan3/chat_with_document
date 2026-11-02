# ADR-002: PostgreSQL + pgvector (HNSW) + full-text trong một CSDL

> Version 0.1 · Trạng thái tài liệu: `Draft` · 2026-11-02 · Chưa được review/duyệt
> Nguồn: `docs/04-design/SAD.md` §0.3, §1.2, §3.1, §5; `backend/app/migrations/versions/0001_init.py`

## Status

`Proposed` (theo SAD §5).

## Context

- Cần lưu dữ liệu quan hệ và vector, với ít thành phần vận hành (TC-10).
- SAD ước lượng 30.000 chunk ở giới hạn MVP (50 tài liệu × 300 trang), tổng vector + chỉ mục < 500 MB (SAD §3.1). Đây là ước lượng, chưa đo.
- Cần giao dịch nhất quán giữa `documents` và `chunks`; truy vấn phải lọc được `documents.status = 'ready'` trong cùng câu SQL (SAD §3.1).

## Decision

Dùng một CSDL PostgreSQL 16 với `pgvector` chỉ mục HNSW, kèm full-text trong cùng CSDL.

**Hiện trạng v0.4:**

- Có vector + HNSW: `chunks.embedding vector(1024)`, `m = 16`, `ef_construction = 64`, `vector_cosine_ops` (`0001_init.py:71,77-80`).
- **Chưa có full-text:** `chunks` không có cột `tsv`, không có chỉ mục GIN (xem ADR-003).
- Lược đồ thực tế 4 bảng, xem [`database-design.md`](database-design.md).

## Consequences

- Ingestion ghi `chunks` và chuyển `documents.status = 'ready'` trong một transaction (`worker/ingest.py:69-93`).
- Không cần đồng bộ với hệ thống vector bên ngoài.
- Hàng đợi (ADR-010) cũng dùng CSDL này, nên CSDL là điểm phụ thuộc chung của API và worker.
- Chưa có số đo recall hay độ trễ của truy vấn vector trên dữ liệu thật: [TBD].

## Rejected alternatives

| Phương án | Lý do loại |
|---|---|
| Qdrant, Pinecone | 30k vector là quá nhỏ để cần hệ thống riêng; pgvector cho phép join và giao dịch với dữ liệu quan hệ (SAD §1.2) |
| OpenSearch | SAD §5 liệt kê là phương án đã loại nhưng không ghi lý do riêng: [TBD] |
