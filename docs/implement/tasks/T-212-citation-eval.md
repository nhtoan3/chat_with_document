# T-212 — Đánh giá độ chính xác trích dẫn (KR2.2)

| Thuộc tính | Giá trị |
|---|---|
| Story | [US-013 — Trích dẫn tài liệu & trang](../../requirements/User_Stories.md) |
| Giai đoạn | Sprint 2 (23/11 → 04/12/2026) |
| Loại | Kiểm thử |
| Ước lượng | 1 ngày |
| Phụ trách đề xuất | QA |
| Phụ thuộc (phải xong trước) | [T-210](T-210-citation-markers.md), [T-010](T-010-golden-eval.md) |
| Mở khóa cho | [T-301](T-301-quality-tuning.md) |
| Nhánh git | `feat/T-212-citation-eval` |
| Trạng thái | `To do` |

## Mục tiêu

Đo và đạt ≥ 90% ⚑ trích dẫn trỏ đúng trang chứa thông tin.

## Phạm vi & đặc tả

1. Chạy `make eval` trên môi trường AWS với golden set đầy đủ.
2. KR2.2 = số trích dẫn có `(document_title, page_start)` thuộc `expected_sources` / tổng số trích dẫn (của các câu positive và multi_doc).
3. **Kiểm tra thủ công 20 trích dẫn ngẫu nhiên:** mở PDF tại trang được nêu, xác nhận nội dung có ở đó (đúng với AC-US-013-2 theo nghĩa người dùng).
4. **Kiểm tra tự động:** không có trích dẫn nào có `page_start > documents.pages` (AC-US-013-4).
5. Ghi kết quả vào `tests/eval/results/` và báo cáo trong sprint review.

## Các bước thực hiện

1. Chạy eval.
2. Kiểm tra thủ công.
3. Ghi báo cáo.

## File cần tạo / sửa

- `backend/tests/eval/results/KR2.2-<ngày>.md`

## Tiêu chí hoàn thành

- [ ] KR2.2 ≥ 90% hoặc có danh sách lỗi và hướng xử lý đưa vào T-301.
- [ ] Đạt Definition of Done chung ([User_Stories.md §9](../../requirements/User_Stories.md)): code review, CI xanh, đã deploy lên môi trường AWS.

## Kiểm thử

- (Chính là task kiểm thử.)

## Tham chiếu

- [PRD.md](../../requirements/PRD.md) KR2.2
- [User_Stories.md](../../requirements/User_Stories.md) AC-US-013-2, 4
