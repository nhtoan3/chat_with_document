# T-301 — Tinh chỉnh chất lượng câu trả lời

| Thuộc tính | Giá trị |
|---|---|
| Story | — (hạng mục nền tảng) |
| Giai đoạn | Tuần ổn định (07/12 → 11/12/2026) |
| Loại | Backend |
| Ước lượng | 3 ngày |
| Phụ trách đề xuất | BE1 + BE2 + QA |
| Phụ thuộc (phải xong trước) | [T-208](T-208-multi-doc-tuning.md), [T-212](T-212-citation-eval.md), [T-214](T-214-tau-calibration.md) |
| Mở khóa cho | [T-305](T-305-uat.md) |
| Nhánh git | `feat/T-301-quality-tuning` |
| Trạng thái | `To do` |

## Mục tiêu

Đạt ngưỡng chất lượng của launch gate: KR2.1 ≥ 80%, KR2.2 ≥ 90%, KR2.3 ≥ 90% ⚑.

## Phạm vi & đặc tả

**Chạy `make eval` mỗi ngày** trên môi trường AWS; ghi kết quả vào `tests/eval/results/STAB-<ngày>.md`.

**Phân loại từng câu sai**, mỗi nhóm có hướng xử lý riêng:

| Nhóm lỗi | Dấu hiệu | Hướng xử lý |
|---|---|---|
| Truy xuất sai | Chunk đúng không có trong top N | Tăng N; thêm `QA_MAX_PER_DOC`; nếu vẫn kém → bật full-text (ADR-003) |
| Chunk cắt dở thông tin | Đáp án nằm vắt qua 2 chunk | Tăng `CHUNK_OVERLAP`; xem lại cách gộp trang ngắn |
| Mô hình trả lời sai / thiếu | Chunk đúng có trong ngữ cảnh nhưng câu trả lời sai | Sửa prompt (T-204) |
| `not_found` nhầm | Câu positive bị chặn bởi τ | Hạ τ (T-214) |
| Bịa | Câu negative có câu trả lời | Tăng τ; củng cố prompt |

**Mỗi thay đổi** là một PR riêng kèm điểm eval trước / sau.

**Điểm dừng:** đạt ngưỡng 2 lần chạy liên tiếp, **hoặc** tới thứ Năm 10/12 → báo PO quyết định go / no-go.

## Các bước thực hiện

1. Chạy eval hằng ngày.
2. Phân loại lỗi.
3. Sửa theo nhóm lỗi.
4. Báo cáo tại buổi họp go / no-go.

## File cần tạo / sửa

- `backend/tests/eval/results/*`

## Tiêu chí hoàn thành

- [ ] Đạt ngưỡng hoặc PO đã có quyết định go / no-go bằng văn bản.
- [ ] Đạt Definition of Done chung ([User_Stories.md §9](../../requirements/User_Stories.md)): code review, CI xanh, đã deploy lên môi trường AWS.

## Kiểm thử

- Golden eval.

## Tham chiếu

- [PRD.md](../../requirements/PRD.md) §6.1 (launch gate)
- [Implement_plan.md](../Implement_plan.md) §4
