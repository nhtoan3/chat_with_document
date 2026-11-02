#!/usr/bin/env bash
# INT-017 — Không có tài liệu Sẵn sàng → 409 no_documents
# Chạy từ gốc repo: node frontend/e2e/run-cli.mjs INT-017 test_reports/INT-017/steps.sh
set -uo pipefail
source frontend/e2e/lib.sh

echo "### Bước 1: Chạy test tự động tests/integration/test_ask.py::test_no_ready_documents (Testcontainers)"
(cd backend && .venv/bin/pytest 'tests/integration/test_ask.py::test_no_ready_documents' -v)

echo "### Bước 2: Kiểm tra stack localhost và dọn dữ liệu"
check_stack || exit 1
reset_data

echo "### Bước 3: Hỏi khi bộ tài liệu rỗng"
ask 'Điều khoản tạm ứng là gì?'

echo "### Bước 4: Tải lên corrupted.pdf, chờ failed, hỏi lại"
upload "$FIXTURES/corrupted.pdf"; wait_idle 120; ask 'Điều khoản tạm ứng là gì?'

echo "### Bước 5: Kiểm tra qa_log"
psql_q "SELECT count(*) FROM qa_log;"
