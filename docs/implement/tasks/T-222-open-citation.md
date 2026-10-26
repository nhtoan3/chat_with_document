# T-222 — Mở PDF tại trang được trích dẫn

| Thuộc tính | Giá trị |
|---|---|
| Story | [US-017 — Mở PDF tại trang](../../requirements/User_Stories.md) |
| Giai đoạn | Sprint 2 (23/11 → 04/12/2026) |
| Loại | Frontend |
| Ước lượng | 0,5 ngày |
| Phụ trách đề xuất | FE |
| Phụ thuộc (phải xong trước) | [T-106](T-106-file-endpoint.md), [T-211](T-211-citation-ui.md) |
| Mở khóa cho | [T-223](T-223-pdf-browser-check.md) |
| Nhánh git | `feat/T-222-open-citation` |
| Trạng thái | `To do` |

## Mục tiêu

Bấm vào trích dẫn mở PDF gốc ở tab mới, đúng trang được trích dẫn.

## Phạm vi & đặc tả

**Click chip `[n]` hoặc dòng nguồn:**

```ts
window.open(`/api/v1/documents/${c.document_id}/file?page=${c.page_start}`, '_blank', 'noopener')
```

Backend (T-106) trả 302 tới presigned URL kèm `#page=N`; trình xem PDF sẵn có của trình duyệt mở tại đúng trang.

**`document_id == null`** (tài liệu đã bị gỡ): chip và dòng nguồn có `aria-disabled="true"`, gạch ngang, tooltip "Tài liệu đã bị gỡ"; bấm vào không làm gì.

**Thuộc tính truy cập:** `title="Mở {tên} tại trang {p} (tab mới)"`.

## Các bước thực hiện

1. Thêm handler click.
2. Xử lý trạng thái vô hiệu.
3. Viết test.

## File cần tạo / sửa

- `frontend/src/features/chat/Answer.tsx`
- `frontend/src/features/chat/SourcesList.tsx`

## Tiêu chí hoàn thành

- [ ] AC-US-017-4 (thay cho AC-US-017-1) pass.
- [ ] Đạt Definition of Done chung ([User_Stories.md §9](../../requirements/User_Stories.md)): code review, CI xanh, đã deploy lên môi trường AWS.

## Kiểm thử

- Playwright: bắt sự kiện `popup` và kiểm tra URL chứa `page=`.

## Ngoài phạm vi task này

- Panel xem PDF trong ứng dụng, tô sáng đoạn trích (đã bỏ).

## Tham chiếu

- [User_Stories.md](../../requirements/User_Stories.md) US-017, §2.1
