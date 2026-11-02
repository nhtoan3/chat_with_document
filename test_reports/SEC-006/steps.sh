#!/usr/bin/env bash
# SEC-006 — Không log nội dung câu hỏi, câu trả lời, tài liệu
# Chạy từ gốc repo: node frontend/e2e/run-cli.mjs SEC-006 test_reports/SEC-006/steps.sh
set -uo pipefail
source frontend/e2e/lib.sh

echo "### Bước 1: Kiểm tra stack localhost và dọn dữ liệu"
check_stack || exit 1
reset_data

echo "### Bước 2: Nạp PDF mẫu"
seed_samples; wait_idle 300

echo "### Bước 3: Hỏi 2 câu có chứa chuỗi đánh dấu"
M=MARKER-$RANDOM$RANDOM; echo $M > "$DATA_DIR/marker.txt"; ask "$M Điều khoản tạm ứng trong hợp đồng khung với ABC là gì?"; ask "$M Mức phạt khi chậm thanh toán là bao nhiêu?"

echo "### Bước 4: Xuất log api và worker"
"${COMPOSE[@]}" logs --no-color api worker > "$DATA_DIR/containers.log"; wc -l "$DATA_DIR/containers.log"

echo "### Bước 5: Tìm nội dung trong log"
M=$(cat "$DATA_DIR/marker.txt"); echo "marker: $(grep -c "$M" "$DATA_DIR/containers.log")"; echo "van_ban_tai_lieu: $(grep -c 'Tạm ứng 30%' "$DATA_DIR/containers.log")"; echo "cau_hoi: $(grep -c 'Mức phạt khi chậm' "$DATA_DIR/containers.log")"

echo "### Bước 6: Kiểm tra cột qa_log"
psql_q "SELECT column_name, data_type FROM information_schema.columns WHERE table_name = 'qa_log' ORDER BY ordinal_position;"
