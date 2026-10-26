# T-002 — Môi trường local bằng Docker Compose

| Thuộc tính | Giá trị |
|---|---|
| Story | — (hạng mục nền tảng) |
| Giai đoạn | Sprint 0 (02/11 → 06/11/2026) |
| Loại | Hạ tầng / DevOps |
| Ước lượng | 1 ngày |
| Phụ trách đề xuất | TL |
| Phụ thuộc (phải xong trước) | [T-001](T-001-repo-skeleton.md) |
| Mở khóa cho | [T-004](T-004-db-baseline.md), [T-009](T-009-poc-embedding.md), [T-010](T-010-golden-eval.md), [T-116](T-116-ingest-pipeline.md) |
| Nhánh git | `feat/T-002-docker-compose` |
| Trạng thái | `To do` |

## Mục tiêu

Một lệnh `make dev` dựng đủ các dịch vụ để phát triển; `make seed` tạo sẵn dữ liệu mẫu.

## Phạm vi & đặc tả

`docker-compose.yml`:

| Service | Image / build | Cổng | Ghi chú |
|---|---|---|---|
| `postgres` | `pgvector/pgvector:pg16` | 5432 | volume `pgdata`; healthcheck `pg_isready` |
| `minio` | `minio/minio` | 9000 / 9001 | thay S3 khi chạy local; container phụ `mc` tạo bucket `cwd-documents-local` |
| `tei` | `ghcr.io/huggingface/text-embeddings-inference:cpu-<phiên bản pin>` | 8080 | `--model-id BAAI/bge-m3 --revision <hash>`; volume cache model |
| `api` | `backend/Dockerfile` | 8000 | `uvicorn app.api.main:app --reload`; mount source |
| `worker` | `backend/Dockerfile` | — | `python -m app.worker.main` |
| `web` | `frontend/` (node:20) | 5173 | Vite dev server, proxy `/api` → `api:8000` |

Biến môi trường local đặt trong `.env.example` (danh sách đầy đủ ở Dev_Tasks.md §0.3); `ANTHROPIC_API_KEY` để trống.

`make seed` chạy `alembic upgrade head`, tạo `admin@local` / `member@local` (dùng CLI T-103 khi đã có, tạm thời insert trực tiếp) và tải 3 PDF mẫu trong `backend/tests/fixtures/pdfs/sample/`.

## Các bước thực hiện

1. Viết `backend/Dockerfile` (multi-stage, user non-root, python:3.12-slim).
2. Viết `docker-compose.yml` theo bảng; dùng `depends_on` với `condition: service_healthy`.
3. Tạo `.env.example`; thêm `.env` vào `.gitignore`.
4. Viết target `dev` và `seed` trong Makefile.
5. Ghi chú trong README: lần chạy đầu TEI tải model khoảng 2,3 GB.

## File cần tạo / sửa

- `docker-compose.yml`
- `backend/Dockerfile`
- `.env.example`
- `Makefile`

## Tiêu chí hoàn thành

- [ ] Trên máy sạch: `make dev` → mọi container ở trạng thái healthy trong vòng 5 phút (không tính lần tải model đầu).
- [ ] `curl localhost:8080/embed -d '{"inputs":["xin chào"]}'` trả về vector 1024 chiều.
- [ ] Truy cập `localhost:5173` thấy SPA; `localhost:8000/healthz` trả 200.
- [ ] Đạt Definition of Done chung ([User_Stories.md §9](../../requirements/User_Stories.md)): code review, CI xanh, đã deploy lên môi trường AWS.

## Kiểm thử

- Developer thứ hai làm theo README và chạy được trong < 30 phút.

## Ngoài phạm vi task này

- Môi trường AWS (T-006).

## Tham chiếu

- [SAD.md](../../design/SAD.md) 'Phạm vi kiến trúc cho MVP'
