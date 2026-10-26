# T-111 — Vùng kéo-thả và tiến trình tải lên

| Thuộc tính | Giá trị |
|---|---|
| Story | [US-005 — Tải lên PDF](../../requirements/User_Stories.md) |
| Giai đoạn | Sprint 1 (09/11 → 20/11/2026) |
| Loại | Frontend |
| Ước lượng | 2 ngày |
| Phụ trách đề xuất | FE |
| Phụ thuộc (phải xong trước) | [T-007](T-007-frontend-shell.md), [T-110](T-110-upload-api.md) |
| Mở khóa cho | — |
| Nhánh git | `feat/T-111-upload-ui` |
| Trạng thái | `To do` |

## Mục tiêu

Người dùng kéo-thả hoặc chọn nhiều PDF, thấy tiến trình riêng từng tệp và lỗi ngay tại tệp đó.

## Phạm vi & đặc tả

**`features/documents/UploadZone.tsx`** — theo khối dropzone và hàng đợi trong `html_design/03-documents.html`:

- **Cách chọn tệp:** kéo-thả (đổi viền khi kéo qua); nút "Chọn file" (`<input type="file" accept=".pdf,application/pdf" multiple>`) có thể dùng bàn phím.
- **Kiểm tra phía client:**
  - > 10 tệp → banner ERR-09, không gửi tệp nào (AC-US-005-2);
  - tệp không phải `.pdf` hoặc > 20 MB → dòng lỗi riêng, không gửi tệp đó.
- **Gửi lên:** mỗi tệp hợp lệ gửi **một request riêng** `POST /documents` (1 tệp / request) bằng `XMLHttpRequest`, có header CSRF và `upload.onprogress` → thanh tiến trình theo %. Tối đa 3 request song song.
- **Kết quả:**
  - item có `error_code` → dòng lỗi với thông điệp `t('errors.'+code)`;
  - thành công → bỏ khỏi hàng đợi, invalidate query `documents`;
  - lỗi mạng (`xhr.onerror`) → "Mất kết nối khi tải lên" + nút **Thử lại** (gửi lại đúng tệp đó) (AC-US-005-6).

## Các bước thực hiện

1. Viết hook `useUploadQueue` (state theo từng tệp).
2. Viết component.
3. Viết test.

## File cần tạo / sửa

- `frontend/src/features/documents/UploadZone.tsx`
- `frontend/src/features/documents/useUploadQueue.ts`

## Tiêu chí hoàn thành

- [ ] AC-US-005-1, 2, 3, 5, 6 pass.
- [ ] Vùng kéo-thả và nút chọn file dùng được bằng bàn phím.
- [ ] Đạt Definition of Done chung ([User_Stories.md §9](../../requirements/User_Stories.md)): code review, CI xanh, đã deploy lên môi trường AWS.

## Kiểm thử

- Vitest cho logic kiểm tra phía client. Playwright: kéo-thả 3 tệp; chọn 11 tệp; giả lập offline giữa chừng.

## Ngoài phạm vi task này

- Hộp thoại trùng tên (US-024 hoãn) — trùng tên chỉ hiển thị lỗi ERR-14.

## Tham chiếu

- [docs/design/html_design/03-documents.html](../../design/html_design/)
- [User_Stories.md](../../requirements/User_Stories.md) US-005
