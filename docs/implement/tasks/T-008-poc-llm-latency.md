# T-008 — PoC AR-01: đo độ trễ LLM

| Thuộc tính | Giá trị |
|---|---|
| Story | — (hạng mục nền tảng) |
| Giai đoạn | Sprint 0 (02/11 → 06/11/2026) |
| Loại | Backend |
| Ước lượng | 1 ngày |
| Phụ trách đề xuất | BE2 |
| Phụ thuộc (phải xong trước) | [T-001](T-001-repo-skeleton.md) |
| Mở khóa cho | [T-205](T-205-anthropic-adapter.md) |
| Nhánh git | `feat/T-008-poc-llm-latency` |
| Trạng thái | `To do` |

## Mục tiêu

Xác nhận với số liệu thực tế rằng cấu hình LLM dự kiến đạt p90 ≤ 5 s tới token đầu và ≤ 15 s tới câu trả lời hoàn chỉnh (NFR-001/002).

## Phạm vi & đặc tả

Script `backend/tests/eval/poc_latency.py`:

- **Đầu vào:** 50 câu hỏi; mỗi câu kèm 12 đoạn văn khoảng 750 token (tổng khoảng 9k token). Có thể lấy đoạn từ PDF mẫu hoặc văn bản tiếng Việt giả lập.
- **Cấu hình gọi:** giống T-205 (`claude-opus-5-5`, `thinking` adaptive, `effort: low`, `max_tokens` 4096, document block có citations, streaming).
- **Đo:** `first_token_ms` (từ lúc gửi request tới text delta đầu tiên), `total_ms`, `input_tokens`, `output_tokens`, `cache_read_input_tokens`.
- **Chạy 2 lượt:** tuần tự, và 5 luồng song song.
- **Xuất:** CSV + p50 / p90 / max.

Báo cáo `docs/implement/poc/AR-01.md` (1 trang): kết quả, chi phí ước tính mỗi câu hỏi, khuyến nghị (giữ nguyên / giảm `QA_TOP_N` / đổi model cho bước phụ).

## Các bước thực hiện

1. Chuẩn bị 50 câu hỏi và 12 đoạn văn mỗi câu.
2. Viết script với `anthropic.AsyncAnthropic` và `client.beta.messages.stream`.
3. Chạy từ EC2 (T-006) nếu đã có, nếu chưa thì chạy từ máy local và ghi chú.
4. Viết báo cáo.

## File cần tạo / sửa

- `backend/tests/eval/poc_latency.py`
- `docs/implement/poc/AR-01.md`

## Tiêu chí hoàn thành

- [ ] Báo cáo có p90 cho cả hai lượt (tuần tự và song song) và một khuyến nghị cụ thể.
- [ ] Tech lead đã đọc và quyết định cấu hình cho T-205.
- [ ] Đạt Definition of Done chung ([User_Stories.md §9](../../requirements/User_Stories.md)): code review, CI xanh, đã deploy lên môi trường AWS.

## Kiểm thử

- —

## Ngoài phạm vi task này

- Tối ưu prompt (T-208, T-301).

## Tham chiếu

- [SAD.md](../../design/SAD.md) §3.2.1 (ngân sách độ trễ), AR-01
- [Dev_Tasks.md](../Dev_Tasks.md) T-205
