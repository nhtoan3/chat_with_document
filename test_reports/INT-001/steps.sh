#!/usr/bin/env bash
# INT-001 — Tải lên 3 PDF hợp lệ rồi xử lý tới Sẵn sàng
# Chạy từ gốc repo: node frontend/e2e/run-cli.mjs INT-001 test_reports/INT-001/steps.sh
set -uo pipefail
source frontend/e2e/lib.sh

echo "### Bước 1: Chạy test tự động tests/integration/test_documents.py::test_upload_three_valid_pdfs_then_ingest (Testcontainers)"
(cd backend && .venv/bin/pytest 'tests/integration/test_documents.py::test_upload_three_valid_pdfs_then_ingest' -v)

echo "### Bước 2: Kiểm tra stack localhost và dọn dữ liệu"
check_stack || exit 1
reset_data

echo "### Bước 3: Tải lên 3 PDF mẫu"
seed_samples

echo "### Bước 4: Chờ worker xử lý xong"
wait_idle 300

echo "### Bước 5: Kiểm tra trạng thái, số trang và số chunk trong CSDL"
psql_q "SELECT d.filename, d.status, d.pages, count(c.id) AS chunks FROM documents d LEFT JOIN chunks c ON c.document_id = d.id GROUP BY 1,2,3 ORDER BY 1;"
