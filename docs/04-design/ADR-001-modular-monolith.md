# ADR-001: Modular monolith (hexagonal) + worker tách tiến trình

> Version 0.1 · Trạng thái tài liệu: `Draft` · 2026-11-02 · Chưa được review/duyệt
> Nguồn: `docs/04-design/SAD.md` §1.2, §5; `docs/05-development/Implement_plan.md` §1; `AGENTS.md`

## Status

`Proposed` (theo SAD §5).

## Context

- Quy mô nhỏ, đội nhỏ: 20 người dùng, 5 người đồng thời (SAD §1.2); ngân sách chưa rõ (TC-10, OQ-007).
- Chưa biết có được gửi nội dung tới AI bên ngoài không (TC-06, OQ-008), nên phải thay được nhà cung cấp.
- Xử lý PDF tốn CPU, bộ nhớ và phải chạy parser trên tệp không tin cậy (SAD §1.2).

## Decision

Một deployable API (FastAPI) tổ chức theo module với ports & adapters cho phụ thuộc ngoài, cộng một tiến trình worker riêng dùng chung domain + adapters. Bản gốc của ADR ghi worker Celery; phần hàng đợi đã được ADR-010 thay.

**Hiện trạng v0.4** (Plan §1 chỉ giữ F1, F2):

- Chỉ có 2 module: `backend/app/modules/documents`, `backend/app/modules/qa`. Không có `identity`, `conversations`, `analytics`, `IdentityPort`.
- Port có trong code: `EmbeddingPort`, `LLMPort`, `RetrievalPort` (`modules/qa/ports.py`), `ObjectStoragePort` (`platform/storage.py`).
- Worker: `python -m app.worker.main`, không dùng Celery.

## Consequences

- Đổi nhà cung cấp AI chỉ cần adapter mới và cấu hình (SAD §1.2; `AGENTS.md`).
- Worker không làm chậm API và cô lập rủi ro parser (SAD §1.2).
- SAD dự kiến kiểm tra quy tắc import bằng `import-linter` trong CI; CI hiện tại không có công cụ này, nên ranh giới chỉ được giữ bằng quy ước và review.
- Ranh giới chưa được giữ đồng đều: `modules/documents/application/upload.py:15,17` import trực tiếp `sqlalchemy` và `adapters.sql_repo`, trong khi `AGENTS.md` quy định use case chỉ phụ thuộc vào port.

## Rejected alternatives

| Phương án | Lý do loại (SAD §1.2) |
|---|---|
| Microservices | Chi phí vận hành vượt xa lợi ích ở quy mô MVP |
| Serverless (Lambda) | Không phù hợp streaming SSE dài; TEI cần chạy liên tục; cold start ảnh hưởng TC-04. Lưu ý: v0.4 không còn streaming, SAD chưa đánh giá lại |
| Event-driven toàn phần (Kafka) | Chỉ có một luồng bất đồng bộ là ingestion; hàng đợi tác vụ là đủ |
