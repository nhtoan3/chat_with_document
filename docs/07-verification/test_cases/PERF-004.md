# PERF-004 — AI không phản hồi: báo lỗi trong ≤ 30 giây

> Nguồn: [Test_Plan.md](../Test_Plan.md) §6.3.7 · Danh sách test case: [README.md](README.md)

| Thuộc tính | Giá trị |
|---|---|
| Mã test case | `PERF-004` |
| Mức / loại | Hiệu năng / độ tin cậy |
| Ưu tiên | P1 |
| Yêu cầu truy vết | NFR-020, EC-06, AC-US-011-8 |
| Task | T-019, T-021 |
| Test tự động có sẵn | — |
| Cách ghi bằng chứng | CLI + UI — cả `run-cli.mjs` và `evidence.mjs` |
| URL kiểm thử | Web `http://localhost:5173` · API `http://localhost:8000` |
| Thư mục artifact | `./test_reports/PERF-004/` |

## Mục tiêu

Khi Claude không phản hồi, giao diện hiện "Hệ thống đang bận, vui lòng thử lại." trong ≤ 30 s và không treo.

## Nhiệm vụ của agent

1. Thực hiện test **chỉ trên localhost**: web `http://localhost:5173`, API `http://localhost:8000` (các dịch vụ phụ cũng ở localhost). Không gọi môi trường AWS.
2. Lưu **mọi** artifact của test case này trong thư mục riêng `./test_reports/PERF-004/` (tính từ gốc repo). Chạy lại thì xóa thư mục cũ trước: `rm -rf test_reports/PERF-004`.
3. **Quay video** toàn bộ quá trình thực hiện test → `./test_reports/PERF-004/video.webm` (nhiều phiên thì `video-02.webm`, …).
4. **Chụp ảnh màn hình** làm bằng chứng tại mỗi bước có 📸 → `./test_reports/PERF-004/screenshots/NN-<mô-tả>.png`.
5. Lưu output lệnh, log và dữ liệu sinh ra vào `./test_reports/PERF-004/logs/` và `./test_reports/PERF-004/data/`.
6. **Tạo báo cáo** `./test_reports/PERF-004/report.md` theo [mẫu ở README §5](README.md#5-mẫu-báo-cáo-reportmd): kết quả từng bước, ảnh nhúng, liên kết video, kết luận ✅ Đạt / ❌ Không đạt / ⛔ Bị chặn.
7. Phần CLI: lưu script vào `./test_reports/PERF-004/steps.sh` (mẫu bên dưới) rồi chạy `node frontend/e2e/run-cli.mjs PERF-004 test_reports/PERF-004/steps.sh` từ gốc repo — công cụ tự quay video, chụp ảnh khi kết thúc mỗi bước `### ` và lưu log.
8. Phần UI: viết script Playwright `./test_reports/PERF-004/PERF-004.mjs` dùng `startEvidence('PERF-004')` từ `frontend/e2e/evidence.mjs` (`caption()` đầu mỗi bước, `shot()` tại mỗi 📸, `finish()` ở cuối) và chạy `node test_reports/PERF-004/PERF-004.mjs` từ gốc repo. Xem ví dụ ở README §4.
9. Không sửa mã ứng dụng để test đạt. Bước nào lỗi thì ghi lại và tiếp tục các bước độc lập còn lại; luôn thực hiện phần dọn dẹp.

## Điều kiện tiên quyết

- Stack local đang chạy (`make dev`), `check_stack` trong `frontend/e2e/lib.sh` báo OK (API `http://localhost:8000/healthz` và web `http://localhost:5173` phản hồi).
- Đã chạy `npm ci` trong `frontend/` (có Playwright 1.64.1).
- Có ≥ 1 tài liệu Sẵn sàng.

## Dữ liệu kiểm thử

- File override `test_reports/PERF-004/data/compose.override.yml` trỏ Anthropic tới địa chỉ không phản hồi:
  ```yaml
  services:
    api:
      environment:
        ANTHROPIC_API_KEY: sk-ant-dummy
        ANTHROPIC_BASE_URL: http://10.255.255.1:81
  ```

## Các bước thực hiện

| # | Thao tác | Kết quả mong đợi | 📸 |
|---|---|---|---|
| 1 | (CLI) Chuẩn bị: nạp tài liệu, khởi động lại api với override | api chạy lại; `/healthz` 200 | 📸 |
| 2 | (UI) Mở `/ask`, gửi "Mức phạt khi chậm thanh toán là bao nhiêu?", bấm giờ từ lúc gửi | Spinner "Đang tìm câu trả lời…"; giao diện vẫn thao tác được (cuộn, gõ) | 📸 |
| 3 | (UI) Chờ tối đa 200 s tới khi xuất hiện thông báo lỗi; chụp ảnh lúc 30 s và lúc thông báo xuất hiện | "Hệ thống đang bận, vui lòng thử lại." + nút "Hỏi lại" xuất hiện trong **≤ 30 s**. Ghi số giây thực tế vào báo cáo | 📸 |
| 4 | (CLI) Khôi phục api | api chạy lại với cấu hình gốc | 📸 |

## Script gợi ý (`steps.sh`)

Chỉ gồm các bước CLI; các bước UI làm bằng script Playwright.

```bash
#!/usr/bin/env bash
# PERF-004 — AI không phản hồi: báo lỗi trong ≤ 30 giây
# Chạy từ gốc repo: node frontend/e2e/run-cli.mjs PERF-004 test_reports/PERF-004/steps.sh
set -uo pipefail
source frontend/e2e/lib.sh

echo "### Bước 1: (CLI) Chuẩn bị: nạp tài liệu, khởi động lại api với override"
check_stack || exit 1; reset_data; seed_samples; wait_idle 300
printf 'services:\n  api:\n    environment:\n      ANTHROPIC_API_KEY: sk-ant-dummy\n      ANTHROPIC_BASE_URL: http://10.255.255.1:81\n' > "$DATA_DIR/compose.override.yml"
docker compose -f docker-compose.yml -f "$DATA_DIR/compose.override.yml" up -d --force-recreate api; for i in $(seq 1 30); do curl -fsS "$API_URL/healthz" >/dev/null && break; sleep 2; done; echo healthz OK

echo "### Bước 4: (CLI) Khôi phục api"
"${COMPOSE[@]}" up -d --force-recreate api; sleep 5; check_stack; reset_data
```

## Tiêu chí đạt

Thời gian tới khi hiện thông báo lỗi ≤ 30 s.

Kết luận **⛔ Bị chặn** khi thiếu điều kiện tiên quyết (stack không chạy, thiếu khóa API, thiếu dữ liệu), không phải do lỗi của ứng dụng.

## Dọn dẹp sau test

- Bước 4 (khôi phục api, `reset_data`)

## Ghi chú

- Dự kiến **không đạt** với cấu hình hiện tại (`llm_timeout_s = 60`, `max_retries = 2`) — xem RISK-008 trong Test_Plan. Ghi số đo thực tế để Tech lead / PO quyết định.
- Chạy bước 1 và 4 bằng `run-cli.mjs` (tách thành `steps-setup.sh`, `steps-restore.sh`), bước 2–3 bằng script Playwright; thư mục sẽ có `video.webm` và `video-02.webm`, `video-03.webm`.
