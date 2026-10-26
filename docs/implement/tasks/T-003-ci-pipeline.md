# T-003 — CI trên GitHub Actions

| Thuộc tính | Giá trị |
|---|---|
| Story | — (hạng mục nền tảng) |
| Giai đoạn | Sprint 0 (02/11 → 06/11/2026) |
| Loại | Hạ tầng / DevOps |
| Ước lượng | 1 ngày |
| Phụ trách đề xuất | TL |
| Phụ thuộc (phải xong trước) | [T-001](T-001-repo-skeleton.md) |
| Mở khóa cho | [T-006](T-006-aws-environment.md) |
| Nhánh git | `feat/T-003-ci-pipeline` |
| Trạng thái | `To do` |

## Mục tiêu

Mỗi pull request được kiểm tra tự động; PR không được merge khi CI đỏ.

## Phạm vi & đặc tả

Workflow `.github/workflows/ci.yml`, chạy trên `pull_request` và `push` vào `main`:

| Job | Bước |
|---|---|
| `backend` | setup Python 3.12 → cài dependencies (có cache) → `ruff check` → `ruff format --check` → `mypy app` → `pytest -m "not eval"` (Testcontainers cần Docker, có sẵn trên `ubuntu-latest`) → `pip-audit` |
| `frontend` | setup Node 20 → `npm ci` → `eslint` → `tsc --noEmit` → `vitest run` → `npm audit --audit-level=high` |
| `secrets` | `gitleaks detect` |
| `build` (chỉ trên `main`) | build image `api` và `web` cho `linux/amd64`, gắn tag `sha-<short>`, push lên ECR (cần secret `AWS_*` từ T-006) |

Bật branch protection cho `main`: bắt buộc 3 job đầu xanh và ≥ 1 review.

## Các bước thực hiện

1. Viết `ci.yml` với 4 job.
2. Thêm `pytest.ini` với marker `eval` (loại khỏi CI).
3. Bật branch protection trên GitHub.
4. Mở một PR thử để xác nhận CI chạy được.

## File cần tạo / sửa

- `.github/workflows/ci.yml`
- `backend/pytest.ini`

## Tiêu chí hoàn thành

- [ ] PR mẫu chạy xanh toàn bộ.
- [ ] PR cố ý chứa lỗi lint thì bị chặn merge.
- [ ] Thời gian CI < 10 phút.
- [ ] Đạt Definition of Done chung ([User_Stories.md §9](../../requirements/User_Stories.md)): code review, CI xanh, đã deploy lên môi trường AWS.

## Kiểm thử

- Commit một chuỗi giống secret (ví dụ `AKIA...`) → job `secrets` đỏ.

## Ngoài phạm vi task này

- Semgrep, Trivy và `import-linter` (để giai đoạn 2, theo ADR-012).

## Tham chiếu

- [SAD.md](../../design/SAD.md) ADR-012
