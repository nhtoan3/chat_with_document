#!/usr/bin/env bash
# UT-009 — Chuẩn hóa tên tệp: bỏ đường dẫn, giới hạn độ dài
# Chạy từ gốc repo: node frontend/e2e/run-cli.mjs UT-009 test_reports/UT-009/steps.sh
set -uo pipefail
source frontend/e2e/lib.sh

echo "### Bước 1: Ghi nhận môi trường: commit, phiên bản Python và trạng thái stack localhost"
git rev-parse --short HEAD; backend/.venv/bin/python --version; check_stack || echo '(stack chưa chạy — không ảnh hưởng unit test)'

echo "### Bước 2: Chạy tests/unit/test_errors_and_upload_helpers.py::test_normalize_filename_strips_paths_and_limits_length"
(cd backend && .venv/bin/pytest 'tests/unit/test_errors_and_upload_helpers.py::test_normalize_filename_strips_paths_and_limits_length' -v)
