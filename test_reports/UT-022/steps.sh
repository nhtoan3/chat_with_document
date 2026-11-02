#!/usr/bin/env bash
# UT-022 — Chấm điểm eval: nhận diện câu "không tìm thấy"
# Chạy từ gốc repo: node frontend/e2e/run-cli.mjs UT-022 test_reports/UT-022/steps.sh
set -uo pipefail
source frontend/e2e/lib.sh

echo "### Bước 1: Ghi nhận môi trường: commit, phiên bản Python và trạng thái stack localhost"
git rev-parse --short HEAD; backend/.venv/bin/python --version; check_stack || echo '(stack chưa chạy — không ảnh hưởng unit test)'

echo "### Bước 2: Chạy tests/unit/test_eval_score.py::test_not_found_detection"
(cd backend && .venv/bin/pytest 'tests/unit/test_eval_score.py::test_not_found_detection' -v)
