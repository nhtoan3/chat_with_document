# T-001 — Khởi tạo repo và cấu trúc mã

| Thuộc tính | Giá trị |
|---|---|
| Story | — (hạng mục nền tảng) |
| Giai đoạn | Sprint 0 (02/11 → 06/11/2026) |
| Loại | Hạ tầng / DevOps |
| Ước lượng | 1 ngày |
| Phụ trách đề xuất | TL |
| Phụ thuộc (phải xong trước) | Không |
| Mở khóa cho | [T-002](T-002-docker-compose.md), [T-003](T-003-ci-pipeline.md), [T-005](T-005-platform-kernel.md), [T-007](T-007-frontend-shell.md), [T-008](T-008-poc-llm-latency.md), [T-114](T-114-pdf-extractor.md) |
| Nhánh git | `feat/T-001-repo-skeleton` |
| Trạng thái | `To do` |

## Mục tiêu

Có monorepo với khung backend (Python 3.12 / FastAPI) và frontend (Vite + React 18 + TypeScript), lệnh `make lint` và `make test` chạy được ngay từ đầu.

## Phạm vi & đặc tả

**Backend** (`backend/pyproject.toml`, quản lý bằng `uv` hoặc `poetry`):

| Nhóm | Thư viện |
|---|---|
| Runtime | `fastapi`, `uvicorn[standard]`, `sqlalchemy[asyncio]>=2`, `asyncpg`, `psycopg[binary]`, `alembic`, `pydantic-settings`, `structlog`, `argon2-cffi`, `pymupdf`, `tokenizers`, `httpx`, `anthropic`, `boto3`, `python-multipart` |
| Dev | `pytest`, `pytest-asyncio`, `testcontainers[postgres]`, `ruff`, `mypy`, `types-boto3` |

**Frontend** (`frontend/package.json`):

| Nhóm | Thư viện |
|---|---|
| Runtime | `react@18`, `react-dom@18`, `react-router-dom`, `@tanstack/react-query`, `i18next`, `react-i18next`, `dompurify`, `marked` |
| Dev | `vite`, `typescript`, `vitest`, `@testing-library/react`, `@playwright/test`, `eslint`, `prettier`, `@axe-core/playwright` |

**Cấu trúc thư mục** (Blueprint §3.1, bản rút gọn cho MVP):

```
backend/app/{platform,api,modules/{identity,documents,qa,conversations},worker}/  backend/tests/{unit,integration,eval}/
frontend/src/{app,features/{auth,documents,chat},shared/{api,ui,i18n}}/
infra/   Makefile   .pre-commit-config.yaml   .editorconfig   README.md
```

Pin phiên bản trong lock file (`uv.lock` / `package-lock.json`).

## Các bước thực hiện

1. Tạo các thư mục theo cấu trúc trên; thêm `__init__.py` cho các package Python.
2. Tạo `pyproject.toml` với các thư viện ở trên; cấu hình `ruff` (line-length 110, rule `E,F,I,B,UP`) và `mypy` (strict cho `app/modules/*/domain`).
3. Khởi tạo frontend bằng `npm create vite@latest frontend -- --template react-ts`, rồi cài các thư viện.
4. Tạo `Makefile` với các target `dev`, `seed`, `lint`, `test`, `eval`, `fmt`.
5. Cài pre-commit: ruff, ruff-format, eslint, prettier, gitleaks.
6. Viết README: yêu cầu cài đặt (Docker, Python 3.12, Node 20) và các lệnh `make`.

## File cần tạo / sửa

- `backend/pyproject.toml`
- `frontend/package.json`
- `Makefile`
- `.pre-commit-config.yaml`
- `README.md`

## Tiêu chí hoàn thành

- [ ] `make lint` và `make test` chạy thành công trên repo trống (0 test cũng là pass).
- [ ] Có `app/main.py` với endpoint `GET /healthz` trả `{"status":"ok"}`.
- [ ] Lock file đã được commit.
- [ ] Đạt Definition of Done chung ([User_Stories.md §9](../../requirements/User_Stories.md)): code review, CI xanh, đã deploy lên môi trường AWS.

## Kiểm thử

- Chạy `make lint`, `make test` trên máy của một developer khác ngoài người tạo.

## Ngoài phạm vi task này

- Docker Compose (T-002) và CI (T-003).

## Tham chiếu

- [Blueprint_Design.md](../../design/Blueprint_Design.md) §3.1
- [SAD.md](../../design/SAD.md) §0.3
