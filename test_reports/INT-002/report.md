# Báo cáo kiểm thử — INT-002: Tải 11 tệp: từ chối cả lô

| Mục | Giá trị |
|---|---|
| Test case | [INT-002](../../docs/07-verification/test_cases/INT-002.md) |
| Kết luận | **✅ Đạt** |
| Thời gian chạy | 2026-11-02 21:41:08 → 21:41:19 (UTC+7) |
| Người / agent thực hiện | Claude Code (agent), `frontend/e2e/run-cli.mjs` + `steps.sh` |
| Commit | `c02cc72 (có thay đổi chưa commit)` |
| Môi trường | localhost · web http://localhost:5173 · API http://localhost:8000 · Darwin 27.0.0 arm64 · Docker 29.6.2 · ANTHROPIC_API_KEY: không |
| Script | [steps.sh](steps.sh) |

## Kết quả từng bước

| # | Thao tác | Kết quả mong đợi | Kết quả thực tế | Đạt? | Bằng chứng |
|---|---|---|---|---|---|
| 1 | Chạy test tự động `tests/integration/test_documents.py::test_too_many_files_rejects_whole_batch` (Testcontainers) | passed, exit code 0 | pytest: `1 passed, 6 warnings in 6.02s` | ✅ | [ảnh](screenshots/01-buoc-1-chay-test-tu-dong-tests-integration-test-documents-py.png) |
| 2 | Kiểm tra stack localhost và dọn dữ liệu | `Stack OK`; lệnh TRUNCATE thành công | Stack OK; TRUNCATE TABLE | ✅ | [ảnh](screenshots/02-buoc-2-kiem-tra-stack-localhost-va-don-du-lieu.png) |
| 3 | Tạo 11 PDF hợp lệ có tên khác nhau | 11 tệp trong `data/` | 11 tệp tep_01…tep_11 trong data/ | ✅ | [ảnh](screenshots/03-buoc-3-tao-11-pdf-hop-le-co-ten-khac-nhau.png) |
| 4 | Tải lên 11 tệp trong một request | HTTP 422, `application/problem+json`, `code: "too_many_files"` | `HTTP 422`; `"code":"too_many_files"` | ✅ | [ảnh](screenshots/04-buoc-4-tai-len-11-tep-trong-mot-request.png) |
| 5 | Kiểm tra không có tài liệu nào được lưu | `total: 0` | `"total":0` | ✅ | [ảnh](screenshots/05-buoc-5-kiem-tra-khong-co-tai-lieu-nao-duoc-luu-ket-thuc.png) |

## Bằng chứng

- Video: [video.webm](video.webm)
- Log: [logs/cleanup.log](logs/cleanup.log), [logs/run-meta.json](logs/run-meta.json), [logs/steps.log](logs/steps.log)
- Ảnh:

  ![01-buoc-1-chay-test-tu-dong-tests-integration-test-documents-py.png](screenshots/01-buoc-1-chay-test-tu-dong-tests-integration-test-documents-py.png)

  ![02-buoc-2-kiem-tra-stack-localhost-va-don-du-lieu.png](screenshots/02-buoc-2-kiem-tra-stack-localhost-va-don-du-lieu.png)

  ![03-buoc-3-tao-11-pdf-hop-le-co-ten-khac-nhau.png](screenshots/03-buoc-3-tao-11-pdf-hop-le-co-ten-khac-nhau.png)

  ![04-buoc-4-tai-len-11-tep-trong-mot-request.png](screenshots/04-buoc-4-tai-len-11-tep-trong-mot-request.png)

  ![05-buoc-5-kiem-tra-khong-co-tai-lieu-nao-duoc-luu-ket-thuc.png](screenshots/05-buoc-5-kiem-tra-khong-co-tai-lieu-nao-duoc-luu-ket-thuc.png)

## Lỗi phát hiện

Không có.

## Ghi chú và sai lệch so với test case

Không có.
