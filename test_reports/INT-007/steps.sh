#!/usr/bin/env bash
# INT-007 — PDF lỗi được đánh dấu failed với mã tương ứng
# Chạy từ gốc repo: node frontend/e2e/run-cli.mjs INT-007 test_reports/INT-007/steps.sh
set -uo pipefail
source frontend/e2e/lib.sh

echo "### Bước 1: Chạy test tự động tests/integration/test_documents.py::test_bad_pdfs_fail_with_code (Testcontainers)"
(cd backend && .venv/bin/pytest 'tests/integration/test_documents.py::test_bad_pdfs_fail_with_code' -v)

echo "### Bước 2: Kiểm tra stack localhost và dọn dữ liệu"
check_stack || exit 1
reset_data

echo "### Bước 3: Sinh PDF 301 trang"
make_pdf pages301 "$DATA_DIR/301_pages.pdf"

echo "### Bước 4: Tải lên 4 tệp lỗi"
upload "$FIXTURES/encrypted.pdf" "$FIXTURES/scanned.pdf" "$FIXTURES/corrupted.pdf" "$DATA_DIR/301_pages.pdf"

echo "### Bước 5: Chờ xử lý và xem mã lỗi"
wait_idle 300; psql_q "SELECT filename, status, error_code FROM documents ORDER BY filename;"
