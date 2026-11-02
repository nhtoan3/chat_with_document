# ADR-004: Embedding `bge-m3` tự vận hành (TEI, CPU)

> Version 0.1 · Trạng thái tài liệu: `Draft` · 2026-11-02 · Chưa được review/duyệt
> Nguồn: `docs/04-design/SAD.md` §0.3, §5, §6; `backend/app/modules/qa/adapters/tei_embedding.py`

## Status

`Proposed — PoC tốc độ` (theo SAD §5). Plan v0.4 §1 đã lược bỏ PoC; kết quả PoC: [TBD].

## Context

- Chưa rõ có được gửi nội dung tới AI bên ngoài không (TC-06, OQ-008).
- Cần mô hình đa ngôn ngữ, tốt với tiếng Việt, 1024 chiều (SAD §0.3).
- PDF 50 trang cần xử lý xong ≤ 60 s ⚑ (TC-05); bge-m3 trên CPU có thể không đạt (AR-02).

## Decision

Chạy `BAAI/bge-m3` bằng Hugging Face Text Embeddings Inference trên CPU, sau `EmbeddingPort`.

**Hiện trạng v0.4:** image `text-embeddings-inference:cpu-1.7`; `--max-batch-tokens` là 16384 ở production (`infra/docker-compose.prod.yml:38`) và 2048 ở local (`docker-compose.yml:48`). Adapter gửi lô 32 văn bản, `normalize: true`, `truncate: true`. Timeout 10 s ở API (`api/deps.py:19`), 30 s ở worker (`worker/main.py:25`).

## Consequences

- Toàn văn tài liệu không rời hệ thống khi embedding, không phát sinh chi phí theo token (SAD §0.3). Tuy vậy, các đoạn truy xuất được vẫn gửi tới LLM (ADR-005).
- TEI lỗi khiến `/api/v1/ask` trả 503 `ai_unavailable`. Phương án truy xuất suy giảm chỉ dùng full-text (SAD §4.2) không có ở v0.4.
- NFR-003 chưa đo với PDF 50 trang trên AWS (`docs/05-development/traceability.md`).
- Đổi mô hình có số chiều khác cần revision Alembic mới và embedding lại toàn bộ chunk.

## Rejected alternatives

| Phương án | Lý do loại (SAD §5) |
|---|---|
| API embedding bên ngoài | Gửi toàn văn tài liệu ra ngoài, trái TC-06 |
