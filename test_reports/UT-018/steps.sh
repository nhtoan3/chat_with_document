#!/usr/bin/env bash
# UT-018 — Adapter Claude: TypeError không liên quan không bị nuốt
# Chạy từ gốc repo: node frontend/e2e/run-cli.mjs UT-018 test_reports/UT-018/steps.sh
set -uo pipefail
source frontend/e2e/lib.sh

echo "### Bước 1: Ghi nhận môi trường: commit, phiên bản Python và trạng thái stack localhost"
git rev-parse --short HEAD; backend/.venv/bin/python --version; check_stack || echo '(stack chưa chạy — không ảnh hưởng unit test)'

echo "### Bước 2: Chạy tests/unit/test_anthropic_adapter.py::test_unrelated_type_error_is_not_swallowed"
(cd backend && .venv/bin/pytest 'tests/unit/test_anthropic_adapter.py::test_unrelated_type_error_is_not_swallowed' -v)
