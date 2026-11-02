# Sơ đồ thiết kế UML 2.0 (as-built, phạm vi v0.4)

**v0.1 Draft, 2026-11-02, chưa được review.** Các sơ đồ phản ánh code hiện tại (F1 Xử lý PDF, F2 Hỏi đáp AI), không phải kiến trúc mục tiêu trong `docs/04-design/SAD.md`. Mở bằng diagrams.net (draw.io).

| Tệp | View 4+1 | Trang | Nguồn |
|---|---|---|---|
| `class-diagram.drawio` | Logical | Module qa · Module documents và worker · platform và lược đồ CSDL | `backend/app/modules/**`, `backend/app/api/routers/*`, `backend/app/api/deps.py`, `backend/app/worker/*`, `backend/app/platform/{storage,errors,config,db,db_schema}.py` |
| `sequence-upload-ingest.drawio` | Process | Tải lên · Xử lý (worker) | `backend/app/api/routers/documents.py`, `modules/documents/application/upload.py`, `modules/documents/adapters/{sql_repo,job_queue}.py`, `worker/main.py`, `worker/ingest.py`, `frontend/src/features/documents/*` |
| `sequence-ask.drawio` | Process | Hỏi đáp | `backend/app/api/routers/ask.py`, `modules/qa/application/ask.py`, `modules/qa/adapters/*`, `frontend/src/features/ask/*` |
| `activity-ingest.drawio` | Process | Xử lý job | `backend/app/worker/main.py`, `worker/ingest.py`, `modules/documents/adapters/job_queue.py`, `platform/config.py` |
| `component-diagram.drawio` | Development | Thành phần | `frontend/src/**`, `frontend/nginx.conf`, `backend/app/**` |
| `deployment-diagram.drawio` | Physical | Production AWS · Local | `infra/docker-compose.prod.yml`, `infra/README.md`, `infra/deploy.sh`, `docker-compose.yml`, `frontend/nginx.conf`, `.github/workflows/ci.yml` |

View Scenarios (+1) là sơ đồ use case: `docs/04-design/UseCase_ChatWithDocument.drawio` vẽ **phạm vi mục tiêu**, không phải v0.4 (còn đăng nhập, trích dẫn, lịch sử hội thoại), nên chưa khớp với các sơ đồ ở đây.

## Lưu ý

- Hạ tầng AWS **chưa được cấp phát** (T-006 đang In progress); trang Production mô tả cấu hình dự kiến.
- Phần lớn backend là module Python chỉ có hàm, nên được vẽ với stereotype `«module»`. Port là `Protocol`, adapter hiện thực ngầm (structural typing).
