# T-118 — Màn hình danh sách tài liệu và tự cập nhật trạng thái

| Thuộc tính | Giá trị |
|---|---|
| Story | [US-006 — Trạng thái xử lý tài liệu](../../requirements/User_Stories.md) |
| Giai đoạn | Sprint 1 (09/11 → 20/11/2026) |
| Loại | Frontend |
| Ước lượng | 1,5 ngày |
| Phụ trách đề xuất | FE |
| Phụ thuộc (phải xong trước) | [T-007](T-007-frontend-shell.md), [T-117](T-117-documents-list-api.md) |
| Mở khóa cho | [T-119](T-119-file-errors-ui.md), [T-125](T-125-delete-document-ui.md) |
| Nhánh git | `feat/T-118-documents-list-ui` |
| Trạng thái | `To do` |

## Mục tiêu

Người dùng thấy mọi tài liệu và trạng thái xử lý, tự cập nhật mà không cần tải lại trang.

## Phạm vi & đặc tả

**`features/documents/DocumentsPage.tsx`** — theo `html_design/03-documents.html`, **bỏ tab lọc và ô tìm kiếm**:

- **Phần đầu trang:** tiêu đề, mô tả, chỉ báo "x/50 tài liệu" (dạng progressbar có `aria-valuenow`), `UploadZone` (T-111).
- **Bảng:** tên tệp (icon PDF), số trang, người tải lên, ngày tải lên (`dd/mm/yyyy`), trạng thái, cột thao tác (nút Gỡ — T-125).
- **Badge trạng thái** (icon + chữ, không phân biệt chỉ bằng màu — AC-US-006-4): Đang chờ xử lý / Đang xử lý (icon xoay) / Sẵn sàng / Lỗi.
- **Tự cập nhật:** `useQuery(['documents'], { refetchInterval: (q) => q.state.data?.counts.processing ? 3000 : false })` (AC-US-006-2). Khi đang tự cập nhật, hiện dòng "Tự cập nhật khi có tài liệu đang xử lý".
- **Phát hiện chuyển trạng thái:** so trạng thái cũ và mới của từng `id`; chuyển sang `ready` → toast "[tên] đã sẵn sàng để hỏi đáp" (AC-US-006-3).
- **Menu:** số trên menu "Tài liệu" ở sidebar = `counts.ready`.
- **Trạng thái trống:** khi chưa có tài liệu nào.

## Các bước thực hiện

1. Viết hook `useDocuments`.
2. Viết bảng và badge.
3. Viết test.

## File cần tạo / sửa

- `frontend/src/features/documents/*`

## Tiêu chí hoàn thành

- [ ] AC-US-006-2, 3, 4 pass; danh sách đúng AC-US-009-1.
- [ ] Đạt Definition of Done chung ([User_Stories.md §9](../../requirements/User_Stories.md)): code review, CI xanh, đã deploy lên môi trường AWS.

## Kiểm thử

- Vitest: logic phát hiện chuyển trạng thái. Playwright: tải tệp → thấy trạng thái đổi sang Sẵn sàng và toast.

## Ngoài phạm vi task này

- Tab lọc và tìm kiếm.

## Tham chiếu

- [docs/design/html_design/03-documents.html](../../design/html_design/)
- [User_Stories.md](../../requirements/User_Stories.md) US-006
