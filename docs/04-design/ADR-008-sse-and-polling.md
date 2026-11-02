# ADR-008: SSE trên POST cho câu trả lời; polling cho trạng thái tài liệu

> Version 0.1 · Trạng thái tài liệu: `Draft` · 2026-11-02 · Chưa được review/duyệt
> Nguồn: `docs/04-design/SAD.md` §2.1, §2.4, §5; `docs/05-development/Implement_plan.md` §1

## Status

`Proposed` (theo SAD §5). Ở v0.4 chỉ phần polling được triển khai.

## Context

- Luồng trả lời phải là POST mang câu hỏi, nên không dùng được `EventSource` (SAD §2.1).
- Mục tiêu p90 ra token đầu ≤ 5 s đòi hỏi streaming (TC-04).
- Trạng thái tài liệu cần tự cập nhật (FR-006).

## Decision

**Thiết kế mục tiêu:** SSE trên `fetch` + `ReadableStream` cho câu trả lời; polling cho trạng thái tài liệu.

**Hiện trạng v0.4:**

| Phần | Trạng thái | Bằng chứng |
|---|---|---|
| SSE | **Không triển khai** (US-016 bị lược bỏ, Plan §1). `POST /api/v1/ask` trả một JSON | `api/routers/ask.py:36-61` |
| Polling | **Đã triển khai:** 3 s, chỉ khi `counts.processing > 0` | `frontend/src/features/documents/useDocuments.ts:11` |

SAD ghi polling bằng `GET /documents?status=processing`. Code gọi `GET /documents` không có tham số; API không hỗ trợ lọc.

## Consequences

- Người dùng chờ khoảng 10–20 s với spinner (Plan §1). Nếu p90 trong `qa_log` > 20 s, Plan §3 yêu cầu giảm `QA_TOP_N` hoặc `max_tokens`.
- Không có nút Dừng, nên yêu cầu đã gửi không dừng được lời gọi LLM từ phía người dùng.
- `frontend/nginx.conf` vẫn đặt `proxy_buffering off`, không ảnh hưởng tới phản hồi JSON hiện tại.

## Rejected alternatives

| Phương án | Lý do loại |
|---|---|
| WebSocket | Polling đơn giản hơn mà vẫn đáp ứng FR-006 (SAD §2.1). Lý do loại WebSocket cho luồng trả lời: [TBD] |
