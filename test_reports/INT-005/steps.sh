#!/usr/bin/env bash
# INT-005 — Trùng tên tài liệu đã có
# Chạy từ gốc repo: node frontend/e2e/run-cli.mjs INT-005 test_reports/INT-005/steps.sh
set -uo pipefail
source frontend/e2e/lib.sh

echo "### Bước 1: Chạy test tự động tests/integration/test_documents.py::test_duplicate_name (Testcontainers)"
(cd backend && .venv/bin/pytest 'tests/integration/test_documents.py::test_duplicate_name' -v)

echo "### Bước 2: Kiểm tra stack localhost và dọn dữ liệu"
check_stack || exit 1
reset_data

echo "### Bước 3: Tải lên PDF mẫu lần 1"
upload "$FIXTURES/sample/Hop_dong_khung_ABC_2026.pdf"

echo "### Bước 4: Tải lên cùng tệp lần 2"
upload "$FIXTURES/sample/Hop_dong_khung_ABC_2026.pdf"

echo "### Bước 5: Đếm tài liệu"
counts
