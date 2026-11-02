# Báo cáo kiểm thử — INT-001: Tải lên 3 PDF hợp lệ rồi xử lý tới Sẵn sàng

| Mục | Giá trị |
|---|---|
| Test case | [INT-001](../../docs/07-verification/test_cases/INT-001.md) |
| Kết luận | **✅ Đạt** |
| Thời gian chạy | 2026-11-02 21:40:46 → 21:41:08 (UTC+7) |
| Người / agent thực hiện | Claude Code (agent), `frontend/e2e/run-cli.mjs` + `steps.sh` |
| Commit | `c02cc72 (có thay đổi chưa commit)` |
| Môi trường | localhost · web http://localhost:5173 · API http://localhost:8000 · Darwin 27.0.0 arm64 · Docker 29.6.2 · ANTHROPIC_API_KEY: không |
| Script | [steps.sh](steps.sh) |

## Kết quả từng bước

| # | Thao tác | Kết quả mong đợi | Kết quả thực tế | Đạt? | Bằng chứng |
|---|---|---|---|---|---|
| 1 | Chạy test tự động `tests/integration/test_documents.py::test_upload_three_valid_pdfs_then_ingest` (Testcontainers) | passed, exit code 0 | pytest: `1 passed, 6 warnings in 5.63s` | ✅ | [ảnh](screenshots/01-buoc-1-chay-test-tu-dong-tests-integration-test-documents-py.png) |
| 2 | Kiểm tra stack localhost và dọn dữ liệu | `Stack OK`; lệnh TRUNCATE thành công | Stack OK; TRUNCATE TABLE | ✅ | [ảnh](screenshots/02-buoc-2-kiem-tra-stack-localhost-va-don-du-lieu.png) |
| 3 | Tải lên 3 PDF mẫu | HTTP 202; 3 item có `document_id` và `status: "queued"` | HTTP 202; 3 item `queued` | ✅ | [ảnh](screenshots/03-buoc-3-tai-len-3-pdf-mau.png) |
| 4 | Chờ worker xử lý xong | `counts` = `{ready:3, processing:0, failed:0, total:3}` | `{"ready":3,"processing":0,"failed":0,"total":3}` | ✅ | [ảnh](screenshots/04-buoc-4-cho-worker-xu-ly-xong.png) |
| 5 | Kiểm tra trạng thái, số trang và số chunk trong CSDL | 3 dòng `ready`, `pages` ≥ 1, `chunks` > 0 | Các dòng: Bien_ban_hop_doi_tac_15-09.pdf: ready, 1 trang, 1 chunk; De_xuat_hop_tac_Minh_Phat.pdf: ready, 1 trang, 1 chunk; Hop_dong_khung_ABC_2026.pdf: ready, 2 trang, 2 chunk | ✅ | [ảnh](screenshots/05-buoc-5-kiem-tra-trang-thai-so-trang-va-so-chunk-trong-csdl-k.png) |

## Bằng chứng

- Video: [video.webm](video.webm)
- Log: [logs/cleanup.log](logs/cleanup.log), [logs/run-meta.json](logs/run-meta.json), [logs/steps.log](logs/steps.log)
- Ảnh:

  ![01-buoc-1-chay-test-tu-dong-tests-integration-test-documents-py.png](screenshots/01-buoc-1-chay-test-tu-dong-tests-integration-test-documents-py.png)

  ![02-buoc-2-kiem-tra-stack-localhost-va-don-du-lieu.png](screenshots/02-buoc-2-kiem-tra-stack-localhost-va-don-du-lieu.png)

  ![03-buoc-3-tai-len-3-pdf-mau.png](screenshots/03-buoc-3-tai-len-3-pdf-mau.png)

  ![04-buoc-4-cho-worker-xu-ly-xong.png](screenshots/04-buoc-4-cho-worker-xu-ly-xong.png)

  ![05-buoc-5-kiem-tra-trang-thai-so-trang-va-so-chunk-trong-csdl-k.png](screenshots/05-buoc-5-kiem-tra-trang-thai-so-trang-va-so-chunk-trong-csdl-k.png)

## Lỗi phát hiện

Không có.

## Ghi chú và sai lệch so với test case

Không có.
