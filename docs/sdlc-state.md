# Trạng thái quy trình SDLC — đọc trước khi làm

> Cập nhật: 2026-11-02 (commit `a091f9b`). **Ai kết thúc một phase hoặc một task thì cập nhật file này**; mọi số liệu dưới đây có nguồn, không ước lượng.

## Phạm vi và vị trí trong quy trình

- Phạm vi hiện hành: **MVP v0.4** (`docs/05-development/Implement_plan.md`): F1 Xử lý PDF, F2 Hỏi đáp AI. Không đăng nhập, không trích dẫn, không streaming.
- Code đã viết xong trước khi phần lớn tài liệu SDLC được bổ sung (26/10). Tài liệu Phase 1, 4 (ADR, API, CSDL, UML), 5 (SDP, WBS) và 7 là **retrofit**, ghi rõ ở đầu mỗi file.
- Go-live kế hoạch: 30/11/2026. UAT: 26/11. Go / no-go: 27/11.

## Cổng duyệt

| Phase | Tài liệu | Trạng thái | Người duyệt theo quy trình |
|---|---|---|---|
| 1 Intake | `docs/01-intake/` | Draft, **chưa duyệt** | PO |
| 2 Requirements | `BRD.md` v0.1 | Draft, chưa theo v0.4, **chưa duyệt**; chưa có biên bản phỏng vấn | PM/PO |
| 3 Analysis | `PRD.md` v0.1, `User_Stories.md` v0.2 (ở `02-requirements/`) | Draft, chưa theo v0.4, **chưa duyệt** | PM/PO + Tech Lead |
| 4 Design | `SAD.md` v0.2, `Blueprint_Design.md`, ADR, `openapi.md`, `database-design.md`, `diagrams/` | Draft, SAD/Blueprint chưa theo v0.4, **chưa duyệt** | Architect + Tech Lead |
| 5 Planning | `Implement_plan.md` v0.4 (thẩm quyền), SDP, WBS, 24 task | Draft; **v0.4 và 4 đánh đổi chưa có bản ghi duyệt** (phiếu: `docs/05-development/evidence/Phe_duyet_v0.4_OQ-008.md`) | PM/PO + Tech Lead |
| 6 Build | 24 task: 23 `In progress`, T-023 `To do`, **0 `Done`** | Tiêu chí "review, CI xanh, deploy AWS" chưa task nào đạt | Human owner |
| 7 Verify | `Test_Plan.md` v0.2, `test-report.md`, `coverage/` | 77 test case: **64 ✅ · 5 ❌ · 8 ⛔**; backend coverage 76 %, frontend 7,1 % | QA + Reviewer |
| 8 Review | — | **Chưa có PR, chưa có review nào.** 0 merge commit | Reviewer ≠ Author |
| 9–11 | — | Chưa đến | Release owner |

**Chưa có tài liệu nào được duyệt.** Mọi ô phê duyệt để trống. Tác giả hầu hết tài liệu là Huy Toan, đồng thời là PO và Tech lead; người duyệt độc lập chưa được chỉ định (OQ-001).

## Checklist đã chấm (review L1 của agent, không phải phê duyệt)

17 checklist, 340 mục: **Done 76 · In Progress 180 · Pending 51 · N/A 33**; Database Design Review: Yes 8, No 10, đề xuất review lại. File nằm cạnh tài liệu tương ứng.

## Câu hỏi mở chặn tiến độ

| Mã | Nội dung | Hạn | Trạng thái |
|---|---|---|---|
| OQ-008 | Được gửi tài liệu tới Anthropic API không; phân loại bảo mật | 06/11/2026 | **Mở**; quyết định nhà cung cấp AI và go-live |
| — | Duyệt phạm vi v0.4 và 4 đánh đổi | 28/10 (quá hạn) | Mở |
| OQ-001 | Người phê duyệt từng tài liệu | 27/10 (quá hạn) | Mở |
| — | Dải IP / VPN cho ALB | 30/10 (quá hạn) | Mở |
| DEP-002 | Golden set thật (≥ 30 positive, ≥ 10 negative) và PDF mẫu | 05/11 | Mở; `golden.yaml` chỉ có 6 câu mẫu |

## Lỗi đang mở (nguồn: `docs/07-verification/test-report.md`)

| Mã | Mức (đề xuất) | Tóm tắt |
|---|---|---|
| DEF-01 | Critical, chờ kiểm chứng trên S3 thật | Tệp > 8 MB nhận `storage_error` với S3Mock (multipart) |
| DEF-02 | Major | AI không phản hồi thì 182,5 s mới báo lỗi, mục tiêu ≤ 30 s |
| DEF-03 | Major | PDF 50 trang `failed` vì `/embed` vượt timeout 30 s (TEI giả lập x86) |
| DEF-04 | Major | `not_found` có trong `ERRORS` nhưng thiếu trong `vi.json` |
| DEF-05 | Minor | Worker thoát hẳn khi mất PostgreSQL; compose local không restart |
| DEF-06 | Minor | `make fixtures`/`make seed` ghi đè fixture được git theo dõi |
| DEF-07 | Minor | `make dev` in URL web trước khi web sẵn sàng ~1 phút |

Ngoài ra, reviewer thiết kế ghi nhận: `DATABASE_URL` có `?ssl=require` theo `infra/README.md` nhiều khả năng làm `alembic upgrade head` lỗi với psycopg (chưa thử trên RDS).

## Hạ tầng và công cụ

- **CI:** GitHub Actions, job `backend` và `frontend` xanh; job `build` đỏ ở `configure-aws-credentials` vì chưa có AWS. Chưa có coverage, secret scan, dependency scan trong CI.
- **AWS:** chưa dựng. `infra/` mới là script và hướng dẫn.
- **Khóa Anthropic:** không có; mọi test cần Claude thật là ⛔.
- **MCP:** `codegraph` (đã `codegraph init`), `playwright` (npx), `agent-browser` (**chưa cài**), `vibe_kanban` (cần app đang chạy và tài khoản đăng nhập; dự án này đang sunsetting).
- **Bộ Agentic SDLC:** 25 agent, skill `/sdlc-run`, **chưa chạy thử đầu cuối**.

## Việc tiếp theo theo thứ tự

1. Quản lý quyết định OQ-008 và duyệt phạm vi v0.4 (phiếu ở `docs/05-development/evidence/`).
2. Chỉ định người duyệt độc lập (OQ-001) rồi mở cổng duyệt Phase 1 → 5.
3. Sửa DEF-04 qua `/sdlc-run 6 T-025` (task card đã tạo) để thử quy trình.
4. Nhận golden set, có khóa API → chạy EVAL-001…005, T-023.
5. Dựng AWS (T-006) → kiểm chứng DEF-01, DEF-03, `ssl=require`, SEC-*, PERF-002.
