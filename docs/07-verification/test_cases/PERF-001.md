# PERF-001 — PDF văn bản 50 trang Sẵn sàng ≤ 60 giây

> Nguồn: [Test_Plan.md](../Test_Plan.md) §6.3.7 · Danh sách test case: [README.md](README.md)

| Thuộc tính | Giá trị |
|---|---|
| Mã test case | `PERF-001` |
| Mức / loại | Hiệu năng |
| Ưu tiên | P1 |
| Yêu cầu truy vết | NFR-003 |
| Task | T-013 |
| Test tự động có sẵn | — |
| Cách ghi bằng chứng | CLI — `steps.sh` + `frontend/e2e/run-cli.mjs` (video + ảnh từ terminal) |
| URL kiểm thử | Web `http://localhost:5173` · API `http://localhost:8000` |
| Thư mục artifact | `./test_reports/PERF-001/` |

## Mục tiêu

Đo thời gian từ khi tải lên tới khi tài liệu 50 trang ở trạng thái `ready`.

## Nhiệm vụ của agent

1. Thực hiện test **chỉ trên localhost**: web `http://localhost:5173`, API `http://localhost:8000` (các dịch vụ phụ cũng ở localhost). Không gọi môi trường AWS.
2. Lưu **mọi** artifact của test case này trong thư mục riêng `./test_reports/PERF-001/` (tính từ gốc repo). Chạy lại thì xóa thư mục cũ trước: `rm -rf test_reports/PERF-001`.
3. **Quay video** toàn bộ quá trình thực hiện test → `./test_reports/PERF-001/video.webm` (nhiều phiên thì `video-02.webm`, …).
4. **Chụp ảnh màn hình** làm bằng chứng tại mỗi bước có 📸 → `./test_reports/PERF-001/screenshots/NN-<mô-tả>.png`.
5. Lưu output lệnh, log và dữ liệu sinh ra vào `./test_reports/PERF-001/logs/` và `./test_reports/PERF-001/data/`.
6. **Tạo báo cáo** `./test_reports/PERF-001/report.md` theo [mẫu ở README §5](README.md#5-mẫu-báo-cáo-reportmd): kết quả từng bước, ảnh nhúng, liên kết video, kết luận ✅ Đạt / ❌ Không đạt / ⛔ Bị chặn.
7. Phần CLI: lưu script vào `./test_reports/PERF-001/steps.sh` (mẫu bên dưới) rồi chạy `node frontend/e2e/run-cli.mjs PERF-001 test_reports/PERF-001/steps.sh` từ gốc repo — công cụ tự quay video, chụp ảnh khi kết thúc mỗi bước `### ` và lưu log.
8. Không sửa mã ứng dụng để test đạt. Bước nào lỗi thì ghi lại và tiếp tục các bước độc lập còn lại; luôn thực hiện phần dọn dẹp.

## Điều kiện tiên quyết

- Đã tạo virtualenv backend (`make venv`).
- Stack local đang chạy (`make dev`), `check_stack` trong `frontend/e2e/lib.sh` báo OK (API `http://localhost:8000/healthz` và web `http://localhost:5173` phản hồi).
- Hàng đợi rỗng (script tự `reset_data`).

## Dữ liệu kiểm thử

- PDF 50 trang tiếng Việt sinh bằng `make_pdf pages50`.

## Các bước thực hiện

| # | Thao tác | Kết quả mong đợi | 📸 |
|---|---|---|---|
| 1 | Kiểm tra stack localhost và dọn dữ liệu | `Stack OK`; lệnh TRUNCATE thành công | 📸 |
| 2 | Sinh PDF 50 trang | Tệp hợp lệ 50 trang | 📸 |
| 3 | Tải lên và chờ | HTTP 202; `ready: 1` sau khi chờ | 📸 |
| 4 | Đọc số đo trong CSDL | `seconds_to_ready` ≤ 60; `processing_ms` của job; `pages = 50` | 📸 |

## Script gợi ý (`steps.sh`)

```bash
#!/usr/bin/env bash
# PERF-001 — PDF văn bản 50 trang Sẵn sàng ≤ 60 giây
# Chạy từ gốc repo: node frontend/e2e/run-cli.mjs PERF-001 test_reports/PERF-001/steps.sh
set -uo pipefail
source frontend/e2e/lib.sh

echo "### Bước 1: Kiểm tra stack localhost và dọn dữ liệu"
check_stack || exit 1
reset_data

echo "### Bước 2: Sinh PDF 50 trang"
make_pdf pages50 "$DATA_DIR/hop_dong_50_trang.pdf"

echo "### Bước 3: Tải lên và chờ"
date +%T; upload "$DATA_DIR/hop_dong_50_trang.pdf"; wait_idle 600; date +%T

echo "### Bước 4: Đọc số đo trong CSDL"
psql_q "SELECT d.filename, d.pages, d.status, round(extract(epoch FROM d.ready_at - d.uploaded_at)::numeric, 1) AS seconds_to_ready, j.processing_ms FROM documents d JOIN ingestion_jobs j ON j.document_id = d.id;"
```

## Tiêu chí đạt

`seconds_to_ready` ≤ 60.

Kết luận **⛔ Bị chặn** khi thiếu điều kiện tiên quyết (stack không chạy, thiếu khóa API, thiếu dữ liệu), không phải do lỗi của ứng dụng.

## Dọn dẹp sau test

- `reset_data`

## Ghi chú

- Số đo trên localhost (đặc biệt Mac Apple Silicon với TEI giả lập) chỉ là tham khảo; kết luận NFR-003 chính thức đo trên AWS.
