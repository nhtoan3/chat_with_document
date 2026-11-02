#!/usr/bin/env bash
# UT-008 — AppError được render thành problem+json
# Chạy từ gốc repo: node frontend/e2e/run-cli.mjs UT-008 test_reports/UT-008/steps.sh
set -uo pipefail
source frontend/e2e/lib.sh

echo "### Bước 1: Ghi nhận môi trường: commit, phiên bản Python và trạng thái stack localhost"
git rev-parse --short HEAD; backend/.venv/bin/python --version; check_stack || echo '(stack chưa chạy — không ảnh hưởng unit test)'

echo "### Bước 2: Chạy tests/unit/test_errors_and_upload_helpers.py::test_app_error_is_problem_json"
(cd backend && .venv/bin/pytest 'tests/unit/test_errors_and_upload_helpers.py::test_app_error_is_problem_json' -v)
