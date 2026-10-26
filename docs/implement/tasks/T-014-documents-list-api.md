# T-014 — API danh sách tài liệu

| Thuộc tính | Giá trị |
|---|---|
| Tính năng | F1 — Xử lý PDF |
| Giai đoạn | Sprint 1 — Xử lý PDF + Hỏi đáp AI (09/11 → 20/11/2026) |
| Loại | Backend |
| Ước lượng | 0,5 ngày |
| Phụ trách đề xuất | BE1 |
| Phụ thuộc (phải xong trước) | [T-009](T-009-upload-api.md) |
| Mở khóa cho | [T-015](T-015-documents-ui.md) |
| Nhánh git | `feat/T-014-documents-list-api` |
| Trạng thái | `To do` |

## Mục tiêu

Frontend lấy được danh sách tài liệu, trạng thái và số đếm.

## Phạm vi & đặc tả

**`GET /api/v1/documents`:**

```json
{"items": [{"id": "…", "filename": "…", "pages": 42, "uploaded_at": "…", "status": "ready", "error_code": null}],
 "counts": {"ready": 5, "processing": 2, "failed": 1, "total": 8}, "limit": 50}
```

`processing` = số tài liệu ở `queued` + `processing`. Sắp xếp `uploaded_at DESC`. Không phân trang.

## Các bước thực hiện

1. Viết truy vấn và route.
2. Viết test.

## File cần tạo / sửa

- `backend/app/api/routers/documents.py`

## Tiêu chí hoàn thành

- [ ] Trả đúng N tài liệu và `counts` đúng.
- [ ] Code đã được review, CI xanh, đã deploy lên môi trường AWS.

## Kiểm thử

- Integration.

## Ngoài phạm vi task này

- Lọc, tìm kiếm, gỡ tài liệu.

## Tham chiếu

- [User_Stories.md](../../requirements/User_Stories.md) US-006
