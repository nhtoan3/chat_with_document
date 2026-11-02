#!/usr/bin/env bash
# INT-021 — /healthz trả 200
# Chạy từ gốc repo: node frontend/e2e/run-cli.mjs INT-021 test_reports/INT-021/steps.sh
set -uo pipefail
source frontend/e2e/lib.sh

echo "### Bước 1: Gọi /healthz"
curl -sS -i "$API_URL/healthz"

echo "### Bước 2: Gọi trang web gốc"
curl -sS -i "$WEB_URL/" | head -30
