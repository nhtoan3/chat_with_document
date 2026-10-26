# T-008 — Golden set và script đánh giá câu trả lời

| Thuộc tính | Giá trị |
|---|---|
| Tính năng | — (hạng mục nền tảng) |
| Giai đoạn | Sprint 0 — Nền tảng (02/11 → 06/11/2026) |
| Loại | Kiểm thử |
| Ước lượng | 1 ngày |
| Phụ trách đề xuất | BE1 + QA |
| Phụ thuộc (phải xong trước) | [T-002](T-002-docker-compose.md) |
| Mở khóa cho | [T-023](T-023-quality-tuning.md) |
| Nhánh git | `feat/T-008-golden-eval` |
| Trạng thái | `To do` |

## Mục tiêu

Có bộ câu hỏi chuẩn và script đo độ đúng của câu trả lời trước mỗi lần deploy.

## Phạm vi & đặc tả

**`backend/tests/eval/golden.yaml`:**

```yaml
- id: G-001
  type: positive        # positive | negative
  question: "Điều khoản thanh toán trong hợp đồng khung với ABC là gì?"
  expected_answer: "3 đợt: 30% tạm ứng..., 50% sau nghiệm thu GĐ1, 20% sau nghiệm thu cuối"
- id: G-051
  type: negative
  question: "Thủ đô của Pháp là gì?"
```

**`make eval BASE_URL=…`:** gọi `POST /api/v1/ask` cho từng câu → ghi `results/<ts>.csv` (câu hỏi, câu trả lời, latency).

- **Câu positive:** BD / QA chấm thủ công cột `correct` (0/1); `make eval-score` tính % đúng (mục tiêu ≥ 80% ⚑).
- **Câu negative:** đếm tự động câu trả lời có cụm "không tìm thấy" (mục tiêu ≥ 90% ⚑).

**BD bàn giao:** bộ PDF mẫu + ≥ 30 câu positive + ≥ 10 câu negative.

## Các bước thực hiện

1. Viết schema và 5 câu mẫu.
2. Viết script gọi API và tính điểm.
3. Gửi template cho BD.

## File cần tạo / sửa

- `backend/tests/eval/{golden.yaml,run_eval.py,score.py}`

## Tiêu chí hoàn thành

- [ ] Script chạy được với 5 câu mẫu; đã gửi template cho BD kèm hạn bàn giao.
- [ ] Code đã được review, CI xanh, đã deploy lên môi trường AWS.

## Kiểm thử

- Unit cho phần tính điểm.

## Ngoài phạm vi task này

- Đo trích dẫn KR2.2 (đã bỏ tính năng trích dẫn).

## Tham chiếu

- [PRD.md](../../requirements/PRD.md) §2.2
