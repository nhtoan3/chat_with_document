# T-214 — Hiệu chỉnh ngưỡng liên quan τ

| Thuộc tính | Giá trị |
|---|---|
| Story | [US-014 — Không tìm thấy thông tin](../../requirements/User_Stories.md) |
| Giai đoạn | Sprint 2 (23/11 → 04/12/2026) |
| Loại | Kiểm thử |
| Ước lượng | 1 ngày |
| Phụ trách đề xuất | BE1 |
| Phụ thuộc (phải xong trước) | [T-203](T-203-ask-question-usecase.md), [T-010](T-010-golden-eval.md), [T-122](T-122-retrieval-tests.md) |
| Mở khóa cho | [T-301](T-301-quality-tuning.md) |
| Nhánh git | `feat/T-214-tau-calibration` |
| Trạng thái | `To do` |

## Mục tiêu

Chọn giá trị `QA_TAU` cân bằng giữa "không tìm thấy" sai và câu trả lời bịa.

## Phạm vi & đặc tả

1. Chạy `make eval` với `QA_TAU` ∈ {0.35, 0.40, 0.45, 0.50, 0.55} (đổi biến môi trường, không cần sửa code).
2. Với mỗi giá trị, ghi lại: KR2.3 (% câu negative → `not_found`), KR2.1 (% câu positive đúng), % câu positive bị `not_found` nhầm.
3. **Chọn** τ đạt KR2.3 ≥ 90% ⚑ **và** có KR2.1 cao nhất. Nếu không có giá trị nào đạt cả hai → báo Tech lead / PO (có thể cần full-text search theo ADR-003).
4. Cập nhật giá trị mặc định trong config và `.env` production.

## Các bước thực hiện

1. Chạy 5 lượt eval.
2. Lập bảng kết quả.
3. Mở PR cập nhật cấu hình kèm bảng kết quả.

## File cần tạo / sửa

- `backend/tests/eval/results/T-214-tau.md`
- `backend/app/platform/config.py`

## Tiêu chí hoàn thành

- [ ] AC-US-014-1 đạt; giá trị τ đã chọn có số liệu chứng minh.
- [ ] Đạt Definition of Done chung ([User_Stories.md §9](../../requirements/User_Stories.md)): code review, CI xanh, đã deploy lên môi trường AWS.

## Kiểm thử

- Golden eval.

## Tham chiếu

- [SAD.md](../../design/SAD.md) AR-04
- [User_Stories.md](../../requirements/User_Stories.md) AC-US-014-1
