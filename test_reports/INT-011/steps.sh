#!/usr/bin/env bash
# INT-011 — GET /documents: danh sách, counts, thứ tự
# Chạy từ gốc repo: node frontend/e2e/run-cli.mjs INT-011 test_reports/INT-011/steps.sh
set -uo pipefail
source frontend/e2e/lib.sh

echo "### Bước 1: Kiểm tra stack localhost và dọn dữ liệu"
check_stack || exit 1
reset_data

echo "### Bước 2: Tải lên 3 PDF mẫu, sau 2 giây tải thêm corrupted.pdf"
seed_samples; sleep 2; upload "$FIXTURES/corrupted.pdf"

echo "### Bước 3: Gọi GET ngay khi còn tài liệu đang xử lý"
curl -sS "$API_URL/api/v1/documents" | jq '{counts, by_status: (.items | group_by(.status) | map({(.[0].status): length}) | add)}'

echo "### Bước 4: Chờ xử lý xong rồi gọi lại"
wait_idle 300; curl -sS "$API_URL/api/v1/documents" | jq '{counts, limit}'

echo "### Bước 5: Kiểm tra trường và thứ tự"
curl -sS "$API_URL/api/v1/documents" | jq '{keys: (.items[0] | keys), order: [.items[].filename], sorted_desc: ([.items[].uploaded_at] == ([.items[].uploaded_at] | sort | reverse))}'
