#!/usr/bin/env bash
# INT-020 — Lỗi không lường trước → 500 internal_error, không lộ stack trace
# Chạy từ gốc repo: node frontend/e2e/run-cli.mjs INT-020 test_reports/INT-020/steps.sh
set -uo pipefail
source frontend/e2e/lib.sh

echo "### Bước 1: Kiểm tra stack localhost"
check_stack || exit 1

echo "### Bước 2: Dừng PostgreSQL"
"${COMPOSE[@]}" stop postgres

echo "### Bước 3: Gọi GET /documents"
curl -sS -i "$API_URL/api/v1/documents" | tee "$DATA_DIR/resp.txt"

echo "### Bước 4: Tìm dấu vết kỹ thuật trong response"
grep -ciE 'traceback|File "|asyncpg|/app/' "$DATA_DIR/resp.txt" || true

echo "### Bước 5: Bật lại PostgreSQL"
"${COMPOSE[@]}" start postgres; for i in $(seq 1 30); do curl -fsS "$API_URL/api/v1/documents" >/dev/null && break; sleep 2; done; counts
