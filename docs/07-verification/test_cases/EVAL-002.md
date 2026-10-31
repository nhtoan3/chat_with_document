# EVAL-002 — Tỷ lệ "không tìm thấy" câu negative ≥ 90%

> Nguồn: [Test_Plan.md](../Test_Plan.md) §6.3.4 · Danh sách test case: [README.md](README.md)

| Thuộc tính | Giá trị |
|---|---|
| Mã test case | `EVAL-002` |
| Mức / loại | Đánh giá chất lượng AI |
| Ưu tiên | P0 |
| Yêu cầu truy vết | KR2.3, AC-US-014-1 |
| Task | T-008, T-023 |
| Test tự động có sẵn | — |
| Cách ghi bằng chứng | CLI — `steps.sh` + `frontend/e2e/run-cli.mjs` (video + ảnh từ terminal) |
| URL kiểm thử | Web `http://localhost:5173` · API `http://localhost:8000` |
| Thư mục artifact | `./test_reports/EVAL-002/` |

## Mục tiêu

Đo tỷ lệ câu negative nhận câu trả lời "không tìm thấy".

## Nhiệm vụ của agent

1. Thực hiện test **chỉ trên localhost**: web `http://localhost:5173`, API `http://localhost:8000` (các dịch vụ phụ cũng ở localhost). Không gọi môi trường AWS.
2. Lưu **mọi** artifact của test case này trong thư mục riêng `./test_reports/EVAL-002/` (tính từ gốc repo). Chạy lại thì xóa thư mục cũ trước: `rm -rf test_reports/EVAL-002`.
3. **Quay video** toàn bộ quá trình thực hiện test → `./test_reports/EVAL-002/video.webm` (nhiều phiên thì `video-02.webm`, …).
4. **Chụp ảnh màn hình** làm bằng chứng tại mỗi bước có 📸 → `./test_reports/EVAL-002/screenshots/NN-<mô-tả>.png`.
5. Lưu output lệnh, log và dữ liệu sinh ra vào `./test_reports/EVAL-002/logs/` và `./test_reports/EVAL-002/data/`.
6. **Tạo báo cáo** `./test_reports/EVAL-002/report.md` theo [mẫu ở README §5](README.md#5-mẫu-báo-cáo-reportmd): kết quả từng bước, ảnh nhúng, liên kết video, kết luận ✅ Đạt / ❌ Không đạt / ⛔ Bị chặn.
7. Phần CLI: lưu script vào `./test_reports/EVAL-002/steps.sh` (mẫu bên dưới) rồi chạy `node frontend/e2e/run-cli.mjs EVAL-002 test_reports/EVAL-002/steps.sh` từ gốc repo — công cụ tự quay video, chụp ảnh khi kết thúc mỗi bước `### ` và lưu log.
8. Không sửa mã ứng dụng để test đạt. Bước nào lỗi thì ghi lại và tiếp tục các bước độc lập còn lại; luôn thực hiện phần dọn dẹp.

## Điều kiện tiên quyết

- Đã tạo virtualenv backend (`make venv`).
- Stack local đang chạy (`make dev`), `check_stack` trong `frontend/e2e/lib.sh` báo OK (API `http://localhost:8000/healthz` và web `http://localhost:5173` phản hồi).
- Có `ANTHROPIC_API_KEY` trong `.env` ở gốc repo và đã khởi động lại api (`docker compose up -d api`). Không có khóa → kết luận **⛔ Bị chặn**.
- Golden set tại `backend/tests/eval/golden.yaml`. Nếu BD đã bàn giao bộ PDF thật, nạp bộ PDF đó thay cho 3 PDF mẫu; nếu chưa, dùng 3 PDF mẫu + bộ câu mẫu và ghi rõ "chưa đại diện" trong báo cáo.

## Dữ liệu kiểm thử

- Không cần dữ liệu riêng.

## Các bước thực hiện

| # | Thao tác | Kết quả mong đợi | 📸 |
|---|---|---|---|
| 1 | Kiểm tra stack localhost và dọn dữ liệu | `Stack OK`; lệnh TRUNCATE thành công | 📸 |
| 2 | Nạp tài liệu và chờ Sẵn sàng | Mọi tài liệu `ready` | 📸 |
| 3 | Chạy golden set với API localhost | File `backend/tests/eval/results/<ts>.csv` mới; mỗi câu có `answer` và `latency_ms` | 📸 |
| 4 | Xem kết quả | Bảng id / type / latency / câu trả lời | 📸 |
| 5 | Tính điểm | Dòng `negative: NN% … target 90% → PASS` | 📸 |

## Script gợi ý (`steps.sh`)

```bash
#!/usr/bin/env bash
# EVAL-002 — Tỷ lệ "không tìm thấy" câu negative ≥ 90%
# Chạy từ gốc repo: node frontend/e2e/run-cli.mjs EVAL-002 test_reports/EVAL-002/steps.sh
set -uo pipefail
source frontend/e2e/lib.sh

echo "### Bước 1: Kiểm tra stack localhost và dọn dữ liệu"
check_stack || exit 1
reset_data

echo "### Bước 2: Nạp tài liệu và chờ Sẵn sàng"
seed_samples; wait_idle 300

echo "### Bước 3: Chạy golden set với API localhost"
make eval BASE_URL=http://localhost:8000; f=$(ls -t backend/tests/eval/results/*.csv | head -1); cp "$f" "$TEST_DIR/logs/"; echo "Kết quả: $f"

echo "### Bước 4: Xem kết quả"
f=$(ls -t "$TEST_DIR"/logs/*.csv | head -1); python3 -c "import csv,sys;[print(r['id'], r['type'], r.get('latency_ms'), '|', (r.get('answer') or '')[:160].replace(chr(10),' ')) for r in csv.DictReader(open(sys.argv[1],encoding='utf-8'))]" "$f"

echo "### Bước 5: Tính điểm"
(cd backend && .venv/bin/python tests/eval/score.py "$(ls -t "$TEST_DIR"/logs/*.csv | head -1)")
```

## Tiêu chí đạt

`negative` ≥ 90%.

Kết luận **⛔ Bị chặn** khi thiếu điều kiện tiên quyết (stack không chạy, thiếu khóa API, thiếu dữ liệu), không phải do lỗi của ứng dụng.

## Dọn dẹp sau test

- `reset_data`

## Ghi chú

- Kết quả trên localhost là tham khảo; kết quả chính thức đo trên AWS (T-023).
