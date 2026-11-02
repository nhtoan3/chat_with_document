# ADR-009: Docker Compose trên một EC2

> Version 0.1 · Trạng thái tài liệu: `Draft` · 2026-11-02 · Chưa được review/duyệt
> Nguồn: `docs/04-design/SAD.md` §0.3, §4.2, §4.4, §5; `infra/README.md`; `infra/docker-compose.prod.yml`

## Status

`Proposed — xem lại khi vượt ×5` (theo SAD §5).

## Context

- Đội nhỏ, ít thành phần vận hành (TC-10); chỉ cần ×5 (TC-09), khả dụng ≥ 95% ⚑ giờ hành chính (TC-08).
- Vùng và nhà cung cấp còn phụ thuộc OQ-008, OQ-020 (SAD §0.3).

## Decision

Một EC2 `m7i.2xlarge` chạy Docker Compose, cùng RDS PostgreSQL và S3 ở `ap-southeast-1`.

**Hiện trạng v0.4:** container `web`, `api` (`uvicorn --workers 2`), `worker` (2 bản sao), `tei`. Không có `redis`, `otel-collector`. Chi tiết tài nguyên ở `infra/README.md` §2.

## Consequences

- EC2 là điểm lỗi đơn; RDS Single-AZ (SAD §4.2). SAD đánh giá đủ cho mức 95% giờ hành chính.
- Dựng hạ tầng thủ công một lần; Terraform để giai đoạn 2 (`infra/README.md`). Mục tiêu dựng lại < 4 giờ ở SAD §4.2 dựa trên Terraform nên chưa áp dụng được ở v0.4; thời gian dựng lại thực tế: [TBD].
- SAD §4.2 ghi `worker` ×1, trong khi T-010 và compose production dùng 2 bản sao; tài liệu task có hiệu lực.

## Rejected alternatives

| Phương án | Lý do loại |
|---|---|
| EKS / ECS | SAD §5 liệt kê nhưng không ghi lý do riêng: [TBD] |
