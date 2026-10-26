# T-122 — Kiểm thử truy xuất

| Thuộc tính | Giá trị |
|---|---|
| Story | [US-008 — Mọi tài liệu Sẵn sàng là nguồn trả lời](../../requirements/User_Stories.md) |
| Giai đoạn | Sprint 1 (09/11 → 20/11/2026) |
| Loại | Kiểm thử |
| Ước lượng | 1 ngày |
| Phụ trách đề xuất | BE2 |
| Phụ thuộc (phải xong trước) | [T-121](T-121-vector-retrieval.md), [T-120](T-120-pdf-fixtures.md) |
| Mở khóa cho | [T-214](T-214-tau-calibration.md) |
| Nhánh git | `feat/T-122-retrieval-tests` |
| Trạng thái | `To do` |

## Mục tiêu

Chứng minh truy xuất trả đúng nguồn và bỏ qua tài liệu chưa sẵn sàng.

## Phạm vi & đặc tả

**Integration** (dùng 3 PDF mẫu, đã ingest với TEI thật trong compose):

| Ca kiểm thử | Kỳ vọng |
|---|---|
| Câu hỏi có đáp án ở tài liệu A | Ít nhất 1 chunk của A nằm trong top 3 |
| Chuyển A sang `processing` rồi hỏi lại | Không còn chunk nào của A |
| Câu hỏi vô nghĩa ("xyz qwe") | `max(sim)` thấp hơn ca liên quan (dữ liệu đầu vào cho T-214) |

**Đo hiệu năng:** chèn 30.000 chunk vector ngẫu nhiên → đo p95 thời gian truy vấn.

## Các bước thực hiện

1. Viết test.
2. Ghi lại phân bố `sim` của câu liên quan / không liên quan vào `tests/eval/results/` để làm đầu vào cho T-214.

## File cần tạo / sửa

- `backend/tests/integration/test_retrieval.py`

## Tiêu chí hoàn thành

- [ ] Mọi ca pass; p95 < 100 ms.
- [ ] Đạt Definition of Done chung ([User_Stories.md §9](../../requirements/User_Stories.md)): code review, CI xanh, đã deploy lên môi trường AWS.

## Kiểm thử

- (Chính là task kiểm thử.)

## Tham chiếu

- [User_Stories.md](../../requirements/User_Stories.md) AC-US-008-1, 2
