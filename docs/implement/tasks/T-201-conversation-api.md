# T-201 — API hội thoại: tạo và đọc tin nhắn

| Thuộc tính | Giá trị |
|---|---|
| Story | [US-011 — Hỏi và nhận câu trả lời](../../requirements/User_Stories.md) |
| Giai đoạn | Sprint 2 (23/11 → 04/12/2026) |
| Loại | Backend |
| Ước lượng | 0,5 ngày |
| Phụ trách đề xuất | BE2 |
| Phụ thuộc (phải xong trước) | [T-108](T-108-conversation-owner-repo.md) |
| Mở khóa cho | [T-202](T-202-sse-endpoint.md), [T-224](T-224-reload-conversation.md) |
| Nhánh git | `feat/T-201-conversation-api` |
| Trạng thái | `To do` |

## Mục tiêu

Frontend tạo được hội thoại và tải lại tin nhắn của hội thoại đó khi refresh trang.

## Phạm vi & đặc tả

| Endpoint | Hành vi |
|---|---|
| `POST /api/v1/conversations` | Body rỗng → tạo hội thoại `title='Hội thoại mới'` thuộc `current_user`, collection `default` → 201 `{id}` |
| `GET /api/v1/conversations/{id}/messages` | `list_messages(id, current_user)` → `{items: [{id, role, content, state, not_found_reason, created_at, citations: [{idx, document_id, document_title, page_start, page_end, cited_text}]}]}`. Không thuộc quyền → 404 |

Tiêu đề hội thoại được cập nhật ở T-203: lấy 80 ký tự đầu của câu hỏi đầu tiên.

**Bổ sung test mức API cho US-003** (TODO từ T-109): người dùng B gọi 2 endpoint này với hội thoại của A → 404.

## Các bước thực hiện

1. Viết router `conversations.py`.
2. Viết test, gồm cả test quyền sở hữu mức API.

## File cần tạo / sửa

- `backend/app/api/routers/conversations.py`

## Tiêu chí hoàn thành

- [ ] Tạo và đọc được hội thoại; B truy cập hội thoại của A nhận 404 (AC-US-003-1, 2, 3).
- [ ] Đạt Definition of Done chung ([User_Stories.md §9](../../requirements/User_Stories.md)): code review, CI xanh, đã deploy lên môi trường AWS.

## Kiểm thử

- Integration.

## Ngoài phạm vi task này

- Danh sách hội thoại / lịch sử (US-020 hoãn).

## Tham chiếu

- [SAD.md](../../design/SAD.md) §2.4
- [User_Stories.md](../../requirements/User_Stories.md) US-003, US-011
