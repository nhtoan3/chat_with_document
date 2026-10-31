# Báo cáo kiểm thử — E2E-003: Kiểm tra tệp phía client (> 10 tệp, > 20 MB)

| Mục | Giá trị |
|---|---|
| Test case | [E2E-003](../../docs/07-verification/test_cases/E2E-003.md) |
| Kết luận | **✅ Đạt** |
| Thời gian chạy | 2026-10-31 22:18:50 → 22:18:54 (UTC+7) |
| Người / agent thực hiện | Claude Code (agent), script Playwright tự động |
| Commit | `2766492 (có thay đổi chưa commit)` |
| Môi trường | localhost · web http://localhost:5173 · API http://localhost:8000 · Darwin 27.0.0 arm64 · Docker 29.6.2 · ANTHROPIC_API_KEY: không |
| Script | [E2E-003.mjs](E2E-003.mjs) |

## Kết quả từng bước

| # | Thao tác | Kết quả mong đợi | Kết quả thực tế | Đạt? | Bằng chứng |
|---|---|---|---|---|---|
| 1 | Mở /documents, theo dõi request POST /api/v1/documents | Trang trống | Trang trống "Chưa có tài liệu nào" | ✅ | [ảnh](screenshots/01-buoc-1-mo-documents-theo-doi-request-post-api-v1-documents.png) |
| 2 | Chọn 11 tệp | Banner "Mỗi lần chỉ tải tối đa 10 tệp. Bạn đã chọn 11 tệp — vui lòng chọn lại."; không có request POST | 11 tệp được chọn; banner: "Mỗi lần chỉ tải tối đa 10 tệp. Bạn đã chọn 11 tệp — vui lòng chọn lại."; số request POST: 0 | ✅ | [ảnh](screenshots/02-buoc-2-chon-11-tep.png) |
| 3 | Chọn qua_lon.pdf (21 MB) và 1 PDF mẫu | qua_lon.pdf – "Vượt quá 20 MB"; đúng 1 request POST chỉ chứa tệp hợp lệ; "Đã tải lên 1 tệp, đang chờ xử lý." | qua_lon.pdf: "Vượt quá 20 MB"; số request POST: 1; kích thước body: 0.00 MB (chỉ tệp hợp lệ); toast "Đã tải lên 1 tệp, đang chờ xử lý." hiện | ✅ | [ảnh](screenshots/03-buoc-3-chon-qua-lon-pdf-21-mb-va-1-pdf-mau.png) |

## Bằng chứng

- Video: [video.webm](video.webm)
- Log: [logs/checks.json](logs/checks.json), [logs/browser-console.log](logs/browser-console.log), [logs/setup.log](logs/setup.log)
- Ảnh:

  ![01-buoc-1-mo-documents-theo-doi-request-post-api-v1-documents.png](screenshots/01-buoc-1-mo-documents-theo-doi-request-post-api-v1-documents.png)

  ![02-buoc-2-chon-11-tep.png](screenshots/02-buoc-2-chon-11-tep.png)

  ![03-buoc-3-chon-qua-lon-pdf-21-mb-va-1-pdf-mau.png](screenshots/03-buoc-3-chon-qua-lon-pdf-21-mb-va-1-pdf-mau.png)

## Lỗi phát hiện

Không có.

## Ghi chú và sai lệch so với test case

Không có.
