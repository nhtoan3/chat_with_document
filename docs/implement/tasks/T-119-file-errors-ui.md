# T-119 — Hiển thị lỗi xử lý tệp

| Thuộc tính | Giá trị |
|---|---|
| Story | [US-007 — Báo lỗi tệp](../../requirements/User_Stories.md) |
| Giai đoạn | Sprint 1 (09/11 → 20/11/2026) |
| Loại | Frontend |
| Ước lượng | 0,5 ngày |
| Phụ trách đề xuất | FE |
| Phụ thuộc (phải xong trước) | [T-118](T-118-documents-list-ui.md) |
| Mở khóa cho | — |
| Nhánh git | `feat/T-119-file-errors-ui` |
| Trạng thái | `To do` |

## Mục tiêu

Mỗi tệp lỗi hiển thị lý do rõ ràng bằng tiếng Việt và hướng xử lý.

## Phạm vi & đặc tả

Ánh xạ `error_code` → thông điệp trong `vi.json` (theo Blueprint §3.5.4):

| `error_code` | Thông điệp |
|---|---|
| `not_pdf` | "\"{file}\" không phải tệp PDF hợp lệ." |
| `file_too_large` | "\"{file}\" vượt quá 20 MB." |
| `encrypted_pdf` | "Tệp được bảo vệ bằng mật khẩu." |
| `no_text_layer` | "Không đọc được văn bản (PDF dạng ảnh chưa được hỗ trợ)." |
| `too_many_pages` | "Tệp dài hơn 300 trang." |
| `corrupted` | "Tệp bị hỏng, không mở được." |
| `transient_exhausted` | "Lỗi tạm thời khi xử lý. Hãy gỡ và tải lại tệp." |
| `duplicate_name` | "Đã có tài liệu tên \"{file}\"." |

Hiển thị dưới tên tệp trong bảng và trong hàng đợi tải lên, kèm icon lỗi.

## Các bước thực hiện

1. Thêm chuỗi vào `vi.json`.
2. Render trong bảng và hàng đợi.

## File cần tạo / sửa

- `frontend/src/shared/i18n/vi.json`
- `frontend/src/features/documents/*`

## Tiêu chí hoàn thành

- [ ] AC-US-007-1..5 hiển thị đúng thông điệp.
- [ ] Đạt Definition of Done chung ([User_Stories.md §9](../../requirements/User_Stories.md)): code review, CI xanh, đã deploy lên môi trường AWS.

## Kiểm thử

- Vitest snapshot cho từng mã lỗi.

## Ngoài phạm vi task này

- Nút Thử lại sau 3 lần retry (AC-US-007-6, đã bỏ).

## Tham chiếu

- [Blueprint_Design.md](../../design/Blueprint_Design.md) §3.5.4
- [User_Stories.md](../../requirements/User_Stories.md) US-007, §2.1
