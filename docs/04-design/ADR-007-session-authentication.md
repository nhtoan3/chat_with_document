# ADR-007: Phiên phía server + cookie HttpOnly, ưu tiên OIDC

> Version 0.1 · Trạng thái tài liệu: `Draft` · 2026-11-02 · Chưa được review/duyệt
> Nguồn: `docs/04-design/SAD.md` "Phạm vi kiến trúc cho MVP", §4.1, §5; `docs/05-development/Implement_plan.md` §1, §3, §4; `infra/README.md`

## Status

`Proposed — chờ OQ-014` (theo SAD §5). **Không được triển khai ở v0.4.** OQ-014 đang ở trạng thái `Open` (`docs/02-requirements/BRD.md:378`).

## Context

Thiết kế mục tiêu yêu cầu xác thực và RBAC 2 vai trò (TC-07). Plan v0.4 §1 lược bỏ đăng nhập, đăng xuất, phân quyền và hội thoại riêng tư (US-001, 002, 003, 023).

## Decision

**Thiết kế mục tiêu:** phiên phía server, cookie HttpOnly; ưu tiên OIDC, dự phòng tài khoản nội bộ. Bản MVP v0.2 lưu phiên ở bảng `sessions` trong PostgreSQL thay vì Redis.

**Hiện trạng v0.4:** không có code đăng nhập, không có bảng `users` / `sessions` trong `0001_init.py`, không có CSRF token. API không xác thực. Bảo vệ duy nhất là security group ALB chỉ cho phép IP / VPN công ty (`infra/README.md`; không mở `0.0.0.0/0`).

## Consequences

- Ai trong mạng công ty cũng truy cập được mọi tài liệu; không đếm được số người dùng (MET-003), chỉ đếm được số câu hỏi (Plan §1, đánh đổi #2).
- Nếu IT không cấp được dải IP / VPN: **bắt buộc thêm lớp xác thực** trước go-live, bằng ALB OIDC (nếu có SSO) hoặc Basic Auth ở Nginx, khoảng 0,5–1 ngày (Plan §4).
- Danh sách IP / VPN đang quá hạn cung cấp (`docs/01-intake/intent.md`).
- Bản thân phạm vi v0.4 và 4 đánh đổi vẫn chờ quản lý duyệt (`docs/05-development/evidence/Phe_duyet_v0.4_OQ-008.md`).

## Rejected alternatives

| Phương án | Lý do loại (SAD §4.1) |
|---|---|
| JWT trong SPA | Không cần cho SPA cùng origin; thu hồi phiên ngay lập tức dễ hơn với phiên phía server |
