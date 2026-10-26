# T-109 — Kiểm thử quyền sở hữu hội thoại

| Thuộc tính | Giá trị |
|---|---|
| Story | [US-003 — Hội thoại của riêng tôi](../../requirements/User_Stories.md) |
| Giai đoạn | Sprint 1 (09/11 → 20/11/2026) |
| Loại | Kiểm thử |
| Ước lượng | 0,25 ngày |
| Phụ trách đề xuất | BE2 |
| Phụ thuộc (phải xong trước) | [T-108](T-108-conversation-owner-repo.md) |
| Mở khóa cho | — |
| Nhánh git | `feat/T-109-conversation-rbac-tests` |
| Trạng thái | `To do` |

## Mục tiêu

Chứng minh người dùng B (Member hoặc Admin) không truy cập được hội thoại của A.

## Phạm vi & đặc tả

**Mức repository (Sprint 1):** A tạo hội thoại H; B gọi `get_owned(H, B)`, `add_message(H, B, …)`, `list_messages(H, B)` → đều ném `not_found`. Lặp lại với B là Admin.

**Mức API:** bổ sung trong T-201 khi đã có endpoint — `POST /conversations/{H}/messages` và `GET …/messages` bằng cookie của B → 404, body không chứa dữ liệu của H.

## Các bước thực hiện

1. Viết test mức repository.
2. Ghi TODO trỏ tới T-201 cho test mức API.

## File cần tạo / sửa

- `backend/tests/integration/test_conversation_ownership.py`

## Tiêu chí hoàn thành

- [ ] AC-US-003-1, 2, 3 được chứng minh ở mức repository.
- [ ] Đạt Definition of Done chung ([User_Stories.md §9](../../requirements/User_Stories.md)): code review, CI xanh, đã deploy lên môi trường AWS.

## Kiểm thử

- (Chính là task kiểm thử.)

## Tham chiếu

- [User_Stories.md](../../requirements/User_Stories.md) AC-US-003-1..3
