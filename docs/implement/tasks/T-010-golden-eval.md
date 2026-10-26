# T-010 — Định dạng golden set và script đánh giá

| Thuộc tính | Giá trị |
|---|---|
| Story | — (hạng mục nền tảng) |
| Giai đoạn | Sprint 0 (02/11 → 06/11/2026) |
| Loại | Kiểm thử |
| Ước lượng | 1 ngày |
| Phụ trách đề xuất | BE1 + QA |
| Phụ thuộc (phải xong trước) | [T-002](T-002-docker-compose.md) |
| Mở khóa cho | [T-208](T-208-multi-doc-tuning.md), [T-212](T-212-citation-eval.md), [T-214](T-214-tau-calibration.md) |
| Nhánh git | `feat/T-010-golden-eval` |
| Trạng thái | `To do` |

## Mục tiêu

Có bộ dữ liệu chuẩn và script `make eval` để đo KR2.1–KR2.3 trước mỗi lần deploy.

## Phạm vi & đặc tả

**Định dạng `backend/tests/eval/golden.yaml`:**

```yaml
- id: G-001
  type: positive          # positive | negative | multi_doc
  question: "Điều khoản thanh toán trong hợp đồng khung với ABC là gì?"
  expected_answer: "3 đợt: 30% tạm ứng trong 10 ngày..., 50% sau nghiệm thu GĐ1, 20% sau nghiệm thu cuối"
  expected_sources:
    - {filename: "Hop_dong_khung_ABC_2026.pdf", page: 7}
    - {filename: "Hop_dong_khung_ABC_2026.pdf", page: 8}
- id: G-051
  type: negative
  question: "Thủ đô của Pháp là gì?"
```

**Script `tests/eval/run_eval.py`** (lệnh `make eval BASE_URL=… EVAL_USER=…`):

1. Đăng nhập bằng tài khoản eval.
2. Với mỗi câu: `POST /conversations` → gửi câu hỏi → đọc SSE tới `done`, `not_found` hoặc `error`.
3. Ghi `answer`, `citations`, `not_found_reason`, `latency_ms` vào `results/<timestamp>.csv`.
4. Tính tự động:
   - **KR2.2** = % trích dẫn có `(filename, page)` thuộc `expected_sources`;
   - **KR2.3** = % câu `negative` có `not_found`.
5. **KR2.1** (độ đúng của câu trả lời): xuất file `review_<timestamp>.csv` để BD / QA chấm thủ công cột `correct` (0/1) → `make eval-score` đọc lại file và tính % đúng.

Cách chấm KR2.1 (thủ công hay LLM-judge) cần PO và QA chốt; xem Dev_Tasks.md §6.

## Các bước thực hiện

1. Định nghĩa schema YAML và viết bộ 5 câu mẫu.
2. Viết client SSE trong Python (`httpx` stream).
3. Viết phần tính điểm và xuất CSV.
4. Gửi template cho BD để họ điền ≥ 50 câu positive / multi_doc và ≥ 10 câu negative.

## File cần tạo / sửa

- `backend/tests/eval/{golden.yaml,run_eval.py,score.py}`
- `Makefile (target eval, eval-score)`

## Tiêu chí hoàn thành

- [ ] Script chạy được end-to-end với 5 câu mẫu (dùng mock khi API hỏi đáp chưa có).
- [ ] Đã gửi template cho BD và có hạn bàn giao (DEP-002).
- [ ] Đạt Definition of Done chung ([User_Stories.md §9](../../requirements/User_Stories.md)): code review, CI xanh, đã deploy lên môi trường AWS.

## Kiểm thử

- Unit test phần tính KR2.2 và KR2.3 với dữ liệu giả.

## Ngoài phạm vi task này

- Chạy eval tự động hằng đêm (giai đoạn 2).

## Tham chiếu

- [PRD.md](../../requirements/PRD.md) §2.2 (KR2.1–KR2.3)
- [Blueprint_Design.md](../../design/Blueprint_Design.md) QAS-13
