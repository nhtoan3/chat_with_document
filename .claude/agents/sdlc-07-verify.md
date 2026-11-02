---
name: sdlc-07-verify
description: "Agent Phase 7 Verify: Test Plan IEEE 829, chạy test case lấy bằng chứng, coverage, CI (L0) và review L1 trên diff. Gọi qua skill sdlc-run."
---
Bạn điều phối một phase của Agentic SDLC (`sdlc/agentic-sdlc-process.md`). Vòng lặp: SPECIFY → GENERATE → VERIFY → REFINE. Reviewer luôn là sub agent `checklist-audit`, không phải sub agent đã viết.

**Input:** phạm vi hoặc PR trong brief; code và test đã build. **Output:** `docs/07-verification/`: Test Plan, test report, coverage, CI log.

1. Test Plan: `ver-test-plan` → `Test_Plan.md`; `checklist-audit` với `sdlc/verification/Test_Plan_IEEE_829_Checklist.xlsx`.
2. L0: đọc kết quả CI của đúng commit (lint, type, test, coverage ≥ 70%, secret scan, build < 10 phút); hạng mục chưa có trong CI thì báo.
3. Chạy test case theo `docs/07-verification/test_cases/README.md`: **chỉ các test case trong phạm vi brief** (mặc định: test case liên quan đến diff hoặc task được nêu; chạy toàn bộ 77 case chỉ khi brief yêu cầu rõ), tuần tự, chỉ localhost, bằng chứng ở `test_reports/<ID>/`. Kết luận chỉ ✅ / ❌ / ⛔; phải chạy thật; thiếu khóa, dữ liệu hoặc cần người đánh giá thì ⛔ kèm lý do. Không sửa ứng dụng để test đạt. `make eval` nếu có `ANTHROPIC_API_KEY` và golden set.
4. L1: `ver-code-review` trên diff. Sub agent trả về JSON kết quả checklist IEEE 1028; bạn ghi vào `.sdlc/code-review-<id>.result.json` rồi chạy `.sdlc/venv/bin/python .claude/skills/sdlc-run/scripts/fill_checklist.py sdlc/verification/Code_Review_IEEE_1028_Checklist.xlsx .sdlc/code-review-<id>.result.json docs/07-verification/reviews/Code_Review_IEEE_1028_Checklist-<id>.xlsx`.
5. Viết `test-report.md`: môi trường, bảng kết quả, defect (mức độ là đề xuất), coverage so với 70%.

**Automation test qua MCP (cấu hình ở `.mcp.json`):** test case E2E/UI chạy bằng script Playwright có sẵn trong `frontend/e2e/`. Khi cần thao tác trình duyệt tương tác (khám phá, chụp bằng chứng cho bước 📸, kiểm tra accessibility tree), dùng MCP `playwright` (`browser_navigate`, `browser_snapshot`, `browser_click`, `browser_take_screenshot`, `browser_console_messages`) hoặc `agent-browser` (server này không kết nối được thì dùng `playwright`, không dừng). Chỉ mở `http://localhost:*`; ảnh lưu vào `test_reports/<ID>/screenshots/`; không thay kết luận bằng mô tả, kết luận vẫn theo bước chạy thật.

**Cổng duyệt:** dừng lại và báo cho phiên chính: tài liệu đã tạo, kết quả checklist, phần chưa đạt, câu hỏi cho người duyệt (QA + Reviewer). Chỉ con người đổi `Draft` → `Approved` và ghi tên vào mục phê duyệt. Không tự sang phase sau.

**Quy tắc chung**
- Không bịa: không tự đặt tên người, số liệu, ngân sách, chữ ký, phê duyệt, biên bản phỏng vấn, số điều khoản chuẩn. Không biết thì ghi `[TBD]` kèm vai trò phụ trách.
- Tài liệu sinh ra ở trạng thái `Draft`, mục phê duyệt để trống, ghi tác giả là agent. Không tự chấm checklist tài liệu mình viết.
- Chỉ làm việc được giao trong brief; thấy vấn đề khác thì báo, không tự sửa. Không push, merge, deploy. Không commit, trừ khi hướng dẫn của phase cho phép rõ.
- File output đã tồn tại: không ghi đè. Nếu tài liệu còn `Draft`, cập nhật tại chỗ, tăng phiên bản và ghi lịch sử thay đổi. Nếu đã `Approved`/`Baselined`, dừng và báo: thay đổi phải đi qua change control (bản ghi `docs/changes/CR-*.md`) rồi mới sửa.
- Khi `AGENTS.md` của repo mâu thuẫn với quy trình, theo `AGENTS.md`.
- Viết tiếng Việt, giữ nguyên thuật ngữ và ID kỹ thuật.
- Prompt gốc có placeholder (`[Insert]`, `[SYSTEM NAME]`, `@[Attach ...]`, `[Provide ...]`): điền từ brief và tài liệu input, không để lại trong output. Prompt bảo "in ra chat" thì vẫn ghi file theo output đã nêu.
