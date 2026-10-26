# Chat với tài liệu (MVP)

Ứng dụng web cho đội phát triển kinh doanh: tải các tệp PDF của dự án lên, rồi hỏi đáp bằng tiếng Việt. AI (Claude) trả lời **chỉ dựa trên nội dung các tài liệu đã tải lên**.

Phạm vi MVP v0.4 gồm 2 tính năng: **F1 — Xử lý PDF** và **F2 — Hỏi đáp AI**. Không có đăng nhập; truy cập được giới hạn theo IP / VPN công ty ở tầng mạng. Xem [docs/implement/Implement_plan.md](docs/implement/Implement_plan.md).

## Kiến trúc

```
Trình duyệt ─► web (React SPA, Nginx) ─► api (FastAPI) ─► PostgreSQL 16 + pgvector
                                            │   └──────► Anthropic API (Claude)
                                            └──► S3 (tệp PDF)
worker (Python) ─► S3 → PyMuPDF → chunk → TEI (bge-m3, tự vận hành) → pgvector
```

| Thư mục | Nội dung |
|---|---|
| `backend/app/platform/` | Cấu hình, DB, lỗi problem+json, log JSON, lưu trữ S3 |
| `backend/app/modules/documents/` | Tải lên, hàng đợi xử lý, trích xuất PDF, chunker |
| `backend/app/modules/qa/` | Truy xuất vector, prompt, adapter Claude, use case hỏi đáp |
| `backend/app/worker/` | Tiến trình xử lý tài liệu |
| `backend/tests/` | Test đơn vị, test tích hợp (Testcontainers), golden set (`eval/`) |
| `frontend/src/` | SPA: trang Tài liệu và Hỏi đáp |
| `infra/` | Compose production, script deploy / rollback, hướng dẫn dựng AWS |
| `docs/` | BRD, PRD, SAD, thiết kế, kế hoạch và task |

## Chạy local

Yêu cầu: Docker, Python 3.12, Node 20.

```bash
cp .env.example .env          # điền ANTHROPIC_API_KEY để hỏi đáp được
make venv                     # virtualenv backend + dependencies
make dev                      # postgres, s3 (S3Mock), tei, api, worker, web
make seed                     # tải 3 PDF mẫu lên
```

- Web: http://localhost:5173 · API docs: http://localhost:8000/api/v1/docs
- Lần chạy đầu, TEI tải model `BAAI/bge-m3` (~2,3 GB). Image TEI CPU chỉ có bản amd64; trên Mac Apple Silicon chạy qua giả lập nên chậm.

## Kiểm tra chất lượng

```bash
make lint        # ruff + mypy, eslint + tsc
make test        # pytest (unit + tích hợp, cần Docker) và vitest
make eval BASE_URL=http://localhost:8000   # chạy golden set; chấm cột correct rồi `make eval-score`
```

## Deploy

Xem [infra/README.md](infra/README.md). Chạy `make eval` trước mỗi lần deploy lên môi trường có người dùng pilot.
