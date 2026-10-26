# T-302 — Rà soát bảo mật trước go-live

| Thuộc tính | Giá trị |
|---|---|
| Story | — (hạng mục nền tảng) |
| Giai đoạn | Tuần ổn định (07/12 → 11/12/2026) |
| Loại | Hạ tầng / DevOps |
| Ước lượng | 1,5 ngày |
| Phụ trách đề xuất | TL |
| Phụ thuộc (phải xong trước) | [T-224](T-224-reload-conversation.md) |
| Mở khóa cho | [T-305](T-305-uat.md) |
| Nhánh git | `feat/T-302-security-review` |
| Trạng thái | `To do` |

## Mục tiêu

Không còn lỗ hổng mức Critical / High trước khi đưa dữ liệu thật vào hệ thống.

## Phạm vi & đặc tả

**Checklist** (ghi kết quả vào `docs/implement/evidence/T-302.md`):

| # | Hạng mục | Cách kiểm tra |
|---|---|---|
| 1 | Mọi endpoint (trừ `/auth/login`, `/healthz`) yêu cầu đăng nhập | Script gọi toàn bộ route trong OpenAPI khi chưa đăng nhập → 401 |
| 2 | CSRF trên mọi POST / DELETE | Gọi thiếu header → 403 |
| 3 | Quyền sở hữu hội thoại; quyền Admin khi gỡ tài liệu | Test T-109, T-124 |
| 4 | Cookie `HttpOnly`, `Secure`, `SameSite=Lax` | DevTools |
| 5 | Header bảo mật: `Content-Security-Policy` (`default-src 'self'`), `X-Content-Type-Options`, `Referrer-Policy`, HSTS | `curl -I` |
| 6 | Không log nội dung câu hỏi / tài liệu | Tìm trong CloudWatch các chuỗi từ golden set |
| 7 | Dependency | `pip-audit`, `npm audit` sạch mức high |
| 8 | Secret | Không có trong image / repo (`gitleaks`, `docker history`) |
| 9 | S3 | Không có quyền public; bắt buộc TLS và KMS |
| 10 | RDS | Không public; TLS bắt buộc (`rds.force_ssl=1`) |
| 11 | Upload | Giới hạn kích thước ở Nginx và API; tệp không phải PDF bị chặn |
| 12 | XSS qua câu trả lời | Ca số 5 của T-216 |

## Các bước thực hiện

1. Chạy checklist.
2. Mở lỗi cho mục không đạt.
3. Xác nhận đã sửa.

## File cần tạo / sửa

- `docs/implement/evidence/T-302.md`
- `infra/nginx.conf (header bảo mật)`

## Tiêu chí hoàn thành

- [ ] 12/12 mục đạt hoặc rủi ro còn lại được PO chấp nhận bằng văn bản.
- [ ] Đạt Definition of Done chung ([User_Stories.md §9](../../requirements/User_Stories.md)): code review, CI xanh, đã deploy lên môi trường AWS.

## Kiểm thử

- (Chính là task kiểm thử.)

## Ngoài phạm vi task này

- Pentest bởi bên thứ ba.

## Tham chiếu

- [SAD.md](../../design/SAD.md) §4.1
- [PRD.md](../../requirements/PRD.md) §6.1
