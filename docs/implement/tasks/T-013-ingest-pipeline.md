# T-013 — Pipeline ingestion: embedding và ghi chunk

| Thuộc tính | Giá trị |
|---|---|
| Tính năng | F1 — Xử lý PDF |
| Giai đoạn | Sprint 1 — Xử lý PDF + Hỏi đáp AI (09/11 → 20/11/2026) |
| Loại | Backend |
| Ước lượng | 1,5 ngày |
| Phụ trách đề xuất | BE1 |
| Phụ thuộc (phải xong trước) | [T-010](T-010-worker-loop.md), [T-012](T-012-chunker.md), [T-002](T-002-docker-compose.md) |
| Mở khóa cho | [T-016](T-016-pdf-tests.md), [T-020](T-020-ask-api.md) |
| Nhánh git | `feat/T-013-ingest-pipeline` |
| Trạng thái | `To do` |

## Mục tiêu

Từ tệp trên S3 tới các chunk có vector trong DB, có retry cho lỗi tạm thời.

## Phạm vi & đặc tả

**`worker/ingest.py` → `run_ingest(job)`:**

1. Tải tệp từ S3.
2. `extract` (T-011).
3. `chunk_pages` (T-012).
4. `TEIEmbedding.embed(embed_texts)`: `POST {TEI_URL}/embed {"inputs": [...], "normalize": true}`, lô 32, timeout 30 s.
5. **Một transaction:** xóa chunk cũ → `INSERT` chunk → `documents.status='ready'`, `pages`, `ready_at` → job `succeeded`, `processing_ms`.

**Xử lý lỗi:**

| Loại lỗi | Hành vi |
|---|---|
| `ExtractionError` | `documents.status='failed'`, `error_code=code`; không retry |
| Lỗi tạm thời (S3, TEI, DB), `attempt < 3` | job `retrying`, `next_run_at = now() + 10 s × 4^(attempt-1)` |
| Lỗi tạm thời, hết lượt | `failed`, `error_code='transient_exhausted'` |

## Các bước thực hiện

1. Viết `TEIEmbedding` (`qa/ports.py` + adapter).
2. Viết `run_ingest`.
3. Viết integration test.

## File cần tạo / sửa

- `backend/app/worker/ingest.py`
- `backend/app/modules/qa/adapters/tei_embedding.py`
- `backend/app/modules/qa/ports.py`

## Tiêu chí hoàn thành

- [ ] PDF văn bản 50 trang → `ready` trong ≤ 60 s trên AWS.
- [ ] Tắt TEI → retry 3 lần rồi `failed`.
- [ ] Một tệp lỗi không ảnh hưởng tệp khác.
- [ ] Code đã được review, CI xanh, đã deploy lên môi trường AWS.

## Kiểm thử

- Integration với TEI trong compose.

## Tham chiếu

- [SAD.md](../../design/SAD.md) §3.2.2
