#!/usr/bin/env bash
# INT-003 — Tải 0 tệp: trả lỗi too_many_files
# Chạy từ gốc repo: node frontend/e2e/run-cli.mjs INT-003 test_reports/INT-003/steps.sh
set -uo pipefail
source frontend/e2e/lib.sh

echo "### Bước 1: Kiểm tra stack localhost và dọn dữ liệu"
check_stack || exit 1
reset_data

echo "### Bước 2: POST multipart không có trường files"
curl -sS -w '\nHTTP %{http_code}\n' -X POST "$API_URL/api/v1/documents" -F 'other=x'

echo "### Bước 3: POST không có body"
curl -sS -w '\nHTTP %{http_code}\n' -X POST "$API_URL/api/v1/documents"
