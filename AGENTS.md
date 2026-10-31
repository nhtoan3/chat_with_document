# AGENTS.md — hướng dẫn cho AI agent và developer

Repo của MVP **"Chat với tài liệu"**: tải PDF dự án lên, hỏi đáp bằng tiếng Việt, AI (Claude) trả lời chỉ dựa trên nội dung tài liệu. Phạm vi hiện tại là **v0.4**: chỉ có **F1 — Xử lý PDF** và **F2 — Hỏi đáp AI**.

## Nguồn sự thật

| Câu hỏi | Xem ở |
|---|---|
| Làm gì, lịch, phạm vi | `docs/implement/Implement_plan.md` (v0.4) |
| Đặc tả từng việc | `docs/implement/tasks/T-001 … T-024` |
| Yêu cầu nào đã được code / test | `docs/implement/traceability.md` |
| Kiến trúc mục tiêu | `docs/design/SAD.md` (mục "Phạm vi kiến trúc cho MVP" ghi đè phần còn lại) |

Khi tài liệu mâu thuẫn: **kế hoạch v0.4 và thư mục `tasks/` có hiệu lực** hơn `User_Stories.md` và `SAD.md` (chưa cập nhật theo v0.4). `Dev_Tasks.md` đã bị thay thế, chỉ để tham khảo cho giai đoạn 2.

## Cấu trúc

```
backend/app/platform/            config, DB, lỗi problem+json, log JSON, lưu trữ S3
backend/app/modules/documents/   tải lên, hàng đợi trong PostgreSQL, trích xuất PDF, chunker
backend/app/modules/qa/          port, truy xuất vector, prompt, adapter Claude, use case hỏi đáp
backend/app/worker/              tiến trình xử lý tài liệu
backend/app/migrations/          Alembic
backend/tests/                   unit/ · integration/ (Testcontainers) · eval/ (golden set) · fixtures/ · fakes/
frontend/src/                    app/ (shell, router) · features/{documents,ask} · shared/{api,ui,i18n}
infra/                           compose production, deploy.sh, rollback.sh, hướng dẫn AWS
```

## Lệnh

```bash
make venv          # virtualenv backend (Python 3.12)
make dev           # stack local: postgres, s3 (S3Mock), tei, api, worker x2, web
make seed          # tải 3 PDF mẫu lên stack đang chạy
make lint          # ruff + mypy · eslint + tsc
make test          # pytest (cần Docker cho Testcontainers) · vitest
make eval BASE_URL=http://localhost:8000   # golden set; chấm cột correct rồi `make eval-score`
```

Chạy một test backend: `cd backend && .venv/bin/pytest tests/unit/test_chunker.py -q`.

## Quy tắc bắt buộc

- **Kiến trúc:** use case trong `modules/*/application/` chỉ phụ thuộc vào port (`modules/qa/ports.py`, `platform/storage.py`); **không** import FastAPI hay SDK `anthropic` / boto3 ở đó. Đổi nhà cung cấp AI chỉ được phép bằng cách thêm adapter mới (OQ-008).
- **Không log nội dung** câu hỏi, câu trả lời hay văn bản tài liệu; `qa_log` chỉ lưu số liệu.
- **Lỗi API** luôn là `AppError(code)` có trong `platform/errors.py::ERRORS`. Thêm mã mới thì thêm cả thông điệp tiếng Việt trong `frontend/src/shared/i18n/vi.json`.
- **Chuỗi giao diện** chỉ nằm trong `vi.json`, không viết cứng trong TSX.
- **Câu trả lời của AI** phải render qua `features/ask/markdown.ts` (marked + DOMPurify).
- **Prompt:** mọi thay đổi `modules/qa/prompts.py` phải chạy lại `make eval` và ghi điểm trước / sau vào mô tả PR.
- **CSDL:** thay đổi lược đồ bằng revision Alembic mới; không sửa `0001_init.py` đã merge.
- **Bí mật:** không commit `.env`, khóa API hay dữ liệu thật của khách hàng; fixture PDF chỉ là dữ liệu giả lập.
- **Không có đăng nhập** trong MVP: bảo vệ dựa vào giới hạn IP / VPN của ALB (`infra/README.md`). Không mở ALB ra `0.0.0.0/0`.

## Git

- Mỗi commit thuộc **một task**, tiêu đề bắt đầu bằng mã task: `T-013: Add ingestion pipeline and worker`. Sửa lỗi của task cũ cũng dùng mã task đó.
- Trước khi commit: `make lint` và `make test` phải xanh.
- Cập nhật `docs/implement/traceability.md` khi thêm hoặc đổi test cho một yêu cầu.

## Môi trường local — lưu ý

- Image TEI CPU chỉ có bản amd64; trên Mac Apple Silicon chạy giả lập, lần đầu tải model khoảng 2,3 GB.
- Docker Desktop cần ≥ 8 GB RAM; compose đã giảm `--max-batch-tokens` của TEI xuống 2048 để không bị hết bộ nhớ.
- Không có `ANTHROPIC_API_KEY` thì `/api/v1/ask` trả **503 `ai_unavailable`**; các phần còn lại vẫn chạy.
- S3 local là Adobe S3Mock (MinIO đã ngừng phát hành image công khai); dữ liệu lưu trong volume `s3data`.
