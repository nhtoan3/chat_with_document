#!/usr/bin/env bash
# OPS-008 — Thiếu ANTHROPIC_API_KEY: /ask 503, phần còn lại vẫn chạy
# Chạy từ gốc repo: node frontend/e2e/run-cli.mjs OPS-008 test_reports/OPS-008/steps.sh
set -uo pipefail
source frontend/e2e/lib.sh

echo "### Bước 1: Kiểm tra stack localhost và dọn dữ liệu"
check_stack || exit 1
reset_data

echo "### Bước 2: Khởi động lại api với khóa rỗng"
ANTHROPIC_API_KEY= "${COMPOSE[@]}" up -d --force-recreate api; for i in $(seq 1 30); do curl -fsS "$API_URL/healthz" >/dev/null && break; sleep 2; done; "${COMPOSE[@]}" exec -T api sh -c 'echo "len(ANTHROPIC_API_KEY)=${#ANTHROPIC_API_KEY}"'

echo "### Bước 3: Tải lên và chờ Sẵn sàng"
seed_samples; wait_idle 300

echo "### Bước 4: Hỏi một câu"
ask 'Điều khoản tạm ứng là gì?'

echo "### Bước 5: Gọi danh sách tài liệu"
curl -sS -o /dev/null -w 'GET /documents %{http_code}\n' "$API_URL/api/v1/documents"

echo "### Bước 6: Khôi phục api với .env"
"${COMPOSE[@]}" up -d --force-recreate api; sleep 5; check_stack
