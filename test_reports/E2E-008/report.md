# Báo cáo kiểm thử — E2E-008: XSS trong câu trả lời không được thực thi

| Mục | Giá trị |
|---|---|
| Test case | [E2E-008](../../docs/07-verification/test_cases/E2E-008.md) |
| Kết luận | **✅ Đạt** |
| Thời gian chạy | 2026-10-31 22:19:39 → 22:19:53 (UTC+7) |
| Người / agent thực hiện | Claude Code (agent), script Playwright tự động |
| Commit | `2766492 (có thay đổi chưa commit)` |
| Môi trường | localhost · web http://localhost:5173 · API http://localhost:8000 · Darwin 27.0.0 arm64 · Docker 29.6.2 · ANTHROPIC_API_KEY: không |
| Script | [E2E-008.mjs](E2E-008.mjs) |

## Kết quả từng bước

| # | Thao tác | Kết quả mong đợi | Kết quả thực tế | Đạt? | Bằng chứng |
|---|---|---|---|---|---|
| 1 | Mở /ask và gửi một câu hỏi bất kỳ | Câu trả lời giả lập hiển thị; "In đậm" được in đậm | Câu trả lời hiển thị; <strong>: In đậm | ✅ | [ảnh](screenshots/01-buoc-1-mo-ask-va-gui-mot-cau-hoi-bat-ky.png) |
| 2 | Kiểm tra hộp thoại | Không có dialog nào | Số dialog: 0 | ✅ | [ảnh](screenshots/02-buoc-2-kiem-tra-hop-thoai.png) |
| 3 | Kiểm tra DOM vùng câu trả lời | Không có <script>; không có thuộc tính on*; không có href javascript: | script: 0; img: 1; thuộc tính on*: không có; href javascript:: 0; số thẻ <a>: 1. outerHTML lưu ở logs/answer-dom.html | ✅ | [ảnh](screenshots/03-buoc-3-kiem-tra-dom-vung-cau-tra-loi.png) |
| 4 | Bấm vào liên kết "bấm vào" (nếu còn) | Không có alert, không điều hướng sang javascript: | Sau khi bấm: dialog 0; URL http://localhost:5173/ask | ✅ | [ảnh](screenshots/04-buoc-4-bam-vao-lien-ket-bam-vao-neu-con.png) |

## Bằng chứng

- Video: [video.webm](video.webm)
- Log: [logs/checks.json](logs/checks.json), [logs/browser-console.log](logs/browser-console.log), [logs/setup.log](logs/setup.log)
- Ảnh:

  ![01-buoc-1-mo-ask-va-gui-mot-cau-hoi-bat-ky.png](screenshots/01-buoc-1-mo-ask-va-gui-mot-cau-hoi-bat-ky.png)

  ![02-buoc-2-kiem-tra-hop-thoai.png](screenshots/02-buoc-2-kiem-tra-hop-thoai.png)

  ![03-buoc-3-kiem-tra-dom-vung-cau-tra-loi.png](screenshots/03-buoc-3-kiem-tra-dom-vung-cau-tra-loi.png)

  ![04-buoc-4-bam-vao-lien-ket-bam-vao-neu-con.png](screenshots/04-buoc-4-bam-vao-lien-ket-bam-vao-neu-con.png)

## Lỗi phát hiện

Không có.

## Ghi chú và sai lệch so với test case

- `/api/v1/ask` được giả lập trả `answer` = `**In đậm**\n\n<img src=x onerror="alert('xss-img')">\n<script>alert('xss-script')</script>\n\n[bấm vào](javascript:alert('xss-link'))`.
