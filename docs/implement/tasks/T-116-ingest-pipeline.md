# T-116 — Pipeline ingestion: embedding và ghi chunk

| Thuộc tính | Giá trị |
|---|---|
| Story | [US-006 — Trạng thái xử lý tài liệu](../../requirements/User_Stories.md) |
| Giai đoạn | Sprint 1 (09/11 → 20/11/2026) |
| Loại | Backend |
| Ước lượng | 1,5 ngày |
| Phụ trách đề xuất | BE1 |
| Phụ thuộc (phải xong trước) | [T-113](T-113-worker-loop.md), [T-114](T-114-pdf-extractor.md), [T-115](T-115-chunker.md), [T-002](T-002-docker-compose.md) |
| Mở khóa cho | [T-120](T-120-pdf-fixtures.md), [T-121](T-121-vector-retrieval.md) |
| Nhánh git | `feat/T-116-ingest-pipeline` |
| Trạng thái | `To do` |

## Mục tiêu

Hoàn tất xử lý một tài liệu: từ tệp trên S3 tới các chunk có vector trong DB, với retry cho lỗi tạm thời.

## Phạm vi & đặc tả

**`worker/ingest.py` → `run_ingest(job)`:**

1. Đọc `documents`; tải tệp từ S3 vào RAM (≤ 20 MB).
2. `pages = extract(bytes, PDF_MAX_PAGES)` (T-114).
3. `chunks = chunk_pages(pages, filename)` (T-115).
4. `vectors = TEIEmbedding.embed([c.embed_text …])`: lô 32, timeout 30 s / lô (`qa/adapters/tei_embedding.py`, gọi `POST {TEI_URL}/embed {"inputs": [...], "normalize": true}`).
5. **Một transaction:** `DELETE chunks WHERE document_id` → `INSERT` toàn bộ chunk (`collection_id`, `chunk_index`, `page_start`, `page_end`, `content`, `token_count`, `embedding`) → `UPDATE documents SET status='ready', pages, ready_at=now()` → `UPDATE ingestion_jobs SET state='succeeded', finished_at, processing_ms`.

**Xử lý lỗi:**

| Loại lỗi | Hành vi |
|---|---|
| `ExtractionError(code)` | `documents.status='failed'`, `error_code=code`; job `failed`; **không retry** |
| Lỗi tạm thời (S3, TEI timeout / 5xx, DB connection) và `attempt < 3` | job `retrying`, `next_run_at = now() + 10s × 4^(attempt-1)` (10 s, 40 s, 160 s); tài liệu giữ `queued` |
| Lỗi tạm thời và `attempt >= 3` | `documents.status='failed'`, `error_code='transient_exhausted'` |

Log mỗi bước kèm `document_id` và `duration_ms`; **không log nội dung**.

## Các bước thực hiện

1. Viết `TEIEmbedding` (port + adapter).
2. Viết `run_ingest`.
3. Viết integration test end-to-end.

## File cần tạo / sửa

- `backend/app/worker/ingest.py`
- `backend/app/modules/qa/adapters/tei_embedding.py`
- `backend/app/modules/qa/ports.py`

## Tiêu chí hoàn thành

- [ ] PDF văn bản 50 trang → `ready` trong ≤ 60 s trên AWS (AC-US-006-1).
- [ ] Tắt TEI → tài liệu retry 3 lần rồi `failed / transient_exhausted`.
- [ ] Một tệp lỗi không ảnh hưởng tệp khác (AC-US-007-7).
- [ ] Đạt Definition of Done chung ([User_Stories.md §9](../../requirements/User_Stories.md)): code review, CI xanh, đã deploy lên môi trường AWS.

## Kiểm thử

- Integration (Testcontainers + TEI thật trong compose, hoặc TEI giả trả vector ngẫu nhiên khi chạy CI).

## Ngoài phạm vi task này

- Re-index khi đổi model embedding.

## Tham chiếu

- [SAD.md](../../design/SAD.md) §3.2.2
- [User_Stories.md](../../requirements/User_Stories.md) AC-US-006-1, AC-US-007-7
