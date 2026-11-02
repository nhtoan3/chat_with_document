# ADR-003: Chiến lược truy xuất và xử lý "không tìm thấy"

> Version 0.1 · Trạng thái tài liệu: `Draft` · 2026-11-02 · Chưa được review/duyệt
> Nguồn: `docs/04-design/SAD.md` "Phạm vi kiến trúc cho MVP", §1.1, §5, §6; `docs/05-development/Implement_plan.md` §1

## Status

`Proposed — PoC` (theo SAD §5). Plan v0.4 §1 đã lược bỏ PoC khỏi các việc nền tảng; kết quả PoC cho ADR này: [TBD].

## Context

- Rủi ro lớn nhất là AI bịa thông tin (D1, RSK-001 — SAD §1.1).
- Full-text `simple` có thể yếu với tiếng Việt (AR-03 — SAD §6).
- Ngưỡng `τ` khó cân bằng giữa "không tìm thấy" sai và bịa (AR-04 — SAD §6).

## Decision

Quyết định đã thay đổi qua ba phiên bản:

| Phiên bản | Truy xuất | "Không tìm thấy" |
|---|---|---|
| Mục tiêu (SAD §1–§4) | Vector + full-text, gộp bằng RRF | Ngưỡng trước khi gọi LLM; sentinel `NOT_FOUND`; hậu kiểm "0 trích dẫn" |
| MVP v0.2 (SAD) | Chỉ vector (HNSW) | Ngưỡng τ |
| **v0.4 (Plan §1, có hiệu lực)** | **Chỉ vector (HNSW)** | **Chỉ bằng prompt. Không có AnswerGuard, không có ngưỡng τ** (US-014 bị lược bỏ) |

**Hiện trạng code v0.4:**

- `modules/qa/adapters/pg_retrieval.py`: lấy `QA_TOP_N` (mặc định 12) chunk gần nhất theo cosine của tài liệu `ready`, `hnsw.ef_search = 80`.
- Cột `sim` được tính nhưng không dùng để chặn: không có đoạn code nào so sánh với ngưỡng, LLM luôn được gọi khi có tài liệu `ready`.
- `modules/qa/prompts.py`: quy tắc 2 yêu cầu trả đúng câu `NOT_FOUND_ANSWER` khi tài liệu không chứa thông tin.
- `modules/qa/adapters/anthropic_llm.py:56-62`: trả `NOT_FOUND_ANSWER` khi `stop_reason == "refusal"` hoặc khi văn bản trả về rỗng.

## Consequences

- Plan §1, đánh đổi #3: tỷ lệ AI bịa khó kiểm soát hơn; chỉ đo được qua golden set.
- Mọi câu hỏi hợp lệ khi có tài liệu `ready` đều tốn một lời gọi LLM, kể cả câu không có đáp án.
- AR-04 (hiệu chỉnh τ) không áp dụng ở v0.4 vì không có τ. AR-03 chỉ áp dụng khi thêm full-text.
- Mục tiêu KR2.3 (≥ 90% ⚑ câu không có đáp án nhận "không tìm thấy") chưa đo được: chưa có golden set thật và khóa API (`docs/01-intake/intent.md` §5).

## Rejected alternatives

| Phương án | Lý do |
|---|---|
| Reranker cross-encoder | Để giai đoạn sau, nếu golden set cho thấy cần (SAD §5) |
| Vector + full-text RRF cho MVP | Hoãn từ v0.2; thêm nếu golden set cho thấy cần (SAD "Phạm vi kiến trúc cho MVP") |
| Ngưỡng τ / AnswerGuard cho MVP | Lược bỏ ở v0.4 (Plan §1). Plan không nêu lý do riêng cho hạng mục này ngoài việc thu hẹp phạm vi |
