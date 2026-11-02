#!/usr/bin/env bash
# INT-016 — Body không hợp lệ → 422 question_invalid (problem+json)
# Chạy từ gốc repo: node frontend/e2e/run-cli.mjs INT-016 test_reports/INT-016/steps.sh
set -uo pipefail
source frontend/e2e/lib.sh

echo "### Bước 1: Kiểm tra stack localhost và dọn dữ liệu"
check_stack || exit 1
reset_data

echo "### Bước 2: Body không phải JSON"
curl -sS -i -X POST "$API_URL/api/v1/ask" -H 'content-type: application/json' -d 'khong-phai-json'

echo "### Bước 3: Body {}"
curl -sS -w '\nHTTP %{http_code}\n' -X POST "$API_URL/api/v1/ask" -H 'content-type: application/json' -d '{}'

echo "### Bước 4: Body {\"question\": 123}"
curl -sS -w '\nHTTP %{http_code}\n' -X POST "$API_URL/api/v1/ask" -H 'content-type: application/json' -d '{"question": 123}'
