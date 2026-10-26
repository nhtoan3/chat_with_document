# T-006 — Môi trường AWS, giới hạn truy cập và script deploy

| Thuộc tính | Giá trị |
|---|---|
| Tính năng | — (hạng mục nền tảng) |
| Giai đoạn | Sprint 0 — Nền tảng (02/11 → 06/11/2026) |
| Loại | Hạ tầng / DevOps |
| Ước lượng | 2 ngày |
| Phụ trách đề xuất | TL |
| Phụ thuộc (phải xong trước) | [T-003](T-003-ci.md) |
| Mở khóa cho | [T-024](T-024-uat-go-live.md) |
| Nhánh git | `feat/T-006-aws-environment` |
| Trạng thái | `To do` |

## Mục tiêu

Một môi trường AWS chạy ứng dụng qua HTTPS, **chỉ truy cập được từ mạng công ty**, deploy bằng một lệnh.

## Phạm vi & đặc tả

| Tài nguyên | Cấu hình |
|---|---|
| EC2 | `m7i.2xlarge`, Docker Compose (`web` / Nginx, `api`, `worker`, `tei`); IAM role đọc Secrets Manager, ECR, S3, CloudWatch Logs |
| RDS | PostgreSQL 16 `db.t4g.medium`, mã hóa KMS, backup 7 ngày, extension `vector` |
| S3 | `cwd-documents-prod`; Block Public Access; SSE-KMS; bắt buộc TLS |
| ALB | HTTPS (ACM), 80 → 443; **security group chỉ cho phép dải IP công ty / VPN** (danh sách do IT cung cấp); idle timeout 120 s |
| Secrets Manager | `DATABASE_URL`, `ANTHROPIC_API_KEY` |
| CloudWatch | Log group `/cwd/prod` |

> ⚠ **Đã bỏ đăng nhập**, nên **giới hạn IP / VPN là lớp bảo vệ duy nhất** cho tài liệu kinh doanh. Không được mở ALB ra `0.0.0.0/0`.

**Script:**

- `infra/deploy.sh <tag>`: lấy secret → `docker compose pull` → `alembic upgrade head` → `docker compose up -d` → `curl -f /healthz` → lưu `.last_tag`.
- `infra/rollback.sh`: deploy lại tag trước.

**Nginx:** `client_max_body_size 25m;` và `proxy_read_timeout 90s;` cho `/api/`.

## Các bước thực hiện

1. Xin IT danh sách IP / VPN.
2. Tạo tài nguyên; ghi các bước vào `infra/README.md`.
3. Viết `docker-compose.prod.yml`, `nginx.conf`, `deploy.sh`, `rollback.sh`.
4. Deploy thử.

## File cần tạo / sửa

- `infra/README.md`
- `infra/docker-compose.prod.yml`
- `infra/nginx.conf`
- `infra/deploy.sh`
- `infra/rollback.sh`

## Tiêu chí hoàn thành

- [ ] Từ mạng công ty: `https://<domain>/healthz` trả 200.
- [ ] Từ mạng ngoài (ví dụ 4G điện thoại): không kết nối được.
- [ ] `rollback.sh` quay về tag trước trong < 10 phút.
- [ ] Code đã được review, CI xanh, đã deploy lên môi trường AWS.

## Kiểm thử

- Kiểm tra truy cập từ trong và ngoài mạng công ty.

## Ngoài phạm vi task này

- Terraform, staging riêng, giám sát (đã lược bỏ).

## Tham chiếu

- [SAD.md](../../design/SAD.md) §4.4, ADR-012
