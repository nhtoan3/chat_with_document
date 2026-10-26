# T-220 — Đo độ trễ trên môi trường AWS

| Thuộc tính | Giá trị |
|---|---|
| Story | [US-016 — Câu trả lời hiện dần](../../requirements/User_Stories.md) |
| Giai đoạn | Sprint 2 (23/11 → 04/12/2026) |
| Loại | Kiểm thử |
| Ước lượng | 1 ngày |
| Phụ trách đề xuất | QA |
| Phụ thuộc (phải xong trước) | [T-203](T-203-ask-question-usecase.md), [T-006](T-006-aws-environment.md) |
| Mở khóa cho | — |
| Nhánh git | `feat/T-220-latency-test` |
| Trạng thái | `To do` |

## Mục tiêu

Xác nhận p90 ≤ 5 s tới token đầu và ≤ 15 s tới câu trả lời hoàn chỉnh khi 5 người hỏi đồng thời.

## Phạm vi & đặc tả

- **Chuẩn bị:** nạp 50 PDF mẫu (hoặc số lượng tối đa có được) lên môi trường AWS.
- **Script** `tests/eval/load_test.py` (Python async, `httpx`): 5 người dùng ảo × 10 câu hỏi lấy từ golden set, gửi đồng thời.
- **Đo:** lấy `first_token_ms` và `latency_ms` từ bảng `messages` (đo ở server), cùng thời gian đo phía client.
- **Báo cáo** p50 / p90 / max và so với NFR-001/002.
- **Nếu không đạt:** áp dụng giảm thiểu trong Implement_plan §4 (giảm `QA_TOP_N`, giảm `max_tokens`) và đo lại.

## Các bước thực hiện

1. Viết script.
2. Chạy ngoài giờ làm việc.
3. Ghi báo cáo.

## File cần tạo / sửa

- `backend/tests/eval/load_test.py`
- `backend/tests/eval/results/T-220-latency.md`

## Tiêu chí hoàn thành

- [ ] Báo cáo có số liệu; AC-US-016-1, 2 đạt hoặc có kế hoạch xử lý.
- [ ] Đạt Definition of Done chung ([User_Stories.md §9](../../requirements/User_Stories.md)): code review, CI xanh, đã deploy lên môi trường AWS.

## Kiểm thử

- (Chính là task kiểm thử.)

## Ngoài phạm vi task này

- Load test quy mô lớn.

## Tham chiếu

- [PRD.md](../../requirements/PRD.md) NFR-001, NFR-002
- [SAD.md](../../design/SAD.md) §3.2.1 (ngân sách độ trễ)
