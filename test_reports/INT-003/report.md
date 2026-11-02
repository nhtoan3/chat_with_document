# Báo cáo kiểm thử — INT-003: Tải 0 tệp: trả lỗi too_many_files

| Mục | Giá trị |
|---|---|
| Test case | [INT-003](../../docs/07-verification/test_cases/INT-003.md) |
| Kết luận | **✅ Đạt** |
| Thời gian chạy | 2026-11-02 21:41:19 → 21:41:22 (UTC+7) |
| Người / agent thực hiện | Claude Code (agent), `frontend/e2e/run-cli.mjs` + `steps.sh` |
| Commit | `c02cc72 (có thay đổi chưa commit)` |
| Môi trường | localhost · web http://localhost:5173 · API http://localhost:8000 · Darwin 27.0.0 arm64 · Docker 29.6.2 · ANTHROPIC_API_KEY: không |
| Script | [steps.sh](steps.sh) |

## Kết quả từng bước

| # | Thao tác | Kết quả mong đợi | Kết quả thực tế | Đạt? | Bằng chứng |
|---|---|---|---|---|---|
| 1 | Kiểm tra stack localhost và dọn dữ liệu | `Stack OK`; lệnh TRUNCATE thành công | Stack OK; TRUNCATE TABLE | ✅ | [ảnh](screenshots/01-buoc-1-kiem-tra-stack-localhost-va-don-du-lieu.png) |
| 2 | POST multipart không có trường `files` | HTTP 422, `code: "too_many_files"` | `HTTP 422`; `"code":"too_many_files"` | ✅ | [ảnh](screenshots/02-buoc-2-post-multipart-khong-co-truong-files.png) |
| 3 | POST không có body | HTTP 422, `code: "too_many_files"` | `HTTP 422`; `"code":"too_many_files"` | ✅ | [ảnh](screenshots/03-buoc-3-post-khong-co-body-ket-thuc.png) |

## Bằng chứng

- Video: [video.webm](video.webm)
- Log: [logs/run-meta.json](logs/run-meta.json), [logs/steps.log](logs/steps.log)
- Ảnh:

  ![01-buoc-1-kiem-tra-stack-localhost-va-don-du-lieu.png](screenshots/01-buoc-1-kiem-tra-stack-localhost-va-don-du-lieu.png)

  ![02-buoc-2-post-multipart-khong-co-truong-files.png](screenshots/02-buoc-2-post-multipart-khong-co-truong-files.png)

  ![03-buoc-3-post-khong-co-body-ket-thuc.png](screenshots/03-buoc-3-post-khong-co-body-ket-thuc.png)

## Lỗi phát hiện

Không có.

## Ghi chú và sai lệch so với test case

Không có.
