#!/usr/bin/env bash
# INT-015 — Câu hỏi rỗng / quá dài → 422 question_invalid
# Chạy từ gốc repo: node frontend/e2e/run-cli.mjs INT-015 test_reports/INT-015/steps.sh
set -uo pipefail
source frontend/e2e/lib.sh

echo "### Bước 1: Chạy test tự động tests/integration/test_ask.py::test_invalid_question (Testcontainers)"
(cd backend && .venv/bin/pytest 'tests/integration/test_ask.py::test_invalid_question' -v)

echo "### Bước 2: Kiểm tra stack localhost và dọn dữ liệu"
check_stack || exit 1
reset_data

echo "### Bước 3: Hỏi chuỗi rỗng"
ask ''

echo "### Bước 4: Hỏi chuỗi chỉ có khoảng trắng"
ask '     '

echo "### Bước 5: Hỏi chuỗi 2001 ký tự"
ask "$(printf 'a%.0s' $(seq 1 2001))"

echo "### Bước 6: Hỏi chuỗi đúng 2000 ký tự (chưa có tài liệu)"
ask "$(printf 'a%.0s' $(seq 1 2000))"
