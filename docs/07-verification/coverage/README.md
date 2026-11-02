# Báo cáo độ phủ — Chat với tài liệu (MVP v0.4)

| Mục | Giá trị |
|---|---|
| Ngày đo | 2026-11-02 (chạy local, không qua CI) |
| Commit | `c02cc72` (cây làm việc có thay đổi tài liệu chưa commit; không có thay đổi trong `backend/`, `frontend/`) |
| Công cụ | Backend: `pytest-cov 7.1.0` (`coverage 7.17.0`), `pytest 8.4.2`, Python 3.12.16. Frontend: `@vitest/coverage-v8@2.1.9`, `vitest 2.1.9`. Cài ngoài manifest (`pip install`, `npm i --no-save`) |
| Mục tiêu | ≥ 70% theo quy trình (`sdlc/agentic-sdlc-process.md`, L0). Lưu ý: Test_Plan v0.2 §5 ghi "đo độ phủ" nằm trong phần lược bỏ của MVP, nên đây là số đo theo quy trình, không phải tiêu chí của Test_Plan |

## Tổng hợp

| Phần | Kết quả test | Độ phủ dòng | So với ≥ 70% |
|---|---|---|---|
| Backend (`--cov=app`) | 50 passed (gồm integration Testcontainers), 0 failed | **76%** (581 / 768 dòng, `line-rate` 0,7565) | ✅ Đạt |
| Frontend (mọi tệp, gồm `e2e/`) | 15 passed, 0 failed | **7,11%** (97 / 1363 dòng) | ❌ Không đạt |
| Frontend (bỏ `frontend/e2e/`, tính tay từ `coverage-summary.json`) | như trên | **9,87%** (97 / 983 dòng); nhánh 58,5%; hàm 30,0% | ❌ Không đạt |

Frontend thấp vì `vitest` chỉ có 4 tệp test logic (`validate`, `markdown`, `client`); các trang và thành phần React không có unit test. Chúng được chạy qua Playwright E2E (`test_reports/E2E-*`), nhưng phần đó **không** được tính vào số trên. Số liệu này là thực đo, không ước lượng phần E2E.

## Backend theo package

| Package | Dòng | Phủ |
|---|---|---|
| `api` | 40 | 80,0% |
| `api.routers` | 58 | 72,4% |
| `modules.documents.adapters` | 50 | 92,0% |
| `modules.documents.application` | 84 | 65,5% |
| `modules.documents.ingestion` | 142 | 84,5% |
| `modules.qa` | 29 | 100% |
| `modules.qa.adapters` | 71 | 74,6% |
| `modules.qa.application` | 35 | 100% |
| `platform` | 153 | 77,1% |
| `worker` | 106 | 48,1% |

Điểm yếu theo tệp: `worker/main.py` 0% (vòng lặp worker, liên quan DEF-05), `platform/storage.py` 36% (adapter S3, liên quan DEF-01), `qa/adapters/tei_embedding.py` 30%. Thư mục `app/migrations` không xuất hiện trong báo cáo.

## Frontend theo package

| Package | Dòng | Phủ dòng | Nhánh |
|---|---|---|---|
| `src` | 15 | 0% | 0 / 1 |
| `src/app` | 112 | 0% | 0 / 3 |
| `src/features/ask` | 247 | 7,3% | 3 / 5 |
| `src/features/documents` | 276 | 7,6% | 11 / 14 |
| `src/shared/api` | 108 | 42,6% | 17 / 21 |
| `src/shared/i18n` | 24 | 50,0% | 0 / 1 |
| `src/shared/ui` | 201 | 0% | 0 / 8 |
| `e2e` (công cụ test, không phải sản phẩm) | 380 | 0% | 0 / 3 |

## Tệp trong thư mục này

- [backend-term.txt](backend-term.txt): output pytest + bảng theo tệp
- [backend-coverage.xml](backend-coverage.xml): Cobertura XML
- [backend-html/index.html](backend-html/index.html): HTML (912 KB, dưới ngưỡng 2 MB nên giữ lại)
- [frontend-term.txt](frontend-term.txt): output vitest + bảng theo tệp
- [frontend/coverage-summary.json](frontend/coverage-summary.json): số liệu theo tệp

## Chạy lại

```bash
backend/.venv/bin/pip install pytest-cov
(cd backend && COVERAGE_FILE=/tmp/.coverage .venv/bin/pytest --cov=app --cov-report=term \
  --cov-report=html:../docs/07-verification/coverage/backend-html \
  --cov-report=xml:../docs/07-verification/coverage/backend-coverage.xml)
(cd frontend && npm i --no-save @vitest/coverage-v8@2.1.9 && npx vitest run --coverage.enabled --coverage.provider=v8 \
  --coverage.reporter=text --coverage.reporter=json-summary --coverage.reportsDirectory=../docs/07-verification/coverage/frontend)
```
