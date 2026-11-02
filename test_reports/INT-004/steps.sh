#!/usr/bin/env bash
# INT-004 — Lô trộn: tệp lỗi không chặn tệp hợp lệ
# Chạy từ gốc repo: node frontend/e2e/run-cli.mjs INT-004 test_reports/INT-004/steps.sh
set -uo pipefail
source frontend/e2e/lib.sh

echo "### Bước 1: Chạy test tự động tests/integration/test_documents.py::test_per_file_errors_do_not_block_valid_files (Testcontainers)"
(cd backend && .venv/bin/pytest 'tests/integration/test_documents.py::test_per_file_errors_do_not_block_valid_files' -v)

echo "### Bước 2: Kiểm tra stack localhost và dọn dữ liệu"
check_stack || exit 1
reset_data

echo "### Bước 3: Sinh tệp 21 MB"
make_pdf big21mb "$DATA_DIR/qua_lon.pdf"

echo "### Bước 4: Tải lên lô 3 tệp"
upload "$FIXTURES/fake.pdf" "$DATA_DIR/qua_lon.pdf" "$FIXTURES/sample/Hop_dong_khung_ABC_2026.pdf"

echo "### Bước 5: Chờ xử lý và xem danh sách"
wait_idle 300; docs
