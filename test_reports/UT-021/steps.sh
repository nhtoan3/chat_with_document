#!/usr/bin/env bash
# UT-021 — Chấm điểm eval: tỷ lệ và câu chưa chấm
# Chạy từ gốc repo: node frontend/e2e/run-cli.mjs UT-021 test_reports/UT-021/steps.sh
set -uo pipefail
source frontend/e2e/lib.sh

echo "### Bước 1: Ghi nhận môi trường: commit, phiên bản Python và trạng thái stack localhost"
git rev-parse --short HEAD; backend/.venv/bin/python --version; check_stack || echo '(stack chưa chạy — không ảnh hưởng unit test)'

echo "### Bước 2: Chạy tests/unit/test_eval_score.py::test_score_rates_and_ungraded"
(cd backend && .venv/bin/pytest 'tests/unit/test_eval_score.py::test_score_rates_and_ungraded' -v)
