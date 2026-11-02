# Báo cáo kiểm thử — INT-007: PDF lỗi được đánh dấu failed với mã tương ứng

| Mục | Giá trị |
|---|---|
| Test case | [INT-007](../../docs/07-verification/test_cases/INT-007.md) |
| Kết luận | **✅ Đạt** |
| Thời gian chạy | 2026-11-02 21:42:00 → 21:42:13 (UTC+7) |
| Người / agent thực hiện | Claude Code (agent), `frontend/e2e/run-cli.mjs` + `steps.sh` |
| Commit | `c02cc72 (có thay đổi chưa commit)` |
| Môi trường | localhost · web http://localhost:5173 · API http://localhost:8000 · Darwin 27.0.0 arm64 · Docker 29.6.2 · ANTHROPIC_API_KEY: không |
| Script | [steps.sh](steps.sh) |

## Kết quả từng bước

| # | Thao tác | Kết quả mong đợi | Kết quả thực tế | Đạt? | Bằng chứng |
|---|---|---|---|---|---|
| 1 | Chạy test tự động `tests/integration/test_documents.py::test_bad_pdfs_fail_with_code` (Testcontainers) | passed, exit code 0 | pytest: `4 passed, 6 warnings in 5.05s` | ✅ | [ảnh](screenshots/01-buoc-1-chay-test-tu-dong-tests-integration-test-documents-py.png) |
| 2 | Kiểm tra stack localhost và dọn dữ liệu | `Stack OK`; lệnh TRUNCATE thành công | Stack OK; TRUNCATE TABLE | ✅ | [ảnh](screenshots/02-buoc-2-kiem-tra-stack-localhost-va-don-du-lieu.png) |
| 3 | Sinh PDF 301 trang | Tệp hợp lệ 301 trang trong `data/` | `301_pages.pdf` | ✅ | [ảnh](screenshots/03-buoc-3-sinh-pdf-301-trang.png) |
| 4 | Tải lên 4 tệp lỗi | HTTP 202; 4 item `queued` (hoặc `corrupted.pdf` bị `not_pdf` nếu không có header `%PDF-` — ghi nhận) | HTTP 202; 4 item queued; item lỗi tại upload: [] | ✅ | [ảnh](screenshots/04-buoc-4-tai-len-4-tep-loi.png) |
| 5 | Chờ xử lý và xem mã lỗi | encrypted → `encrypted_pdf`; scanned → `no_text_layer`; corrupted → `corrupted`; 301_pages → `too_many_pages`; tất cả `failed` | status=failed: 301_pages.pdf → too_many_pages, corrupted.pdf → corrupted, encrypted.pdf → encrypted_pdf, scanned.pdf → no_text_layer | ✅ | [ảnh](screenshots/05-buoc-5-cho-xu-ly-va-xem-ma-loi-ket-thuc.png) |

## Bằng chứng

- Video: [video.webm](video.webm)
- Log: [logs/cleanup.log](logs/cleanup.log), [logs/run-meta.json](logs/run-meta.json), [logs/steps.log](logs/steps.log)
- Ảnh:

  ![01-buoc-1-chay-test-tu-dong-tests-integration-test-documents-py.png](screenshots/01-buoc-1-chay-test-tu-dong-tests-integration-test-documents-py.png)

  ![02-buoc-2-kiem-tra-stack-localhost-va-don-du-lieu.png](screenshots/02-buoc-2-kiem-tra-stack-localhost-va-don-du-lieu.png)

  ![03-buoc-3-sinh-pdf-301-trang.png](screenshots/03-buoc-3-sinh-pdf-301-trang.png)

  ![04-buoc-4-tai-len-4-tep-loi.png](screenshots/04-buoc-4-tai-len-4-tep-loi.png)

  ![05-buoc-5-cho-xu-ly-va-xem-ma-loi-ket-thuc.png](screenshots/05-buoc-5-cho-xu-ly-va-xem-ma-loi-ket-thuc.png)

## Lỗi phát hiện

Không có.

## Ghi chú và sai lệch so với test case

Không có.
