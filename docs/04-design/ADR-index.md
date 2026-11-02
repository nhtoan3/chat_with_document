# Danh mục ADR — "Chat với tài liệu"

> Version 0.1 · Trạng thái tài liệu: `Draft` · 2026-11-02 · Chưa được review/duyệt
> Nguồn: `docs/04-design/SAD.md` §5 và mục "Phạm vi kiến trúc cho MVP"; `docs/05-development/Implement_plan.md` v0.4

Các ADR được tách từ bảng tóm tắt SAD §5, giữ nguyên số hiệu. Cột **Status** chép từ SAD. Khi có khác biệt, Plan v0.4 và thư mục `tasks/` có hiệu lực hơn SAD (`AGENTS.md`). Phần không có trong nguồn được ghi `[TBD]`.

| ADR | Quyết định | Status (SAD §5) | Hiện trạng v0.4 |
|---|---|---|---|
| [ADR-001](ADR-001-modular-monolith.md) | Modular monolith (hexagonal) + worker | Proposed | Có; 2 module; worker theo ADR-010 |
| [ADR-002](ADR-002-postgresql-pgvector.md) | PostgreSQL + pgvector + full-text | Proposed | Có vector; chưa có full-text |
| [ADR-003](ADR-003-retrieval-strategy.md) | Truy xuất và "không tìm thấy" | Proposed — PoC | Chỉ vector; "không tìm thấy" chỉ bằng prompt, không có τ |
| [ADR-004](ADR-004-self-hosted-embedding.md) | `bge-m3` tự vận hành | Proposed — PoC tốc độ | Có |
| [ADR-005](ADR-005-llm-provider.md) | Claude qua Anthropic API | **Chờ OQ-008** | Có adapter; không Citations, không streaming; **OQ-008 đang mở** |
| [ADR-006](ADR-006-page-bounded-chunking.md) | Chunk theo trang, trích dẫn phía server | Proposed | Có chunk theo trang; không có trích dẫn |
| [ADR-007](ADR-007-session-authentication.md) | Phiên phía server, OIDC | Proposed — chờ OQ-014 | **Không triển khai** |
| [ADR-008](ADR-008-sse-and-polling.md) | SSE trên POST; polling | Proposed | Chỉ có polling |
| [ADR-009](ADR-009-docker-compose-single-ec2.md) | Docker Compose trên một EC2 | Proposed — xem lại khi vượt ×5 | Có |
| [ADR-010](ADR-010-postgres-job-queue.md) | Hàng đợi bằng PostgreSQL | Accepted (v0.2) | Có |
| [ADR-011](ADR-011-mvp-feature-reductions.md) | Lược bỏ cơ chế không thiết yếu | Accepted (v0.2) | Có; v0.4 cắt thêm |
| [ADR-012](ADR-012-single-environment-minimal-ops.md) | Một môi trường, log JSON, CI tối giản | Accepted (v0.2) | Có; CI không còn quét bảo mật |

## Quyết định còn chờ

| Hạng mục | Ảnh hưởng | Trạng thái trong repo |
|---|---|---|
| OQ-008 | ADR-005, ADR-004, ADR-009 | Mở; hạn 06/11/2026 |
| OQ-014 | ADR-007 | `Open` (`docs/02-requirements/BRD.md:378`) |
| OQ-020, OQ-023 | ADR-009 | OQ-020 `Open` (`docs/02-requirements/PRD.md:563`); OQ-023: chưa có bản ghi đóng |
| OQ-024 | ADR-005 | Chưa có bản ghi đóng |
| Duyệt phạm vi v0.4 và 4 đánh đổi | Mọi ghi chú "Hiện trạng v0.4" | Chờ quản lý; phiếu `docs/05-development/evidence/Phe_duyet_v0.4_OQ-008.md` chưa điền |
| Kết quả PoC | ADR-003, ADR-004 | Plan v0.4 §1 lược bỏ PoC: [TBD] |
