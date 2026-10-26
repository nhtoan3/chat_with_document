# T-124 — API gỡ tài liệu (Admin)

| Thuộc tính | Giá trị |
|---|---|
| Story | [US-010 — Gỡ tài liệu](../../requirements/User_Stories.md) |
| Giai đoạn | Sprint 1 (09/11 → 20/11/2026) |
| Loại | Backend |
| Ước lượng | 1 ngày |
| Phụ trách đề xuất | BE2 |
| Phụ thuộc (phải xong trước) | [T-110](T-110-upload-api.md), [T-005](T-005-platform-kernel.md) |
| Mở khóa cho | [T-125](T-125-delete-document-ui.md) |
| Nhánh git | `feat/T-124-delete-document-api` |
| Trạng thái | `To do` |

## Mục tiêu

Admin xóa ngay một tài liệu; tài liệu đó không còn được dùng để trả lời.

## Phạm vi & đặc tả

**`DELETE /api/v1/documents/{id}`** — `require_role('admin')`; Member nhận 403 `forbidden`.

1. Không tìm thấy → 404.
2. **Transaction:** `audit('document_remove', target=document, details={filename})` → `DELETE FROM documents WHERE id` (chunk và job xóa theo CASCADE; `citations.document_id` → NULL, `document_title` vẫn giữ).
3. **Sau commit:** `storage.delete_all_versions(key)`. Lỗi S3 chỉ ghi log `warning`, **không** rollback (tài liệu đã biến mất khỏi hệ thống; object thừa trên S3 được dọn thủ công).
4. Trả 204.

Nếu tài liệu đang được worker xử lý: job sẽ không tìm thấy document → worker đánh dấu job `failed` và bỏ qua (xử lý trường hợp này trong `run_ingest`).

## Các bước thực hiện

1. Viết use case `remove_document`.
2. Viết route.
3. Sửa `run_ingest` cho trường hợp tài liệu đã bị xóa.
4. Viết test.

## File cần tạo / sửa

- `backend/app/modules/documents/application/remove.py`
- `backend/app/api/routers/documents.py`

## Tiêu chí hoàn thành

- [ ] Sau khi xóa, các câu hỏi có đáp án chỉ nằm trong tài liệu đó không còn trích dẫn nó (AC-US-010-2).
- [ ] Member gọi → 403 (AC-US-010-3).
- [ ] Có audit `document_remove` (AC-US-010-6).
- [ ] Đạt Definition of Done chung ([User_Stories.md §9](../../requirements/User_Stories.md)): code review, CI xanh, đã deploy lên môi trường AWS.

## Kiểm thử

- Integration: xóa → không còn dòng `chunks`; citation cũ có `document_id = NULL`; Member nhận 403.

## Ngoài phạm vi task này

- Xóa mềm và job xóa sau 30 ngày (đã bỏ trong MVP).

## Tham chiếu

- [User_Stories.md](../../requirements/User_Stories.md) US-010, §2.1
- [SAD.md](../../design/SAD.md) 'Phạm vi kiến trúc cho MVP'
