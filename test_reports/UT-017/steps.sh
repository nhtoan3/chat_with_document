#!/usr/bin/env bash
# UT-017 — Adapter Claude: lỗi API được ánh xạ thành LLM unavailable
# Chạy từ gốc repo: node frontend/e2e/run-cli.mjs UT-017 test_reports/UT-017/steps.sh
set -uo pipefail
source frontend/e2e/lib.sh

echo "### Bước 1: Ghi nhận môi trường: commit, phiên bản Python và trạng thái stack localhost"
git rev-parse --short HEAD; backend/.venv/bin/python --version; check_stack || echo '(stack chưa chạy — không ảnh hưởng unit test)'

echo "### Bước 2: Chạy tests/unit/test_anthropic_adapter.py::test_failures_map_to_llm_unavailable"
(cd backend && .venv/bin/pytest 'tests/unit/test_anthropic_adapter.py::test_failures_map_to_llm_unavailable' -v)
