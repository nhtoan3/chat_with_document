#!/usr/bin/env bash
# OPS-002 — make seed nạp 3 PDF mẫu tới Sẵn sàng
# Chạy từ gốc repo: node frontend/e2e/run-cli.mjs OPS-002 test_reports/OPS-002/steps.sh
set -uo pipefail
source frontend/e2e/lib.sh

echo "### Bước 1: Kiểm tra stack localhost và dọn dữ liệu"
check_stack || exit 1
reset_data

echo "### Bước 2: Chạy make seed"
make seed

echo "### Bước 3: Chờ xử lý"
wait_idle 300
