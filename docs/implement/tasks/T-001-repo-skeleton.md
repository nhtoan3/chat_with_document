# T-001 — Khởi tạo repo và cấu trúc mã

| Thuộc tính | Giá trị |
|---|---|
| Tính năng | — (hạng mục nền tảng) |
| Giai đoạn | Sprint 0 — Nền tảng (02/11 → 06/11/2026) |
| Loại | Hạ tầng / DevOps |
| Ước lượng | 1 ngày |
| Phụ trách đề xuất | TL |
| Phụ thuộc (phải xong trước) | Không |
| Mở khóa cho | [T-002](T-002-docker-compose.md), [T-003](T-003-ci.md), [T-007](T-007-frontend-shell.md), [T-011](T-011-pdf-extractor.md) |
| Nhánh git | `feat/T-001-repo-skeleton` |
| Trạng thái | `To do` |

## Mục tiêu

Có monorepo với khung backend (Python 3.12 / FastAPI) và frontend (Vite + React 18 + TypeScript); lệnh `make lint` và `make test` chạy được.

## Phạm vi & đặc tả

**Backend** (`backend/pyproject.toml`):

| Nhóm | Thư viện |
|---|---|
| Runtime | `fastapi`, `uvicorn[standard]`, `sqlalchemy[asyncio]>=2`, `asyncpg`, `psycopg[binary]`, `pgvector`, `alembic`, `pydantic-settings`, `structlog`, `pymupdf`, `tokenizers`, `httpx`, `anthropic`, `boto3`, `python-multipart` |
| Dev | `pytest`, `pytest-asyncio`, `testcontainers[postgres]`, `ruff`, `mypy` |

**Frontend** (`frontend/package.json`):

| Nhóm | Thư viện |
|---|---|
| Runtime | `react@18`, `react-dom@18`, `react-router-dom`, `@tanstack/react-query`, `i18next`, `react-i18next`, `marked`, `dompurify` |
| Dev | `vite`, `typescript`, `vitest`, `@testing-library/react`, `@playwright/test`, `eslint`, `prettier` |

**Cấu trúc thư mục:**

```
backend/app/
  platform/            config.py · db.py · errors.py · logging.py · storage.py
  api/                 main.py · routers/{documents,ask}.py
  modules/documents/   application/ · adapters/ · ingestion/{pdf_extractor,chunker}.py
  modules/qa/          application/ask.py · adapters/{anthropic_llm,tei_embedding,pg_retrieval}.py · prompts.py · ports.py
  worker/              main.py · ingest.py
backend/tests/         unit/ · integration/ · eval/ · fixtures/
frontend/src/          app/ · features/{documents,ask}/ · shared/{api,ui,i18n}/
infra/   Makefile   .pre-commit-config.yaml   README.md
```

## Các bước thực hiện

1. Tạo các thư mục theo cấu trúc trên.
2. Tạo `pyproject.toml`; cấu hình `ruff` và `mypy`.
3. Khởi tạo frontend bằng `npm create vite@latest frontend -- --template react-ts` rồi cài các thư viện.
4. Tạo `Makefile` với các target `dev`, `seed`, `lint`, `test`, `eval`.
5. Viết README: yêu cầu cài đặt (Docker, Python 3.12, Node 20) và các lệnh `make`.

## File cần tạo / sửa

- `backend/pyproject.toml`
- `frontend/package.json`
- `Makefile`
- `README.md`

## Tiêu chí hoàn thành

- [ ] `make lint` và `make test` chạy thành công trên repo trống.
- [ ] `GET /healthz` trả `{"status":"ok"}`.
- [ ] Lock file đã được commit.
- [ ] Code đã được review, CI xanh, đã deploy lên môi trường AWS.

## Kiểm thử

- Một developer khác clone repo và chạy được `make lint`, `make test`.

## Ngoài phạm vi task này

- Docker Compose (T-002), CI (T-003).

## Tham chiếu

- [Blueprint_Design.md](../../design/Blueprint_Design.md) §3.1
