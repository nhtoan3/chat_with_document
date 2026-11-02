# Báo cáo kiểm thử — EVAL-003: Không bịa ở câu negative

| Mục | Giá trị |
|---|---|
| Test case | [EVAL-003](../../docs/07-verification/test_cases/EVAL-003.md) |
| Kết luận | **⛔ Bị chặn** |
| Thời gian chạy | 2026-11-02 22:08:56 → 22:09:07 (UTC+7) |
| Người / agent thực hiện | Claude Code (agent), `frontend/e2e/run-cli.mjs` + `steps.sh` |
| Commit | `c02cc72 (có thay đổi chưa commit)` |
| Môi trường | localhost · web http://localhost:5173 · API http://localhost:8000 · Darwin 27.0.0 arm64 · Docker 29.6.2 · ANTHROPIC_API_KEY: không |
| Script | [steps.sh](steps.sh) |

> ⛔ Cần Claude thật nhưng không có `ANTHROPIC_API_KEY`; không dùng khóa nào và không giả lập vì test case không cho phép. Chỉ chạy tới bước chứng minh điều kiện tiên quyết.

## Kết quả từng bước

| # | Thao tác | Kết quả mong đợi | Kết quả thực tế | Đạt? | Bằng chứng |
|---|---|---|---|---|---|
| 1 | Kiểm tra stack localhost và dọn dữ liệu | `Stack OK`; lệnh TRUNCATE thành công | Stack OK; TRUNCATE TABLE | ✅ | [ảnh](screenshots/01-buoc-1-kiem-tra-stack-localhost-va-don-du-lieu.png) |
| 2 | Nạp tài liệu và chờ Sẵn sàng | Mọi tài liệu `ready` | ready: 3 | ✅ | [ảnh](screenshots/02-buoc-2-nap-tai-lieu-va-cho-san-sang.png) |
| 3 | Chạy golden set với API localhost | File `backend/tests/eval/results/<ts>.csv` mới; mỗi câu có `answer` và `latency_ms` | Chứng minh thiếu khóa: `len(ANTHROPIC_API_KEY)=0`, không có `.env`; hỏi thử 1 câu → HTTP 503 `ai_unavailable`. Golden set / câu live KHÔNG chạy | ⛔ | [ảnh](screenshots/03-buoc-3-xac-nhan-dieu-kien-tien-quyet-co-khoa-api-trong-conta.png) |
| 4 | Xem kết quả | Bảng id / type / latency / câu trả lời | Không chạy — bị chặn vì thiếu khóa API | — | — |
| 5 | In đầy đủ câu trả lời negative | Mỗi câu chỉ nói không tìm thấy thông tin trong tài liệu, không kèm kiến thức chung (ví dụ không nói "Paris") | Không chạy — bị chặn vì thiếu khóa API | — | — |

## Bằng chứng

- Video: [video.webm](video.webm)
- Log: [logs/cleanup.log](logs/cleanup.log), [logs/run-meta.json](logs/run-meta.json), [logs/steps.log](logs/steps.log)
- Ảnh:

  ![01-buoc-1-kiem-tra-stack-localhost-va-don-du-lieu.png](screenshots/01-buoc-1-kiem-tra-stack-localhost-va-don-du-lieu.png)

  ![02-buoc-2-nap-tai-lieu-va-cho-san-sang.png](screenshots/02-buoc-2-nap-tai-lieu-va-cho-san-sang.png)

  ![03-buoc-3-xac-nhan-dieu-kien-tien-quyet-co-khoa-api-trong-conta.png](screenshots/03-buoc-3-xac-nhan-dieu-kien-tien-quyet-co-khoa-api-trong-conta.png)

## Lỗi phát hiện

Không có.

## Ghi chú và sai lệch so với test case

- Chỉ chạy bước 1–2 và một câu hỏi để chứng minh thiếu khóa (script khác script gợi ý: không chạy `make eval`, không chấm điểm). Không có số đo chất lượng hay độ trễ nào được ghi nhận.
