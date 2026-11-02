# ADR-011: Lược bỏ các cơ chế không thiết yếu cho MVP

> Version 0.1 · Trạng thái tài liệu: `Draft` · 2026-11-02 · Chưa được review/duyệt
> Nguồn: `docs/04-design/SAD.md` "Phạm vi kiến trúc cho MVP", §5; `docs/05-development/Implement_plan.md` §1

## Status

`Accepted (v0.2)`, ghi nguyên văn theo SAD §5. Repo không có biên bản duyệt riêng cho ADR này.

## Context

SAD v0.2 thu hẹp kiến trúc để rút ngắn thời gian ra mắt. Rate limit được bỏ với lý do hệ thống có 20 người dùng nội bộ. Lý do riêng cho các mục khác: [TBD].

## Decision

| Hạng mục | Thiết kế mục tiêu | MVP v0.2 (SAD) | Hiện trạng v0.4 |
|---|---|---|---|
| Câu hỏi nối tiếp | Viết lại câu hỏi bằng LLM | Không có; mỗi câu độc lập | Không có; không có hội thoại |
| Chịu lỗi LLM | Retry + watchdog + circuit breaker | Retry SDK `max_retries=2` + timeout 30 s | `max_retries=2`; timeout mặc định **60 s** (`platform/config.py:22`) |
| Rate limit | Token bucket trên Redis | Không có | Không có |
| Analytics | `analytics_events`, 13 sự kiện | SQL trên `messages`, `conversations` | SQL trên **`qa_log`**; hai bảng kia không tồn tại (`infra/README.md` §6) |
| CSDL | Partition, job purge / aggregate | Bảng thường; gỡ = xóa ngay; không job định kỳ | Bảng thường; không job định kỳ; **không có chức năng gỡ** |
| Xem nguồn | Panel PDF.js | Tab mới tại `#page=N` | **Không có** (US-017 bị lược bỏ) |

## Consequences

- Gỡ tài liệu lỗi thời cần Tech lead xóa trực tiếp trong DB / S3 (Plan §1, đánh đổi #4; `infra/README.md` §7).
- Không có rate limit và không có đăng nhập, nên chi phí LLM chỉ được chặn bởi hạn mức chi tiêu cấu hình ở Anthropic Console (`infra/README.md` §5). Hạn mức cụ thể: [TBD: OQ-007].
- Không có circuit breaker: mỗi yêu cầu khi LLM lỗi vẫn chịu đủ retry và timeout.

## Rejected alternatives

| Phương án | Lý do |
|---|---|
| Triển khai đầy đủ theo SAD §2–§4 | Để giai đoạn 2 (SAD §5) |
