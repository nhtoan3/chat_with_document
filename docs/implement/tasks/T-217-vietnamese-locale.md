# T-217 — Tiếng Việt và định dạng ngày giờ

| Thuộc tính | Giá trị |
|---|---|
| Story | [US-015 — Tiếng Việt](../../requirements/User_Stories.md) |
| Giai đoạn | Sprint 2 (23/11 → 04/12/2026) |
| Loại | Frontend |
| Ước lượng | 0,5 ngày |
| Phụ trách đề xuất | FE |
| Phụ thuộc (phải xong trước) | [T-007](T-007-frontend-shell.md) |
| Mở khóa cho | — |
| Nhánh git | `feat/T-217-vietnamese-locale` |
| Trạng thái | `To do` |

## Mục tiêu

Toàn bộ giao diện bằng tiếng Việt, ngày giờ theo định dạng và múi giờ Việt Nam.

## Phạm vi & đặc tả

- **Không có chuỗi viết cứng:** rà soát toàn bộ `src/` theo eslint rule `i18next/no-literal-string`; mọi chuỗi nằm trong `vi.json`.
- **Định dạng ngày giờ:** `shared/i18n/format.ts` dùng `Intl.DateTimeFormat('vi-VN', {timeZone: 'Asia/Ho_Chi_Minh', day: '2-digit', month: '2-digit', year: 'numeric'})` → `dd/mm/yyyy`; giờ dùng `HH:mm`.
- **HTML:** `<html lang="vi">`.
- **Phía backend:** quy tắc ngôn ngữ đã có trong system prompt (T-204, mục 3); không cần code thêm.

## Các bước thực hiện

1. Bật lint rule và sửa các vi phạm.
2. Viết hàm format; thay mọi chỗ hiển thị ngày.

## File cần tạo / sửa

- `frontend/src/shared/i18n/format.ts`
- `frontend/.eslintrc`

## Tiêu chí hoàn thành

- [ ] AC-US-015-1 (qua golden set tiếng Việt), AC-US-015-4 pass; lint sạch.
- [ ] Đạt Definition of Done chung ([User_Stories.md §9](../../requirements/User_Stories.md)): code review, CI xanh, đã deploy lên môi trường AWS.

## Kiểm thử

- Vitest cho hàm format.

## Ngoài phạm vi task này

- Câu hỏi tiếng Anh và câu không dấu (AC-US-015-2, 3 — đã bỏ).

## Tham chiếu

- [User_Stories.md](../../requirements/User_Stories.md) US-015, §2.1
