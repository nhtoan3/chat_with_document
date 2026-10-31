# PERF-003 — Tải lô 10 × 20 MB: RAM api tăng ≤ 100 MB

> Nguồn: [Test_Plan.md](../Test_Plan.md) §6.3.7 · Danh sách test case: [README.md](README.md)

| Thuộc tính | Giá trị |
|---|---|
| Mã test case | `PERF-003` |
| Mức / loại | Hiệu năng |
| Ưu tiên | P1 |
| Yêu cầu truy vết | US-005, F1.1 |
| Task | T-009 |
| Test tự động có sẵn | — |
| Cách ghi bằng chứng | CLI — `steps.sh` + `frontend/e2e/run-cli.mjs` (video + ảnh từ terminal) |
| URL kiểm thử | Web `http://localhost:5173` · API `http://localhost:8000` |
| Thư mục artifact | `./test_reports/PERF-003/` |

## Mục tiêu

Upload đọc stream: tải 10 tệp 20 MB trong 1 request không làm RAM container `api` tăng quá 100 MB.

## Nhiệm vụ của agent

1. Thực hiện test **chỉ trên localhost**: web `http://localhost:5173`, API `http://localhost:8000` (các dịch vụ phụ cũng ở localhost). Không gọi môi trường AWS.
2. Lưu **mọi** artifact của test case này trong thư mục riêng `./test_reports/PERF-003/` (tính từ gốc repo). Chạy lại thì xóa thư mục cũ trước: `rm -rf test_reports/PERF-003`.
3. **Quay video** toàn bộ quá trình thực hiện test → `./test_reports/PERF-003/video.webm` (nhiều phiên thì `video-02.webm`, …).
4. **Chụp ảnh màn hình** làm bằng chứng tại mỗi bước có 📸 → `./test_reports/PERF-003/screenshots/NN-<mô-tả>.png`.
5. Lưu output lệnh, log và dữ liệu sinh ra vào `./test_reports/PERF-003/logs/` và `./test_reports/PERF-003/data/`.
6. **Tạo báo cáo** `./test_reports/PERF-003/report.md` theo [mẫu ở README §5](README.md#5-mẫu-báo-cáo-reportmd): kết quả từng bước, ảnh nhúng, liên kết video, kết luận ✅ Đạt / ❌ Không đạt / ⛔ Bị chặn.
7. Phần CLI: lưu script vào `./test_reports/PERF-003/steps.sh` (mẫu bên dưới) rồi chạy `node frontend/e2e/run-cli.mjs PERF-003 test_reports/PERF-003/steps.sh` từ gốc repo — công cụ tự quay video, chụp ảnh khi kết thúc mỗi bước `### ` và lưu log.
8. Không sửa mã ứng dụng để test đạt. Bước nào lỗi thì ghi lại và tiếp tục các bước độc lập còn lại; luôn thực hiện phần dọn dẹp.

## Điều kiện tiên quyết

- Stack local đang chạy (`make dev`), `check_stack` trong `frontend/e2e/lib.sh` báo OK (API `http://localhost:8000/healthz` và web `http://localhost:5173` phản hồi).

## Dữ liệu kiểm thử

- 10 tệp ~20 MB có header `%PDF-` (`make_pdf big20mb`); worker sẽ đánh dấu chúng `corrupted` sau đó — không ảnh hưởng phép đo.

## Các bước thực hiện

| # | Thao tác | Kết quả mong đợi | 📸 |
|---|---|---|---|
| 1 | Kiểm tra stack localhost và dọn dữ liệu | `Stack OK`; lệnh TRUNCATE thành công | 📸 |
| 2 | Sinh 10 tệp 20 MB | 10 tệp trong `data/` | 📸 |
| 3 | Đo RAM nền của api | Một giá trị `MemUsage` | 📸 |
| 4 | Tải lên trong khi lấy mẫu RAM mỗi giây | HTTP 202, 10 item `queued` | 📸 |
| 5 | Tính mức tăng RAM | `tang_MiB` ≤ 100 | 📸 |

## Script gợi ý (`steps.sh`)

```bash
#!/usr/bin/env bash
# PERF-003 — Tải lô 10 × 20 MB: RAM api tăng ≤ 100 MB
# Chạy từ gốc repo: node frontend/e2e/run-cli.mjs PERF-003 test_reports/PERF-003/steps.sh
set -uo pipefail
source frontend/e2e/lib.sh

echo "### Bước 1: Kiểm tra stack localhost và dọn dữ liệu"
check_stack || exit 1
reset_data

echo "### Bước 2: Sinh 10 tệp 20 MB"
for i in $(seq -w 1 10); do make_pdf big20mb "$DATA_DIR/lon_$i.pdf" >/dev/null; done; ls -lh "$DATA_DIR"

echo "### Bước 3: Đo RAM nền của api"
id=$("${COMPOSE[@]}" ps -q api); docker stats --no-stream --format '{{.Name}} {{.MemUsage}}' "$id"

echo "### Bước 4: Tải lên trong khi lấy mẫu RAM mỗi giây"
id=$("${COMPOSE[@]}" ps -q api); (for i in $(seq 1 40); do docker stats --no-stream --format '{{.MemUsage}}' "$id"; done > "$DATA_DIR/mem.txt") & sp=$!; upload "$DATA_DIR"/lon_*.pdf; sleep 3; kill $sp 2>/dev/null; wait $sp 2>/dev/null; true

echo "### Bước 5: Tính mức tăng RAM"
python3 - "$DATA_DIR/mem.txt" <<'PY'
import re,sys
v=[]
for l in open(sys.argv[1]):
    m=re.match(r'([\d.]+)(KiB|MiB|GiB)',l.strip())
    if m: v.append(float(m[1])*{'KiB':1/1024,'MiB':1,'GiB':1024}[m[2]])
print('mau:',len(v),'min_MiB:',round(min(v),1),'max_MiB:',round(max(v),1),'tang_MiB:',round(max(v)-min(v),1))
PY
```

## Tiêu chí đạt

Upload trả 202 và `tang_MiB` ≤ 100.

Kết luận **⛔ Bị chặn** khi thiếu điều kiện tiên quyết (stack không chạy, thiếu khóa API, thiếu dữ liệu), không phải do lỗi của ứng dụng.

## Dọn dẹp sau test

- `reset_data`

## Ghi chú

- Local không có Nginx (`client_max_body_size`); giới hạn kích thước request qua Nginx chỉ kiểm được trên AWS.
