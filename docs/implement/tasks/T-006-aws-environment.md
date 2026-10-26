# T-006 — Môi trường AWS và script deploy

| Thuộc tính | Giá trị |
|---|---|
| Story | — (hạng mục nền tảng) |
| Giai đoạn | Sprint 0 (02/11 → 06/11/2026) |
| Loại | Hạ tầng / DevOps |
| Ước lượng | 2,5 ngày |
| Phụ trách đề xuất | TL |
| Phụ thuộc (phải xong trước) | [T-003](T-003-ci-pipeline.md) |
| Mở khóa cho | [T-220](T-220-latency-test.md), [T-221](T-221-sse-proxy-config.md), [T-304](T-304-runbook.md) |
| Nhánh git | `feat/T-006-aws-environment` |
| Trạng thái | `To do` |

## Mục tiêu

Một môi trường AWS duy nhất (ADR-012) chạy được ứng dụng qua HTTPS và deploy được bằng một lệnh.

## Phạm vi & đặc tả

**Tài nguyên** (tạo bằng console hoặc CLI có ghi lại các bước trong `infra/README.md`; Terraform để giai đoạn 2):

| Tài nguyên | Cấu hình |
|---|---|
| VPC | 2 public subnet (ALB), 2 private subnet (EC2, RDS); NAT Gateway để gọi `api.anthropic.com` |
| EC2 | `m7i.2xlarge`, Amazon Linux 2023, Docker + Compose plugin; EBS gp3 100 GB có mã hóa; IAM role: đọc Secrets Manager, ECR pull, S3 trên bucket ứng dụng, CloudWatch Logs |
| RDS | PostgreSQL 16, `db.t4g.medium`, 50 GB gp3, mã hóa KMS, backup 7 ngày; parameter group cho phép extension `vector` |
| S3 | `cwd-documents-prod`; Block Public Access; SSE-KMS (CMK riêng); versioning; bucket policy bắt buộc `aws:SecureTransport` |
| ALB | Listener 443 (chứng chỉ ACM), 80 → 301 sang 443; target là EC2:80 (Nginx); idle timeout 120 s; health check `/healthz` |
| Secrets Manager | `cwd/prod`: `DATABASE_URL`, `ANTHROPIC_API_KEY` |
| ECR | Repository `cwd-api`, `cwd-web` |
| CloudWatch | Log group `/cwd/prod`; Docker log driver `awslogs` |

**`infra/deploy.sh <tag>`**: SSH (hoặc SSM) vào EC2 → lấy secret ghi ra `.env` (quyền 600) → `docker compose pull` → chạy `alembic upgrade head` (container một lần) → `docker compose up -d` → smoke test `curl -f https://<domain>/healthz` → ghi tag hiện tại vào `.last_tag`. `infra/rollback.sh` deploy lại tag trong `.last_tag`.

**Nginx** (container `web`, phục vụ SPA đã build): `location /api/ { proxy_pass http://api:8000; proxy_buffering off; proxy_read_timeout 120s; }`.

## Các bước thực hiện

1. Tạo các tài nguyên theo bảng; ghi lại các bước trong `infra/README.md`.
2. Viết `docker-compose.prod.yml` gồm `web` (Nginx + static), `api`, `worker`, `tei` (không có postgres / minio).
3. Viết `deploy.sh`, `rollback.sh`.
4. Deploy image từ T-003 và kiểm tra HTTPS.

## File cần tạo / sửa

- `infra/README.md`
- `infra/docker-compose.prod.yml`
- `infra/nginx.conf`
- `infra/deploy.sh`
- `infra/rollback.sh`

## Tiêu chí hoàn thành

- [ ] `https://<domain>/healthz` trả 200 qua ALB.
- [ ] `deploy.sh` chạy idempotent; `rollback.sh` quay về tag trước trong < 10 phút.
- [ ] Log của `api` xuất hiện trong CloudWatch.
- [ ] Bucket S3 từ chối request HTTP thường và upload không có SSE-KMS.
- [ ] Đạt Definition of Done chung ([User_Stories.md §9](../../requirements/User_Stories.md)): code review, CI xanh, đã deploy lên môi trường AWS.

## Kiểm thử

- Deploy 2 lần liên tiếp cùng một tag không lỗi; thử rollback.

## Ngoài phạm vi task này

- Terraform, môi trường staging riêng, Multi-AZ (giai đoạn 2).

## Tham chiếu

- [SAD.md](../../design/SAD.md) §4.4, ADR-009, ADR-012
- [Blueprint_Design.md](../../design/Blueprint_Design.md) §3.8
