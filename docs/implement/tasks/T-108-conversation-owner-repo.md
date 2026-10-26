# T-108 — Repository hội thoại có kiểm tra chủ sở hữu

| Thuộc tính | Giá trị |
|---|---|
| Story | [US-003 — Hội thoại của riêng tôi](../../requirements/User_Stories.md) |
| Giai đoạn | Sprint 1 (09/11 → 20/11/2026) |
| Loại | Backend |
| Ước lượng | 0,5 ngày |
| Phụ trách đề xuất | BE2 |
| Phụ thuộc (phải xong trước) | [T-004](T-004-db-baseline.md), [T-101](T-101-session-csrf.md) |
| Mở khóa cho | [T-109](T-109-conversation-rbac-tests.md), [T-201](T-201-conversation-api.md) |
| Nhánh git | `feat/T-108-conversation-owner-repo` |
| Trạng thái | `To do` |

## Mục tiêu

Không ai, kể cả Admin, đọc hoặc ghi được hội thoại của người khác; truy cập trái phép nhận 404.

## Phạm vi & đặc tả

**`modules/conversations/adapters/sql_repo.py`** — mọi hàm nhận `user_id` và đưa điều kiện sở hữu **vào chính câu SQL**:

| Hàm | SQL chính |
|---|---|
| `create(user_id, collection_id, title)` | `INSERT conversations` |
| `get_owned(conv_id, user_id)` | `SELECT … WHERE id=:id AND user_id=:uid` → không có → `AppError('not_found', 404)` |
| `add_message(conv_id, user_id, role, content, …)` | Gọi `get_owned` trước; `INSERT messages`; cập nhật `conversations.last_activity_at` |
| `list_messages(conv_id, user_id)` | `JOIN conversations` có điều kiện `user_id` |

**Không** viết hàm nào lấy hội thoại chỉ theo `id`. Thêm comment ở đầu file nêu rõ quy tắc này.

## Các bước thực hiện

1. Viết repository và domain object `Conversation`, `Message`.
2. Viết test (T-109).

## File cần tạo / sửa

- `backend/app/modules/conversations/**`

## Tiêu chí hoàn thành

- [ ] Mọi hàm có tham số `user_id`; code review xác nhận không có truy vấn nào bỏ qua điều kiện sở hữu.
- [ ] Đạt Definition of Done chung ([User_Stories.md §9](../../requirements/User_Stories.md)): code review, CI xanh, đã deploy lên môi trường AWS.

## Kiểm thử

- Xem T-109.

## Ngoài phạm vi task này

- Endpoint hội thoại (T-201).

## Tham chiếu

- [User_Stories.md](../../requirements/User_Stories.md) US-003
- [SAD.md](../../design/SAD.md) §4.1 (phân quyền)
