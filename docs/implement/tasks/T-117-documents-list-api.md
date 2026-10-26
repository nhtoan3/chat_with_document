# T-117 — API danh sách tài liệu

| Thuộc tính | Giá trị |
|---|---|
| Story | [US-006 — Trạng thái xử lý tài liệu](../../requirements/User_Stories.md) |
| Giai đoạn | Sprint 1 (09/11 → 20/11/2026) |
| Loại | Backend |
| Ước lượng | 0,5 ngày |
| Phụ trách đề xuất | BE1 |
| Phụ thuộc (phải xong trước) | [T-110](T-110-upload-api.md) |
| Mở khóa cho | [T-118](T-118-documents-list-ui.md), [T-123](T-123-chat-source-indicator.md) |
| Nhánh git | `feat/T-117-documents-list-api` |
| Trạng thái | `To do` |

## Mục tiêu

Frontend lấy được danh sách tài liệu, trạng thái và số đếm trong một lần gọi.

## Phạm vi & đặc tả

**`GET /api/v1/documents`** (cần đăng nhập):

```json
{"items": [{"id": "…", "filename": "…", "pages": 42, "uploaded_by_name": "Nguyễn Lan",
            "uploaded_at": "2026-11-12T03:15:00Z", "status": "ready", "error_code": null}],
 "counts": {"ready": 5, "processing": 2, "failed": 1, "total": 8},
 "limit": 50}
```

- `processing` = số tài liệu ở `queued` + `processing`.
- Sắp xếp theo `uploaded_at DESC`. Không phân trang (tối đa 50).

## Các bước thực hiện

1. Viết truy vấn (JOIN `users` lấy tên).
2. Viết route và test.

## File cần tạo / sửa

- `backend/app/api/routers/documents.py`
- `backend/app/modules/documents/adapters/sql_repo.py`

## Tiêu chí hoàn thành

- [ ] Trả đúng N tài liệu, không thiếu, không trùng (AC-US-009-1, đã gộp vào US-006).
- [ ] Đạt Definition of Done chung ([User_Stories.md §9](../../requirements/User_Stories.md)): code review, CI xanh, đã deploy lên môi trường AWS.

## Kiểm thử

- Integration: 3 tài liệu ở 3 trạng thái → `counts` đúng.

## Ngoài phạm vi task này

- Lọc và tìm kiếm (đã bỏ trong MVP).

## Tham chiếu

- [User_Stories.md](../../requirements/User_Stories.md) §2.1 (US-006 gộp US-009)
