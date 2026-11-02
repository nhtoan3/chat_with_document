#!/usr/bin/env bash
# INT-002 — Tải 11 tệp: từ chối cả lô
# Chạy từ gốc repo: node frontend/e2e/run-cli.mjs INT-002 test_reports/INT-002/steps.sh
set -uo pipefail
source frontend/e2e/lib.sh

echo "### Bước 1: Chạy test tự động tests/integration/test_documents.py::test_too_many_files_rejects_whole_batch (Testcontainers)"
(cd backend && .venv/bin/pytest 'tests/integration/test_documents.py::test_too_many_files_rejects_whole_batch' -v)

echo "### Bước 2: Kiểm tra stack localhost và dọn dữ liệu"
check_stack || exit 1
reset_data

echo "### Bước 3: Tạo 11 PDF hợp lệ có tên khác nhau"
for i in $(seq -w 1 11); do cp "$FIXTURES/sample/Hop_dong_khung_ABC_2026.pdf" "$DATA_DIR/tep_$i.pdf"; done; ls "$DATA_DIR"

echo "### Bước 4: Tải lên 11 tệp trong một request"
upload "$DATA_DIR"/tep_*.pdf

echo "### Bước 5: Kiểm tra không có tài liệu nào được lưu"
counts
