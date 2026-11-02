#!/usr/bin/env bash
# INT-012 — Lỗi lưu trữ S3 khi tải lên → 502 storage_error
# Chạy từ gốc repo: node frontend/e2e/run-cli.mjs INT-012 test_reports/INT-012/steps.sh
set -uo pipefail
source frontend/e2e/lib.sh

echo "### Bước 1: Kiểm tra stack localhost và dọn dữ liệu"
check_stack || exit 1
reset_data

echo "### Bước 2: Dừng S3Mock"
"${COMPOSE[@]}" stop s3

echo "### Bước 3: Tải lên 1 PDF mẫu"
upload "$FIXTURES/sample/Hop_dong_khung_ABC_2026.pdf"

echo "### Bước 4: Kiểm tra không có bản ghi mồ côi"
psql_q "SELECT (SELECT count(*) FROM documents) AS documents, (SELECT count(*) FROM ingestion_jobs) AS jobs;"

echo "### Bước 5: Bật lại S3Mock và thử lại"
"${COMPOSE[@]}" start s3; sleep 5; upload "$FIXTURES/sample/Hop_dong_khung_ABC_2026.pdf"
