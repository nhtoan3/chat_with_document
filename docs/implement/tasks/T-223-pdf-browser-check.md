# T-223 — Kiểm tra mở PDF tại trang trên các trình duyệt

| Thuộc tính | Giá trị |
|---|---|
| Story | [US-017 — Mở PDF tại trang](../../requirements/User_Stories.md) |
| Giai đoạn | Sprint 2 (23/11 → 04/12/2026) |
| Loại | Kiểm thử |
| Ước lượng | 0,5 ngày |
| Phụ trách đề xuất | QA |
| Phụ thuộc (phải xong trước) | [T-222](T-222-open-citation.md) |
| Mở khóa cho | — |
| Nhánh git | `feat/T-223-pdf-browser-check` |
| Trạng thái | `To do` |

## Mục tiêu

Biết chính xác trình duyệt nào hỗ trợ mở PDF tại trang `#page=N`.

## Phạm vi & đặc tả

Kiểm tra thủ công trên các trình duyệt mới nhất:

| Trình duyệt | Mở được PDF? | Đúng trang? | Ghi chú |
|---|---|---|---|
| Chrome (Windows / macOS) | | | |
| Edge (Windows) | | | |
| Firefox | | | |
| Safari (macOS) | | | |

Trình duyệt nào không hỗ trợ `#page`: ghi vào hướng dẫn sử dụng ("PDF mở ở trang 1, hãy chuyển tới trang N") và báo PO.

## Các bước thực hiện

1. Kiểm tra.
2. Ghi kết quả vào `docs/implement/evidence/T-223.md`.

## File cần tạo / sửa

- `docs/implement/evidence/T-223.md`

## Tiêu chí hoàn thành

- [ ] Bảng kết quả đầy đủ; hướng dẫn sử dụng đã cập nhật nếu cần.
- [ ] Đạt Definition of Done chung ([User_Stories.md §9](../../requirements/User_Stories.md)): code review, CI xanh, đã deploy lên môi trường AWS.

## Kiểm thử

- (Chính là task kiểm thử.)

## Tham chiếu

- [PRD.md](../../requirements/PRD.md) §8.1 (trình duyệt hỗ trợ)
