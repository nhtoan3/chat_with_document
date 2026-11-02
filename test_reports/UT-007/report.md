# Báo cáo kiểm thử — UT-007: Trích xuất PDF từ chối tệp quá 300 trang

| Mục | Giá trị |
|---|---|
| Test case | [UT-007](../../docs/07-verification/test_cases/UT-007.md) |
| Kết luận | **✅ Đạt** |
| Thời gian chạy | 2026-11-02 21:37:45 → 21:37:50 (UTC+7) |
| Người / agent thực hiện | Claude Code (agent), `frontend/e2e/run-cli.mjs` + `steps.sh` |
| Commit | `c02cc72 (có thay đổi chưa commit)` |
| Môi trường | localhost · web http://localhost:5173 · API http://localhost:8000 · Darwin 27.0.0 arm64 · Docker 29.6.2 · ANTHROPIC_API_KEY: không |
| Script | [steps.sh](steps.sh) |

## Kết quả từng bước

| # | Thao tác | Kết quả mong đợi | Kết quả thực tế | Đạt? | Bằng chứng |
|---|---|---|---|---|---|
| 1 | Ghi nhận môi trường: commit, phiên bản Python và trạng thái stack localhost | In ra commit hiện tại, Python 3.12 và trạng thái stack | commit `c02cc72`; Python 3.12.16; Stack OK | ✅ | [ảnh](screenshots/01-buoc-1-ghi-nhan-moi-truong-commit-phien-ban-python-va-trang-.png) |
| 2 | Chạy `tests/unit/test_pdf_extractor.py::test_too_many_pages` | `1 passed` (hoặc mọi biến thể tham số đều passed), exit code 0 | pytest: `1 passed, 5 warnings in 1.05s` | ✅ | [ảnh](screenshots/02-buoc-2-chay-tests-unit-test-pdf-extractor-py-test-too-many-p.png) |

## Bằng chứng

- Video: [video.webm](video.webm)
- Log: [logs/run-meta.json](logs/run-meta.json), [logs/steps.log](logs/steps.log)
- Ảnh:

  ![01-buoc-1-ghi-nhan-moi-truong-commit-phien-ban-python-va-trang-.png](screenshots/01-buoc-1-ghi-nhan-moi-truong-commit-phien-ban-python-va-trang-.png)

  ![02-buoc-2-chay-tests-unit-test-pdf-extractor-py-test-too-many-p.png](screenshots/02-buoc-2-chay-tests-unit-test-pdf-extractor-py-test-too-many-p.png)

## Lỗi phát hiện

Không có.

## Ghi chú và sai lệch so với test case

Không có.
