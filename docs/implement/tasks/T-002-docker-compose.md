# T-002 — Môi trường local bằng Docker Compose

| Thuộc tính | Giá trị |
|---|---|
| Tính năng | — (hạng mục nền tảng) |
| Giai đoạn | Sprint 0 — Nền tảng (02/11 → 06/11/2026) |
| Loại | Hạ tầng / DevOps |
| Ước lượng | 1 ngày |
| Phụ trách đề xuất | TL |
| Phụ thuộc (phải xong trước) | [T-001](T-001-repo-skeleton.md) |
| Mở khóa cho | [T-004](T-004-db-migration.md), [T-008](T-008-golden-eval.md), [T-013](T-013-ingest-pipeline.md) |
| Nhánh git | `feat/T-002-docker-compose` |
| Trạng thái | `To do` |

## Mục tiêu

Một lệnh `make dev` dựng đủ các dịch vụ để phát triển.

## Phạm vi & đặc tả

`docker-compose.yml`:

| Service | Image / build | Cổng | Ghi chú |
|---|---|---|---|
| `postgres` | `pgvector/pgvector:pg16` | 5432 | volume `pgdata`; healthcheck |
| `minio` | `minio/minio` | 9000 | thay S3 khi chạy local; tự tạo bucket `cwd-documents-local` |
| `tei` | `ghcr.io/huggingface/text-embeddings-inference:cpu-<phiên bản pin>` | 8080 | `--model-id BAAI/bge-m3`; volume cache model |
| `api` | `backend/Dockerfile` | 8000 | `uvicorn app.api.main:app --reload` |
| `worker` | `backend/Dockerfile` | — | `python -m app.worker.main` |
| `web` | `frontend/` (node:20) | 5173 | Vite dev server, proxy `/api` → `api:8000` |

- **Biến môi trường:** `.env.example` (`DATABASE_URL`, `S3_BUCKET`, `S3_ENDPOINT_URL`, `TEI_URL`, `ANTHROPIC_API_KEY`, `LLM_MODEL`, `QA_TOP_N`, `UPLOAD_MAX_MB`, `UPLOAD_MAX_FILES`, `PDF_MAX_PAGES`, `COLLECTION_MAX_DOCS`).
- **`make seed`:** chạy migration và tải 3 PDF mẫu từ `backend/tests/fixtures/pdfs/sample/`.

## Các bước thực hiện

1. Viết `backend/Dockerfile` (python:3.12-slim, user non-root).
2. Viết `docker-compose.yml`, dùng `depends_on` với điều kiện healthy.
3. Viết `.env.example` và các target `dev`, `seed`.

## File cần tạo / sửa

- `docker-compose.yml`
- `backend/Dockerfile`
- `.env.example`
- `Makefile`

## Tiêu chí hoàn thành

- [ ] `make dev` → mọi container healthy.
- [ ] `curl localhost:8080/embed -d '{"inputs":["xin chào"]}'` trả vector 1024 chiều.
- [ ] `localhost:5173` hiển thị SPA.
- [ ] Code đã được review, CI xanh, đã deploy lên môi trường AWS.

## Kiểm thử

- Developer thứ hai làm theo README và chạy được trong < 30 phút.

## Ngoài phạm vi task này

- Môi trường AWS (T-006).

## Tham chiếu

- [SAD.md](../../design/SAD.md) 'Phạm vi kiến trúc cho MVP'
