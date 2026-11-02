#!/usr/bin/env bash
# UT-016 — Prompt chứa đủ quy tắc bắt buộc và định dạng ngữ cảnh
# Chạy từ gốc repo: node frontend/e2e/run-cli.mjs UT-016 test_reports/UT-016/steps.sh
set -uo pipefail
source frontend/e2e/lib.sh

echo "### Bước 1: Ghi nhận môi trường: commit, phiên bản Python và trạng thái stack localhost"
git rev-parse --short HEAD; backend/.venv/bin/python --version; check_stack || echo '(stack chưa chạy — không ảnh hưởng unit test)'

echo "### Bước 2: Chạy tests/unit/test_ask_usecase.py::test_prompt_contains_required_rules_and_context_format"
(cd backend && .venv/bin/pytest 'tests/unit/test_ask_usecase.py::test_prompt_contains_required_rules_and_context_format' -v)
