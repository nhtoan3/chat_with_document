# T-022 — Kiểm thử Hỏi đáp

| Thuộc tính | Giá trị |
|---|---|
| Tính năng | F2 — Hỏi đáp AI |
| Giai đoạn | Sprint 1 — Xử lý PDF + Hỏi đáp AI (09/11 → 20/11/2026) |
| Loại | Kiểm thử |
| Ước lượng | 1 ngày |
| Phụ trách đề xuất | BE2 |
| Phụ thuộc (phải xong trước) | [T-020](T-020-ask-api.md) |
| Mở khóa cho | [T-023](T-023-quality-tuning.md) |
| Nhánh git | `feat/T-022-ask-tests` |
| Trạng thái | `To do` |

## Mục tiêu

Test tích hợp end-to-end cho luồng hỏi đáp.

## Phạm vi & đặc tả

| Ca kiểm thử | Kỳ vọng |
|---|---|
| 3 PDF mẫu đã `ready`, hỏi câu có đáp án ở tài liệu A | `FakeLLM` nhận ngữ cảnh chứa chunk của A |
| Tài liệu B đang `processing` | Ngữ cảnh không chứa chunk của B |
| Câu hỏi rỗng / 2001 ký tự | 422 |
| Không có tài liệu `ready` | 409 |
| `FakeLLM` ném lỗi | 503, `qa_log.status='error'` |
| Gọi thật (marker `live`, chạy thủ công) | Câu trả lời tiếng Việt, hợp lý với tài liệu mẫu |

## Các bước thực hiện

1. Viết test.

## File cần tạo / sửa

- `backend/tests/integration/test_ask.py`

## Tiêu chí hoàn thành

- [ ] Mọi ca (trừ `live`) pass trong CI.
- [ ] Code đã được review, CI xanh, đã deploy lên môi trường AWS.

## Kiểm thử

- (Chính là task kiểm thử.)

## Tham chiếu

- [User_Stories.md](../../requirements/User_Stories.md) US-008, US-011
