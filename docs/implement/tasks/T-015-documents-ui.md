# T-015 — Màn hình Tài liệu: tải lên, danh sách, trạng thái

| Thuộc tính | Giá trị |
|---|---|
| Tính năng | F1 — Xử lý PDF |
| Giai đoạn | Sprint 1 — Xử lý PDF + Hỏi đáp AI (09/11 → 20/11/2026) |
| Loại | Frontend |
| Ước lượng | 2 ngày |
| Phụ trách đề xuất | FE |
| Phụ thuộc (phải xong trước) | [T-007](T-007-frontend-shell.md), [T-009](T-009-upload-api.md), [T-014](T-014-documents-list-api.md) |
| Mở khóa cho | [T-024](T-024-uat-go-live.md) |
| Nhánh git | `feat/T-015-documents-ui` |
| Trạng thái | `To do` |

## Mục tiêu

Người dùng chọn PDF để tải lên và thấy trạng thái xử lý từng tài liệu tự cập nhật.

## Phạm vi & đặc tả

**`features/documents/DocumentsPage.tsx`** — theo `html_design/03-documents.html`, **bỏ**: kéo-thả, thanh tiến trình, tab, tìm kiếm, nút gỡ.

**Tải lên:**

- Nút "Chọn file PDF" (`<input type="file" accept=".pdf" multiple>`).
- Kiểm tra phía client: > 10 tệp → banner lỗi; tệp > 20 MB hoặc không phải `.pdf` → báo lỗi tại tệp đó.
- Gửi một request `POST /documents` chứa các tệp hợp lệ, nút hiển thị "Đang tải lên…".
- Item lỗi trong response → hiển thị thông điệp theo `error_code`.

**Bảng:** tên tệp, số trang, ngày tải lên (`dd/mm/yyyy`), trạng thái. Badge có icon + chữ: Đang chờ / Đang xử lý / Sẵn sàng / Lỗi + lý do.

**Thông điệp lỗi** (`vi.json`):

| `error_code` | Thông điệp |
|---|---|
| `not_pdf` | Không phải tệp PDF hợp lệ |
| `file_too_large` | Vượt quá 20 MB |
| `duplicate_name` | Đã có tài liệu cùng tên |
| `encrypted_pdf` | Tệp có mật khẩu |
| `no_text_layer` | PDF dạng ảnh chưa được hỗ trợ |
| `too_many_pages` | Dài hơn 300 trang |
| `corrupted` | Tệp bị hỏng |
| `transient_exhausted` | Lỗi tạm thời, hãy tải lại |

**Tự cập nhật:** `refetchInterval: 3000` khi `counts.processing > 0`. Tài liệu chuyển sang `ready` → toast "[tên] đã sẵn sàng". Số trên sidebar = `counts.ready`.

## Các bước thực hiện

1. Hook `useDocuments`, `useUpload`.
2. Viết trang.
3. Viết test.

## File cần tạo / sửa

- `frontend/src/features/documents/*`
- `frontend/src/shared/i18n/vi.json`

## Tiêu chí hoàn thành

- [ ] Tải 3 PDF → thấy chuyển từ Đang chờ → Sẵn sàng mà không cần tải lại trang.
- [ ] Tệp lỗi hiển thị đúng lý do.
- [ ] Code đã được review, CI xanh, đã deploy lên môi trường AWS.

## Kiểm thử

- Playwright: tải 3 tệp hợp lệ + 1 tệp lỗi.

## Ngoài phạm vi task này

- Kéo-thả, tiến trình, gỡ tài liệu.

## Tham chiếu

- [docs/design/html_design/03-documents.html](../../design/html_design/)
- [User_Stories.md](../../requirements/User_Stories.md) US-005, US-006, US-007
