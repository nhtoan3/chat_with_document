#!/usr/bin/env bash
# INT-010 — Thu hồi job treo (running quá hạn)
# Chạy từ gốc repo: node frontend/e2e/run-cli.mjs INT-010 test_reports/INT-010/steps.sh
set -uo pipefail
source frontend/e2e/lib.sh

echo "### Bước 1: Ghi nhận môi trường localhost"
git rev-parse --short HEAD; check_stack || echo '(stack chưa chạy — không ảnh hưởng test này)'

echo "### Bước 2: Chạy test tự động tests/integration/test_documents.py::test_stale_running_job_is_reclaimed (Testcontainers)"
(cd backend && .venv/bin/pytest 'tests/integration/test_documents.py::test_stale_running_job_is_reclaimed' -v)
