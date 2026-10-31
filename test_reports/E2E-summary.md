# Tổng hợp kết quả E2E — 31/10/2026

| Mục | Giá trị |
|---|---|
| Phạm vi | E2E-001 … E2E-009 ([test case](../docs/07-verification/test_cases/README.md)) |
| Môi trường | localhost · web http://localhost:5173 · API http://localhost:8000 · macOS arm64 · Docker 29.6.2 · Playwright 1.64.1 (Chromium, headless) |
| Commit | `2766492` (có thay đổi chưa commit: tài liệu test, `frontend/e2e/`, Playwright) |
| ANTHROPIC_API_KEY | Không có → E2E-005…009 giả lập `/api/v1/ask` như test case cho phép; F1 (tải lên, xử lý) chạy thật với TEI `bge-m3` |
| Kết quả | **9 / 9 Đạt** |

| Test case | Tên | Kết luận | Báo cáo | Video |
|---|---|---|---|---|
| E2E-001 | Tải lên PDF và theo dõi trạng thái tới Sẵn sàng | ✅ Đạt | [report](E2E-001/report.md) | [video](E2E-001/video.webm) |
| E2E-002 | Tệp lỗi sau xử lý hiển thị đúng lý do | ✅ Đạt | [report](E2E-002/report.md) | [video](E2E-002/video.webm) |
| E2E-003 | Kiểm tra tệp phía client (> 10 tệp, > 20 MB) | ✅ Đạt | [report](E2E-003/report.md) | [video](E2E-003/video.webm) |
| E2E-004 | Chưa có tài liệu Sẵn sàng: khóa ô hỏi | ✅ Đạt | [report](E2E-004/report.md) | [video](E2E-004/video.webm) |
| E2E-005 | Hỏi và nhận câu trả lời (API giả lập) | ✅ Đạt | [report](E2E-005/report.md) | [video](E2E-005/video.webm) |
| E2E-006 | Kiểm tra ô nhập câu hỏi | ✅ Đạt | [report](E2E-006/report.md) | [video](E2E-006/video.webm) |
| E2E-007 | Lỗi AI và nút Hỏi lại | ✅ Đạt | [report](E2E-007/report.md) | [video](E2E-007/video.webm) |
| E2E-008 | XSS trong câu trả lời không được thực thi | ✅ Đạt | [report](E2E-008/report.md) | [video](E2E-008/video.webm) |
| E2E-009 | Lịch sử hỏi đáp chỉ giữ trong trang | ✅ Đạt | [report](E2E-009/report.md) | [video](E2E-009/video.webm) |

## Phát hiện (không chặn)

| # | Mô tả | Mức độ | Nguồn |
|---|---|---|---|
| 1 | Khi câu hỏi > 2000 ký tự, thông báo "Câu hỏi dài quá N ký tự." chỉ nằm trong tooltip (`title`) của bộ đếm, không hiển thị trên màn hình. Nút Gửi vẫn bị khóa đúng | Minor (UX) | E2E-006 bước 2 |
| 2 | Trong lúc `GET /documents` chưa trả về, trang Hỏi đáp hiện lời chào và ô nhập **dùng được**, sidebar hiện 0 (`locked` chỉ đúng khi đã có dữ liệu). Nếu gửi trong khoảng ngắn này, API vẫn chặn bằng 409 `no_documents` | Minor | Quan sát khi chạy E2E-005 lần đầu |
| 3 | Phản hồi 504 HTML (Nginx timeout) được xử lý tốt: hiện "Hệ thống đang bận…" và nút Hỏi lại — giảm bớt hệ quả UI của RISK-008 (thời gian chờ vẫn cần đo ở PERF-004) | Ghi nhận | E2E-007 bước 4 |

## Chưa kiểm chứng

- Câu trả lời từ **Claude thật** (không có `ANTHROPIC_API_KEY`): cần chạy lại E2E-005 với khóa, cùng INT-022 và EVAL-001…005.

## Chạy lại

```bash
make dev                                   # stack local
node test_reports/E2E-001/E2E-001.mjs      # từng test; HEADED=1 để xem trình duyệt, SLOWMO=300 để chạy chậm
```
