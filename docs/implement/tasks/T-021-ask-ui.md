# T-021 — Màn hình Hỏi đáp

| Thuộc tính | Giá trị |
|---|---|
| Tính năng | F2 — Hỏi đáp AI |
| Giai đoạn | Sprint 1 — Xử lý PDF + Hỏi đáp AI (09/11 → 20/11/2026) |
| Loại | Frontend |
| Ước lượng | 1,5 ngày |
| Phụ trách đề xuất | FE |
| Phụ thuộc (phải xong trước) | [T-007](T-007-frontend-shell.md), [T-020](T-020-ask-api.md) |
| Mở khóa cho | [T-024](T-024-uat-go-live.md) |
| Nhánh git | `feat/T-021-ask-ui` |
| Trạng thái | `To do` |

## Mục tiêu

Người dùng nhập câu hỏi và đọc câu trả lời trên một trang.

## Phạm vi & đặc tả

**`features/ask/AskPage.tsx`** — theo `html_design/04-chat.html`, **bỏ**: trích dẫn, mục Nguồn, panel PDF, đánh giá, nút Dừng, danh sách Gần đây.

- **Ô nhập:** `<textarea>`; Enter gửi, Shift+Enter xuống dòng; khóa nút Gửi khi rỗng hoặc > 2000 ký tự; bộ đếm `n/2000`.
- **Gửi:** thêm bong bóng câu hỏi; tin nhắn AI hiện "Đang tìm câu trả lời…" (spinner). Câu trả lời có thể mất **10–20 giây** vì không streaming, nên hiện thêm dòng phụ "Có thể mất tới 20 giây".
- **Câu trả lời:** Markdown (`marked`) đã làm sạch (`DOMPurify`); nhãn "Câu trả lời do AI tạo — hãy đối chiếu tài liệu gốc".
- **Lỗi** 503 / mạng → "Hệ thống đang bận, vui lòng thử lại" + nút **Hỏi lại**.
- **Chưa có tài liệu Sẵn sàng** (`counts.ready == 0`) → khóa ô nhập + hướng dẫn "Tải lên tài liệu để bắt đầu" (link `/documents`).
- **Lịch sử:** các cặp hỏi–đáp chỉ giữ trong bộ nhớ trang (mất khi tải lại trang).

## Các bước thực hiện

1. Viết trang và hook `useAsk`.
2. Viết test.

## File cần tạo / sửa

- `frontend/src/features/ask/*`

## Tiêu chí hoàn thành

- [ ] Hỏi → nhận câu trả lời; lỗi → Hỏi lại được; chưa có tài liệu → ô nhập bị khóa.
- [ ] Payload `<img onerror>` trong câu trả lời không được thực thi.
- [ ] Code đã được review, CI xanh, đã deploy lên môi trường AWS.

## Kiểm thử

- Playwright với API giả lập.

## Ngoài phạm vi task này

- Streaming, trích dẫn, lịch sử hội thoại.

## Tham chiếu

- [docs/design/html_design/04-chat.html](../../design/html_design/)
- [User_Stories.md](../../requirements/User_Stories.md) US-011
