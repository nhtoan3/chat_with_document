# T-303 — Khả năng tiếp cận và responsive

| Thuộc tính | Giá trị |
|---|---|
| Story | — (hạng mục nền tảng) |
| Giai đoạn | Tuần ổn định (07/12 → 11/12/2026) |
| Loại | Frontend |
| Ước lượng | 1 ngày |
| Phụ trách đề xuất | FE |
| Phụ thuộc (phải xong trước) | [T-224](T-224-reload-conversation.md) |
| Mở khóa cho | — |
| Nhánh git | `feat/T-303-a11y-responsive` |
| Trạng thái | `To do` |

## Mục tiêu

Các màn hình MVP đạt WCAG 2.1 AA và dùng được ở độ rộng 768–2560 px.

## Phạm vi & đặc tả

**Tự động:** `@axe-core/playwright` trên `/login`, `/documents`, `/chat` (gồm trạng thái có câu trả lời và trạng thái not-found) → 0 lỗi serious / critical (AC-G-04).

**Bàn phím:** Tab qua toàn bộ luồng đăng nhập → tải lên → hỏi → mở trích dẫn → đăng xuất, không cần chuột; focus luôn nhìn thấy được.

**Responsive:** kiểm tra ở 1440, 1280, 1024 và 768 px — không có thanh cuộn ngang; drawer hoạt động dưới 1280 px (AC-G-05).

**Trình đọc màn hình:** VoiceOver hoặc NVDA đọc được trạng thái tài liệu và câu trả lời sau khi stream xong.

## Các bước thực hiện

1. Thêm test axe vào CI.
2. Kiểm tra thủ công.
3. Sửa lỗi.

## File cần tạo / sửa

- `frontend/e2e/a11y.spec.ts`

## Tiêu chí hoàn thành

- [ ] AC-G-04, AC-G-05 đạt.
- [ ] Đạt Definition of Done chung ([User_Stories.md §9](../../requirements/User_Stories.md)): code review, CI xanh, đã deploy lên môi trường AWS.

## Kiểm thử

- Playwright + kiểm tra thủ công.

## Tham chiếu

- [Blueprint_Design.md](../../design/Blueprint_Design.md) UXS-02, UXS-04, UXC-01..03
