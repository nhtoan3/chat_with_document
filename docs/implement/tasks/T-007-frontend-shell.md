# T-007 — Frontend shell, design system và API client

| Thuộc tính | Giá trị |
|---|---|
| Story | — (hạng mục nền tảng) |
| Giai đoạn | Sprint 0 (02/11 → 06/11/2026) |
| Loại | Frontend |
| Ước lượng | 2 ngày |
| Phụ trách đề xuất | FE |
| Phụ thuộc (phải xong trước) | [T-001](T-001-repo-skeleton.md) |
| Mở khóa cho | [T-104](T-104-login-ui.md), [T-111](T-111-upload-ui.md), [T-118](T-118-documents-list-ui.md), [T-123](T-123-chat-source-indicator.md), [T-207](T-207-sse-client.md), [T-217](T-217-vietnamese-locale.md) |
| Nhánh git | `feat/T-007-frontend-shell` |
| Trạng thái | `To do` |

## Mục tiêu

Khung SPA dùng chung cho mọi màn hình, đồng bộ với thiết kế trong `docs/design/html_design/`.

## Phạm vi & đặc tả

| Thành phần | Yêu cầu |
|---|---|
| Router (`app/router.tsx`) | `/login`, `/chat`, `/chat/:conversationId`, `/documents`, `/error/:code`, `*` → `/error/404`. Route khác `/login` phải đăng nhập (guard gọi `/me`) |
| `AppShell` | Topbar (logo, tên + vai trò người dùng, nút Đăng xuất), sidebar (nút "Hội thoại mới", menu Hỏi đáp / Tài liệu kèm số tài liệu Sẵn sàng). Dưới 1280 px: sidebar thành drawer có nút menu (`aria-expanded`). Theo bố cục `html_design/04-chat.html` |
| `shared/ui/tokens.css` | Sao chép biến `:root` từ html_design (màu, bo góc, bóng đổ, font Be Vietnam Pro) |
| Component | `Button` (primary / secondary / danger / ghost / icon), `Badge`, `Dialog` (dùng `<dialog>`, có focus trap), `Toast` (`aria-live`), `EmptyState`, `Table`, `Banner` |
| `shared/api/client.ts` | `apiFetch(path, init)`: tiền tố `/api/v1`, `credentials: 'same-origin'`, tự gắn `X-CSRF-Token` (lấy từ cache `/me`) cho request không phải GET. 401 → `navigate('/login?next=…')`. Body problem+json → `throw new ApiError(code, status)` |
| `shared/api/errors.ts` | `messageFor(code)` → `t('errors.'+code)` |
| `shared/i18n/vi.json` | Đủ chuỗi giao diện và thông điệp ERR-01..20 (lấy từ Blueprint §3.5.4) |
| Trang lỗi | `/error/403`, `/error/404`, `/error/503` theo `html_design/08-errors.html` |

## Các bước thực hiện

1. Thiết lập React Query provider, i18n provider, router.
2. Chuyển CSS token và component cơ bản từ html_design sang React.
3. Viết `apiFetch` và `ApiError`; viết unit test.
4. Dựng `AppShell` và trang lỗi.

## File cần tạo / sửa

- `frontend/src/app/*`
- `frontend/src/shared/{api,ui,i18n}/*`

## Tiêu chí hoàn thành

- [ ] Ở độ rộng 1440 px và 1024 px, shell hiển thị giống html_design (so sánh bằng mắt).
- [ ] Không có chuỗi giao diện viết cứng (eslint rule `i18next/no-literal-string` bật).
- [ ] `axe-core` không báo lỗi serious / critical trên shell.
- [ ] Đạt Definition of Done chung ([User_Stories.md §9](../../requirements/User_Stories.md)): code review, CI xanh, đã deploy lên môi trường AWS.

## Kiểm thử

- Vitest: `apiFetch` gắn CSRF; ánh xạ 401 / problem+json. Playwright: drawer mở và đóng bằng bàn phím.

## Ngoài phạm vi task này

- Nội dung các màn hình nghiệp vụ (thuộc task của từng story).

## Tham chiếu

- [docs/design/html_design/](../../design/html_design/) (index.html, 04-chat.html, 08-errors.html)
- [Blueprint_Design.md](../../design/Blueprint_Design.md) §2.4, §2.5
