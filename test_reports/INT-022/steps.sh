#!/usr/bin/env bash
# INT-022 — chỉ chạy tới bước chứng minh điều kiện tiên quyết thiếu (không có ANTHROPIC_API_KEY).
# Các bước cần Claude thật KHÔNG chạy và KHÔNG giả lập: test case kết luận ⛔ Bị chặn khi không có khóa.
set -uo pipefail
source frontend/e2e/lib.sh

echo "### Bước 1: Kiểm tra stack localhost và dọn dữ liệu"
check_stack || exit 1
reset_data

echo "### Bước 2: Nạp tài liệu và chờ Sẵn sàng"
seed_samples; wait_idle 300

echo "### Bước 3: Xác nhận điều kiện tiên quyết: có khóa API trong container api?"
"${COMPOSE[@]}" exec -T api sh -c 'echo "len(ANTHROPIC_API_KEY)=${#ANTHROPIC_API_KEY}"'
ls -la .env 2>&1 | sed 's/^/.env: /'
ask 'Điều khoản tạm ứng trong hợp đồng khung với ABC là gì?'
