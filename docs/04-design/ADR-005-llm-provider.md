# ADR-005: LLM Claude qua Anthropic API, sau `LLMPort`

> Version 0.1 · Trạng thái tài liệu: `Draft` · 2026-11-02 · Chưa được review/duyệt
> Nguồn: `docs/04-design/SAD.md` §0.3, §5, §6; `docs/05-development/Implement_plan.md` §1, §3, §4; `docs/05-development/tasks/T-019-anthropic-adapter.md`

## Status

**Chờ OQ-008** (theo SAD §5). **OQ-008 vẫn đang mở:** hạn quyết định 06/11/2026 (`docs/01-intake/intent.md`); phiếu `docs/05-development/evidence/Phe_duyet_v0.4_OQ-008.md` chưa được điền. Quyết định này chưa được chấp nhận.

## Context

- OQ-008: tài liệu được phân loại bảo mật ở mức nào, có được gửi nội dung tới dịch vụ AI bên ngoài không.
- Trước khi OQ-008 đóng, không dùng tài liệu thật để thử với dịch vụ AI bên ngoài (`docs/01-intake/sources.md`).
- OQ-024 (có cần Zero Data Retention với Anthropic không) được quyết định cùng OQ-008 (SAD §6).

## Decision

Dùng Claude `claude-opus-5-5` qua Anthropic Messages API, sau `LLMPort`. Bản gốc gồm Citations + streaming.

**Hiện trạng v0.4 (Plan §1 lược bỏ trích dẫn và streaming):**

| Khía cạnh | SAD | Code v0.4 |
|---|---|---|
| Citations | Có | **Không** (US-013, 017 bị lược bỏ) |
| Streaming | SSE | **Không**: `messages.create` chờ toàn bộ câu trả lời (`modules/qa/adapters/anthropic_llm.py:20`) |
| Retry | `max_retries=2` | `max_retries=2` |
| Timeout | 30 s (SAD "Phạm vi kiến trúc cho MVP") | `llm_timeout_s = 60.0` (`platform/config.py:22`) |
| Effort | `low` | `output_config={"effort": "low"}` |

Dữ liệu gửi đi: tối đa `QA_TOP_N` đoạn (mặc định 12) và câu hỏi; không gửi toàn bộ tài liệu.

## Consequences

- Phương án theo kết quả OQ-008 (Plan §4):

| Kết quả OQ-008 | Điều chỉnh |
|---|---|
| Được dùng Anthropic API | Giữ nguyên |
| Chỉ dùng trong AWS của tổ chức | Đổi adapter sang Claude trên Bedrock, khoảng 1 ngày; go-live giữ nguyên |
| Không được gửi dữ liệu ra ngoài | Thêm khoảng 1 tuần dựng LLM tự vận hành; go-live lùi tới khoảng 07/12/2026 |

- Không có trích dẫn: người dùng không kiểm chứng được nguồn; BO-002 "câu trả lời kiểm chứng được" không còn được đáp ứng (Plan §1, đánh đổi #1).
- Người dùng chờ khoảng 10–20 s với spinner (Plan §1).
- Không có `ANTHROPIC_API_KEY` thì `/api/v1/ask` trả 503 `ai_unavailable`.

## Rejected alternatives

SAD §5 ghi hai phương án sau là **dự phòng**, không phải bị loại hẳn; việc chọn phụ thuộc OQ-008.

| Phương án | Vai trò |
|---|---|
| Claude trên Amazon Bedrock | Dự phòng theo OQ-008 |
| Mô hình tự vận hành | Dự phòng theo OQ-008 |
