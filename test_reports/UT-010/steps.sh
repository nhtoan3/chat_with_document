#!/usr/bin/env bash
# UT-010 — Backoff thử lại 10 / 40 / 160 giây
# Chạy từ gốc repo: node frontend/e2e/run-cli.mjs UT-010 test_reports/UT-010/steps.sh
set -uo pipefail
source frontend/e2e/lib.sh

echo "### Bước 1: Ghi nhận môi trường: commit, phiên bản Python và trạng thái stack localhost"
git rev-parse --short HEAD; backend/.venv/bin/python --version; check_stack || echo '(stack chưa chạy — không ảnh hưởng unit test)'

echo "### Bước 2: Chạy tests/unit/test_errors_and_upload_helpers.py::test_retry_backoff"
(cd backend && .venv/bin/pytest 'tests/unit/test_errors_and_upload_helpers.py::test_retry_backoff' -v)
