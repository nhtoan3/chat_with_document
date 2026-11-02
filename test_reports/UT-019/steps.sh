#!/usr/bin/env bash
# UT-019 — Adapter Claude: ghép các text block, bỏ thinking
# Chạy từ gốc repo: node frontend/e2e/run-cli.mjs UT-019 test_reports/UT-019/steps.sh
set -uo pipefail
source frontend/e2e/lib.sh

echo "### Bước 1: Ghi nhận môi trường: commit, phiên bản Python và trạng thái stack localhost"
git rev-parse --short HEAD; backend/.venv/bin/python --version; check_stack || echo '(stack chưa chạy — không ảnh hưởng unit test)'

echo "### Bước 2: Chạy tests/unit/test_anthropic_adapter.py::test_text_blocks_are_joined_and_thinking_ignored"
(cd backend && .venv/bin/pytest 'tests/unit/test_anthropic_adapter.py::test_text_blocks_are_joined_and_thinking_ignored' -v)
