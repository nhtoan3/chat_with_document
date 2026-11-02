@AGENTS.md

# Claude Code — bổ sung cho AGENTS.md

- Quy trình Agentic SDLC: `sdlc/agentic-sdlc-process.md`. Chạy một phase bằng `/sdlc-run <1-11> [mã task | PR | ghi chú]`; mỗi phase dừng ở cổng duyệt, con người duyệt.
- Agent trong `.claude/agents/` được sinh từ prompt trong `sdlc/`: sửa prompt ở `sdlc/` rồi chạy `python3 .claude/skills/sdlc-run/scripts/gen_agents.py`; không sửa tay file agent.
- Script checklist cần `.sdlc/venv` (`python3 -m venv .sdlc/venv && .sdlc/venv/bin/pip install openpyxl`); hook codegraph cần `codegraph init .`; MCP khai báo ở `.mcp.json`.
- Agent không approve, merge, deploy, hay đổi trạng thái `Draft` → `Approved` thay con người. Tài liệu đã `Approved` chỉ sửa qua `docs/changes/CR-*.md`.
