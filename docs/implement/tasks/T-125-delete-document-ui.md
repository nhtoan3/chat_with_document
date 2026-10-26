# T-125 — Nút gỡ tài liệu và hộp thoại xác nhận

| Thuộc tính | Giá trị |
|---|---|
| Story | [US-010 — Gỡ tài liệu](../../requirements/User_Stories.md) |
| Giai đoạn | Sprint 1 (09/11 → 20/11/2026) |
| Loại | Frontend |
| Ước lượng | 0,5 ngày |
| Phụ trách đề xuất | FE |
| Phụ thuộc (phải xong trước) | [T-118](T-118-documents-list-ui.md), [T-124](T-124-delete-document-api.md) |
| Mở khóa cho | — |
| Nhánh git | `feat/T-125-delete-document-ui` |
| Trạng thái | `To do` |

## Mục tiêu

Admin gỡ tài liệu sau khi xác nhận; Member không thấy nút gỡ.

## Phạm vi & đặc tả

- **Nút:** icon thùng rác (`aria-label="Gỡ {tên}"`), chỉ render khi `me.role === 'admin'`.
- **Hộp thoại xác nhận** (component `Dialog`): tiêu đề "Gỡ tài liệu?", tên tệp, nội dung "Tài liệu sẽ bị xóa ngay và không còn được dùng để trả lời. Không thể hoàn tác.", nút [Hủy] [Gỡ tài liệu] (màu nguy hiểm). Focus mặc định vào nút Hủy.
- **Thành công:** toast "Đã gỡ \"{tên}\"." + invalidate `documents`.
- **Lỗi:** toast lỗi theo `code`.

## Các bước thực hiện

1. Thêm nút vào cột thao tác.
2. Viết dialog.
3. Viết test.

## File cần tạo / sửa

- `frontend/src/features/documents/RemoveDocumentDialog.tsx`

## Tiêu chí hoàn thành

- [ ] AC-US-010-1 (bản đã sửa), 3, 6 pass.
- [ ] Đạt Definition of Done chung ([User_Stories.md §9](../../requirements/User_Stories.md)): code review, CI xanh, đã deploy lên môi trường AWS.

## Kiểm thử

- Playwright: Admin gỡ thành công; Member không thấy nút.

## Tham chiếu

- [docs/design/html_design/03-documents.html](../../design/html_design/) (dialog gỡ)
- [User_Stories.md](../../requirements/User_Stories.md) US-010
