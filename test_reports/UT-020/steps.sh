#!/usr/bin/env bash
# UT-020 — Adapter Claude: refusal trả câu "không tìm thấy"
# Chạy từ gốc repo: node frontend/e2e/run-cli.mjs UT-020 test_reports/UT-020/steps.sh
set -uo pipefail
source frontend/e2e/lib.sh

echo "### Bước 1: Ghi nhận môi trường: commit, phiên bản Python và trạng thái stack localhost"
git rev-parse --short HEAD; backend/.venv/bin/python --version; check_stack || echo '(stack chưa chạy — không ảnh hưởng unit test)'

echo "### Bước 2: Chạy tests/unit/test_anthropic_adapter.py::test_refusal_returns_not_found_answer"
(cd backend && .venv/bin/pytest 'tests/unit/test_anthropic_adapter.py::test_refusal_returns_not_found_answer' -v)
