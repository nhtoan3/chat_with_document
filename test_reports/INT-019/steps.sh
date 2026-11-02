#!/usr/bin/env bash
# INT-019 — TEI lỗi khi hỏi → 503 ai_unavailable
# Chạy từ gốc repo: node frontend/e2e/run-cli.mjs INT-019 test_reports/INT-019/steps.sh
set -uo pipefail
source frontend/e2e/lib.sh

echo "### Bước 1: Kiểm tra stack localhost và dọn dữ liệu"
check_stack || exit 1
reset_data

echo "### Bước 2: Nạp PDF mẫu"
seed_samples; wait_idle 300

echo "### Bước 3: Dừng TEI"
"${COMPOSE[@]}" stop tei

echo "### Bước 4: Hỏi một câu"
ask 'Minh Phát đề xuất mức chiết khấu bao nhiêu?'

echo "### Bước 5: Kiểm tra qa_log"
psql_q "SELECT id, status, latency_ms FROM qa_log ORDER BY id DESC LIMIT 1;"

echo "### Bước 6: Bật lại TEI"
"${COMPOSE[@]}" start tei; sleep 5; "${COMPOSE[@]}" ps tei
