#!/usr/bin/env bash
# UT-015 — Use case hỏi đáp: lỗi dịch vụ ngoài thành kết quả lỗi
# Chạy từ gốc repo: node frontend/e2e/run-cli.mjs UT-015 test_reports/UT-015/steps.sh
set -uo pipefail
source frontend/e2e/lib.sh

echo "### Bước 1: Ghi nhận môi trường: commit, phiên bản Python và trạng thái stack localhost"
git rev-parse --short HEAD; backend/.venv/bin/python --version; check_stack || echo '(stack chưa chạy — không ảnh hưởng unit test)'

echo "### Bước 2: Chạy tests/unit/test_ask_usecase.py::test_external_failure_is_error_outcome"
(cd backend && .venv/bin/pytest 'tests/unit/test_ask_usecase.py::test_external_failure_is_error_outcome' -v)
