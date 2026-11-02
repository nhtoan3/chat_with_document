@AGENTS.md

# Claude Code — vận hành Agentic SDLC

## Đọc trước khi làm
- `docs/sdlc-state.md`: phase nào đã duyệt, câu hỏi mở, lỗi mở, hạ tầng. Kết thúc một phase hoặc task thì cập nhật file đó.
- Hiện **chưa tài liệu nào được duyệt**; tất cả là `Draft`. Không coi bất kỳ tài liệu nào là baseline.

## Bản đồ tài liệu (`docs/`)
| Thư mục | Nội dung | Lưu ý |
|---|---|---|
| `01-intake/` | intent, glossary, stakeholders, sources | Retrofit |
| `02-requirements/` | BRD, **PRD, User_Stories** (quy trình xếp vào 03-analysis), interviews (mới có mẫu), BRD prompt gốc = SRC-001 | BRD/PRD/US chưa theo v0.4 |
| `04-design/` | SAD, Blueprint, ADR-*, openapi, database-design, diagrams/, html_design/, schema.sql | SAD/Blueprint chưa theo v0.4; phần còn lại retrofit từ code |
| `05-development/` | **Implement_plan.md v0.4 = thẩm quyền**, SDP, WBS, tasks/T-001…024, traceability, evidence/ | Khi mâu thuẫn: Implement_plan và tasks/ thắng |
| `07-verification/` | Test_Plan, test_cases/ (quy ước bắt buộc trong README), test-report, coverage/, reviews/ | Bằng chứng chạy ở `test_reports/<ID>/` |
| Checklist `*.xlsx` | Nằm cạnh tài liệu được chấm | Review L1 của agent, không phải phê duyệt |

## Chạy quy trình
- `sdlc/agentic-sdlc-process.md` là quy trình; prompt và checklist gốc trong `sdlc/`.
- `/sdlc-run <phase> [T-xxx | next | PR | ghi chú]`: agent `sdlc-NN-*` điều phối Specify → Generate → Verify → Refine rồi **dừng ở cổng duyệt**. Không tự sang phase sau.

| Phase | Agent | Người duyệt |
|---|---|---|
| 1 Intake | `sdlc-01-intake` | PO |
| 2 Requirements | `sdlc-02-requirements` → `req-brd-elicitation`, `req-brd` | PM/PO |
| 3 Analysis | `sdlc-03-analysis` → `ana-prd` | PM/PO + Tech Lead |
| 4 Design | `sdlc-04-design` → `des-sad`, `des-uml-diagram`, `des-blueprint`, `des-api-design`, `des-db-design`, `des-ui-ux` | Architect + Tech Lead |
| 5 Planning | `sdlc-05-planning` → `plan-devplan`, `plan-task-breakdown`; đưa task lên `vibe_kanban` | PM/PO + Tech Lead |
| 6 Build | `sdlc-06-build` (test trước, code sau, commit trên `feat/T-xxx`) | Human owner |
| 7 Verify | `sdlc-07-verify` → `ver-test-plan`, `ver-code-review` | QA + Reviewer |
| 8 Review | `sdlc-08-review` chuẩn bị hồ sơ; con người review và merge | Reviewer ≠ Author |
| 9–11 | `sdlc-09-release`, `sdlc-10-operate`, `sdlc-11-decommission` | Release owner / Owner |

- Reviewer luôn là `checklist-audit`, khác agent đã viết. Nhiều task Phase 6: mỗi task một lần `/sdlc-run 6`, trạng thái nằm trên bảng và task card, không trong hội thoại.
- Sau baseline, mọi thay đổi qua `docs/changes/CR-*.md`; không ghi đè tài liệu đã `Approved`.
- Agent sinh từ `sdlc/`: sửa prompt ở `sdlc/` rồi `python3 .claude/skills/sdlc-run/scripts/gen_agents.py`; không sửa tay `.claude/agents/`.

## Kiểm thử và bằng chứng
- Kết luận chỉ ✅ Đạt / ❌ Không đạt / ⛔ Bị chặn, và **phải chạy thật**. Không có `ANTHROPIC_API_KEY`, không có golden set thật, hoặc cần người đánh giá → ⛔. Không suy từ CI cũ hay từ đọc code.
- Chạy test case tuần tự, chỉ localhost; mỗi case một thư mục `test_reports/<ID>/` theo mẫu trong `docs/07-verification/test_cases/README.md`. Không sửa ứng dụng để test đạt.
- Đổi `modules/qa/prompts.py`: `make eval` trước và sau, ghi điểm vào PR. `golden.yaml` hiện chỉ có 6 câu mẫu.

## Công cụ (`.mcp.json`, `.claude/settings.json`)
- `codegraph`: cần `codegraph init .` (có `.codegraph/`); hook chèn symbol và file phụ thuộc trước mỗi Edit/Write trong `backend/app`, `frontend/src`; dùng `codegraph_explore` trước khi sửa code.
- `playwright` (npx, headless), `vibe_kanban` (cần `npx vibe-kanban` đang chạy và đăng nhập).
- Script checklist cần `.sdlc/venv`: `python3 -m venv .sdlc/venv && .sdlc/venv/bin/pip install openpyxl`.

## Agent không được
- Approve, ký, merge, deploy, thay đổi production, đổi `Draft` → `Approved`, điền tên người duyệt, tự chấm tài liệu mình viết, bịa phỏng vấn hay kết quả test. Mọi giá trị chưa có nguồn ghi `[TBD]` kèm vai trò phụ trách.
