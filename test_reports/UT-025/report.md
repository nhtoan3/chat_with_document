# Báo cáo kiểm thử — UT-025: Render Markdown an toàn (chống XSS)

| Mục | Giá trị |
|---|---|
| Test case | [UT-025](../../docs/07-verification/test_cases/UT-025.md) |
| Kết luận | **✅ Đạt** |
| Thời gian chạy | 2026-11-02 21:39:05 → 21:39:08 (UTC+7) |
| Người / agent thực hiện | Claude Code (agent), `frontend/e2e/run-cli.mjs` + `steps.sh` |
| Commit | `c02cc72 (có thay đổi chưa commit)` |
| Môi trường | localhost · web http://localhost:5173 · API http://localhost:8000 · Darwin 27.0.0 arm64 · Docker 29.6.2 · ANTHROPIC_API_KEY: không |
| Script | [steps.sh](steps.sh) |

## Kết quả từng bước

| # | Thao tác | Kết quả mong đợi | Kết quả thực tế | Đạt? | Bằng chứng |
|---|---|---|---|---|---|
| 1 | Ghi nhận môi trường: commit, phiên bản Node và trạng thái stack localhost | In ra commit, Node ≥ 20 và trạng thái stack | commit `c02cc72`; Node `v24.18.0`; Stack OK | ✅ | [ảnh](screenshots/01-buoc-1-ghi-nhan-moi-truong-commit-phien-ban-node-va-trang-th.png) |
| 2 | Chạy `npx vitest run src/features/ask/markdown.test.ts` | `Tests  3 passed (3)`, exit code 0 | vitest: `Tests 3 passed (3)` | ✅ | [ảnh](screenshots/02-buoc-2-chay-npx-vitest-run-src-features-ask-markdown-test-ts.png) |

## Bằng chứng

- Video: [video.webm](video.webm)
- Log: [logs/run-meta.json](logs/run-meta.json), [logs/steps.log](logs/steps.log)
- Ảnh:

  ![01-buoc-1-ghi-nhan-moi-truong-commit-phien-ban-node-va-trang-th.png](screenshots/01-buoc-1-ghi-nhan-moi-truong-commit-phien-ban-node-va-trang-th.png)

  ![02-buoc-2-chay-npx-vitest-run-src-features-ask-markdown-test-ts.png](screenshots/02-buoc-2-chay-npx-vitest-run-src-features-ask-markdown-test-ts.png)

## Lỗi phát hiện

Không có.

## Ghi chú và sai lệch so với test case

Không có.
