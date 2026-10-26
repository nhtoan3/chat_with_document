# T-208 — Tinh chỉnh câu trả lời tổng hợp nhiều tài liệu

| Thuộc tính | Giá trị |
|---|---|
| Story | [US-012 — Tổng hợp nhiều tài liệu](../../requirements/User_Stories.md) |
| Giai đoạn | Sprint 2 (23/11 → 04/12/2026) |
| Loại | Backend |
| Ước lượng | 1,5 ngày |
| Phụ trách đề xuất | BE1 |
| Phụ thuộc (phải xong trước) | [T-203](T-203-ask-question-usecase.md), [T-010](T-010-golden-eval.md) |
| Mở khóa cho | [T-301](T-301-quality-tuning.md) |
| Nhánh git | `feat/T-208-multi-doc-tuning` |
| Trạng thái | `To do` |

## Mục tiêu

Câu hỏi có đáp án nằm rải rác ở nhiều tài liệu nhận câu trả lời đủ ý từ tất cả các nguồn (≥ 80% ⚑).

## Phạm vi & đặc tả

1. Đảm bảo golden set có ≥ 10 câu `type: multi_doc`.
2. Chạy `make eval` → đo tỷ lệ câu `multi_doc` có trích dẫn từ **tất cả** tài liệu trong `expected_sources` và được chấm đúng.
3. Nếu < 80%, thử lần lượt các cách sau, **mỗi lần chỉ đổi một yếu tố** và ghi kết quả:

| # | Thay đổi | Cấu hình |
|---|---|---|
| a | Tăng số chunk | `QA_TOP_N` 12 → 16 |
| b | Đa dạng nguồn | Sau truy vấn top 30, giữ tối đa 4 chunk mỗi tài liệu rồi lấy top N (`QA_MAX_PER_DOC=4`) |
| c | Prompt | Nhấn mạnh mục 4 của system prompt (T-204) |

4. Chọn cấu hình tốt nhất mà không làm giảm KR2.1 / KR2.3 hoặc tăng p90 vượt 15 s.

## Các bước thực hiện

1. Bổ sung câu `multi_doc`.
2. Thêm tùy chọn `QA_MAX_PER_DOC` vào retrieval.
3. Chạy thử nghiệm và ghi kết quả.

## File cần tạo / sửa

- `backend/app/modules/qa/adapters/pg_retrieval.py`
- `backend/tests/eval/results/T-208.md`

## Tiêu chí hoàn thành

- [ ] AC-US-012-1, 2 đạt trên golden set; AC-US-012-3 kiểm thử thủ công với 2 tài liệu mâu thuẫn.
- [ ] Đạt Definition of Done chung ([User_Stories.md §9](../../requirements/User_Stories.md)): code review, CI xanh, đã deploy lên môi trường AWS.

## Kiểm thử

- Golden eval.

## Ngoài phạm vi task này

- Reranker (giai đoạn 2).

## Tham chiếu

- [User_Stories.md](../../requirements/User_Stories.md) US-012
- [SAD.md](../../design/SAD.md) ADR-003
