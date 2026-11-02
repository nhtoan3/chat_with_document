---
name: sdlc-run
description: "Chạy một phase của Agentic SDLC (sdlc/agentic-sdlc-process.md) bằng agent của phase đó, rồi dừng ở cổng duyệt của con người."
argument-hint: "<số phase 1-11> [mã task, PR, hoặc ghi chú]"
disable-model-invocation: true
---
Phase: **$0**. Tham số đầy đủ: `$ARGUMENTS` (phần sau số phase là ghi chú, mã task hoặc PR).

| Phase | Agent | Cần kèm |
|---|---|---|
| 1 | `sdlc-01-intake` | mô tả ý tưởng |
| 2 | `sdlc-02-requirements` | |
| 3 | `sdlc-03-analysis` | vị trí output nếu repo đã có tài liệu |
| 4 | `sdlc-04-design` | |
| 5 | `sdlc-05-planning` | |
| 6 | `sdlc-06-build` | mã task `T-xxx`, hoặc `next` để lấy task kế tiếp từ bảng vibe_kanban |
| 7 | `sdlc-07-verify` | phạm vi hoặc PR |
| 8 | `sdlc-08-review` | số PR hoặc nhánh |
| 9 | `sdlc-09-release` | tag hoặc commit |
| 10 | `sdlc-10-operate` | sự cố hoặc chủ đề |
| 11 | `sdlc-11-decommission` | |

1. Kiểm tra input của phase (output phase trước đã duyệt chưa, mục phê duyệt trong tài liệu). Chưa duyệt thì hỏi người dùng có làm tiếp không; nếu tiếp, ghi vào brief để agent ghi "input chưa duyệt" ở đầu tài liệu.
2. Hỏi người dùng các quyết định không suy ra được trước khi giao, vì agent không hỏi được người dùng.
3. Gọi agent của phase với brief: phase, input, output, ghi chú trên, điều đã biết. Chờ kết quả.
4. Báo lại nguyên trạng: tài liệu, kết quả checklist, phần chưa đạt, câu hỏi cho người duyệt. Không tự chuyển phase; không commit nếu không được yêu cầu.

**Nhiều task (Phase 6):** mỗi task là một lần `/sdlc-run 6 T-xxx` (hoặc `/sdlc-run 6 next`) trong một phiên hoặc sau `/clear`, để mỗi task có context mới. Trạng thái nằm trên bảng `vibe_kanban` và trong task card, không nằm trong hội thoại; phiên chính không cần nhớ các task trước.

Script dùng chung cho agent nằm ở `scripts/` (`gen_agents.py` sinh lại `.claude/agents/` từ `sdlc/`) (checklist cần openpyxl: `python3 -m venv .sdlc/venv && .sdlc/venv/bin/pip install openpyxl`).
