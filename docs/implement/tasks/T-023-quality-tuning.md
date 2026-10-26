# T-023 — Tinh chỉnh chất lượng câu trả lời

| Thuộc tính | Giá trị |
|---|---|
| Tính năng | F2 — Hỏi đáp AI |
| Giai đoạn | Tuần ổn định & go-live (23/11 → 27/11/2026) |
| Loại | Backend |
| Ước lượng | 2 ngày |
| Phụ trách đề xuất | BE1 + BE2 + QA |
| Phụ thuộc (phải xong trước) | [T-022](T-022-ask-tests.md), [T-008](T-008-golden-eval.md) |
| Mở khóa cho | [T-024](T-024-uat-go-live.md) |
| Nhánh git | `feat/T-023-quality-tuning` |
| Trạng thái | `To do` |

## Mục tiêu

Đạt ≥ 80% ⚑ câu positive trả lời đúng và ≥ 90% ⚑ câu negative trả lời "không tìm thấy".

## Phạm vi & đặc tả

**Chạy `make eval` mỗi ngày** trên AWS với golden set của BD; BD / QA chấm cột `correct`.

**Phân loại câu sai và xử lý:**

| Nhóm lỗi | Hướng xử lý |
|---|---|
| Đoạn đúng không được truy xuất | Tăng `QA_TOP_N` (12 → 16); xem lại chunk size |
| Có đoạn đúng nhưng trả lời sai / thiếu | Sửa prompt (T-018) |
| Bịa khi tài liệu không có thông tin | Củng cố quy tắc 1–2 trong prompt |

**Mỗi thay đổi** là một PR kèm điểm eval trước / sau.

**Hạn:** thứ Năm 26/11 → báo PO để quyết định go / no-go.

## Các bước thực hiện

1. Chạy eval hằng ngày.
2. Sửa theo nhóm lỗi.
3. Báo cáo cho PO.

## File cần tạo / sửa

- `backend/tests/eval/results/*`

## Tiêu chí hoàn thành

- [ ] Đạt ngưỡng hoặc PO đã có quyết định go / no-go.
- [ ] Code đã được review, CI xanh, đã deploy lên môi trường AWS.

## Kiểm thử

- Golden eval.

## Tham chiếu

- [PRD.md](../../requirements/PRD.md) §2.2
